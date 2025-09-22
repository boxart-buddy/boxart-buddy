local pager = require("util.pagination")
local colors = require("util.colors")
local media = require("util.media")
local stringUtil = require("util.string")
local netcheck = require("util.netcheck")
local PillBar = require("gui.widget.pillbar")
local Confirm = require("gui.widget.special.confirm")

---@class RomsScreen
local M = class({
    name = "RomsScreen",
})

function M:new(
    environment,
    systemeventsubscriber,
    inputeventsubscriber,
    database,
    thread,
    romFilterDataProvider,
    scraper,
    mediaTypeProvider,
    previousCanvas
)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.thread = thread
    self.romFilterDataProvider = romFilterDataProvider
    self.scraper = scraper
    self.mediaTypeProvider = mediaTypeProvider
    self.previousCanvas = previousCanvas
    self.romRepository = require("repository.rom")(database)
    self.mediaRepository = require("repository.media")(database, environment)

    self.pageLimit = 8
    self.canvasHeight = SCREEN.mainH
    self.shouldRedraw = true

    -- state
    self.activeTableRow = 1
    self.activeMediaRow = 1
    self.activePanel = "table" -- "table"/"media"
    self.romData = nil
    self.pagination = nil
    self.filters = nil
    self.confirmDelete = nil

    -- tracking this to release memory
    self.lastLoadedImage = nil

    -- set on screen entry
    self.mediaTypes = {}
    self.scrapeMediaTypes = {}

    -- render options
    self.mediaBoxWidth = SCREEN.wUnit(8)
    self.mediaBoxMarginRight = SCREEN.wUnit(0.4)
    self.tableBoxMarginLeft = SCREEN.wUnit(0.4)
    self.tableBoxMarginRight = SCREEN.wUnit(0.4)
    self.tableBoxWidth = SCREEN.w
        - self.mediaBoxWidth
        - self.mediaBoxMarginRight
        - self.tableBoxMarginLeft
        - self.tableBoxMarginRight

    self.paginationFont = ASSETS.font.univers.regular(FONTSIZE.s)
    self.tableFont = ASSETS.font.univers.regular(FONTSIZE.s)

    -- init rom data
    self.romData = {}
    self.mediaData = {}

    -- handle input
    self.inputHandlers = {
        nav_left = function()
            if self.activePanel == "media_preview" then
                return
            end
            local current = self.pagerGui:handleInput("left")
            if current ~= self.pagination.current then
                self.pagination.current = current
                self.systemeventsubscriber:publish("rom_table_page_change")
                self.systemeventsubscriber:publish(
                    "rom_table_row_change",
                    { romUuid = self.romData[self.activeTableRow].uuid }
                )
                self.shouldRedraw = true
            end
        end,
        nav_right = function()
            if self.activePanel == "media_preview" then
                return
            end
            -- if self.pagination.current == self.pagination.max then
            --     return
            -- end
            local current = self.pagerGui:handleInput("right")
            if current ~= self.pagination.current then
                self.pagination.current = current
                self.systemeventsubscriber:publish("rom_table_page_change")
                self.systemeventsubscriber:publish(
                    "rom_table_row_change",
                    { romUuid = self.romData[self.activeTableRow].uuid }
                )
                if self.romData[self.activeTableRow] == nil then
                    self.activeTableRow = 1
                end
                self.shouldRedraw = true
            end
        end,
        up = function()
            if self.activePanel == "table" then
                if self.activeTableRow == 1 then
                    return -- top of list already
                end
                self.activeTableRow = self.activeTableRow - 1
                -- throw event that active table row has changed
                self.systemeventsubscriber:publish(
                    "rom_table_row_change",
                    { romUuid = self.romData[self.activeTableRow].uuid }
                )
                self.shouldRedraw = true
            elseif self.activePanel == "media" or self.activePanel == "media_preview" then
                if self.activeMediaRow == 1 then
                    return -- top of list already
                end
                self.activeMediaRow = self.activeMediaRow - 1
                self.systemeventsubscriber:publish(
                    "rom_media_row_change",
                    { type = self.mediaTypes[self.activeMediaRow] }
                )
                self.shouldRedraw = true
            end
        end,
        down = function()
            if self.activePanel == "table" then
                if self.activeTableRow == #self.romData then
                    return -- bottom of list already
                end
                self.activeTableRow = self.activeTableRow + 1
                self.shouldRedraw = true
                -- throw event that active table row has changed
                self.systemeventsubscriber:publish(
                    "rom_table_row_change",
                    { romUuid = self.romData[self.activeTableRow].uuid }
                )
            elseif self.activePanel == "media" or self.activePanel == "media_preview" then
                if self.activeMediaRow == #self.mediaTypes then
                    return -- bottom of list already
                end
                self.activeMediaRow = self.activeMediaRow + 1
                self.systemeventsubscriber:publish(
                    "rom_media_row_change",
                    { type = self.mediaTypes[self.activeMediaRow] }
                )
                self.shouldRedraw = true
            end
        end,
        left = function()
            if self.activePanel == "table" or self.activePanel == "media_preview" then
                return
            end
            self.systemeventsubscriber:publish("rom_table_entered")
            self.activePanel = "table"
            self.shouldRedraw = true
        end,
        right = function()
            if self.activePanel == "media" or self.activePanel == "media_preview" then
                return
            end
            self.systemeventsubscriber:publish("media_table_entered")
            self.activePanel = "media"
            self.systemeventsubscriber:publish("rom_media_row_change", { type = self.mediaTypes[self.activeMediaRow] })
            self.shouldRedraw = true
        end,
        confirm = function()
            if not netcheck.hasInternet() then
                self.systemeventsubscriber:publish(
                    "toast_create",
                    { message = "No Connection to Internet. Cannot scrape", typ = "error" }
                )
            else
                self.transitionTo = "ROMSCRAPE"
            end
        end,
        secondary = function()
            if self.activePanel == "table" then
                self.transitionTo = "ROMOPTIONS"
                -- local romUuid = self.romData[self.activeTabpleRow].uuid
                -- self.thread:dispatchTasks("scan_roms", { { type = "reScanOne", parameters = { romUuid = romUuid } } })
            elseif self.activePanel == "media" then
                local mediaUuid = self.mediaData[self.mediaTypes[self.activeMediaRow]]
                        and self.mediaData[self.mediaTypes[self.activeMediaRow]].uuid
                    or nil
                if mediaUuid then
                    self.systemeventsubscriber:publish("media_preview_entered")
                    self.activePanel = "media_preview"
                    self.shouldRedraw = true
                end
            elseif self.activePanel == "media_preview" then
                self.activePanel = "media"
                self.systemeventsubscriber:publish("media_table_entered")
                self.shouldRedraw = true
            end
        end,
        tertiary = function()
            self.transitionTo = "ROMFILTER"
        end,
        start = function()
            self.transitionTo = "STAT"
        end,
        cancel = function()
            -- delete individual media
            if self.activePanel == "media" then
                self.confirmDelete = Confirm(self.systemeventsubscriber, {
                    message = string.format("Delete %s?", self.mediaTypes[self.activeMediaRow]),
                    onConfirm = function()
                        local mediaUuid = self.mediaData[self.mediaTypes[self.activeMediaRow]]
                                and self.mediaData[self.mediaTypes[self.activeMediaRow]].uuid
                            or nil
                        if mediaUuid then
                            self.mediaRepository:deleteMedia(mediaUuid)
                            self:loadMediaData()
                        end
                    end,
                })
                self.confirmDelete:open()
            end
        end,
    }

    self.boundInputHandler = function(e)
        self:handleInput(e)
    end

    self.boundReloadMedia = function(event)
        self:loadMediaData()
    end
    self.boundLoadNewPage = function(event)
        self:loadNewPageData()
    end

    self.forceRedraw = function(event)
        self.shouldRedraw = true
    end

    --#subscribers
    self.systemeventsubscriber:subscribe("screen_enter", function(event)
        if event.screen == "ROMS" then
            self:loadNewPageData()
            self:loadMediaData()
        end
    end)

    self.systemeventsubscriber:subscribe("scan_roms_complete", function(event)
        self.activeTableRow = 1
        self.activeMediaRow = 1
        self.pagination = nil
    end)

    -- used to other screens directly
    self.transitionTo = nil
