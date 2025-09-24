local filesystem = require("lib.nativefs")
local path = require("util.path")
local stringUtil = require("util.string")
local https = require("https")
local media = require("util.media")
local image = require("util.image")
local socket = require("socket")

---@class Scraper
local M = class({
    name = "Scraper",
})

function M:new(
    environment,
    logger,
    systemeventsubscriber,
    database,
    platform,
    thread,
    rateLimitedHttps,
    mediaTypeProvider
)
    self.environment = environment
    self.logger = logger
    self.platform = platform
    self.systemeventsubscriber = systemeventsubscriber
    self.database = database
    self.thread = thread
    self.romRepository = require("repository.rom")(database)
    self.mediaRepository = require("repository.media")(database, environment)
    self.scraperRepository = require("repository.scraper")(database)
    self.rateLimitedHttps = rateLimitedHttps
    self.mediaTypeProvider = mediaTypeProvider

    -- configure which scrapers to use
    self._scrapers = {
        file = require("module.filescraper")(self.environment, self.logger),
        libretro = require("module.libretro.scraper")(self.environment, self.logger, self.platform),
        screenscraper = require("module.screenscraper.scraper")(
            self.environment,
            self.platform,
            self.logger,
            self.rateLimitedHttps,
            self.mediaRepository,
            self.scraperRepository
        ),
        steamgriddb = require("module.steamgriddb.scraper")(
            self.environment,
            self.platform,
            self.logger,
            self.mediaRepository,
            self.scraperRepository
        ),
    }
end

function M:getDefinedScrapers()
    return {
        file = self._scrapers.file,
        libretro = self._scrapers.libretro,
        screenscraper = self._scrapers.screenscraper,
        steamgriddb = self._scrapers.steamgriddb,
    }
end

function M:getScraperSupportedTypes(id)
    local supported = {
        file = { "screenshot", "box2d", "box3d", "wheel", "grid1x1", "grid2x3" },
        libretro = { "screenshot", "box2d", "wheel" },
        screenscraper = { "screenshot", "box2d", "box3d", "wheel" },
        steamgriddb = { "wheel", "grid1x1", "grid2x3" },
    }
    local types = supported[id]
    if types == nil then
        error("unknown scraper id: " .. id)
    end
    return types
end

function M:_getDefaultScraperByType(mediaType)
    return "screenscraper"
end

---Gets scrapers defaulting to currently configured, but allowing an override
---@param opts? table list of scraper keys
---@return table
function M:getScrapers(opts)
    opts = opts or {}
    local scrapers = {}
    if opts.ids and type(opts.ids) == "table" then
        for index, name in ipairs(opts.ids) do
            if not self:getDefinedScrapers()[name] then
                error("cannot get unknown scraper: " .. name)
            end
            table.insert(scrapers, { id = name, module = self:getDefinedScrapers()[name] })
        end
    else
        if self.environment:getConfig("scraper_file_enabled") then
            table.insert(scrapers, { id = "file", module = self:getDefinedScrapers().file })
        end
        if self.environment:getConfig("scraper_libretro_enabled") then
            table.insert(scrapers, { id = "libretro", module = self:getDefinedScrapers().libretro })
        end
        if self.environment:getConfig("scraper_screenscraper_enabled") then
            table.insert(scrapers, { id = "screenscraper", module = self:getDefinedScrapers().screenscraper })
        end
        if self.environment:getConfig("scraper_steamgriddb_enabled") then
            table.insert(scrapers, { id = "steamgriddb", module = self:getDefinedScrapers().steamgriddb })
        end
    end

    -- filter by supported type if types provided
    if not opts.types then
        return scrapers
    end

    local filtered = {}
    for _, tuple in ipairs(scrapers) do
        local supported = self:getScraperSupportedTypes(tuple.id)
        if table.any(opts.types, function(typ)
            return table.contains(supported, typ)
        end) then
            table.insert(filtered, tuple)
        end
    end

    -- order according to priority
    local scraperOrder = self.environment:getConfig("scraper_priority") or {}

    -- order according to priority
    local priority = {}
    for i, id in ipairs(scraperOrder) do
        priority[id] = i
    end

    table.sort(filtered, function(a, b)
        return (priority[a.id] or 100) < (priority[b.id] or 100)
    end)

    return filtered
