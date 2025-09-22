local json = require("lib.json")
local uri = require("util.uri")
local socket = require("socket")

---@class ScreenscraperClient
local M = class({
    name = "ScreenscraperClient",
})

----------------------------------------------------------------
-- CONSTANTS (do not mutate at runtime)
----------------------------------------------------------------
local BACKOFF_SEQUENCE_QUANTA = { 2, 4, 8, 16 } -- each step is a multiple of quantumStepMs
local QUOTA_REFRESH_INTERVAL_SECONDS = 5
local DEFAULT_HEADROOM_FACTOR = 0.95
local DEFAULT_QUANTUM_STEP_MS = 100
local DEFAULT_DAILY_RELEVANCE_THRESHOLD = 0.25

----------------------------------------------------------------
-- Centralized status-code handling
----------------------------------------------------------------
local CLOSE_IMMEDIATELY = {
    [401] = "Closed API For Non Members", -- server CPU too high
    [403] = "Forbidden, bad credentials", -- bad creds
    [423] = "API Totally Closed", -- server error
    [426] = "Software Blacklisted",
    [430] = "Daily Quota Exceeded", -- ran out of scrapes
    [431] = "Too many searches with zero results", -- ran out of KO scrapes
    [418] = "Too Many Threads Selected by User: %s. Only allowed: %s", -- not a server error but one I throw myself when people set too many threads
}

----------------------------------------------------------------
-- Utilities
----------------------------------------------------------------
local function quantizeUp(valueMs, quantumStepMs)
    local q = math.max(1, quantumStepMs or DEFAULT_QUANTUM_STEP_MS)
    return math.floor((valueMs + q - 1) / q) * q
end

local function nowMs()
    return socket.gettime() * 1000
end

----------------------------------------------------------------
-- Instance
----------------------------------------------------------------
function M:new(environment, logger, https, scraperRepository)
    self.environment = environment
    self.logger = logger
    self.https = https
    self.scraperRepository = scraperRepository

    self.devCredentials = {
        devid = "duckdownroms",
        devpassword = "enafiBfBA7B",
    }
    self.userCredentials = {
        ssid = environment:getConfig("scraper_screenscraper_user"),
        sspassword = environment:getConfig("scraper_screenscraper_password"),
    }
    self.output = "json" -- xml
    self.softname = string.format("boxartbuddy-%s", environment:getVersion())
    self.baseUri = "https://www.screenscraper.fr/api2/"

    -- Controller config (set via setRateOptions)
    self.totalWorkerCount = 1
    self.headroomFactor = DEFAULT_HEADROOM_FACTOR
    self.quantumStepMs = DEFAULT_QUANTUM_STEP_MS
    self.minimumDelayMs = 200
    self.plannedTotalRequests = nil
    self.dailyRelevanceThreshold = DEFAULT_DAILY_RELEVANCE_THRESHOLD
    self.dailyWindow = 24
    self.skipInterval = 14

    -- Controller state
    self.status = "open" -- "open" | "backingOff" | "closed"
    self.closedCode = nil
    self.closedMessage = nil
    self.baselineIntervalMs = nil
    self.currentIntervalMs = nil
    self.backoffStepIndex = 1
    self.lastQuotaRefreshMs = 0
end

----------------------------------------------------------------
-- Public config API
----------------------------------------------------------------
---@param opts table
--[[
opts = {
  threads: integer,
  headroomFactor: number,
  quantumStepMs: integer,
  minimumDelayMs: integer,
  plannedTotalRequests: integer|nil,
  dailyRelevanceThreshold: number|nil
}
]]
function M:setOptions(opts)
    if not opts then
        return
    end
    if opts.threads then
        self.totalWorkerCount = math.max(1, opts.threads)
    end
    if opts.headroomFactor then
        self.headroomFactor = opts.headroomFactor
    end
    if opts.quantumStepMs then
        self.quantumStepMs = math.max(20, opts.quantumStepMs)
    end
    if opts.minimumDelayMs then
        self.minimumDelayMs = math.max(0, opts.minimumDelayMs)
    end
    if opts.plannedTotalRequests ~= nil then
        self.plannedTotalRequests = opts.plannedTotalRequests
    end
    if opts.dailyRelevanceThreshold then
        self.dailyRelevanceThreshold = opts.dailyRelevanceThreshold
    end
    if opts.dailyWindow then
        self.dailyWindow = math.max(1, math.min(24, opts.dailyWindow))
    end
    if opts.skipInterval then
        self.skipInterval = math.max(0, math.min(28, opts.skipInterval))
    end
