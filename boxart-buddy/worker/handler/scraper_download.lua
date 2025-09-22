-- only used by the interactive version of the scraper
---@class ScrapeDownloadHandler
local M = class({
    name = "ScraperDownloadHandler",
    implements = { require("worker.handler.abstract") },
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:handle(task)
    task.parameters = task.parameters or {}

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

    if task.type == "download" then
        return pcall(function()
            local subScraper = scraper:getDefinedScrapers()[task.parameters.scraperId]
            local path
            -- if scraper implements its own download function then use that, else use fallback
            if subScraper and type(subScraper.downloadMedia) == "function" then
                path = subScraper:downloadMedia(
                    task.parameters.remotePath,
                    task.parameters.assetType,
                    task.parameters.uuid
                )
            else
                path =
                    scraper:downloadMedia(task.parameters.remotePath, task.parameters.assetType, task.parameters.uuid)
            end
            return { path = path, url = task.parameters.remotePath }
        end)
    end
    error("cannot handle unknown task type: " .. task.type)
end

return M
