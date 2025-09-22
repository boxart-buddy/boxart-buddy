---@class PrintLogHandler
local M = class({
    name = "PrintLogHandler",
})

function M:new() end

function M:name()
    return "print"
end

function M:handle(log)
    local formatted = string.format("[%s] %s: %s", log.channel, string.upper(log.level), log.msg)
    print(formatted)
end

return M
