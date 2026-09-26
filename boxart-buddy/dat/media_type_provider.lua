---@class MediaTypeProvider
local M = class({
    name = "MediaTypeProvider",
})

function M:new(environment)
    self.environment = environment
end

function M:getMediaTypes()
    -- screenshot is hard coded, not for any particular reason
    -- other than guessing most would always want it
    local types = { "screenshot" }
    if self.environment:getConfig("media_box2d_enabled") then
        table.insert(types, "box2d")
    end
    if self.environment:getConfig("media_wheel_enabled") then
        table.insert(types, "wheel")
    end
    if self.environment:getConfig("media_box3d_enabled") then
        table.insert(types, "box3d")
    end
    -- if self.environment:getConfig("media_titlescreen_enabled") then
    --     table.insert(types, "titlescreen")
    -- end
    -- if self.environment:getConfig("media_marquee_enabled") then
    --     table.insert(types, "marquee")
    -- end
    if self.environment:getConfig("media_grid1x1_enabled") then
        table.insert(types, "grid1x1")
    end
    if self.environment:getConfig("media_grid2x3_enabled") then
        table.insert(types, "grid2x3")
    end
    if self.environment:getConfig("media_video_enabled") then
        table.insert(types, "video")
    end
    table.insert(types, "mix")

    return types
end

---Media types that can be scraped
---@return table
function M:getScrapeMediaTypes(excludeList)
    local types = self:getMediaTypes()

    -- Always remove "mix"
    table.remove_value(types, "mix")

    -- If a list of exclusions is provided, loop through and remove them
    if excludeList then
        for _, value in ipairs(excludeList) do
            table.remove_value(types, value)
        end
    end

    return types
end

---Media types that can be inset in mix
---@return table
function M:getInsetMediaTypes()
    local types = self:getMediaTypes()

    table.remove_value(types, "mix")
    --table.remove_value(types, "screenshot")

    return types
end

return M
