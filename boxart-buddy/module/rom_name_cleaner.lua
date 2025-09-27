local M = {}

---@class RomNameCleaner
local M = class({
    name = "RomNameCleaner",
})

function M:new() end

---Cleans up a ROM filename for better matching
---@param romname string
---@param mode integer|nil -- 1 = mild, 2 = moderate, 3 = aggressive
---@return string
function M:cleanRomName(romname, mode)
    local clean = romname:lower()
    mode = mode or 1

    if mode >= 2 then
        clean = clean:gsub("%b()", "")
        clean = clean:gsub("%b[]", "")
        clean = clean:gsub("%b{}", "")
        clean = clean:gsub("v%d+%.?%d*", "") -- remove v1, v1.1
        clean = clean:gsub("%f[%a]rev%f[%A]%s*[A-Za-z]$", "") -- remove standalone "rev A", "rev B"
        clean = clean:gsub("[%-_]", " ")
        clean = clean:gsub("%s%s+", " ")
        clean = clean:gsub("^%s*(.-)%s*$", "%1")
        clean = clean:gsub("%s+%.", ".")
    end

    if mode >= 3 then
        local garbage = { "demo", "proto", "sample", "kiosk", "alt", "hack" }
        for _, word in ipairs(garbage) do
            clean = clean:gsub("%f[%a]" .. word .. "%f[%A]", "")
        end
        -- Remove standalone 4-digit years
        clean = clean:gsub("%f[%d]%d%d%d%d%f[%D]", "")
        -- Remove date patterns like yyyy-mm-dd
        clean = clean:gsub("%f[%d]%d%d%d%d%-%d%d%-%d%d%f[%D]", "")
        -- Remove "multi" language indicators
        clean = clean:gsub("[Mm]ulti%d*", "")
        -- Remove short language groupings like (En,Fr)
        clean = clean:gsub("%b()", function(m)
            if m:find(",") and #m < 12 then
                return ""
            else
                return m
            end
        end)
        -- Remove disc/side markers
        clean = clean:gsub("%s*[Dd]isc%s*%d+", "")
        clean = clean:gsub("%s*[Ss]ide%s*[ABab]", "")
        clean = clean:gsub("%s+%.", ".")
    end

    return clean
end

return M
