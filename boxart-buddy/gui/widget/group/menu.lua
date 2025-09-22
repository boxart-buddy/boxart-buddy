local colors = require("util.colors")
local Checkbox = require("gui.widget.checkbox")
local TinySelect = require("gui.widget.tiny_select")
local Number = require("gui.widget.number")
local Pillbar = require("gui.widget.pillbar")
local Button = require("gui.widget.button")
local Keyboard = require("gui.widget.keyboard")
local NumPad = require("gui.widget.numpad")

---@class WidgetGroupMenu
local M = class({ name = "WidgetGroupMenu" })

local function isDisabledWidget(w)
    if not w then
        return false
    end
    -- Prefer a method if the widget exposes one
    if type(w.isDisabled) == "function" then
        local ok, res = pcall(function()
            return w:isDisabled()
        end)
        if ok then
            return res and true or false
        end
    end
    -- Fallback to common flags
    if w.disabled ~= nil then
        return w.disabled == true
    end
    if w.options and w.options.disabled ~= nil then
        return w.options.disabled == true
    end
    return false
end

function M:new(canvas, systemeventsubscriber, definitions, values, options)
    self.canvas = canvas
    self.systemeventsubscriber = systemeventsubscriber
    self.definitions = definitions
    self.values = values -- contains the current values

    self.optionWidgets = {}
    self.widgetHeight = options.widgetHeight or SCREEN.hUnit(3.4)

    -- force same font for all widgets, also applies to label
    self.font = options.font or ASSETS.font.univers.regular(FONTSIZE.s)

    -- INITIALIZE ALL WIDGETS WITH CORRECT OPTIONS
    local currentWidgetY = 0

    for i, def in ipairs(definitions) do
        local value
        if type(def.default) == "table" then
            value = table.deep_copy(def.default)
        else
            value = def.default
        end
        -- this assumes 'nil' can never be a valid value for a config
        -- will break if this isnt the case
        if values[def.key] ~= nil then
            value = values[def.key]
        end
        -- sets the tracked 'value' state using the default if it wasn't set up front
        if value ~= nil then
            values[def.key] = value
        end

        local widgetOptions = {}
        if i == 1 and def.type == "group" then
            widgetOptions.expanded = true
        end
        local widget = self:_initWidget(def, value, currentWidgetY, options, widgetOptions)
        currentWidgetY = currentWidgetY + widget.height
        self.optionWidgets[i] = { widget = widget, key = def.key, type = def.type }
    end

    -- DEBUG
    self.debug = options.debug

    -- LAYOUT
    self.x = options.x or 0
    self.y = options.y or 0

    -- PANE SIZING (defaults to full screen unless auto)
    self.width = (options and options.width) or SCREEN.w - self.x
    if options.height == "auto" then
        self.height = 0
        for _, w in ipairs(self.optionWidgets) do
            self.height = self.height + w.widget.height
        end
    else
        self.height = (options and options.height) or SCREEN.h - self.y
    end

    -- DISPLAY MODE
    self.overflow = options.overflow or "scroll"
    if self.overflow == "scroll" then
        self.shouldScroll = true
        self.shouldScissor = true
    elseif self.overflow == "clip" then
        self.shouldScroll = false
        self.shouldScissor = true
    elseif self.overflow == "visible" then
        self.shouldScroll = false
        self.shouldScissor = false
    end

    --=========== SCROLL STUFF ========
    self.scrollY = 0

    -- start scrolling a bit before the last visible row to give affordance
    self.scrollAffordanceTop = math.floor((options.scrollAffordanceTop or 0.5) * self.widgetHeight)
    self.scrollAffordanceBottom = math.floor((options.scrollAffordanceBottom or 0.5) * self.widgetHeight)

    -- Clamp affordances so small panes don't start scrolled
    local halfPane = math.floor(self.height * 0.5)
    if self.scrollAffordanceTop > halfPane then
        self.scrollAffordanceTop = halfPane
    end
    if self.scrollAffordanceBottom > halfPane then
        self.scrollAffordanceBottom = halfPane
    end
    local maxAff = self.widgetHeight
    if self.scrollAffordanceTop > maxAff then
        self.scrollAffordanceTop = maxAff
    end
    if self.scrollAffordanceBottom > maxAff then
        self.scrollAffordanceBottom = maxAff
    end
    --=========== SCROLL STUFF ========

    -- allows the initial menu option to be set via options on init
    self.currentOption = options.currentOptionIndex or 1

    -- Ensure the initial selection is on an enabled widget
    local function findNextEnabled(startIdx, step)
        local idx = startIdx
        while idx >= 1 and idx <= #self.optionWidgets do
            local t = self.optionWidgets[idx]
            if t and not isDisabledWidget(t.widget) then
                return idx
            end
            idx = idx + step
        end
        return startIdx -- fallback if none found
    end
    if isDisabledWidget(self.optionWidgets[self.currentOption] and self.optionWidgets[self.currentOption].widget) then
        -- try forward first, then backward
        local forward = findNextEnabled(self.currentOption + 1, 1)
        if forward == self.currentOption then
            local backward = findNextEnabled(self.currentOption - 1, -1)
            self.currentOption = backward
        else
            self.currentOption = forward
        end
    end
    -- throw event for first option
    self.systemeventsubscriber:publish("option_selected", { option = self.optionWidgets[self.currentOption] })
    self:_ensureCurrentOptionVisible()
