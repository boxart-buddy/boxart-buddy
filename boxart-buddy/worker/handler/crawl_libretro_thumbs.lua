---@class CrawlLibretroThumbsHandler
local M = class({
    name = "CrawlLibretroThumbsHandler",
    implements = { require("worker.handler.abstract") },
})

function M:new(DIC)
    self.DIC = DIC
    return self
end

function M:handle(task)
    task.parameters = task.parameters or {}
    local libretroCrawler = require("boxart-buddy.module.libretro_thumb_crawler")(
        self.DIC.logger,
        self.DIC.environment,
        self.DIC.systemeventsubscriber,
        self.DIC.thread
    )

    if task.type == "generateAll" then
        if task.type == "generateAll" then
            return pcall(function()
                libretroCrawler:generateAll()
            end)
        end
    end
    error("cannot handle unknown task type: " .. task.type)
end

return M
