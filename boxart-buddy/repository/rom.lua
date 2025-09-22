local path = require("util.path")
local json = require("lib.json")
local QueryBuilder = require("repository.querybuilder")

---@class RomRepository
local M = class({
    name = "RomRepository",
})

function M:new(database)
    self.database = database
end

function M:getFreshRoms(platforms)
    local qb = QueryBuilder()
    qb:select("rom.uuid", "rom.filename")
    qb:from("rom")
    qb:where("rom.stale = 0")
    qb:where("rom.hidden = 0")
    qb:orderBy("rom.platform DESC")

    if platforms then
        qb:whereIn("rom.platform", platforms)
    end

    local sql = qb:getQuery()

    return self.database:blockingSelect(sql)
end

function M:hasRoms()
    local qb = QueryBuilder()
    qb:select("rom.uuid")
    qb:from("rom")
    qb:where("rom.stale = 0")
    qb:where("rom.hidden = 0")
    qb:orderBy("rom.created LIMIT 1")

    local sql = qb:getQuery()
    local result = self.database:blockingSelect(sql)
    if not next(result) then
        return false
    end
    return true
end

function M:getRandomRomUuid()
    local qb = QueryBuilder()
    qb:select("rom.uuid")
    qb:from("rom")
    qb:where("rom.stale = 0")
    qb:where("rom.hidden = 0")
    qb:orderBy("RANDOM() LIMIT 1")

    local sql = qb:getQuery()

    local result = self.database:blockingSelect(sql)
    if not next(result) then
        return nil
    end
    return result[1].uuid
end

---@return number
function M:getRomCount()
    local countQuery = "SELECT COUNT(*) as count FROM rom WHERE rom.stale = 0 AND rom.hidden=0"

    return tonumber(self.database:blockingSelect(countQuery)[1].count) or 0
end

function M:saveRomOptions(romUuid, romOptionsJson)
    local updateSql = "UPDATE rom SET options = :romOptionsJson WHERE rom.uuid = :romUuid"
    return self.database:blockingExec(updateSql, { romUuid = romUuid, romOptionsJson = romOptionsJson })
end

---@return number
function M:getErrorCount()
    local countQuery = "SELECT COUNT(*) as count FROM rom WHERE rom.stale = 0 AND rom.hidden=0 AND rom.error=1 "

    return tonumber(self.database:blockingSelect(countQuery)[1].count) or 0
end

---@param number number
---@param types table the types we are searching within
---@return number
function M:numberOfRomsWithNMedia(number, types)
    if not types then
        error("types must be passed to numberOfRomsWithNMedia")
    end
    if type(number) ~= "number" then
        error("`number` must be a number")
    end

    local countQuery = string.format(
        "SELECT COUNT(*) AS count FROM (SELECT mr.rom_uuid FROM rom r LEFT JOIN media_rom mr ON mr.rom_uuid = r.uuid JOIN media m ON mr.media_uuid = m.uuid WHERE r.hidden = 0 and r.stale = 0 AND m.type IN %s GROUP BY mr.rom_uuid HAVING COUNT(*) = %s) AS sub",
        QueryBuilder:tableToSqlInList(types),
        number
    )

    return tonumber(self.database:blockingSelect(countQuery)[1].count) or 0
end

function M:numberOfRomsWithMediaType(type)
    local countQuery = string.format(
        "SELECT COUNT(DISTINCT rom.uuid) AS count FROM rom JOIN media_rom ON rom.uuid = media_rom.rom_uuid JOIN media ON media.uuid = media_rom.media_uuid WHERE media.type = '%s' AND rom.hidden=0 AND rom.stale=0",
        type
    )
    return self.database:blockingSelect(countQuery)[1].count
end

