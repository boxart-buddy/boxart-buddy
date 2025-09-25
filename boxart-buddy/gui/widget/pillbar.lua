local colors = require("util.colors")

---@class Pillbar
local M = class({ name = "WidgetPillbar", extends = require("gui.widget.base") })

function M:new(canvas, items, current, options)
    options = options or {}

    -- LAYOUT
    self.font = options.font or ASSETS.font.inter.medium(FONTSIZE.s)

    -- area between the top of the widget and the start of the background
    self.barMarginY = options.barMarginY or SCREEN.hUnit(0.2)

    -- between edge of pill background and the 'active pill'
    self.barPadY = options.barPadY or SCREEN.hUnit(0.4)
    self.barPadX = options.barPadX or SCREEN.wUnit(0.5)

    -- area between the text and the edge of each pill (applied on _each side_ of the text)
    self.pillPadX = options.pillPadX or SCREEN.wUnit(0.4)

    -- REORDER MODE
    self.reorderable = options.reorderable or false

    -- init base
    self:super(canvas, value, self:_extractBaseOptions(options))

    -- labels/keys
    self.uppercaseText = options.uppercaseText or false
    self.keyTransformer = options.keyTransformer or false
    self.currentIndex = 1
    self.items = {}
    -- Normalize items/set self.items: { key = ..., value = ... }
    if #items > 0 then
        for i, v in ipairs(items) do
            local key = self.uppercaseText and string.upper(v) or v
            key = self.keyTransformer and self.keyTransformer(v) or key
            table.insert(self.items, { key = key, value = v })
            if v == current then
                self.currentIndex = i
            end
        end
    else
        for k, v in pairs(items) do
            local key = self.uppercaseText and string.upper(k) or k
            key = self.keyTransformer and self.keyTransformer(v) or key
            table.insert(self.items, { key = key, value = v })
            if v == current then
                self.currentIndex = #self.items
            end
        end
    end

    -- Calc width of the pillbar itself
    self.pillBarWidth = options.pillBarWidth
        or self:_calculateMinimumWidth(self.items, self.font, self.pillPadX, self.barPadX)
    self.pillBarHeight = self.height - (self.barMarginY * 2)

    -- DISPLAY OPTIONS
    self.activeDisplayMode = options.activeDisplayMode or "pill" -- or "underline"
    self.maxGap = options.maxGap or nil
    self.align = options.align or "center"
    self.imageLeft = options.imageLeft or nil
    self.imageRight = options.imageRight or nil
    self.imageMargin = options.imageMargin or 10

    self.colors = table.shallow_overlay({
        bg = colors.veryDarkGrey,
        activeBG = colors.lightGrey,
        text = colors.offWhite,
        activeText = colors.darkGrey,
        activeUnderline = colors.offWhite,
        image = colors.white,
    }, options.colors or {})
end

function M:draw(active)
    if not next(self.items) then
        return
    end
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)

    -- debug box
    if self.debug then
        love.graphics.setColor(colors.green)
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
    end

    -- only draw base if label is present
    if self.label then
        self:_drawBase(active)
    else
        love.graphics.setCanvas(self.canvas)
    end

    -- INSERTION POINT DEPENDING ON ALIGN OPTION
    local innerOffsetX
    if self.align == "left" then
        innerOffsetX = self.inputX
    elseif self.align == "right" then
        error("not implemented")
    else
        -- centre align - does this work?
        innerOffsetX = self.inputX + ((self.width - self.inputX) - self.pillBarWidth) / 2
    end

    -- debug box
    if self.debug then
        love.graphics.setColor(colors.pink)
        love.graphics.rectangle(
            "line",
            innerOffsetX,
            self:_vAlignCentre(self.pillBarHeight),
            self.pillBarWidth,
            self.pillBarHeight
        )
    end

    -- BAR BG
    if self.colors.bg then
        love.graphics.setColor(self.colors.bg)
        love.graphics.rectangle(
            "fill",
            innerOffsetX,
            self:_vAlignCentre(self.pillBarHeight),
            self.pillBarWidth,
            self.pillBarHeight,
            self.pillBarHeight / 2,
            self.pillBarHeight / 2
        )
    end

    local labels = {}
    for i, item in ipairs(self.items) do
        labels[i] = item.key
    end
    local layout =
        self:_layoutEvenlySpaced(labels, self.font, self.pillBarWidth, self.pillPadX, self.barPadX, self.maxGap)

    -- LEFT / RIGHT IMAGES
    if self.imageLeft then
        local img = self.imageLeft
        love.graphics.setColor(self.colors.image)
        love.graphics.draw(img, innerOffsetX - img:getWidth() - self.imageMargin, self:_vAlignCentre(img:getHeight()))
    end
    if self.imageRight then
        local img = self.imageRight
        love.graphics.setColor(self.colors.image)
        love.graphics.draw(
            img,
            innerOffsetX + self.pillBarWidth + self.imageMargin,
            self:_vAlignCentre(img:getHeight())
        )
    end

    -- LAYOUT ITEMS
    for i, item in ipairs(layout) do
        local isActive = i == self.currentIndex

        -- ACTIVE ITEM BG OR UNDERLINE
        if isActive then
            if self.activeDisplayMode == "pill" then
                local pillX = innerOffsetX + self.barPadX + item.activeX
                local pillY = self:_vAlignCentre(self.pillBarHeight - (self.barPadY * 2))
                local pillW = item.width
                local pillH = self.pillBarHeight - (self.barPadY * 2)
                love.graphics.setColor(self.colors.activeBG)
                love.graphics.rectangle("fill", pillX, pillY, pillW, pillH, pillH / 2, pillH / 2)
            elseif self.activeDisplayMode == "underline" then
                local pillX = innerOffsetX + self.barPadX + item.labelX
                local pillY = self:_vAlignCentre(self.pillBarHeight - (self.barPadY * 2))
                local pillW = item.width - (self.pillPadX * 2)
                local pillH = self.pillBarHeight - self.barMarginY - self.barPadY
                love.graphics.setColor(self.colors.activeUnderline)
                local underlineThickness = 3
                love.graphics.rectangle("fill", pillX, pillY + pillH, pillW, underlineThickness)
            else
                error("unknown active display mode: " .. self.activeDisplayMode)
            end
        end

        -- ITEM TEXT
        local drawColor = isActive and self.colors.activeText or self.colors.text
        love.graphics.setColor(drawColor)
        love.graphics.setFont(self.font)
        love.graphics.printf(
            item.label,
            innerOffsetX + self.barPadX + item.labelX,
            self:_vAlignCentre(self.font:getHeight(item.label)),
            item.width,
            "left"
        )
    end

    love.graphics.pop()