end

-- Build the common query parameters, omitting ssid/sspassword when non-member
function M:buildQuery()
    local query = {
        devid = self.devCredentials.devid,
        devpassword = self.devCredentials.devpassword,
        softname = self.softname,
        output = self.output,
    }
    if self.userCredentials.ssid and self.userCredentials.sspassword then
        query.ssid = self.userCredentials.ssid
        query.sspassword = self.userCredentials.sspassword
    end
    return query
end

function M:isClosed()
    return self.status == "closed"
end

function M:getCloseState()
    if self.status ~= "closed" then
        return nil
    end
    return { status = self.status, code = self.closedCode, message = self.closedMessage }
end

-- Raise immediately if the client has been closed (callers should wrap in pcall).
function M:ensureOpen()
    if self.status == "closed" then
        error(
            string.format("Screenscraper client closed: %s %s", tostring(self.closedCode), tostring(self.closedMessage)),
            2
        )
    end
end

----------------------------------------------------------------
-- Baseline calculation (from quotas)
----------------------------------------------------------------
local function computePerMinuteRps(maxRequestsPerMinute, headroomFactor, totalWorkerCount)
    local perMinuteShare = math.floor((maxRequestsPerMinute * headroomFactor) / totalWorkerCount)
    return perMinuteShare / 60
end

local function computeDailyRelevance(plannedTotalRequests, totalWorkerCount, dailyRemaining, threshold)
    if plannedTotalRequests == nil then
        return true
    end
    local perWorkerPlanned = plannedTotalRequests / totalWorkerCount
    return perWorkerPlanned > (dailyRemaining * (threshold or DEFAULT_DAILY_RELEVANCE_THRESHOLD))
end

function M:computeInitialBaselineIntervalMs(maxRequestsPerMinute, maxRequestsPerDay, requestsToday)
    local minuteRps = computePerMinuteRps(maxRequestsPerMinute, self.headroomFactor, self.totalWorkerCount)

    local dailyRemaining = math.max(0, (maxRequestsPerDay or 0) - (requestsToday or 0))
    local dailyRelevant = computeDailyRelevance(
        self.plannedTotalRequests,
        self.totalWorkerCount,
        dailyRemaining,
        self.dailyRelevanceThreshold
    )

    local targetRps
    if dailyRelevant then
        -- Use configured dailyWindow (hours) for per-day pacing instead of full-day reset
        local windowSeconds = (self.dailyWindow or 24) * 3600
        local dailyRps = ((dailyRemaining * self.headroomFactor) / self.totalWorkerCount) / windowSeconds
        targetRps = math.min(minuteRps, dailyRps)
    else
        targetRps = minuteRps
    end

    if targetRps <= 0 then
        return quantizeUp(self.minimumDelayMs, self.quantumStepMs), dailyRelevant
    end

    local rawMs = 1000 / targetRps
    local floored = math.max(rawMs, self.minimumDelayMs)
    return quantizeUp(floored, self.quantumStepMs), dailyRelevant
end

function M:applyDelayIfChanged(newIntervalMs, reason, extra)
    if newIntervalMs == nil then
        return
    end
    if self.currentIntervalMs == nil or math.abs(newIntervalMs - self.currentIntervalMs) >= self.quantumStepMs then
        self.currentIntervalMs = newIntervalMs
        self.https:setDelay(self.currentIntervalMs)
        if self.logger then
            self.logger:log(
                "info",
                "screenscraper",
                string.format(
                    "[rate] %s interval=%dms baseline=%s quantum=%d headroom=%.2f minDelay=%d%s",
                    reason,
                    self.currentIntervalMs,
                    tostring(self.baselineIntervalMs),
                    self.quantumStepMs,
                    self.headroomFactor,
                    self.minimumDelayMs,
                    extra and (" " .. extra) or ""
                )
            )
        end
    end
end

