local path = require("util.path")
local filesystem = require("lib.nativefs")
local socket = require("socket")

---@class SplashScreen
local M = class({
    name = "SplashScreen",
})

function M:new(environment, systemeventsubscriber, database, thread, logger)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.database = database
    self.mixRepository = require("repository.mix")(database)
    self.thread = thread
    self.logger = logger
    self.endSplash = false
    self.logo = love.graphics.newImage("assets/image/logo.png")
    self.jingle = ASSETS.sound.splash.k
    self.initComplete = false
    self.skipSplash = false

    -- event subscriber
    self.boundDbInitComplete = function()
        self.initComplete = true
    end
end

function M:enter()
    if self.environment:getConfig("ui_skip_splash") then
        self.skipSplash = true
    end

    self.splashtimer = timer(self.skipSplash and 0.01 or 3, function() end, function()
        self.endSplash = true
    end)
    if (not self.skipSplash) and (not self.environment:getConfig("ui_mute_sound")) then
        love.audio.play(self.jingle)
    end
    self.systemeventsubscriber:publish("screen_enter", { screen = "SPLASH" })
    self.systemeventsubscriber:subscribe("init_db_complete", self.boundDbInitComplete)
    -- rotate logs
    if self.logger.handlers.file then
        self.logger.handlers.file:cleanupOldLogs(7)
    end
end

function M:exit()
    -- wont need it again
    ASSETS.sound.splash.k = nil
    self.systemeventsubscriber:unsubscribe("init_db_complete", self.boundDbInitComplete)
    self.systemeventsubscriber:publish("screen_exit", { screen = "SPLASH" })
end

function M:update(dt)
    if self.splashtimer then
        self.splashtimer:update(dt)
    end
    if self.endSplash then
        if self.database:isInitialized() then
            self.initComplete = true
            self.endSplash = false
            return
        end
        -- send command to init database
        self.thread:dispatchTasks("init_db", {
            {
                type = "initialize",
            },
        }, {
            progressStyle = "modal",
            progressText = "Initializing Database (please wait)",
            silentThread = true,
            skipThreadCreation = true,
        })

        self.endSplash = false -- set back to false to prevent block from running again
    end
    if self.initComplete then
        self:_initMixes()
        --check that database is initialized and if it isn't then do it NOW, only navigate to main app once it's been done
        self.systemeventsubscriber:publish("screen_exit", { screen = "SPLASH" })
        return "HOME"
    end
end

function M:draw(dt)
    if not self.initComplete and not self.skipSplash then
        local logoHeight = self.logo:getHeight()
        local logoWidth = self.logo:getWidth()
        love.graphics.draw(self.logo, (SCREEN.w - logoWidth) / 2, (SCREEN.h - logoHeight) / 2)
    end
end

function M:_initMixes()
    local initializedPath = self.environment:getPath("initialized_mix_presets")
    for i = 1, 10 do
        if filesystem.getInfo(initializedPath) then
            return
        end
        socket.sleep(0.1)
    end

    self.mixRepository:importPresets()

    filesystem.write(initializedPath, "")
end

return M