end

function M:getScraperKeysWithOptions()
    local s = {}
    for _, tuple in ipairs(self:getScrapers()) do
        --- @todo do scrapers need options here? both currently empty
        if tuple.module.getOptions then
            s[tuple.id] = tuple.module:getOptions()
        else
            s[tuple.id] = {}
        end
    end
    return s
end

function M:orchestrate(options)
    self.logger:log("info", "scraper", "starting rom scrape process")
    local tasks = {}
    local platforms = options and options.platforms or nil
    -- select roms from database then produce tasks from them
    local roms = self.romRepository:getFreshRoms(platforms)
    local steps = {}
    for __, row in ipairs(roms) do
        local task = {
            type = "scrapeOne",
            parameters = {
                romUuid = row.uuid,
                options = {
                    scrapers = self:getScraperKeysWithOptions(),
                    overwrite = self.environment:getConfig("scraper_overwrite"),
                    batch = true,
                },
            },
        }
        table.insert(steps, row.filename)
        table.insert(tasks, task)
    end

    return {
        tasks = tasks,
        threads = self.environment:getConfig("scraper_screenscraper_threads"),
        steps = steps,
        text = "Scraping Roms",
    }
end

function M:scrapeOne(romUuid, options)
    if not options or not options.scrapers or not next(options.scrapers) then
        self.logger:log("error", "scraper", "Cannot scrape as no currently enabled scrapers")
        return { status = self.thread.TASK_STATUS.fail }
    end

    local scrapers = self:getScrapers({ ids = table.keys(options.scrapers) })

    self.logger:log(
        "debug",
        "scraper",
        string.format("Scraping rom uuid='%s' with options:\n %s", romUuid, pretty.string(options))
    )

    -- set options into the scrapers if provided via the task
    -- @todo this isn't currently being used, can we remove it?
    for id, scraperOpts in pairs(options.scrapers) do
        for _, tuple in ipairs(scrapers) do
            if tuple.id == id and tuple.module.setOptions then
                tuple.module:setOptions(scraperOpts)
            end
        end
    end

    -- when this option is true then existing media will be rescraped
    local overwrite = options and options.overwrite or false
    local requestedTypes = options.mediaTypes and options.mediaTypes or self.mediaTypeProvider:getMediaTypes()

    -- using this option uses any 'alternate' platforms the rom might have
    -- and then if the romname is a '.zip' does a match on the dat file agains the filename to extract a "name" for the datfile
    -- this is useful when the .zip cannot be crc32 checked and therefore the rom search name is short/gibberish vs a more useful 'real' name from a datfile
    local fuzzyMatchRomfile = true

    local fuzzyPlatforms = nil
    if fuzzyMatchRomfile then
        local romPlatform = self.romRepository:getPlatformForRom(romUuid)
        if not romPlatform then
            error("Rom not found, could not get platform")
        end
        fuzzyPlatforms = { romPlatform }

        local p = self.platform:getPlatformByKey(romPlatform)
        if p.alternate then
            for _, altP in ipairs(p.alternate) do
                table.insert(fuzzyPlatforms, altP)
            end
        end
    end

    local rom = self.romRepository:getRomWithMediaForScraping(romUuid, fuzzyPlatforms)
    if rom.uuid == nil then
        error("Could not scrape for unknown rom # " .. romUuid .. " \n" .. pretty.string(rom))
        return { status = self.thread.TASK_STATUS.fail }
    end

    -- 'overwrite' variable = true prevents scraping for types we already have
    local scrapeTypes = {}
    for _, typ in ipairs(requestedTypes) do
        -- not in 'overwrite' mode
        if overwrite == false and rom.media[typ] then
            -- do nothing
        else
            table.insert(scrapeTypes, typ)
        end
    end

    -- options.batch only used to supress this warning in batch mode
    if #scrapeTypes == 0 and not options.batch then
        return {
            status = self.thread.TASK_STATUS.ok,
            logs = {
                {
                    level = "warn",
                    channel = "scrape",
                    message = "All media present, overwrite = false, nothing to do here!",
                },
            },
        }
    end

    local result = {}
    local downloadedCount = 0
    local scrapeRemaining = table.shallow_copy(scrapeTypes)
    if next(scrapeTypes) then
        for i, scraperTuple in ipairs(scrapers) do
            -- we scrapin
            local scraper = scraperTuple.module
            local scraperId = scraperTuple.id

            local supported = self:getScraperSupportedTypes(scraperTuple.id)

            if
                next(scrapeRemaining)
                and table.any(scrapeRemaining, function(t)
                    return table.contains(supported, t)
                end)
            then
                -- only scrape for types supported by the scraper
                local scrapeSupported = {}
                for _, typ in ipairs(scrapeRemaining) do
                    if table.contains(supported, typ) then
                        table.insert(scrapeSupported, typ)
                    end
                end
                local matches = scraper:scrape(rom, scrapeSupported)

                if not next(matches) then
                    self.logger:log(
                        "debug",
                        "scraper",
                        string.format(
                            "scraper: `%s` yielded no matches for: %s(%s)",
                            scraperTuple.id,
                            rom.romname,
                            rom.platform
                        )
                    )
                end
                for typ, url in pairs(matches) do
                    local uuid = identifier.uuid4()

                    local localFilename, err
                    if type(scraper.downloadMedia) == "function" then
                        -- allow scraper to handle its own downloads
                        localFilename, err = scraper:downloadMedia(url, typ, uuid)
                    else
                        localFilename, err = self:downloadMedia(url, typ, uuid)
                    end

                    if not localFilename then
                        result.status = self.thread.TASK_STATUS.fail
                        self.logger:log(
                            "error",
                            "scraper",
                            string.format("error when downloading media:\n%s\n%s", url, err)
                        )
                        break
                    end

                    downloadedCount = downloadedCount + 1

                    -- if media for this type already exists then we need to delete it
                    if rom.media[typ] then
                        self.mediaRepository:deleteMedia(rom.media[typ].uuid)
                        rom.media[typ] = nil
                    end

                    -- create media
                    if type(scraper.createMedia) == "function" then
                        -- allow scraper to create its own media if it wants to
                        scraper:createMedia(uuid, localFilename, typ, url, rom.uuid)
                    else
                        self.mediaRepository:createMedia(uuid, localFilename, typ, scraperId, url, rom.uuid)
                    end

                    -- remove from scrapeRemaining
                    table.remove_value(scrapeRemaining, typ)
                end
            end
        end
    end

    if result.status == nil then
        result.status = self.thread.TASK_STATUS.ok
    end

    result.logs = {
        {
            level = "info",
            channel = "scraper",
            handler = "console",
            message = string.format(
                "Scraped %i images for rom: %s (platform: %s)",
                downloadedCount,
                rom.romname,
                rom.platform
            ),
        },
    }

    return result