end

function M:loadNewPageData()
    local limit = self.pagination and self.pagination.limit or 8
    local current = self.pagination and self.pagination.current or 1
    if self.filters == nil then
        self.filters = self.romFilterDataProvider:getFilters()
    end
    local romData, count = self.romRepository:getRomTableData(limit, current, self.filters, self.scrapeMediaTypes)
    self.romData = romData
    self.pagination = pager.getPagination(count, limit, current)
    self.pagerGui = PillBar(self.canvas, self.pagination.pages, self.pagination.current, {
        width = self.tableBoxWidth - SCREEN.wUnit(1.5),
        pillBarWidth = self.tableBoxWidth - SCREEN.wUnit(5),
        height = SCREEN.hUnit(3),
        x = SCREEN.wUnit(0.5),
        y = SCREEN.hUnit(1),
        barPadX = SCREEN.wUnit(1),
        pillPadX = SCREEN.wUnit(0.5),
        colors = {
            text = colors.grey,
            activeText = colors.white,
            image = colors.darkGrey,
            bg = false,
        },
        font = self.paginationFont,
        maxGap = SCREEN.wUnit(3),
        imageLeft = ASSETS.image.button.gamepad.small.l1,
        imageRight = ASSETS.image.button.gamepad.small.r1,
        imageMargin = SCREEN.wUnit(0.7),
    })

    -- stops self.activeTableRow becoming out of bounds on last page
    if not self.romData[self.activeTableRow] then
        self.activeTableRow = 1
    end

    if self.pagination.count == 0 and not self:_isFilterApplied() then
        self.systemeventsubscriber:publish("rom_data_loaded_empty")
    elseif self.pagination.count == 0 and self:_isFilterApplied() then
        self.systemeventsubscriber:publish("rom_data_loaded_no_results")
    end
