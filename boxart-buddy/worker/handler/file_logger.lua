---@class FileLoggerHandler
local M = class({
    name = "FileLoggerHandler",
    implements = { require("worker.handler.abstract") },
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:handle(task)
    task.parameters = task.parameters or {}
    local fileHandler = self.DIC.logger.handlers.file

    if task.type == "logToFile" then
        return pcall(function()
            return fileHandler:logToFile(task.parameters.log)
        end)
    end
    error("cannot handle unknown task type: " .. task.type)
end

return M
