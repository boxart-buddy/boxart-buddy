---@class PackHandler
local M = class({
    name = "PackHandler",
    implements = { require("worker.handler.abstract") },
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:handle(task)
    task.parameters = task.parameters or {}
    local packer = require("module.packer")(
        self.DIC.environment,
        self.DIC.logger,
        self.DIC.database,
        self.DIC.platform,
        self.DIC.mixStrategyProvider
    )

    if task.type == "packOne" then
        return pcall(function()
            return packer:packOne(task.parameters.romUuid, task.parameters.options)
        end)
    end

    if task.type == "archive" then
        return pcall(function()
            return packer:archiveTempToPackageFolder()
        end)
    end

    error("cannot handle unknown task type: " .. task.type)
end

return M
