-- fontscale.lua (or inline this in your startup)
local BASE = { xs = 12, s = 14, m = 16, l = 18, xl = 20, xxl = 24 }
local BASE_W, BASE_H, BASE_IN = 640, 480, 3.5
local BASE_PPI = (math.sqrt(BASE_W * BASE_W + BASE_H * BASE_H)) / BASE_IN -- ~228.57

local function roundStep(x)
    -- Snap small text to 1px steps, larger to 2px (crisper)
    local step = (x < 18) and 1 or 2
    return math.max(8, step * math.floor(x / step + 0.5))
end

-- Given screen w,h, and physical diagonal in inches:
local function buildFontMatrix(w, h, inches)
    -- PPI
    local diag_px = math.sqrt(w * w + h * h)
    local ppi = diag_px / inches

    -- Scale components
    local height_scale = h / BASE_H -- keeps perceived size stable
    local ppi_scale = (ppi / BASE_PPI) ^ 0.4 -- gentle DPI response

    -- Combined scale with guardrails
    local s = math.max(0.8, math.min(1.35, height_scale * ppi_scale))

    -- Produce matrix
    local M = {}
    for k, base_px in pairs(BASE) do
        M[k] = roundStep(base_px * s)
    end

    return M, ppi, s
end

local M = {}
function M.getFontSizes(w, h, s)
    local matrix, ppi, scale = buildFontMatrix(w, h, s)
    return matrix
end

return M
