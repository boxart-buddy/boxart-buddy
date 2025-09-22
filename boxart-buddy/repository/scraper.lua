---@class ScraperRepository
local M = class({
    name = "ScraperRepository",
})

function M:new(database)
    self.database = database
end

function M:insertSkip(url, scraper)
    local sql = "INSERT INTO scraper_skip (scraper, url) VALUES (:scraper, :url)"
    return self.database:blockingExec(sql, { url = url, scraper = scraper })
end

function M:shouldSkip(url, scraper, offsetDays)
    offsetDays = offsetDays or 7
    local sql = string.format(
        "SELECT 1 FROM scraper_skip WHERE url = :url AND scraper = :scraper AND created >= datetime('now', '-%s days')",
        offsetDays
    )
    local result = self.database:blockingSelect(sql, { url = url, scraper = scraper })
    return next(result) and true or false
end

return M
