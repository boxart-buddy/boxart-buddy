local vips = require("lib.vips")
local M = class({ name = "MixContextAdaptor" })

-- Small helpers (private)
local function _bb_clamp(v, lo, hi)
    if v < lo then
        return lo
    end
    if v > hi then
        return hi
    end
    return v
end

local function _bb_round(mode, x)
    if mode == "floor" then
        return math.floor(x)
    elseif mode == "ceil" then
        return math.ceil(x)
    else
        return math.floor(x + 0.5)
    end -- default: round
end

local function _bb_parse_percent_or_number(v)
    if type(v) == "string" then
        local p = v:match("^%s*(%-?[%d%.]+)%%%s*$")
        if p then
            return tonumber(p) / 100.0
        end
    end
    return tonumber(v)
end

local function _bb_parse_object_position(pos, axis)
    -- axis: "x" or "y"
    if type(pos) == "table" then
        local v = (axis == "x") and pos.x or pos.y
        if v == nil then
            return 0.5
        end
        local n = _bb_parse_percent_or_number(v)
        if n ~= nil then
            return _bb_clamp(n, 0, 1)
        end
        if type(v) == "string" then
            v = v:lower()
            if axis == "x" then
                if v == "left" then
                    return 0.0
                end
                if v == "center" or v == "middle" then
                    return 0.5
                end
                if v == "right" then
                    return 1.0
                end
            else
                if v == "top" then
                    return 0.0
                end
                if v == "center" or v == "middle" then
                    return 0.5
                end
                if v == "bottom" then
                    return 1.0
                end
            end
        end
        return 0.5
    elseif pos == nil then
        return 0.5
    else
        local n = _bb_parse_percent_or_number(pos)
        if n ~= nil then
            return _bb_clamp(n, 0, 1)
        end
        return 0.5
    end
end

local function _bb_color_or_transparent(bg)
    -- Ensure 4-element RGBA array (uchar)
    local r, g, b, a = 0, 0, 0, 0
    if type(bg) == "table" then
        r = tonumber(bg[1]) or 0
        g = tonumber(bg[2]) or 0
        b = tonumber(bg[3]) or 0
        a = tonumber(bg[4]) or 0
    end
    return { r, g, b, a }
end

local function toAlpha(img)
    local b = img:bands()
    if b == 4 or b == 2 then
        -- use the existing alpha band
        return img:extract_band(b - 1)
    elseif b == 1 then
        -- already single-band
        return img
    else
        -- 3-band RGB: convert to a single-band luma mask
        return img:colourspace("b-w")
    end
end

local function ensureRGBA(img)
    -- Return a STRAIGHT (unpremultiplied) RGBA image tagged as sRGB, alpha last
    local b = img:bands()

    if b == 4 then
        -- Assume last band is alpha; just ensure sRGB tag
        return img:copy({ interpretation = "srgb" })
    elseif b == 3 then
        -- RGB -> RGBA with opaque alpha
        local rgba = img:bandjoin({ img:new_from_image(255) })
        return rgba:copy({ interpretation = "srgb" })
    elseif b == 2 then
        -- Gray + Alpha -> replicate gray to RGB and append alpha
        local gray = img:extract_band(0)
        local alpha = img:extract_band(1)
        local rgb = gray:bandjoin({ gray, gray })
        local rgba = rgb:bandjoin({ alpha })
        return rgba:copy({ interpretation = "srgb" })
    elseif b == 1 then
        -- Gray -> replicate to RGB, add opaque alpha
        local rgb = img:bandjoin({ img, img })
        local rgba = rgb:bandjoin({ img:new_from_image(255) })
        return rgba:copy({ interpretation = "srgb" })
    else
        -- >4 bands: take first three as RGB and last as alpha
        local rgb = img:extract_band(0, { n = 3 })
        local alpha = img:extract_band(b - 1)
        local rgba = rgb:bandjoin({ alpha })
        return rgba:copy({ interpretation = "srgb" })
    end
end

function M:new(ctx)
    self.ctx = ctx
end

function M:hasMedia(typ)
    return self.ctx:hasMedia(typ)
