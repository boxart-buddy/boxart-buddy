local colors = require("util.colors")

---@class Toaster
local M = class({
    name = "Toaster",
})

-- configurable drawing constants
local PADDING_X = SCREEN.wUnit(0.7)
local PADDING_Y = SCREEN.hUnit(1)
local GAP = SCREEN.hUnit(1)
local RADIUS = 2
local RIGHT_MARGIN = SCREEN.wUnit(0.6)
local BOTTOM_MARGIN = SCREEN.hUnit(1.2)
local FONT = ASSETS.font.inter.medium(FONTSIZE.m)

-- Utility: color with alpha multiplier (preserve original theme colors)
local function applyAlpha(c, a)
    return c[1], c[2], c[3], (c[4] or 1) * a
end

function M:new(flux)
    self.flux = flux
    self.tweenTime = 0.5
    self.duration = 6
    self.theme = {
        error = {
            background = colors.toastErrorBg,
            border = colors.toastErrorBorder,
            text = colors.white,
        },
        success = {
            background = colors.toastSuccessBg,
            border = colors.toastSuccessBorder,
            text = colors.white,
        },
        info = { -- reasonable extra type
            background = colors.toastInfoBg or { 0.12, 0.12, 0.12, 1 },
            border = colors.toastInfoBorder or { 0.3, 0.3, 0.3, 1 },
            text = colors.white,
        },
    }

    self.toasts = {}
end

-- Internal: compute width/height for a message
function M:_measure(message)
    local font = FONT
    local maxW = math.floor((SCREEN and SCREEN.w or love.graphics.getWidth()) * 0.5)
    -- start with a sane base width and wrap
    local textW = maxW - (PADDING_X * 2)
    local _, lines = font:getWrap(message, textW)
    local lineH = font:getHeight()
    local h = #lines * lineH + PADDING_Y * 2
    local w = maxW -- we keep a consistent width for alignment; could also shrink-to-fit
    return w, h
end

-- Internal: recompute target Y positions for stack and animate items to their slots.
function M:_layoutAndAnimate()
    local screenW = (SCREEN and SCREEN.w) or love.graphics.getWidth()
    local screenH = (SCREEN and SCREEN.h) or love.graphics.getHeight()

    local y = screenH - BOTTOM_MARGIN
    for i = #self.toasts, 1, -1 do
        local t = self.toasts[i]
        y = y - t.h -- top edge of this toast
        local targetX = screenW - RIGHT_MARGIN - t.w
        local targetY = y
        -- animate only if target changed noticeably
        if
            not t.animatingTo
            or math.abs(t.animatingTo.x - targetX) > 0.5
            or math.abs(t.animatingTo.y - targetY) > 0.5
        then
            if t.posTween then
                t.posTween:stop()
            end
            t.animatingTo = { x = targetX, y = targetY }
            t.posTween = self.flux.to(t, self.tweenTime, { x = targetX, y = targetY }):ease("quartout")
        end
        y = y - GAP
    end
end

-- Public: create a toast
function M:create(message, typ)
    typ = typ or "info"
    local w, h = self:_measure(message)

    local toast = {
        message = message,
        typ = typ,
        w = w,
        h = h,
        x = SCREEN.w + SCREEN.hUnit(5), -- start off-screen to the right so it slides in from bottom-right
        y = SCREEN.h + SCREEN.hUnit(5), -- off-screen bottom
        alpha = 0,
        life = self.duration,
        removing = false,
        posTween = nil,
        fadeTween = nil,
        animatingTo = nil,
    }

    table.insert(self.toasts, toast)

    -- Fade/slide in for the new toast; position target set by layout call
    if toast.fadeTween then
        toast.fadeTween:stop()
    end
    toast.fadeTween = self.flux.to(toast, self.tweenTime, { alpha = 1 }):ease("quadout")

    -- First layout to set targets for all toasts (including existing ones moving up)
    self:_layoutAndAnimate()

    return toast
end

-- Internal: begin removal animation for a toast (fade out then delete)
function M:_dismiss(toast)
    if toast.removing then
        return
    end
    toast.removing = true
    -- optional slight downward nudge on exit
    if toast.posTween then
        toast.posTween:stop()
    end
    toast.posTween = self.flux.to(toast, self.tweenTime * 0.6, { y = toast.y + 10 }):ease("quadout")
    if toast.fadeTween then
        toast.fadeTween:stop()
    end
    toast.fadeTween = self.flux.to(toast, self.tweenTime * 0.6, { alpha = 0 }):ease("quadout"):oncomplete(function()
        -- remove from array
        for i = #self.toasts, 1, -1 do
            if self.toasts[i] == toast then
                table.remove(self.toasts, i)
                break
            end
        end
        -- reflow remaining toasts
        self:_layoutAndAnimate()
    end)
end

function M:update(dt)
    -- countdown and dismiss when time's up
    for i = #self.toasts, 1, -1 do
        local t = self.toasts[i]
        if not t.removing then
            t.life = t.life - dt
            if t.life <= 0 then
                self:_dismiss(t)
            end
        end
    end
end

function M:draw()
    if #self.toasts == 0 then
        return
    end

    local lg = love.graphics
    lg.push("all")

    for i = 1, #self.toasts do
        local t = self.toasts[i]
        local theme = self.theme[t.typ] or self.theme.info

        -- background
        local br, bg, bb, ba = applyAlpha(theme.background, t.alpha)
        lg.setColor(br, bg, bb, ba)
        lg.rectangle("fill", t.x, t.y, t.w, t.h, RADIUS, RADIUS)

        -- border
        local rr, rg, rb, ra = applyAlpha(theme.border, t.alpha)
        lg.setColor(rr, rg, rb, ra)
        lg.setLineWidth(1)
        lg.rectangle("line", t.x, t.y, t.w, t.h, RADIUS, RADIUS)

        -- text
        local tr, tg, tb, ta = applyAlpha(theme.text, t.alpha)
        lg.setColor(tr, tg, tb, ta)
        lg.setFont(FONT)
        local textX = t.x + PADDING_X
        local textY = t.y + PADDING_Y
        local textW = t.w - (PADDING_X * 2)
        lg.printf(t.message, textX, textY, textW, "center")
    end

    lg.pop()
end

-- Optional helper to force-dismiss all toasts (e.g., on scene change)
function M:clear()
    for i = #self.toasts, 1, -1 do
        self:_dismiss(self.toasts[i])
    end
end

return M