end

--- used after searching to create media from scraped
function M:createMedia(scraperId, scraper, uuid, filename, typ, url, romUuid)
    -- deletes existing media
    self.mediaRepository:deleteMediaFromRomWithType(romUuid, typ)

    -- create media
    if type(scraper.createMedia) == "function" then
        -- allow scraper to create its own media if it wants to
        scraper:createMedia(uuid, filename, typ, url, romUuid)
    else
        self.mediaRepository:createMedia(uuid, filename, typ, scraperId, url, romUuid)
    end
end

function M:searchOne(romUuid, scraperId, mediaType, options)
    -- first some cleanup, clear the tmp folder out
    local cleanupTmpCmd =
        string.format("rm -rf %s", stringUtil.shellQuote(path.join(self.environment:getPath("cache"), "tmp")))
    os.execute(cleanupTmpCmd)

    local scraperTuple = self:getScrapers({ ids = { scraperId } })[1]

    self.logger:log(
        "debug",
        "scraper",
        string.format(
            "Searching rom uuid='%s', type='%s' with options:\n %s",
            romUuid,
            mediaType,
            pretty.string(options)
        )
    )

    -- using this option uses any 'alternate' platforms defined by the primary platform of the given rom
    -- and then if the romname is a '.zip' does a match on the dat file agains the filename to extract a "name" for the datfile
    -- this is useful when the .zip cannot be crc32 checked and therefore the rom search name is short/gibberish vs a more useful 'real' name from a datfile
    local fuzzyMatchRomfile = true

    local fuzzyPlatforms = nil
    if fuzzyMatchRomfile then
        local romPlatform = self.romRepository:getPlatformForRom(romUuid)
        if not romPlatform then
            error("Rom not found, could not get platform")
        end
        fuzzyPlatforms = { romPlatform }

        local p = self.platform:getPlatformByKey(romPlatform)
        if p.alternate then
            for _, altP in ipairs(p.alternate) do
                table.insert(fuzzyPlatforms, altP)
            end
        end
    end

    local rom = self.romRepository:getRomWithMediaForScraping(romUuid, fuzzyPlatforms)
    if rom.uuid == nil then
        error("Could not scrape for unknown rom # " .. romUuid .. " \n" .. pretty.string(rom))
        return { status = self.thread.TASK_STATUS.fail }
    end

    local result = {}

    -- we scrapin
    local scraper = scraperTuple.module
    local matches = scraper:search(rom, { mediaType })

    if not next(matches) then
        self.logger:log(
            "debug",
            "scraper",
            string.format("scraper: `%s` yielded no matches for: %s(%s)", scraperTuple.id, rom.romname, rom.platform)
        )
    end

    local downloadedMatches = {}
    local downloadTasks = {}
    for _, url in ipairs(matches) do
        local uuid = identifier.uuid4()
        table.insert(downloadTasks, {
            type = "download",
            uuid = uuid,
            parameters = {
                uuid = uuid,
                assetType = "tmp",
                remotePath = url,
                scraperId = scraperTuple.id,
            },
        })
    end

    -- get results
    local results = self.thread:demandAll("scraper_download", downloadTasks, { timeout = 10 })

    for _, r in ipairs(results) do
        local res = r.result
        local localFilename = res and res.path or nil
        local url = res and res.url or nil
        local err = res and res.error

        if not localFilename then
            result.status = self.thread.TASK_STATUS.fail
            self.logger:log("error", "scraper", string.format("error when downloading media:\n%s\n%s", url, err))
        else
            table.insert(
                downloadedMatches,
                { path = media.mediaPath(self.environment:getPath("cache"), "tmp", localFilename), url = url }
            )
        end
    end

    if result.status == nil then
        result.status = self.thread.TASK_STATUS.ok
    end

    result.data = downloadedMatches

    return result
