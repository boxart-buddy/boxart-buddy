local ContextAdaptor = require("module.mix.context_adaptor")
local path = require("util.path")
local colors = require("util.colors")
local stringUtil = require("util.string")
local filesystem = require("lib.nativefs")
local layout = require("util.layout")

---@class AdvancedMixStrategy
local M = class({ name = "AdvancedMixStrategy", implements = { require("module.mix.strategy.abstract") } })

function M:new(environment)
    self.environment = environment

    self.mixAssetPath = self.environment:getPath("mix_asset")
    return self
end

function M:_processBackgroundOptions(options, ctxAdaptor)
    local options = options or {}
    local output = {}

    -- HEADER/FOOTER
    if options.header_footer then
        output.header = self.environment:getConfig("mix_header_y") or 42
        output.footer = self.environment:getConfig("mix_footer_y") or 42
    else
        output.header = 0
        output.footer = 0
    end

    -- BACKGROUND COLOR
    if options.bg_color ~= "transparent" then
        if options.bg_color == "custom" then
            local customColor = colors.hexToRGB(self.environment:getConfig("mix_custom_bg_hex"))
            table.insert(customColor, 1) -- alpha 1, could make it configurable if needed in future
            output.bg_color = customColor
        else
            output.bg_color = colors[options.bg_color]
        end
    end

    -- layout helpers
    local header = output.header
    local footer = output.footer
    local trimY = header + footer
    local wDiv = layout:divider(SCREEN.w)
    local hDiv = layout:divider(SCREEN.h - trimY)

    -- SCREENSHOT
    if options.screenshot ~= "none" and options.screenshot ~= nil then
        local positionMap = {
            regular = {
                ["full"] = { x = wDiv(1, 2), y = hDiv(1, 2) + header },
                ["1/2"] = { x = wDiv(3, 4), y = hDiv(1, 2) + header },
                ["3/4"] = { x = wDiv(5, 8), y = hDiv(1, 2) + header },
                ["3/5"] = { x = wDiv(7, 10), y = hDiv(1, 2) + header },
                ["top_1/4"] = { x = wDiv(3, 4), y = hDiv(1, 4) + header },
                ["middle_1/4"] = { x = wDiv(3, 4), y = hDiv(1, 2) + header },
                ["bottom_1/4"] = { x = wDiv(3, 4), y = hDiv(3, 4) + header },
            },
            flipped = {
                ["full"] = { x = wDiv(1, 2), y = hDiv(1, 2) + header },
                ["1/2"] = { x = wDiv(1, 4), y = hDiv(1, 2) + header },
                ["3/4"] = { x = wDiv(3, 8), y = hDiv(1, 2) + header },
                ["3/5"] = { x = wDiv(3, 10), y = hDiv(1, 2) + header },
                ["top_1/4"] = { x = wDiv(1, 4), y = hDiv(1, 4) + header },
                ["middle_1/4"] = { x = wDiv(1, 4), y = hDiv(1, 2) + header },
                ["bottom_1/4"] = { x = wDiv(1, 4), y = hDiv(3, 4) + header },
            },
        }

        local sizeMap = {
            ["full"] = { w = wDiv(1, 1), h = hDiv(1, 1) },
            ["1/2"] = { w = wDiv(1, 2), h = hDiv(1, 1) },
            ["3/4"] = { w = wDiv(3, 4), h = hDiv(1, 1) },
            ["3/5"] = { w = wDiv(3, 5), h = hDiv(1, 1) },
            ["top_1/4"] = { w = wDiv(1, 2), h = hDiv(1, 2) },
            ["middle_1/4"] = { w = wDiv(1, 2), h = hDiv(1, 2) },
            ["bottom_1/4"] = { w = wDiv(1, 2), h = hDiv(1, 2) },
        }

        local positionType = "regular"
        if options.flip_h == true then
            positionType = "flipped"
        end

        local screenshotMedia = ctxAdaptor:getMedia("screenshot")
        if screenshotMedia then
            output.screenshot = {
                image = screenshotMedia,
                opacity = options.opacity,
                size = sizeMap[options.screenshot],
                position = positionMap[positionType][options.screenshot],
                anchor = { x = "center", y = "middle" },
            }
        end

        -- MASK
        if options.mask ~= "none" then
            local maskPath = path.join({
                self.mixAssetPath,
                "mask",
                string.format("%s-%s-%s.png", stringUtil.filenameSafe(options.mask), SCREEN.w, SCREEN.h),
            })
            local maskExists = filesystem.getInfo(maskPath)
            -- fallback to the 640x480 version
            if not maskExists then
                maskPath = path.join({
                    self.mixAssetPath,
                    "mask",
                    string.format("%s-%s-%s.png", stringUtil.filenameSafe(options.mask), "640", "480"),
                })
                maskExists = filesystem.getInfo(maskPath)
            end
            if maskExists then
                output.mask = {
                    image = maskPath,
                    size = { w = SCREEN.w, h = SCREEN.h }, -- mask is designed for full screen so don't resize
                    position = { x = SCREEN.w / 2, y = SCREEN.h / 2 },
                    anchor = { x = "center", y = "middle" },
                    flipped = options.flip_h,
                }

                -- if options.screenshot == "brush_deboss" or options.screenshot == "brush_emboss" then
                --     output.mask.overlay = path.join({ self.mixAssetPath, "overlay", options.mask .. ".png" })
                -- end
            end
        end
    end

    return output
