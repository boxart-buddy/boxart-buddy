local colors = require("util.colors")

---@class WidgetBase
local M = class({ name = "WidgetBase" })

function M:new(canvas, value, opts)
    opts = opts or {}
    self.canvas = canvas
    self.value = value

    -- LAYOUT
    self.x = opts.x or 0
    self.y = opts.y or 0
    self.width = opts.width or SCREEN.w
    self.height = opts.height or SCREEN.h

    -- LABEL
    self.label = opts.label or nil
    self.labelFont = opts.labelFont or ASSETS.font.univers.regular(FONTSIZE.s)
    self.labelHighlightPaddingX = opts.labelHighlightPaddingX or 4
    self.labelHighlightPaddingY = opts.labelHighlightPaddingY or 2
    self.labelWidth = opts.labelWidth or self.labelFont:getWidth(self.label or "X") + self.labelHighlightPaddingX * 2 -- if supplied then the value is inclusive of labelHighlightPaddingX
    self.labelHeight = opts.labelHeight or self.labelFont:getHeight(self.label or "X") + self.labelHighlightPaddingY * 2 -- if supplied then the value is inclusive of labelHighlightPaddingY

    -- INPUT PADDING (right of label/left of widget body)
    self.inputPaddingLeft = opts.inputPaddingLeft or 10

    -- SET X/Y FOR PARENT WIDGETS
    self.inputX = self.labelWidth + self.inputPaddingLeft

    -- COLORS
    self.baseColors = table.shallow_overlay({
        label = colors.offWhite,
        labelHighlight = colors.activeUI,
    }, opts.colors or {})

    self.debug = opts.debug or false
end

function M:_extractBaseOptions(opts)
    local baseOpts = {}
    baseOpts.x = opts.x
    baseOpts.y = opts.y
    baseOpts.width = opts.width
    baseOpts.height = opts.height
    baseOpts.label = opts.label
    baseOpts.labelFont = opts.labelFont or opts.font
    baseOpts.labelHighlightPaddingX = opts.labelHighlightPaddingX
    baseOpts.labelHighlightPaddingY = opts.labelHighlightPaddingY
    baseOpts.labelWidth = opts.labelWidth
    baseOpts.labelHeight = opts.labelHeight
    baseOpts.inputPaddingLeft = opts.inputPaddingLeft
    baseOpts.baseColors = opts.baseColors
    baseOpts.debug = opts.debug
    if baseOpts.labelWidth == nil and baseOpts.label == "" or not baseOpts.label then
        baseOpts.labelWidth = 0
    end
    return baseOpts
end

---The Y co-ord to place something of `height` to have it centre aligned
---@param height number
---@return number
function M:_vAlignCentre(height)
    -- should this add self.y?
    return math.floor((self.height - height) / 2)
end

function M:_drawBase(active)
    love.graphics.setCanvas(self.canvas)

    -- debug box
    if self.debug then
        love.graphics.setColor(colors.green)
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
    end

    -- highlight the label
    if active and self.label then
        love.graphics.setColor(self.baseColors.labelHighlight)
        love.graphics.rectangle(
            "fill",
            0,
            self:_vAlignCentre(self.labelHeight),
            self.labelWidth,
            self.labelHeight,
            6,
            6
        )
    end

    -- Label
    if self.label then
        love.graphics.setColor(self.baseColors.label)
        love.graphics.setFont(self.labelFont)
        love.graphics.print(
            self.label,
            self.labelHighlightPaddingX,
            self:_vAlignCentre(self.labelHeight - self.labelHighlightPaddingY)
        )
    end
end

return M
