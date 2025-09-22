local socket = require("socket")
local https = require("https")

---@class RateLimitedHttps
local M = class({
    name = "RateLimitedHttps",
})

function M:new(logger)
    self.logger = logger

    self.lastRequestTime = socket.gettime() * 1000
    self.delay = 0
end

function M:setDelay(ms)
    self.delay = ms
end

function M:request(...)
    local now = socket.gettime() * 1000
    local elapsed = now - self.lastRequestTime
    if elapsed < self.delay then
        socket.sleep((self.delay - elapsed) / 1000)
    end
    self.lastRequestTime = socket.gettime() * 1000
    return https.request(...)
end

return M
