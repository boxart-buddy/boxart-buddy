---@class MixStrategyAbstract
local M = class({ name = "MixStrategyAbstract" })

function M:new(mixAssetPath)
    self.mixAssetPath = mixAssetPath
    return self
end

function M:mediaRequired()
    error("implement assetsRequired()")
end

--- @param ctx MixContext
--- @return MixContext  -- RGBA 640x480
function M:render(ctx)
    error("implement render()")
end

return M