end

---@param name string
---@return Image?
function M:getMedia(name)
    if not self.ctx.media[name] then
        return nil
    end

    return vips.Image.new_from_file(self.ctx.media[name], { access = "random" }):colourspace("srgb")
end

function M:alphaMask(maskPath, opts)
    opts = opts or {}

    -- Placement and transform options
    local x = tonumber(opts.x or 0)
    local y = tonumber(opts.y or 0)
    local flipH = opts.flipH or false

    -- Use same anchor semantics as `place`
    local anchor = opts.canvas_anchor or {}
    anchor.x = anchor.x or "left"
    anchor.y = anchor.y or "top"

    local pixel_round = (opts.pixel_round or "round"):lower()

    -- Load mask without colourspace conversion so we don't drop/alter its alpha band
    local maskImg = vips.Image.new_from_file(maskPath, { access = "random" })
    if flipH then
        maskImg = maskImg:fliphor()
    end

    -- If requested, resize the mask using the existing `resize` logic
    -- (forward the same options) when fit ~= "none".
    local fit = (opts.fit or "none"):lower()
    local src
    if fit ~= "none" then
        -- Reuse pipeline: resize respects frame/fit/object_position/etc.
        src = self:resize(maskImg, opts)
    else
        src = maskImg
    end

    -- Ensure we work on straight (unpremultiplied) canvas and get its size
    local straight = self.ctx.canvas
    local cw, ch = straight:width(), straight:height()

    -- Derive a single-band alpha from the (potentially resized) mask
    local aMask = toAlpha(src)
    -- ensure mask is uchar single-band
    if aMask:bands() > 1 then
        aMask = aMask:extract_band(0)
    end
    if aMask:format() ~= "uchar" then
        aMask = aMask:cast("uchar")
    end

    -- Compute placement like `place`, using canvas_anchor
    local sw, sh = src:width(), src:height()
    local ax = 0
    if anchor.x == "center" then
        ax = -math.floor(sw / 2)
    elseif anchor.x == "right" then
        ax = -sw
    end

    local ay = 0
    if anchor.y == "middle" then
        ay = -math.floor(sh / 2)
    elseif anchor.y == "bottom" then
        ay = -sh
    end

    -- Apply rounding mode and anchor offsets
    local function _round(mode, val)
        if mode == "floor" then
            return math.floor(val)
        elseif mode == "ceil" then
            return math.ceil(val)
        else
            return math.floor(val + 0.5)
        end
    end
    local px = _round(pixel_round, x) + ax
    local py = _round(pixel_round, y) + ay

    -- Split RGB and existing alpha from canvas
    local rgb = straight:extract_band(0, { n = 3 })
    rgb = rgb:copy({ interpretation = "srgb" })
    local oldA = straight:extract_band(3)

    -- Build a full-size zero mask and insert our (placed) mask alpha at (px,py)
    local fullMask = oldA:new_from_image(0)
    fullMask = fullMask:insert(aMask, px, py)
    -- ensure fullMask is uchar single-band (safety)
    if fullMask:bands() > 1 then
        fullMask = fullMask:extract_band(0)
    end
    if fullMask:format() ~= "uchar" then
        fullMask = fullMask:cast("uchar")
    end

    -- decide how to apply the mask
    local oldAmax = oldA:max() or 0

    local newA
    if oldAmax == 0 then
        -- empty canvas alpha: set alpha from mask region (keep outside as 0)
        newA = fullMask
    else
        -- multiply existing alpha by mask in [0..1]
        local m = (fullMask:cast("float") / 255.0)
        newA = (oldA:cast("float") * m):cast("uchar")
    end

    -- rejoin as straight RGBA (no premultiply in straight pipeline)
    local masked = rgb:bandjoin({ newA })
    masked = masked:copy({ interpretation = "srgb" })
    self.ctx.canvas = masked
    return self
end

