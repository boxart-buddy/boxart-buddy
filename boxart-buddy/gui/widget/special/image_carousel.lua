local nativefs = require("nativefs")
local colors = require("util.colors")
local media = require("util.media")

---@class ImageCarousel
local M = class({
    name = "ImageCarousel",
})

--[[
Options:
  offsetX (number)      -- x position to draw the widget
  offsetY (number)      -- y position to draw the widget
  width   (number)      -- widget area width (required)
  height  (number)      -- widget area height (required)
  spacing (number)      -- horizontal spacing between frames (default 16)
  framePadding (number) -- inner padding inside each frame (default 8)
  colors (table)        -- { frame, selectedFrame }
  startIndex (number)   -- 1-based starting index (default 1)

Signature:
  M:new(canvas, items, options)
    items: array of tables, each at least: { path = "/abs/path/to.png", id=?, label=? }

Behavior:
  - Always renders inline (non-modal)
  - Shows the selected item centered, with partial neighbors left/right (clipped by widget area)
  - Wrap navigation on left/right; returns the selected item table when moved
  - Uses flux to tween horizontal slide between selections
]]

-- ---------- Helpers ----------
local function clamp(v, a, b)
    if v < a then
        return a
    elseif v > b then
        return b
    else
        return v
    end
end

local function wrapIndex(i, n)
    return (i - 1) % n + 1
end

-- Load an Image from absolute path with in-memory caching
local function makeImageLoader(cache)
    return function(path)
        if not path then
            return nil
        end
        local cached = cache[path]
        if cached and cached.type and cached:typeOf("Image") then
            return cached
        end
        local bytes, err = nativefs.read(path)
        if not bytes then
            return nil
        end
        local fdata = love.filesystem.newFileData(bytes, path)
        local idata = love.image.newImageData(fdata)
        local img = love.graphics.newImage(idata)
        cache[path] = img
        return img
    end
end

local function preloadNeighbors(self)
    local n = #self.items
    if n <= 1 then
        return
    end
    local function idx(k)
        return (k - 1) % n + 1
    end
    local i = self.index
    -- preload two on each side
    local want = { idx(i - 2), idx(i - 1), i, idx(i + 1), idx(i + 2) }
    for _, wi in ipairs(want) do
        local it = self.items[wi]
        if it and it.path then
            self.loadImage(it.path) -- caches result
        end
    end
end

-- Draw an image fitted into a rectangle, preserving aspect, clipped to the frame
local function drawImageFit(img, x, y, w, h)
    if not (img and img.type and img:typeOf("Image")) then
        return
    end
    local iw, ih = img:getDimensions()
    local scale = math.min(w / iw, h / ih)
    local dx = x + (w - iw * scale) / 2
    local dy = y + (h - ih * scale) / 2

    love.graphics.push("all")
    -- preserve any existing scissor (e.g., widget bounds) and intersect with our frame rect
    local sx, sy, sw, sh = love.graphics.getScissor()
    if sx then
        local nx = math.max(x, sx)
        local ny = math.max(y, sy)
        local nx2 = math.min(x + w, sx + sw)
        local ny2 = math.min(y + h, sy + sh)
        local nw = math.max(0, nx2 - nx)
        local nh = math.max(0, ny2 - ny)
        love.graphics.setScissor(nx, ny, nw, nh)
    else
        love.graphics.setScissor(x, y, w, h)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, dx, dy, 0, scale, scale)

    -- restore previous scissor (do NOT clear the widget scissor)
    if sx then
        love.graphics.setScissor(sx, sy, sw, sh)
    else
        love.graphics.setScissor()
    end
    love.graphics.pop()
end

-- ---------- Constructor ----------
function M:new(canvas, flux, items, options)
    self.canvas = canvas
    self.items = items or {}
    self.options = options or {}

    self.flux = flux
    self.offsetX = self.options.offsetX or 0
    self.offsetY = self.options.offsetY or 0
    self.width = assert(self.options.width, "ImageCarousel requires options.width")
    self.height = assert(self.options.height, "ImageCarousel requires options.height")
    self.spacing = self.options.spacing or 16
    self.framePadding = self.options.framePadding or 8
    self.cornerR = 6

    self.colors = self.options.colors
        or {
            frame = colors.offWhite,
            selectedFrame = colors.red,
            selectedFill = colors.activeUI,
        }

    local count = #self.items
    local start = clamp(self.options.startIndex or 1, 1, math.max(1, count))
    self.index = start

    -- animation state (horizontal slide in pixels)
    self.slide = 0
    self.animating = false
    self.animStep = 0 -- cached step size used during animation

    -- image cache + loader
    self.imageCache = {}
    self.loadImage = makeImageLoader(self.imageCache)

    preloadNeighbors(self)
