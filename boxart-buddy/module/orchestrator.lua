---@class Orchestrator
local M = class({
    name = "Orchestrator",
})

function M:new(DIC)
    -- this is an antipattern, dont do it anywhere else
    self.DIC = DIC
end

function M:request(type, parameters)
    if type == "import_dat" then
        self.DIC.thread:push("orchestrator", { type = "import_dat", threadKey = "import_dat" })
        self.DIC.systemeventsubscriber:publish("orchestrate_requested", { type = "import_dat" })
    elseif type == "scrape_roms" then
        self.DIC.thread:push(
            "orchestrator",
            { type = "scrape_roms", threadKey = "scrape_roms", parameters = parameters }
        )
        self.DIC.systemeventsubscriber:publish(
            "orchestrate_requested",
            { type = "scrape_roms", text = "Scraping Roms" }
        )
    elseif type == "crawl_libretro_thumbs" then
        self.DIC.thread:push("orchestrator", { type = "crawl_libretro_thumbs", threadKey = "crawl_libretro_thumbs" })
        self.DIC.systemeventsubscriber:publish("orchestrate_requested", { type = "crawl_libretro_thumbs" })
    elseif type == "scan_roms" then
        self.DIC.thread:push("orchestrator", { type = "scan_roms", threadKey = "scan_roms", parameters = parameters })
        self.DIC.systemeventsubscriber:publish(
            "orchestrate_requested",
            { type = "scan_roms", text = "Scanning rom folders" }
        )
    elseif type == "mix" then
        self.DIC.thread:push("orchestrator", { type = "mix", threadKey = "mix", parameters = parameters })
        self.DIC.systemeventsubscriber:publish("orchestrate_requested", { type = "mix", text = "Generating Mixes" })
    elseif type == "pack" then
        self.DIC.thread:push("orchestrator", { type = "pack", threadKey = "pack", parameters = parameters })
        self.DIC.systemeventsubscriber:publish("orchestrate_requested", { type = "pack" })
    end
end

function M:orchestrate(type, parameters)
    if type == "import_dat" then
        local datimporter = require("module.datimporter")(
            self.DIC.systemeventsubscriber,
            self.DIC.database,
            self.DIC.logger,
            self.DIC.environment,
            self.DIC.thread,
            self.DIC.platform
        )
        return datimporter:orchestrate()
    elseif type == "scan_roms" then
        local romScanner = require("module.romscanner")(
            self.DIC.environment,
            self.DIC.logger,
            self.DIC.database,
            self.DIC.platform,
            self.DIC.thread,
            self.DIC.systemeventsubscriber
        )
        if parameters and parameters.romRelativePath then
            return romScanner:orchestrate(parameters.romRelativePath)
        else
            return romScanner:orchestrate()
        end
    elseif type == "crawl_libretro_thumbs" then
        local libretroThumbCrawler = require("module.libretro.thumb_crawler")(
            self.DIC.logger,
            self.DIC.environment,
            self.DIC.systemeventsubscriber,
            self.DIC.thread
        )
        return libretroThumbCrawler:orchestrate()
    elseif type == "scrape_roms" then
        local scraper = require("module.scraper")(
            self.DIC.environment,
            self.DIC.logger,
            self.DIC.systemeventsubscriber,
            self.DIC.database,
            self.DIC.platform,
            self.DIC.thread,
            self.DIC.ratelimithttps,
            self.DIC.mediaTypeProvider
        )

        if parameters and parameters.options then
            return scraper:orchestrate(parameters.options)
        else
            return scraper:orchestrate()
        end
    elseif type == "mix" then
        local mixer = require("module.mixer")(
            self.DIC.environment,
            self.DIC.logger,
            self.DIC.database,
            self.DIC.mixStrategyProvider
        )
        return mixer:orchestrate(
            parameters.strategyName,
            { mixOptions = parameters.mixOptions, platforms = parameters.platforms }
        )
    elseif type == "pack" then
        local mixer = require("module.packer")(
            self.DIC.environment,
            self.DIC.logger,
            self.DIC.database,
            self.DIC.platform,
            self.DIC.mixStrategyProvider
        )
        return mixer:orchestrate({ platforms = parameters.platforms })
    else
        error(string.format("Cannot orchestrate for unknown type %s", type))
    end
end

return M
