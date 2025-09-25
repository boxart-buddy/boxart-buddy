local colors = require("util.colors")

---@class Confirm
local M = class({ name = "Confirm" })

function M:new(systemeventsubscriber, options)
    options = options or {}

    self.systemeventsubscriber = systemeventsubscriber
    -- init base
    self.font = options.font or ASSETS.font.inter.medium(FONTSIZE.l)
    self.buttonFont = options.font or ASSETS.font.inter.medium(FONTSIZE.m)
    self.buttonWidth = options.buttonWidth or SCREEN.w / 4
    self.buttonHeight = options.buttonWidth or SCREEN.hUnit(6)
    self.message = options.message or "Do you confirm?"

    self.onConfirm = options.onConfirm or nil
    self.onCancel = options.onCancel or nil

    self.selection = "cancel"

    self.colors = table.shallow_overlay(options.colors or {
        messageText = colors.offWhite,
        confirmBg = colors.green,
        confirmText = colors.offWhite,
        confirmBorder = colors.green,
        cancelBg = colors.blue,
        cancelText = colors.offWhite,
        cancelBorder = colors.blue,
        highlightBorder = colors.red,
    }, options.colors or {})

    -- internal state
    self.isOpen = false
end

function M:open()
    self.isOpen = true
end

function M:close()
    self.isOpen = false
end

function M:handleInput(input)
    if not self.isOpen then
        return
    end
    if input == "left" then
        self.selection = "cancel"
    elseif input == "right" then
        self.selection = "confirm"
    elseif input == "confirm" then
        if self.selection == "cancel" then
            if type(self.onCancel) == "function" then
                self.onCancel()
            end
            self:close()
        elseif self.selection == "confirm" then
            if type(self.onConfirm) == "function" then
                self.onConfirm()
            end
            self:close()
        end
    elseif input == "cancel" then
        self.selection = "cancel"
        self:close()
    end
end

function M:draw()
    -- Only draw when open
    if not self.isOpen then
        return
    end

    local lg = love.graphics
    lg.push("all")
    lg.setCanvas()

    local sw, sh = SCREEN.w, SCREEN.h

    -- --- Modal veil ---
    local veil = colors.modalCover or { 0, 0, 0, 0.55 }
    lg.setColor(veil)
    lg.rectangle("fill", 0, 0, sw, sh)

    -- --- Layout ---
    local bw = self.buttonWidth
    local bh = self.buttonHeight
    local gap = math.max(16, math.floor(sw * 0.02))
    local cx = math.floor(sw / 2)
    local cy = math.floor(sh / 2)

    local cancelX = cx - gap / 2 - bw
    local confirmX = cx + gap / 2
    local y = cy - math.floor(bh / 2)
    local radius = 4

    -- --- Message text ---
    lg.setFont(self.font)
    lg.setColor(self.colors.messageText)
    local msgW = self.font:getWidth(self.message)
    local msgH = self.font:getHeight()
    local msgX = math.floor((sw - msgW) / 2)
    local msgY = y - msgH - gap
    lg.print(self.message, msgX, msgY)

    -- Helper to draw one button
    local function drawButton(x, y, w, h, bg, border, highlightBorder, textColor, label, selected)
        -- background
        lg.setColor(bg)
        lg.rectangle("fill", x, y, w, h, radius, radius)
        -- border (thicker if selected)
        lg.setLineWidth(selected and 3 or 1)
        lg.setColor(border)
        lg.rectangle("line", x, y, w, h, radius, radius)
        -- subtle focus glow if selected
        if selected then
            lg.setColor(highlightBorder)
            lg.rectangle("line", x - 2, y - 2, w + 4, h + 4, radius + 2, radius + 2)
        end
        -- label
        lg.setFont(self.buttonFont)
        lg.setColor(textColor)
        lg.printf(label, x, y + (h - self.buttonFont:getHeight()) / 2, w, "center")
    end

    -- --- Cancel button (left) ---
    local cancelSelected = (self.selection == "cancel")
    drawButton(
        cancelX,
        y,
        bw,
        bh,
        self.colors.cancelBg,
        self.colors.cancelBorder,
        self.colors.highlightBorder,
        self.colors.cancelText,
        "CANCEL",
        cancelSelected
    )

    -- --- Confirm button (right) ---
    local confirmSelected = (self.selection == "confirm")
    drawButton(
        confirmX,
        y,
        bw,
        bh,
        self.colors.confirmBg,
        self.colors.confirmBorder,
        self.colors.highlightBorder,
        self.colors.confirmText,
        "CONFIRM",
        confirmSelected
    )

    lg.pop()
end
return M
