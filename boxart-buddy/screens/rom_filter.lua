local colors = require("util.colors")
local PillBar = require("gui.widget.pillbar")

---@class RomFilterScreen
local M = class({
    name = "RomFilterScreen",
})

function M:new(systemeventsubscriber, inputeventsubscriber, romFilterDataProvider, previousCanvas)
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.romFilterDataProvider = romFilterDataProvider
    self.previousCanvas = previousCanvas
    self.options = {}
    self.canvas = nil
    self.shouldRedraw = true
    self.transitionTo = nil
    self.prevCanvas = nil
    self.prevScreen = nil

    self.mediaSelect = nil
    self.verifiedSelect = nil

    self.currentOption = "verified" -- verified/media/platforms
    self.currentPlatformOption = 1

    -- bound functions
    self.inputHandlers = {
        tertiary = function()
            self:applyFilterChanges()
            self.transitionTo = self.prevScreen
        end,
        confirm = function()
            if self.currentOption ~= "platforms" then
                return
            end
            local currentPlatformOption, scrollY, toggledItem =
                self.platformGrid:handleInput("confirm", self.currentPlatformOption, self.platformGridScrollY)
            if toggledItem then
                self.filterDataTransient.platforms[toggledItem] = not self.filterDataTransient.platforms[toggledItem]
            end
            self.shouldRedraw = true
        end,
        secondary = function()
            -- toggle all
            local nTrue = 0
            local nFalse = 0
            local n = 0
            for key, value in pairs(self.filterDataTransient.platforms) do
                if value then
                    nTrue = nTrue + 1
                else
                    nFalse = nFalse + 1
                end
                n = n + 1
            end
            if nTrue == n then
                for key, value in pairs(self.filterDataTransient.platforms) do
                    self.filterDataTransient.platforms[key] = false
                end
            elseif nFalse == n then
                for key, value in pairs(self.filterDataTransient.platforms) do
                    self.filterDataTransient.platforms[key] = true
                end
            else
                for key, value in pairs(self.filterDataTransient.platforms) do
                    self.filterDataTransient.platforms[key] = true
                end
            end
            self.shouldRedraw = true
        end,
        up = function()
            if self.currentOption == "verified" then
                return
            elseif self.currentOption == "media" then
                self.currentOption = "verified"
                self.systemeventsubscriber:publish("filter_option_active", { option = "verified" })
                self.shouldRedraw = true
                return
            elseif
                self.currentOption == "platforms"
                and self.verifiedSelect
                and self.mediaSelect
                and (
                    self.currentPlatformOption == 1
                    or self.currentPlatformOption == 2
                    or self.currentPlatformOption == 3
                )
            then
                self.currentOption = "media"
                self.systemeventsubscriber:publish("filter_option_active", { option = "media" })
                self.shouldRedraw = true
            elseif self.currentOption == "platforms" then
                local currentPlatformOption, scrollY, toggledItem =
                    self.platformGrid:handleInput("up", self.currentPlatformOption, self.platformGridScrollY)
                self.currentPlatformOption = currentPlatformOption
                self.platformGridScrollY = scrollY
                self.shouldRedraw = true
            end
        end,
        down = function()
            if self.currentOption == "verified" then
                self.currentOption = "media"
                self.systemeventsubscriber:publish("filter_option_active", { option = "media" })
                self.shouldRedraw = true
                return
            end
            if self.currentOption == "media" then
                self.currentOption = "platforms"
                self.systemeventsubscriber:publish("filter_option_active", { option = "platforms" })
                self.shouldRedraw = true
                return
            elseif self.currentOption == "platforms" then
                local currentPlatformOption, scrollY, toggledItem =
                    self.platformGrid:handleInput("down", self.currentPlatformOption, self.platformGridScrollY)
                self.currentPlatformOption = currentPlatformOption
                self.platformGridScrollY = scrollY
                self.shouldRedraw = true
            end
        end,
        left = function()
            if self.currentOption == "verified" then
                local current = self.verifiedSelect:handleInput("left")
                if current ~= self.filterDataTransient.verified then
                    self.filterDataTransient.verified = current
                    self.shouldRedraw = true
                end
            elseif self.currentOption == "media" then
                local current = self.mediaSelect:handleInput("left")
                if current ~= self.filterDataTransient.media then
                    self.filterDataTransient.media = current
                    self.shouldRedraw = true
                end
            elseif self.currentOption == "platforms" then
                local currentPlatformOption, scrollY, toggledItem =
                    self.platformGrid:handleInput("left", self.currentPlatformOption, self.platformGridScrollY)
                self.currentPlatformOption = currentPlatformOption
                self.shouldRedraw = true
            end
        end,
        right = function()
            if self.currentOption == "verified" then
                local current = self.verifiedSelect:handleInput("right")
                if current ~= self.filterDataTransient.verified then
                    self.filterDataTransient.verified = current
                    self.shouldRedraw = true
                end
            elseif self.currentOption == "media" then
                local current = self.mediaSelect:handleInput("right")
                if current ~= self.filterDataTransient.media then
                    self.filterDataTransient.media = current
                    self.shouldRedraw = true
                end
            elseif self.currentOption == "platforms" then
                local currentPlatformOption, scrollY, toggledItem =
                    self.platformGrid:handleInput("right", self.currentPlatformOption, self.platformGridScrollY)
                self.currentPlatformOption = currentPlatformOption
                self.shouldRedraw = true
            end
        end,
    }
    self.boundEventHandler = function(e)
        self:handleInput(e)
    end
end

