local colors = require("util.colors")

---@class WidgetNumber
local M = class({ name = "WidgetNumber", extends = require("gui.widget.base") })

function M:new(canvas, value, options)
    options = options or {}
    -- init base
    self:super(canvas, value, self:_extractBaseOptions(options))

    self.font = options.font or ASSETS.font.inter.medium(FONTSIZE.s)
    self.arrowLeft = options.arrowLeft or ASSETS.image.arrow_left
    self.arrowRight = options.arrowRight or ASSETS.image.arrow_right
    self.arrowScale = options.arrowScale or 0.7
    self.textWidth = options.textWidth or nil
    self.keyTransformer = options.keyTransformer or nil
    self.min = options.min or 1
    self.max = options.max or 100

    self.colors = table.shallow_overlay({
        text = colors.offWhite,
        arrow = colors.offWhite,
    }, options.colors or {})
end

function M:handleInput(input)
    if input == "left" then
        if self.value == self.min then
            return self.value
        end
        self.value = self.value - 1
    elseif input == "right" then
        if self.value == self.max then
            return self.value
        end
        self.value = self.value + 1
    end
    return self.value
end

function M:draw(active)
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    self:_drawBase(active)

    -- ARROWS
    local arrowWidth = math.floor(self.arrowLeft:getWidth() * self.arrowScale)
    local arrowHeight = math.floor(self.arrowLeft:getHeight() * self.arrowScale)

    local arrowY = self:_vAlignCentre(arrowHeight)

    love.graphics.setColor(self.colors.arrow)
    love.graphics.draw(self.arrowLeft, self.inputX, arrowY, 0, self.arrowScale, self.arrowScale)

    local rightArrowOffset = 0
    if self.textWidth then
        rightArrowOffset = self.textWidth
    else
        rightArrowOffset = self.font:getWidth(self.max) + 4
    end

    love.graphics.draw(
        self.arrowRight,
        self.inputX + arrowWidth + rightArrowOffset,
        arrowY,
        0,
        self.arrowScale,
        self.arrowScale
    )

    -- TEXT
    local currentText = string.format("%s", self.value)
    if self.keyTransformer then
        currentText = self.keyTransformer(currentText)
    end
    local currentTextX = self.inputX
        + arrowWidth
        + (((rightArrowOffset - 4) / 2) - ((self.font:getWidth(currentText)) / 2))
        + 2

    love.graphics.setColor(self.colors.text)

    love.graphics.print(
        currentText,
        currentTextX, -- centre aligns
        self:_vAlignCentre(self.font:getHeight(currentText))
    )

    love.graphics.pop()
end
return M
