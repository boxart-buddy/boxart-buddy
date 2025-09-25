local progress = require("gui.progress.static")
local colors = require("util.colors")
local layout = require("util.layout")

---@class StatScreen
local M = class({
    name = "StatScreen",
})

function M:new(environment, database, inputeventsubscriber, systemeventsubscriber, mediaTypeProvider)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.mediaTypeProvider = mediaTypeProvider

    self.romRepository = require("repository.rom")(database)
    self.canvas = love.graphics.newCanvas(SCREEN.w, SCREEN.mainH)
    self.transitionTo = nil

    self.boundInputHandler = function(e)
        self:handleInput(e)
    end

    self.inputHandlers = {
        cancel = function()
            self.transitionTo = "ROMS"
        end,
        start = function()
            self.transitionTo = "ROMS"
        end,
    }
end

function M:handleInput(e)
    local handler = self.inputHandlers[e.type]
    if handler then
        handler()
    end
end

function M:enter()
    self.systemeventsubscriber:publish("screen_enter", { screen = "STAT" })

    self.inputeventsubscriber:subscribe("input", self.boundInputHandler)

    self.drawn = false
end

function M:exit()
    self.inputeventsubscriber:unsubscribe("input", self.boundInputHandler)
    self.systemeventsubscriber:publish("screen_exit", { screen = "STAT" })

    self.drawn = false
    self.transitionTo = nil
end

function M:update(dt)
    if self.transitionTo then
        return self.transitionTo
    end
    if self.drawn then
        return
    end

    local mediaTypes = self.mediaTypeProvider:getMediaTypes()
    local scrapeMediaTypes = self.mediaTypeProvider:getScrapeMediaTypes()
    -- db lookup stats

    local romCount = self.romRepository:getRomCount()
    local verifiedCount = self.romRepository:getVerifiedCount()
    local errorCount = self.romRepository:getErrorCount()
    local coreImagesCountWithAll = self.romRepository:numberOfRomsWithNMedia(#scrapeMediaTypes, scrapeMediaTypes)

    local typCounts = {}
    local mediaCountTotal = 0
    for _, typ in ipairs(mediaTypes) do
        typCounts[typ] = self.romRepository:numberOfRomsWithMediaType(typ)
        mediaCountTotal = mediaCountTotal + typCounts[typ]
    end

    -- fonts
    local font = ASSETS.font.inter.medium(FONTSIZE.m)
    local fontLarge = ASSETS.font.inter.bold(24)
    local baselineY = layout.baselineY(SCREEN.hUnit(3), SCREEN.hUnit(4.8))

    -- draw to canvas
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(colors.black)
    --bg
    -- background
    love.graphics.setColor(colors.veryDarkGrey)
    love.graphics.rectangle("fill", 0, 0, SCREEN.w, SCREEN.mainH, 16, 16)

    love.graphics.setFont(fontLarge)
    love.graphics.setColor(colors.offWhite)
    -- rom count
    love.graphics.printf(string.format("%s Roms", romCount), layout.getXForColumnLayout(), baselineY(0), 300, "left")

    -- all images present
    love.graphics.setFont(font)
    -- love.graphics.printf("Complete", layout.getXForColumnLayout({ columns = 3, index = 1 }), baselineY(2), 300, "left")
    love.graphics.printf(
        "Complete: " .. coreImagesCountWithAll,
        layout.getXForColumnLayout({ columns = 3, index = 1 }) + 90,
        baselineY(2),
        300,
        "left"
    )

    -- verified count
    -- love.graphics.printf("Verified", layout.getXForColumnLayout({ columns = 3, index = 2 }), baselineY(2), 300, "left")
    love.graphics.printf(
        "Verified: " .. verifiedCount,
        layout.getXForColumnLayout({ columns = 3, index = 2 }) + 80,
        baselineY(2),
        300,
        "left"
    )

    -- error count
    love.graphics.setFont(font)
    -- love.graphics.printf("Errors", layout.getXForColumnLayout({ columns = 3, index = 3 }), baselineY(2), 300, "left")
    love.graphics.printf(
        "Errors: " .. errorCount,
        layout.getXForColumnLayout({ columns = 3, index = 3 }) + 60,
        baselineY(2),
        300,
        "left"
    )

    if romCount > 0 then
        local currentBaseline = 4
        for _, typ in ipairs(mediaTypes) do
            love.graphics.printf(typ, SCREEN.wDiv(1, 6), baselineY(currentBaseline), 300, "left")
            local percent = string.format("%.1f%%", (typCounts[typ] / romCount) * 100)
            love.graphics.printf(percent, SCREEN.wDiv(2, 6), baselineY(currentBaseline), 300, "left")

            progress.linear(
                SCREEN.wDiv(2, 6) + SCREEN.wUnit(3),
                baselineY(currentBaseline) + 4,
                SCREEN.wDiv(3, 6) - SCREEN.wUnit(3),
                14,
                (typCounts[typ] / romCount) * 100
            )

            currentBaseline = currentBaseline + 1
        end
    end
    -- end
    self.drawn = true
    love.graphics.setCanvas()
end

function M:draw(dt)
    -- modal
    love.graphics.setCanvas()
    love.graphics.setColor(colors.modalCover)
    love.graphics.rectangle("fill", 0, 0, SCREEN.w, SCREEN.h - SCREEN.footerH)

    --draw filters
    if self.canvas then
        love.graphics.setColor(colors.white)
        love.graphics.draw(self.canvas, 0, SCREEN.headerH)
    end
end

return M