function M:opacity(scale)
    -- Ensure we are working with a STRAIGHT RGBA image (alpha last)
    local img = ensureRGBA(self.ctx.canvas)

    -- Normalize and clamp the scale to [0,1]
    local s = tonumber(scale) or 1.0
    if s > 1.0 then
        s = 1.0
    end
    if s < 0.0 then
        s = 0.0
    end

    -- Compute new alpha = old alpha * s (work in float, then cast back)
    local oldA = img:extract_band(3)
    local newA = (oldA:cast("float") * s):cast("uchar")

    -- Rebuild as RGBA by joining RGB (first 3 bands) with the *new* alpha
    local rgb = img:extract_band(0, { n = 3 }):copy({ interpretation = "srgb" })

    self.ctx.canvas = rgb:bandjoin({ newA })
    return self
end

function M:premultiply()
    local img = ensureRGBA(self.ctx.canvas):cast("float")
    local rgb = img:extract_band(0, { n = 3 })
    local alpha = img:extract_band(3)
    local premul = (rgb * alpha / 255):cast("uchar")
    self.ctx.canvas = premul:bandjoin({ alpha })
    return self
end

function M:withStroke(img, opts)
    opts = opts or {}

    -- Ensure random access (sequential sources can only be read once)
    --img = img:copy_memory()

    local width = tonumber(opts.width or 4)
    local pad = math.ceil(width + 2)
    local color = opts.color or { 1, 1, 1, 1 }
    local opacity = opts.opacity

    color[1] = _bb_round("round", color[1] * 255)
    color[2] = _bb_round("round", color[2] * 255)
    color[3] = _bb_round("round", color[3] * 255)

    -- Canonicalise to STRAIGHT RGBA: ensure we have 4 bands with alpha last
    -- (safe even in a straight-alpha pipeline; output remains straight)
    local straight = ensureRGBA(img)

    -- Optional padding so the stroke is not clipped at image bounds
    if pad > 0 then
        straight = straight:embed(
            pad,
            pad,
            straight:width() + 2 * pad,
            straight:height() + 2 * pad,
            { extend = "background", background = { 0, 0, 0, 0 } }
        )
    end

    -- Robust alpha extraction (handles RGBA, GA, etc.)
    local a = toAlpha(straight)
    local af = (a:cast("float") / 255.0) -- 0..1

    -- Build continuous outline: blur-expand then subtract original
    local sigma = math.max(0.5, width / 2)
    local expanded = af:gaussblur(sigma)
    local outline = (expanded - af) -- continuous, may have tiny negatives

    -- Remove tiny negatives without bouncing types
    local posmask = outline:moreeq(0):cast("float") / 255.0 -- 0/1 float mask
    outline = outline * posmask

    -- HARD THRESHOLD to make a solid edge (0..1 float)
    -- Use provided threshold if given (0..1 or 0..255); default ~0.05 (≈13/255)
    local thr
    if opts.threshold ~= nil then
        thr = tonumber(opts.threshold) or 0.05
        if thr > 1.0 then
            thr = thr / 255.0
        end
    else
        thr = 0.05
    end
    local hardMask = outline:more(thr):cast("float") / 255.0 -- 0 or 1 in float

    -- Apply a small default feather to avoid jaggy edges (no option)
    local feather = 1
    hardMask = hardMask:gaussblur(feather)

    -- If requested, keep stroke strictly outside the original fill
    if opts.outside_only then
        hardMask = hardMask * (1.0 - af)
    end

    -- Resolve opacity scale: color[4] can be 0..1 (preferred) or 0..255.
    local alphaScale
    if color[4] ~= nil then
        local v = tonumber(color[4]) or 1.0
        alphaScale = (v > 1.0) and (v / 255.0) or v
    elseif opacity ~= nil then
        alphaScale = tonumber(opacity) or 1.0
    else
        alphaScale = 1.0
    end

    -- Final stroke alpha in 0..1 float
    local sa = hardMask * alphaScale

    -- Build coloured stroke (float RGB 0..255), tag as sRGB, then premultiply
    local cr, cg, cb = color[1] or 255, color[2] or 255, color[3] or 255
    local sc = vips.Image
        .black(straight:width(), straight:height())
        :new_from_image({ cr, cg, cb })
        :copy({ interpretation = "srgb" })
        :cast("float")

    -- Build STRAIGHT (unpremultiplied) stroke: uchar RGB + uchar A
    local saU2 = (sa * 255):cast("uchar")
    local scU2 =
        vips.Image.black(sc:width(), sc:height()):new_from_image({ cr, cg, cb }):copy({ interpretation = "srgb" }) -- tag as sRGB
    local stroke = scU2:bandjoin({ saU2 })

    -- Composite in straight-alpha to avoid dark edge tint (both inputs straight)
    local result_s = straight:composite2(stroke, "over", { premultiplied = false })
    local result = result_s

    return result
