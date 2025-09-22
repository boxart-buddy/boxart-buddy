---@class DatImporter
local M = class({
    name = "DatImporter",
})

local path = require("util.path")
local filesystem = require("lib.nativefs")

function M:new(systemeventsubscriber, database, logger, environment, thread, platform)
    self.systemeventsubscriber = systemeventsubscriber
    self.database = database
    self.logger = logger
    self.environment = environment
    self.thread = thread
    self.platform = platform
end

function M:orchestrate()
    self:_deleteAll()

    self.logger:log("info", "datimporter", "starting DAT import process")

    local stepText = {}
    local tasks = {}

    for i1, p in ipairs(self.platform:getAll()) do
        if p.dat == nil then
            -- continue
        elseif type(p.dat) == "table" then
            for i2, dn in ipairs(p.dat) do
                table.insert(tasks, {
                    type = "importOne",
                    parameters = {
                        platformKey = p.key,
                        datFolder = dn[1],
                        datFilename = dn[2],
                    },
                })

                table.insert(stepText, string.format("%s [%s/%s]", string.upper(p.key), i2, #p.dat))
            end
        end
    end
    return { tasks = tasks, steps = stepText, text = "Importing DAT Files" }
end

function M:_deleteAll()
    self.logger:log("debug", "datimporter", "Deleting existing dat entries from database")
    self.database:blockingExec("DELETE FROM dat")
end

function M:_getFilesRecursive(basePath)
    local result = {}

    --- Internal recursive function
    --- @param currentPath string
    --- @param relativePath string
    local function scan(currentPath, relativePath)
        local items = filesystem.getDirectoryItems(currentPath)

        for _, item in ipairs(items) do
            local fullPath = path.join({ currentPath, item })
            local relPath = relativePath ~= "" and (path.join({ relativePath, item })) or item

            if filesystem.getInfo(fullPath, "directory") then
                scan(fullPath, relPath)
            else
                -- Extract just the filename from relPath
                local filename = relPath:match("^.+/(.+)$") or relPath

                -- only read .dat files
                if path.extension(filename) == "dat" then
                    table.insert(result, {
                        path = fullPath,
                        name = filename,
                    })
                end
            end
        end
    end

    table.sort(result, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    scan(basePath, "")
    return result
end

function M:importOne(platformKey, folder, searchFilename)
    -- load datfile paths into memory if missing
    local datfiles = self:_getFilesRecursive(self.environment:getPath("dat_root"))
    if datfiles == nil then
        error("no datfiles to import")
    end

    -- gets the first part of the dat
    local datType = folder:match("([^/]+)")

    -- get prefers to set priority when inserting
    local prefer = self.platform:getPlatformByKey(platformKey).prefer

    for i, datfile in ipairs(datfiles) do
        local containingFolder = path.join({ self.environment:getPath("dat_root"), folder })

        if
            (datfile.path:sub(1, #containingFolder) == containingFolder)
            and (string.find(datfile.name, searchFilename, 1, true))
        then
            local games
            local filecontents = filesystem.read(datfile.path)

            self.logger:log(
                "debug",
                "datimporter",
                string.format("parsing %s file: %s", datType, path.join({ folder, datfile.name }))
            )

            if datType == "libretro" then
                local datparser = require("module.datparser")(self.logger)
                games = datparser:parse(filecontents)
            else -- PC XML Format
                local handler = require("lib.xml2lua.xmlhandler.tree"):new()
                local parser = require("lib.xml2lua.xml2lua").parser(handler)

                parser:parse(filecontents)

                games = handler.root.datafile.game
            end

            -- get dat key and lookup prefers

            local statement =
                "INSERT or IGNORE INTO dat (id, platform, source, sourcekey, name, romname, size, crc32, md5, sha1, serial, priority) VALUES (:id, :platform, :source, :sourcekey, :name, :romname, :size, :crc32, :md5, :sha1, :serial, :priority)"

            for i2, game in ipairs(games) do
                if game.rom and datType == "libretro" then -- libretro dat format
                    local entry = {}
                    entry.id = identifier.uuid4()
                    entry.platform = platformKey
                    entry.source = path.relativePath(datfile.path, self.environment:getPath("dat_root"))
                    entry.sourcekey = self:sourceKey(entry.source)
                    entry.name = game.name
                    -- game.category
                    -- game.description

                    entry.romname = game.rom.name or game.name
                    entry.size = tonumber(game.rom.size)
                    entry.crc32 = game.rom.crc
                    entry.md5 = game.rom.md5
                    entry.sha1 = game.rom.sha1
                    entry.serial = game.rom.serial or entry.serial
                    entry.priority = self:getPriorityByPrefer(entry.sourcekey, prefer)

                    self.database:blockingExec(statement, entry)
                elseif game.rom and game.rom._attr and game.rom._attr.crc then -- single rom xml fomat
                    local entry = {}
                    entry.id = identifier.uuid4()
                    entry.platform = platformKey
                    entry.source = path.relativePath(datfile.path, self.environment:getPath("dat_root"))
                    entry.sourcekey = self:sourceKey(entry.source)
                    entry.name = game._attr.name
                    -- game.category
                    -- game.description

                    entry.romname = game.rom._attr.name
                    entry.size = tonumber(game.rom._attr.size)
                    entry.crc32 = game.rom._attr.crc
                    entry.md5 = game.rom._attr.md5
                    entry.sha1 = game.rom._attr.sha1
                    entry.priority = self:getPriorityByPrefer(entry.sourcekey, prefer)

                    self.database:blockingExec(statement, entry)
                elseif game.rom then -- multiple roms in xml node
                    for i3, innerRom in ipairs(game.rom) do
                        local entry = {}
                        entry.id = identifier.uuid4()
                        entry.platform = platformKey
                        entry.source = path.relativePath(datfile.path, self.environment:getPath("dat_root"))
                        entry.sourcekey = self:sourceKey(entry.source)
                        entry.name = game._attr.name
                        entry.romname = innerRom._attr.name
                        entry.size = tonumber(innerRom._attr.size)
                        entry.crc32 = innerRom._attr.crc
                        entry.md5 = innerRom._attr.md5
                        entry.sha1 = innerRom._attr.sha1
                        entry.priority = self:getPriorityByPrefer(entry.sourcekey, prefer)

                        self.database:blockingExec(statement, entry)
                    end
                end
            end
            self.database:close()

            self.logger:log("debug", "datimporter", string.format("datfile `%s` imported", datfile.name))
        end
    end
end

function M:getPriorityByPrefer(sourceKey, prefer)
    if prefer == nil then
        return 10
    end -- the lowest preference
    for i, k in ipairs(prefer) do
        if k == sourceKey then
            return i
        end
    end

    return 10
end

function M:sourceKey(source)
    local keyMap = {
        ["libretro/dat"] = "libretro-dats",
        ["libretro/metadat/libretro-dats"] = "libretro-dats",
        ["libretro/metadat/no-intro"] = "no-intro",
        ["libretro/metadat/tosec"] = "tosec",
        ["libretro/metadat/redump"] = "redump",
        ["libretro/metadat/fbneo-split"] = "fbneo-split",
        ["libretro/metadat/mame"] = "mame",
        ["libretro/metadat/hacks"] = "hacks",
        ["libretro/metadat/homebrew"] = "homebrew",
        ["libretro/metadat/headered"] = "headered",
        ["no-intro/"] = "no-intro",
        ["redump/"] = "redump",
    }

    for prefix, value in pairs(keyMap) do
        if source:sub(1, #prefix) == prefix then
            return value
        end
    end

    return "unknown"
end

return M