end

function M:downloadMedia(remotePath, assetType, uuid)
    local options = {}
    local requesturl = remotePath

    local filenameExtension = path.extension(remotePath, { "png", "jpg", "jpeg" }) or "png"
    local localFilename = uuid .. "." .. filenameExtension

    local code, body = https.request(requesturl, options)

    if code ~= 200 then
        self.logger:log(
            "warn",
            "scraper",
            string.format(
                "Media download failed for:\npath: %s\nbody: %s\nresponsecode: %s",
                remotePath,
                pretty.string(body),
                code
            )
        )
        return nil
    else
        self.logger:log("info", "scraper", "Media downloaded: " .. remotePath)
    end

    local cacheFolder =
        path.join({ self.environment:getPath("cache"), assetType, stringUtil.uuidToFolder(localFilename) })

    local assetPath = path.join({ cacheFolder, localFilename })

    local result, writeError
    local maxAttempts = 5
    for attempt = 1, maxAttempts do
        -- ensure directory exists
        local okDir, dirErr = pcall(filesystem.createDirectory, cacheFolder)

        if not okDir then
            writeError = dirErr
        else
            -- attempt to write the file
            result, writeError = filesystem.write(assetPath, body)
        end

        if result then
            break
        end

        if attempt < maxAttempts then
            socket.sleep(0.2)
        else
            self.logger:log(
                "error",
                "scraper",
                string.format(
                    "Failed on final attempt creating directory or writing file:\nDir error: %s\nWrite error: %s",
                    tostring(dirErr),
                    tostring(writeError)
                )
            )
        end
    end

    if not result then
        self.logger:log(
            "error",
            "scraper",
            string.format(
                "Error saving file to disk (%s), downloaded from: %s\nerror: %s",
                assetPath,
                remotePath,
                writeError
            )
        )
        return nil
    end

    -- convert to png if it's a jpg (assumes file can be opened by libvips)
    return path.basename(image.ensurePng(assetPath))
end

return M
