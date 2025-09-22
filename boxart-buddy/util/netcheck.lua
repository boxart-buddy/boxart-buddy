local M = {}

-- Fast TCP probe; doesn't rely on DNS
function M.tcpProbe(host, port, timeout)
    local ok, socket = pcall(require, "socket")
    if not ok then
        return nil, "luasocket not available"
    end
    local tcp = assert(socket.tcp())
    tcp:settimeout(timeout or 0.5) -- seconds
    local ok2, err = tcp:connect(host or "1.1.1.1", port or 80)
    if ok2 then
        tcp:close()
        return true
    else
        return false, err
    end
end

-- One-call convenience
function M.hasInternet(timeout)
    timeout = timeout or 1
    local ok = M.tcpProbe("1.1.1.1", 80, timeout)
    if ok then
        return true
    end
    -- If that fails, try Google DNS over TCP (also no DNS needed)
    return M.tcpProbe("8.8.8.8", 53, timeout)
end

return M
