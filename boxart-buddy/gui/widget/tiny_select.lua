local colors = require("util.colors")

---@class WidgetTinySelect
local M = class({ name = "WidgetTinySelect", extends = require("gui.widget.base") })

function M:new(canvas, items, value, options)
    options = options or {}
    -- init base
    self:super(canvas, value, self:_extractBaseOptions(options))
    self.items = items

    self:setCurrentIndexByValue(self.value)

    self.cycle = options.cycle or true
    self.font = options.font or ASSETS.font.univers.regular(FONTSIZE.s)
    self.arrowLeft = options.arrowLeft or ASSETS.image.arrow_left
    self.arrowRight = options.arrowRight or ASSETS.image.arrow_right
    self.arrowScale = options.arrowScale or 0.7
    self.textWidth = options.textWidth or nil
    self.keyTransformer = options.keyTransformer or nil
    self.colors = table.shallow_overlay({
        text = colors.offWhite,
        arrow = colors.offWhite,
    }, options.colors or {})
end

function M:handleInput(input)
    if input == "left" then
        if self.currentIndex == 1 then
            if self.cycle == true then
                self.currentIndex = #self.items
            end
        else
            self.currentIndex = self.currentIndex - 1
        end
    elseif input == "right" then
        if self.currentIndex == #self.items then
            if self.cycle == true then
                self.currentIndex = 1
            end
        else
            self.currentIndex = self.currentIndex + 1
        end
    end

    for i, v in ipairs(self.items) do
        if i == self.currentIndex then
            self.value = v
        end
    end
    return self.value
end

function M:setCurrentIndexByValue(val)
    for i, v in ipairs(self.items) do
        if v == val then
            self.currentIndex = i
        end
    end
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
        -- offset to the length of the longest option
        for i, v in ipairs(self.items) do
            if self.keyTransformer then
                v = self.keyTransformer(v)
            end
            local len = self.font:getWidth(v) + 4
            if len > rightArrowOffset then
                rightArrowOffset = len
            end
        end
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
    local currentText = string.format("%s", self.items[self.currentIndex])
    if self.keyTransformer then
        currentText = self.keyTransformer(currentText)
    end
    -- Set font before measuring and printing
    love.graphics.setFont(self.font)
    local padding = 2
    local textW = self.font:getWidth(currentText)
    -- rightArrowOffset is the slot width between arrows (including padding)
    local currentTextX = self.inputX
        + arrowWidth
        + padding
        + math.floor(((rightArrowOffset - 2 * padding) - textW) / 2 + 0.5)

    love.graphics.setColor(self.colors.text)
    love.graphics.print(
        currentText,
        currentTextX, -- centre aligns
        self:_vAlignCentre(self.font:getHeight(currentText))
    )

    love.graphics.pop()
end
return M
