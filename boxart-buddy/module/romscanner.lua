local zip = require("module.zip")()
local ezlib = require("ezlib")
local path = require("util.path")
local filefilter = require("util.filefilter")
local filesystem = require("lib.nativefs")
local discscanner = require("module.discscanner")
local socket = require("socket")

---@class RomScanner
local M = class({
    name = "RomScanner",
})

function M:new(environment, logger, database, platform, thread, systemeventsubscriber)
    self.environment = environment
    self.logger = logger
    self.database = database
    self.platform = platform
    self.thread = thread
    self.systemeventsubscriber = systemeventsubscriber
    self.romRepository = require("repository.rom")(database)

    --self.mode = "skip" -- or overwrite
    self.mode = "overwrite"
end

function M:orchestrate(romRelativePath)
    -- allows one rom to be scanned (mostly for debugging)
    if romRelativePath then
        return {
            tasks = {
                {
                    type = "scanOne",
                    parameters = { romRelativePath = romRelativePath },
                },
            },
        }
    end

    self.romRepository:markAllRomsAsStale()

    self.logger:log(
        "info",
        "romscanner",
        string.format("starting rom scan process at path: %s", self.environment:getPath("roms"))
    )

    -- recursive
    local tasks, secondaryTasks = self:_getRomScanTasksRecursive(self.environment:getPath("roms"), {}, {})
    local combinedTasks = {}

    for _, t in ipairs(tasks) do
        table.insert(combinedTasks, t)
    end

    for _, t in ipairs(secondaryTasks) do
        table.insert(combinedTasks, t)
    end

    return { tasks = combinedTasks, text = "Scanning rom folders" }
end

function M:_getRomScanTasksRecursive(currentPath, tasks, secondaryTasks)
    local items = filesystem.getDirectoryItems(currentPath)

    for _, item in ipairs(items) do
        local innerPath = path.join({ currentPath, item })

        if filesystem.getInfo(innerPath, "directory") and not item:match("^%.") then
            tasks, secondaryTasks = self:_getRomScanTasksRecursive(innerPath, tasks, secondaryTasks)
        else
            local ext = path.extension(innerPath)

            if filefilter:shouldIgnore(path.basename(innerPath)) then
                -- do nothing, skip to next iteration
                -- self.logger:log("warn", "scraper", string.format("skipping file as it's trash `%s`", innerPath))
            else
                local romRelativePath = path.relativePath(innerPath, self.environment:getPath("roms"))
                if romRelativePath ~= "." then
                    -- possible bugs if a symlink?
                    local task = {
                        type = "scanOne",
                        parameters = { romRelativePath = romRelativePath },
                    }

                    if
                        path.extension(romRelativePath) == "m3u"
                        or path.extension(romRelativePath) == "cue"
                        or path.extension(romRelativePath) == "gdi"
                    then
                        table.insert(secondaryTasks, task)
                    else
                        table.insert(tasks, task)
                    end
                end
            end
        end
    end

    return tasks, secondaryTasks
end

function M:_isValidExtension(romRelativePath, plat)
    -- if platform doesn't use this then return early, we don't need to scan it
    local ext = path.extension(romRelativePath)
    ext = ext and string.lower(ext)

    if not self.platform:platformUsesExtension(plat, ext) then
        return false
    end

    return true
end

function M:reScanOne(romUuid)
    if not romUuid then
        error("romUuid is required")
    end
    local folder, filename = self.romRepository:getFolderAndFilenameForRom(romUuid)
    if folder == nil or filename == nil then
        return
    end
    local romRelativePath = path.join({ folder, filename })

    return self:scanOne(romRelativePath)
end

---@param romRelativePath string the rom path relative to the ROMS basepath
function M:scanOne(romRelativePath)
    --socket.sleep(0.5)

    local existingUuid = self.romRepository:romExists(romRelativePath)
    if self.mode == "skip" and existingUuid then
        self.romRepository:setRomAsFresh(existingUuid)
        --self.logger:log("debug", "romscanner", "Skipping as already exists: " .. romRelativePath)

        return
    end
    local romdata = self:getRomData(romRelativePath)
    if not romdata then
        return { status = self.thread.TASK_STATUS.fail }
    end

    self.romRepository:upsertRomToDB(romdata)

    return
end

