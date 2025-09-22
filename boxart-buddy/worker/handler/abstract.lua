---@class AbstractHandler
local M = class({
    name = "AbstractHandler",
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:postKill() end

function M:handle(task) end

return M
