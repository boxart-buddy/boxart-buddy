---@class WidgetCheckbox
local M = class({ name = "WidgetCheckbox", extends = require("gui.widget.base") })

local colors = require("util.colors")

function M:new(canvas, value, options)
    options = options or {}
    -- init base
    self:super(canvas, value, self:_extractBaseOptions(options))

    self.checkboxStrokeWidth = options.checkboxStrokeWidth or 1
    self.checkboxSize = options.checkboxSize or SCREEN.hUnit(2)

    -- colors
    self.colors = table.shallow_overlay({
        box = colors.offWhite,
        selectedBox = colors.offWhite,
    }, options.colors or {})
end

function M:handleInput(input)
    if input == "confirm" then
        self.value = not self.value
    end
    return self.value
end

function M:draw(active)
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    self:_drawBase(active)

    -- Draw Box
    love.graphics.setColor(self.value == true and self.colors.selectedBox or self.colors.box)
    local checkboxX = self.inputX + self.checkboxStrokeWidth
    local checkboxY = self:_vAlignCentre(self.checkboxSize + self.checkboxStrokeWidth)
    love.graphics.setLineWidth(self.checkboxStrokeWidth)
    love.graphics.rectangle("line", checkboxX, checkboxY, self.checkboxSize, self.checkboxSize)
    -- Draw a cross if checked
    if self.value == true then
        love.graphics.line(
            checkboxX,
            self:_vAlignCentre(self.checkboxSize),
            checkboxX + self.checkboxSize,
            checkboxY + self.checkboxSize
        )
        love.graphics.line(
            checkboxX + self.checkboxSize,
            self:_vAlignCentre(self.checkboxSize),
            checkboxX,
            checkboxY + self.checkboxSize
        )
    end

    love.graphics.pop()
end

return M