end

-- ---------- Update ----------
function M:update(dt)
    -- Intentionally empty; assume flux.update(dt) is called centrally.
end

-- ---------- Input ----------
function M:handleInput(input)
    local n = #self.items
    if n == 0 then
        return nil
    end
    if self.animating then
        return nil
    end

    -- Frame is square based on widget height
    local frameSize = self.height
    local step = frameSize + self.spacing

    if input == "left" then
        self.animating = true
        self.animStep = step
        local nextIndex = wrapIndex(self.index - 1, n)
        preloadNeighbors({ items = self.items, index = nextIndex, loadImage = self.loadImage })
        self.slide = 0
        self.flux.to(self, 0.22, { slide = step }):ease("quadout"):oncomplete(function()
            self.index = nextIndex
            self.slide = 0
            self.animating = false
            preloadNeighbors(self)
        end)
        return self.items[nextIndex]
    elseif input == "right" then
        self.animating = true
        self.animStep = step
        local nextIndex = wrapIndex(self.index + 1, n)
        preloadNeighbors({ items = self.items, index = nextIndex, loadImage = self.loadImage })
        self.slide = 0
        self.flux.to(self, 0.22, { slide = -step }):ease("quadout"):oncomplete(function()
            self.index = nextIndex
            self.slide = 0
            self.animating = false
            preloadNeighbors(self)
        end)
        return self.items[nextIndex]
    end

    return nil
end

function M:current()
    return self.items[self.index]
end

-- ---------- Rendering ----------
function M:draw()
    love.graphics.setCanvas(self.canvas)

    local n = #self.items
    if n == 0 then
        love.graphics.setCanvas()
        return
    end

    local ox, oy, w, h = self.offsetX, self.offsetY, self.width, self.height

    -- Clip to widget bounds
    love.graphics.push("all")
    love.graphics.setScissor(ox, oy, w, h)

    local centerX = ox + w / 2
    local frameSize = h -- square frames that fully use widget height
    local step = frameSize + self.spacing
    local baseY = oy + (h - frameSize) / 2

    local iSel = self.index
    local iL1 = wrapIndex(iSel - 1, n)
    local iL2 = wrapIndex(iSel - 2, n)
    local iR1 = wrapIndex(iSel + 1, n)
    local iR2 = wrapIndex(iSel + 2, n)

    local cx = math.floor(centerX - frameSize / 2)
    -- positions for neighbors relative to center, shifted by slide
    local xL2 = cx - 2 * step + self.slide
    local xL1 = cx - 1 * step + self.slide
    local xC = cx + self.slide -- current image also slides
    local xR1 = cx + 1 * step + self.slide
    local xR2 = cx + 2 * step + self.slide

    -- Selected fill (under images), fixed at center
    if self.colors.selectedFill then
        love.graphics.setColor(self.colors.selectedFill or { 0, 0, 0, 0 })
        love.graphics.rectangle("fill", cx, baseY, frameSize, frameSize, self.cornerR, self.cornerR)
    end

    -- Draw order: furthest neighbors first, selected last (visual priority)
    local frames = {
        { idx = iL2, x = xL2 },
        { idx = iL1, x = xL1 },
        { idx = iR1, x = xR1 },
        { idx = iR2, x = xR2 },
        { idx = iSel, x = xC },
    }

    for _, f in ipairs(frames) do
        local item = self.items[f.idx]
        local img = item and self.loadImage(item.path)

        -- Frame rect
        local fx, fy, fw, fh = f.x, baseY, frameSize, frameSize

        -- Image rect inside frame (padding)
        local pad = self.framePadding
        local ix, iy, iw, ih = fx + pad, fy + pad, fw - pad * 2, fh - pad * 2

        -- Frame outline (base color); selection is drawn separately as a fixed overlay
        if self.colors.frame then
            love.graphics.setColor(self.colors.frame)
            love.graphics.rectangle("line", fx, fy, fw, fh, self.cornerR, self.cornerR)
        end
        -- Image
        if img then
            drawImageFit(img, ix, iy, iw, ih)
        end
    end

    -- Fixed center selection highlight
    if self.colors.selectedFrame then
        love.graphics.setColor(self.colors.selectedFrame)
        love.graphics.rectangle("line", cx, baseY, frameSize, frameSize, self.cornerR, self.cornerR)
    end

    -- Restore state
    love.graphics.setScissor()
    love.graphics.pop()

    love.graphics.setCanvas()
end

return M
