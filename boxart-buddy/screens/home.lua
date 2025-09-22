local netcheck = require("util.netcheck")
local Menu = require("gui.widget.group.menu")
local colors = require("util.colors")

---@class HomeScreen
local M = class({
    name = "HomeScreen",
})

function M:new(
    environment,
    systemeventsubscriber,
    inputeventsubscriber,
    orchestrator,
    database,
    mixStrategyProvider,
    mediaTypeProvider,
    romFilterDataProvider,
    previousCanvas
)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.orchestrator = orchestrator
    self.mediaRepository = require("repository.media")(database, environment)
    self.romRepository = require("repository.rom")(database)
    self.mixStrategyProvider = mixStrategyProvider
    self.mediaTypeProvider = mediaTypeProvider
    self.romFilterDataProvider = romFilterDataProvider
    self.previousCanvas = previousCanvas
    self.canvas = nil
    self.buttonList = nil

    self.startFx = ASSETS.sound.fx.start
    --self.successFx = ASSETS.sound.fx.exit_success

    self.filters = nil

    self.boundInputHandler = function(e)
        self:handleInput(e)
    end

    self.boundRefreshButtonList = function(e)
        self:updateLastScanAndRomCount()
        self:initButtonList()
    end
end

function M:initButtonList()
    local hasRoms = self.romRepository:hasRoms()
    if not hasRoms then
        self.systemeventsubscriber:publish("footer_button_state_change", { text = "FILTER", enabled = false })
    end
    local hasMedia = self.mediaRepository:hasMedia()

    -- scrape rom subtext
    local scrapeRomSubText = "No roms"
    if self:_allPlatformsFiltered() then
        scrapeRomSubText = "all platforms filtered out"
    else
        scrapeRomSubText = self:_isFilterApplied() and string.format("%s roms (filtered)", self.romCount)
            or string.format("%s roms", self.romCount)
    end

    local mute = self.environment:getConfig("ui_mute_sound")
    local buttonDefinitions = {
        {
            key = "scrape_roms",
            type = "button",
            label = "Scrape",
            description = "Uses configured scraping services to download media/images for your scanned roms",
            options = {
                subText = scrapeRomSubText,
                subTextFont = ASSETS.font.univers.bold(FONTSIZE.m),
                x = (SCREEN.w - SCREEN.wUnit(22)) / 2,
                buttonWidth = SCREEN.wUnit(22),
                buttonHeight = SCREEN.hUnit(7),
                textOffsetX = SCREEN.wUnit(6),
                iconOffsetX = SCREEN.wUnit(1.5),
                disabled = not hasRoms or self:_allPlatformsFiltered(),
                textTransform = "upper",
                textAlign = "left",
                icon = "download",
                iconScale = 0.35,
                onConfirm = function()
                    if not netcheck.hasInternet() then
                        self.systemeventsubscriber:publish(
                            "toast_create",
                            { message = "No Connection to Internet. Cannot scrape", typ = "error" }
                        )
                    else
                        local params = nil
                        if self:_isFilterApplied() then
                            params = { options = { platforms = self:_getFilterPlatforms() } }
                        end
                        if not mute then
                            love.audio.play(self.startFx)
                        end
                        self.orchestrator:request("scrape_roms", params)
                    end
                end,
            },
        },
        {
            key = "generate_mix",
            type = "button",
            label = "Generate Mixes",
            description = "Combines scraped images to make a composite 'mix' for display in the background or foreground when browsing roms",
            options = {
                subText = (self.selectedPreset ~= nil) and self.selectedPreset.name or nil,
                subTextFont = ASSETS.font.univers.bold(FONTSIZE.m),
                x = (SCREEN.w - SCREEN.wUnit(22)) / 2,
                buttonWidth = SCREEN.wUnit(22),
                buttonHeight = SCREEN.hUnit(7),
                textOffsetX = SCREEN.wUnit(6),
                iconOffsetX = SCREEN.wUnit(1.5),
                disabled = not hasMedia or not hasRoms or self:_allPlatformsFiltered() or not self.selectedPreset,
                textTransform = "upper",
                textAlign = "left",
                icon = "art",
                iconScale = 0.35,
                onConfirm = function()
                    local preset = self.selectedPreset
                    if preset then
                        local params = {
                            strategyName = preset.strategy,
                            mixOptions = preset.values,
                        }
                        if self:_isFilterApplied() then
                            params.platforms = self:_getFilterPlatforms()
                        end
                        if not mute then
                            love.audio.play(self.startFx)
                        end
                        self.orchestrator:request("mix", params)
                    end
                end,
            },
        },
        {
            key = "pack_images",
            type = "button",
            label = "Pack Images",
            description = "Copies images and mixes into the catalogue, or into an archive file",
            options = {
                subText = self.environment:getConfig("pack_archive") and "Catalog Package" or "Direct Install",
                subTextFont = ASSETS.font.univers.bold(FONTSIZE.m),
                x = (SCREEN.w - SCREEN.wUnit(22)) / 2,
                buttonWidth = SCREEN.wUnit(22),
                buttonHeight = SCREEN.hUnit(7),
                textOffsetX = SCREEN.wUnit(6),
                iconOffsetX = SCREEN.wUnit(1.5),
                disabled = not (hasRoms and hasMedia),
                textTransform = "upper",
                textAlign = "left",
                iconScale = 0.35,
                icon = "openbox",
                onConfirm = function()
                    local params = {}
                    if self:_isFilterApplied() then
                        params.platforms = self:_getFilterPlatforms()
                    end
                    if not mute then
                        love.audio.play(self.startFx)
                    end
                    self.orchestrator:request("pack", params)
                end,
            },
        },
    }
    self.buttonList = Menu(self.canvas, self.systemeventsubscriber, buttonDefinitions, {}, {
        width = SCREEN.w,
        height = SCREEN.mainH,
        y = SCREEN.hUnit(10),
        widgetHeight = SCREEN.hUnit(9),
        font = ASSETS.font.univers.bold(FONTSIZE.xxl),
        labelWidth = 0,
    })
