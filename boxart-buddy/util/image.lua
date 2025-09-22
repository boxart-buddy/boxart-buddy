local vips = require("lib.vips")
local nativefs = require("nativefs")
local stringUtil = require("util.string")

local M = {}

--- Scale an image in-place to the given width, preserving aspect ratio.
--- Only downsizes; never upscales if options.scaleDownOnly == true
--- Overwrites the original using nativefs.
---
--- @param path string         Path to the image file
--- @param targetWidth number Desired maximum width
--- @param options table Options
--- @return boolean|nil, string?  true if resized, false if no change, nil+err if error
function M.rescale(path, targetWidth, options)
    options = options or {}
    local scaleDownOnly = options.scaleDownOnly or false
    if type(path) ~= "string" or path == "" then
        return nil, "invalid path"
    end
    local tw = tonumber(targetWidth)
    if not tw or tw <= 0 then
        return nil, "invalid targetWidth"
    end

    local img = vips.Image.new_from_file(path, { access = "random" })
    if not img then
        return nil, "failed to open image"
    end

    local w = img:width()
    if tw >= w and scaleDownOnly then
        return false, "no resize needed"
    end

    local scale = tw / w
    local resized = img:resize(scale, { kernel = "lanczos3" })

    -- Write to a temporary file in same directory, preserving extension so vips knows the format
    local ext = path:match("%.([A-Za-z0-9]+)$")
    local tmp
    if ext then
        tmp = path .. ".vips.tmp." .. ext
    else
        tmp = path .. ".vips.tmp"
    end
    local ok, err = pcall(function()
        resized:write_to_file(tmp)
    end)
    if not ok then
        nativefs.remove(tmp) -- cleanup if partial
        return nil, "failed to write temp file: " .. tostring(err)
    end

    -- Replace original with temp using mv via os.execute for efficiency
    local cmd = string.format("mv %s %s", stringUtil.shellQuote(tmp), stringUtil.shellQuote(path))
    local result = os.execute(cmd)
    if result ~= true and result ~= 0 then
        nativefs.remove(tmp)
        return nil, "failed to move temp file to destination"
    end

    return true
end

function M.ensurePng(path)
    if type(path) ~= "string" or path == "" then
        return nil, "invalid path"
    end

    local ext = path:match("%.([A-Za-z0-9]+)$")
    if ext and ext:lower() == "png" then
        return path -- already PNG
    end

    local img
    local ok, err = pcall(function()
        img = vips.Image.new_from_file(path, { access = "random" })
    end)
    if not ok or not img then
        return path, "failed to open image: " .. tostring(err)
    end

    -- Build new filename with .png extension
    local base = path:gsub("%.[A-Za-z0-9]+$", "")
    local newPath = base .. ".png"

    local ok2, err2 = pcall(function()
        img:write_to_file(newPath)
    end)
    if not ok2 then
        return path, "failed to write PNG: " .. tostring(err2)
    end

    -- Remove the old file and replace with newPath
    nativefs.remove(path)
    return newPath
end

return M
