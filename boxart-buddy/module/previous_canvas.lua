local colors = require("util.colors")

--- Just a singleton that can be used to reference the previous canvas state.
--- Useful within screens that are 'modals' of other screens. Previous canvas
--- Must be set on 'exit' of each screen
---@class PreviousCanvas
local M = class({
    name = "PreviousCanvas",
})

function M:new()
    self.canvas = nil
    self.prevScreenName = nil
end

function M:set(prevCanvas, prevScreenName)
    local newCanvas = love.graphics.newCanvas(prevCanvas:getDimensions())
    newCanvas:renderTo(function()
        love.graphics.setColor(colors.white)
        love.graphics.draw(prevCanvas, 0, 0)
    end)
    self.canvas = newCanvas
    self.prevScreenName = prevScreenName
end

function M:get()
    return self.canvas, self.prevScreenName
end

return M
