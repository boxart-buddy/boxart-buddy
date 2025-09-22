---@class ScanRomsHandler
local M = class({
    name = "ScanRomsHandler",
    implements = { require("worker.handler.abstract") },
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:handle(task)
    task.parameters = task.parameters or {}

    local romScanner = require("module.romscanner")(
        self.DIC.environment,
        self.DIC.logger,
        self.DIC.database,
        self.DIC.platform,
        self.DIC.thread,
        self.DIC.systemeventsubscriber
    )

    if task.type == "scanOne" then
        return pcall(function()
            return romScanner:scanOne(task.parameters.romRelativePath)
        end)
    end

    if task.type == "reScanOne" then
        return pcall(function()
            return romScanner:reScanOne(task.parameters.romUuid)
        end)
    end

    error("cannot handle unknown task type: " .. task.type)
end

return M
