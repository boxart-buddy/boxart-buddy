local screen = require("util.screen")

function love.conf(t)
    t.version = "11.5"
    t.window.title = "boxart-buddy"
    t.identity = "boxart-buddy"
    t.console = false

    local screenW, screenH = screen.getResolution()

    t.window.width = screenW
    t.window.height = screenH
    t.window.borderless = false
    -- modules
    t.modules.physics = false
    t.modules.mouse = false
    t.modules.touch = false
    t.modules.video = false
    t.window.msaa = 4
end
