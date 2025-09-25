local colors = require("util.colors")
local layout = require("util.layout")
local PillBar = require("gui.widget.pillbar")

---@class TopNav
local M = class({
    name = "TopNav",
})

function M:new(environment, systemeventsubscriber, inputeventsubscriber)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.canvas = love.graphics.newCanvas(SCREEN.w, SCREEN.headerH, { msaa = 8 })

    self.screens = {
        "HOME",
        "ROMS",
        "MIX",
        "CONF",
    }

    if environment:getConfig("env_debug_menu") then
        table.insert(self.screens, "DEV")
    end

    self.current = "HOME"
    self.lastUpdated = nil

    self.pillbar = PillBar(self.canvas, self.screens, self.current, {
        colors = {
            bg = colors.veryDarkGrey,
            activeBg = colors.midGrey,
            image = colors.darkGrey,
        },
        width = SCREEN.w,
        height = SCREEN.hUnit(3.5),
        barPadY = SCREEN.hUnit(0.3),
        pillPadX = SCREEN.wUnit(1),
        imageLeft = ASSETS.image.button.gamepad.small.l2,
        imageRight = ASSETS.image.button.gamepad.small.r2,
        imageMargin = SCREEN.wUnit(1),
        font = ASSETS.font.inter.bold(FONTSIZE.m),
        cycle = true,
    })

    self.active = true

    -- dont need to bind/unbind as never destroyed
    systemeventsubscriber:subscribe("screen_enter", function(e)
        if e.screen == "SPLASH" then
            self.active = false
        end
    end)

    systemeventsubscriber:subscribe("screen_exit", function(e)
        if e.screen == "SPLASH" then
            self.active = true
        end
    end)

    inputeventsubscriber:subscribe("input", function(e)
        self:handleInput(e)
    end)

    self.inputHandlers = {
        main_nav_left = function()
            local current = self.pillbar:handleInput("left")
            if current ~= self.current then
                self.current = current
                self.systemeventsubscriber:publish("screen_change", { screen = self.current })
            end
        end,
        main_nav_right = function()
            local current = self.pillbar:handleInput("right")
            if current ~= self.current then
                self.current = current
                self.systemeventsubscriber:publish("screen_change", { screen = self.current })
            end
        end,
    }
end

function M:handleInput(e)
    if not self.active then
        return
    end
    if e.scope ~= "global" then
        return
    end
    local handler = self.inputHandlers[e.type]
    if handler then
        handler()
    end
end

function M:update(dt)
    if not self.active then
        return
    end
    if self.current == self.lastUpdated then
        return
    end

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(colors.black)

    self.pillbar:draw(self.current)

    love.graphics.setCanvas(self.canvas)

    love.graphics.setCanvas()
    self.lastUpdated = self.current
end

function M:draw()
    love.graphics.setColor(colors.white)
    love.graphics.setCanvas()
    love.graphics.draw(self.canvas, layout.centreX(self.canvas:getWidth()), 4)
end

return M
