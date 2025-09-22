-- Wraps the entire screen, holds 'progress' objects and renders them
-- Registers event subscribers to that update progressRenderer
-- Disable Input And play noises
---@class Screenwrapper
local M = class({
    name = "Screenwrapper",
})

function M:new(environment, systemeventsubscriber, inputeventsubscriber, input, flux, progressRegistry, thread)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.input = input
    self.flux = flux
    self.progressRegistry = progressRegistry
    self.thread = thread
    self.currentlyRunning = nil

    self.progressRenderer = require("module.progress_renderer")(self.flux, self.systemeventsubscriber)
    self.toaster = require("module.toaster")(flux)

    self._boundActionStart = function(action)
        self:actionStart(action)
    end

    self._boundActionComplete = function(action)
        self:actionComplete(action)
    end

    self._boundOrchestrationResultReceived = function(event)
        if event.taskCount == 0 then
            self:actionComplete({ success = true })
        end
    end

    self._boundCreateToast = function(e)
        self.toaster:create(e.message, e.typ or "info")
    end

    self.boundKeyboardValidationFailure = function(e)
        self.toaster:create(e.message, "error")
    end

    self.systemeventsubscriber:subscribe("action_start", self._boundActionStart)
    self.systemeventsubscriber:subscribe("action_complete", self._boundActionComplete)
    self.systemeventsubscriber:subscribe("orchestration_result_received", self._boundOrchestrationResultReceived)
    self.systemeventsubscriber:subscribe("action_complete_async", self._boundActionComplete)
    self.systemeventsubscriber:subscribe("orchestrator_error_received", self._boundActionComplete)
    self.systemeventsubscriber:subscribe("toast_create", self._boundCreateToast)
    self.systemeventsubscriber:subscribe("keyboard_validation_fail", self.boundKeyboardValidationFailure)

    -- sound effects
    self.systemeventsubscriber:subscribe("console_open", function()
        if not self.environment:getConfig("ui_mute_sound") then
            love.audio.play(ASSETS.sound.fx.console_open)
        end
    end)
    self.systemeventsubscriber:subscribe("console_close", function()
        if not self.environment:getConfig("ui_mute_sound") then
            love.audio.play(ASSETS.sound.fx.console_close)
        end
    end)
    self.systemeventsubscriber:subscribe("config_saved", function()
        if not self.environment:getConfig("ui_mute_sound") then
            love.audio.play(ASSETS.sound.fx.info)
        end
    end)
    self.systemeventsubscriber:subscribe("task_error", function()
        if not self.environment:getConfig("ui_mute_sound") then
            love.audio.play(ASSETS.sound.fx.exit_failure)
        end
    end)

    -- input scoping
    local subscreens = { "ROMSCRAPE", "ROMFILTER", "STAT", "ROMOPTIONS" }
    self.systemeventsubscriber:subscribe("screen_enter", function(e)
        if table.contains(subscreens, e.screen) then
            self.input:setScope("subscreen")
        end
    end)
    self.systemeventsubscriber:subscribe("orchestrate_requested", function()
        self.input:setScope("blocking_modal")
    end)
    self.systemeventsubscriber:subscribe("confirm_opened", function()
        self.input:setScope("confirm_modal")
    end)
    self.systemeventsubscriber:subscribe("keyboard_opened", function()
        self.input:setScope("keyboard")
    end)
    self.systemeventsubscriber:subscribe("numpad_opened", function()
        self.input:setScope("numpad")
    end)

    -- revert back to global scope
    self.systemeventsubscriber:subscribe("confirm_closed", function()
        self.input:setScope("global")
    end)
    self.systemeventsubscriber:subscribe("keyboard_closed", function()
        self.input:revertScope()
    end)
    self.systemeventsubscriber:subscribe("numpad_closed", function()
        self.input:revertScope()
    end)
    self.systemeventsubscriber:subscribe("action_complete_async", function()
        self.input:setScope("global")
    end)
    self.systemeventsubscriber:subscribe("screen_exit", function(e)
        if table.contains(subscreens, e.screen) then
            self.input:setScope("global")
        end
    end)

    -- code to allow clearing tasks associated with blocking modal
    self.systemeventsubscriber:subscribe("tasks_dispatched", function(e)
        self.currentlyRunning = e.threadKey
    end)

    local canCancelWhitelist = { "scrape_roms", "mix", "pack", "scan_roms" }
    self.inputeventsubscriber:subscribe("input", function(e)
        if
            e.scope == "blocking_modal"
            and e.type == "select"
            and self.currentlyRunning
            and table.contains(canCancelWhitelist, self.currentlyRunning)
        then
            self.thread:clearChannel(self.currentlyRunning, self.thread.channelType.INPUT)
            self.thread:setThreadPoolTaskCount(self.currentlyRunning, 0)
            self.thread:setThreadPoolStatus(self.currentlyRunning, self.thread.threadStatusValue.COMPLETE)
            self.toaster:create(string.format("Cancelled `%s`", self.currentlyRunning), "error")
            love.audio.play(ASSETS.sound.fx.cancel)
        end
    end)
end

function M:actionStart(action)
    if action.tags.blockinput then
        self.input:block({
            "up",
            "down",
            "left",
            "right",
            "confirm",
            "back",
            "nav_left",
            "nav_right",
            "main_nav_left",
            "main_nav_right",
        })
    end
end
function M:actionComplete(action)
    ---@todo always unblocked even if not previously blocked.
    ---@todo the issue is that the 'complete' event is too far away from the start to send the tags
    ---@todo we _could_ keep an action:tag mapping (or just save every action send here by key
    ---@todo assuming keyed actions always have the same params
    self.input:unblock()
    local silent = false
    if action.tags and action.tags.silent then
        silent = true
    end
    if not self.environment:getConfig("ui_mute_sound") and not silent then
        if action.success then
            love.audio.play(ASSETS.sound.fx.correct)
        else
            love.audio.play(ASSETS.sound.fx.notice)
        end
    end
end

function M:update(dt)
    self.progressRenderer:update(dt)
    self.toaster:update(dt)
end

function M:draw()
    self.progressRenderer:draw()
    self.toaster:draw()
end

return M
