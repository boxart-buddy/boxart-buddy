local utf8 = require("utf8")
local colors = require("util.colors")

---@class WidgetNumpad
local M = class({ name = "WidgetNumpad", extends = require("gui.widget.base") })

-- ---------- Helpers ----------
local function deletePrevRune(s, i)
    if i <= 1 then
        return s, 1
    end
    local p = utf8.offset(s, -1, i) or 1
    return s:sub(1, p - 1) .. s:sub(i), p
end

local function runeLen(s)
    return utf8.len(s) or 0
end

-- ---------- Layout ----------
local ROWS = {
    { "1", "2", "3" },
    { "4", "5", "6" },
    { "7", "8", "9" },
    { "", "0", "" }, -- blanks either side of 0
}

-- ---------- Constructor ----------
function M:new(systemeventsubscriber, canvas, value, options)
    value = value or ""
    self.systemeventsubscriber = systemeventsubscriber
    options = options or {}
    -- init base
    self:super(canvas, value, self:_extractBaseOptions(options))

    self.maxLength = options.maxLength or 32

    --CARET
    self.caretVisible = true
    self.caretBlinkTimer = 0
    self.caretBlinkPeriod = 0.5

    -- FONT
    self.inlineFont = options.font or ASSETS.font.inter.medium(FONTSIZE.s)
    self.keycapFont = options.keycapFont or ASSETS.font.montserrat.bold(22)
    self.typedTextFont = options.typedTextFont or ASSETS.font.inter.bold(22)

    self.colors = table.shallow_overlay({
        label = colors.offWhite,
        highlight = colors.activeUI,
        modal = colors.modalCover,
        kbBackdrop = colors.black,
        keycapFill = colors.offWhite,
        active = { 0.25, 0.85, 1, 1 },
        text = colors.offWhite,
        glyph = colors.black,
        typedText = colors.white,
        caret = colors.red,
    }, options.colors or {})

    -- INTERNAL STATE
    self.initialValue = tostring(self.value or "")
    self.caret = #tostring(self.value) + 1
    self.open = false

    self.rows = ROWS
    self.cols = 3
    self.rowsCount = 4
    self.selRow = 1
    self.selCol = 1
end

-- ---------- Update ----------
function M:update(dt)
    if not self.open then
        self.caretVisible = true
        self.caretBlinkTimer = 0
        return
    end
    self.caretBlinkTimer = self.caretBlinkTimer + dt
    if self.caretBlinkTimer >= self.caretBlinkPeriod then
        self.caretBlinkTimer = self.caretBlinkTimer - self.caretBlinkPeriod
        self.caretVisible = not self.caretVisible
    end
end