----------------------------------------------------------------
-- Quota refresh (every 20s)
----------------------------------------------------------------
function M:handleQuotaRefresh(ssuser, serveurs)
    if not ssuser then
        return
    end
    local now = nowMs()
    if self.baselineIntervalMs and (now - self.lastQuotaRefreshMs) < (QUOTA_REFRESH_INTERVAL_SECONDS * 1000) then
        return
    end
    self.lastQuotaRefreshMs = now

    local maxPerMinute = tonumber(ssuser.maxrequestspermin or 0) or 0
    local maxPerDay = tonumber(ssuser.maxrequestsperday or 0) or 0
    local requestsToday = tonumber(ssuser.requeststoday or 0) or 0

    local baselineNew, dailyRelevant = self:computeInitialBaselineIntervalMs(maxPerMinute, maxPerDay, requestsToday)
    -- Combine quota baseline and thread-load adjustment
    local adjustedBaseline = baselineNew

    -- Thread-load scaling (member mode only)
    local multiplier = 1
    if
        self.userCredentials.ssid
        and self.userCredentials.sspassword
        and serveurs
        and tonumber(serveurs.threadformember or 0) > 0
        and tonumber(serveurs.maxthreadformember or 0) > 0
    then
        local threadCount = tonumber(serveurs.threadformember)
        local maxThreads = tonumber(serveurs.maxthreadformember)
        local loadRatio = threadCount / maxThreads
        local threshold = 0.5 -- if system is above this load then kick in multiplier to slow down requests
        local maxMultiplier = 5
        if loadRatio > threshold then
            local t = (loadRatio - threshold) / (1 - threshold)
            local multiplier = maxMultiplier ^ t
            adjustedBaseline = quantizeUp(adjustedBaseline * multiplier, self.quantumStepMs)
        end
        adjustedBaseline = quantizeUp(adjustedBaseline * multiplier, self.quantumStepMs)
    end

    self.baselineIntervalMs = adjustedBaseline
    self:applyDelayIfChanged(
        self.baselineIntervalMs,
        "quota_and_load_adjust",
        string.format(
            "dailyRelevant=%s maxPerMin=%d maxPerDay=%d requestsToday=%d threadCount=%d maxThreads=%d loadRatio=%.2f multiplier=%.2f dailyWindow=%d totalWorkerCount=%s",
            tostring(dailyRelevant),
            maxPerMinute,
            maxPerDay,
            requestsToday,
            serveurs and tonumber(serveurs.threadformember) or 0,
            serveurs and tonumber(serveurs.maxthreadformember) or 0,
            serveurs and (tonumber(serveurs.threadformember) / tonumber(serveurs.maxthreadformember)) or 0,
            multiplier or 1,
            self.dailyWindow,
            self.totalWorkerCount
        )
    )
end

function M:closeWith(code, message)
    self.status = "closed"
    self.closedCode = code
    self.closedMessage = message or "closed"
    if self.logger then
        self.logger:log("error", "screenscraper", string.format("[closed] %d %s", code or -1, self.closedMessage))
    end
    -- Throw so callers using pcall can bail out immediately.
    error(string.format("Screenscraper client closed: %d %s", code or -1, self.closedMessage), 2)
end

function M:handleStatusCode(code)
    if not code then
        return
    end
    if CLOSE_IMMEDIATELY[code] then
        self:closeWith(code, CLOSE_IMMEDIATELY[code])
        return
    end

    if code == 429 then
        -- Backoff in quantized steps: +2q, +4q, +8q, +16q then close
        local step = BACKOFF_SEQUENCE_QUANTA[self.backoffStepIndex]
        if not step then
            self:closeWith(429, "Rate limit exceeded (backoff exhausted)")
            return
        end
        local incMs = step * self.quantumStepMs
        local target = math.max(self.baselineIntervalMs or 0, (self.currentIntervalMs or 0)) + incMs
        target = quantizeUp(target, self.quantumStepMs)
        self.status = "backingOff"
        self.backoffStepIndex = self.backoffStepIndex + 1
        self:applyDelayIfChanged(target, "429_backoff", string.format("step=%dq", step))
        return
    end
end

----------------------------------------------------------------
-- API calls
----------------------------------------------------------------

---Authenticates and returns user info (raw block), also initializes baseline if not set
---ssuserInfos.php
---@return table? ssuser
function M:fetchUserInfo()
    self:ensureOpen()

    local query = self:buildQuery()

    local url = self.baseUri .. "ssuserInfos.php?" .. uri.encodeQuery(query)
    local requestOptions = { headers = { accept = "application/json" } }

    local code, body, headers = self.https:request(url, requestOptions)

    -- Status handling first
    self:handleStatusCode(code)
    self:ensureOpen()

    if not body or code ~= 200 then
        if self.logger then
            self.logger:log(
                "error",
                "screenscraper",
                string.format("fetchUserInfo failed with code %s\n%s", tostring(code), pretty.string(body))
            )
        end
        return nil
    end

    local ok, decoded = pcall(json.decode, body)
    if not ok or not decoded or not decoded.response then
        if self.logger then
            self.logger:log(
                "error",
                "screenscraper",
                "Failed to decode response from ssuserInfos.php probably invalid json:\n" .. pretty.string(body)
            )
        end
        return nil
    end

    local ssuser = decoded.response.ssuser

    return ssuser