end

function M:loadMediaData()
    if #self.romData == 0 then
        self.mediaData = {}
        return
    end
    local uuid = self.romData[self.activeTableRow].uuid
    self.mediaData = self.romRepository:getMediaForRom(uuid)
    -- this event is used on the mix page. bit of a dirty hack to work around the iffy event binding on this page
    self.systemeventsubscriber:publish("rom_media_loaded", { romUuid = uuid })
end

function M:_isFilterApplied()
    if self.filters.verified ~= "all" then
        return true
    end
    if self.filters.media ~= "all" then
        return true
    end
    for k, v in pairs(self.filters.platforms) do
        if v == false then
            return true
        end
    end
    return false
end

function M:update(dt)
    if self.transitionTo then
        return self.transitionTo
    end

    if self.shouldRedraw == false then
        return
    end

    if not self.pagination or not self.romData or not self.mediaData then
        error("LOGICAL ERROR DATA NOT LOADED")
    end

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(colors.black)

    -- case when there are 0 roms
    if not next(self.romData) and not self:_isFilterApplied() then
        love.graphics.setColor(colors.white)
        love.graphics.setFont(ASSETS.font.univers.bold(FONTSIZE.xl))
        love.graphics.printf("NO ROMS FOUND\nHAVE YOU SCANNED ROMS YET?", 0, 100, SCREEN.w, "center")
        love.graphics.setCanvas()
        self.shouldRedraw = false
        return
    elseif not next(self.romData) then
        love.graphics.setColor(colors.white)
        love.graphics.setFont(ASSETS.font.univers.bold(FONTSIZE.xl))
        love.graphics.printf("NO RESULTS", 0, 100, SCREEN.w, "center")
        love.graphics.setCanvas()
        self.shouldRedraw = false
        return
    end
    -- end case when there are 0 roms

    ---- draw pagination
    self.pagerGui:draw(self.canvas, self.pagination.pages, self.pagination.current)

    -- count
    love.graphics.setCanvas(self.canvas)
    love.graphics.setColor(colors.white)
    love.graphics.setFont(self.paginationFont)
    local countText = string.format("%s results", self.pagination.count)
    if self:_isFilterApplied() then
        countText = countText .. " (filtered)"
    end
    love.graphics.printf(
        countText,
        self.tableBoxWidth + self.tableBoxMarginLeft,
        20,
        self.mediaBoxWidth + self.mediaBoxMarginRight,
        "center"
    )
    ---- end pagination

    local tableTopMargin = SCREEN.hUnit(4.5) -- height of the pagination above
    local tableRowHeight = math.ceil((self.canvasHeight - tableTopMargin) / self.pageLimit)
    local tableRowPaddingY = 2
    -- draw main table
    for i, rom in ipairs(self.romData) do
        local tableRowY = tableTopMargin + ((tableRowHeight * i) - tableRowHeight)
        local tableRowYMid = tableRowY + tableRowHeight / 2

        -- active BG
        if i == self.activeTableRow then
            local activeTableRowColor = self.activePanel == "table" and colors.activeUI or colors.activeSecondaryUI
            love.graphics.setColor(activeTableRowColor)
            love.graphics.rectangle(
                "fill",
                self.tableBoxMarginLeft,
                tableRowY + tableRowPaddingY,
                self.tableBoxWidth,
                tableRowHeight - (tableRowPaddingY * 2),
                4,
                4
            )
            love.graphics.setColor(colors.white)
        end
        -- end activeBG

        -- verified
        if rom.error == 1 then
            local warnImage = ASSETS.image.warn
            love.graphics.draw(warnImage, 14, tableRowYMid - warnImage:getHeight() / 2)
        elseif rom.verified then
            local verifiedImage = ASSETS.image.verified
            love.graphics.draw(verifiedImage, 14, tableRowYMid - verifiedImage:getHeight() / 2)
        end

        -- media count donut
        if rom.media_count > 0 then
            local donutFolder = "donut" .. math.min(#self.scrapeMediaTypes, 6) -- defensive if > 6 media
            local mediaCountIcon = ASSETS.image[donutFolder][rom.media_count]
            love.graphics.draw(mediaCountIcon, 42, tableRowYMid - mediaCountIcon:getHeight() / 2)
        end

        -- platform
        local platformImage = ASSETS.image.mix.platform.small[rom.platform] or ASSETS.image.mix.platform.small.missing
        local platformLogoScaleFactor = 0.7 -- the images are too big and I CBA converting them
        love.graphics.setColor(colors.grey)
        love.graphics.draw(
            platformImage,
            69,
            tableRowYMid - math.ceil(platformImage:getHeight() * platformLogoScaleFactor) / 2,
            0,
            platformLogoScaleFactor,
            platformLogoScaleFactor
        )

        -- romname
        love.graphics.setFont(self.tableFont)
        local tableFontHeight = self.tableFont:getHeight()
        love.graphics.setColor(colors.offWhite)
        local romNameTruncated =
            stringUtil.truncateStringAfterWidth(rom.filename, self.tableBoxWidth - 158, self.tableFont)
        love.graphics.printf(romNameTruncated, 170, tableRowYMid - tableFontHeight / 2, 1000, "left")
    end
    -- end pagination

    --- draw media

    local screenshotY = tableTopMargin + SCREEN.hUnit(0.5)

    -- screenshot
    local currentMedia = self.mediaData[self.mediaTypes[self.activeMediaRow]]
    local currentImage, currentImageData, currentImageMetadataPretty

    if self.lastLoadedImage and self.lastLoadedImage:typeOf("Image") then
        self.lastLoadedImage:release()
    end

    if currentMedia then
        local mediaFilename =
            media.mediaPath(self.environment:getPath("cache"), currentMedia.type, currentMedia.filename)

        currentImage, currentImageData = media.loadImage(mediaFilename)
        self.lastLoadedImage = currentImage
    else
        currentImage = ASSETS.image.media.missing
        self.lastLoadedImage = nil
    end

    -- wrap errors loading bad images
    if currentImage then
        love.graphics.setColor(colors.white)
        if (currentMedia and currentMedia.type == "screenshot") or not currentMedia then
            media.scaleMedia(currentImage, self.canvas, {
                x = SCREEN.w - ((self.mediaBoxMarginRight + self.mediaBoxWidth) / 2),
                y = screenshotY + (SCREEN.h / 8),
                width = SCREEN.w / 4,
                height = SCREEN.h / 4,
                anchor = { x = "center", y = "middle" },
            })
        else
            media.fitMedia(currentImage, self.canvas, {
                x = SCREEN.w - ((self.mediaBoxMarginRight + self.mediaBoxWidth) / 2),
                y = screenshotY + (SCREEN.h / 8),
                width = SCREEN.w / 4,
                height = SCREEN.h / 4,
                anchor = { x = "center", y = "middle" },
            })
        end
        if currentImageData then
            local w, h = currentImage:getDimensions()
            currentImageMetadataPretty =
                string.format("i:%s (%sx%s)", stringUtil.formatBytes(currentImageData:getSize()), w, h)
        end
    end
    -- end screenshot

    -- media table
    love.graphics.setCanvas(self.canvas)

    local mediaTableY = SCREEN.h / 4 + screenshotY + SCREEN.hUnit(1)
    local mediaTableRowHeight = SCREEN.hUnit(2.2)

    for i, type in ipairs(self.mediaTypes) do
        local mediaRowYMid = mediaTableY + mediaTableRowHeight / 2 + (mediaTableRowHeight * (i - 1))
        local tableFontHeight = self.tableFont:getHeight()

        if self.activeMediaRow == i then
            local activeMediaRowColor = self.activePanel == "media" and colors.activeUI or colors.activeSecondaryUI
            love.graphics.setColor(activeMediaRowColor)
            love.graphics.rectangle(
                "fill",
                SCREEN.w - self.mediaBoxWidth - self.mediaBoxMarginRight,
                mediaTableY + (mediaTableRowHeight * (i - 1)) + tableRowPaddingY,
                self.mediaBoxWidth,
                mediaTableRowHeight - (tableRowPaddingY * 2),
                4,
                4
            )
            love.graphics.setColor(colors.white)
        end
        -- cross/tick with text
        local mediaIcon = self.mediaData[type] and ASSETS.image.media.check or ASSETS.image.media.cross
        love.graphics.setColor(colors.white)
        love.graphics.draw(
            mediaIcon,
            (SCREEN.w - self.mediaBoxWidth - self.mediaBoxMarginRight) + SCREEN.wUnit(0.3),
            mediaRowYMid - mediaIcon:getHeight() / 2
        )
        love.graphics.setFont(self.tableFont)
        love.graphics.setColor(colors.offWhite)
        love.graphics.printf(
            type,
            (SCREEN.w - self.mediaBoxWidth - self.mediaBoxMarginRight) + SCREEN.wUnit(1.6),
            mediaRowYMid - (tableFontHeight / 2),
            self.mediaBoxWidth - SCREEN.wUnit(1.6),
            "left"
        )
    end
    -- end media table
    -- game info below media
    if self.romData[self.activeTableRow] then
        local romSize = self.romData[self.activeTableRow].size or "unknown size"
        local romCrc32 = self.romData[self.activeTableRow].crc32 or "????"
        local romSerial = self.romData[self.activeTableRow].serial
        local gameInfoFont = ASSETS.font.inconsolita.medium(FONTSIZE.xs)
        love.graphics.setFont(gameInfoFont)
        love.graphics.setColor(colors.lightGrey)
        if currentImageMetadataPretty then
            love.graphics.printf(
                currentImageMetadataPretty,
                (SCREEN.w - self.mediaBoxWidth - self.mediaBoxMarginRight) + SCREEN.wUnit(0.6),
                SCREEN.mainH - SCREEN.hUnit(3.5),
                self.mediaBoxWidth,
                "left"
            )
        end

        local romVerifier = romSerial or romCrc32 or ""
        local romMetadataPretty = string.format("r:%s", stringUtil.formatBytes(romSize))
        if romVerifier then
            romMetadataPretty = romMetadataPretty .. string.format(" (%s)", romVerifier)
        end
        love.graphics.printf(
            romMetadataPretty,
            (SCREEN.w - self.mediaBoxWidth - self.mediaBoxMarginRight) + SCREEN.wUnit(0.6),
            SCREEN.mainH - SCREEN.hUnit(2),
            self.mediaBoxWidth,
            "left"
        )
    end
    -- end game info

    ---- end media

    ---- media preview!
    if self.activePanel == "media_preview" then
        -- modal
        love.graphics.setColor(colors.modalCover)
        love.graphics.rectangle("fill", 50, SCREEN.headerH, SCREEN.w - 100, SCREEN.mainH)
        if currentImage then
            if currentMedia and currentMedia.type == "mix" then
                media.scaleMedia(ASSETS.image.mixbg, self.canvas, {
                    x = SCREEN.hUnit(5),
                    y = 0,
                    width = SCREEN.w - SCREEN.wUnit(5),
                    height = SCREEN.mainH,
                })
            end
            media.fitMedia(currentImage, self.canvas, {
                x = SCREEN.hUnit(5),
                y = 0,
                width = SCREEN.w - SCREEN.wUnit(5),
                height = SCREEN.mainH,
            })
        end
    end

    ---- end media preview

    love.graphics.setCanvas()
    self.shouldRedraw = false
end

function M:draw()
    love.graphics.draw(self.canvas, 0, SCREEN.headerH)
    if self.confirmDelete then
        self.confirmDelete:draw()
    end
end

function M:handleInput(e)
    -- confirm popup takes prio
    if self.confirmDelete and self.confirmDelete.isOpen then
        self.confirmDelete:handleInput(e.type)
        self.shouldRedraw = true
        return
    end

    local handler = self.inputHandlers[e.type]
    if handler then
        handler()
    end
end

function M:enter()
    self.canvas = love.graphics.newCanvas(SCREEN.w, self.canvasHeight, { msaa = 8 })
    --inputs
    self.inputeventsubscriber:subscribe("input", self.boundInputHandler)

    --data load on navigation
    self.systemeventsubscriber:subscribe("rom_table_page_change", self.boundLoadNewPage)
    self.systemeventsubscriber:subscribe("rom_table_row_change", self.boundReloadMedia)

    -- force reload after table row actions
    self.systemeventsubscriber:subscribe("scan_roms_complete", self.boundLoadNewPage)
    self.systemeventsubscriber:subscribe("scan_roms_complete", self.boundReloadMedia)
    self.systemeventsubscriber:subscribe("scan_roms_complete", self.forceRedraw)
    self.systemeventsubscriber:subscribe("scrape_roms_complete", self.boundLoadNewPage)
    self.systemeventsubscriber:subscribe("scrape_roms_complete", self.boundReloadMedia)
    self.systemeventsubscriber:subscribe("scrape_roms_complete", self.forceRedraw)

    -- media types might have changed due to config changes
    self.mediaTypes = self.mediaTypeProvider:getMediaTypes()
    self.scrapeMediaTypes = self.mediaTypeProvider:getScrapeMediaTypes()

    self.systemeventsubscriber:publish("screen_enter", { screen = "ROMS" })
end

function M:exit()
    --inputs
    self.inputeventsubscriber:unsubscribe("input", self.boundInputHandler)

    --data load on navigation
    self.systemeventsubscriber:unsubscribe("rom_table_row_change", self.boundReloadMedia)
    self.systemeventsubscriber:unsubscribe("rom_table_page_change", self.boundLoadNewPage)

    -- force reload after table row actions
    self.systemeventsubscriber:unsubscribe("scan_roms_complete", self.boundLoadNewPage)
    self.systemeventsubscriber:unsubscribe("scan_roms_complete", self.boundReloadMedia)
    self.systemeventsubscriber:unsubscribe("scan_roms_complete", self.forceRedraw)
    self.systemeventsubscriber:unsubscribe("scrape_roms_complete", self.boundLoadNewPage)
    self.systemeventsubscriber:unsubscribe("scrape_roms_complete", self.boundReloadMedia)
    self.systemeventsubscriber:unsubscribe("scrape_roms_complete", self.forceRedraw)

    self.systemeventsubscriber:publish("screen_exit", { screen = "ROMS" })

    -- cleanup state for future screen loads
    self.activePanel = "table"

    self.shouldRedraw = true
    self.transitionTo = nil

    self.romData = nil
    self.mediaData = nil

    self.previousCanvas:set(self.canvas, "ROMS")
    self.canvas = nil
end

return M
