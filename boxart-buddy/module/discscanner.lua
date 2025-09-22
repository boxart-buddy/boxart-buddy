local discscanner = require("discscanner")

local M = {}

function M.scan(absolutePath, plat)
    local serial = discscanner.scan_serial(absolutePath, plat)
    return serial
end

return M
