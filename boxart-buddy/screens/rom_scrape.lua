local colors = require("util.colors")
local path = require("util.path")
local media = require("util.media")
local stringUtil = require("util.string")
local Menu = require("gui.widget.group.menu")
local ImageCarousel = require("gui.widget.special.image_carousel")
local TinySelect = require("gui.widget.tiny_select")
local Loading = require("gui.loading")

---@class RomScrapeScreen
local M = class({
    name = "RomScrapeScreen",
})

function M:new(
    environment,
    systemeventsubscriber,
    inputeventsubscriber,
    database,
    mediaTypeProvider,
    thread,
    flux,
    previousCanvas,
    scraper
)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.mediaTypeProvider = mediaTypeProvider
    self.scraper = scraper
    self.thread = thread
    self.flux = flux
    self.romRepository = require("repository.rom")(database)
    self.previousCanvas = previousCanvas

    self.canvas = nil
    self.transitionTo = nil

    self.rom = nil
    self.romUuid = nil
    self.mediaType = nil
    self.mediaTypes = self.mediaTypeProvider:getScrapeMediaTypes()

    self.loadingResults = nil

    self.searchResults = nil
    self.imageCarousel = nil
    self.scrapeSelector = nil
    self.mediaTypeSelector = nil
    self.currentSelectedImage = nil
    self.currentScraper = self.scraper:_getDefaultScraperByType(self:_getMediaType())

    -- bound functions
    self.boundEventHandler = function(e)
        self:handleInput(e)
    end
    self.boundSearchResultHandler = function(e)
        if e.threadKey == "scrape_roms" then
            -- -- manually kill scraper_download thread
            -- self.thread:killThreadPool("scraper_download")
            if e.result.data then
                self:searchResultsToCarousel(e.result.data)
            end
        end
        self.loadingResults = nil
    end

    self.boundScraperChanged = function(e)
        if e.option.type == "button" then
            self.currentScraper = e.option.key
            if not self.loadingResults then
                self:search()
            end
        end
    end

    -- romUuid defaults to last viewed rom on rom screen
    self.systemeventsubscriber:subscribe("rom_media_loaded", function(e)
        self.romUuid = e.romUuid
    end)

    -- romUuid defaults to last viewed rom on rom screen
    self.systemeventsubscriber:subscribe("rom_media_row_change", function(e)
        if table.contains(self.mediaTypes, e.type) then
            self.mediaType = e.type
        end
    end)
end

function M:handleInput(e)
    if e.type == "main_nav_left" or e.type == "main_nav_right" then
        return
    end
    if e.type == "left" or e.type == "right" then
        if self.imageCarousel then
            self.currentSelectedImage = self.imageCarousel:handleInput(e.type)
        end
    end
    if e.type == "up" or e.type == "down" then
        if not self.loadingResults and self.scrapeSelector then
            self.scrapeSelector:handleInput(e)
            -- change event handled by 'onchange' event
        end
    end

    if e.type == "nav_left" or e.type == "nav_right" then
        if not self.loadingResults and self.mediaTypeSelector then
            self.mediaType = self.mediaTypeSelector:handleInput(e.type == "nav_left" and "left" or "right")
            self:initScrapeSelector() -- kicks off a search automatically
        end
    end

    if e.type == "confirm" then
        if not self.loadingResults then
            if self.currentSelectedImage then
                -- copy image to correct location before inserting
                local filename = path.basename(self.currentSelectedImage.path)
                local copyCmd = string.format(
                    "mkdir -p %s && cp %s %s",
                    stringUtil.shellQuote(
                        path.dirname(media.mediaPath(self.environment:getPath("cache"), self:_getMediaType(), filename))
                    ),
                    stringUtil.shellQuote(media.mediaPath(self.environment:getPath("cache"), "tmp", filename)),
                    stringUtil.shellQuote(
                        media.mediaPath(self.environment:getPath("cache"), self:_getMediaType(), filename)
                    )
                )
                os.execute(copyCmd)

                self.scraper:createMedia(
                    self.currentScraper,
                    self.scraper:getDefinedScrapers(self.currentScraper),
                    path.stem(self.currentSelectedImage.path),
                    filename,
                    self:_getMediaType(),
                    self.currentSelectedImage.url,
                    self.rom.uuid
                )
            end
            self.transitionTo = "ROMS"
        end
    end
    if e.type == "cancel" then
        if not self.loadingResults then
            self.transitionTo = "ROMS"
        end
    end
