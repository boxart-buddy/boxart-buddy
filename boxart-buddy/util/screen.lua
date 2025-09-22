local filesystem = require("lib.nativefs")

local M = {}

local deviceNamePath = "/opt/muos/device/config/board/name"

local deviceScreenSize = {
    ["gcs-h36s"] = { s = 3.5, w = 640, h = 480 }, -- 640x480
    ["mgx-zero28"] = { s = 2.8, w = 640, h = 480 }, -- 640x480
    ["rg28xx-h"] = { s = 2.8, w = 640, h = 480 }, -- 640x480
    ["rg34xx-h"] = { s = 3.4, w = 720, h = 480 }, -- 720x480
    ["rg34xx-sp"] = { s = 3.4, w = 720, h = 480 }, -- 720x480
    ["rg35xx-2024"] = { s = 3.5, w = 640, h = 480 }, -- 640x480
    ["rg35xx-h"] = { s = 3.5, w = 640, h = 480 }, -- 640x480
    ["rg35xx-plus"] = { s = 3.5, w = 640, h = 480 }, -- 640x480
    ["rg35xx-pro"] = { s = 3.5, w = 640, h = 480 }, -- 640x480
    ["rg35xx-sp"] = { s = 3.5, w = 640, h = 480 }, -- 640x480
    ["rg40xx-h"] = { s = 4, w = 640, h = 480 }, -- 640x480
    ["rg40xx-v"] = { s = 4, w = 640, h = 480 }, -- 640x480
    ["rgcubexx-h"] = { s = 3.95, w = 720, h = 720 }, -- 720x720
    ["tui-brick"] = { s = 3.2, w = 1024, h = 768 }, -- 1024x768
    ["tui-spoon"] = { s = 4.96, w = 1280, h = 720 }, -- 1280x720
}

function M.getDeviceInfo()
    local data = filesystem.read(deviceNamePath)
    if not data then
        return nil
    end
    local name = data:match("^%s*(.-)%s*$") -- trim whitespace/newlines
    if not name or name == "" then
        return nil
    end
    local info = deviceScreenSize[name]
    if info then
        return info.w, info.h, info.s, name
    end
    return nil
end

function M.getResolution()
    -- fallback values
    local width, height, siz = 640, 480, 3.5 -- (3.5-inch and 4 inch)
    --local width, height, siz = 1024, 768, 3.2 -- TrimUi Brick (3.2 inch)
    --local width, height, siz = 1280, 720, 4.96 -- TrimUi Smart Pro (4.96 inch)
    --local width, height, siz = 720, 720, 3.95 -- Cube (3.95 inch)
    --local width, height, siz = 720, 480, 3.4 -- GBA (3.4 inch)
    if not jit.os == "Linux" then
        return width, height, siz
    end

    -- first try device info file
    local w, h, d = M:getDeviceInfo()
    if w and h and d then
        return w, h, s
    end

    -- fallback
    return width, height, siz
end

return M
