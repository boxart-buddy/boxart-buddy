-- a logger that can store log messages and then uses configured channels to handle them
local path = require("util.path")

---@class Logger
---@field levels table
---@field logLevel table
local M = class({
    name = "Logger",
    defaults = {
        ["levels"] = {
            ["debug"] = 1,
            ["info"] = 2,
            ["warn"] = 3,
            ["error"] = 4,
            ["fatal"] = 5,
        },
    },
})

function M:new(environment)
    self.logLevel = {}
    self.environment = environment
    self.messages = require("module.queue")()
    self.handlers = {}
    self.muteChannels = environment:getConfig("log_mute_channels") or {}
end

function M:registerHandler(name, level, handler)
    self.handlers[name] = handler
    self.logLevel[name] = level
end

function M:log(level, channel, msg, timestamp, handler)
    if self.levels[level] == nil then
        error("Cannot log at unknown level " .. level)
    end

    if table.contains(self.muteChannels, channel) then
        return
    end

    self.messages:add({
        level = level,
        channel = channel,
        msg = msg,
        handler = handler,
        timestamp = timestamp or os.date("%Y-%m-%d %H:%M:%S"),
    })
end

function M:logToHandler(level, channel, msg, handler)
    self:log(level, channel, msg, nil, handler)
end

function M:update()
    self:_handleMessages()
end

function M:_handleMessages()
    local log = self["messages"]:get()
    while log do
        for name, handler in pairs(self.handlers) do
            -- allow logs to specify a handler (e.g target log message to console only)
            if log.handler == nil or log.handler == handler:name() then
                if self.levels[log.level] >= self.levels[self.logLevel[name]] then
                    handler:handle(log)
                end
            end
        end
        log = self["messages"]:get()
    end
end

return M
