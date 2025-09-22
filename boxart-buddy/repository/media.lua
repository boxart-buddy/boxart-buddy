local filesystem = require("lib.nativefs")
local path = require("util.path")
local mediaUtil = require("util.media")
local QueryBuilder = require("repository.querybuilder")

---@class MediaRepository
local M = class({
    name = "MediaRepository",
})

function M:new(database, environment)
    self.database = database
    self.environment = environment
end

---Create media and optionally create a link with a rom
---@param uuid string
---@param typ string
---@param source string
---@param sourceFilename string
---@param romUuid string
function M:createMedia(uuid, localFilename, typ, source, sourceFilename, romUuid)
    -- ensure this type doesn't already exist for this rom
    if self:romHasMediaType(romUuid, typ) then
        error(
            string.format(
                "Media with type '%s' already exists for rom '%s'. Cannot duplicate. The old media must be deleted before inserting new",
                typ,
                romUuid
            )
        )
    end

    local params = {
        uuid = uuid,
        filename = localFilename,
        type = typ,
        source = source,
        sourceFilename = sourceFilename,
    }
    local mediaInsertSql =
        "INSERT INTO media (uuid, filename, type, source, source_filename) VALUES (:uuid, :filename, :type, :source, :sourceFilename)"

    local mediaInsertResult = self.database:blockingExec(mediaInsertSql, params)

    if romUuid == nil then
        return
    end

    local mediaRomInsertSql = "INSERT INTO media_rom (media_uuid, rom_uuid) VALUES (:mediaUuid, :romUuid)"
    self.database:blockingExec(mediaRomInsertSql, { mediaUuid = uuid, romUuid = romUuid })
end

---@param uuid string
---@return table
function M:deleteMedia(uuid)
    local selectSql = "SELECT media.uuid, type, filename FROM media where uuid = :uuid" -- should auto cascade and delete from media_rom as well
    local media = self.database:blockingSelect(selectSql, { uuid = uuid })

    filesystem.remove(mediaUtil.mediaPath(self.environment:getPath("cache"), media[1].type, media[1].filename))

    local deleteSql = "DELETE FROM media WHERE uuid = :uuid"
    return self.database:blockingExec(deleteSql, { uuid = uuid })
end

function M:deleteMediaFromRomWithType(romUuid, typ)
    local selectSql =
        "SELECT media.uuid, media.filename FROM media INNER JOIN media_rom ON media_rom.media_uuid = media.uuid INNER JOIN rom ON rom.uuid = media_rom.rom_uuid WHERE media.type = :type AND rom.uuid = :romUuid"
    local rows = self.database:blockingSelect(selectSql, { romUuid = romUuid, type = typ })
    for _, media in ipairs(rows) do
        filesystem.remove(mediaUtil.mediaPath(self.environment:getPath("cache"), typ, media.filename))
        local deleteSql = "DELETE FROM media WHERE uuid = :uuid"
        self.database:blockingExec(deleteSql, { uuid = media.uuid })
    end
end

---@param romUuid string
---@param typ string a valid media type
---@return boolean
function M:romHasMediaType(romUuid, typ)
    local typeExistsSql =
        "SELECT 1 as typeexists FROM media INNER JOIN media_rom on media_rom.media_uuid = media.uuid WHERE media.type=:typ AND media_rom.rom_uuid = :romUuid"
    local typeExists = self.database:blockingSelect(typeExistsSql, { romUuid = romUuid, typ = typ })
    if next(typeExists) then
        return true
    end
    return false
end

function M:hasMedia()
    local qb = QueryBuilder()
    qb:select("media.uuid")
    qb:from("media")
    qb:orderBy("media.created LIMIT 1")

    local sql = qb:getQuery()
    local result = self.database:blockingSelect(sql)
    if not next(result) then
        return false
    end
    return true
end

return M
