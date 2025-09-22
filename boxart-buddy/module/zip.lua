local archive = require("archive")
local ezlib = require("ezlib")
local filesystem = require("lib.nativefs")
local path = require("util.path")

---@class Zip
---@field zipExtensions table
local M = class({
    name = "Zip",
    defaults = {
        zipExtensions = {
            "zip",
            "7z",
            "7zip",
            "z",
            "gz",
        },
    },
})

function M:new() end

function M:writeFolderToArchive(inpath, outpath, deleteSource)
    -- Create a ZIP archive at `outpath` and stream all contents of `inpath` into it.
    -- If `deleteSource` is true, files are deleted after being added; empty
    -- directories are removed after processing.

    assert(type(inpath) == "string" and #inpath > 0, "inpath must be a path string")
    assert(type(outpath) == "string" and #outpath > 0, "outpath must be a path string")

    local info = filesystem.getInfo(inpath)
    if not info or info.type ~= "directory" then
        error("writeFolderToArchive: inpath must be a directory: " .. tostring(inpath))
    end

    -- Open output file via nativefs and stream libarchive chunks to it
    local out = assert(filesystem.newFile(outpath))
    -- ensure output dir
    if not filesystem.getInfo(path.dirname(outpath)) then
        filesystem.createDirectory(path.dirname(outpath))
    end
    local ok, err = out:open("w")
    if not ok then
        error("Failed to open output file for writing: " .. tostring(err))
    end

    local ar = archive.write({
        format = "zip",
        -- Force Zip64 for very large archives; libarchive may auto-enable but we
        -- make it explicit to be safe with thousands of files / >4GB archives.
        options = "zip:zip64",
        writer = function(_, chunk)
            -- libarchive may call the writer with nil to signal flush/end; guard against that
            if chunk == nil then
                return 0
            end
            out:write(chunk)
            return #chunk
        end,
    })

    -- Helper: normalise to forward slashes for ZIP entries
    local function zip_path(rel)
        return (rel:gsub("\\", "/"))
    end

    -- Recursively walk `dir`, adding entries to the archive. `base` is the
    -- relative path inside the ZIP (no leading slash).
    local function walk(dir, base)
        -- Ensure we emit a directory entry so empty folders are preserved
        if base ~= "" then
            local dirEntry = archive.entry({
                pathname = zip_path(base .. "/"),
                mode = tonumber("040755", 8),
                size = 0,
            })
            ar:header(dirEntry)
        end

        local names = filesystem.getDirectoryItems(dir)
        table.sort(names) -- deterministic ordering
        for _, name in ipairs(names) do
            local abs = path.join(dir, name)
            local rel = base ~= "" and (base .. "/" .. name) or name
            local nfo = filesystem.getInfo(abs)
            if nfo and nfo.type == "directory" then
                walk(abs, rel)
                if deleteSource then
                    -- Attempt to remove the now-empty directory
                    pcall(function()
                        filesystem.remove(abs)
                    end)
                end
            elseif nfo and nfo.type == "file" then
                local e = archive.entry({
                    pathname = zip_path(rel),
                    mode = tonumber("100644", 8),
                    size = nfo.size or 0,
                    mtime = { nfo.modtime, 0 },
                })
                ar:header(e)

                local fh = assert(filesystem.newFile(abs))
                local okRead, errRead = fh:open("r")
                if not okRead then
                    fh:close()
                    error("Failed to open file for reading: " .. tostring(abs) .. ": " .. tostring(errRead))
                end
                local CHUNK = 64 * 1024
                while true do
                    local chunk = fh:read(CHUNK)
                    -- nativefs may return an empty string "" at EOF; treat that as EOF too
                    if not chunk or #chunk == 0 then
                        break
                    end
                    ar:data(chunk)
                end
                fh:close()

                if deleteSource then
                    pcall(function()
                        filesystem.remove(abs)
                    end)
                end
            end
        end
    end

    local okWalk, walkErr = pcall(function()
        walk(inpath, "")
    end)

    -- Always close archive and file handles
    local closeErr
    pcall(function()
        ar:close()
    end)
    local okClose
    okClose, closeErr = pcall(function()
        out:close()
    end)

    if not okWalk then
        error(walkErr)
    end
    if not okClose then
        error(closeErr)
    end

    return true
end

function M:crc32(filepath, options)
    options = options or {}

    local extension = path.extension(filepath)

    if extension == "zip" then
        return self:_minizCrc32(filepath, options)
    else
        if extension ~= "7zip" and extension ~= "7z" then
            options.stream = true
        end

        -- could set format and compression for further perf gain (maybe)
        return self:_archiveCrc32(filepath, options)
    end
end

function M:_minizCrc32(filepath, options)
    if path.extension(filepath) ~= "zip" then
        error("Can only use miniz crc32 extraction with zip files")
    end

    local crc32Ints = archive.miniz():crc32(filepath)

    if crc32Ints == nil then
        error("crc32 reading failed using miniz")
    end

    local result = {}

    for i, v in ipairs(crc32Ints) do
        local single = {
            filename = v.filename,
            size = v.size,
            crc32 = string.format("%08x", v.crc32), -- int to hex
        }
        if options and type(options) == "table" and options.single then
            return single
        end
        table.insert(result, single)
    end

    return result
end

function M:_archiveCrc32(filepath, options)
    if options and type(options) == "table" and options.maxSize then
        local info = filesystem.getInfo(filepath)

        -- zip is too big to read into memory and get crc32 for
        if info.size > options.maxSize then
            return {
                filename = path.basename(filepath),
                crc32 = nil,
                size = info.size,
            }
        end
    end
    local fh, err = filesystem.newFile(filepath)
    local ok, errOpen = fh:open("r")

    if not ok then
        error("Failed to open file with nativefs: " .. tostring(err))
    end

    local readOptions = {}
    local extension = path.extension(filepath)
    if options and type(options) == "table" and options.stream and extension ~= "7zip" and extension ~= "7z" then
        readOptions.reader = function(archive_read)
            local chunk = fh:read(10000)
            -- nativefs may return an empty string "" at EOF; return nil to signal end of stream
            if not chunk or #chunk == 0 then
                return nil
            end
            return chunk, #chunk
        end
    else
        readOptions.filepath = filepath
    end

    if options and type(options) == "table" and options.format then
        readOptions.format = options.format
    else
        readOptions.format = "all"
    end

    local read = archive.read(readOptions)

    local header = read:next_header()

    if not header then
        error("Empty archive or corrupt header, could not read")
    end

    local result = {}

    while header do
        local crc = 0

        while true do
            local chunk = read:data()
            if not chunk or #chunk == 0 then
                break
            end
            crc = ezlib.crc32(chunk, crc)
        end

        local single = {
            filename = header:pathname(),
            crc32 = string.format("%08x", crc),
            size = header:size(),
        }

        if options and type(options) == "table" and options.single then
            result = single
            break
        end

        table.insert(result, single)
    end
    fh:close()
    read:close()
    read = nil
    header = nil

    return result
end

return M
