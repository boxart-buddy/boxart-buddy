local filesystem = require("lib.nativefs")
local path = require("util.path")

---@class FileLogHandler
local M = class({
    name = "FileLogHandler",
})

function M:new(environment, thread)
    self.environment = environment
    self.thread = thread
end

function M:name()
    return "file"
end

function M:handle(log)
    self:_deferLogToFile(log)
end

function M:_deferLogToFile(log)
    self.thread:push("file_logger", { type = "logToFile", parameters = { log = log } })
end

function M:logToFile(log)
    local logdir = self.environment:getPath("log")
    local timestamp = log.timestamp
    if timestamp == nil then
        timestamp = os.date("%Y-%m-%d %H:%M:%S")
    end
    local formatted = string.format("[%s] [%s] %s: %s\n", timestamp, log.channel, string.upper(log.level), log.msg)

    -- Rotate log daily
    local dateSuffix = os.date("%Y-%m-%d")
    local logFilename = string.format("log-%s.txt", dateSuffix)
    local logpath = path.join({ logdir, logFilename })

    -- Ensure log directory exists
    if not filesystem.getInfo(logdir) then
        filesystem.createDirectory(logdir)
    end

    -- Write using nativefs.writeFile
    local ok, err = filesystem.append(logpath, formatted)

    if not ok then
        print("Failed to write to log file:", tostring(err))
    end
end

function M:cleanupOldLogs(maxAgeDays)
    maxAgeDays = maxAgeDays or 7
    local logdir = self.environment:getPath("log")
    local files = filesystem.getDirectoryItems(logdir)
    local currentTime = os.time()

    for _, filename in ipairs(files) do
        local year, month, day = filename:match("^log%-(%d%d%d%d)%-(%d%d)%-(%d%d)%.txt$")

        local y = tonumber(year)
        local m = tonumber(month)
        local d = tonumber(day)

        if y and m and d then
            local fileDate = os.time({
                year = y,
                month = m,
                day = d,
                hour = 0,
            })

            local age = os.difftime(currentTime, fileDate) / (60 * 60 * 24)
            if age > maxAgeDays then
                local fullpath = path.join({ logdir, filename })
                local ok, err = filesystem.remove(fullpath)
            end
        end
    end
end

return M