function M:getVerifiedCount()
    local countQuery = [[
        SELECT COUNT(*) as count
        FROM rom
        WHERE rom.hidden = 0
          AND rom.stale = 0
          AND (
            rom.serial IS NOT NULL AND EXISTS (
              SELECT 1 FROM dat
              WHERE dat.serial = rom.serial
              ORDER BY dat.priority ASC
              LIMIT 1
            )
            OR (
              (rom.serial IS NULL OR NOT EXISTS (
                SELECT 1 FROM dat
                WHERE dat.serial = rom.serial
                ORDER BY dat.priority ASC
                LIMIT 1
              ))
              AND EXISTS (
                SELECT 1 FROM dat
                WHERE dat.crc32 = rom.crc32
                ORDER BY dat.priority ASC
                LIMIT 1
              )
            )
          )
    ]]

    return self.database:blockingSelect(countQuery)[1].count
end

function M:romExists(romRelativePath)
    local params = {
        folder = path.dirname(romRelativePath),
        filename = path.basename(romRelativePath),
    }

    local sql = "SELECT uuid FROM rom WHERE folder=:folder AND filename=:filename"

    local result = self.database:blockingSelect(sql, params)
    if result[1] then
        return result[1].uuid
    end

    return nil
end

function M:setRomHidden(uuid)
    local sql = "UPDATE rom SET hidden=1 WHERE uuid=:uuid"

    return self.database:blockingExec(sql, { uuid = uuid })
end

function M:setRomAsFresh(uuid)
    local sql = "UPDATE rom SET stale=0 WHERE uuid=:uuid"
    return self.database:blockingExec(sql, { uuid = uuid })
end

function M:getDistinctPlatforms()
    local platforms = {}
    local rows = self.database:blockingSelect("SELECT DISTINCT platform FROM rom WHERE rom.stale=0 and rom.hidden=0")
    for i, row in ipairs(rows) do
        table.insert(platforms, row.platform)
    end

    return platforms
end

-- function M:_getPreferOrderClause(prefers)
--     local case = { "ORDER BY CASE dat.sourcekey" }
--     for i, sourcekey in ipairs(prefers) do
--         table.insert(case, string.format("WHEN '%s' THEN %s", sourcekey, i))
--     end
--     table.insert(case, "ELSE 99 END")

--     return table.concat(case, " ")
-- end

function M:markAllRomsAsStale()
    --roms are "stale" until they are verified during the scanning process
    local sql = "UPDATE rom SET stale=1"
    self.database:blockingExec(sql)
end

function M:getLastCreated()
    local sql = "SELECT strftime('%d/%m/%Y %H:%M', created) AS created FROM rom ORDER BY created DESC LIMIT 1"
    local result = self.database:blockingSelect(sql)
    if result[1] then
        return result[1].created
    end

    return nil
end

function M:upsertRomToDB(romdata)
    local sql =
        "INSERT INTO rom (uuid, filename, romname, folder, platform, size, crc32, serial, error, stale) VALUES ( :uuid, :filename, :romname, :folder, :platform, :size, :crc32, :serial, :error, 0) ON CONFLICT(filename, folder) DO UPDATE SET romname = excluded.romname, size = excluded.size, crc32 = excluded.crc32, stale = excluded.stale, serial = excluded.serial, error = excluded.error, created = CURRENT_TIMESTAMP"
    self.database:blockingExec(sql, romdata)
end

function M:getPlatformForRom(uuid)
    local sql = "SELECT platform FROM rom WHERE rom.uuid=:uuid"
    local result = self.database:blockingSelect(sql, { uuid = uuid })
    if result[1] then
        return result[1].platform
    end

    return nil
end

function M:getOptionsForRom(uuid)
    local sql = "SELECT options FROM rom WHERE rom.uuid=:uuid"
    local result = self.database:blockingSelect(sql, { uuid = uuid })
    if result[1] then
        return result[1].options and json.decode(result[1].options) or {}
    end

    return {}
end

function M:getRom(uuid)
    local sql = "SELECT * FROM rom WHERE rom.uuid=:uuid"
    local result = self.database:blockingSelect(sql, { uuid = uuid })
    if result[1] then
        return result[1]
    end

    return nil
end