end

function M:_processInsertOptions(options, romOptions, ctxAdaptor, header, footer)
    local options = options or {}
    local romOptions = romOptions or {}
    local output = {}

    -- MEDIA TYPE
    local platformFolders = {
        platform_white = "light_white",
        platform_color = "light_color",
        platform_alt = "alt_white",
        platform_retro = "retro",
    }
    if options.media_type == "none" then
        return nil
        -- INSERT PLATFORM LOGO
    elseif table.contains(table.keys(platformFolders), options.media_type) then
        local platformImagePath = path.join({
            self.mixAssetPath,
            "platform",
            "large",
            platformFolders[options.media_type],
            ctxAdaptor.ctx.platform .. ".png",
        })
        local platformImageExists = filesystem.getInfo(platformImagePath)
        -- no platform image
        if not platformImageExists then
            return nil
        end
        -- pass the path, is resolved to libvips image in adaptor later
        output.media = platformImagePath
    else
        -- INSERT MEDIA
        if not ctxAdaptor:hasMedia(options.media_type) then
            return nil
        end
        output.media = ctxAdaptor:getMedia(options.media_type)
    end

    -- STROKE COLOR (romOptions can obliterate & nil chosen strokeColor with "remove")
    if options.stroke_color ~= "none" and romOptions.mix_stroke_color ~= "remove" then
        output.stroke_color = colors[options.stroke_color]
    end

    -- LAYOUT
    local trimY = header + footer
    local wDiv = layout:divider(SCREEN.w)
    local hDiv = layout:divider(SCREEN.h - trimY)

    -- SIZE
    local sizeTweak = options.size_adjust or 0
    local sizeMap = {
        proportional = {
            xs = { w = wDiv(8 + sizeTweak, 100), h = hDiv(8 + sizeTweak, 100) },
            s = { w = wDiv(14 + sizeTweak, 100), h = hDiv(14 + sizeTweak, 100) },
            m = { w = wDiv(20 + sizeTweak, 100), h = hDiv(20 + sizeTweak, 100) },
            l = { w = wDiv(35 + sizeTweak, 100), h = hDiv(35 + sizeTweak, 100) },
            xl = { w = wDiv(50 + sizeTweak, 100), h = hDiv(50 + sizeTweak, 100) },
            xxl = { w = wDiv(100 + sizeTweak, 100), h = hDiv(100 + sizeTweak, 100) },
        },
        square = {
            xs = { w = hDiv(8 + sizeTweak, 100), h = hDiv(8 + sizeTweak, 100) },
            s = { w = hDiv(14 + sizeTweak, 100), h = hDiv(14 + sizeTweak, 100) },
            m = { w = hDiv(20 + sizeTweak, 100), h = hDiv(20 + sizeTweak, 100) },
            l = { w = hDiv(35 + sizeTweak, 100), h = hDiv(35 + sizeTweak, 100) },
            xl = { w = hDiv(50 + sizeTweak, 100), h = hDiv(50 + sizeTweak, 100) },
            xxl = { w = hDiv(100 + sizeTweak, 100), h = hDiv(100 + sizeTweak, 100) },
        },
    }
    output.size = sizeMap[options.size_ratio][options.size]
    output.fit = options.fit

    local positionMap = {
        inner = {
            top_left = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(1, 4), y = hDiv(1, 4) + header },
            },
            top_centre = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(2, 4), y = hDiv(1, 4) + header },
            },
            top_right = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(3, 4), y = hDiv(1, 4) + header },
            },
            middle_left = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(1, 4), y = hDiv(1, 2) + header },
            },
            middle_centre = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(2, 4), y = hDiv(1, 2) + header },
            },
            middle_right = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(3, 4), y = hDiv(1, 2) + header },
            },
            bottom_left = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(1, 4), y = hDiv(3, 4) + header },
            },
            bottom_centre = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(2, 4), y = hDiv(3, 4) + header },
            },
            bottom_right = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(3, 4), y = hDiv(3, 4) + header },
            },
        },
        edge = {
            top_left = {
                anchor = { x = "left", y = "top" },
                position = { x = 0, y = header },
            },
            top_centre = {
                anchor = { x = "center", y = "top" },
                position = { x = wDiv(1, 2), y = header },
            },
            top_right = {
                anchor = { x = "right", y = "top" },
                position = { x = wDiv(1, 1), y = header },
            },
            middle_left = {
                anchor = { x = "left", y = "middle" },
                position = { x = 0, y = hDiv(1, 2) + header },
            },
            middle_centre = {
                anchor = { x = "center", y = "middle" },
                position = { x = wDiv(1, 2), y = hDiv(1, 2) + header },
            },
            middle_right = {
                anchor = { x = "right", y = "middle" },
                position = { x = wDiv(1, 1), y = hDiv(1, 2) + header },
            },
            bottom_left = {
                anchor = { x = "left", y = "bottom" },
                position = { x = 0, y = hDiv(1, 1) + header },
            },
            bottom_centre = {
                anchor = { x = "center", y = "bottom" },
                position = { x = wDiv(1, 2), y = hDiv(1, 1) + header },
            },
            bottom_right = {
                anchor = { x = "right", y = "bottom" },
                position = { x = wDiv(1, 1), y = hDiv(1, 1) + header },
            },
        },
    }
    -- OFFSET X
    output.offset_x = 0
    if options.offset_x and options.offset_x ~= 0 then
        output.offset_x = math.floor((wDiv(1, 1) / 100) * options.offset_x)
    end

    -- OFFSET Y
    output.offset_y = 0
    if options.offset_y and options.offset_y ~= 0 then
        output.offset_y = math.floor((hDiv(1, 1) / 100) * options.offset_y)
    end

    -- POSITION & ANCHOR
    output.anchor = positionMap[options.anchor][options.position].anchor
    output.position = positionMap[options.anchor][options.position].position

    -- ZINDEX
    output.z_index = options.z_index

    return output
