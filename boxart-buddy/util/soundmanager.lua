local cargo = require("lib.cargo")
local FX = cargo.init("assets/sound/fx")

local M = {}

-- ["correct"] = "assets/sound/fx/correct.wav",
-- ["error"] = "assets/sound/fx/error.wav",
-- ["exit_failure"] = "assets/sound/fx/exit_failure.wav",
-- ["exit_success"] = "assets/sound/fx/exit_success.wav",
-- ["info"] = "assets/sound/fx/info.wav",
-- ["menu_move"] = "assets/sound/fx/menu_move.wav",
-- ["menu_back"] = "assets/sound/fx/menu_back.wav",
-- ["menu_select"] = "assets/sound/fx/menu_select.wav",
-- ["notice"] = "assets/sound/fx/notice.wav",
-- ["splash"] = "assets/sound/splash/k.mp3",
-- ["start"] = "assets/sound/fx/start.wav",
-- ["console_open"] = "assets/sound/fx/console_open.wav",
-- ["console_close"] = "assets/sound/fx/console_close.wav",

function M.fx(name)
    if love.audio == nil then
        return
    end

    local fx = FX[name]
    if not fx then
        error("unknown sound fx: " .. name)
    end
    love.audio.play(fx)
end

return M
