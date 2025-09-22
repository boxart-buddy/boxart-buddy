---@class ScrapeRomsHandler
local M = class({
    name = "ScrapeRomsHandler",
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

    if task.type == "scrapeOne" then
        return pcall(function()
            local r = scraper:scrapeOne(task.parameters.romUuid, task.parameters.options)
            return r
        end)
    elseif task.type == "searchOne" then
        return pcall(function()
            return scraper:searchOne(
                task.parameters.romUuid,
                task.parameters.scraperId,
                task.parameters.mediaType,
                task.parameters.options
            )
        end)
    end
    error("cannot handle unknown task type: " .. task.type)
end

return M
