--- Simple progress indicators that can be rendered statically. No Animation, for contexts where no 'progress' class is attached
local M = {}

-- Draws a donut-style progress indicator
-- x, y = center position
-- radius = outer radius of the donut
-- thickness = ring thickness
-- progress = value between 0 and 1 (e.g., 0.75 for 75%)
function M.donut(x, y, radius, thickness, progress)
    love.graphics.push("all") -- save everything
    -- Clamp progress between 0 and 1
    progress = math.max(0, math.min(1, progress / 100))

    local segments = 100
    local angleStart = -math.pi / 2
    local angleEnd = angleStart + (2 * math.pi * progress)

    -- Background ring
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.setLineWidth(thickness)
    love.graphics.arc("line", "open", x, y, radius, 0, 2 * math.pi, segments)

    -- Progress color: red to green
    local r = 1 - progress
    local g = progress
    love.graphics.setColor(r, g, 0, 1)

    -- Foreground arc (progress)
    love.graphics.arc("line", "open", x, y, radius, angleStart, angleEnd, segments)
    love.graphics.pop() -- restore everything
end

-- Draws a horizontal linear progress bar
-- x, y = top-left corner
-- width, height = size of the bar
-- progress = value between 0 and 100
function M.linear(x, y, width, height, progress)
    love.graphics.push("all")
    -- Clamp progress between 0 and 1
    progress = math.max(0, math.min(1, progress / 100))

    -- Draw background bar
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", x, y, width, height)

    -- Progress color: red to green
    local r = 1 - progress
    local g = progress
    love.graphics.setColor(r, g, 0, 1)

    -- Draw filled progress portion
    love.graphics.rectangle("fill", x, y, width * progress, height)
    love.graphics.pop()
end

return M