function M:getFolderAndFilenameForRom(uuid)
    local sql = "SELECT folder,filename FROM rom WHERE rom.uuid=:uuid"
    local result = self.database:blockingSelect(sql, { uuid = uuid })
    if result[1] then
        return result[1].folder, result[1].filename
    end

    return nil, nil
end

function M:getRomWithMediaForScraping(uuid, fuzzyPlatforms)
    -- lookup name of rom from dat if verified as more likely to match, falling back to a matching using the name of the rom (useful to extract names where .zip crc dont match)
    local qb = QueryBuilder()

    -- lookup dat first
    local datQuery1 = "(SELECT id FROM dat WHERE dat.crc32 = rom.crc32 ORDER BY dat.priority ASC LIMIT 1)"
    local datQuery2 = "(SELECT id FROM dat WHERE dat.serial = rom.serial ORDER BY dat.priority ASC LIMIT 1)"

    if fuzzyPlatforms then
        local datQuery3 = string.format(
            "(SELECT id FROM dat WHERE dat.romname = rom.romname AND rom.platform IN %s AND substr(rom.romname, -4) = '.zip' ORDER BY dat.priority ASC LIMIT 1)",
            QueryBuilder:tableToSqlInList(fuzzyPlatforms)
        )
        qb:selectCoalesce(datQuery1, datQuery2, datQuery3, { alias = "dat_id" })
    else
        qb:selectCoalesce(datQuery1, datQuery2, { alias = "dat_id" })
    end

    qb:from("rom")
    qb:where("rom.uuid = :uuid")

    local datIdResult = self.database:blockingSelect(qb:getQuery(), { uuid = uuid })

    if datIdResult == nil then
        error("Dat lookup failed #" .. uuid)
    end

    local datId = datIdResult[1].dat_id

    local datName, datRomName, datPlatform, sha1, md5, crc32 = nil, nil, nil, nil, nil, nil
    if datId then
        local datQuery = "SELECT name, romname, platform, sha1, md5, crc32 FROM dat WHERE id = :id"
        local datResult = self.database:blockingSelect(datQuery, { id = datId })
        datName = datResult[1].name
        datRomName = datResult[1].romname
        datPlatform = datResult[1].platform
        sha1 = datResult[1].sha1
        md5 = datResult[1].md5
        crc32 = datResult[1].crc32
    end
    -- end rom/dat lookup

    -- media lookup
    local romWithMediaSql =
        "SELECT rom.uuid, rom.romname, rom.filename as romfilename, rom.platform, rom.size, rom.crc32, rom.serial, rom.options, rom.created, media.uuid as media_uuid, media.type, media.filename, media.source, media.source_filename FROM rom LEFT JOIN media_rom mr on rom.uuid = mr.rom_uuid LEFT JOIN media on media.uuid = mr.media_uuid WHERE rom.uuid = :uuid"

    local rows = self.database:blockingSelect(romWithMediaSql, { uuid = uuid })

    local rom = {}
    local medias = {}
    for i, row in ipairs(rows) do
        if i == 1 then
            rom.uuid = row.uuid
            rom.romname = row.romname
            rom.datname = datName
            rom.filename = row.romfilename
            rom.datromname = datRomName
            rom.datplatform = datPlatform
            rom.platform = row.platform
            rom.serial = row.serial
            rom.size = row.size
            rom.crc32 = crc32 or row.crc32
            rom.sha1 = sha1
            rom.md5 = md5
            rom.created = row.created
            rom.options = row.options and json.decode(row.options) or {}
        end

        if row.media_uuid then
            local media = {
                uuid = row.media_uuid,
                type = row.type,
                filename = row.filename,
                source = row.source,
                source_filename = row.source_filename,
            }
            medias[row.type] = media
        end
    end
    rom.media = medias
    return rom
end

