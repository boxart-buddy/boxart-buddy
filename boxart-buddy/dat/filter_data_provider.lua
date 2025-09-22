---@class FilterDataProvider
local M = class({
    name = "FilterDataProvider",
})

function M:new(database, systemeventsubscriber)
    self.romRepository = require("repository.rom")(database)
    self.filters = nil
    systemeventsubscriber:subscribe("scan_roms_complete", function()
        self:replaceFiltersWithDefaults()
        systemeventsubscriber:publish("default_filters_updated")
    end)
end

function M:getDefault()
    local distinctPlatforms = self.romRepository:getDistinctPlatforms()
    local allPlatforms = {}
    for _, value in ipairs(distinctPlatforms) do
        allPlatforms[value] = true
    end
    return {
        verified = "all",
        media = "all",
        platforms = allPlatforms,
    }
end

function M:getFilters()
    if self.filters == nil then
        self.filters = table.deep_copy(self:getDefault())
    end
    return self.filters
end

-- needs to be called whenever platforms are refreshed/after rom scanning
function M:replaceFiltersWithDefaults()
    if not self.filters then
        return
    end
    if #(table.keys(self.filters.platforms)) == #(table.keys(self:getDefault().platforms)) then
        return
    end
    for key, value in pairs(self.filters) do
        self.filters[key] = self:getDefault()[key]
    end
end

function M:getOptions()
    return {
        verified = { "all", "verified", "unverified" },
        media = { "all", "complete", "partial", "empty" },
        platforms = self.romRepository:getDistinctPlatforms(),
    }
end

return M
