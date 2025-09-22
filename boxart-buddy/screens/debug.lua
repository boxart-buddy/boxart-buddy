-- Used as a general purpose 'menu' class to group types of options or buttons and handle input/navigation

local Menu = require("gui.widget.group.menu")

---@class DebugScreen
local M = class({
    name = "DebugScreen",
})

function M:new(
    environment,
    systemeventsubscriber,
    inputeventsubscriber,
    orchestrator,
    database,
    platform,
    mixStrategyProvider
)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.orchestrator = orchestrator
    self.mediaRepository = require("repository.media")(database, environment)
    self.romRepository = require("repository.rom")(database)
    self.platform = platform
    self.mixStrategyProvider = mixStrategyProvider
    self.canvas = nil
    self.buttonList = nil

    self.boundInputHandler = function(e)
        self:handleInput(e)
    end

    self.boundRefreshButtonList = function(e)
        self:initButtonList()
    end
end

function M:initButtonList()
    local buttonDefinitions = {
        {
            key = "import_dat",
            type = "button",
            options = {
                buttonWidth = 300,
                buttonHeight = 30,
                labelWidth = 0,
                align = "center",
                onConfirm = function()
                    self.orchestrator:request("import_dat")
                end,
            },
            label = "Run DAT File Import",
        },
        {
            key = "crawl_libretro_thumbs",
            type = "button",
            options = {
                buttonWidth = 300,
                buttonHeight = 30,
                labelWidth = 0,
                align = "center",
                onConfirm = function()
                    self.orchestrator:request("crawl_libretro_thumbs")
                end,
            },
            label = "Generate Libretro Thumb TXT",
        },
        {
            key = "write_platforms_index",
            type = "button",
            options = {
                buttonWidth = 300,
                buttonHeight = 30,
                labelWidth = 0,
                align = "center",
                onConfirm = function()
                    self.platform.writeCombinedIndex(self.environment:getPath("resources"))
                end,
            },
            label = "Write Platforms Index",
        },
    }
    self.buttonList = Menu(self.canvas, self.systemeventsubscriber, buttonDefinitions, {}, {
        width = SCREEN.w,
        height = SCREEN.mainH,
        x = 20,
        y = 20,
        spacingY = 50,
        textAlign = "center",
        font = ASSETS.font.univers.regular(FONTSIZE.s),
    })
end

function M:enter()
    self.inputeventsubscriber:subscribe("input", self.boundInputHandler)
    self.systemeventsubscriber:subscribe("action_complete_async", self.boundRefreshButtonList)

    self.systemeventsubscriber:publish("screen_enter", { screen = "DEBUG" })
    self.canvas = love.graphics.newCanvas(SCREEN.w, SCREEN.mainH, { msaa = 8 })
    self:initButtonList()
end

function M:exit()
    self.inputeventsubscriber:unsubscribe("input", self.boundInputHandler)
    self.systemeventsubscriber:unsubscribe("action_complete_async", self.boundRefreshButtonList)
    self.systemeventsubscriber:publish("screen_exit", { screen = "DEBUG" })

    self.buttonList = nil
    self.canvas = nil
end

function M:handleInput(event)
    if event.type == "main_nav_left" or event.type == "main_nav_right" then
        return
    elseif event.type == "confirm" or event.type == "up" or event.type == "down" then
        self.buttonList:handleInput(event)
    end
end

function M:update(dt)
    self.buttonList:update()
end

function M:draw(dt)
    self.buttonList:draw()
    love.graphics.draw(self.canvas, 0, SCREEN.footerH)
end

return M