end

--- Render an image into a *frame* of fixed size using fit/crop/alignment rules.
--- Returns a new bitmap sized to the frame; does not composite on the canvas.
---
--- Options (`opts`):
--- • frame: { w: number, h: number }
---     Target frame size. Defaults to canvas size (if available) or source size.
---
--- • fit: 'contain'|'cover'|'fill'|'none'|'scale-down' (default 'contain')
---     - contain: uniform scale to fit fully; pads with background.
---     - cover:   uniform scale to fill frame; crops overflow.
---     - fill:    non-uniform stretch to exactly fill frame.
---     - none:    no scaling; clip or pad as needed.
---     - scale-down: like contain but never upsizes.
---
--- • object_position: { x: string|number, y: string|number }
---     Alignment inside frame (for contain: padding position; for cover: crop side).
---     Keywords: 'left'|'center'|'right' (x), 'top'|'center'|'bottom' (y).
---     Or numeric 0..1, or percent strings e.g. "30%".
---
--- • focal_point: { fx: number, fy: number }
---     Normalized [0..1] point in source image to keep in view.
---
--- • map_focal_to: { px: number, py: number }
---     Normalized [0..1] point in frame where focal_point should land. Defaults to center.
---
--- • allow_upscale: boolean (default true)
--- • min_scale, max_scale: numbers to clamp scale
--- • zoom: number multiplier applied after fit scale (default 1.0)
--- • kernel: string resample kernel (default 'lanczos3')
--- • pixel_round: 'round'|'floor'|'ceil' (default 'round')
--- • background: {r,g,b,a} in 0..255 for letterbox padding (default transparent)
--- • pad: boolean (default true) — when false, return the scaled image at its actual size (no letterbox embedding).
---
--- @param img vips.Image
--- @param opts table|nil
--- @return vips.Image
function M:resize(img, opts)
    if type(img) == "string" then
        img = vips.Image.new_from_file(img, { access = "random" })
    end
    opts = opts or {}

    -- Frame definition
    local frame = opts.frame or {}
    local bw = tonumber(frame.w) or ((self.ctx.canvas and self.ctx.canvas:width()) or img:width())
    local bh = tonumber(frame.h) or ((self.ctx.canvas and self.ctx.canvas:height()) or img:height())

    -- Fit options
    local fit = (opts.fit or "contain"):lower() -- contain|cover|fill|none|scale-down
    local kernel = opts.kernel or "lanczos3"
    local allow_upscale = (opts.allow_upscale ~= false)
    local min_scale = tonumber(opts.min_scale or -math.huge)
    local max_scale = tonumber(opts.max_scale or math.huge)
    local zoom = tonumber(opts.zoom or 1.0)
    local pad = (opts.pad ~= false) -- default true: padded frame; false: return tight image

    -- Alignment inside the frame
    local posx = _bb_parse_object_position(opts.object_position, "x")
    local posy = _bb_parse_object_position(opts.object_position, "y")

    -- Focal point mapping (optional)
    local use_focal = (type(opts.focal_point) == "table")
    local fx = 0.5
    local fy = 0.5
    if use_focal then
        fx = _bb_clamp(tonumber(opts.focal_point.fx or 0.5) or 0.5, 0, 1)
        fy = _bb_clamp(tonumber(opts.focal_point.fy or 0.5) or 0.5, 0, 1)
    end
    local px = 0.5
    local py = 0.5
    if type(opts.map_focal_to) == "table" then
        px = _bb_clamp(tonumber(opts.map_focal_to.px or 0.5) or 0.5, 0, 1)
        py = _bb_clamp(tonumber(opts.map_focal_to.py or 0.5) or 0.5, 0, 1)
    end

    local bg = _bb_color_or_transparent(opts.background)
    local pixel_round = (opts.pixel_round or "round"):lower()

    -- Ensure input colourspace is sRGB (keep alpha straight)
    local src = img:copy({ interpretation = "srgb" })
    local iw, ih = src:width(), src:height()

    local result

    if fit == "fill" then
        -- Independent scaling to match frame exactly
        local sx = bw / iw
        local sy = bh / ih
        if not allow_upscale then
            if sx > 1 then
                sx = 1
            end
            if sy > 1 then
                sy = 1
            end
        end
        sx = _bb_clamp(sx, min_scale, max_scale)
        sy = _bb_clamp(sy, min_scale, max_scale)
        local scaled = src:resize(sx, { vscale = sy, kernel = kernel })
        -- If rounding produced off-by-1, pad or crop to exact frame
        if scaled:width() ~= bw or scaled:height() ~= bh then
            if scaled:width() < bw or scaled:height() < bh then
                local ox = math.floor((bw - scaled:width()) / 2 + 0.5)
                local oy = math.floor((bh - scaled:height()) / 2 + 0.5)
                result = scaled:embed(ox, oy, bw, bh, { extend = "background", background = bg })
            else
                result = scaled:crop(0, 0, bw, bh)
            end
        else
            result = scaled
        end
        return result:copy({ interpretation = "srgb" })
    end

    -- Compute uniform scale for contain/cover/scale-down
    local sx = bw / iw
    local sy = bh / ih
    local s
    if fit == "contain" or fit == "scale-down" then
        s = math.min(sx, sy)
        if fit == "scale-down" and s > 1 then
            s = 1
        end
    elseif fit == "cover" then
        s = math.max(sx, sy)
    elseif fit == "none" then
        s = nil -- will handle separately
    else
        error("unknown fit: " .. tostring(fit))
    end

    if s then
        s = s * zoom
        if not allow_upscale and s > 1 then
            s = 1
        end
        s = _bb_clamp(s, min_scale, max_scale)
    end

    local sw, sh, scaled
    if s then
        scaled = src:resize(s, { kernel = kernel })
        sw, sh = scaled:width(), scaled:height()
    else
        scaled = src
        sw, sh = iw, ih
    end

    if fit == "cover" then
        -- Overflow to crop: choose crop origin using focal or object-position
        local ox_over = math.max(0, sw - bw)
        local oy_over = math.max(0, sh - bh)

        local cx, cy
        if use_focal then
            local focal_x = fx * sw
            local focal_y = fy * sh
            cx = _bb_round(pixel_round, focal_x - px * bw)
            cy = _bb_round(pixel_round, focal_y - py * bh)
        else
            cx = _bb_round(pixel_round, posx * ox_over)
            cy = _bb_round(pixel_round, posy * oy_over)
        end
        cx = _bb_clamp(cx, 0, ox_over)
        cy = _bb_clamp(cy, 0, oy_over)
        result = scaled:crop(cx, cy, bw, bh)
        return result:copy({ interpretation = "srgb" })
    elseif fit == "contain" then
        -- Letterbox: compute placement inside frame
        local Lx = math.max(0, bw - sw)
        local Ly = math.max(0, bh - sh)
        local ox, oy
        if use_focal then
            local want_x = px * bw - fx * sw
            local want_y = py * bh - fy * sh
            ox = _bb_round(pixel_round, want_x)
            oy = _bb_round(pixel_round, want_y)
        else
            ox = _bb_round(pixel_round, posx * Lx)
            oy = _bb_round(pixel_round, posy * Ly)
        end
        ox = _bb_clamp(ox, 0, Lx)
        oy = _bb_clamp(oy, 0, Ly)
        if pad then
            result = scaled:embed(ox, oy, bw, bh, { extend = "background", background = bg })
        else
            -- Return the scaled image at its actual size (no letterbox)
            result = scaled
        end
        return result:copy({ interpretation = "srgb" })
    elseif fit == "scale-down" then
        -- Same as contain but with the s rule already applied above
        local Lx = math.max(0, bw - sw)
        local Ly = math.max(0, bh - sh)
        local ox = _bb_round(pixel_round, posx * Lx)
        local oy = _bb_round(pixel_round, posy * Ly)
        ox = _bb_clamp(ox, 0, Lx)
        oy = _bb_clamp(oy, 0, Ly)
        if pad then
            result = scaled:embed(ox, oy, bw, bh, { extend = "background", background = bg })
        else
            result = scaled
        end
        return result:copy({ interpretation = "srgb" })
    elseif fit == "none" then
        -- No scaling. Clip if larger than frame; pad if smaller.
        local tmp = scaled
        local cw = math.min(bw, sw)
        local ch = math.min(bh, sh)

        local ox_over = math.max(0, sw - bw)
        local oy_over = math.max(0, sh - bh)
        local cx = _bb_round(pixel_round, posx * ox_over)
        local cy = _bb_round(pixel_round, posy * oy_over)
        cx = _bb_clamp(cx, 0, ox_over)
        cy = _bb_clamp(cy, 0, oy_over)

        -- Crop if necessary
        if sw > bw or sh > bh then
            tmp = tmp:crop(cx, cy, cw, ch)
        end

        -- Pad only if requested and necessary
        if pad and (tmp:width() < bw or tmp:height() < bh) then
            local px2 = _bb_round(pixel_round, posx * (bw - tmp:width()))
            local py2 = _bb_round(pixel_round, posy * (bh - tmp:height()))
            result = tmp:embed(px2, py2, bw, bh, { extend = "background", background = bg })
        else
            result = tmp
        end
        return result:copy({ interpretation = "srgb" })
    end

    error("unreachable fit branch")
