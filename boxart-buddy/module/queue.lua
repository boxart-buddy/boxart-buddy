---@class Queue
local M = class({
    name = "Queue",
})

function M:new()
    self._items = {}
    self._first = 1
    self._last = 0
    return self
end

-- Add an item to the end of the queue
function M:add(item)
    self._last = self._last + 1
    self._items[self._last] = item
end

-- Remove and return the first item in the queue
function M:get()
    if self._first > self._last then
        return nil -- Queue is empty
    end
    local item = self._items[self._first]
    self._items[self._first] = nil -- Free memory
    self._first = self._first + 1
    return item
end

function M:isEmpty()
    return self._first > self._last
end

function M:peek()
    return self._items[self._first]
end

function M:size()
    return self._last - self._first + 1
end

return M
