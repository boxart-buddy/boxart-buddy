local colors = require("util.colors")
local hash = require("util.hash")
local stringUtil = require("util.string")
local Menu = require("gui.widget.group.menu")
local PillBar = require("gui.widget.pillbar")
local Confirm = require("gui.widget.special.confirm")

---@class ConfigScreen
local M = class({
    name = "ConfigScreen",
})

function M:new(environment, systemeventsubscriber, inputeventsubscriber, database, configManager, thread)
    self.environment = environment
    self.configManager = configManager
    self.inputeventsubscriber = inputeventsubscriber
    self.systemeventsubscriber = systemeventsubscriber
    self.thread = thread
    self.database = database

    self.shouldRedraw = true
    self.config = nil
    self.lastSavedConfig = nil
    self.displayHelp = false
    self.configChangeState = "unchanged"

    self.boundHandleInput = function(e)
        self:handleInput(e)
    end

    -- generic handler for button presses on the 'sys' menu
    self.boundConfigButtonPressedHandler = function(e)
        if e.buttonKey == "sys_full_reset" then
            self.confirmDelete = Confirm(self.systemeventsubscriber, {
                message = "Delete all data? (cannot be undone)",
                onConfirm = function()
                    self:_handleFullReset()
                end,
            })
            self.confirmDelete:open()
        end
    end
end

function M:enter()
    self.systemeventsubscriber:publish("screen_enter", { screen = "CONFIG" })
    self.config = self.configManager:get()
    self.lastSavedConfig = hash.cheapHash(self.config)

    self.canvas = love.graphics.newCanvas(SCREEN.w, SCREEN.mainH, { msaa = 8 })
    self.shouldRedraw = true

    self.currentGroup = "scraper"
    self.groupNavigation = PillBar(self.canvas, self.configManager:getGroups(), self.currentGroup, {
        y = SCREEN.hUnit(1),
        pillPadX = 12,
        barPadY = 3,
        barPadX = SCREEN.wUnit(1),
        height = SCREEN.hUnit(3),
        inputPaddingLeft = 0,
        uppercaseText = true,
        font = ASSETS.font.univers.bold(FONTSIZE.s),
        imageLeft = ASSETS.image.button.gamepad.small.l1,
        imageRight = ASSETS.image.button.gamepad.small.r1,
        imageMargin = 14,
        colors = {
            bg = colors.veryDarkGrey,
            activeBg = colors.midGrey,
            text = colors.offWhite,
            image = colors.darkGrey,
        },
    })

    self.inputeventsubscriber:subscribe("input", self.boundHandleInput)
    self.systemeventsubscriber:subscribe("button_pressed", self.boundConfigButtonPressedHandler)

    self:setMenu(self.currentGroup)
end

function M:exit()
    self.inputeventsubscriber:unsubscribe("input", self.boundHandleInput)
    self.systemeventsubscriber:unsubscribe("button_pressed", self.boundConfigButtonPressedHandler)
    self.systemeventsubscriber:publish("screen_exit", { screen = "CONFIG" })
end

function M:setMenu(name)
    self.menu = Menu(
        self.canvas,
        self.systemeventsubscriber,
        self.configManager:getOrderedDefinitionGroup(name), --definitions
        self.config, --values
        {
            x = SCREEN.hUnit(7),
            y = SCREEN.wUnit(3),
            font = ASSETS.font.univers.regular(FONTSIZE.s),
            labelWidth = SCREEN.wUnit(10),
            spacingY = SCREEN.hUnit(3.4),
            height = SCREEN.mainH - SCREEN.hUnit(13),
            width = SCREEN.w - SCREEN.wUnit(5),
        }
    )
end

function M:pageLeft()
    local current = self.groupNavigation:handleInput("left")
    if current ~= self.currentGroup then
        self.currentGroup = current
        self:setMenu(self.currentGroup)
        self.shouldRedraw = true
    end
end

function M:pageRight()
    local current = self.groupNavigation:handleInput("right")
    if current ~= self.currentGroup then
        self.currentGroup = current
        self:setMenu(self.currentGroup)
        self.shouldRedraw = true
    end
