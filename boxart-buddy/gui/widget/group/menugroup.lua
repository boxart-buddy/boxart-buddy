local Menu = require("gui.widget.group.menu")

---@class WidgetGroupMenuGroup
local M = class({ name = "WidgetGroupMenuGroup", extends = require("gui.widget.base") })

local colors = require("util.colors")

function M:new(systemeventsubscriber, canvas, definitions, values, options)
    values = values or {}
    options = options or {}
    self.systemeventsubscriber = systemeventsubscriber

    -- init base
    self:super(canvas, value, self:_extractBaseOptions(options))

    -- colors
    self.colors = table.shallow_overlay({
        text = colors.offWhite,
        background = colors.red,
    }, options.colors or {})

    -- submenu
    self.menu = Menu(
        self.canvas,
        self.systemeventsubscriber,
        definitions, --definitions
        values, --values
        table.shallow_overlay({
            x = 0,
            y = self.labelHeight,
            height = "auto",
            overflow = "visible",
        }, self:extractMenuOptions(options.menuOptions))
    )

    -- internal state
    self.originalHeight = self.height
    self.expanded = false
    if options.expanded == true then
        self:expand()
    end
end

function M:extractMenuOptions(opts)
    local o = {}
    o.width = opts.width
    o.font = opts.font
    o.labelWidth = opts.labelWidth
    o.labelPaddingLeft = opts.labelPaddingLeft
    o.widgetHeight = opts.widgetHeight
    o.debug = opts.debug

    return o
end

function M:expand()
    self.expanded = true
    self.height = self.originalHeight + self.menu.height
end

function M:collapse()
    self.expanded = false
    self.height = self.originalHeight
end

function M:handleInput(input)
    -- close submenu
    if not self.menu:isCurrentOptionOpen() and input == "up" and self.menu:currentPositionFirst() then
        self:collapse()
        return self.menu.value
    end
    if not self.menu:isCurrentOptionOpen() and input == "down" and self.menu:currentPositionLast() then
        self:collapse()
        return self.menu.value
    end

    local values = self.menu:handleInput(input)
    return values
end

function M:_vAlignCentre(height)
    return math.floor((self.originalHeight - height) / 2)
end

function M:_drawLabel(active)
    -- debug box
    if self.debug then
        love.graphics.setColor(colors.pink)
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
    end

    -- Insert expanded arrow
    local r = 0
    local arrow = ASSETS.image.collapse_arrow
    if active then
        arrow = ASSETS.image.expand_arrow
    end

    local arrowScale = 0.25
    love.graphics.setColor(self.baseColors.label)
    love.graphics.draw(arrow, 5, self:_vAlignCentre(arrow:getHeight() * arrowScale), r, arrowScale, arrowScale)

    -- Label
    local label = self.label
    if label then
        love.graphics.setColor(self.baseColors.label)
        love.graphics.setFont(self.labelFont)
        love.graphics.printf(
            self.label,
            50,
            self:_vAlignCentre(self.labelFont:getHeight(self.label)),
            self.width,
            "left"
        )
    end
end

function M:update(dt)
    self.menu:update(dt)
end

function M:draw(active)
    love.graphics.setCanvas(self.canvas)
    local px, py, pw, ph = love.graphics.getScissor()

    --store outer scissor to restore it after rendering submenu
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)

    local ax, ay = love.graphics.transformPoint(0, 0)
    love.graphics.intersectScissor(ax, ay, self.width, self.height)

    self:_drawLabel(active)
    self.menu:draw()
    love.graphics.pop()
end

return M
