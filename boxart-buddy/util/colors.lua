-- https://rgbcolorpicker.com/0-1

local M = {
    -- named colors
    ["red"] = { 0.921, 0.101, 0.113, 1 },
    ["green"] = { 0, 0.552, 0.270, 1 },
    ["blue"] = { 0.027, 0.286, 0.705, 1 },
    ["lightBlue"] = { 0.337, 0.412, 1, 1 },
    ["yellow"] = { 0.996, 0.807, 0.082, 1 },
    ["pink"] = { 0.804, 0.078, 0.831, 1 },

    --greyscale
    ["white"] = { 1, 1, 1, 1 },
    ["offWhite"] = { 0.8, 0.8, 0.8, 1 },
    ["lightGrey"] = { 0.65, 0.65, 0.65, 1 },
    ["grey"] = { 0.5, 0.5, 0.5, 1 },
    ["midGrey"] = { 0.35, 0.35, 0.35, 1 },
    ["darkGrey"] = { 0.2, 0.2, 0.2, 1 },
    ["veryDarkGrey"] = { 0.16, 0.16, 0.16, 1 },
    ["offBlack"] = { 0.09, 0.09, 0.09, 1 },
    ["black"] = { 0, 0, 0, 1 },

    -- colors for stuff
    ["consoleBg"] = { 0.851, 0.196, 0.196, 0.7 },
    ["consoleBgAlt"] = { 0.271, 0.255, 0.859, 0.7 },
    ["consoleStroke"] = { 0.851, 0.196, 0.196, 1 },
    ["consoleText"] = { 1, 0.882, 0.882, 1 },
    ["progressBarOuter"] = { 0.027, 0.067, 0.137, 1 },
    ["progressBarInnerStart"] = { 0.957, 0.961, 0.016, 1 }, -- starts color yellow
    ["progressBarInnerEnd"] = { 0.863, 0.027, 0.153, 1 }, -- end color red
    ["progressBarStroke"] = { 0.950, 0.950, 0.950, 1 },
    ["activeUI"] = { 0.043, 0.183, 0.471, 1 },
    ["activeSecondaryUI"] = { 0.016, 0.071, 0.180, 1 },
    ["helpBg"] = { 0.086, 0.118, 0.561, 0.7 },
    ["helpStroke"] = { 0.086, 0.118, 0.561, 1 },

    --toasts
    ["toastErrorBg"] = { 0.851, 0.196, 0.196, 1 },
    ["toastErrorBorder"] = { 0.569, 0.035, 0.145, 1 },
    ["toastSuccessBg"] = { 0.4, 0.639, 0.2, 1 },
    ["toastSuccessBorder"] = { 0.086, 0.38, 0.024, 1 },
    ["toastInfoBg"] = { 0.055, 0.647, 1, 1 },
    ["toastInfoBorder"] = { 0, 0.4, 0.639 },

    ["modalCover"] = { 0, 0, 0, 0.7 },
}

-- midpoint between two colors by scale
function M.midpoint(start, target, scale)
    local r = (start[1] - target[1]) * scale
    local g = (start[2] - target[2]) * scale
    local b = (start[3] - target[3]) * scale
    local a = (start[4] - target[4]) * scale

    return {
        start[1] - r,
        start[2] - g,
        start[3] - b,
        start[4] - a,
    }
end

---@param input table color table
---@param scale number 0-1
---@return table
function M.darken(input, scale)
    return {
        input[1] * (1 - scale),
        input[2] * (1 - scale),
        input[3] * (1 - scale),
        input[4],
    }
end

---@param hex string 6-character hex color (optionally with leading '#')
---@return table rgb color table with values in [0,1]
function M.hexToRGB(hex)
    -- validate input type
    if type(hex) ~= "string" then
        return { 0, 0, 0 }
    end

    -- allow optional leading '#'
    if hex:sub(1, 1) == "#" then
        hex = hex:sub(2)
    end

    -- must be exactly 6 hex digits
    if #hex ~= 6 or not hex:match("^[%da-fA-F]+$") then
        return { 0, 0, 0 }
    end

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    if not (r and g and b) then
        return { 0, 0, 0 }
    end

    return { r / 255, g / 255, b / 255 }
end

return M