end

---Fetches game metadata from jeuInfos.php
---@param params table A table of query parameters: crc, md5, sha1, romnom, systemeid, romtaille, etc.
---@param options table Options for how to fetch information
---@return table|nil Parsed JSON response on success, or nil on failure
function M:fetchGameInfo(params, options)
    self:ensureOpen()

    local allowedParams = {
        crc = true,
        md5 = true,
        sha1 = true,
        romnom = true,
        romtaille = true, --size
        serialnum = true,
        gameid = true,
        systemeid = true,
        romtype = true,
    }

    -- On the very first member‐mode request, start at 200 ms before we know the baseline
    if self.currentIntervalMs == nil and self.userCredentials.ssid and self.userCredentials.sspassword then
        self.https:setDelay(200)
    end

    local query = self:buildQuery()

    local cleanMode = options and options.cleanMode or 1

    for k, v in pairs(params or {}) do
        if allowedParams[k] then
            if k == "romnom" then
                query[k] = self:cleanRomName(v, cleanMode)
            else
                query[k] = v
            end
        end
    end

    local url = self.baseUri .. "jeuInfos.php?" .. uri.encodeQuery(query)
    local requestOptions = { headers = { accept = "application/json" } }

    if self.scraperRepository:shouldSkip(url, "screenscraper", self.skipInterval) then
        self.logger:log(
            "debug",
            "screenscraper",
            "Skipping game as present in the skip table (API returned 404 within recent window)"
        )
        return nil
    end

    if self.logger then
        self.logger:log("debug", "screenscraper", "Making Game Info Request:\n " .. pretty.string(query))
    end

    local code, body, headers = self.https:request(url, requestOptions)
    if code == 404 then
        self.scraperRepository:insertSkip(url, "screenscraper")
    end

    -- Status handling
    self:handleStatusCode(code)
    self:ensureOpen()

    if not body or code ~= 200 then
        if self.logger then
            self.logger:log(
                "error",
                "screenscraper",
                string.format("fetchGameInfo failed with code %s\n%s", tostring(code), pretty.string(body))
            )
        end
        return nil
    end

    local ok, decoded = pcall(json.decode, body)
    if not ok then
        if self.logger then
            self.logger:log(
                "error",
                "screenscraper",
                "Failed to decode response from jeuInfos.php probably invalid json:\n" .. pretty.string(body)
            )
        end
        return nil
    end

    if decoded and decoded.response and decoded.response.ssuser then
        if self.totalWorkerCount > tonumber(decoded.response.ssuser.maxthreads) then
            self:closeWith(
                418,
                string.format(CLOSE_IMMEDIATELY[418], self.totalWorkerCount, decoded.response.ssuser.maxthreads)
            )
        end
    end

    -- Quota refresh if block present and interval elapsed
    if decoded and decoded.response and decoded.response.ssuser and decoded.response.serveurs then
        self:handleQuotaRefresh(decoded.response.ssuser, decoded.response.serveurs)
    end

    return decoded
end

function M:filterGameInfo(decoded, options)
    -- Filter synopsis
    local synopsis
    if
        options
        and options.preferredLanguages
        and decoded
        and decoded.response
        and decoded.response.jeu
        and type(decoded.response.jeu.synopsis) == "table"
    then
        for _, lang in ipairs(options.preferredLanguages) do
            for _, entry in ipairs(decoded.response.jeu.synopsis) do
                if entry.langue == lang and entry.text and entry.text ~= "" then
                    synopsis = entry.text
                    break
                end
            end
            if synopsis then
                break
            end
        end
    end
    synopsis = synopsis
        or (
            decoded
                and decoded.response
                and decoded.response.jeu
                and type(decoded.response.jeu.synopsis) == "string"
                and decoded.response.jeu.synopsis
            or nil
        )

    -- New logic: Filter medias by alias table with fallbacks
    local mediaByAlias = {}
    if options and decoded and decoded.response and decoded.response.jeu and decoded.response.jeu.medias then
        for alias, fallbackTypes in pairs(options.types or {}) do
            local bestMatch = nil
            local bestScore = 1000

            for _, fallbackType in ipairs(fallbackTypes) do
                for _, media in ipairs(decoded.response.jeu.medias) do
                    if media.type == fallbackType then
                        local score = 1000
                        if options.preferredRegions and media.region then
                            for i, region in ipairs(options.preferredRegions) do
                                if media.region:lower() == region:lower() then
                                    score = i
                                    break
                                end
                            end
                        end
                        if not bestMatch or score < bestScore then
                            bestMatch = media
                            bestScore = score
                        end
                    end
                end
                if bestMatch then
                    mediaByAlias[alias] = bestMatch
                    break
                end
            end
        end
    end

    local namedMedia = {}
    for alias, media in pairs(mediaByAlias) do
        if media.url then
            namedMedia[alias] = media.url
        end
    end

    return {
        synopsis = synopsis,
        media = namedMedia,
    }
