local colors = require("util.colors")

---@class Footer
local M = class({
    name = "Footer",
})

function M:new(systemeventsubscriber)
    self.systemeventsubscriber = systemeventsubscriber

    if true then
        self.buttonImages = {
            ["confirm"] = ASSETS.image.button.gamepad.small.a,
            ["cancel"] = ASSETS.image.button.gamepad.small.b,
            ["secondary"] = ASSETS.image.button.gamepad.small.x,
            ["tertiary"] = ASSETS.image.button.gamepad.small.y,
            ["l1"] = ASSETS.image.button.gamepad.small.l1,
            ["r1"] = ASSETS.image.button.gamepad.small.r1,
            ["l2"] = ASSETS.image.button.gamepad.small.l2,
            ["r2"] = ASSETS.image.button.gamepad.small.r2,
            ["plus"] = ASSETS.image.button.gamepad.small.plus,
            ["select"] = ASSETS.image.button.gamepad.small.select,
            ["start"] = ASSETS.image.button.gamepad.small.start,
            ["menu"] = ASSETS.image.button.gamepad.small.menu,
            ["up"] = ASSETS.image.button.gamepad.small.dpad_up,
            ["down"] = ASSETS.image.button.gamepad.small.dpad_down,
            ["vertical"] = ASSETS.image.button.gamepad.small.dpad_vertical,
            ["left"] = ASSETS.image.button.gamepad.small.dpad_left,
            ["right"] = ASSETS.image.button.gamepad.small.dpad_right,
            ["horizontal"] = ASSETS.image.button.gamepad.small.dpad_horizontal,
        }
    end

    self.footerCanvas = love.graphics.newCanvas(SCREEN.w, SCREEN.footerH)
    self._lastButtonSignature = nil

    self.buttons = {}
    self.previousButtons = {}

    self.imageMargin = 2
    self.textMarginLeft = 6
    self.marginX = 50
    self.maxGap = 80

    -- track the current screen
    self.currentScreen = nil

    -- bind events
    local romsTableButtons = {
        { images = { "start" }, text = "STATS" },
        { images = { "confirm" }, text = "RESCRAPE" },
        { images = { "secondary" }, text = "OPTIONS" },
        { images = { "tertiary" }, text = "FILTER" },
    }

    self.systemeventsubscriber:subscribe("screen_enter", function(event)
        self.currentScreen = event.screen
        if event.screen == "ROMFILTER" then
            self.buttons = {
                { images = { "secondary" }, text = "TOGGLE ALL PLATFORMS" },
                { images = { "tertiary" }, text = "APPLY & CLOSE" },
            }
        elseif event.screen == "ROMOPTIONS" then
            self.buttons = {
                { images = { "secondary" }, text = "SAVE & CLOSE" },
            }
        elseif event.screen == "ROMSCRAPE" then
            self.buttons = {
                { images = { "vertical" }, text = "SCRAPER" },
                { images = { "horizontal" }, text = "IMAGE" },
                { images = { "cancel" }, text = "CANCEL" },
                { images = { "confirm" }, text = "SELECT & SAVE" },
            }
        elseif event.screen == "ROMS" then
            self.buttons = romsTableButtons
        elseif event.screen == "MIX" then
            self.buttons = {
                { images = { "secondary" }, text = "RANDOM PREVIEW" },
                { images = { "tertiary" }, text = "SAVE", enabled = false },
                { images = { "select" }, text = "DELETE", enabled = false },
                { images = { "start" }, text = "SET", enabled = false },
            }
        elseif event.screen == "PACKAGE" then
            self.buttons = {}
        elseif event.screen == "STAT" then
            self.buttons = {
                { images = { "cancel" }, text = "CLOSE" },
                { images = { "start" }, text = "CLOSE" },
            }
        elseif event.screen == "HOME" then
            self.buttons = {
                { images = { "l1", "plus", "r1" }, text = "QUIT" },
                { images = { "menu" }, text = "CONSOLE" },
                { images = { "start" }, text = "SCAN ROMS" },
                { images = { "tertiary" }, text = "FILTER" },
            }
        elseif event.screen == "DEV" then
            self.buttons = {
                { images = { "confirm" }, text = "SELECT" },
            }
        elseif event.screen == "CONFIG" then
            self.buttons = {
                { images = { "secondary" }, text = "SAVE CONFIG", enabled = false },
                { images = { "tertiary" }, text = "TOGGLE HELP" },
            }
        end
    end)
    -- roms
    self.systemeventsubscriber:subscribe("rom_table_entered", function(event)
        self.buttons = romsTableButtons
    end)
    self.systemeventsubscriber:subscribe("media_table_entered", function(event)
        self.buttons = {
            { images = { "start" }, text = "STATS" },
            { images = { "confirm" }, text = "RESCRAPE" },
            { images = { "secondary" }, text = "PREVIEW" },
            { images = { "cancel" }, text = "DELETE" },
            { images = { "tertiary" }, text = "FILTER" },
        }
    end)
    self.systemeventsubscriber:subscribe("media_preview_entered", function(event)
        self.buttons = {
            { images = { "secondary" }, text = "CLOSE" },
        }
    end)
    self.systemeventsubscriber:subscribe("rom_data_loaded_empty", function(event)
        self.buttons = {}
    end)
    self.systemeventsubscriber:subscribe("rom_data_loaded_no_results", function(event)
        self.buttons = {
            { images = { "tertiary" }, text = "FILTER" },
        }
    end)

    -- config
    self.systemeventsubscriber:subscribe("config_changed", function(event)
        self.buttons = {
            { images = { "secondary" }, text = "SAVE CONFIG", enabled = true },
            { images = { "tertiary" }, text = "TOGGLE HELP" },
        }
    end)
    self.systemeventsubscriber:subscribe("config_saved", function(event)
        self.buttons = {
            { images = { "secondary" }, text = "SAVE CONFIG", enabled = false },
            { images = { "tertiary" }, text = "TOGGLE HELP" },
        }
    end)
    self.systemeventsubscriber:subscribe("config_unchanged", function(event)
        self.buttons = {
            { images = { "secondary" }, text = "SAVE CONFIG", enabled = false },
            { images = { "tertiary" }, text = "TOGGLE HELP" },
        }
    end)

    -- keyboard open
    self.systemeventsubscriber:subscribe("keyboard_opened", function(event)
        self.marginX = 10
        self.textMarginLeft = 3
        self.previousButtons = table.shallow_copy(self.buttons)
        self.buttons = {
            { images = { "start" }, text = "DONE" },
            { images = { "select" }, text = "CANCEL" },
            { images = { "confirm" }, text = "SELECT" },
            { images = { "cancel" }, text = "DEL" },
            { images = { "secondary" }, text = "CAPS" },
            { images = { "l1", "r1" }, text = "CURSOR" },
        }
    end)

    self.systemeventsubscriber:subscribe("keyboard_closed", function(event)
        self.marginX = 50
        self.textMarginLeft = 6
        self.buttons = table.shallow_copy(self.previousButtons)
    end)
    self.systemeventsubscriber:subscribe("numpad_opened", function(event)
        self.marginX = 10
        self.textMarginLeft = 3
        self.previousButtons = table.shallow_copy(self.buttons)
        self.buttons = {
            { images = { "start" }, text = "DONE" },
            { images = { "select" }, text = "CANCEL" },
            { images = { "confirm" }, text = "SELECT" },
            { images = { "cancel" }, text = "DEL" },
            { images = { "l1", "r1" }, text = "CURSOR" },
        }
    end)

    self.systemeventsubscriber:subscribe("numpad_closed", function(event)
        self.marginX = 50
        self.textMarginLeft = 6
        self.buttons = table.shallow_copy(self.previousButtons)
    end)

    -- CANCEL MODAL
    local canCancelWhitelist = { "scrape_roms", "mix", "pack", "scan_roms" }
    self.systemeventsubscriber:subscribe("progress_created", function(e)
        if
            e.tags
            and e.tags.style
            and e.tags.style == "modal"
            and e.key
            and table.contains(canCancelWhitelist, e.key)
        then
            self.previousButtons = table.shallow_copy(self.buttons)
            self.buttons = {
                { images = { "select" }, text = "CANCEL PROCESS" },
            }
        end
    end)
    self.systemeventsubscriber:subscribe("progress_destroyed", function(key)
        if key and table.contains(canCancelWhitelist, key) and self.previousButtons and next(self.previousButtons) then
            self.buttons = table.shallow_copy(self.previousButtons)
            self.previousButtons = {}
        end
    end)

    -- GENERAL BUTTON STATE LISTENER
    self.systemeventsubscriber:subscribe("footer_button_state_change", function(e)
        self:changeButtonState(e.text, e.enabled)
    end)
