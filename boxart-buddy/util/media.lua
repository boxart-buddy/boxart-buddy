local path = require("util.path")
local filesystem = require("lib.nativefs")
local colors = require("util.colors")
local stringUtil = require("util.string")

local M = {}

function M.mediaPath(cachePath, type, filename)
    return path.join({ cachePath, type, stringUtil.uuidToFolder(filename), filename })
end

---@param absolutePath string
---@return Image?
---@return FileData?
function M.loadImage(absolutePath)
    local fileData = filesystem.newFileData(absolutePath)
    if not fileData then
        return nil, nil
    end

    local success, imageData = pcall(function()
        return love.image.newImageData(fileData)
    end)

    if not success then
        return nil, nil
    end

    return love.graphics.newImage(imageData), fileData
end

local function computeViewportOrigin(x, y, width, height, anchor)
    local ax = anchor.x or "left"
    local ay = anchor.y or "top"

    local vx
    if ax == "center" or ax == "middle" then
        vx = x - width / 2
    elseif ax == "right" then
        vx = x - width
    else -- left or default
        vx = x
    end

    local vy
    if ay == "center" or ay == "middle" then
        vy = y - height / 2
    elseif ay == "bottom" then
        vy = y - height
    else -- top or default
        vy = y
    end

    return vx, vy
end

function M.scaleMedia(image, canvas, options)
    options = options or {}
    local x = options.x or 0
    local y = options.y or 0
    local width = options.width or SCREEN.w
    local height = options.height or SCREEN.h
    local anchor = options.anchor or { x = "left", y = "top" }

    local iw, ih = image:getDimensions()
    local scale = math.max(width / iw, height / ih)

    local sw = width / scale
    local sh = height / scale
    local sx = (iw - sw) / 2
    local sy = (ih - sh) / 2

    local vx, vy = computeViewportOrigin(x, y, width, height, anchor)
    local drawX = vx - sx * scale
    local drawY = vy - sy * scale

    love.graphics.push("all")
    love.graphics.setCanvas(canvas)
    love.graphics.setScissor(vx, vy, width, height)
    love.graphics.setColor(colors.white)
    love.graphics.draw(image, drawX, drawY, 0, scale, scale)
    love.graphics.setScissor()
    love.graphics.setCanvas()
    love.graphics.pop()
end

function M.fitMedia(image, canvas, options)
    options = options or {}
    local x = options.x or 0
    local y = options.y or 0
    local width = options.width or SCREEN.w
    local height = options.height or SCREEN.h
    local anchor = options.anchor or { x = "left", y = "top" }

    local iw, ih = image:getDimensions()
    local scale = math.min(width / iw, height / ih)

    local dx = (width - iw * scale) / 2
    local dy = (height - ih * scale) / 2

    local vx, vy = computeViewportOrigin(x, y, width, height, anchor)
    local drawX = vx + dx
    local drawY = vy + dy

    love.graphics.push("all")
    love.graphics.setCanvas(canvas)
    love.graphics.setScissor(vx, vy, width, height)
    love.graphics.setColor(colors.white)
    love.graphics.draw(image, drawX, drawY, 0, scale, scale)
    love.graphics.setScissor()
    love.graphics.setCanvas()
    love.graphics.pop()
end

return M
