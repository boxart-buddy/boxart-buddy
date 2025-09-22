local M = {}

--- Join path parts into a single path.
--- If called with a table: M.join({ "a", "b", "c" })
--- If called with varargs: M.join("a", "b", "c")
---@overload fun(...: string): string
---@param parts string[]|string  # table of segments or first segment
---@vararg string                # remaining segments when using varargs
---@return string
function M.join(parts, ...)
    local args
    if select("#", ...) > 0 then
        -- Called as M.join("a", "b", "c")
        args = { parts, ... }
    elseif type(parts) == "table" then
        -- Called as M.join({"a", "b", "c"})
        args = parts
    else
        -- Single string argument
        args = { parts }
    end

    local cleaned = {}
    local isAbsolute = false

    for i, part in ipairs(args) do
        if type(part) == "string" then
            if i == 1 and part:sub(1, 1) == "/" then
                isAbsolute = true
            end
            local stripped = (part:gsub("^/*", "")):gsub("/*$", "")
            if #stripped > 0 then
                table.insert(cleaned, stripped)
            end
        end
    end

    local path = table.concat(cleaned, "/")
    if isAbsolute then
        path = "/" .. path
    end

    return path
end

--- Get the file extension from a path (excluding the dot)
--- Returns nil if no extension is found
--- @param path string
--- @return string|nil
function M.extension(path, whitelist)
    -- Strip trailing slashes (e.g., "/some/dir/")
    path = path:gsub("/*$", "")

    -- Get the last component of the path
    local filename = path:match("([^/\\]+)$")
    if not filename then
        return nil
    end

    -- Ignore hidden files like `.bashrc` (no extension)
    if filename:sub(1, 1) == "." and not filename:find("%.", 2) then
        return nil
    end

    -- Find last dot, return substring after
    local ext = filename:match("^.+%.([^%.]+)$")

    if not ext then
        return nil
    end
    if string.len(ext) > 10 then
        return nil
    end
    if whitelist and type(whitelist) == "table" then
        if not table.contains(whitelist, ext) then
            return nil
        end
    end
    return ext
end

---removes the exisiting file extension and replaces it wth a new one
---@param path string
---@param newExtension string
---@return string
function M.swapExtension(path, newExtension)
    local ext = M.extension(path)
    if not ext then
        -- no extension, just append
        return path .. "." .. newExtension
    end

    -- replace last occurrence of .ext with new extension
    local replaced = path:gsub("%." .. ext .. "$", "." .. newExtension)
    return replaced
end

--- Returns the filename (last component) of the path, including extension.
-- @param fullpath string
-- @return string basename
function M.basename(fullpath)
    -- Remove trailing slashes (if any)
    fullpath = fullpath:gsub("/*$", "")

    -- Capture last part after the final slash
    local filename = fullpath:match("([^/\\]+)$")
    return filename
end

--- Returns the filename without its extension.
-- @param fullpath string
-- @return string stem
function M.stem(fullpath)
    -- Strip trailing slashes
    fullpath = fullpath:gsub("/*$", "")

    -- Separate directory and filename
    local dir, file = fullpath:match("^(.-)([^/\\]+)$")
    if not file then
        return fullpath -- no filename found
    end

    -- Ignore hidden files like `.bashrc`
    if file:sub(1, 1) == "." and not file:find("%.", 2) then
        return fullpath
    end

    -- Remove last dot and extension
    local base = file:match("^(.*)%.([^%.]+)$")
    if not base then
        return fullpath
    end

    return (dir or "") .. base
end

--- Returns the directory part of `fullpath` relative to `basepath`.
-- @param fullpath string
-- @param basepath string
-- @return string relative_dir
function M.relativeDir(fullpath, basepath)
    -- Normalize slashes (optional, in case of Windows-style paths)
    fullpath = fullpath:gsub("\\", "/")
    basepath = basepath:gsub("\\", "/")

    -- Strip the filename
    local dir = fullpath:match("^(.*)/[^/]*$") or fullpath

    -- Remove the basepath prefix
    if dir == basepath then
        return "."
    elseif dir:sub(1, #basepath) == basepath then
        local relative = dir:sub(#basepath + 1)
        if relative:sub(1, 1) == "/" then
            relative = relative:sub(2)
        end
        return relative
    end

    -- If basepath is not a prefix, return nil or the full dir
    return nil
end

--- Returns the directory portion of the path.
-- @param fullpath string
-- @return string dirname
function M.dirname(fullpath)
    -- Normalize slashes
    fullpath = fullpath:gsub("\\", "/")
    -- Remove trailing slashes
    fullpath = fullpath:gsub("/+$", "")
    -- If no slash left, it's in the current directory
    if not fullpath:find("/") then
        return "."
    end
    -- Remove last path component
    local dir = fullpath:match("^(.*)/[^/]*$") or fullpath
    return dir ~= "" and dir or "/"
end

--- Returns the name of the immediate parent directory.
-- @param fullpath string
-- @return string parentName
function M.parentName(fullpath)
    fullpath = fullpath:gsub("\\", "/")
    fullpath = fullpath:gsub("/+$", "") -- strip trailing slashes

    local parent = fullpath:match("^(.*)/[^/]*$") or ""
    local name = parent:match("([^/]+)$")

    return name or ""
end

---Returns all parent folders with immediate parent first / root folder last
---@param fullPath string
---@return table
function M.parentNames(fullPath)
    fullPath = fullPath:gsub("\\", "/")
    fullPath = fullPath:gsub("/+$", "") -- strip trailing slashes

    local parents = {}
    local current = fullPath:match("^(.*)/[^/]*$") -- remove file or last segment

    while current and current ~= "" do
        local name = current:match("([^/]+)$")
        if not name then
            break
        end
        table.insert(parents, name)
        current = current:match("^(.*)/[^/]*$") -- move one level up
    end

    return parents
end

--- Returns the full path relative to a base path (including filename).
-- @param fullpath string
-- @param basepath string
-- @return string|nil relative_path
function M.relativePath(fullpath, basepath)
    -- Normalize slashes
    fullpath = fullpath:gsub("\\", "/")
    basepath = basepath:gsub("\\", "/")

    -- Ensure basepath ends with a slash for clean matching
    if basepath:sub(-1) ~= "/" then
        basepath = basepath .. "/"
    end

    -- Check prefix
    if fullpath:sub(1, #basepath) == basepath then
        local relative = fullpath:sub(#basepath + 1)
        return relative
    end

    -- No match
    return nil
end

return M