end

function M:loadRom()
    if self.romUuid == nil then
        error("Runtime Error, romUuid cannot be nil on scrape screen")
    end
    local rom = self.romRepository:getRom(self.romUuid)
    if not rom then
        error("No rom found, cannot load options scrape for rom #: " .. self.romUuid)
    end
    return rom
end

function M:_getMediaType()
    return self.mediaType or self.mediaTypes[1]
end

function M:search()
    --- INSTANTIATE DOWNLOAD THREADS FOR CONCURRENT DOWNLOADS
    local numThreads = 1
    if self.currentScraper == "steamgriddb" then
        numThreads = 5
    elseif self.currentScraper == "screenscraper" then
        numThreads = self.environment:getConfig("scraper_screenscraper_threads")
    end

    self.thread:ensureThreadsInPool("scraper_download", numThreads)
    --- END INSTANTIATE DOWNLOAD THREADS FOR CONCURRENT DOWNLOADS

    self.loadingResults =
        Loading(self.canvas, ASSETS.image.loading.sprite_64, { x = (SCREEN.w / 8) * 5, y = (SCREEN.mainH / 2) })
    self.imageCarousel = nil
    self.thread:dispatchTasks("scrape_roms", {
        {
            type = "searchOne",
            parameters = {
                romUuid = self.rom.uuid,
                scraperId = self.currentScraper,
                mediaType = self:_getMediaType(),
                options = {},
            },
        },
    }, { progressStyle = "hidden", progressText = "Searching Media", silentThread = true })
end

function M:searchResultsToCarousel(searchResults)
    local options = {
        width = (SCREEN.w / 4) * 3,
        height = SCREEN.mainH - 140,
        offsetX = (SCREEN.w / 4),
        offsetY = 100,
        colors = {
            frame = nil,
            selectedFrame = nil,
            selectedFill = colors.activeUI,
        },
    }
    if next(searchResults) then
        self.imageCarousel = ImageCarousel(self.canvas, self.flux, searchResults, options)
        self.currentSelectedImage = self.imageCarousel:current()
    else
        self.imageCarousel = nil
        self.currentSelectedImage = nil
    end
end

function M:initScrapeSelector()
    local scrapers = self.scraper:getScrapers({ types = { self:_getMediaType() } })

    if not next(scrapers) then
        self.scrapeSelector = nil
        self.imageCarousel = nil
        return
    end
    local buttons = {}
    local currentOptionIndex = 1
    for i, tuple in ipairs(scrapers) do
        buttons[i] = {
            type = "button",
            key = tuple.id,
            label = tuple.id,
            options = {
                width = (SCREEN.w / 4) - 20,
                height = 40,
                buttonWidth = (SCREEN.w / 4) - 40,
                align = "left",
                textAlign = "left",
                textOffsetX = 10,
                colors = {
                    text = colors.offWhite,
                    bg = false,
                    highlightBg = colors.blue,
                    disabledBg = false,
                    border = false,
                    highlightBorder = colors.activeUI,
                    disabledBorder = false,
                },
            },
        }
        -- pick the correct scraper in the menu on init if available
        if tuple.id == self.currentScraper then
            currentOptionIndex = i
        end
    end
    -- in case currentScraper not available within list
    self.currentScraper = scrapers[currentOptionIndex].id

    self.scrapeSelector = Menu(self.canvas, self.systemeventsubscriber, buttons, {}, {
        x = 10,
        y = 100,
        font = ASSETS.font.inter.medium(FONTSIZE.s),
        -- spacingY = 34,
        currentOptionIndex = currentOptionIndex,
    })