end

function M:_getFilterPlatforms()
    local platforms = {}
    for platform, selected in pairs(self.filters.platforms) do
        if selected == true then
            table.insert(platforms, platform)
        end
    end
    return platforms
end

function M:_allPlatformsFiltered()
    return self:_isFilterApplied() and #self:_getFilterPlatforms() == 0
end

function M:_isFilterApplied()
    for k, v in pairs(self.filters.platforms) do
        if v == false then
            return true
        end
    end
    return false
end

function M:enter()
    self.inputeventsubscriber:subscribe("input", self.boundInputHandler)
    self.systemeventsubscriber:subscribe("action_complete_async", self.boundRefreshButtonList)
    self.systemeventsubscriber:subscribe("default_filters_updated", self.boundRefreshButtonList)

    self.systemeventsubscriber:publish("screen_enter", { screen = "HOME" })
    self.canvas = love.graphics.newCanvas(SCREEN.w, SCREEN.mainH, { msaa = 8 })

    self.selectedPreset = self.mixStrategyProvider:getSelectedPreset()
    self:updateLastScanAndRomCount()
    self:initButtonList()
end

function M:updateLastScanAndRomCount()
    self.lastScan = self.romRepository:getLastCreated()
    self.filters = table.deep_copy(self.romFilterDataProvider:getFilters())
    self.filters.verified = nil
    self.filters.media = nil
    -- get count of roms (with filter applied)
    local _romData, count =
        self.romRepository:getRomTableData(4, 1, self.filters, self.mediaTypeProvider:getScrapeMediaTypes())
    self.romCount = count
end

function M:exit()
    self.inputeventsubscriber:unsubscribe("input", self.boundInputHandler)
    self.systemeventsubscriber:unsubscribe("action_complete_async", self.boundRefreshButtonList)
    self.systemeventsubscriber:unsubscribe("default_filters_updated", self.boundRefreshButtonList)
    self.systemeventsubscriber:publish("screen_exit", { screen = "HOME" })

    self.buttonList = nil
    self.transitionTo = nil
    self.previousCanvas:set(self.canvas, "HOME")
    self.canvas = nil
end

function M:handleInput(event)
    if event.scope ~= "global" then
        return
    end

    if event.type == "main_nav_left" or event.type == "main_nav_right" then
        return
    elseif event.type == "tertiary" then
        if self.romRepository:hasRoms() then
            self.transitionTo = "ROMFILTER"
        end
    elseif event.type == "start" then
        -- rescan
        love.audio.play(self.startFx)
        self.orchestrator:request("scan_roms")
    elseif event.type == "confirm" or event.type == "up" or event.type == "down" then
        self.buttonList:handleInput(event)
    end
end

function M:update(dt)
    if self.transitionTo then
        return self.transitionTo
    end
    self.buttonList:update()
end

function M:draw(dt)
    -- draw to main canvas
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0) -- clear if you want transparency

    self.buttonList:draw()

    -- LAST SCANNED
    local inlineTextFont = ASSETS.font.univers.bold(FONTSIZE.s)
    local lastScanText = "No roms scanned"
    if self.lastScan then
        lastScanText = string.format("Last Scan: %s", self.lastScan)
    end

    love.graphics.setFont(inlineTextFont)
    love.graphics.setColor(colors.white)
    love.graphics.printf(lastScanText, SCREEN.wUnit(3), SCREEN.hUnit(2), SCREEN.w, "left")

    -- ROM COUNT
    local romCountTextFormat = "%s roms"
    if self:_isFilterApplied() then
        romCountTextFormat = "%s roms (filtered)"
    end
    local romCountText = string.format(romCountTextFormat, self.romCount)

    love.graphics.printf(
        romCountText,
        (SCREEN.w - SCREEN.wUnit(3)) - inlineTextFont:getWidth(romCountText),
        SCREEN.hUnit(2),
        inlineTextFont:getWidth(romCountText),
        "right"
    )

    -- SCAN HINT
    if self.lastScan == nil then
        local scanHintFont = ASSETS.font.univers.bold(FONTSIZE.l)
        local scanHintText = "Press `START` to scan roms"

        love.graphics.setFont(scanHintFont)
        love.graphics.setColor(colors.white)
        love.graphics.printf(scanHintText, 0, SCREEN.hUnit(6), SCREEN.w, "center")
    end

    -- BUTTONS
    love.graphics.setCanvas()
    love.graphics.setColor(colors.white)
    love.graphics.draw(self.canvas, 0, SCREEN.footerH)
end

return M
