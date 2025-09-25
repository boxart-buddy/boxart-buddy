local utf8 = require("utf8")
local colors = require("util.colors")
local stringUtil = require("util.string")

---@class WidgetKeyboard
local M = class({ name = "WidgetKeyboard", extends = require("gui.widget.base") })

-- ---------- Helpers ----------
local function prevByteIndex(s, i)
    if i <= 1 then
        return 1
    end
    return utf8.offset(s, -1, i) or 1
end

local function nextByteIndex(s, i)
    if i > #s then
        return #s + 1
    end
    -- advance to the next codepoint; start searching after i
    local n = utf8.offset(s, 1, i + 1)
    return n or (#s + 1)
end

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

-- Fixed 12x4 grids
local LOWER_ROWS = {
    { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l" },
    { "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x" },
    { "y", "z", " ", ".", ",", "-", "_", "@", "/", ";", ":", "+" },
    { "#", "'", '"', "(", ")", "[", "]", "{", "}", "?", "!", "=" },
}
local UPPER_ROWS = {
    { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L" },
    { "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X" },
    { "Y", "Z", " ", ".", ",", "-", "_", "@", "/", ";", ":", "+" },
    { "#", "'", '"', "(", ")", "[", "]", "{", "}", "?", "!", "=" },
}
local SYMBOL_ROWS = {
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "_" },
    { "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "[", "]" },
    { "{", "}", ";", ":", "'", '"', ",", ".", "/", "\\", "+", "=" },
    { "<", ">", "?", "`", "~", " ", "£", "€", "|", "¥", "¢", "°" },
}
local MODES = { "lower", "upper", "symbols" }
local function gridFor(mode)
    if mode == "lower" then
        return LOWER_ROWS
    elseif mode == "upper" then
        return UPPER_ROWS
    else
        return SYMBOL_ROWS
    end
end

-- ---------- Constructor ----------
-- options: offsetX (inline X), offsetY (inline Y), keycapFont (modal keyboard), font (inline string), colors, maxLength
function M:new(systemeventsubscriber, canvas, value, options)
    self.systemeventsubscriber = systemeventsubscriber
    options = options or {}
    -- init base
    self:super(canvas, value, self:_extractBaseOptions(options))

    -- DISPLAY
    self.obfuscate = options.obfuscate or false

    -- VALIDATION
    self.maxLength = options.maxLength or 128
    self.allowEmpty = (options.allowEmpty == nil) and true or options.allowEmpty
    self.validate = options.validate or nil

    -- FONTS
    self.inlineFont = options.font or ASSETS.font.inter.medium(FONTSIZE.s)
    self.keycapFont = options.keycapFont or ASSETS.font.montserrat.regular(FONTSIZE.xl)
    self.typedTextFont = options.typedTextFont or ASSETS.font.inter.medium(FONTSIZE.xl)

    -- CARET
    self.caretVisible = true
    self.caretBlinkTimer = 0
    self.caretBlinkPeriod = 0.5 -- seconds

    -- COLORS
    self.colors = table.shallow_overlay({
        label = colors.offWhite,
        highlight = colors.activeUI,
        modal = colors.modalCover, -- full-screen modal veil (semi-transparent)
        kbBackdrop = colors.black, -- solid black behind keyboard only
        keycapFill = colors.offWhite, -- key background fill (idle)
        active = { 0.25, 0.85, 1, 1 }, -- key background fill (selected)
        text = colors.offWhite, -- glyph on keycap
        glyph = colors.black, -- glyph on keycap
        typedText = colors.white, -- typed text color
        caret = colors.red, -- caret color
    }, options.colors or {})

    -- INTERNAL STATE
    self.modeIndex = 1 -- lower
    self.rows = gridFor("lower")
    self.initialValue = tostring(value or "")
    self.caret = #self.value + 1
    self.open = false

    self.cols = 12
    self.rowsCount = 4
    self.selRow = 1
    self.selCol = 1
end

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
        lg.print(inlineValue, self.inputX, self:_vAlignCentre(self.inlineFont:getHeight(inlineValue)))

        lg.pop()
        return
    end

    local ww, wh = lg.getDimensions()

    -- layout regions
    local textH = math.floor(wh * 0.25)
    local bottomGap = 100
    local kbH = wh - textH - bottomGap
    local kbY = textH

    -- draw the existing modal first (semi-transparent veil)
    lg.setColor(self.colors.modal)
    lg.rectangle("fill", 0, 0, ww, wh)

    -- then draw an additional opaque black area ONLY behind the keyboard
    lg.setColor(self.colors.kbBackdrop or { 0, 0, 0, 1 })
    lg.rectangle("fill", 0, kbY, ww, kbH)

    -- keyboard bounding with margins
    local margin = math.floor(math.min(ww, wh) * 0.025) -- ~2.5%
    local kbX = margin
    local kbW = ww - margin * 2
    local kbHInner = kbH - margin

    local rows = self.rows
    local cols = self.cols
    local gutter = math.max(2, math.floor(kbW * 0.008))
    local keySizeW = math.floor((kbW - gutter * (cols + 1)) / cols)
    local keySizeH = math.floor((kbHInner - gutter * (self.rowsCount + 1)) / self.rowsCount)
    local keySize = math.min(keySizeW, keySizeH)

    local usedW = keySize * cols + gutter * (cols + 1)
    local usedH = keySize * self.rowsCount + gutter * (self.rowsCount + 1)
    local originX = kbX + math.floor((kbW - usedW) / 2)
    local originY = kbY + math.floor((kbHInner - usedH) / 2)

    -- text line (centered) + caret on baseline
    lg.push("all")
    lg.setFont(self.typedTextFont)
    local textW = self.typedTextFont:getWidth(self.value)
    local textX = math.floor((ww - textW) / 2)
    local textY = math.floor(textH / 2 - self.typedTextFont:getHeight() / 2)

    lg.setColor(self.colors.typedText)
    lg.print(self.value, textX, textY)

    -- caret position matches baseline of printed text
    local pre = self.value:sub(1, self.caret - 1)
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

    -- draw keys: filled rounded rectangles, glyph centered
    for r = 1, self.rowsCount do
        for c = 1, cols do
            local ch = rows[r][c]
            local x = originX + gutter + (c - 1) * (keySize + gutter)
            local y = originY + gutter + (r - 1) * (keySize + gutter)

            -- key background fill (active vs idle)
            if r == self.selRow and c == self.selCol then
                lg.setColor(self.colors.active)
            else
                lg.setColor(self.colors.keycapFill)
            end
            lg.rectangle("fill", x, y, keySize, keySize, 6, 6)

            -- glyph text centered on top
            lg.push("all")
            lg.setFont(self.keycapFont)
            lg.setColor(self.colors.glyph)
            local gh = self.keycapFont:getHeight()
            -- Note: space ' ' will appear blank by design
            lg.printf(ch, x, y + (keySize - gh) / 2, keySize, "center")
            lg.pop()
        end
    end
end

function M:doOpen()
    self.open = true
    self.systemeventsubscriber:publish("keyboard_opened")
end

function M:close(typ)
    self.open = false
    self.systemeventsubscriber:publish("keyboard_closed", { type = typ })
end

function M:handleInput(input)
    -- if keyboard is closed, only 'confirm' opens it
    if not self.open then
        if input == "confirm" then
            self:doOpen()
        end
        return self.value
    end

    -- move selection (wrap)
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
        self.caret = prevByteIndex(self.value, self.caret)
        return self.value
    elseif input == "nav_right" then
        self.caret = nextByteIndex(self.value, self.caret)
        return self.value
    end

    -- type key
    if input == "confirm" then
        local ch = self.rows[self.selRow][self.selCol]
        if (runeLen(self.value) < self.maxLength) and ch and ch ~= "" then
            local left = self.value:sub(1, self.caret - 1)
            local right = self.value:sub(self.caret)
            self.value = left .. ch .. right
            self.caret = self.caret + #ch
        end
        return self.value
    end

    -- backspace
    if input == "cancel" then
        if true then
            self.value, self.caret = deletePrevRune(self.value, self.caret)
        end
        return self.value
    end

    -- clear
    if input == "tertiary" then
        self.value = ""
        self.caret = 1
        return self.value
    end

    -- change mode
    if input == "secondary" then
        self.modeIndex = (self.modeIndex % #MODES) + 1
        self.rows = gridFor(MODES[self.modeIndex])
        return self.value
    end

    -- commit
    if input == "start" then
        if self.allowEmpty == false and string.len(self.value) == 0 then
            self.systemeventsubscriber:publish("keyboard_validation_fail", { message = "Value cannot be empty" })
        elseif self.validate and type(self.validate) == "function" and self.validate(self.value) == false then
            local valid, message = self.validate(self.value)
            self.systemeventsubscriber:publish("keyboard_validation_fail", { message = message })
        else
            self:close("confirm")
        end
        return self.value
    end

    -- cancel/discard
    if input == "select" then
        self:close("cancel")
        self.value = self.initialValue
        self.caret = #self.value + 1
        return self.value
    end
end

return M