end

--- @param ctx MixContext
--- @return MixContext
function M:render(ctx, options, romOptions)
    options = options or {}

    local c = ContextAdaptor(ctx)

    -- BACKGROUND / SCREENSHOT / MASK
    local background = self:_processBackgroundOptions(options.background, c)

    -- INSERTS (    -- Sort by Z-index)
    local inserts = table.compact({
        self:_processInsertOptions(options.insert_1, romOptions, c, background.header, background.footer),
        self:_processInsertOptions(options.insert_2, romOptions, c, background.header, background.footer),
        self:_processInsertOptions(options.insert_3, romOptions, c, background.header, background.footer),
        self:_processInsertOptions(options.insert_4, romOptions, c, background.header, background.footer),
    }, 4)

    table.sort(inserts, function(a, b)
        if a == nil then
            return true
        end
        if b == nil then
            return false
        end
        return (a.z_index or 0) < (b.z_index or 0)
    end)

    -- RENDER SCREENSHOT/MASK
    if background.screenshot then
        c:resizeAndPlace(background.screenshot.image, {
            x = background.screenshot.position.x,
            y = background.screenshot.position.y,
            frame = background.screenshot.size,
            fit = "cover",
            canvas_anchor = background.screenshot.anchor,
        })
        if background.screenshot.opacity < 100 then
            c:opacity(background.screenshot.opacity / 100)
        end
    end
    if background.mask then
        c:alphaMask(background.mask.image, {
            x = background.mask.position.x,
            y = background.mask.position.y,
            frame = background.mask.size,
            flipH = background.mask.flipped,
            fit = "fill",
            canvas_anchor = background.mask.anchor,
        })
        if background.mask.overlay then
            c:resizeAndPlace(background.mask.overlay, {
                x = background.mask.position.x,
                y = background.mask.position.y,
                frame = background.mask.size,
                flipH = background.mask.flipped,
                fit = "fill",
                canvas_anchor = background.screenshot.anchor,
            })
        end
    end

    -- RENDER INSERTS
    for _, insert in ipairs(inserts) do
        --SIZE
        local ins = c:resize(insert.media, { frame = insert.size, fit = insert.fit, pad = false })

        -- STROKE
        if insert.stroke_color then
            ins = c:withStroke(ins, {
                width = 6,
                color = insert.stroke_color,
                opacity = 1,
                outside_only = true,
            })
        end

        -- PLACE
        c:place(ins, {
            x = insert.position.x + insert.offset_x,
            y = insert.position.y + insert.offset_y,
            canvas_anchor = insert.anchor,
        })
    end

    -- background
    if background.bg_color then
        c:bg(background.bg_color)
    else
        c:premultiply()
    end

    return c:raw()
end

return M