---Used on ROMS table and in MIX (mixer) and PACK
---@param uuid any
---@return nil
function M:getMediaForRom(uuid)
    -- media lookup
    local romWithMediaSql =
        "SELECT rom.uuid, rom.romname, rom.platform, rom.size, rom.crc32, rom.created, media.uuid as media_uuid, media.type, media.filename, media.source, media.source_filename FROM rom LEFT JOIN media_rom mr on rom.uuid = mr.rom_uuid LEFT JOIN media on media.uuid = mr.media_uuid WHERE rom.uuid = :uuid"

    local rows = self.database:blockingSelect(romWithMediaSql, { uuid = uuid })

    if rows == nil then
        return nil
    end

    local medias = {}
    for i, row in ipairs(rows) do
        if row.media_uuid then
            local media = {
                uuid = row.media_uuid,
                type = row.type,
                filename = row.filename,
                source = row.source,
                --source_filename = row.source_filename,
            }
            medias[row.type] = media
        end
    end
    return medias
end

---For use on the 'Roms' page
---@param pageLimit integer
---@param currentPage integer
---@param filters table
---@return table
---@return integer
function M:getRomTableData(pageLimit, currentPage, filters, scrapeMediaTypes)
    local qb = QueryBuilder()

    -- only counts `scrape` media types in the count
    qb:with(
        "WITH media_counts AS (SELECT rom_uuid, COUNT(*) AS media_count FROM media_rom INNER JOIN media ON media.uuid = media_rom.media_uuid WHERE media.type IN "
            .. qb:tableToSqlInList(scrapeMediaTypes)
            .. "GROUP BY rom_uuid)"
    )

    local verifiedCoalesce =
        "COALESCE((SELECT 1 FROM dat WHERE dat.serial = rom.serial ORDER BY dat.priority ASC LIMIT 1),(SELECT 1 FROM dat WHERE dat.crc32 = rom.crc32 ORDER BY dat.priority ASC LIMIT 1))"

    qb:select(
        "rom.uuid",
        "rom.platform",
        "rom.filename",
        "rom.size",
        "rom.crc32",
        "rom.serial",
        "rom.error",
        string.format("%s AS verified", verifiedCoalesce),
        "COALESCE(media_counts.media_count, 0) as media_count"
    )

    qb:from("rom LEFT JOIN media_counts ON media_counts.rom_uuid = rom.uuid")

    local platforms = {}
    for k, v in pairs(filters.platforms) do
        if v == true then
            table.insert(platforms, k)
        end
    end

    qb:whereIn("rom.platform", platforms)
    qb:where("rom.hidden=0")
    qb:where("rom.stale=0")

    --verified filter
    if filters.verified == "verified" then
        qb:where(string.format("%s IS NOT NULL", verifiedCoalesce))
    elseif filters.verified == "unverified" then
        qb:where(string.format("%s IS NULL", verifiedCoalesce))
    end

    --media filter
    if filters.media == "complete" then
        qb:where(string.format("COALESCE(media_counts.media_count, 0) = %s", #scrapeMediaTypes))
    elseif filters.media == "partial" then
        qb:where(
            string.format(
                "COALESCE(media_counts.media_count, 0) > 0 AND COALESCE(media_counts.media_count, 0) < %s",
                #scrapeMediaTypes
            )
        )
    elseif filters.media == "empty" then
        qb:where("COALESCE(media_counts.media_count, 0) = 0")
    end

    -- limit/offset and get results
    local countQuery = qb:countQuery()
    local count = self.database:blockingSelect(countQuery)[1].count

    -- compute requested offset; allow shorter last page; only clamp if it would be empty
    local requestedOffset = math.max(0, pageLimit * ((currentPage or 1) - 1))
    local offset
    if requestedOffset >= count then
        if count == 0 then
            offset = 0
        else
            -- snap to the first row of the last non-empty page
            local lastPageIndex = math.floor((count - 1) / pageLimit)
            offset = lastPageIndex * pageLimit
        end
    else
        offset = requestedOffset
    end

    qb:limit(pageLimit)
    if offset > 0 then
        qb:offset(offset)
    end
    local romData = self.database:blockingSelect(qb:getQuery())
    return romData, count
end

---@class RomRepository
return M
