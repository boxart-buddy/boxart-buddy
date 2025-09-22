---@class Input
---@field inputCooldown integer
---@field timeSinceLastInput integer
---@field repeatInitialDelay number
---@field repeatInterval number
---@field repeatAccelAfter number
---@field repeatAccelFactor number
local M = class({
    name = "Input",
    defaults = {
        ["inputCooldown"] = 0.2,
        ["timeSinceLastInput"] = 0,
        ["repeatInitialDelay"] = 0.33, -- seconds before first auto-repeat
        ["repeatInterval"] = 0.10, -- seconds between repeats while held
        ["repeatAccelAfter"] = 1.5, -- seconds held before acceleration kicks in (nil to disable)
        ["repeatAccelFactor"] = 0.6, -- multiply interval during acceleration (0.6 = 40% faster)
    },
})

-- Keyboard key -> action mapping (order irrelevant; single press dispatch)
local KEYBOARD_MAPPING = {
    up = "up",
    down = "down",
    left = "left",
    right = "right",
    escape = "quit",
    ["`"] = "toggle_console",
    o = "select",
    p = "start",
    ["return"] = "confirm",
    b = "cancel",
    y = "tertiary",
    x = "secondary",
    ["["] = "main_nav_left",
    ["]"] = "main_nav_right",
    [","] = "nav_left",
    ["."] = "nav_right",
}

-- Simple one-button mapping (indexed like keyboard) + explicit priority order
local GAMEPAD_BUTTON_MAP = {
    dpup = "up",
    dpdown = "down",
    dpleft = "left",
    dpright = "right",
    x = "secondary",
    a = "confirm",
    y = "tertiary",
    b = "cancel",
    leftshoulder = "nav_left",
    rightshoulder = "nav_right",
    guide = "toggle_console",
    back = "select",
    start = "start",
}

-- Axis checks
local GAMEPAD_AXES = {
    { button = "triggerleft", threshold = 0.5, action = "main_nav_left" },
    { button = "triggerright", threshold = 0.5, action = "main_nav_right" },
}

-- Combo checks (all listed must be down)
local GAMEPAD_COMBOS = {
    { buttons = { "leftshoulder", "rightshoulder" }, action = "quit" },
}

-- Which actions should auto-repeat when held
local REPEATABLE_ACTIONS = {
    up = true,
    down = true,
    left = true,
    right = true,
}

-- Repeat behavior:
-- Pressed keys/buttons immediately fire an action and start a hold timer.
-- After an initial delay, actions auto-repeat at regular intervals while held.
-- Releasing the key/button ends the hold and stops repeats.

function M:new(inputeventsubscriber)
    self.inputeventsubscriber = inputeventsubscriber
    self.blocked = {}
    self.currentScope = "global"
    self.previousScope = "global"

    -- Auto-repeat held state: action -> { source=..., next=..., held=true }
    self.held = {}

    if love.joystick == nil and love.keyboard == nil then
        return
    end

    function love.keypressed(key, scancode, isrepeat)
        local action = KEYBOARD_MAPPING[key]
        if action and not self:isBlocked(action) then
            -- immediate fire
            self:publish(action, "keyboard")
            -- start hold for auto-repeat
            if REPEATABLE_ACTIONS[action] then
                self.held[action] = { source = "keyboard", next = self.repeatInitialDelay, held = true, t = 0 }
            end
        end
    end

    function love.keyreleased(key, scancode)
        local action = KEYBOARD_MAPPING[key]
        if action then
            self.held[action] = nil
        end
    end

    local joysticks = love.joystick.getJoysticks()

    if #joysticks > 0 then
        self.joystick = joysticks[1]
    end

    function love.gamepadpressed(joystick, button)
        if not self.joystick or joystick ~= self.joystick then
            return
        end
        local action = GAMEPAD_BUTTON_MAP[button]
        if action and not self:isBlocked(action) then
            -- immediate fire
            self:publish(action, "gamepad")
            self.timeSinceLastInput = 0
            -- start hold for auto-repeat
            if REPEATABLE_ACTIONS[action] then
                self.held[action] = { source = "gamepad", next = self.repeatInitialDelay, held = true, t = 0 }
            end
        end
    end

    function love.gamepadreleased(joystick, button)
        if not self.joystick or joystick ~= self.joystick then
            return
        end
        local action = GAMEPAD_BUTTON_MAP[button]
        if action then
            self.held[action] = nil
        end
    end
end

function M:setScope(scope)
    self.previousScope = self.currentScope
    self.currentScope = scope
end

function M:revertScope()
    self.currentScope = self.previousScope
end

function M:publish(type, source)
    -- legacy, prefer to use general event instead
    -- self.inputeventsubscriber:publish(type)
    self.inputeventsubscriber:publish("input", { type = type, source = source, scope = self.currentScope })
end

function M:block(keys)
    self.blocked = keys
end

function M:unblock(keys)
    if keys == nil then
        self.blocked = {}
        return
    end
end

function M:isBlocked(key)
    for i, v in ipairs(self.blocked) do
        if v == key then
            return true
        end
    end

    return false
end

function M:update(dt)
    if love.joystick == nil and love.keyboard == nil then
        return
    end

    self.timeSinceLastInput = self.timeSinceLastInput + dt

    -- Auto-repeat processing for held actions (keyboard/gamepad buttons)
    for action, h in pairs(self.held) do
        if h.held then
            h.next = h.next - dt
            h.t = (h.t or 0) + dt
            if h.next <= 0 then
                if not self:isBlocked(action) then
                    self:publish(action, h.source)
                    self.timeSinceLastInput = 0
                end
                -- choose interval, possibly accelerated
                local iv = self.repeatInterval
                if self.repeatAccelAfter and h.t >= self.repeatAccelAfter then
                    iv = iv * (self.repeatAccelFactor or 1)
                end
                h.next = iv
            end
        end
    end

    if self.joystick then
        self:handleJoystickInput(dt)
    end
end

function M:handleJoystickInput(dt)
    if self.timeSinceLastInput >= self.inputCooldown then
        local hasInput = false
        local j = self.joystick

        -- 1) combos (highest priority)
        for i = 1, #GAMEPAD_COMBOS do
            local combo = GAMEPAD_COMBOS[i]
            local ok = true
            for _, b in ipairs(combo.buttons) do
                if not j:isGamepadDown(b) then
                    ok = false
                    break
                end
            end
            if ok then
                local act = combo.action
                if not self:isBlocked(act) then
                    self:publish(act, "gamepad")
                    hasInput = true
                end
                break
            end
        end

        -- 2) axes
        if not hasInput then
            for i = 1, #GAMEPAD_AXES do
                local ax = GAMEPAD_AXES[i]
                local thr = ax.threshold or 0.5
                if (j:getGamepadAxis(ax.button) or 0) > thr then
                    if not self:isBlocked(ax.action) then
                        self:publish(ax.action, "gamepad")
                        hasInput = true
                    end
                    break
                end
            end
        end

        if hasInput then
            self.timeSinceLastInput = 0
        end
    end
end

return M
