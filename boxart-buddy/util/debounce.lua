-- util/debounce.lua

---Create a debounced function wrapper.
---@param fn function   The function to debounce
---@param delay number  Seconds to wait after the last call
---@return function     Debounced function (callable)
---@return function     Update function (must be called each frame with dt)
return function(fn, delay)
    local cooldown = 0
    local queued = false

    -- Call this in your input/event handler
    local function call()
        queued = true
        cooldown = delay
    end

    -- Call this in your update(dt) loop
    local function update(dt)
        if queued then
            cooldown = cooldown - dt
            if cooldown <= 0 then
                queued = false
                fn()
            end
        end
    end

    return call, update
end
