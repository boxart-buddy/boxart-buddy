local colors = require("util.colors")
local stringUtil = require("util.string")
local romOptionDefinition = require("dat.rom_option_definition")
local json = require("lib.json")
local Menu = require("gui.widget.group.menu")

---@class RomOptionScreen
local M = class({
    name = "RomOptionScreen",
})

function M:new(systemeventsubscriber, inputeventsubscriber, database, previousCanvas)
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.romRepository = require("repository.rom")(database)
    self.previousCanvas = previousCanvas
    self.canvas = nil
    self.shouldRedraw = true
    self.transitionTo = nil
    self.romOptions = nil
    self.romUuid = nil
    self.menu = nil
    self.displayHelp = true -- hard coded to true

    -- bound functions
    self.boundInputHandler = function(e)
        self:handleInput(e)
    end

    -- romUuid defaults to last viewed rom on rom screen
    self.systemeventsubscriber:subscribe("rom_media_loaded", function(e)
        self.romUuid = e.romUuid
    end)
end

function M:handleInput(e)
    self.romOptions = self.menu:handleInput(e)
    if e.scope == "subscreen" then
        if e.type == "secondary" or e.type == "start" then
            self.romRepository:saveRomOptions(self.rom.uuid, self:encodeRomOptionsPriorToSave(self.romOptions))
            self.transitionTo = "ROMS"
        end
    end
    self.shouldRedraw = true
end

--- if the options are totally empty then saves null back to the database
--- "none" valued options are not stored
---@param options table
---@return nil|table
function M:encodeRomOptionsPriorToSave(options)
    local clean = {}
    for k, v in pairs(options) do
        if v ~= "none" and v ~= nil and v ~= "" then
            clean[k] = v
        end
    end

    if not next(clean) then
        return nil
    end

    return json.encode(clean)
end

function M:loadRom()
    if self.romUuid == nil then
        error("Runtime Error, romUuid cannot be nil on options screen")
    end
    local rom = self.romRepository:getRom(self.romUuid)
    if not rom then
        error("No rom found, cannot load options screen for rom #: " .. self.romUuid)
    end
    return rom
end

function M:initMenu()
    local opts = {}

    if self.rom.options then
        opts = json.decode(self.rom.options)
        if not opts then
            error("rom options json string not valid")
        end
    end

    self.menu = Menu(
        self.canvas,
        self.systemeventsubscriber,
        romOptionDefinition, --definitions
        opts, --values
        { x = 70, y = 60, font = ASSETS.font.univers.regular(FONTSIZE.s), labelWidth = 190, spacingY = 34 }
    )
end

function M:enter()
    self.canvas = love.graphics.newCanvas(SCREEN.w, SCREEN.mainH, { msaa = 8 })
    self.rom = self:loadRom()
    self:initMenu()

    self.inputeventsubscriber:subscribe("input", self.boundInputHandler)
    self.systemeventsubscriber:publish("screen_enter", { screen = "ROMOPTIONS" })
end

function M:exit()
    self.canvas = nil
    self.inputeventsubscriber:unsubscribe("input", self.boundInputHandler)
    self.systemeventsubscriber:publish("screen_exit", { screen = "ROMOPTIONS" })

    self.shouldRedraw = true
    self.transitionTo = nil
    self.canvas = nil
    self.rom = nil
    self.romOptions = nil
end

function M:update(dt)
    if self.transitionTo then
        return self.transitionTo
    end
    if self.shouldRedraw == false then
        return
    end

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)

    -- background
    love.graphics.setColor({ 0.16, 0.16, 0.16, 0.6 })
    love.graphics.rectangle("fill", 0, 0, SCREEN.w, SCREEN.mainH, 16, 16)

    -- heading
    local headingFont = ASSETS.font.univers.bold(FONTSIZE.xl)
    love.graphics.setFont(headingFont)
    love.graphics.setColor(colors.offWhite)
    love.graphics.printf(
        stringUtil.truncateStringAfterWidth(self.rom.romname, SCREEN.w - SCREEN.wUnit(1), headingFont),
        0,
        0,
        SCREEN.w - 20,
        "center"
    )

    -- draw options
    self.menu:update(dt)
    self.menu:draw()

    --help
    if self.displayHelp then
        love.graphics.setCanvas(self.canvas)
        local helpY = SCREEN.h - SCREEN.hUnit(15)
        local helpStrokeWidth = 2
        love.graphics.setColor(colors.helpBg)
        love.graphics.rectangle(
            "fill",
            helpStrokeWidth,
            helpY,
            SCREEN.w - helpStrokeWidth * 2,
            SCREEN.mainH - helpY - (helpStrokeWidth * 2)
        )
        love.graphics.setLineWidth(helpStrokeWidth)
        love.graphics.setColor(colors.helpStroke)
        love.graphics.rectangle(
            "line",
            helpStrokeWidth,
            helpY,
            SCREEN.w - helpStrokeWidth * 2,
            SCREEN.mainH - helpY - (helpStrokeWidth * 2)
        )
        love.graphics.setColor(colors.offWhite)
        love.graphics.setFont(ASSETS.font.inconsolita.medium(FONTSIZE.s))
        local helpText = self.menu:getCurrentDefinition().description or "Help Text Missing"
        love.graphics.printf(helpText, SCREEN.wUnit(0.5), helpY + SCREEN.hUnit(1), SCREEN.w - SCREEN.wUnit(1), "left")
        love.graphics.setLineWidth(1)
    end

    -- end
    love.graphics.setCanvas()

    if not self.menu:isCurrentOptionOpen() then
        self.shouldRedraw = false
    end
end

function M:draw(dt)
    love.graphics.setCanvas()
    --previous
    local prevCanvas = self.previousCanvas:get()
    if prevCanvas then
        love.graphics.draw(prevCanvas, 0, SCREEN.headerH)
    end

    -- modal
    love.graphics.setColor(colors.modalCover)
    love.graphics.rectangle("fill", 0, 0, SCREEN.w, SCREEN.h - SCREEN.footerH)

    --options
    if self.canvas then
        love.graphics.setColor(colors.white)
        love.graphics.draw(self.canvas, 0, SCREEN.headerH)
    end
end
return M
