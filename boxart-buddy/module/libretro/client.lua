local path = require("util.path")
local url = require("lib.url")

---@class LibretroClient
local M = class({
    name = "LibretroClient",
})

function M:new(environment, logger, platform)
    self.logger = logger
    self.environment = environment
    self.platform = platform
    self.platformOptions = {
        amiga = { prefix_fallback = true },
        arduboy = { prefix_fallback = true },
        c64 = { prefix_fallback = true, strip_leading_index = true },
        md = { normalize_rev = true },
    }
    self.warnIssued = {}
    self.baseUri = "https://thumbnails.libretro.com"
end

---@return table,string? Table of matches, keyed by box/screen/wheel etc
function M:getMatchesByPlatformAndRomname(plat, romname)
    local thumbDicts = self:_getThumbDictionariesForPlatform(plat)
    if not next(thumbDicts) then
        -- only warns once on missing dictionaries
        if not self.warnIssued[plat] then
            self.logger:log("warn", "libretro", "Cannot load thumb dictionary for platform: " .. plat)
            self.warnIssued[plat] = true
        end
        return {}
    end

    local prefixes = {
        "Named_Boxarts",
        "Named_Logos",
        "Named_Snaps",
        --"Named_Titles",
    }

    local options = {}
    if self.platformOptions[plat] then
        options = self.platformOptions[plat]
    end

    local result = nil
    local matchingPlatform = plat
    for platform, thumbDict in pairs(thumbDicts) do
        result = self:lookupInDictionary(
            thumbDict,
            prefixes,
            romname,
            { "World", "USA", "United Kingdom", "Europe" },
            { "Demo", "Kiosk", "Beta" },
            options
        )
        -- if result contains anything truthy then dont search any more dictionaries
        if result and next(result) then
            for _, v in pairs(result) do
                if v ~= false then
                    matchingPlatform = platform
                    break
                end
            end
        end
    end

    if result == nil then
        return {}
    end

    local thumbDir = self:_getThumbDirectoryForPlatform(matchingPlatform)
    return self:_mapKeys(result, thumbDir)
end

function M:_mapKeys(result, thumbDir)
    local mapped = {}

    if result["Named_Boxarts"] then
        mapped.box2d = url:encodePath(self.baseUri .. "/" .. thumbDir .. "/" .. result["Named_Boxarts"])
    end
    if result["Named_Logos"] then
        mapped.wheel = url:encodePath(self.baseUri .. "/" .. thumbDir .. "/" .. result["Named_Logos"])
    end
    if result["Named_Snaps"] then
        mapped.screenshot = url:encodePath(self.baseUri .. "/" .. thumbDir .. "/" .. result["Named_Snaps"])
    end
    DD(mapped)
    -- if result["Named_Titles"] then
    --     mapped.title = result["Named_Titles"]
    -- end
    return mapped
end

function M:_getThumbDirectoryForPlatform(plat)
    local p = self.platform:getPlatformByKey(plat)

    if p.libretroThumbFolder == nil then
        return nil
    end

    return p.libretroThumbFolder
end

function M:_getThumbDictionariesForPlatform(plat)
    local thumbDicts = {}
    local p = self.platform:getPlatformByKey(plat)

    if p.libretroThumbFolder ~= nil then
        thumbDicts[plat] =
            path.join({ self.environment:getPath("libretro_thumb_dictionary"), p.libretroThumbFolder .. ".lua" })
    end

    if p.alternate then
        for _, altPlatformKey in ipairs(p.alternate) do
            local altP = self.platform:getPlatformByKey(altPlatformKey)
            if altP.libretroThumbFolder ~= nil then
                thumbDicts[altPlatformKey] = path.join({
                    self.environment:getPath("libretro_thumb_dictionary"),
                    altP.libretroThumbFolder .. ".lua",
                })
            end
        end
    end

    return thumbDicts
end

function M:_getThumbDictionaryForPlatform(plat)
    local p = self.platform:getPlatformByKey(plat)

    if p.libretroThumbFolder == nil then
        return nil
    end

    return path.join({ self.environment:getPath("libretro_thumb_dictionary"), p.libretroThumbFolder .. ".lua" })
end

