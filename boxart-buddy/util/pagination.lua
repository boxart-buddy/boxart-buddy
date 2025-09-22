local M = {}

function M.getPagination(count, limit, currentPage)
    local totalPages = math.ceil(count / limit)
    local maxVisible = 5
    local pages = {}

    -- Clamp currentPage
    currentPage = math.max(1, math.min(currentPage, totalPages))

    local startPage, endPage

    if totalPages <= maxVisible then
        -- Show all pages
        startPage = 1
        endPage = totalPages
    elseif currentPage <= 3 then
        -- Beginning of range
        startPage = 1
        endPage = 5
    elseif currentPage >= totalPages - 2 then
        -- End of range
        startPage = totalPages - 4
        endPage = totalPages
    else
        -- Middle of range
        startPage = currentPage - 2
        endPage = currentPage + 2
    end

    for i = startPage, endPage do
        table.insert(pages, i)
    end

    return {
        max = totalPages,
        limit = limit, -- number of results per page
        count = count, -- total number of results
        pageCount = totalPages,
        current = currentPage, -- current page
        pages = pages, -- list of page numbers (for display)
    }
end

return M
