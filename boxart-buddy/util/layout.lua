local M = {}

function M.centreX(width)
    return (SCREEN.w - width) / 2
end

function M.baselineY(baseLine, offsetY)
    offsetY = offsetY or 0
    return function(line)
        return offsetY + ((line - 1) * baseLine)
    end
end

---Get the X value for laying out elements in a column layout
---@param options? table
---@return number
function M.getXForColumnLayout(options)
    options = options or {}

    local elementWidth = options.elementWidth or 0
    local numCols = options.columns or 2
    local colGap = options.gap or SCREEN.wUnit(3)
    local align = options.align or "left"
    local colIndex = options.index or 1
    local totalWidth = options.width or SCREEN.w

    -- Total horizontal gap space
    local totalGap = colGap * (numCols + 1)
    local availableWidth = totalWidth - totalGap
    local columnWidth = availableWidth / numCols

    -- Start of this column (relative to screen)
    local colStartX = colGap + (colIndex - 1) * (columnWidth + colGap)

    if align == "left" then
        return colStartX
    elseif align == "center" then
        return colStartX + (columnWidth - elementWidth) / 2
    elseif align == "right" then
        return colStartX + columnWidth - elementWidth
    else
        error("Invalid alignment: " .. tostring(align))
    end
end

function M:divider(total)
    return function(numerator, denominator)
        assert(type(numerator) == "number", "layout numerator must be a number")
        assert(type(denominator) == "number", "layout denominator must be a number")
        return math.ceil((total / denominator) * numerator)
    end
end

return M