--- Normalize a string for fuzzy matching by removing bracket,spaces,special chars and rewriting 'and'/'the' etc.
function M:_normalize(str, options)
    str = str
        :gsub(",%s*[Tt][Hh][Ee]", "") -- remove any ',The' (case/spacing insensitive)
        :gsub("^[Tt][Hh][Ee]%s+", "") -- remove 'The ' from start
        :gsub("%b()", "") -- remove balanced (...)
        :gsub("%b[]", "") -- remove balanced [...]
        :gsub("[\"'%+~*#%^=`|!?]", "") -- removes various special characters
        :gsub("[%./\\_%-:]", "")
        :gsub("&", "and") -- removes more special characters

    if options and options.preserve_and then
        -- nothing
    else
        str = str:gsub("%s+[Aa][Nn][Dd]%s+", "")
    end

    if options and options.strip_leading_index then
        str = str:gsub("^%s*[%(%[]?%s*%d+[%]%)]?[%s%._%-:]*", "")
    end
    str = str
        :gsub("%s+", " ") -- collapse multiple spaces
        :gsub("^%s+", "") -- trim leading
        :gsub("%s+$", "") -- trim trailing

    str = str:gsub("%s+", "")

    str = str:lower() -- make case-insensitive

    if options and options.normalize_rev then
        str = str:gsub("[_%-%s]?rev%d+$", "") -- remove "revN"
    end

    return str
end

--- Extract list of region tags from a filename (e.g. returns { "USA", "Europe", "Rev 1" })
--- @param name string
--- @return string[]
function M:_extractRegions(name)
    local regions = {}
    for tag in name:gmatch("%((.-)%)") do
        for subregion in tag:gmatch("[^,]+") do
            local trimmed = subregion:gsub("^%s+", ""):gsub("%s+$", "")
            table.insert(regions, trimmed)
        end
    end
    return regions
end

--- Score a match based on preferred regions and penalty tokens
--- Lower score is better. If no preferred region matches, returns math.huge
--- @param regions string[] list of tags from filename
--- @param preferredRegions string[]
--- @param penaltyTokens? string[] optional list of "bad" tags to downrank
function M:_scoreRegions(regions, preferredRegions, penaltyTokens)
    local score = math.huge

    for i, pref in ipairs(preferredRegions or {}) do
        for _, region in ipairs(regions) do
            if region:lower() == pref:lower() then
                score = i
                break
            end
        end
        if score ~= math.huge then
            break
        end
    end

    -- Penalty if any unwanted tokens are present
    if penaltyTokens then
        for _, penalty in ipairs(penaltyTokens) do
            for _, tag in ipairs(regions) do
                if tag:lower():find(penalty:lower(), 1, true) then
                    score = score + 1000 -- Arbitrary penalty weight
                    break
                end
            end
        end
    end

    return score
end

--- Lookup logic with fuzzy fallback and region priority
--- @param dictionaryPath string
--- @param prefixes string[]
--- @param filename string (input name, no extension)
--- @param preferredRegions? string[] (optional)
--- @param penaltyTokens? string[] (optional)
--- @return table<string, string|false>|nil
function M:lookupInDictionary(dictionaryPath, prefixes, filename, preferredRegions, penaltyTokens, options)
    local ok, entriesOrErr = pcall(dofile, dictionaryPath)
    if not ok then
        self.logger:log("warn", "libretro", "Failed to load dictionary: " .. tostring(entriesOrErr))
        return nil
    end

    self.logger:log("debug", "libretro", string.format("Searching %s for %s", dictionaryPath, filename))

    local entries = entriesOrErr
    local entrySet = {}
    local normalizedMap = {} -- prefix -> normalized -> { original path list }

    for _, pth in ipairs(entries) do
        entrySet[pth] = true
        local prefix, name = pth:match("([^/]+)/(.+)")
        if prefix and name then
            local normalizedName = self:_normalize(path.stem(name), options)
            normalizedMap[prefix] = normalizedMap[prefix] or {}
            normalizedMap[prefix][normalizedName] = normalizedMap[prefix][normalizedName] or {}
            table.insert(normalizedMap[prefix][normalizedName], pth)
        end
    end

    local results = {}
    local targetNormalized = self:_normalize(filename, options)

    for _, prefix in ipairs(prefixes) do
        local full = prefix .. "/" .. filename
        if entrySet[full] then
            results[prefix] = full -- exact match
        elseif normalizedMap[prefix] and normalizedMap[prefix][targetNormalized] then
            local candidates = normalizedMap[prefix][targetNormalized]
            if preferredRegions and #preferredRegions > 0 then
                local bestScore = math.huge
                local bestPath = nil
                for _, pth in ipairs(candidates) do
                    local _, name = pth:match("([^/]+)/(.+)")
                    local score = self:_scoreRegions(self:_extractRegions(name), preferredRegions, penaltyTokens)
                    if score < bestScore then
                        bestScore = score
                        bestPath = pth
                    end
                end
                results[prefix] = bestPath or candidates[1]
            else
                results[prefix] = candidates[1] -- fallback to first fuzzy match
            end
        elseif options and options.prefix_fallback and normalizedMap[prefix] then
            for normKey, candidates in pairs(normalizedMap[prefix]) do
                if normKey:find("^" .. targetNormalized) then
                    results[prefix] = candidates[1]
                    break
                end
            end
            results[prefix] = results[prefix] or false
        else
            results[prefix] = false
        end
    end

    return results
end

return M
