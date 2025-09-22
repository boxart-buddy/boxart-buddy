local Thread = require("module.thread")

---@class HttpsHandler
local M = class({
    name = "HttpsHandler",
    implements = { require("worker.handler.abstract") },
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:handle(task)
    task.parameters = task.parameters or {}
    local https = require("https")

    if task.type == "request" then
        return pcall(function()
            local code, body, headers = https:request(task.parameters.url, task.parameters.requestOptions)
            return {
                status = (code == 200) and Thread.TASK_STATUS.ok or Thread.TASK_STATUS.fail,
                data = { code = code, body = body, headers = headers },
            }
        end)
    end

    error("cannot handle unknown task type: " .. task.type)
end

return M
