-- Setup & Boot Container
local bootstrap = require("bootstrap")({ projectRoot = require("util.env"):demandArg("project-root") })
local DIC = bootstrap:getDIC()
local orchestrator = require("module.orchestrator")(DIC) -- BAD

-- wrapper / top nav / footer
local screenwrapper = require("src.screenwrapper")(
    DIC.environment,
    DIC.systemeventsubscriber,
    DIC.inputeventsubscriber,
    DIC.input,
    DIC.flux,
    DIC.progressRegistry,
    DIC.thread
)
local topNav = require("src.topnav")(DIC.environment, DIC.systemeventsubscriber, DIC.inputeventsubscriber)
local footer = require("src.footer")(DIC.systemeventsubscriber)
-- end top nav

-- Screens
local launchScreen
local screens

local romFilterDataProvider = require("dat.filter_data_provider")(DIC.database, DIC.systemeventsubscriber)
screens = {
    SPLASH = require("screens.splash")(
        DIC.environment,
        DIC.systemeventsubscriber,
        DIC.database,
        DIC.thread,
        DIC.logger
    ),
    ROMFILTER = require("screens.rom_filter")(
        DIC.systemeventsubscriber,
        DIC.inputeventsubscriber,
        romFilterDataProvider,
        DIC.previousCanvas
    ),
    ROMOPTIONS = require("screens.rom_options")(
        DIC.systemeventsubscriber,
        DIC.inputeventsubscriber,
        DIC.database,
        DIC.previousCanvas
    ),
    ROMSCRAPE = require("screens.rom_scrape")(
        DIC.environment,
        DIC.systemeventsubscriber,
        DIC.inputeventsubscriber,
        DIC.database,
        DIC.mediaTypeProvider,
        DIC.thread,
        DIC.flux,
        DIC.previousCanvas,
        require("module.scraper")(
            DIC.environment,
            DIC.logger,
            DIC.systemeventsubscriber,
            DIC.database,
            DIC.platform,
            DIC.thread,
            DIC.ratelimithttps,
            DIC.mediaTypeProvider
        )
    ),
    HOME = require("screens.home")(
        DIC.environment,
        DIC.systemeventsubscriber,
        DIC.inputeventsubscriber,
        orchestrator,
        DIC.database,
        DIC.mixStrategyProvider,
        DIC.mediaTypeProvider,
        romFilterDataProvider,
        DIC.previousCanvas
    ),
    ROMS = require("screens.roms")(
        DIC.environment,
        DIC.systemeventsubscriber,
        DIC.inputeventsubscriber,
        DIC.database,
        DIC.thread,
        romFilterDataProvider,
        require("module.scraper")(
            DIC.environment,
            DIC.logger,
            DIC.systemeventsubscriber,
            DIC.database,
            DIC.platform,
            DIC.thread,
            DIC.ratelimithttps,
            DIC.mediaTypeProvider
        ),
        DIC.mediaTypeProvider,
        DIC.previousCanvas
    ),
    STAT = require("screens.stat")(
        DIC.environment,
        DIC.database,
        DIC.inputeventsubscriber,
        DIC.systemeventsubscriber,
        DIC.mediaTypeProvider
    ),
    MIX = require("screens.mix")(
        DIC.environment,
        DIC.systemeventsubscriber,
        DIC.inputeventsubscriber,
        DIC.thread,
        DIC.database,
        orchestrator,
        DIC.mixStrategyProvider
    ),
    CONF = require("screens.config")(
        DIC.environment,
        DIC.systemeventsubscriber,
        DIC.inputeventsubscriber,
        DIC.database,
        DIC.configManager,
        DIC.thread
    ),
}

if DIC.configManager:get("env_debug_menu") then
    screens.DEV = require("screens.debug")(
        DIC.environment,
        DIC.systemeventsubscriber,
        DIC.inputeventsubscriber,
        orchestrator,
        DIC.database,
        DIC.platform,
        DIC.mixStrategyProvider
    )
end
launchScreen = "SPLASH"

local screenState = state_machine(screens, launchScreen)
-- End Screens

-- bind top nav events to screen changes
DIC.systemeventsubscriber:subscribe("screen_change", function(event)
    screenState:set_state(event.screen)
end)
-- end bind top nav events

function love.load()
    local quitFunction = function(e)
        if e.type ~= "quit" then
            return
        end
        -- dont need to check scope as quit should apply in all contexts
        DIC.thread:killAll()
        DIC.database:close()
        love.event.quit()
        return
    end

    DIC.inputeventsubscriber:subscribe("input", quitFunction)
end

function love.update(dt)
    DIC.input:update(dt)
    DIC.logger:update()
    DIC.flux.update(dt)
    DIC.console:update(dt)
    DIC.thread:update(dt)

    screenState:update(dt)
    topNav:update(dt)
    screenwrapper:update(dt)
    footer:update()
end

function love.draw()
    topNav:draw()
    footer:draw()
    screenState:draw()
    screenwrapper:draw()
    DIC.console:draw()
end

-- function love.threaderror(thread, errorstr)
--     DIC.logger:log("error", "thread", errorstr)
-- end
