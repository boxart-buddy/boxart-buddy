local colors = require("util.colors")
local stringUtil = require("util.string")
local hash = require("util.hash")
local media = require("util.media")
local debounce = require("util.debounce")
local Menu = require("gui.widget.group.menu")
local TinySelect = require("gui.widget.tiny_select")
local Keyboard = require("gui.widget.keyboard")
local Loading = require("gui.loading")

---@class MixScreen
local M = class({
    name = "MixScreen",
})

function M:new(
    environment,
    systemeventsubscriber,
    inputeventsubscriber,
    thread,
    database,
    orchestrator,
    mixStrategyProvider
)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.romRepository = require("repository.rom")(database)
    self.mixRepository = require("repository.mix")(database)
    self.thread = thread
    self.orchestrator = orchestrator
    self.mixStrategyProvider = mixStrategyProvider
    self.canvas = nil
    self.shouldRedraw = true
    self.menu = nil
    self.strategySelect = nil
    self.previewImage = nil
    self.previewRomUuid = nil

    self.strategyNames = {}
    self.currentStrategy = nil

    self.currentPreset = nil
    self.lastUsedPreset = {}
    self.customPresetName = "My Preset"

    self.mixStrategyOptionValues = {}
    self.customValues = {}

    self.loading = nil
    self.savingPreset = false
    self.hasRoms = false

    self.presets = {}
    self.selectedPreset = nil

    self.boundInputHandler = function(e)
        self:handleInput(e)
    end

    -- preview generation is debounced
    self.debouncePreview, self.updatePreviewDebounce = debounce(function()
        self:generatePreview()
    end, 0.25)
    self.boundConfigChangeHandler = function()
        self:debouncePreview()
    end

    self.boundRefreshPreviewHandler = function(e)
        if e.threadKey == "mix" then
            self:refreshPreview(e)
        end
    end

    self.boundKeyboardCloseHandler = function(e)
        -- dont save when keyboard is dismissed via cancel
        if e.type == "confirm" then
            self:savePreset()
        end
    end

    -- romUuid defaults to last viewed rom on rom screen
    self.systemeventsubscriber:subscribe("rom_media_loaded", function(e)
        self.previewRomUuid = e.romUuid
    end)
end

function M:setMenu()
    -- reset values
    self.menu = Menu(
        self.canvas,
        self.systemeventsubscriber,
        self.mixStrategyProvider:getOptions(self.currentStrategy), --definitions
        self.mixStrategyOptionValues, --values
        {
            x = (SCREEN.w / 2) + SCREEN.wUnit(2),
            y = SCREEN.hUnit(3.5),
            font = ASSETS.font.inter.medium(FONTSIZE.s),
            labelWidth = SCREEN.wUnit(6),
            spacingY = SCREEN.hUnit(3.4),
            inputPaddingLeft = 0,
            height = SCREEN.mainH - SCREEN.wUnit(2),
            width = SCREEN.w - ((SCREEN.w / 2) + SCREEN.wUnit(2)),
            widgetHeight = SCREEN.hUnit(2.6),
        }
    )
    self.previousMixStrategyOptionValues = table.deep_copy(self.menu.values)
end

function M:setPresetSelect()
    self.presets = self.mixStrategyProvider:getPresets(self.currentStrategy)
    self.selectedPreset = self.mixStrategyProvider:getSelectedPreset()

    local presetNames = table.map(table.deep_copy(self.presets), function(p)
        return p.name
    end)
    table.insert(presetNames, 1, "custom")

    -- don't clobber last used selection
    if self.lastUsedPreset[self.currentStrategy] then
        self.currentPreset = self.lastUsedPreset[self.currentStrategy]
    else
        for _, pre in ipairs(self.presets) do
            if pre.selected then
                self.currentPreset = pre.name
            end
        end
        if self.currentPreset == nil then
            self.currentPreset = presetNames[2] -- 'custom' is first
        end
    end

    -- if previously used custom values then use them again
    if self.currentPreset ~= "custom" then
        self.mixStrategyOptionValues =
            table.deep_copy(self.mixStrategyProvider:getPresetByName(self.currentStrategy, self.currentPreset).values)
        self.customValues = table.deep_copy(self.mixStrategyOptionValues)
    else
        self.mixStrategyOptionValues = self.customValues
    end

    -- reset values
    self.presetSelect = TinySelect(self.canvas, presetNames, self.currentPreset, {
        x = SCREEN.wUnit(1),
        y = SCREEN.hUnit(3),
        width = (SCREEN.w / 2),
        height = SCREEN.hUnit(3),
        font = ASSETS.font.inter.bold(FONTSIZE.m),
        -- labelWidth = 0,
        -- inputPaddingLeft = 0,
        textWidth = (SCREEN.w / 2) - SCREEN.wUnit(3),
        arrowLeft = ASSETS.image.button.gamepad.small.l1,
        arrowRight = ASSETS.image.button.gamepad.small.r1,
        -- keyTransformer = function(v)
        --     return stringUtil.capitalCase(stringUtil.toSpace(v, "_", "-"))
        -- end,
        colors = {
            arrow = colors.midGrey,
        },
    })

    self:mixPresetChanged(self.currentPreset)