end

function M:_initWidget(def, value, y, options, widgetOptions)
    local widget

    -- INHERIT (widget options from menu)
    widgetOptions.debug = options.debug
    widgetOptions.font = options.font
    widgetOptions.width = options.width
    widgetOptions.labelWidth = options.labelWidth

    -- SET OPTIONS FROM DEFINITION
    widgetOptions.label = def.label

    -- SET Y DRAW POINT/Height (use previous widget height instead?)
    widgetOptions.y = y
    widgetOptions.height = self.widgetHeight

    -- merge options if provided
    if def.options then
        table.deep_overlay(widgetOptions, def.options)
    end

    if def.type == "boolean" then
        widget = Checkbox(self.canvas, value, widgetOptions)
    elseif def.type == "select" then
        widgetOptions.align = "left"
        widgetOptions.activeDisplayMode = "underline"
        widgetOptions.barPadX = 0
        widgetOptions.inputPaddingLeft = 0
        widgetOptions.colors = { activeText = colors.offWhite, bg = false }
        widget = Pillbar(self.canvas, def.values, value, widgetOptions)
    elseif def.type == "reorder" then
        widgetOptions.align = "left"
        widgetOptions.activeDisplayMode = "underline"
        widgetOptions.barPadX = 0
        widgetOptions.inputPaddingLeft = 0
        widgetOptions.colors = { activeText = colors.offWhite, bg = false }
        widgetOptions.reorderable = true
        if value == nil then
            value = table.deep_copy(def.values)
        end
        widget = Pillbar(self.canvas, value, value[1], widgetOptions)
    elseif def.type == "tiny_select" then
        widget = TinySelect(self.canvas, def.values, value, widgetOptions)
    elseif def.type == "number" then
        widget = Number(self.canvas, value, widgetOptions)
    elseif def.type == "button" then
        widgetOptions.label = nil
        if not widgetOptions.onConfirm then
            -- if not an explicit handler then issue a generic event which can be subscribed to elsewhere
            widgetOptions.onConfirm = function()
                self.systemeventsubscriber:publish("button_pressed", { buttonKey = def.key })
            end
        end
        widget = Button(self.canvas, def.label, widgetOptions)
    elseif def.type == "string" then
        widget = Keyboard(self.systemeventsubscriber, self.canvas, value, widgetOptions)
    elseif def.type == "numpad" then
        widget = NumPad(self.systemeventsubscriber, self.canvas, value, widgetOptions)
    elseif def.type == "group" then
        local MenuGroup = require("gui.widget.group.menugroup")
        -- pass the same menu options to the menugroup
        widgetOptions.menuOptions = options
        widgetOptions.labelHeight = self.widgetHeight
        widget = MenuGroup(self.systemeventsubscriber, self.canvas, def.items, value, widgetOptions)
    end
    return widget
