---@class ConsoleLogHandler
local M = class({
    name = "ConsoleLogHandler",
})

function M:new(console)
    self.console = console
end

function M:name()
    return "console"
end

function M:handle(log)
    local formatted = string.format("[%s] %s: %s", log.channel, string.upper(log.level), log.msg)
    self.console:add(formatted)
end

return M