-- ---------- Rendering ----------
function M:draw(active)
    local lg = love.graphics
    lg.setCanvas(self.canvas)

    -- When closed, draw inline value only (no modal, no grid)
    if not self.open then
        love.graphics.push("all")
        love.graphics.translate(self.x, self.y)
        self:_drawBase(active)

        lg.setFont(self.inlineFont)
        lg.setColor(self.colors.text)
        -- obfuscate text value if requested
        local inlineValue = self.obfuscate and stringUtil.obfuscate(self.value) or self.value
        if inlineValue then
            lg.print(inlineValue, self.inputX, self:_vAlignCentre(self.inlineFont:getHeight(inlineValue)))
        end

        lg.pop()
        return
    end

    local ww, wh = lg.getDimensions()
    local textH = math.floor(wh * 0.25)
    local bottomGap = 100
    local kbH = wh - textH - bottomGap
    local kbY = textH

    lg.setColor(self.colors.modal)
    lg.rectangle("fill", 0, 0, ww, wh)

    lg.setColor(self.colors.kbBackdrop)
    lg.rectangle("fill", 0, kbY, ww, kbH)

    local margin = math.floor(math.min(ww, wh) * 0.025)
    local kbX = margin
    local kbW = ww - margin * 2
    local kbHInner = kbH - margin

    local cols, rows = self.cols, self.rows
    local gutter = math.max(2, math.floor(kbW * 0.008))
    local keySizeW = math.floor((kbW - gutter * (cols + 1)) / cols)
    local keySizeH = math.floor((kbHInner - gutter * (self.rowsCount + 1)) / self.rowsCount)
    local keySize = math.min(keySizeW, keySizeH)

    local usedW = keySize * cols + gutter * (cols + 1)
    local usedH = keySize * self.rowsCount + gutter * (self.rowsCount + 1)
    local originX = kbX + math.floor((kbW - usedW) / 2)
    local originY = kbY + math.floor((kbHInner - usedH) / 2)

    -- typed text + caret
    lg.push("all")
    lg.setFont(self.typedTextFont)
    local textW = self.typedTextFont:getWidth(self.value)
    local textX = math.floor((ww - textW) / 2)
    local textY = math.floor(textH / 2 - self.typedTextFont:getHeight() / 2)
    lg.setColor(self.colors.typedText)
    lg.print(self.value, textX, textY)
    local pre = tostring(self.value):sub(1, self.caret - 1)
    local preW = self.typedTextFont:getWidth(pre)
    local caretX = textX + preW
    local caretY = textY
    local caretH = self.typedTextFont:getHeight()
    if self.caretVisible then
        lg.setColor(self.colors.caret)
        lg.setLineWidth(2)
        lg.line(caretX, caretY, caretX, caretY + caretH)
    end
    lg.pop()

    -- draw keys
    for r = 1, self.rowsCount do
        for c = 1, cols do
            local ch = rows[r][c]
            local x = originX + gutter + (c - 1) * (keySize + gutter)
            local y = originY + gutter + (r - 1) * (keySize + gutter)
            if r == self.selRow and c == self.selCol then
                lg.setColor(self.colors.active)
            else
                lg.setColor(self.colors.keycapFill)
            end
            lg.rectangle("fill", x, y, keySize, keySize, 6, 6)
            if ch ~= "" then
                lg.push("all")
                lg.setFont(self.keycapFont)
                lg.setColor(self.colors.glyph)
                local gh = self.keycapFont:getHeight()
                lg.printf(ch, x, y + (keySize - gh) / 2, keySize, "center")
                lg.pop()
            end
        end
    end
end

-- ---------- Input ----------
function M:handleInput(input)
    if not self.open then
        if input == "confirm" then
            self.open = true
            self.systemeventsubscriber:publish("numpad_opened")
        end
        return self.value
    end

    -- move selection
    if input == "left" then
        self.selCol = ((self.selCol - 2) % self.cols) + 1
        return self.value
    elseif input == "right" then
        self.selCol = (self.selCol % self.cols) + 1
        return self.value
    elseif input == "up" then
        self.selRow = ((self.selRow - 2) % self.rowsCount) + 1
        return self.value
    elseif input == "down" then
        self.selRow = (self.selRow % self.rowsCount) + 1
        return self.value
    end

    -- caret movement
    if input == "nav_left" then
        if self.caret > 1 then
            self.caret = self.caret - 1
        end
        return self.value
    elseif input == "nav_right" then
        if self.caret < #self.value then
            self.caret = self.caret + 1
        end
        return self.value
    end

    -- type key
    if input == "confirm" then
        local ch = self.rows[self.selRow][self.selCol]
        if (runeLen(self.value) < self.maxLength) and ch and ch ~= "" then
            local left = tostring(self.value):sub(1, self.caret - 1)
            local right = tostring(self.value):sub(self.caret)
            self.value = left .. ch .. right
            self.caret = self.caret + #ch
        end
        return self.value
    end

    -- backspace
    if input == "cancel" then
        self.value, self.caret = deletePrevRune(self.value, self.caret)
        return self.value
    end

    -- clear
    if input == "secondary" then
        self.value = ""
        self.caret = 1
        return self.value
    end

    -- commit
    if input == "start" then
        self.open = false
        self.systemeventsubscriber:publish("numpad_closed")
        return self.value
    end

    -- cancel/discard
    if input == "select" then
        self.value = self.initialValue
        self.caret = #self.value + 1
        self.open = false
        self.systemeventsubscriber:publish("numpad_closed")
        return self.value
    end
end

return M
