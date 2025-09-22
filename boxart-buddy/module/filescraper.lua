local path = require("util.path")
local filesystem = require("lib.nativefs")
local stringUtil = require("util.string")
local image = require("util.image")

---@class FileScraper
local M = class({
    name = "FileScraper",
})

function M:new(environment, logger)
    self.environment = environment
    self.logger = logger
end

function M:scrape(rom, scrapeTypes)
    -- filter to only those requested
    local filteredMatches = {}
    for _, typ in ipairs(scrapeTypes) do
        local match = self:getImageFromFilesystem(rom.platform, rom.filename, typ)
        if match then
            filteredMatches[typ] = match
        end
    end
    return filteredMatches
end

function M:search(rom, scrapeTypes)
    local transformed = {}
    local matches = self:scrape(rom, scrapeTypes)
    -- strip keys
    for typ, uri in pairs(matches) do
        table.insert(transformed, uri)
    end
    return transformed
end

---Returns the path for the file if it exists and nil if it doesnt
---@param platform string
---@param filename string
---@param typ string
---@return string?
function M:getImageFromFilesystem(platform, filename, typ)
    local extensions = { ".png", ".jpg", ".jpeg" }
    for _, ext in ipairs(extensions) do
        local absolutePath =
            path.join(self.environment:getPath("file_scraper"), platform, path.stem(filename), typ .. ext)
        if filesystem.getInfo(absolutePath, "file") then
            return absolutePath
        end
    end
    return nil
end

---Copies the file into the cache folder, leaving the original intact
---@param originalFilePath string
---@param typ string
---@param uuid string
---@return nil
function M:downloadMedia(originalFilePath, typ, uuid)
    local filenameExtension = path.extension(originalFilePath, { "png", "jpg", "jpeg" }) or "png"
    local localFilename = uuid .. "." .. filenameExtension

    local cacheFolder = path.join({ self.environment:getPath("cache"), typ, stringUtil.uuidToFolder(localFilename) })
    filesystem.createDirectory(cacheFolder) -- ensure directory exists

    local assetPath = path.join({ cacheFolder, localFilename })
    local originalFile = filesystem.read(originalFilePath)
    local result, writeError = filesystem.write(assetPath, originalFile)
    if not result then
        self.logger:log(
            "error",
            "scraper",
            string.format(
                "Error in file scraper, saving file to disk (%s), from path from: %s\nerror: %s",
                assetPath,
                originalFilePath,
                writeError
            )
        )
        return nil
    end

    -- convert to png if it's a jpg (assumes file can be opened by libvips)
    return path.basename(image.ensurePng(assetPath))
end

return M
