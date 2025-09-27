local path = require("util.path")

---@class TgdbScraper
local M = class({
    name = "TgdbScraper",
})

function M:new(environment, logger, database, platform)
    self.platform = platform
    self.client = require("module.tgdb.client")(environment, logger, database)
end

function M:scrape(rom, scrapeTypes)
    local romName = rom.datname and rom.datname or path.stem(rom.romname)
    -- lookup platforms
    local p = self.platform:getPlatformByKey(rom.platform)
    if not p then
        return {}
    end

    local plats = p.tgdbId
    if not plats then
        return {}
    end
    if type(plats) ~= "table" then
        plats = { plats }
    end

    local matches = self.client:searchByNameAndPlatform(romName, plats, scrapeTypes)

    return matches
end

function M:search(rom, scrapeTypes)
    local transformed = {}
    local matches = self:scrape(rom, scrapeTypes)
    if not matches or not next(matches) then
        return transformed
    end
    -- strip keys
    for typ, uri in pairs(matches) do
        table.insert(transformed, uri)
    end
    return transformed
end

return M
