local json = require("lib.json")
local uri = require("util.uri")
local socket = require("socket")
local mime = require("mime")
local romNameCleaner = require("module.rom_name_cleaner")

---@class TgdbClient
local M = class({
    name = "TgdbClient",
})

function M:new(environment, logger, database)
    self.environment = environment
    self.logger = logger
    self.https = require("module.rate_limit_https")(logger)
    self.https:setDelay(200)
    self.scraperRepository = require("repository.scraper")(database)
    self.skipInterval = math.max(0, math.min(28, environment:getConfig("scraper_skip_offset")))

    self.apiKey = mime.unb64("NDU3OGMzZmFiZmYyZTZjMmRiYjc5NGU2NGVmYzUzODNmMTRiNGI2YjMyMWJkN2U1NGQyYjVmMWExMmIxZWI1Nw==")
    self.baseUrl = "https://api.thegamesdb.net/v1"
    self.searchUrl = self.baseUrl .. "/Games/ByGameName"

    local imageType = self.environment:getConfig("scraper_tgdb_use_thumb") and "thumb" or "medium"
    self.cdnUrlBase = string.format("https://cdn.thegamesdb.net/images/%s", imageType)
end

function M:searchByNameAndPlatform(romName, platforms, scrapeTypes)
    local platformIds = table.concat(platforms, ",")
    local searchTerm = romNameCleaner:cleanRomName(romName, 3)
    local url = string.format(
        "%s?%s",
        self.searchUrl,
        uri.encodeQuery({
            apikey = self.apiKey,
            name = searchTerm,
            ["filter[platform]"] = platformIds,
            ["include"] = "boxart",
        })
    )

    if self.scraperRepository:shouldSkip(url, "tgdb", self.skipInterval) then
        self.logger:log(
            "debug",
            "tgdb",
            "Skipping game as present in the skip table (API returned 404 within recent window)"
        )
        return nil
    end

    local code, body, headers = self.https:request(url, { headers = { accept = "application/json" } })

    -- the API doesn't return 404 errors...
    if code == 404 then
        self.scraperRepository:insertSkip(url, "tgdb")
    end

    local ok, decoded = pcall(json.decode, body)
    if not ok or not decoded or not decoded.status or not decoded.status == "Success" then
        if self.logger then
            self.logger:log("error", "tgdb", "Failed to decode response from tgdb api call: " .. pretty.string(body))
        end
        return nil
    end

    if decoded.data.count == 0 then
        self.scraperRepository:insertSkip(url, "tgdb")
        return nil
    end

    if decoded.remaining_monthly_allowance and decoded.remaining_monthly_allowance <= 0 then
        self.logger:log("error", "tgdb", "tgdb remaining_monthly_allowance (quota) exhausted")
        return nil
    end

    local gameId = decoded.data.games[1].id

    -- box2d info is included in the response, so use it if available
    local box2dUrl = nil
    if decoded.include and decoded.include.boxart and decoded.include.boxart.data then
        for gameId, box2dAssets in pairs(decoded.include.boxart.data) do
            for _, boxAssetData in ipairs(box2dAssets) do
                if boxAssetData.side and boxAssetData.side == "front" then
                    box2dUrl = string.format("%s/%s", self.cdnUrlBase, boxAssetData.filename)
                    break
                end
            end
            if box2dUrl ~= nil then
                break
            end
        end
    end

    local matches = {}
    for _, typ in ipairs(scrapeTypes) do
        local urlsForType = self:getUrlsForType(gameId, typ)
        if box2dUrl and typ == "box2d" then
            table.insert(urlsForType, 1, box2dUrl)
        end

        for i, assetUrl in ipairs(urlsForType) do
            local code, body, headers =
                self.https:request(assetUrl, { headers = { accept = "application/json" }, method = "HEAD" })
            if code == 200 then
                matches[typ] = assetUrl
                break
            end
        end
    end

    return matches
end

function M:getUrlsForType(gameId, scrapeType)
    local urls = {}
    if scrapeType == "box2d" then
        urls = {
            string.format("%s/boxart/front/%s-1.jpg", self.cdnUrlBase, gameId),
            string.format("%s/boxart/front/%s-1.png", self.cdnUrlBase, gameId),
        }
    elseif scrapeType == "wheel" then
        urls = {
            string.format("%s/clearlogo/%s-1.png", self.cdnUrlBase, gameId),
            string.format("%s/clearlogo/%s.png", self.cdnUrlBase, gameId),
        }
    elseif scrapeType == "screenshot" then
        urls = {
            string.format("%s/screenshots/%s-1.jpg", self.cdnUrlBase, gameId),
            string.format("%s/screenshots/%s-1.png", self.cdnUrlBase, gameId),
            string.format("%s/screenshot/%s-1.jpg", self.cdnUrlBase, gameId),
            string.format("%s/screenshot/%s-1.png", self.cdnUrlBase, gameId),
            -- Some screenshots only appear to have a '2' and not a '1'??
            -- string.format("%s/screenshots/%s-2.jpg", self.cdnUrlBase, gameId),
            -- string.format("%s/screenshots/%s-2.png", self.cdnUrlBase, gameId),
            -- string.format("%s/screenshot/%s-2.jpg", self.cdnUrlBase, gameId),
            -- string.format("%s/screenshot/%s-2.png", self.cdnUrlBase, gameId),
        }
    elseif scrapeType == "titlescreen" then
        urls = {
            string.format("%s/titlescreen/%s-1.jpg", self.cdnUrlBase, gameId),
            string.format("%s/titlescreen/%s-1.png", self.cdnUrlBase, gameId),
        }
    elseif scrapeType == "marquee" then
        urls = {
            string.format("%s/graphical/%s-g.jpg", self.cdnUrlBase, gameId),
            string.format("%s/graphical/%s-g.png", self.cdnUrlBase, gameId),
        }
    end
    return urls
end

return M