end

--- Layout items so that the space *between* each item is even.
-- @param items table of strings
-- @param totalWidth total horizontal space to use
-- @param maxGap maximum gap allowed between items
-- @return table of {label, centerX, width}
function M:_layoutEvenlySpaced(items, font, totalWidth, pillPadX, barPadX, maxGap)
    pillPadX = pillPadX or 0
    local boxes = {}
    local totalItemsWidth = 0

    for _, label in ipairs(items) do
        local w = font:getWidth(label) + pillPadX * 2
        table.insert(boxes, { label = label, width = w })
        totalItemsWidth = totalItemsWidth + w
    end

    local numGaps = #boxes - 1
    local totalGapSpace = totalWidth - totalItemsWidth - (barPadX * 2)
    local gap = numGaps > 0 and totalGapSpace / numGaps or 0

    if maxGap and gap > maxGap then
        gap = maxGap
    end

    local layout = {}
    local x = 0
    for _, box in ipairs(boxes) do
        table.insert(layout, {
            label = box.label,
            activeX = x,
            labelX = x + pillPadX,
            width = box.width,
        })
        x = x + box.width + gap
    end

    return layout
end

function M:_swapLeft()
    if self.currentIndex > 1 then
        self.items[self.currentIndex], self.items[self.currentIndex - 1] =
            self.items[self.currentIndex - 1], self.items[self.currentIndex]
        self.currentIndex = self.currentIndex - 1
        return true
    end
    return false
end

function M:_swapRight()
    if self.currentIndex < #self.items then
        self.items[self.currentIndex], self.items[self.currentIndex + 1] =
            self.items[self.currentIndex + 1], self.items[self.currentIndex]
        self.currentIndex = self.currentIndex + 1
        return true
    end
    return false
end

function M:_values()
    local out = {}
    for i, item in ipairs(self.items) do
        out[i] = item.value
    end
    return out
end

function M:handleInput(input)
    if #self.items == 0 then
        return nil, self.currentIndex
    end

    -- Navigation always works the same
    if input == "left" and self.currentIndex > 1 then
        self.currentIndex = self.currentIndex - 1
    elseif input == "right" and self.currentIndex < #self.items then
        self.currentIndex = self.currentIndex + 1
    end

    -- Reordering with confirm/cancel when enabled
    if self.reorderable then
        if input == "confirm" then
            self:_swapRight()
        elseif input == "cancel" then
            self:_swapLeft()
        end
        return self:_values(), self.currentIndex
    end

    -- Default behavior (non-reorderable): return selected value
    return self.items[self.currentIndex].value, self.currentIndex
end

function M:_calculateMinimumWidth(items, font, pillPadX, barPadX)
    local labels = {}
    for i, item in ipairs(items) do
        labels[i] = item.key
    end
    local totalItemWidth = 0
    for _, label in ipairs(labels) do
        totalItemWidth = totalItemWidth + font:getWidth(label)
    end
    local totalGapWidth = #labels > 0 and (pillPadX * 2 * #labels) or 0
    local calculatedWidth = totalItemWidth + totalGapWidth + (barPadX * 2)

    return calculatedWidth
end

return M
