local toml = require("lib.toml")
local filesystem = require("lib.nativefs")
local path = require("util.path")
local definitions = require("dat.config_data_definition")
local socket = require("socket")

---@class Config
local M = class({
    name = "Config",
})

function M:new(configPath)
    self.configPath = configPath
    self.config = nil
end

---load config file from disk, nil if file empty or not present
function M:load()
    local fileInfo = filesystem.getInfo(self.configPath)

    -- Retry logic: recheck up to 10 times with 100ms sleep between
    local retries = 0
    while not fileInfo and retries < 10 do
        socket.sleep(0.1)
        retries = retries + 1
        fileInfo = filesystem.getInfo(self.configPath)
    end

    -- create file if it doesn't exist
    if fileInfo == nil then
        error("Config file is missing from disk")
    end

    local tomlString = filesystem.read(self.configPath)
    local config = toml.parse(tomlString, { strict = false })
    if not next(config) then
        return nil
    end

    return config
end

function M:createFreshFromDefaults()
    self.config = self:getDefaults()
    self:save()
end

---@return table
function M:getDefaults()
    local defaults = {}
    for _, def in ipairs(definitions) do
        defaults[def.key] = def.default
    end
    return defaults
end

---returns a table of definitions grouped by their "group" key
---@return table
function M:getDefinitionsByGroup(excludeHidden)
    excludeHidden = excludeHidden or true
    local grouped = {}

    for _, def in ipairs(definitions) do
        if excludeHidden == false or not def.hidden then
            local groupName = def.group or "extra"
            grouped[groupName] = grouped[groupName] or {}
            table.insert(grouped[groupName], def)
        end
    end

    return grouped
end

--- for use on config management screen
---@param groupName string
---@return table
function M:getOrderedDefinitionGroup(groupName)
    local groups = self:getDefinitionsByGroup(true)
    if not groups[groupName] then
        error("cannot get unknown group: " .. groupName)
    end
    return groups[groupName]
end

---Get the keys of groups in a predictable order
---@return table
function M:getGroups()
    local groups = self:getDefinitionsByGroup()
    local keys = table.keys(groups)
    local priority = { scraper = 1, log = 2, env = 3, media = 4, mix = 5, ui = 6, pack = 7 }

    table.sort(keys, function(a, b)
        local pa, pb = priority[a], priority[b]
        if pa and pb then
            return pa < pb
        end
        if pa then
            return true
        end
        if pb then
            return false
        end
        return a < b
    end)
    return keys
end

function M:save()
    if not filesystem.getInfo(path.dirname(self.configPath)) then
        filesystem.createDirectory(path.dirname(self.configPath))
    end
    filesystem.write(self.configPath, toml.encode(self.config))
end

---Get the whole config or a single key
---@param key string
---@return table
function M:get(key)
    if self.config == nil then
        self.config = self:load()
    end
    if key == nil then
        return self.config
    end
    return self.config[key]
end

return M
