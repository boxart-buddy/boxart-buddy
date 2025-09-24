-- override error handler
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("error")
else
    require("error_user_friendly")
end

-- needed early for class system
require("lib.batteries"):export()
local screenUtil = require("util.screen")
local layout = require("util.layout")
local fontScale = require("util.fontscale")
local path = require("util.path")
local filesystem = require("lib.nativefs")
local socket = require("socket")

-- rng
math.randomseed(os.time() + tonumber(tostring(os.clock()):reverse()))

--asset manager with global scope
ASSETS = require("lib.cargo").init("assets")

---------- SCREEN AND FONT SIZERS --------
local screenW, screenH, screenS = screenUtil.getResolution()
SCREEN = {
    w = screenW or 640,
    h = screenH or 480,
    size = screenS or 3.5,
}
--10px
SCREEN.hUnit = function(u)
    return math.floor((SCREEN.h / 48) * u)
end
--20px
SCREEN.wUnit = function(u)
    return math.floor((SCREEN.w / 32) * u)
end
SCREEN.hDiv = layout:divider(SCREEN.h)
SCREEN.wDiv = layout:divider(SCREEN.w)
SCREEN.footerH = SCREEN.hUnit(4.2)
SCREEN.headerH = SCREEN.hUnit(4.2)
SCREEN.mainH = SCREEN.h - SCREEN.footerH - SCREEN.headerH

FONTSIZE = fontScale.getFontSizes(SCREEN.w, SCREEN.h, SCREEN.size)
---------- SCREEN AND FONT SIZERS --------

---------- DIRTY DEBUG FUNCTIONS -------------------
-- dirty utility debug/print function
function DD(any)
    print(pretty.string(any))
end
function DDD(msg)
    local f = filesystem.newFile("/tmp/bb-crash.txt")
    local ok, err = f:open("a") -- open in append mode
    if ok then
        f:write(msg)
        f:close()
    else
        error("Failed to open log file")
    end
end
---------- DIRTY DEBUG FUNCTIONS -------------------
---
--@class Bootstrap
local M = class({
    name = "Bootstrap",
})

function M:new(options)
    self.options = options
    self.configManager =
        require("module.config_manager")(path.join({ self:_getOption("projectRoot"), "data", "config", "config.toml" }))

    local initConfig = function()
        local initializedPath = path.join({ self:_getOption("projectRoot"), "data", "initialized_conf" })
        for i = 1, 10 do
            if filesystem.getInfo(initializedPath) then
                return
            end
            socket.sleep(0.1)
        end

        if filesystem.getInfo(path.join({ self:_getOption("projectRoot"), "data", "config", "config.toml" })) then
            error("config already exists")
        end

        self.configManager:createFreshFromDefaults()

        filesystem.write(path.join({ self:_getOption("projectRoot"), "data", "initialized_conf" }), "")
    end

    initConfig()

    self.environment = require("module.environment")(options.projectRoot, self.configManager)

    -- load gamepad DB if desktop/enabled (already loaded in muOS)
    if
        not self.environment:isMuOs()
        and not self.environment:isThread()
        and self.environment:getConfig("env_use_gamepad")
    then
        love.joystick.loadGamepadMappings(filesystem.read(self.environment:getPath("gamecontrollerdb")))
    end

    -- ADD NATIVE CPATHS TO LOADER
    self.environment.ensureSupported()
    package.cpath = package.cpath .. ";" .. self.environment:getPath("native")
    package.path = package.path
        .. ";"
        .. path.join({ self.environment:getPath("lib"), "?.lua" })
        .. ";"
        .. path.join({ self.environment:getPath("lib"), "?", "init.lua" })

    -- unsubtle.. .for ffi includes
    FFI_INCLUDE_PATH = self.environment:getPath("nativeffi")

    -- INIT DEBUGGER
    if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" and (self.environment.isThread() == false) then
        require("lldebugger").start()
        DEBUG_LEVEL = 1
    elseif self.environment.isThread() then
        DEBUG_LEVEL = 0
    else
        DEBUG_LEVEL = 0
    end
end

function M:_getOption(name)
    if self.options and type(self.options) == "table" and self.options[name] ~= nil then
        return self.options[name]
    end

    return nil
end

-- Define DI Container
function M:getDIC()
    if self.instantiated then
        error("DIC should only be instantiated once")
    end

    local DIC = {}

    local inputeventsubscriber = pubsub()
    local systemeventsubscriber = pubsub()

    local flux = require("lib.flux")

    ---@type Logger
    local logger = require("module.logger")(self.environment)
    -- only set global to allow error handler to flush logger, do not use the global in other places
    LOGGER = logger
    ---@type Thread
    local thread = require("module.thread")(systemeventsubscriber, self.environment, logger)
    ---@type Input
    local input = require("module.input")(inputeventsubscriber)
    ---@type Platform
    local platform = require("module.platform")(self.environment, logger)
    ---@type Database
    local database = require("module.database")(self.environment, logger, thread)
    ---@type ProgressRegistry
    local progressRegistry = require("module.progress_registry")(systemeventsubscriber, logger)
    ---@type Console
    local console =
        require("module.console")(self.environment, systemeventsubscriber, inputeventsubscriber, flux, thread)
    ---@type RateLimitedHttps
    local ratelimithttps = require("module.rate_limit_https")(logger)
    ---@type MediaTypeProvider
    local mediaTypeProvider = require("dat.media_type_provider")(self.environment)
    ---@type MixStrategyProvider
    local mixStrategyProvider = require("module.mix.strategy.provider")(mediaTypeProvider, database)
    ---@type PreviousCanvas
    local previousCanvas = require("module.previous_canvas")()

    if self.environment:getConfig("log_file") == true then
        local fileLogLevel = self.environment:getConfig("log_file_level")
        logger:registerHandler("file", fileLogLevel, require("module.log_handler.file")(self.environment, thread))
    end

    if self.environment:getConfig("log_print") == true then
        local printLogLevel = self.environment:getConfig("log_file_level")
        logger:registerHandler("print", printLogLevel, require("module.log_handler.print")())
    end

    if not self:_getOption("thread") then
        if self.environment:getConfig("log_console") == true then
            local consoleLogLevel = self.environment:getConfig("log_console_level")
            logger:registerHandler("console", consoleLogLevel, require("module.log_handler.console")(console))
        end

        -- long running threads only created in main thread
        thread:addThreadToPool(
            "database",
            { sendResult = false, sendProgress = false, permanent = true, worker = "database" }
        )
        thread:addThreadToPool("file_logger", { sendResult = false, sendProgress = false, permanent = true })
        thread:addThreadToPool("orchestrator", { permanent = true, worker = "orchestrator" })
    end

    DIC.configManager = self.configManager
    DIC.environment = self.environment
    DIC.inputeventsubscriber = inputeventsubscriber
    DIC.systemeventsubscriber = systemeventsubscriber
    DIC.input = input
    DIC.console = console
    DIC.logger = logger
    DIC.flux = flux
    DIC.database = database
    DIC.thread = thread
    DIC.platform = platform
    DIC.progressRegistry = progressRegistry
    DIC.ratelimithttps = ratelimithttps
    DIC.mediaTypeProvider = mediaTypeProvider
    DIC.mixStrategyProvider = mixStrategyProvider
    DIC.previousCanvas = previousCanvas
    -- GLOBALDIC = DIC -- delete this for debugging only

    -- init DB if needed (creates DB from fixture on first run only)
    --DIC.database:initialize()

    self.instantiated = true
    return DIC
end

return M