end

function M:setStrategySelect()
    if #self.strategyNames == 1 then
        self:setPresetSelect()
        return
    end
    -- reset values
    self.strategySelect = TinySelect(self.canvas, self.strategyNames, self.currentStrategy, {
        x = 40,
        y = (SCREEN.h / 2) + 75,
        width = (SCREEN.w / 2),
        height = 30,
        font = ASSETS.font.inter.bold(FONTSIZE.m),
        labelWidth = 0,
        textWidth = (SCREEN.w / 2) - 110,
        arrowLeft = ASSETS.image.button.gamepad.small.start,
        arrowRight = ASSETS.image.button.gamepad.small.select,
        keyTransformer = function(v)
            return stringUtil.capitalCase(stringUtil.toSpace(v, "_", "-"))
        end,
        colors = {
            arrow = colors.midGrey,
        },
    })

    self:setPresetSelect()
end

function M:mixPresetChanged(name)
    local pre = self.mixStrategyProvider:getPresetByName(self.currentStrategy, name)
    local isSoft = false
    local isSelected = false

    if pre then
        isSoft = not pre.hard
        isSelected = pre.selected
    end

    if name == "custom" then
        self.systemeventsubscriber:publish("footer_button_state_change", { text = "SAVE", enabled = true })
    else
        self.systemeventsubscriber:publish("footer_button_state_change", { text = "SAVE", enabled = false })
    end

    if isSoft then
        self.systemeventsubscriber:publish("footer_button_state_change", { text = "DELETE", enabled = true })
    else
        self.systemeventsubscriber:publish("footer_button_state_change", { text = "DELETE", enabled = false })
    end

    if not isSelected and name ~= "custom" then
        self.systemeventsubscriber:publish("footer_button_state_change", { text = "SET", enabled = true })
    else
        self.systemeventsubscriber:publish("footer_button_state_change", { text = "SET", enabled = false })
    end
end

function M:generatePreview()
    if self.previewImage then
        self.previewImage:release()
        self.previewImage = nil
    end

    self.loading = Loading(
        self.canvas,
        ASSETS.image.loading.sprite_32,
        { x = SCREEN.wDiv(1, 4) + SCREEN.wUnit(1), y = SCREEN.hDiv(4, 10), frameWidth = 32, frameHeight = 32, fps = 32 }
    )

    self.thread:dispatchTasks("mix", {
        {
            type = "mix_preview",
            parameters = {
                strategyName = self.currentStrategy,
                romUuid = self.previewRomUuid,
                options = {
                    mixOptions = self.mixStrategyOptionValues,
                },
            },
        },
    }, { progressStyle = "hidden", progressText = "Generating Preview", silentThread = true })
end

function M:refreshPreview(e)
    if self.previewImage then
        self.previewImage:release()
    end

    local previewPath = e.result.data.previewPath
    self.previewImage = media.loadImage(previewPath)
    self.loading = nil
    self.shouldRedraw = true
end

function M:savePreset()
    self.savingPreset = false
    self.mixRepository:savePreset(self.currentStrategy, self.customPresetName, self.mixStrategyOptionValues)
    self.lastUsedPreset[self.currentStrategy] = self.customPresetName
    self:setPresetSelect()
    -- auto set newly saved preset as selected
    self:selectCurrentPreset()
