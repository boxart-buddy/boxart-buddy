local json = require("lib.json")
local uri = require("util.uri")
local socket = require("socket")

---@class SteamGridDbClient
local M = class({
    name = "SteamGridDbClient",
})

----------------------------------------------------------------
-- Utilities
----------------------------------------------------------------

---replace template tokens like {term} or {gameId}
local function formatPath(tmpl, params)
    return (
        tmpl:gsub("%b{}", function(key)
            local k = key:sub(2, -2)
            return tostring(params[k] or key)
        end)
    )
end

---build a full URL with query parameters using util/uri.encodeQuery
local function buildUrl(base, path, query)
    if query and next(query) ~= nil then
        return base .. "/" .. path .. "?" .. uri.encodeQuery(query)
    else
        return base .. "/" .. path
    end
end

---perform an HTTPS GET and parse JSON, returns (table|nil, err)
local function getJson(https, url, headers, logger)
    -- Try request with headers (signature: https.request(url, { headers = ... }))
    local ok, code, body = pcall(function()
        return https.request(url, { headers = headers or {} })
    end)

    if not ok then
        -- Fallback: simple signature (https.request(url) -> code, body)
        if logger then
            logger:log(
                "warn",
                "steamgriddb",
                "HTTPS client does not support headered requests; retrying without headers"
            )
        end
        ok, code, body = pcall(function()
            return https.request(url)
        end)
        if not ok then
            return nil, tostring(code)
        end
    end

    local status = tonumber(code)
    if status == 200 then
        local text = body or ""
        if text == "" then
            return {}, nil
        end
        local okj, parsed = pcall(json.decode, text)
        if not okj then
            return nil, "Failed to decode JSON: " .. tostring(parsed)
        end
        return parsed, nil
    elseif status == 401 or status == 404 then
        return nil, string.format("HTTP %d: %s", status, tostring(body or ""))
    else
        return nil, string.format("Unexpected HTTP %d: %s", status, tostring(body or ""))
    end
end

---extract an array of URLs from a SteamGridDB response `{ data = { { url = ... }, ... } }`
local function extractUrls(payload, urlKey)
    local out = {}
    if type(payload) == "table" and type(payload.data) == "table" then
        for _, item in ipairs(payload.data) do
            if type(item) == "table" and type(item[urlKey]) == "string" then
                table.insert(out, item[urlKey])
            end
        end
    end
    return out
end

---Allocate per-gameID quotas that sum to total, with earlier IDs weighted higher via geometric decay.
---@param n integer number of game IDs
---@param total integer desired total results
---@param decay number weight decay per subsequent ID (0<decay<1), e.g. 0.6
---@return table quotas array of length n
local function allocateQuotas(n, total, decay)
    if not total or total <= 0 or n <= 0 then
        return nil
    end
    decay = (decay and decay > 0 and decay < 1) and decay or 0.6

    local weights, wsum = {}, 0
    for i = 1, n do
        local w = decay ^ (i - 1)
        weights[i] = w
        wsum = wsum + w
    end

    local quotas, assigned = {}, 0
    for i = 1, n do
        local q = math.floor(total * (weights[i] / wsum))
        if q < 1 then
            q = 1
        end
        quotas[i] = q
        assigned = assigned + q
    end

    -- Adjust to match total exactly
    local idx = 1
    while assigned > total do
        if quotas[idx] > 0 then
            quotas[idx] = quotas[idx] - 1
            assigned = assigned - 1
        end
        idx = (idx % n) + 1
    end
    idx = 1
    while assigned < total do
        quotas[idx] = quotas[idx] + 1
        assigned = assigned + 1
        idx = (idx % n) + 1
    end

    return quotas
end

---Compute a weighted cap for the current ID based on remaining headroom and decay.
---@param idx integer current id index (1-based)
---@param n integer total ids
---@param remaining integer remaining results budget
---@param decay number geometric decay factor (0<decay<1)
---@return integer cap
local function weightedCap(idx, n, remaining, decay)
    decay = (decay and decay > 0 and decay < 1) and decay or 0.6
    local sumW = 0
    for j = idx, n do
        sumW = sumW + (decay ^ (j - idx))
    end
    local wHere = 1 -- since (decay^(idx-idx)) == 1
    local cap = math.floor(remaining * (wHere / sumW))
    if cap < 1 then
        cap = 1
    end
    return cap
end

----------------------------------------------------------------
-- Instance
----------------------------------------------------------------
function M:new(environment, logger, https, scraperRepository)
    self.environment = environment
    self.logger = logger
    self.https = https
    self.scraperRepository = scraperRepository
    self.baseUri = "https://www.steamgriddb.com/api/v2"
    self.searchUri = "search/autocomplete/{term}"
    self.logosUri = "logos/game/{gameId}"
    self.gridsUri = "grids/game/{gameId}"

    self.apiToken = environment:getConfig("scraper_steamgriddb_api_token")
    self.defaultHeaders = {
        Authorization = "Bearer " .. tostring(self.apiToken or ""),
        Accept = "application/json",
        ["User-Agent"] = "boxart-buddy/steamgriddb-client",
    }
    self.useThumb = self.environment:getConfig("scraper_steamgriddb_use_thumb")
