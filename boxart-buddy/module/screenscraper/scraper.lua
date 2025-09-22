local filesystem = require("lib.nativefs")
local path = require("util.path")
local stringUtil = require("util.string")
local uri = require("util.uri")

---@class ScreenscraperScraper
local M = class({
    name = "ScreenscraperScraper",
})

function M:new(environment, platform, logger, https, mediaRepository, scraperRepository)
    self.environment = environment
    self.platform = platform
    self.logger = logger
    self.https = https -- this https wrapper is rate limited
    self.mediaRepository = mediaRepository
    self.client = require("module.screenscraper.client")(environment, logger, https, scraperRepository)
end

function M:setOptions(options)
    -- to remove
end

function M:scrape(rom, types)
    self.client:setOptions({
        dailyWindow = self.environment:getConfig("scraper_screenscraper_burnthrough"),
        threads = self.environment:getConfig("scraper_screenscraper_threads"),
        skipInterval = self.environment:getConfig("scraper_skip_offset"),
    })
    return self:_scrapeApiAndFormatResult(rom, types, "filtered")
end

function M:search(rom, types)
    self.client:setOptions({
        dailyWindow = 1,
        threads = 1,
        skipInterval = 0,
    })
    return self:_scrapeApiAndFormatResult(rom, types, "preferred")
end

function M:_scrapeApiAndFormatResult(rom, types, returnFormat)
    -- client will throw on closed state (wrap this call in pcall outside if desired)
    local systemId
    if rom.datplatform then
        local platform = self.platform:getPlatformByKey(rom.datplatform)
        systemId = platform.ssId
    end
    if not systemId then
        local platform = self.platform:getPlatformByKey(rom.platform)
        systemId = platform.ssId
    end

    local params = {
        crc = rom.crc32,
        md5 = rom.md5,
        sha1 = rom.sha1,
        romtaille = rom.size,
        serialnum = rom.serial,
        systemeid = systemId,
        romnom = rom.datromname or rom.romname,
    }

    -- if "scraper_screenscraper_gameid" then just use that
    if rom.options and rom.options.scraper_screenscraper_gameid then
        params = {
            gameid = rom.options.scraper_screenscraper_gameid,
        }
    end

    local ok, decoded = pcall(function()
        return self.client:fetchGameInfo(params)
    end)
    if not ok then
        self.logger:log("error", "screenscraper", "fetchGameInfo failed: " .. tostring(decoded))
        return {}
    end
    if not decoded or not decoded.response or not decoded.response.jeu then
        return {}
    end

    local searchTypes = {}
    local typMap = {
        wheel = { "wheel", "wheel-hd", "wheel-carbon" },
        box2d = { "box-2D", "support-2D" },
        screenshot = { "ss", "sstitle" },
        box3d = { "box-3D" },
        cart = { "support-2D" },
    }
    for _, typ in ipairs(types) do
        if typMap[typ] then
            searchTypes[typ] = typMap[typ]
        end
    end

    if returnFormat == "filtered" then
        -- returns one entry per requested "searchTypes" key
        local filteredResult = self.client:filterGameInfo(decoded, {
            preferredLanguages = self.environment:getConfig("scraper_screenscraper_preferred_languages"),
            preferredRegions = self.environment:getConfig("scraper_screenscraper_preferred_regions"),
            types = searchTypes,
        })

        return filteredResult.media
    elseif returnFormat == "preferred" then
        local flatTypes = {}
        for typ, ssTyps in pairs(searchTypes) do
            flatTypes = table.dedupe(table.shallow_overlay(flatTypes, ssTyps))
        end
        -- returns a tabled of X number of results (flat)
        local preferredResult = self.client:selectPreferredMedia(decoded, {
            preferredRegions = self.environment:getConfig("scraper_screenscraper_preferred_regions"),
            types = flatTypes,
        })

        return preferredResult
    end

    error("cannot return scrape results for unknown format:" .. returnFormat)
end

function M:createMedia(uuid, localFilename, type, url, romUuid)
    url = self:_maskRemoteUri(url)
    self.mediaRepository:createMedia(uuid, localFilename, type, "screenscraper", url, romUuid)
end

function M:downloadMedia(remotePath, assetType, uuid)
    -- client.fetchGameInfo would have thrown if closed
    local localFilename = uuid .. ".png"
    local code, body = self.https:request(remotePath, {})
    if code ~= 200 then
        self.logger:log("warn", "scraper", "Media download failed: " .. remotePath)
        return nil
    end
    self.logger:log("info", "scraper", "Media downloaded: " .. remotePath)

    local cacheFolder =
        path.join({ self.environment:getPath("cache"), assetType, stringUtil.uuidToFolder(localFilename) })
    filesystem.createDirectory(cacheFolder)

    local assetPath = path.join({ cacheFolder, localFilename })
    if not filesystem.write(assetPath, body) then
        self.logger:log("error", "scraper", "Error saving file: " .. assetPath)
        return nil
    end
    return localFilename
end

function M:_maskRemoteUri(remotePath)
    return uri.removeQueryStringParts(remotePath, { remove = { "devid", "devpassword", "ssid", "sspassword" } })
end

return M
