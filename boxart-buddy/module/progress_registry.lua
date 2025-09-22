---@class ProgressRegistry
local M = class({
    name = "ProgressRegistry",
})

function M:new(systemeventsubscriber, logger)
    self.systemeventsubscriber = systemeventsubscriber
    self.logger = logger

    self.progressMap = {}

    self.systemeventsubscriber:subscribe("tasks_dispatched", function(event)
        if self.progressMap[event.threadKey] then
            self.progressMap[event.threadKey]:addSteps(event.steps)
        else
            self:createProgress(event.threadKey, event.steps, event.tags, event.text)
        end
    end)

    self.systemeventsubscriber:subscribe("orchestration_result_received", function(e)
        self:destroyProgress("orchestrator")
    end)

    self.systemeventsubscriber:subscribe("orchestrate_requested", function(e)
        local text = e.text or "standby"
        self:createProgress("orchestrator", 1, { style = "modal" }, text)
    end)

    self.systemeventsubscriber:subscribe("action_progress", function(e)
        self:advanceProgress(e)
    end)

    self.systemeventsubscriber:subscribe("action_complete_async", function(e)
        self:destroyProgress(e.key)
    end)

    return self
end

function M:createProgress(key, steps, tags, text)
    if self.progressMap[key] ~= nil then
        error(string.format("progress with key `%s` already exists", key))
    end

    self.progressMap[key] = require("module.progress")(key, steps, tags, text)

    self.systemeventsubscriber:publish("progress_created", self.progressMap[key])
end

function M:destroyProgress(key)
    local p = self.progressMap[key]
    if not p then
        self.logger:log("warn", "progress", "cannot destroy unregistered progress")
    end

    self.progressMap[key] = nil
    self.systemeventsubscriber:publish("progress_destroyed", key)
end

function M:advanceProgress(action)
    local p = self.progressMap[action.key]
    if not p then
        return
    end
    p:progress()
end

function M:getProgressByTag(tag)
    for key, prog in pairs(self.progressMap) do
        if prog.tags ~= nil then
            for i2, t in ipairs(prog.tags) do
                if t == tag then
                    return prog
                end
            end
        end
    end

    return nil
end

return M