end

function M:setOptions(opts)
    if not opts then
        return
    end
end

function M:search(searchString, types, options)
    options = options or {}
    local gameQty = options.gameQty or 10 -- how many game IDs to consider
    local limit = options.limit or nil -- optional safety cap per SGDB request
    local totalLimit = options.totalLimit or 25 -- desired total results per type (across all gameIds)
    local decay = options.decay or 0.6 -- weighting for earlier IDs

    -- map from our app's type keys to SGDB endpoint + options
    local typeMap = {
        wheel = { type = "logo" },
        grid1x1 = { type = "grid", dimensions = { "512x512", "1024x1024" } },
        grid2x3 = { type = "grid", dimensions = { "600x900" } },
    }

    if not types or #types == 0 then
        self.logger:log("info", "steamgriddb", "no types requested; returning empty result")
        return {}
    end

    searchString = self:cleanRomName(searchString, 3)

    -- 1) Search for game IDs via autocomplete (single request)
    local path = formatPath(self.searchUri, { term = uri.urlEncode(searchString) })
    local url = buildUrl(self.baseUri, path, nil)
    self.logger:log("debug", "steamgriddb", "search URL: " .. url)
    local payload, err = getJson(self.https, url, self.defaultHeaders, self.logger)
    if not payload then
        self.logger:log("error", "steamgriddb", "search failed: " .. tostring(err))
        return {}
    end

    local gameIds = {}
    if type(payload) == "table" and type(payload.data) == "table" then
        for _, item in ipairs(payload.data) do
            if type(item) == "table" and item.id then
                table.insert(gameIds, item.id)
            end
            if #gameIds >= gameQty then
                break
            end
        end
    end

    if #gameIds == 0 then
        self.logger:log("info", "steamgriddb", "no game IDs for query: " .. tostring(searchString))
        return {}
    end

    -- Removed preallocation of perIdQuotas

    -- 2) For each requested type, fetch assets for each gameId and collect URLs keyed by that type
    local resultsByType = {}

    for _, typeKey in ipairs(types) do
        local conf = typeMap[typeKey]
        if not conf then
            self.logger:log("warn", "steamgriddb", "unknown type key '" .. tostring(typeKey) .. "' — skipping")
        else
            local query = { mimes = "image/png,image/jpeg", types = "static" }
            if conf.type == "logo" then
                query = { mimes = "image/png", types = "static" }
            end
            if limit then
                query.limit = limit
            end
            if conf.type == "grid" and conf.dimensions and #conf.dimensions > 0 then
                query.dimensions = table.concat(conf.dimensions, ",")
            end

            local urlsForType = {}
            for i, gid in ipairs(gameIds) do
                -- Remaining budget and ids left
                local remaining = totalLimit and (totalLimit - #urlsForType) or nil
                if remaining and remaining <= 0 then
                    break
                end
                local idsLeft = (#gameIds - i + 1)

                -- Decide if headroom is tight. If tight, apply a decay-weighted cap; otherwise, be greedy.
                local targetPerId = options.targetPerId or limit or 10
                local tight = remaining and (remaining < idsLeft * targetPerId) or false

                local effectiveLimit
                if remaining then
                    if tight then
                        -- allocate only a weighted share to preserve budget for later IDs
                        effectiveLimit = weightedCap(i, #gameIds, remaining, decay)
                    else
                        -- plenty of headroom: be greedy but respect optional per-request limit
                        effectiveLimit = remaining
                    end
                end

                if limit then
                    effectiveLimit = effectiveLimit and math.min(effectiveLimit, limit) or limit
                end

                -- Build per-request query
                local reqQuery = {}
                for k, v in pairs(query) do
                    reqQuery[k] = v
                end
                if effectiveLimit and effectiveLimit > 0 then
                    reqQuery.limit = effectiveLimit
                else
                    reqQuery.limit = nil
                end

                local tmpl = (conf.type == "grid") and self.gridsUri or self.logosUri
                local p = formatPath(tmpl, { gameId = gid })
                local u = buildUrl(self.baseUri, p, reqQuery)
                self.logger:log("debug", "steamgriddb", "fetch URL (" .. typeKey .. "): " .. u)
                local res, rerr = getJson(self.https, u, self.defaultHeaders, self.logger)
                if res then
                    local urlKey = self.useThumb and "thumb" or "url"
                    local urls = extractUrls(res, urlKey)
                    for _, v in ipairs(urls) do
                        table.insert(urlsForType, v)
                        if totalLimit and #urlsForType >= totalLimit then
                            break
                        end
                    end
                else
                    self.logger:log(
                        "warn",
                        "steamgriddb",
                        "fetch failed for id " .. tostring(gid) .. " (" .. typeKey .. "): " .. tostring(rerr)
                    )
                end
                if totalLimit and #urlsForType >= totalLimit then
                    break
                end
            end

            resultsByType[typeKey] = urlsForType
        end
    end

    return resultsByType
end

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

return M
