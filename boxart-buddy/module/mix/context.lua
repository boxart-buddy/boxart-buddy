---@class MixContext
---@field canvas vips.Image
---@field media table<string, vips.Image>
local M = class({ name = "MixContext" })

function M:new(args)
    self.canvas = assert(args.canvas, "canvas required")
    self.media = args.media or {}
    self.platform = args.platform or nil
    return self
end

function M:withCanvas(newCanvas)
    self.canvas = newCanvas
    return self
end

function M:hasMedia(typ)
    if self.media[typ] then
        return true
    end
    return false
end

return M
