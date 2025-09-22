local path = require("util.path")

---@class LibretroScraper
local M = class({
    name = "LibretroScraper",
})

function M:new(environment, logger, platform)
    self.platform = platform
    self.client = require("module.libretro.client")(environment, logger, platform)

    self.baseUri = "https://thumbnails.libretro.com/"
end

function M:scrape(rom, scrapeTypes)
    -- scrape with libretro
    local libretroThumbMatches = {}
    if rom.datname then
        libretroThumbMatches = self.client:getMatchesByPlatformAndRomname(rom.platform, rom.datname)
    end
    if not next(libretroThumbMatches) and (rom.datname ~= rom.romname) then
        libretroThumbMatches = self.client:getMatchesByPlatformAndRomname(rom.platform, path.stem(rom.romname))
    end

    -- filter to only those requested
    local filteredMatches = {}
    for _, type in ipairs(scrapeTypes) do
        if libretroThumbMatches[type] ~= false then
            filteredMatches[type] = libretroThumbMatches[type]
        end
    end

    return filteredMatches
end

function M:search(rom, scrapeTypes)
    local transformed = {}
    local matches = self:scrape(rom, scrapeTypes)
    -- strip keys
    for typ, uri in pairs(matches) do
        table.insert(transformed, uri)
    end
    return transformed
end

return M
