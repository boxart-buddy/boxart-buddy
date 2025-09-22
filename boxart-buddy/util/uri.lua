local M = {}

---Encodes a string as a URL-safe component
---@param str string
---@return string
function M.urlEncode(str)
    return (str:gsub("([^%w%-_.~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end))
end

---Encodes a table of key/value pairs into a URL query string
---Keys are sorted to ensure the same query string is returned given the same inputs
---@param t table
---@return string
function M.encodeQuery(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys) -- Ensure consistent order

    local q = {}
    for _, k in ipairs(keys) do
        local v = t[k]
        if v ~= nil then
            table.insert(q, M.urlEncode(k) .. "=" .. M.urlEncode(tostring(v)))
        end
    end

    return table.concat(q, "&")
end

function M.removeQueryStringParts(url, options)
    if not url or not options or not options.remove or #options.remove == 0 then
        return url
    end

    local removeSet = {}
    for _, key in ipairs(options.remove) do
        removeSet[key] = true
    end

    local base, query = url:match("^(.-)%?(.*)$")
    if not query then
        return url
    end

    local newQueryParts = {}
    for pair in string.gmatch(query, "([^&]+)") do
        local key, value = pair:match("([^=]+)=?(.*)")
        if key then
            if removeSet[key] then
                table.insert(newQueryParts, key .. "=***")
            else
                table.insert(newQueryParts, key .. "=" .. value)
            end
        end
    end

    return base .. "?" .. table.concat(newQueryParts, "&")
end

return M
