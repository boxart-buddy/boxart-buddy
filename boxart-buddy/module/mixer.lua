local mediaUtil = require("util.media")
local filesystem = require("lib.nativefs")
local path = require("util.path")
local Thread = require("module.thread")
local colors = require("util.colors")

---@class Mixer
local M = class({
    name = "Mixer",
})

function M:new(environment, logger, database, mixStrategyProvider)
    self.environment = environment
    self.logger = logger
    self.mixStrategyProvider = mixStrategyProvider

    self.romRepository = require("repository.rom")(database)
    self.mediaRepository = require("repository.media")(database, environment)
    self.orchestrator = require("module.mix.orchestrator")(environment)

    -- register strategies
    for k, s in pairs(self.mixStrategyProvider:getKeyedStrategies()) do
        self.orchestrator:register(k, require(s))
    end
end

function M:orchestrate(strategyName, options)
    self.logger:log("info", "mixed", "starting mix process")
    local tasks = {}
    local steps = {}
    local platforms = options and options.platforms or nil
    local mixOptions = options and options.mixOptions or {}

    -- select roms from database then produce tasks from them
    local roms = self.romRepository:getFreshRoms(platforms)
    for __, row in ipairs(roms) do
        local task = {
            type = "mix",
            parameters = {
                romUuid = row.uuid,
                strategyName = strategyName,
                options = {
                    overwrite = self.environment:getConfig("mix_overwrite"),
                    mixOptions = mixOptions,
                },
            },
        }
        table.insert(tasks, task)
        table.insert(steps, row.filename)
    end

    return { tasks = tasks, steps = steps, text = "Generating Mixes" }
end

function M:mixPreview(romUuid, strategyName, options)
    local mixOptions = options.mixOptions or {}
    local mixUuid = identifier.uuid4()
    local mixFilename = string.format("%s.png", mixUuid)
    local absoluteDirectory = path.join(self.environment:getPath("cache"), "preview", "mix")
    local absoluteFilename = path.join(absoluteDirectory, mixFilename)

    if romUuid == nil then
        romUuid = self.romRepository:getRandomRomUuid()
        if not romUuid then
            error("cannot generate mix preview without any roms")
        end
    end

    --load roms / get media paths
    local platform = self.romRepository:getPlatformForRom(romUuid)
    local media = self.romRepository:getMediaForRom(romUuid)
    local mediaPaths = {}
    for typ, dat in pairs(media) do
        mediaPaths[typ] = mediaUtil.mediaPath(self.environment:getPath("cache"), typ, dat.filename)
    end

    -- ensure output dir
    if not filesystem.getInfo(path.dirname(absoluteFilename)) then
        filesystem.createDirectory(path.dirname(absoluteFilename))
    end

    -- delete all existing previews
    local cmd = string.format("rm -rf %s/*.png", absoluteDirectory)
    os.execute(cmd)

    local outPath = self.orchestrator:render(
        strategyName,
        mediaPaths,
        platform,
        mixOptions,
        self.romRepository:getOptionsForRom(romUuid),
        absoluteFilename
    )
    self.logger:log("info", "mix", string.format("Generated mix preview at: %s", absoluteFilename))

    -- delete, for testing only
    --socket.sleep(2)

    return {
        status = Thread.TASK_STATUS.ok,
        data = { previewPath = outPath },
    }
end

function M:mix(romUuid, strategyName, options)
    local mixOptions = options.mixOptions or {}
    if options and options.overwrite == false then
        -- check if mix already exists and return early
        if self.mediaRepository:romHasMediaType(romUuid, "mix") then
            self.logger:log(
                "info",
                "mix",
                string.format("Mix already exists for rom '%s'. Skipping because overwrite mode false", romUuid)
            )
            return
        end
    end
    local mixUuid = identifier.uuid4()
    local mixFilename = string.format("%s.png", mixUuid)
    local absoluteFilename = mediaUtil.mediaPath(self.environment:getPath("cache"), "mix", mixFilename)

    --load roms / get media paths
    local platform = self.romRepository:getPlatformForRom(romUuid)
    local media = self.romRepository:getMediaForRom(romUuid)
    local mediaPaths = {}
    for typ, dat in pairs(media) do
        mediaPaths[typ] = mediaUtil.mediaPath(self.environment:getPath("cache"), typ, dat.filename)
    end

    -- ensure output dir
    if not filesystem.getInfo(path.dirname(absoluteFilename)) then
        filesystem.createDirectory(path.dirname(absoluteFilename))
    end

    local outPath = self.orchestrator:render(
        strategyName,
        mediaPaths,
        platform,
        mixOptions,
        self.romRepository:getOptionsForRom(romUuid),
        absoluteFilename
    )

    if not filesystem.getInfo(outPath, "file") then
        self.logger:log(
            "error",
            "mix",
            string.format("Mix generation failed. \nfilename: %s\nromUuid:%s", absoluteFilename, romUuid)
        )
        return
    end

    -- create media object
    if self.mediaRepository:romHasMediaType(romUuid, "mix") then
        self.mediaRepository:deleteMediaFromRomWithType(romUuid, "mix")
    end
    self.mediaRepository:createMedia(mixUuid, mixFilename, "mix", "mixer", "localhost", romUuid)

    self.logger:log("info", "mix", string.format("Generated mix at: %s", absoluteFilename))
end

return M
