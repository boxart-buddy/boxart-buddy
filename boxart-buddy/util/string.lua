local M = {}

function M.truncateStringAfterWidth(str, maxWidth, font)
    if font:getWidth(str) <= maxWidth then
        return str
    end

    local ellipsis = "…"
    local ellipsisWidth = font:getWidth(ellipsis)
    local truncated = ""

    for i = 1, #str do
        local sub = str:sub(1, i)
        if font:getWidth(sub) + ellipsisWidth > maxWidth then
            truncated = str:sub(1, i - 1)
            break
        end
    end

    return truncated .. ellipsis
end

function M.uuidToFolder(uuid)
    -- Remove hyphens and extract the first two hex characters
    local hex = uuid:gsub("-", "")
    return hex:sub(1, 2)
end

function M.formatBytes(bytes, decimalPlaces)
    decimalPlaces = decimalPlaces or 1
    local units = { "B", "KB", "MB", "GB" }
    local size = bytes
    local unitIndex = 1

    while size >= 1024 and unitIndex < #units do
        size = size / 1024
        unitIndex = unitIndex + 1
    end

    return string.format("%." .. decimalPlaces .. "f %s", size, units[unitIndex])
end

function M.toSpace(str, ...)
    local chars = { ... }
    if #chars == 0 then
        return str
    end
    for _, ch in ipairs(chars) do
        str = str:gsub(tostring(ch), " ")
    end
    return str
end

function M.capitalCase(str)
    -- Convert first letter of each word to uppercase, rest lowercase
    return (str:gsub("(%S)(%S*)", function(first, rest)
        return first:upper() .. rest:lower()
    end))
end

function M.shellQuote(str)
    return "'" .. tostring(str):gsub("'", "'\\''") .. "'"
end

function M.filenameSafe(str)
    if not str then
        return ""
    end
    -- replace spaces with underscores
    local safe = str:gsub("%s", "_")
    -- replace slashes with underscores
    safe = safe:gsub("[\\/]", "_")
    -- remove characters that are not alphanumeric, dot, dash, underscore
    safe = safe:gsub("[^%w%._-]", "")
    return safe
end

function M.obfuscate(str)
    return string.rep("·", string.len(str))
end

return M