function M:handleInput(e)
    local handler = self.inputHandlers[e.type]
    if handler then
        handler()
    end
end

function M:enter()
    self.canvas = love.graphics.newCanvas(SCREEN.w, SCREEN.mainH, { msaa = 8 })
    self.prevCanvas, self.prevScreen = self.previousCanvas:get()

    if self.prevScreen == "HOME" then
        self.currentOption = "platforms"
        self.currentPlatformOption = 1
    end

    self.filterData = self.romFilterDataProvider:getFilters()
    self.filterDataTransient = table.deep_copy(self.filterData)

    self.options = self.romFilterDataProvider:getOptions()

    local platformY = SCREEN.hUnit(4)
    if self.prevScreen == "ROMS" then
        -- select widgets
        self.verifiedSelect = PillBar(self.canvas, self.options.verified, self.filterDataTransient.verified, {
            width = SCREEN.wUnit(17),
            height = SCREEN.hUnit(3.6),
            x = SCREEN.wUnit(3),
            y = SCREEN.hUnit(0.2),
            align = "left",
            pillPadX = SCREEN.wUnit(1),
            barPadY = SCREEN.hUnit(0.2),
            barPadX = SCREEN.wUnit(1),
            uppercaseText = true,
            labelWidth = SCREEN.wUnit(5),
            colors = {
                bg = colors.offBlack,
                activeBg = colors.midGrey,
            },
            label = "VERIFIED",
        })

        self.mediaSelect = PillBar(self.canvas, self.options.media, self.filterDataTransient.media, {
            width = SCREEN.wUnit(17),
            height = SCREEN.hUnit(3.6),
            x = SCREEN.wUnit(3),
            y = SCREEN.hUnit(5.4),
            align = "left",
            pillPadX = SCREEN.wUnit(1),
            barPadY = SCREEN.hUnit(0.2),
            barPadX = SCREEN.wUnit(1),
            uppercaseText = true,
            labelWidth = SCREEN.wUnit(5),
            colors = {
                bg = colors.offBlack,
                activeBg = colors.midGrey,
            },
            label = "MEDIA",
        })

        platformY = SCREEN.hUnit(13)
    end

    -- platform widget
    self.platformGrid = require("gui.platform_grid")(
        self.canvas,
        self.options.platforms,
        { x = SCREEN.wUnit(2.5), y = platformY, w = SCREEN.wUnit(27), h = SCREEN.hUnit(25) },
        {
            font = ASSETS.font.univers.regular(FONTSIZE.s),
            colors = {
                label = colors.offWhite,
                box = colors.offWhite,
                selectedBox = colors.white,
                highlight = colors.activeUI,
            },
        }
    )
    self.platformGridScrollY = 0

    self.inputeventsubscriber:subscribe("input", self.boundEventHandler)
    self.systemeventsubscriber:publish("screen_enter", { screen = "ROMFILTER" })
end

function M:exit()
    self.canvas = nil
    self.inputeventsubscriber:unsubscribe("input", self.boundEventHandler)
    self.systemeventsubscriber:publish("screen_exit", { screen = "ROMFILTER" })

    -- reset selected option
    self.currentOption = "verified"
    self.currentPlatformOption = 1
    if self.prevScreen == "HOME" then
        self.currentOption = "platforms"
    end
    self.mediaSelect = nil
    self.verifiedSelect = nil

    self.platformGridScrollY = 1

    self.shouldRedraw = true
    self.transitionTo = nil
    self.canvas = nil
end

function M:applyFilterChanges()
    for key, value in pairs(self.filterData) do
        self.filterData[key] = self.filterDataTransient[key]
    end
end

function M:update(dt)
    if self.transitionTo then
        return self.transitionTo
    end
    if self.shouldRedraw == false then
        return
    end

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)

    -- background
    love.graphics.setColor({ 0.16, 0.16, 0.16, 0.6 })
    love.graphics.rectangle("fill", 0, 0, SCREEN.w, SCREEN.mainH, 16, 16)

    -- verified
    if self.verifiedSelect then
        self.verifiedSelect:draw(self.currentOption == "verified")
    end
    -- media
    if self.mediaSelect then
        self.mediaSelect:draw(self.currentOption == "media")
    end
    -- platforms
    love.graphics.setCanvas(self.canvas)
    local font = ASSETS.font.univers.bold(FONTSIZE.s)
    love.graphics.setFont(font)
    love.graphics.setColor(colors.offWhite)
    love.graphics.printf(
        "PLATFORMS",
        0,
        self.prevScreen == "ROMS" and SCREEN.hUnit(10) or SCREEN.hUnit(1),
        SCREEN.w,
        "center"
    )

    -- PLATFORM GRID AND SCROLLING AREA GOES HERE
    self.platformGrid:draw(
        self.currentOption == "platforms",
        self.currentPlatformOption,
        self.filterDataTransient.platforms,
        self.platformGridScrollY
    )

    -- end
    love.graphics.setCanvas()
    self.shouldRedraw = false
end

function M:draw(dt)
    love.graphics.setCanvas()
    --previous
    if self.prevCanvas then
        love.graphics.draw(self.prevCanvas, 0, SCREEN.headerH)
    end

    -- modal
    love.graphics.setColor(colors.modalCover)
    love.graphics.rectangle("fill", 0, 0, SCREEN.w, SCREEN.h - SCREEN.footerH)

    --filters
    if self.canvas then
        love.graphics.setColor(colors.white)
        love.graphics.draw(self.canvas, 0, SCREEN.headerH)
    end
end
return M
