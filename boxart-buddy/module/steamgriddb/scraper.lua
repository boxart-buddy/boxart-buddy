local filesystem = require("lib.nativefs")
local path = require("util.path")
local stringUtil = require("util.string")
local uri = require("util.uri")

---@class SteamGridDbScraper
local M = class({
    name = "SteamGridDbScraper",
})

local function flattenTable(t)
    local r = {}
    for _, sub in pairs(t) do
        if type(sub) == "table" then
            for _, v in ipairs(sub) do
                table.insert(r, v)
            end
        end
    end
    return r
end

local function reduceSearchResuls(t)
    local r = {}
    for typ, urls in pairs(t) do
        r[typ] = urls[1]
    end
    return r
end

function M:new(environment, platform, logger, mediaRepository, scraperRepository)
    self.environment = environment
    self.platform = platform
    self.logger = logger
    self.mediaRepository = mediaRepository
    self.client = require("module.steamgriddb.client")(environment, logger, require("https"), scraperRepository)
end

function M:setOptions(options)
    -- to remove
end

function M:scrape(rom, types)
    local searchTerm = rom.datname or rom.romname -- does it need cleaned? need to test

    -- when scraping only the first result is used, so define that in the request
    local options = { gameQty = 20, limit = 1, targetPerId = 1, totalLimit = 1 }
    local ok, result = pcall(function()
        return self.client:search(searchTerm, types, options)
    end)
    if not ok then
        self.logger:log("error", "steamgriddb", "steamgriddb search: " .. tostring(result))
        return {}
    end

    return reduceSearchResuls(result)
end

function M:search(rom, types)
    local searchTerm = rom.datname or rom.romname -- does it need cleaned? need to test
    local totalLimit = self.environment:getConfig("scraper_steamgriddb_search_qty") or 25
    local options = {
        gameQty = math.floor(totalLimit / 3),
        targetPerId = math.floor(totalLimit / 4),
        limit = 8,
        decay = 0.6,
        totalLimit = totalLimit,
    }

    local ok, result = pcall(function()
        return self.client:search(searchTerm, types, options)
    end)
    if not ok then
        self.logger:log("error", "steamgriddb", "steamgriddb search: " .. tostring(result))
        return {}
    end

    return flattenTable(result)
end

return M
