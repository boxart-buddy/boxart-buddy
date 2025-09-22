---@class MixHandler
local M = class({
    name = "MixHandler",
    implements = { require("worker.handler.abstract") },
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:handle(task)
    task.parameters = task.parameters or {}
    local mixer =
        require("module.mixer")(self.DIC.environment, self.DIC.logger, self.DIC.database, self.DIC.mixStrategyProvider)

    if task.type == "mix" then
        return pcall(function()
            return mixer:mix(task.parameters.romUuid, task.parameters.strategyName, task.parameters.options)
        end)
    end

    if task.type == "mix_preview" then
        return pcall(function()
            return mixer:mixPreview(task.parameters.romUuid, task.parameters.strategyName, task.parameters.options)
        end)
    end
    error("cannot handle unknown task type: " .. task.type)
end

return M