end
function M:_contentHeight()
    local count = #self.optionWidgets
    if count <= 0 then
        return 0
    end
    local height = 0
    for _, v in ipairs(self.optionWidgets) do
        height = v.widget.height + height
    end
    return height
end

function M:_maxScroll()
    local ch = self:_contentHeight()
    local maxScroll = math.max(0, ch - self.height)
    return maxScroll
end

function M:_clampScroll()
    local maxScroll = self:_maxScroll()
    if self.scrollY < 0 then
        self.scrollY = 0
    end
    if self.scrollY > maxScroll then
        self.scrollY = maxScroll
    end
end

function M:_ensureCurrentOptionVisible()
    local currentWidget = self.optionWidgets[self.currentOption].widget
    -- Ensure the selected row is within the pane with some affordance
    local rowTop = currentWidget.y
    local rowBottom = currentWidget.y + currentWidget.height

    -- Apply virtual padding only to the scroll math
    local paneTop = self.scrollY
    local paneBottom = paneTop + self.height

    -- Scroll up early if the row is approaching the top
    if rowTop < (paneTop + self.scrollAffordanceTop) then
        self.scrollY = rowTop - self.scrollAffordanceTop
        self:_clampScroll()
        return
    end

    -- Scroll down early if the row is approaching the bottom
    if rowBottom > (paneBottom - self.scrollAffordanceBottom) then
        self.scrollY = rowBottom - (self.height - self.scrollAffordanceBottom)
        self:_clampScroll()
        return
    end
end

function M:update(dt)
    for _, widgetTuple in pairs(self.optionWidgets) do
        if widgetTuple.widget.update then
            widgetTuple.widget:update(dt)
        end
    end
end

function M:draw()
    -- Save prior canvas/scissor; start clean so our clipping doesn't affect/receive outside state
    -- local prevCanvas = { love.graphics.getCanvas() }
    -- local psx, psy, psw, psh = love.graphics.getScissor()
    -- local hadPrevScissor = psx ~= nil
    if self.shouldScissor then
        love.graphics.setScissor()
    end

    love.graphics.push("all")
    love.graphics.setCanvas(self.canvas)
    love.graphics.translate(self.x, self.y)

    -- debug box
    if self.debug then
        love.graphics.setColor(colors.red)
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
    end

    love.graphics.setColor(colors.white)

    local modalOpen = self:isCurrentOptionOpen()

    -- SCROLL/SCISSOR
    if self.shouldScissor then
        love.graphics.setScissor(self.x, self.y, self.width, self.height)
    end
    if self.shouldScroll then
        love.graphics.translate(0, -self.scrollY)
    else
        love.graphics.translate(0, 0)
    end

    -- First pass: draw all non-open widgets in list order
    for idx, widgetTuple in ipairs(self.optionWidgets) do
        local w = widgetTuple.widget
        if w and w.draw and not w.open then
            local active = (widgetTuple.key == self.optionWidgets[self.currentOption].key)
            -- ensure we're drawing to this group's canvas and scissor for the background list
            --love.graphics.setCanvas(self.canvas)
            --love.graphics.setScissor(math.floor(ox), math.floor(oy), math.floor(ow), math.floor(oh))
            w:draw(active)
        end
    end

    -- If no modal is open, also draw any open widgets inside the clipped/scrolling context
    if not modalOpen then
        for idx, widgetTuple in ipairs(self.optionWidgets) do
            local w = widgetTuple.widget
            if w and w.draw and w.open then
                local active = (widgetTuple.key == self.optionWidgets[self.currentOption].key)
                -- love.graphics.setCanvas(self.canvas)
                -- love.graphics.setScissor(math.floor(ox), math.floor(oy), math.floor(ow), math.floor(oh))
                w:draw(active)
            end
        end
    end

    love.graphics.pop()
    love.graphics.setScissor()

    -- If a modal is open, draw it now WITHOUT clipping and WITHOUT scroll translation
    if modalOpen then
        for idx, widgetTuple in ipairs(self.optionWidgets) do
            local w = widgetTuple.widget
            if w and w.draw and w.open then
                local active = (widgetTuple.key == self.optionWidgets[self.currentOption].key)
                love.graphics.setCanvas(self.canvas)
                -- no scissor here on purpose so modal isn't clipped by the pane
                -- no translation so modal can position itself in canvas coordinates
                w:draw(active)
            end
        end
    end

    -- Scrollbar overlay
    local contentHeight = self:_contentHeight()
    if self.shouldScroll and contentHeight > self.height then
        love.graphics.push("all")
        love.graphics.translate(self.x, self.y)
        love.graphics.setCanvas(self.canvas)
        -- Height proportional to visible fraction; clamped between 20 and pane height
        local proportional = (self.height * self.height) / contentHeight
        local scrollbarHeight = math.max(20, math.min(self.height, math.floor(proportional + 0.5)))

        -- Clamp ratio to [0,1] to avoid overshoot due to rounding
        local denom = (contentHeight - self.height)
        local scrollRatio = (denom > 0) and math.min(1, math.max(0, self.scrollY / denom)) or 0

        local scrollbarY = (self.height - scrollbarHeight) * scrollRatio
        love.graphics.setColor({ 1, 1, 1, 0.3 })
        love.graphics.rectangle("fill", self.width - 15, scrollbarY, 5, scrollbarHeight, 2, 2)
        love.graphics.pop()
    end

    -- Restore prior scissor/canvas so nothing outside this draw is clipped unexpectedly
    -- if hadPrevScissor then
    --     love.graphics.setScissor(psx, psy, psw, psh)
    -- else
    --     love.graphics.setScissor()
    -- end
    --love.graphics.setCanvas(unpack(prevCanvas))
