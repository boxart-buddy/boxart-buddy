local filesystem = require("lib.nativefs")
local path = require("util.path")
local mediaUtil = require("util.media")
local stringUtil = require("util.string")
local zip = require("module.zip")()
local image = require("util.image")

---@class Packer
local M = class({
    name = "Packer",
})

function M:new(environment, logger, database, platform, mixStrategyProvider)
    self.environment = environment
    self.logger = logger
    self.platform = platform
    self.mixStrategyProvider = mixStrategyProvider
    self.romRepository = require("repository.rom")(database)
    self.mediaRepository = require("repository.media")(database, environment)
end

function M:orchestrate(options)
    options = options or {}
    self.logger:log("info", "mixed", "starting pack process")
    local tasks = {}
    local steps = {}
    local platforms = options and options.platforms or nil
    local archive = self.environment:getConfig("pack_archive")

    -- select roms from database then produce tasks from them
    local roms = self.romRepository:getFreshRoms(platforms)
    for __, row in ipairs(roms) do
        local task = {
            type = "packOne",
            parameters = {
                romUuid = row.uuid,
                options = {
                    target = self.environment:getConfig("pack_sd_card"),
                    archive = archive,
                },
            },
        }
        table.insert(tasks, task)
        table.insert(steps, row.filename)
    end

    if archive then
        table.insert(tasks, {
            type = "archive",
            parameters = {},
        })
        table.insert(steps, "creating archive (wait)")
    end

    local orchestrationText = "Packing Images"
    if archive then
        orchestrationText = orchestrationText .. " (to archive)"
    end

    return { tasks = tasks, steps = steps, text = orchestrationText }
end

function M:packOne(romUuid, options)
    options = options or {}
    local pathOptions = {}
    if options.target ~= "auto" then
        pathOptions.force = options.target
    end

    local catalogPath = self.environment:getPath("catalog", pathOptions)

    if not filesystem.getInfo(catalogPath, "directory") then
        filesystem.createDirectory(catalogPath)
    end
    if not filesystem.getInfo(catalogPath, "directory") then
        error("Could not create pack output directory on target: " .. options.target)
    end

    local rom = self.romRepository:getRom(romUuid)
    local media = self.romRepository:getMediaForRom(romUuid)

    -- if using archive function then content needs to be staged prior to transfer, otherwise copy directly to the target
    local targetFolder = catalogPath
    if options.archive then
        targetFolder = path.join(self.environment:getPath("cache"), "catalog_temp")
        if not filesystem.getInfo(targetFolder, "directory") then
            filesystem.createDirectory(targetFolder)
        end
    end

    local targetMapping = {
        mix = "box",
        screenshot = "preview",
    }

    for _, typ in ipairs({ "mix", "screenshot" }) do
        if media[typ] then
            local p = self.platform:getPlatformByKey(rom.platform)
            local from = mediaUtil.mediaPath(self.environment:getPath("cache"), typ, media[typ].filename)
            local toDir = path.join(targetFolder, p.muos, targetMapping[typ])
            local to = path.join(toDir, path.swapExtension(rom.filename, "png"))
            local cmd = string.format(
                "mkdir -p %s && cp %s %s",
                stringUtil.shellQuote(toDir),
                stringUtil.shellQuote(from),
                stringUtil.shellQuote(to)
            )
            os.execute(cmd)

            -- hackish - resize preview to 515px (max allowed by muos)
            if typ == "screenshot" then
                local r, err = image.rescale(to, 515)
            end
        end
    end
end

function M:archiveTempToPackageFolder()
    local dateString = os.date("%Y-%m-%d_%H-%M-%S", os.time())

    local archiveNameStrategy = self.environment:getConfig("pack_archive_name_strategy")
    local archiveName = "bb"
    if archiveNameStrategy == "date" then
        archiveName = string.format("boxart_%s", dateString)
    elseif archiveNameStrategy == "custom" then
        archiveName = "boxart_" .. stringUtil.filenameSafe(self.environment:getConfig("pack_archive_name_custom"))
    end
    local outDir = self.environment:getPath("catalog_package")

    -- ensure archiveName is not already used and increment integer if it is
    local baseName = archiveName
    for i = 0, 1000 do
        local candidate = archiveName
        if i > 0 then
            candidate = string.format("%s%d", baseName, i)
        end
        local candidatePath = path.join(outDir, candidate .. ".muxcat")
        if not filesystem.getInfo(candidatePath) then
            archiveName = candidate
            break
        end
        if i == 1000 then
            error("Could not find free archive name after 1000 attempts")
        end
    end

    local inpath = path.join(self.environment:getPath("cache"), "catalog_temp")
    local outpath = path.join(outDir, archiveName .. ".tmp")
    zip:writeFolderToArchive(inpath, outpath, true)
    -- rename tmp to muxcat
    os.execute(
        string.format(
            "mv %s %s",
            stringUtil.shellQuote(outpath),
            stringUtil.shellQuote(path.swapExtension(outpath, "muxcat"))
        )
    )
end

return M
