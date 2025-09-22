---@class ImportDatHandler
local M = class({
    name = "ImportDatHandler",
    implements = { require("worker.handler.abstract") },
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:handle(task)
    task.parameters = task.parameters or {}
    local datimporter = require("module.datimporter")(
        self.DIC.systemeventsubscriber,
        self.DIC.database,
        self.DIC.logger,
        self.DIC.environment,
        self.DIC.thread,
        self.DIC.platform
    )

    if task.type == "importOne" then
        return pcall(function()
            datimporter:importOne(task.parameters.platformKey, task.parameters.datFolder, task.parameters.datFilename)
        end)
    end
    error("cannot handle unknown task type: " .. task.type)
end

return M
