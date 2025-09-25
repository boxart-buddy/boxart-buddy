local colors = require("util.colors")
local Loading = require("gui.loading")

---@class ModalLoader
local M = class({
    name = "ModalLoader",
})

function M:new(progress, options, canvas)
    self.progress = progress
    self.canvas = canvas
    self.options = options or {}

    self.headingFont = ASSETS.font.inter.bold(FONTSIZE.m)

    self.loading =
        Loading(self.canvas, ASSETS.image.loading.sprite_64, { x = SCREEN.wDiv(1, 2), y = SCREEN.hDiv(2, 3), fps = 32 })
end

function M:update(dt)
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

    local yPos = (SCREEN.h - SCREEN.hUnit(3)) / 2

    -- text above progress bar
    love.graphics.setColor(colors.white)
    local headerTextObject = love.graphics.newText(self.headingFont)
    headerTextObject:addf({ colors.white, self.progress.text }, SCREEN.w, "center", 0, 0)
    love.graphics.draw(headerTextObject, 0, yPos - SCREEN.hUnit(3))

    --loader
    self.loading:draw()

    love.graphics.setCanvas()
end

return M
