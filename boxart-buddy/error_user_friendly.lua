-- CUSTOM USER FACING ERROR HANDLER
local utf8 = require("utf8")

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1 + (layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
    msg = tostring(msg)

    error_printer(msg, 2)

    if not love.window or not love.graphics or not love.event then
        return
    end

    if not love.graphics.isCreated() or not love.window.isOpen() then
        local success, status = pcall(love.window.setMode, 800, 600)
        if not success or not status then
            return
        end
    end

    if LOGGER then
        LOGGER:update()
    end

    -- RESET STATE
    if love.joystick then
        -- Stop all joystick vibrations.
        for i, v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end
    if love.audio then
        love.audio.stop()
    end
    -- END RESET STATE

    love.graphics.reset()
    local font = love.graphics.setNewFont(14)

    love.graphics.setColor(1, 1, 1)

    local trace = debug.traceback()

    love.graphics.origin()

    local sanitizedmsg = {}
    for char in msg:gmatch(utf8.charpattern) do
        table.insert(sanitizedmsg, char)
    end
    sanitizedmsg = table.concat(sanitizedmsg)

    local err = {}

    table.insert(err, "Error\n")
    table.insert(err, sanitizedmsg)

    if #sanitizedmsg ~= #msg then
        table.insert(err, "Invalid UTF-8 string in error message.")
    end

    table.insert(err, "\n")

    for l in trace:gmatch("(.-)\n") do
        if not l:match("boot.lua") then
            l = l:gsub("stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = p:gsub("\t", "")
    p = p:gsub('%[string "(.-)"%]', "%1")

    local function draw()
        if not love.graphics.isActive() then
            return
        end
        local pos = 20
        love.graphics.clear(0, 0, 0)
        love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
        love.graphics.present()
    end

    local fullErrorText = p

    local function getArg(name)
        for _, v in ipairs(arg or {}) do
            local key, value = v:match("^%-%-([^=]+)=(.+)")
            if key == name then
                return value
            end
        end
    end

    local datetime = os.date("%Y%m%d-%H%M%S")
    local projectRoot = getArg("project-root") or "."
    local crashLogSavePath = projectRoot .. "/data/log/crash-" .. datetime .. ".txt"
    local file, err = io.open(crashLogSavePath, "w")
    if file then
        file:write(fullErrorText)
        file:close()
    else
        print("Failed to write crash log: " .. tostring(err))
    end

    p = "FATAL ERROR:"
    p = p .. "\n\n" .. sanitizedmsg
    p = p .. "\n\n\n\n Crash log saved to:\n\n" .. crashLogSavePath
    if love.system then
        p = p .. "\n\n\nPress a,b,x or y to quit"
    end

    return function()
        love.event.pump()

        if love.joystick then
            local joysticks = love.joystick.getJoysticks()
            if #joysticks > 0 then
                local js = joysticks[1]
                if js:isGamepadDown("b") or js:isGamepadDown("a") or js:isGamepadDown("x") or js:isGamepadDown("y") then
                    return 1
                end
            end
        end

        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return 1
            elseif e == "keypressed" then
                return 1
            end
        end

        draw()

        if love.timer then
            love.timer.sleep(0.1)
        end
    end
end