end

--- Place a pre-resized frame image onto the canvas at (x,y) with anchor.
--- Does not rescale the image.
---
--- Options (`opts`):
--- • canvas_anchor: { x: string|number, y: string|number }
---     Anchor inside the canvas.
---     Keywords: 'left'|'center'|'right' (x), 'top'|'middle'|'bottom' (y).
---     Or numeric 0..1 / percent string.
---
--- • x, y: numbers
---     Canvas coordinates of the anchor point (default 0,0).
---
--- • pixel_round: 'round'|'floor'|'ceil' (default 'round')
---
--- @param frameImg vips.Image  # output from resize()
--- @param opts table|nil
--- @return MixContextAdaptor
function M:place(img, opts)
    opts = opts or {}

    local anchor = opts.canvas_anchor or {}
    anchor.x = anchor.x or "left"
    anchor.y = anchor.y or "top"

    local pixel_round = (opts.pixel_round or "round"):lower()
    local x = _bb_round(pixel_round, tonumber(opts.x or 0))
    local y = _bb_round(pixel_round, tonumber(opts.y or 0))

    -- Place an image at (x,y) with anchor defined by align/valign; NO scaling.
    local src = img
    local sw, sh = src:width(), src:height()

    local ax = 0
    if anchor.x == "center" then
        ax = -math.floor(sw / 2)
    elseif anchor.x == "right" then
        ax = -sw
    end

    local ay = 0
    if anchor.y == "middle" then
        ay = -math.floor(sh / 2)
    elseif anchor.y == "bottom" then
        ay = -sh
    end

    x = (opts.x or 0) + ax
    y = (opts.y or 0) + ay

    self.ctx.canvas = self.ctx.canvas:composite2(src, "over", { x = x, y = y, premultiplied = false })

    return self
