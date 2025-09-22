local colors = require("util.colors")

---@class PlatformGrid
local M = class({
    name = "PlatformGrid",
})

function M:new(canvas, items, viewport, options)
    if type(items) ~= "table" then
        error("items must be a table of strings")
    end
    self.canvas = canvas
    self.items = items
    self.viewport = viewport or { x = 0, y = 0, w = 300, h = 300 }
    self.options = options or {}

    -- Set defaults
    self.options.columns = self.options.columns or 3
    self.options.rowHeight = self.options.rowHeight or 30
    self.options.colWidth = self.options.colWidth or 165
    self.options.paddingX = self.options.paddingX or 15
    self.options.paddingY = self.options.paddingY or 8
    self.options.font = self.options.font or ASSETS.font.univers.regular(FONTSIZE.s)
    self.options.colors = self.options.colors
        or {
            label = colors.offWhite,
            box = colors.offWhite,
            selectedBox = colors.offWhite,
            highlight = colors.activeUI,
        }

    return self
end

function M:draw(highlight, focusedIndex, selected, scrollY)
    love.graphics.setCanvas(self.canvas)

    local ox, oy, ow, oh = self.viewport.x, self.viewport.y, self.viewport.w, self.viewport.h
    local colW = self.options.colWidth
    local rowH = self.options.rowHeight
    local padX = self.options.paddingX
    local padY = self.options.paddingY

    love.graphics.setScissor(ox, oy, ow, oh)
    love.graphics.push()
    love.graphics.translate(ox + 2, oy - scrollY + 2)

    love.graphics.setFont(self.options.font)
    for i, item in ipairs(self.items) do
        local row = math.floor((i - 1) / self.options.columns)
        local col = (i - 1) % self.options.columns
        local x = col * (colW + padX)
        local y = row * (rowH + padY)

        local isFocused = (i == focusedIndex)
        local isSelected = selected[item]

        -- Highlight behind label
        if highlight and isFocused then
            local labelX = x + 30
            local labelY = y
            local labelW = colW - 30
            local labelH = rowH
            love.graphics.setColor(self.options.colors.highlight)
            love.graphics.rectangle("fill", labelX - 4, labelY - 2, labelW + 8, labelH + 4, 6, 6)
        end

        -- Checkbox
        love.graphics.setColor(isSelected and self.options.colors.selectedBox or self.options.colors.box)
        love.graphics.rectangle("line", x, y, 20, 20)
        if isSelected then
            love.graphics.line(x, y, x + 20, y + 20)
            love.graphics.line(x + 20, y, x, y + 20)
        end

        -- Label
        love.graphics.setColor(self.options.colors.label)
        love.graphics.print(item, x + 30, y + 2)
    end

    love.graphics.pop()

    -- Scrollbar
    local contentHeight = math.ceil(#self.items / self.options.columns)
        * (self.options.rowHeight + self.options.paddingY)
    if contentHeight > oh then
        local scrollbarHeight = math.max(20, oh * (oh / contentHeight))
        local scrollRatio = scrollY / (contentHeight - oh)
        local scrollbarY = oy + (oh - scrollbarHeight) * scrollRatio

        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("fill", ox + ow - 5, scrollbarY, 5, scrollbarHeight, 2, 2)
    end

    love.graphics.setScissor()

    love.graphics.setCanvas()
end

function M:handleInput(action, focusedIndex, scrollY)
    local count = #self.items
    local cols = self.options.columns
    local rowH = self.options.rowHeight + self.options.paddingY

    if action == "left" and (focusedIndex % cols) ~= 1 then
        focusedIndex = focusedIndex - 1
    elseif action == "right" and (focusedIndex % cols) ~= 0 and focusedIndex < count then
        focusedIndex = focusedIndex + 1
    elseif action == "up" and focusedIndex > cols then
        focusedIndex = focusedIndex - cols
    elseif action == "down" and focusedIndex + cols <= count then
        focusedIndex = focusedIndex + cols
    end

    -- Calculate target Y
    local row = math.floor((focusedIndex - 1) / cols)
    local y = row * rowH

    if y < scrollY then
        scrollY = y
    elseif y + rowH > scrollY + self.viewport.h then
        local offset = math.floor(self.options.rowHeight * 0.4)
        scrollY = math.min(y + rowH - self.viewport.h + offset, math.ceil((count / cols)) * rowH - self.viewport.h)
    end

    local toggledItem = nil
    if action == "confirm" then
        toggledItem = self.items[focusedIndex]
    end

    return focusedIndex, scrollY, toggledItem
end

return M
