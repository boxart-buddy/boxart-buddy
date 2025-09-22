local https = require("https")
local url = require("socket.url")
local filesystem = require("lib.nativefs")
local path = require("util.path")

local baseUrl = "https://thumbnails.libretro.com/"

---@class LibretroThumbCrawler
local M = class({
    name = "LibretroThumbCrawler",
})

function M:new(logger, environment, systemeventsubscriber, thread)
    self.logger = logger
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.thread = thread
end

-- Fetch a URL using lua-https
local function fetchUrl(targetUrl)
    local code, body = https.request(targetUrl)
    if code ~= 200 then
        return nil, "Failed to fetch: " .. targetUrl .. " (HTTP " .. tostring(code) .. ")"
    end
    return body
end

-- Extract <a href="..."> links
local function extractLinks(html)
    local links = {}
    for href in html:gmatch('<a href="(.-)">') do
        if href ~= "../" then
            table.insert(links, href)
        end
    end
    return links
end

-- Count folder depth relative to root
local function getDepth(path)
    local count = 0
    for _ in path:gmatch("[^/]+/") do
        count = count + 1
    end
    return count
end

-- Recursively crawl folders and collect file paths
local function crawlFolder(baseUrl, relativePath, results, visited)
    if visited[relativePath] then
        return
    end
    visited[relativePath] = true

    local depth = getDepth(relativePath)
    if depth > 2 then
        return
    end

    local targetUrl = baseUrl .. relativePath
    local html, err = fetchUrl(targetUrl)
    if not html then
        error(err)
        return
    end

    for _, entry in ipairs(extractLinks(html)) do
        if entry:lower():match("%.png$") then
            table.insert(results, relativePath .. entry)
        elseif entry:sub(-1) == "/" then
            local nextPath = relativePath:gsub("/+$", "") .. "/" .. entry
            crawlFolder(baseUrl, nextPath, results, visited)
        end
    end
end

-- Get top-level folders from the root
local function getTopLevelFolders()
    local html, err = fetchUrl(baseUrl)
    if not html then
        error(err)
    end

    local folders = {}
    for _, link in ipairs(extractLinks(html)) do
        if link:sub(-1) == "/" then
            table.insert(folders, link)
        end
    end
    return folders
end

-- Decode %20 etc. from folder name
local function decodeUrl(encoded)
    return url.unescape(encoded:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

function M:requestOrchestrate()
    self.thread:push("orchestrator", { type = "crawl_libretro_thumbs", threadKey = "crawl_libretro_thumbs" })
    self.systemeventsubscriber:publish("orchestrate_requested", { type = "crawl_libretro_thumbs" })
end

function M:orchestrate()
    -- hardcoded single task - seems like this doesnt need to be orchestrated at all really......
    return { tasks = { { type = "generateAll" } } }
end

-- Write all results into a .txt file per top-level folder
function M:generateAll()
    local folders = getTopLevelFolders()

    -- max number of files to generate, for debugging
    local counter = 0
    local max = 400

    for _, folder in ipairs(folders) do
        local decodedName = decodeUrl(folder:gsub("/$", ""))
        local outputFileName = decodedName .. ".lua"

        if counter > max then
            self.logger:log("debug", "libretrothumb", "SKIPPING: " .. outputFileName)
        else
            local results = {}
            local visited = {} -- TRACK visited folders for this crawl only

            local fullFilePath = path.join({ self.environment:getPath("libretro_thumb_dictionary"), outputFileName })
            self.logger:log("debug", "libretrothumb", "Crawling: " .. folder)

            crawlFolder(baseUrl, folder, results, visited)
            table.sort(results)

            -- wipe existing file
            filesystem.write(fullFilePath, "")

            -- Begin Lua table
            filesystem.write(fullFilePath, "return {\n")
            for _, path in ipairs(results) do
                local relative = decodeUrl(path:sub(#folder + 1))
                local line = string.format("  %q,\n", relative)
                local ok, err = filesystem.append(fullFilePath, line)
                if not ok then
                    print("Failed to write to file:", tostring(err))
                end
            end
            -- End Lua table

            filesystem.append(fullFilePath, "}\n")

            self.logger:log("debug", "libretrothumb", "Saved: " .. outputFileName)

            counter = counter + 1
        end
    end
end

return M