end

function M:initMediaTypeSelector()
    self.mediaTypeSelector = TinySelect(self.canvas, self.mediaTypes, self:_getMediaType(), {
        x = (SCREEN.w / 4),
        y = 50,
        width = (SCREEN.w / 3),
        height = 30,
        font = ASSETS.font.inter.bold(FONTSIZE.m),
        labelWidth = 0,
        textWidth = ((SCREEN.w / 4) * 3) - 80,
        arrowLeft = ASSETS.image.button.gamepad.small.l1,
        arrowRight = ASSETS.image.button.gamepad.small.r1,
        colors = {
            arrow = colors.lightGrey,
        },
    })
end

function M:enter()
    self.canvas = love.graphics.newCanvas(SCREEN.w, SCREEN.mainH, { msaa = 8 })
    self.rom = self:loadRom()

    self.inputeventsubscriber:subscribe("input", self.boundEventHandler)
    self.systemeventsubscriber:subscribe("task_result", self.boundSearchResultHandler)
    self.systemeventsubscriber:subscribe("option_selected", self.boundScraperChanged)

    self.systemeventsubscriber:publish("screen_enter", { screen = "ROMSCRAPE" })
    self:initMediaTypeSelector()
    self:initScrapeSelector()
end

function M:exit()
    self.canvas = nil
    self.inputeventsubscriber:unsubscribe("input", self.boundEventHandler)
    self.systemeventsubscriber:unsubscribe("task_result", self.boundSearchResultHandler)
    self.systemeventsubscriber:unsubscribe("option_selected", self.boundScraperChanged)

    self.systemeventsubscriber:publish("screen_exit", { screen = "ROMSCRAPE" })

    self.transitionTo = nil
    self.canvas = nil
    self.rom = nil
    self.romOptions = nil
end

function M:update(dt)
    if self.transitionTo then
        return self.transitionTo
    end

    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)

    -- background
    love.graphics.setColor({ 0.16, 0.16, 0.16, 0.6 })
    love.graphics.rectangle("fill", 0, 0, SCREEN.w, SCREEN.mainH, 16, 16)

    -- heading
    local headingFont = ASSETS.font.inter.bold(FONTSIZE.xl)
    love.graphics.setFont(headingFont)
    love.graphics.setColor(colors.offWhite)
    love.graphics.printf(
        stringUtil.truncateStringAfterWidth(self.rom.romname, SCREEN.w - 20, headingFont),
        0,
        0,
        SCREEN.w - 20,
        "center"
    )

    -- draw scrape selector
    if self.scrapeSelector then
        self.scrapeSelector:draw()
    else
        -- no scraper for this media type
        love.graphics.setCanvas(self.canvas)
        love.graphics.setColor(colors.white)
        love.graphics.setFont(ASSETS.font.inter.bold(FONTSIZE.xl))
        love.graphics.printf(
            "NO SCRAPER ENABLED\nFOR THIS MEDIA TYPE",
            (SCREEN.w / 4) * 1,
            (SCREEN.mainH / 2),
            (SCREEN.w / 4) * 3,
            "center"
        )
    end

    -- draw type selector
    if self.mediaTypeSelector then
        self.mediaTypeSelector:draw()
    end

    -- draw image carousel
    if self.imageCarousel then
        self.imageCarousel:update(dt)
        self.imageCarousel:draw()
    elseif not self.loadingResults and self.scrapeSelector then
        -- no results
        love.graphics.setCanvas(self.canvas)
        love.graphics.setColor(colors.white)
        love.graphics.setFont(ASSETS.font.inter.bold(FONTSIZE.xl))
        love.graphics.printf("NO RESULTS", (SCREEN.w / 4) * 1, (SCREEN.mainH / 2), (SCREEN.w / 4) * 3, "center")
    end

    -- draw loader
    love.graphics.setCanvas(self.canvas)
    if self.loadingResults then
        self.loadingResults:update(dt)
        self.loadingResults:draw()
    end

    -- end
    love.graphics.setCanvas()
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