function M:getRomData(romRelativePath)
    --self.logger:log("debug", "romscanner", "Scanning: " .. romRelativePath)

    local filepath = path.join({ self.environment:getPath("roms"), romRelativePath })
    local info = filesystem.getInfo(filepath)

    if info == nil or info.size == nil then
        self.logger:log("warn", "romscanner", string.format("File Does not exist: %s", filepath))
        return
    end

    local plat = self.platform:getPlatformKeyForRom(romRelativePath)
    if not plat then
        self.logger:log("debug", "romscanner", string.format("Platform not identified: %s", filepath))
        return
    end

    -- need to check extension to see if it's a zip
    local filename = path.basename(romRelativePath)
    local romname = filename
    local crc32
    local size = info.size
    local serial
    local romError = 0

    local crc32MaxSize = self.environment:getConfig("scanner_max_crc32_size") or 8388608

    -- if platform dat explicitly allows 'zip' extension (e.g neogeo) then dont inspect the internals of the zip file
    if filefilter:isZip(path.extension(filepath)) and (not self.platform:platformUsesExtension(plat, "zip")) then
        -- crc32
        local crcData = {}
        local ok, err = pcall(function()
            crcData = zip:crc32(filepath, { single = true, maxSize = crc32MaxSize })
        end)
        if not ok then
            self.logger:log("warn", "romscanner", string.format("CRC32 scan failed for %s: %s", filepath, err))
            romError = 1
        end
        filename = path.basename(romRelativePath)
        romname = crcData.filename or filename
        crc32 = crcData.crc32
        size = crcData.size or size
        if not crcData.size then
            self.logger:log("warn", "romscanner", "size missing from zip module crc32 call")
        end
    elseif -- cue/m3u/bin (these are the 'secondaryTasks' so should be processed last)
        path.extension(filepath) == "m3u"
        or path.extension(filepath) == "gdi"
        or path.extension(filepath) == "cue"
    then
        local fileList = {}
        if path.extension(filepath) == "m3u" then
            fileList = self:parseM3uFile(filepath)
        elseif path.extension(filepath) == "gdi" then
            fileList = self:parseGdiFile(filepath)
        elseif path.extension(filepath) == "cue" then
            fileList = self:parseCueFile(filepath)
        end

        local firstRomPath = nil
        -- make all referenced files 'hidden'
        for i, relPath in ipairs(fileList) do
            local cDir = path.dirname(filepath)
            local absPath = path.join({ cDir, relPath })
            local romRelPath = path.relativePath(absPath, self.environment:getPath("roms"))
            if i == 1 then
                firstRomPath = romRelPath
            end
            local romUuid = self.romRepository:romExists(romRelPath)
            if romUuid then
                self.romRepository:setRomHidden(romUuid)
            end
        end

        -- extract info from the the first rom
        if firstRomPath then
            local firstRomData = self:getRomData(firstRomPath)
            if firstRomData then
                size = firstRomData.size
                serial = firstRomData.serial
                crc32 = firstRomData.crc32
            else
                romError = 1
            end
        end
        -- scan the 'first' entry and use _that_ information for this 'rom'
    elseif filefilter:isDisc(path.extension(filepath)) then -- do disc stuff
        serial, error = discscanner.scan(filepath, plat)
    else -- non zips / zips that are too big
        -- spot check size. If larger than configured limit then don't attempt to get crc32
        if size < crc32MaxSize then
            local fh = filesystem.newFile(filepath)
            local ok, err = fh:open("r")
            if not ok then
                error(string.format("Could not open file: %s (%s)", filepath, err))
            end

            local crc = 0
            local chunkSize = 64 * 1024
            while true do
                local chunk = fh:read(chunkSize)
                if not chunk or #chunk == 0 then
                    break
                end
                crc = ezlib.crc32(chunk, crc)
            end
            fh:close()

            crc32 = string.format("%08x", crc)
        end
    end

    if not self:_isValidExtension(romname, plat) then
        self.logger:log(
            "warn",
            "romscanner",
            string.format("Invalid extension for (%s): %s. Romname: %s", plat, filepath, romname)
        )
        return nil
    end

    local uuid = identifier.uuid4()
    if uuid == nil then
        error("UUID IS NIL - WHY?!")
    end

    -- size
    local romdata = {}
    romdata.uuid = uuid
    romdata.filename = filename
    romdata.romname = romname
    romdata.folder = path.dirname(romRelativePath)
    romdata.platform = plat
    romdata.size = size
    romdata.serial = serial
    romdata.error = romError
    romdata.crc32 = crc32 and string.upper(crc32) or nil -- could be nil!
    return romdata
end

function M:parseCueFile(path)
    local files = {}
    for line in filesystem.lines(path) do
        local fname = line:match('^FILE%s+"([^"]+)"')
        if fname then
            table.insert(files, fname)
        end
    end
    return files
end

function M:parseGdiFile(path)
    local files = {}
    for line in filesystem.lines(path) do
        local parts = {}
        for token in line:gmatch("%S+") do
            table.insert(parts, token)
        end
        if tonumber(parts[3]) == 4 and parts[5] then
            table.insert(files, parts[5])
        end
    end
    return files
end

function M:parseM3uFile(path)
    local files = {}
    for line in filesystem.lines(path) do
        local ref = line:match("^%s*(.-)%s*$")
        if ref ~= "" and not ref:match("^#") then -- ignore empty lines and comments
            table.insert(files, ref)
        end
    end
    return files
end

return M