end

function M:changeButtonState(text, enabled)
    for _, button in ipairs(self.buttons) do
        if button.text == text then
            button.enabled = enabled
        end
    end
end

function M:update()
    local buttonSignature = pretty.string(self.buttons)
    if self._lastButtonSignature == buttonSignature then
        return -- No change, skip redraw
    end

    self._lastButtonSignature = buttonSignature

    love.graphics.setCanvas(self.footerCanvas)
    love.graphics.clear(colors.black)

    local font = ASSETS.font.univers.bold(FONTSIZE.s)
    local imageMargin = self.imageMargin or 2
    local textMarginLeft = self.textMarginLeft or 8
    local marginX = self.marginX or 0
    local totalWidth = self.footerCanvas:getWidth() - (2 * marginX)

    love.graphics.setFont(font)

    -- Step 1: measure button widths
    local buttonWidths = {}
    for i, btn in ipairs(self.buttons) do
        local w = 0
        for _, imgKey in ipairs(btn.images) do
            local img = self.buttonImages[imgKey]
            w = w + img:getWidth()
        end
        w = w + (#btn.images - 1) * imageMargin
        w = w + textMarginLeft
        w = w + font:getWidth(btn.text)
        table.insert(buttonWidths, w)
    end

    -- Step 2: calculate total width and spacing
    local totalButtonsWidth = 0
    for _, w in ipairs(buttonWidths) do
        totalButtonsWidth = totalButtonsWidth + w
    end

    local spaceBetween = 0
    if #buttonWidths > 1 then
        spaceBetween = math.floor((totalWidth - totalButtonsWidth) / (#buttonWidths - 1))
        if spaceBetween > self.maxGap then
            spaceBetween = self.maxGap
        end
    end

    local layoutWidth = totalButtonsWidth + (#buttonWidths - 1) * spaceBetween
    local startX = math.floor((self.footerCanvas:getWidth() - layoutWidth) / 2)
    local x = startX

    for i, btn in ipairs(self.buttons) do
        local w = buttonWidths[i]

        -- calculate x to center vertically (images + text)
        local btnX = x
        local btnY = math.floor((self.footerCanvas:getHeight() - font:getHeight()) / 2)

        -- draw images
        local imgX = btnX
        for j, imgKey in ipairs(btn.images) do
            local img = self.buttonImages[imgKey]
            local y = math.floor((self.footerCanvas:getHeight() - img:getHeight()) / 2)
            local buttonColor
            buttonColor = colors.white
            if btn.enabled == false then
                buttonColor = colors.darken(buttonColor, 0.6)
            end
            buttonColor = love.graphics.setColor(buttonColor)
            love.graphics.draw(img, imgX, y)
            love.graphics.setColor(1, 1, 1, 1)
            imgX = imgX + img:getWidth()
            if j < #btn.images then
                imgX = imgX + imageMargin
            end
        end

        -- draw text
        imgX = imgX + textMarginLeft
        local textColor = colors.white
        if btn.enabled == false then
            textColor = colors.darkGrey
        end
        love.graphics.setColor(textColor)
        love.graphics.setFont(font)
        love.graphics.print(btn.text, imgX, btnY)
        love.graphics.setColor(colors.white)

        x = x + w + spaceBetween
    end

    love.graphics.setCanvas()
end

function M:draw()
    love.graphics.draw(self.footerCanvas, 0, SCREEN.h - SCREEN.footerH)
end

return M