end

---Cleans up a ROM filename for better matching
---@param romname string
---@param mode integer|nil -- 1 = mild, 2 = moderate, 3 = aggressive
---@return string
function M:cleanRomName(romname, mode)
    local clean = romname:lower()
    mode = mode or 1

    if mode >= 2 then
        clean = clean:gsub("%b()", "")
        clean = clean:gsub("%b[]", "")
        clean = clean:gsub("%b{}", "")
        clean = clean:gsub("v%d+%.?%d*", "") -- remove v1, v1.1
        clean = clean:gsub("rev%s*[a-z]", "") -- remove rev A, rev B
        clean = clean:gsub("[%-_]", " ")
        clean = clean:gsub("%s%s+", " ")
        clean = clean:gsub("^%s*(.-)%s*$", "%1")
        clean = clean:gsub("%s+%.", ".")
    end

    if mode >= 3 then
        local garbage = { "demo", "proto", "sample", "kiosk", "alt", "hack" }
        for _, word in ipairs(garbage) do
            clean = clean:gsub("%f[%a]" .. word .. "%f[%A]", "")
        end
        -- Remove standalone 4-digit years
        clean = clean:gsub("%f[%d]%d%d%d%d%f[%D]", "")
        -- Remove date patterns like yyyy-mm-dd
        clean = clean:gsub("%f[%d]%d%d%d%d%-%d%d%-%d%d%f[%D]", "")
        -- Remove "multi" language indicators
        clean = clean:gsub("[Mm]ulti%d*", "")
        -- Remove short language groupings like (En,Fr)
        clean = clean:gsub("%b()", function(m)
            if m:find(",") and #m < 12 then
                return ""
            else
                return m
            end
        end)
        -- Remove disc/side markers
        clean = clean:gsub("%s*[Dd]isc%s*%d+", "")
        clean = clean:gsub("%s*[Ss]ide%s*[ABab]", "")
        clean = clean:gsub("%s+%.", ".")
    end

    return clean
end

---Selects up to `options.quantity` media entries based on type and region priority
---@param decoded table The decoded jeuInfos.php response
---@param options table Table with `types`, `preferredRegions`, and `quantity`
---@return table Selected media entries
function M:selectPreferredMedia(decoded, options)
    local quantity = options and options.quantity or 20
    if
        quantity <= 0
        or not decoded
        or not decoded.response
        or not decoded.response.jeu
        or not decoded.response.jeu.medias
    then
        return {}
    end

    local candidates = {}

    -- Gather all matching media with type and region scores
    for _, media in ipairs(decoded.response.jeu.medias) do
        if table.index_of(options.types, media.type) then
            local typeScore = 1000
            for i, t in ipairs(options.types or {}) do
                if t == media.type then
                    typeScore = i
                    break
                end
            end

            local regionScore = 1000
            if options.preferredRegions and media.region then
                for i, r in ipairs(options.preferredRegions) do
                    if media.region:lower() == r:lower() then
                        regionScore = i
                        break
                    end
                end
            end

            table.insert(candidates, {
                media = media,
                typeScore = typeScore,
                regionScore = regionScore,
            })
        end
    end
    -- Sort by typeScore, then regionScore
    table.sort(candidates, function(a, b)
        if a.typeScore ~= b.typeScore then
            return a.typeScore < b.typeScore
        elseif a.regionScore ~= b.regionScore then
            return a.regionScore < b.regionScore
        else
            return (a.media.url or "") < (b.media.url or "")
        end
    end)

    -- Return up to quantity
    local result = {}
    for i = 1, math.min(quantity, #candidates) do
        table.insert(result, candidates[i].media.url)
    end

    return result
end

return M