end

function M:selectCurrentPreset()
    local pre = self.mixStrategyProvider:getPresetByName(self.currentStrategy, self.currentPreset)
    if self.currentPreset ~= "custom" and pre and pre.selected == false then
        self.mixRepository:selectPreset(self.currentStrategy, self.currentPreset)
        self:setPresetSelect()
    end
end

function M:setHasRoms()
    if self.romRepository:hasRoms() then
        self.hasRoms = true
    else
        self.hasRoms = false
    end
end

function M:enter()
    self.inputeventsubscriber:subscribe("input", self.boundInputHandler)
    self.systemeventsubscriber:subscribe("task_result", self.boundRefreshPreviewHandler)
    self.systemeventsubscriber:subscribe("strategy_options_changed", self.boundConfigChangeHandler)
    self.systemeventsubscriber:subscribe("keyboard_closed", self.boundKeyboardCloseHandler)

    self.canvas = love.graphics.newCanvas(SCREEN.w, SCREEN.mainH, { msaa = 8 })

    -- init strategy names only on enter
    if not next(self.strategyNames) then
        self.strategyNames = self.mixStrategyProvider:getStrategyNames()
        self.currentStrategy = table.next_element(self.strategyNames)
    end

    self.systemeventsubscriber:publish("screen_enter", { screen = "MIX" })
    self:setStrategySelect()
    self:setMenu()
    self:setHasRoms()
    if self.hasRoms then
        self:generatePreview()
    end

    -- keyboard for saving custom presets
    self.keyboard = Keyboard(self.systemeventsubscriber, self.canvas, self.customPresetName, {
        allowEmpty = false,
        validate = function(v)
            local blacklist = { "custom" }
            for _, preset in ipairs(self.presets) do
                if preset.hard then
                    table.insert(blacklist, string.lower(preset.name))
                end
            end
            if table.contains(blacklist, string.lower(v)) then
                return false, string.format("`%s` is a reserved name, chose a different name", v)
            end
            return true
        end,
    })
end

function M:exit()
    self.inputeventsubscriber:unsubscribe("input", self.boundInputHandler)
    self.systemeventsubscriber:unsubscribe("task_result", self.boundRefreshPreviewHandler)
    self.systemeventsubscriber:unsubscribe("strategy_options_changed", self.boundConfigChangeHandler)
    self.systemeventsubscriber:unsubscribe("keyboard_closed", self.boundKeyboardCloseHandler)

    self.systemeventsubscriber:publish("screen_exit", { screen = "MIX" })

    if self.previewImage then
        self.previewImage:release()
    end
    self.previewImage = nil
    self.canvas = nil
    self.shouldRedraw = true
end

