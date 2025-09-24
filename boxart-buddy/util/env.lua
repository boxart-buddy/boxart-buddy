local M = {}

function M:getArg(name)
    for _, v in ipairs(arg or {}) do
        local key, value = v:match("^%-%-([^=]+)=(.+)")
        if key == name then
            return value
        end
    end
end

function M:demandArg(name)
    local v = M:getArg(name)
    if not v then
        error(name .. " is a required argument")
    end

    return v
end

return M