end

-- Convenience: full pipeline (fit into frame, then place frame on canvas)
function M:resizeAndPlace(img, opts)
    if type(img) == "string" then
        img = vips.Image.new_from_file(img, { access = "random" })
    end

    if opts and opts.flipH then
        img = img:fliphor()
    end
    if opts and opts.flipV then
        img = img:flipver()
    end
    if opts and opts.rotate then
        local r = tonumber(opts.rotate) or 0
        if r % 360 ~= 0 then
            -- libvips has rot90/rot180/rot270 for right angles; for arbitrary use similarity
            local rr = ((r % 360) + 360) % 360
            if rr == 90 then
                img = img:rot90()
            elseif rr == 180 then
                img = img:rot180()
            elseif rr == 270 then
                img = img:rot270()
            end
        end
    end

    local frameImg = self:resize(img, opts)
    return self:place(frameImg, opts)
end

function M:bg(color)
    -- Place a solid-colour layer BEHIND the current canvas.
    -- `color` is {r,g,b,a} with each in 0..1
    color = color or { 0, 0, 0, 0 }

    -- Ensure canvas is STRAIGHT RGBA, alpha last, tagged sRGB
    local canvas = ensureRGBA(self.ctx.canvas)
    local w, h = canvas:width(), canvas:height()

    -- Convert 0..1 floats to 0..255 uchar
    local r = _bb_round("round", (tonumber(color[1]) or 0) * 255)
    local g = _bb_round("round", (tonumber(color[2]) or 0) * 255)
    local b = _bb_round("round", (tonumber(color[3]) or 0) * 255)
    local a = _bb_round("round", (tonumber(color[4]) or 0) * 255)

    -- Build solid RGBA background of same size, tagged sRGB
    local rgb = vips.Image.black(w, h):new_from_image({ r, g, b }):copy({ interpretation = "srgb" })
    local alpha = vips.Image.black(w, h):new_from_image(a)
    local bg = rgb:bandjoin({ alpha })

    -- Composite: canvas OVER background -> background sits behind
    local out = bg:composite2(canvas, "over", { premultiplied = false })

    self.ctx.canvas = out
    return self
