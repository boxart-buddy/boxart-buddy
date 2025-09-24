---@class InitDbHandler
local M = class({
    name = "InitDbHandler",
    implements = { require("worker.handler.abstract") },
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:handle(task)
    task.parameters = task.parameters or {}

    if task.type == "initialize" then
        return pcall(function()
            return self.DIC.database:initialize()
        end)
    end

    if task.type == "replace" then
        return pcall(function()
            self.DIC.database:replaceDBFromFixture()
            -- replace preset mix values
            local mixRepository = require("repository.mix")(self.DIC.database)
            mixRepository:importPresets()
        end)
    end

    error("cannot handle unknown task type: " .. task.type)
end

return M
