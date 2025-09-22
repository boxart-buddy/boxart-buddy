local M = {}

local ZIP_EXTENSIONS = {
    zip = true,
    ["7z"] = true,
    ["7zip"] = true,
    z = true,
    gz = true,
}

local DISC_EXTENSIONS = {
    chd = true,
    bin = true,
    iso = true,
    img = true,
    ccd = true,
    nrg = true,
    mdf = true,
}

local EXTENSION_BLACKLIST = {
    txt = true,
    nfo = true,
    log = true,
    doc = true,
    ini = true,
    json = true,
    xml = true,
}

-- this is pointless due to the above
local FILENAME_BLACKLIST = {
    ["readme.txt"] = true,
    ["license.txt"] = true,
    ["rominfo.txt"] = true,
    ["file_id.diz"] = true,
    ["catalog.xml"] = true,
    ["cheats.json"] = true,
    ["neogeo.zip"] = true,
}

---@param extension ?string
---@return boolean
function M:isZip(extension)
    return extension ~= nil and ZIP_EXTENSIONS[extension]
end

function M:isDisc(extension)
    return extension ~= nil and DISC_EXTENSIONS[extension]
end

--- @param filename string file basename with extension
--- @return boolean Should the filename be ignored (is it trash?)
function M:shouldIgnore(filename)
    -- skip hidden/dotfiles
    if filename:sub(1, 1) == "." then
        return true
    end

    local lower = filename:lower()

    -- check exact filename
    if FILENAME_BLACKLIST[lower] then
        return true
    end

    -- extract extension and check
    local ext = lower:match("%.([a-z0-9]+)$")
    if ext and EXTENSION_BLACKLIST[ext] then
        return true
    end

    return false
end

return M
