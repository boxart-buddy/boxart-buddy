local M = {}

--- Cheap non-cryptographic string hash
-- @param str string
-- @return integer hash
function M.cheapHash(input)
    if type(input) == "table" then
        return M.cheapHash(pretty.string(input, { indent = false }))
    end
    local hash = 0
    for i = 1, #input do
        hash = (hash * 31 + input:byte(i)) % 2 ^ 32
    end
    return hash
end

return M
