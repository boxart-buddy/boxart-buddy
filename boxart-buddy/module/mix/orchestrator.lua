local vips = require("lib.vips")
local Ctx = require("module.mix.context")

---@class MixOrchestrator
local M = class({ name = "MixOrchestrator" })

function M:new(environment)
    self.environment = environment

    -- vips tuning (adjust after profiling on device)
    vips.concurrency_set(2)
    vips.cache_set_max(0) -- number of cached operations
    vips.cache_set_max_mem(64 * 1024 * 1024) -- ~64MB
    vips.cache_set_max_files(0) -- no cached temp files

    self.registry = {}
    self.pngWriteDefaults = { compression = 6, interlace = false, strip = true }

    return self
end

function M:register(name, ctor)
    self.registry[name] = ctor
end

--- Renders a strategy to a PNG.
-- @param name string strategy key registered via :register
-- @param media table<string,string> absolute file paths (you provide)
-- @param options table|nil strategy options (merged over defaults)
-- @param outPath string absolute output path
function M:render(name, media, platform, options, romOptions, outPath)
    local ctor = assert(self.registry[name], "unknown strategy: " .. tostring(name))
    local strategy = ctor(self.environment)

    -- canvas + options
    local canvas = self:makeCanvas(SCREEN.w, SCREEN.h)

    local ctx = Ctx({ canvas = canvas, media = media, platform = platform })

    -- render and save
    ctx = strategy:render(ctx, options, romOptions)
    ctx.canvas = ctx.canvas:unpremultiply()

    ctx.canvas:write_to_file(outPath, self.pngWriteDefaults)

    -- nuke refs
    ctx.canvas = nil
    ctx = nil
    strategy = nil

    -- force garbage collection aggressively
    collectgarbage("collect")
    -- vips.cache_set_max(0)
    -- vips.cache_set_max_mem(0)
    -- vips.cache_set_max_files(0)

    return outPath
end

function M.loadPng(path)
    -- Force image into sRGB on load
    return vips.Image.new_from_file(path, { access = "random" }):colourspace("srgb")
end

function M:makeCanvas(w, h)
    local base = vips.Image.black(w, h):cast("uchar")
    local rgb = base:new_from_image({ 0, 0, 0 }):copy({ interpretation = "srgb" })
    local a = base:new_from_image(0)
    local rgba = rgb:bandjoin({ a })
    return rgba
end
return M
