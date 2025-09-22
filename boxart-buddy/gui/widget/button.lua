local colors = require("util.colors")

---@class WidgetButton
local M = class({ name = "WidgetButton", extends = require("gui.widget.base") })

function M:new(canvas, text, options)
    options = options or {}
    self.text = text
    self.subText = options.subText or nil

    -- buttons never have a value
    self.value = nil

    -- DISPLAY
    self.corner = options.corner or 4
    self.borderStroke = options.borderStroke or 2
    self.textPadding = options.textPadding or 4
    self.disabled = options.disabled or false

    -- TEXT/ALIGN
    self.font = options.font or ASSETS.font.univers.regular(FONTSIZE.s)
    self.subTextFont = options.subTextFont or ASSETS.font.univers.regular(FONTSIZE.xs)
    self.subTextMarginY = options.subTextMarginY or 0
    self.align = options.align or "left"
    self.textAlign = options.textAlign or "center"
    self.textOffsetX = options.textOffsetX or 0
    self.textTransform = options.textTransform or nil

    -- LAYOUT
    self.buttonWidth = options.buttonWidth or self.font:getWidth(self.text) + self.textPadding
    self.buttonHeight = options.buttonHeight or self.font:getHeight(self.text) + self.textPadding

    -- init base
    self:super(canvas, nil, self:_extractBaseOptions(options))

    -- ICON
    self.icon = options.icon or nil
    self.iconScale = options.iconScale or 1
    self.iconOffsetX = options.iconOffsetX or 0

    self.colors = table.shallow_overlay({
        icon = colors.offWhite,
        --text
        text = colors.offWhite,
        highlightText = colors.offWhite,
        disabledText = colors.midGrey,
        -- bg
        bg = colors.blue,
        highlightBg = colors.blue,
        disabledBg = colors.lightGrey,
        --border
        border = colors.blue,
        highlightBorder = colors.red,
        disabledBorder = colors.lightGrey,
    }, options.colors or {})

    -- on Confirm
    self.onConfirm = options.onConfirm or nil
end

function M:isDisabled()
    return self.disabled == true
end

-- allow overriding options
-- function M:setOptions(opts)
--     for key, value in pairs(opts) do
--         self.options[key] = value
--     end
-- end

function M:handleInput(input)
    if input == "confirm" then
        if self.onConfirm then
            self.onConfirm()
        end
    end
    return nil
end

function M:draw(active)
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    self:_drawBase(active)

    -- COLORS
    local textColor = self.colors.text
    local bgColor = self.colors.bg
    local borderColor = self.colors.border
    if active then
        textColor = self.colors.highlightText
        bgColor = self.colors.highlightBg
        borderColor = self.colors.highlightBorder
    end
    if self.disabled == true then
        textColor = self.colors.disabledText
        bgColor = self.colors.disabledBg
        borderColor = self.colors.disabledBorder
    end

    local buttonX = self.inputX
    if self.align == "center" then
        buttonX = ((self.width - self.inputX) - self.buttonWidth) / 2
    end
    -- button background
    if bgColor then
        love.graphics.setColor(bgColor)
        love.graphics.rectangle(
            "fill",
            buttonX,
            self:_vAlignCentre(self.buttonHeight),
            self.buttonWidth,
            self.buttonHeight,
            self.corner,
            self.corner
        )
    end

    -- button border
    -- note that button border is _inside_ the rectangle to preserve all other layout options (width/height etc)
    if borderColor then
        love.graphics.setColor(borderColor)
        love.graphics.setLineWidth(self.borderStroke)
        love.graphics.rectangle(
            "line",
            buttonX + math.floor(self.borderStroke / 2),
            self:_vAlignCentre(self.buttonHeight) + math.floor(self.borderStroke / 2),
            self.buttonWidth - self.borderStroke,
            self.buttonHeight - self.borderStroke,
            self.corner - 1,
            self.corner - 1
        )
    end

    --icon
    if self.icon then
        local icon = ASSETS.image.icon[self.icon]
        love.graphics.setColor(self.colors.icon)
        local iconX = buttonX + self.iconOffsetX
        local iconY = self:_vAlignCentre(icon:getHeight() * self.iconScale)
        love.graphics.draw(icon, iconX, iconY, 0, self.iconScale, self.iconScale)
    end

    --text
    love.graphics.setFont(self.font)
    love.graphics.setColor(textColor)

    local buttonText = self.text
    local buttonSubText = self.subText
    if self.textTransform and self.textTransform == "upper" then
        buttonText = string.upper(buttonText)
        if buttonSubText then
            buttonSubText = string.upper(buttonSubText)
        end
    end
    local textX = buttonX + self.textOffsetX
    local totalTextHeight = self.font:getHeight(buttonText)
    if buttonSubText then
        totalTextHeight = totalTextHeight + self.subTextMarginY + self.subTextFont:getHeight(buttonSubText)
    end
    local textY = self:_vAlignCentre(totalTextHeight)
    love.graphics.printf(buttonText, textX, textY, self.buttonWidth - self.textOffsetX, self.textAlign)
    if buttonSubText then
        love.graphics.setFont(self.subTextFont)
        love.graphics.printf(
            buttonSubText,
            textX,
            textY + self.subTextMarginY + self.font:getHeight(buttonText),
            self.buttonWidth - self.textOffsetX,
            self.textAlign
        )
    end

    love.graphics.pop()
end
return M
