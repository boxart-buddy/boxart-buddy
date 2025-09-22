local colors = require("util.colors")
local stringUtil = require("util.string")
local Loading = require("gui.loading")

---@class ModalBar
local M = class({
    name = "ModalBar",
})

function M:new(progress, flux, options, canvas)
    self.flux = flux
    self.progress = progress
    self.canvas = canvas
    self.options = options or {}

    self.stepFont = ASSETS.font.univers.regular(FONTSIZE.s)
    self.headingFont = ASSETS.font.univers.bold(FONTSIZE.m)

    self.options.barHeight = self.options.barHeight or SCREEN.hUnit(3)
    self.options.barWidth = self.options.barWidth or SCREEN.wUnit(20)
    self.options.barStrokeWidth = self.options.barStrokeWidth or 2
    self.options.barPadding = self.options.barPadding or 2
    self.options.stepTweenTime = self.options.stepTweenTime or 0.2

    self.loading =
        Loading(self.canvas, ASSETS.image.loading.sprite_64, { x = SCREEN.wDiv(1, 2), y = SCREEN.hDiv(2, 3), fps = 32 })
end

function M:update(dt)
    -- inner
    local maxWidth = self.options.barWidth - (self.options.barPadding * 2)
    local newInnerWidth = maxWidth * (self.progress:percent() / 100)
    local newInnerColor =
        colors.midpoint(colors.progressBarInnerStart, colors.progressBarInnerEnd, (self.progress:percent() / 100))

    if self.options.stepTweenTime == nil then
        self.progress.innerBarWidth = newInnerWidth
        self.progress.innerBarColor = newInnerColor
    else
        -- tween width
        self.flux.to(self.progress, self.options.stepTweenTime, { innerBarWidth = newInnerWidth })

        -- tween color
        if self.progress.innerBarColor == nil then
            self.progress.innerBarColor = newInnerColor
        else
            self.flux.to(self.progress.innerBarColor, self.options.stepTweenTime, newInnerColor)
        end
    end

    --loading
    self.loading:update(dt)
end

function M:draw()
    if self.canvas then
        love.graphics.setCanvas(self.canvas)
    else
        love.graphics.setCanvas()
    end

    -- modal BG
    love.graphics.setColor(colors.modalCover)
    love.graphics.rectangle("fill", 0, 0, SCREEN.w, SCREEN.h)

    -- x / y
    local xPos = (SCREEN.w - self.options.barWidth) / 2
    local yPos = (SCREEN.h - self.options.barHeight) / 2

    --outer
    love.graphics.setColor(colors.progressBarOuter)
    love.graphics.rectangle(
        "fill",
        xPos,
        yPos,
        self.options.barWidth,
        self.options.barHeight,
        self.options.barStrokeWidth,
        self.options.barStrokeWidth
    )

    --stroke
    love.graphics.setColor(colors.progressBarStroke)
    love.graphics.setLineWidth(self.options.barStrokeWidth)
    love.graphics.rectangle(
        "line",
        xPos,
        yPos,
        self.options.barWidth,
        self.options.barHeight,
        self.options.barStrokeWidth,
        self.options.barStrokeWidth
    )

    -- inner
    love.graphics.setColor(self.progress.innerBarColor)
    love.graphics.rectangle(
        "fill",
        xPos + self.options.barPadding,
        yPos + self.options.barPadding,
        self.progress.innerBarWidth,
        self.options.barHeight - (self.options.barPadding * 2),
        self.options.barStrokeWidth,
        self.options.barStrokeWidth
    )

    -- text within bar
    local stepTextInner = stringUtil.truncateStringAfterWidth(
        self.progress:stepTextNumerical(),
        self.options.barWidth - 20,
        self.stepFont
    )
    local textObjectInner = love.graphics.newText(self.stepFont)
    textObjectInner:addf({ colors.white, stepTextInner }, SCREEN.w, "center", 0, 0)

    local textHeightInner = textObjectInner:getHeight()
    local yPosTextInner = yPos + (self.options.barHeight - textHeightInner) / 2

    love.graphics.setColor(colors.white)
    love.graphics.draw(textObjectInner, 0, yPosTextInner)

    -- step text
    local stepText =
        stringUtil.truncateStringAfterWidth(self.progress:stepText(), self.options.barWidth - 20, self.stepFont)
    if stepText ~= stepTextInner then
        local textObject = love.graphics.newText(self.stepFont)
        textObject:addf({ colors.white, stepText }, SCREEN.w, "center", 0, 0)

        local yPosText = yPos + self.options.barHeight + 5

        love.graphics.setColor(colors.white)
        love.graphics.draw(textObject, 0, yPosText)
    end

    -- text above progress bar
    local headerTextObject = love.graphics.newText(self.headingFont)
    headerTextObject:addf({ colors.white, self.progress.text }, SCREEN.w, "center", 0, 0)
    love.graphics.draw(headerTextObject, 0, yPos - SCREEN.hUnit(3))

    --loader
    self.loading:draw()

    love.graphics.setCanvas()
end

return M