end

function M:handleInput(event)
    if self.confirmDelete and self.confirmDelete.isOpen then
        self.confirmDelete:handleInput(event.type)
        return
    end
    self.menu:handleInput(event)

    if event.scope == "global" then
        if event.type == "main_nav_left" or event.type == "main_nav_right" then
            return
        elseif event.type == "nav_left" then
            self:pageLeft()
        elseif event.type == "nav_right" then
            self:pageRight()
        end
        if event.type == "secondary" then
            if hash.cheapHash(self.config) ~= self.lastSavedConfig then
                self.configManager:save()
                self.systemeventsubscriber:publish("config_saved", { config = self.config })
                self.lastSavedConfig = hash.cheapHash(self.config)
            end
        end

        if event.type == "tertiary" then
            self.displayHelp = not self.displayHelp
        end

        -- dont bother throwing these events within keyboard scope
        if hash.cheapHash(self.config) ~= self.lastSavedConfig then
            if self.configChangeState == "unchanged" then
                self.systemeventsubscriber:publish("config_changed", { config = self.config })
                self.configChangeState = "changed"
            end
        end

        if hash.cheapHash(self.config) == self.lastSavedConfig then
            if self.configChangeState == "changed" then
                self.systemeventsubscriber:publish("config_unchanged", { config = self.config })
                self.configChangeState = "unchanged"
            end
        end
    end

    -- crude, but just redraw on every input just in case
    self.shouldRedraw = true
end

function M:_handleFullReset()
    -- dispatch replace DB task
    self.thread:dispatchTasks("database", {
        {
            type = "replace",
        },
    }, { progressStyle = "modal", progressText = "Replacing Database (please wait)", skipThreadCreation = true })

    -- replace mixes
    local mixRepository = require("repository.mix")(self.database)
    mixRepository:importPresets()

    -- clear cache
    local clearCacheCmd = string.format("rm -rf %s", stringUtil.shellQuote(self.environment:getPath("cache")))
    os.execute(clearCacheCmd)
end

function M:update(dt)
    if self.shouldRedraw == false then
        return
    end
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(colors.black)

    self.groupNavigation:draw(self.canvas, self.currentGroup)

    -- help
    if self.displayHelp then
        love.graphics.setCanvas(self.canvas)
        local helpY = SCREEN.h - SCREEN.hUnit(15)
        local helpStrokeWidth = 2
        love.graphics.setColor(colors.helpBg)
        love.graphics.rectangle(
            "fill",
            helpStrokeWidth,
            helpY,
            SCREEN.w - helpStrokeWidth * 2,
            SCREEN.mainH - helpY - (helpStrokeWidth * 2)
        )
        love.graphics.setLineWidth(helpStrokeWidth)
        love.graphics.setColor(colors.helpStroke)
        love.graphics.rectangle(
            "line",
            helpStrokeWidth,
            helpY,
            SCREEN.w - helpStrokeWidth * 2,
            SCREEN.mainH - helpY - (helpStrokeWidth * 2)
        )
        love.graphics.setColor(colors.offWhite)
        love.graphics.setFont(ASSETS.font.inconsolita.medium(FONTSIZE.s))
        local helpText = self.menu:getCurrentDefinition().description or "Help Text Missing"
        love.graphics.printf(helpText, SCREEN.wUnit(0.5), helpY + SCREEN.hUnit(1), SCREEN.w - SCREEN.wUnit(1), "left")
        love.graphics.setLineWidth(1)
    end

    -- draw options groups
    self.menu:update(dt)
    self.menu:draw()

    -- only set this to false if not with an open widget, like 'keyboard' as this needs constant redraws
    if not self.menu:isCurrentOptionOpen() then
        self.shouldRedraw = false
    end
    love.graphics.setCanvas()
end

function M:draw(dt)
    love.graphics.setColor(colors.white)
    love.graphics.draw(self.canvas, 0, SCREEN.headerH)
    if self.confirmDelete then
        self.confirmDelete:draw()
    end
end

return M