end

function M:handleInput(input)
    if input.type then
        input = input.type
    end
    local currentTuple = self.optionWidgets[self.currentOption]
    local currentWidget = currentTuple and currentTuple.widget
    local currentOptionKey = currentTuple and currentTuple.key

    local newValue = currentWidget and currentWidget.handleInput and currentWidget:handleInput(input)
    if newValue ~= nil and currentOptionKey then
        self.values[currentOptionKey] = newValue
    end

    local open = (currentWidget and currentWidget.open == true) or false
    local expanded = (currentWidget and currentWidget.expanded == true) or false

    -- If a modal widget is open (e.g., keyboard) or expanded (submenu), it captures ALL input.
    if open or expanded then
        return self.values
    end

    -- move through the menu list (only when no modal widget is open)
    local previousIndex = self.currentOption
    local function stepToEnabled(startIdx, step)
        local idx = startIdx + step
        while idx >= 1 and idx <= #self.optionWidgets do
            local t = self.optionWidgets[idx]
            if t and not isDisabledWidget(t.widget) then
                return idx
            end
            idx = idx + step
        end
        return startIdx -- no change if none enabled in that direction
    end
    if input == "up" then
        self.currentOption = stepToEnabled(self.currentOption, -1)
    elseif input == "down" then
        self.currentOption = stepToEnabled(self.currentOption, 1)
    end

    -- expand once landing on expandable widget
    local currentWidget = self.optionWidgets[self.currentOption].widget
    if currentWidget.expanded ~= nil and currentWidget.expanded == false then
        currentWidget:expand()
    end

    -- needed in case group expansion has adjusted y positions
    self:reflowWidgetLayouts()

    if self.currentOption ~= previousIndex then
        self.systemeventsubscriber:publish("option_selected", { option = self.optionWidgets[self.currentOption] })
        self:_ensureCurrentOptionVisible()
    end
    return self.values
end

function M:reflowWidgetLayouts()
    local currentWidgetY = 0
    if self.optionWidgets then
        for i, w in ipairs(self.optionWidgets) do
            w.widget.y = currentWidgetY
            currentWidgetY = currentWidgetY + w.widget.height
        end
    end
end

function M:getCurrentDefinition()
    return self.definitions[self.currentOption]
end

function M:currentPositionFirst()
    return self.currentOption == 1
end

function M:currentPositionLast()
    return self.currentOption == #self.optionWidgets
end

function M:isCurrentOptionOpen()
    local t = self.optionWidgets[self.currentOption]
    return t and t.widget and t.widget.open == true or false
end

return M