function M:handleInput(event)
    if
        event.type == "main_nav_left"
        or event.type == "main_nav_right"
        or event.type == "toggle_console"
        or event.type == "quit"
    then
        return
    end
    if self.keyboard.open then
        self.customPresetName = self.keyboard:handleInput(event.type)
        return
    end
    -- currently only the advanced strategy remains
    if (event.type == "l3" or event.type == "r3") and self.strategySelect then
        self.currentStrategy = self.strategySelect:handleInput(event.type == "l3" and "left" or "right")
        self.mixStrategyOptionValues = {}
        self:setPresetSelect()
        self:setMenu()
        self:generatePreview()
    elseif (event.type == "nav_left" or event.type == "nav_right") and self.presetSelect then
        self.currentPreset = self.presetSelect:handleInput(event.type == "nav_left" and "left" or "right")
        if self.currentPreset ~= "custom" then
            self.mixStrategyOptionValues = nil
            self.mixStrategyOptionValues = table.deep_copy(
                self.mixStrategyProvider:getPresetByName(self.currentStrategy, self.currentPreset).values
            )
            self.customValues = table.deep_copy(self.mixStrategyOptionValues)
        else
            self.mixStrategyOptionValues = table.deep_copy(self.customValues)
        end
        self:mixPresetChanged(self.currentPreset)
        self:setMenu()
        self:generatePreview()
    elseif event.type == "secondary" then
        if self.hasRoms then
            self.previewRomUuid = self.romRepository:getRandomRomUuid()
            self:generatePreview()
        end
    elseif event.type == "tertiary" then -- save
        if self.currentPreset == "custom" then
            self.keyboard:doOpen()
            self.savingPreset = true
        end
    elseif event.type == "start" then -- set
        self:selectCurrentPreset()
    elseif event.type == "select" then --delete
        if self.mixStrategyProvider:getPresetByName(self.currentStrategy, self.currentPreset).hard == false then
            self.mixRepository:deletePreset(self.currentStrategy, self.currentPreset)
            -- switch over to custom after deleting
            self.presetSelect:setCurrentIndexByValue("custom")
            self.currentPreset = "custom"
            self.lastUsedPreset[self.currentStrategy] = self.currentPreset
            self:setPresetSelect()
        end
    else
        -- manually navigate the preset selector over to 'custom' before editing
        self.presetSelect:setCurrentIndexByValue("custom")
        self.currentPreset = "custom"
        local newValues = self.menu:handleInput(event)
        if hash.cheapHash(self.mixStrategyOptionValues) ~= hash.cheapHash(self.previousMixStrategyOptionValues) then
            self.systemeventsubscriber:publish("strategy_options_changed", { values = newValues })
            self.previousMixStrategyOptionValues = table.deep_copy(newValues)
        end
        self:mixPresetChanged(self.currentPreset)
    end

    if self.currentPreset == "custom" then
        self.systemeventsubscriber:publish("footer_button_state_change", { text = "SAVE PRESET", enabled = true })
    else
        self.systemeventsubscriber:publish("footer_button_state_change", { text = "SAVE PRESET", enabled = false })
    end

    -- backup the last used preset in case of revisiting
    self.lastUsedPreset[self.currentStrategy] = self.currentPreset

    self.mixStrategyProvider.currentStrategy = self.currentStrategy
    self.mixStrategyProvider.mixStrategyOptionValues = self.mixStrategyOptionValues
    self.shouldRedraw = true
end

function M:update(dt)
    self.updatePreviewDebounce(dt)

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(colors.black)

    -- if no roms then print warning
    if not self.hasRoms then
        love.graphics.setColor(colors.white)
        love.graphics.setFont(ASSETS.font.inter.bold(FONTSIZE.xl))
        love.graphics.printf("NO ROMS FOUND\nHAVE YOU SCANNED ROMS YET?", 0, 100, SCREEN.w, "center")
        love.graphics.setCanvas()
        self.shouldRedraw = false
        return
    end

    -- preview
    if self.strategySelect then
        self.strategySelect:draw(false)
    end
    if self.presetSelect then
        self.presetSelect:draw(false)
    end
    if
        self.selectedPreset
        and (self.currentPreset == self.selectedPreset.name)
        and (self.currentStrategy == self.selectedPreset.strategy)
    then
        -- render star
        local star = ASSETS.image.star
        love.graphics.draw(
            star,
            (SCREEN.wDiv(1, 4) + SCREEN.wUnit(1)) - (star:getWidth() / 2) + 10,
            SCREEN.hUnit(1.5),
            0,
            0.5,
            0.5
        )
    end

    -- end preview

    media.scaleMedia(
        ASSETS.image.mixbg,
        self.canvas,
        { x = SCREEN.wUnit(1), y = SCREEN.hUnit(7), width = SCREEN.wDiv(1, 2), height = SCREEN.hDiv(1, 2) }
    )
    if self.loading then
        self.loading:update(dt)
        self.loading:draw()
    end
    if self.previewImage then
        media.scaleMedia(
            self.previewImage,
            self.canvas,
            { x = SCREEN.wUnit(1), y = SCREEN.hUnit(7), width = SCREEN.wDiv(1, 2), height = SCREEN.hDiv(1, 2) }
        )
    end

    --endpreview

    --options
    love.graphics.setCanvas(self.canvas)
    if self.menu then
        self.menu:draw()
    end
    --endoptions

    if self.keyboard.open then
        self.keyboard:update(dt)
        self.keyboard:draw()
    end

    --end
    love.graphics.setCanvas()

    if not self.keyboard.open then
        self.shouldRedraw = false
    end
end

function M:draw(dt)
    love.graphics.setCanvas()
    love.graphics.draw(self.canvas, 0, SCREEN.footerH)
end
return M