end

function M:clip(x, y, w, h)
    -- Crop the *contents* to a rectangle but KEEP the canvas size unchanged.
    -- Pixels outside the rectangle become transparent; pixels inside remain
    -- at their original coordinates. The rectangle is clipped to canvas bounds.

    local canvas = ensureRGBA(self.ctx.canvas)
    local cw, ch = canvas:width(), canvas:height()

    -- Defaults for missing width/height: from (x,y) to canvas edge
    if w == nil then
        w = cw - (tonumber(x) or 0)
    end
    if h == nil then
        h = ch - (tonumber(y) or 0)
    end

    -- Round to pixel grid
    local rx = _bb_round("round", tonumber(x) or 0)
    local ry = _bb_round("round", tonumber(y) or 0)
    local rw = _bb_round("round", tonumber(w) or 0)
    local rh = _bb_round("round", tonumber(h) or 0)

    -- Intersection with canvas
    local sx = math.max(0, rx)
    local sy = math.max(0, ry)
    local ex = math.min(cw, rx + rw)
    local ey = math.min(ch, ry + rh)

    local ow = math.max(0, ex - sx)
    local oh = math.max(0, ey - sy)

    if ow <= 0 or oh <= 0 then
        -- Entirely outside: return a fully transparent canvas of SAME size
        local rgb = vips.Image.black(cw, ch):new_from_image({ 0, 0, 0 }):copy({ interpretation = "srgb" })
        local alpha = vips.Image.black(cw, ch):new_from_image(0)
        self.ctx.canvas = rgb:bandjoin({ alpha })
        return self
    end

    -- Split RGB and A (straight alpha pipeline)
    local rgb = canvas:extract_band(0, { n = 3 }):copy({ interpretation = "srgb" })
    local oldA = canvas:extract_band(3)

    -- Build a full-size mask with 255 inside the rect and 0 outside
    local fullMask = oldA:new_from_image(0)
    local rectMask = vips.Image.black(ow, oh):new_from_image(255)
    fullMask = fullMask:insert(rectMask, sx, sy)

    -- New alpha = old alpha * mask
    local m = (fullMask:cast("float") / 255.0)
    local newA = (oldA:cast("float") * m):cast("uchar")

    -- Rejoin RGB with masked alpha; canvas size is unchanged
    self.ctx.canvas = rgb:bandjoin({ newA }):copy({ interpretation = "srgb" })
    return self
end

function M:raw()
    return self.ctx
end

return M
