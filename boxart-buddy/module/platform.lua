-- utility module for access to platforms data
-- generates and dumps and index for faster keyed lookup to underlying data
local filesystem = require("lib.nativefs")
local platforms = require("resources.platforms")
local path = require("util.path")
local hash = require("util.hash")
local json = require("lib.json")

---@class Platform
local M = class({
    name = "Platform",
})

local function prequire(m)
    local ok, err = pcall(require, m)
    if not ok then
        return nil, err
    end
    return err
end

function M:new(environment, logger)
    self.logger = logger
    self.environment = environment

    local platformsIndexed = prequire("resources.platforms_indexed")

    if platformsIndexed then
        self.platformsIndexed = platformsIndexed
    end
end

function M:getAll()
    return platforms.all
end

---@return boolean
---@param plat string a valid platform key
---@param extension string a file extension (without the dot)
function M:platformUsesExtension(plat, extension)
    local p = self:getPlatformByKey(plat)
    if p.extensions == nil then
        return false
    end
    for i, v in ipairs(p.extensions) do
        if v == extension then
            return true
        end
    end

    return false
end

---@return table A platform entry
---@param key string A valid platform key
function M:getPlatformByKey(key)
    assert(key, "Key passed to getPlatformByKey() cannot be nil")

    -- use platforms_indexed.lua
    if self.platformsIndexed then
        if self.platformsIndexed.byKey[key] == nil then
            error("No platform in INDEX: " .. key)
        end
        return self.platformsIndexed.byKey[key]
    end
    -- fall back to platforms.lua / will never happen while error clause above is there thought
    for i, v in ipairs(platforms.all) do
        if v.key == key then
            return v
        end
    end
    error("No platform" .. key)
end

---@return table A platform entry
---@param key string A valid platform muos key ('muos' in platforms.lua)
function M:getPlatformKeyByMuos(key)
    --- should i strip spaces?
    key = string.lower(key)

    -- use platforms_indexed.lua
    if self.platformsIndexed then
        if self.platformsIndexed.byMuos[key] == nil then
            error("No platform with muos key : " .. key)
        end
        return self.platformsIndexed.byMuos[key].key
    end

    -- fall back to platforms.lua
    for i, v in ipairs(platforms.all) do
        if v.muos == key then
            return v.key
        end
    end
    error("No platform" .. key)
end

-- Used as part of the code to dump indexes to file
---@param value any
---@param indent string?
---@return string
local function serializeValue(value, indent)
    indent = indent or "  "
    local vType = type(value)

    if vType == "string" then
        return string.format("%q", value)
    elseif vType == "number" or vType == "boolean" or vType == "nil" then
        return tostring(value)
    elseif vType == "table" then
        local isArray = (#value > 0)
        local parts = {}

        for k, v in pairs(value) do
            local keyStr
            if isArray then
                keyStr = ""
            elseif type(k) == "string" and k:match("^%a[%w_]*$") then
                keyStr = k .. " = "
            else
                keyStr = "[" .. serializeValue(k) .. "] = "
            end
            table.insert(parts, indent .. "  " .. keyStr .. serializeValue(v, indent .. "  "))
        end

        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
    else
        error("Unsupported type in serialization: " .. vType)
    end
end

--- Used as part of the code to dump indexes to file
---@param platformsList table[]
---@param field string
---@return table<string, table>
local function buildIndexByField(platformsList, field)
    local output = {}
    for _, entry in ipairs(platformsList) do
        local key = entry[field]
        if type(key) == "string" then
            output[string.lower(key)] = entry
        end
    end
    return output
end

--- Writes the combined index module to disk
---@param outputDir string
function M.writeCombinedIndex(outputDir)
    local outputPath = path.join({ outputDir, "platforms_indexed.lua" })
    local byKey = buildIndexByField(platforms.all, "key")
    local byMuos = buildIndexByField(platforms.all, "muos")

    local result = {
        byKey = byKey,
        byMuos = byMuos,
    }

    local content = "-- DO NOT EDIT THIS CODE IT IS GENERATED AUTOMATICALLY\nlocal M = "
        .. serializeValue(result)
        .. "\n\nreturn M\n"
    local success, err = filesystem.write(outputPath, content)
    if not success then
        error("Failed to write index to " .. outputPath .. ": " .. tostring(err))
    end
end

--- For a given rom get the bb platform key derived from rom config, folder config then assigns.json in that order
---@param romRelativePath any
---@return string|nil
function M:getPlatformKeyForRom(romRelativePath)
    local romDirname = path.dirname(romRelativePath)
    local romRelativePathWithoutExtension = path.stem(romRelativePath)

    local coreFolder = self.environment:getPath("coreinfo")

    -- if the rom has a .cfg override
    local romCfgPath = path.join({ coreFolder, romRelativePathWithoutExtension .. ".cfg" })

    -- if the folder has been defined (most likely)
    local romFolderCfgPath = path.join({ coreFolder, romDirname, "core.cfg" })

    return self:_getPlatformKeyByCfg(romCfgPath, 3)
        or self:_getPlatformKeyByCfg(romFolderCfgPath, 2)
        or self:_getFallbackFromAssigns(romRelativePath)
        or nil
end

function M:_getFallbackFromAssigns(romRelativePath)
    -- cache in memory
    if self.fallbackAssigns == nil then
        -- open file / parse json to table / set on module
        local assignsFile = self.environment:getPath("assign")
        local assignsFileContent = filesystem.read(assignsFile)
        if not assignsFileContent then
            error("Can not open assigns.json file")
        end

        local assigns = json.decode(assignsFileContent)
        if not assignsFileContent then
            error("assigns.json file not valid")
        end

        self.fallbackAssigns = assigns
    end
    -- remove spaces to match assign.json key
    local romParentDirs = path.parentNames(romRelativePath)

    local matching = nil
    for _, folder in ipairs(romParentDirs) do
        matching = self.fallbackAssigns[string.lower(folder):gsub("%s+", "")]
        if matching then
            break
        end
    end

    if not matching then
        return nil
    end

    local muosKey = string.lower(path.stem(matching)) -- remove .ini

    local ok, result = pcall(function()
        return self:getPlatformKeyByMuos(muosKey)
    end)

    return ok and result or nil
end

--- Returns the platform key (third line) from a muos core assigning config (.cfg) file, if it exists,
--- mapped to the platform key in BB from its verbose muos name
--- @param absoluteCfgPath string Absolute path to the .cfg file
--- @return string|nil
function M:_getPlatformKeyByCfg(absoluteCfgPath, lineToReadFrom)
    local fileBaseName = path.basename(absoluteCfgPath)

    if not filesystem.getInfo(absoluteCfgPath) then
        return nil
    end

    local cacheKey

    if fileBaseName == "core.cfg" then
        -- this is a folder config so cache it
        self.folderAssigns = self.folderAssigns or {}

        cacheKey = hash.cheapHash(absoluteCfgPath)
        if self.folderAssigns[cacheKey] then
            return self.folderAssigns[cacheKey]
        end
    end

    local lineCount = 0
    for line in filesystem.lines(absoluteCfgPath) do
        lineCount = lineCount + 1
        if lineCount == lineToReadFrom then
            local ok, result = pcall(function()
                return self:getPlatformKeyByMuos(line)
            end)
            local pkey = ok and result or nil
            if pkey and fileBaseName == "core.cfg" then
                self.folderAssigns[cacheKey] = pkey
            end

            ---@diagnostic disable-next-line: return-type-mismatch
            return pkey
        end
    end

    return nil -- fewer than 3 lines
end

return M
