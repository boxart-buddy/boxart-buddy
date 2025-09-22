local filesystem = require("lib.nativefs")
local path = require("util.path")

-- platform and path dependent information including access to configurations
---@class Environment
---@field muosPaths table
local M = class({
    name = "Environment",
    defaults = {
        muosPaths = {
            ["sd1"] = "/mnt/mmc",
            ["sd2"] = "/mnt/sdcard",
        },
    },
})

function M:new(projectRoot, configManager)
    self.projectRoot = projectRoot
    self.configManager = configManager
    -- memoized to reduce future lookups
    self.assignPath = nil
    self.coreFolderPath = nil
    self.catalogFolderPath = nil
    self.catalogPackageFolderPath = nil
end

function M.getPlatformLibPath()
    -- jit.os: Contains the target OS name: "Windows", "Linux", "OSX", "BSD", "POSIX" or "Other".
    -- jit.arch:Contains the target architecture name: "x86", "x64", "arm", "arm64", "arm64be", "ppc", "mips", "mipsel", "mips64", "mips64el", "mips64r6", "mips64r6el".
    if jit.os == "OSX" and jit.arch == "arm64" then
        return ";./boxart-buddy/lib/cpp/macarm64/?.so"
    elseif jit.os == "Linux" and jit.arch == "arm64" then
        return ";./boxart-buddy/lib/cpp/linuxarm64/?.so"
    end
end

function M.ensureSupported()
    if jit.arch ~= "arm64" then
        error("Unsupported platform or architecture")
    end

    if jit.os ~= "OSX" and jit.os ~= "Linux" then
        error("Unsupported platform or architecture")
    end
end

function M.isThread()
    -- hack
    return (love.graphics == nil)
end

function M.isMuOs()
    return jit.os == "Linux"
end

function M:getProjectRoot()
    return self.projectRoot
end

function M:getCodePath()
    return self:getProjectRoot() .. "/boxart-buddy"
end

---@param id string type of the path to get
---@return string An absolute path
function M:getPath(id, options)
    options = options or {}
    if type(id) ~= "string" then
        error("type required")
    end

    local saveDir = self:getProjectRoot() .. "/data"
    local codeDir = self:getCodePath()

    if id == "db_dir" then
        return saveDir
    elseif id == "db" then
        return path.join({ saveDir, "bb.db" })
    elseif id == "db_initial" then
        local dbname = "bb.db"
        return path.join({ codeDir, "resources", "db", dbname })
    elseif id == "mix_asset" then
        return path.join({ codeDir, "assets", "image", "mix" })
    elseif id == "dat_root" then
        return path.join({ self:getProjectRoot(), "/tools/fixtures/dat" })
    elseif id == "log" then
        return path.join({ saveDir, "log" })
    elseif id == "lib" then
        return path.join({ codeDir, "lib" })
    elseif id == "resources" then
        return path.join({ codeDir, "resources" })
    elseif id == "libretro_thumb_dictionary" then
        return path.join({ codeDir, "resources", "libretro_thumb" })
    elseif id == "gamecontrollerdb" then
        return path.join({ codeDir, "resources", "gamecontrollerdb.txt" })
    elseif id == "native" then
        local platform
        if jit.os == "OSX" and jit.arch == "arm64" then
            platform = "macarm64"
        elseif jit.os == "Linux" and jit.arch == "arm64" then
            platform = "linuxarm64"
        end

        return path.join({ codeDir, "native", platform, "?.so" })
    elseif id == "nativeffi" then
        local platform
        if jit.os == "OSX" and jit.arch == "arm64" then
            platform = "macarm64"
        elseif jit.os == "Linux" and jit.arch == "arm64" then
            platform = "linuxarm64"
        end

        return path.join({ codeDir, "native", platform })
    elseif id == "roms" then
        if self:isMuOs() then
            return self:muosRomFolder()
        else
            return self.configManager:get("env_rom_path")
        end
    elseif id == "catalog" then
        if self:isMuOs() then
            return self:muosCatalogFolder(options.force)
        else
            return self.configManager:get("env_catalog_path")
        end
    elseif id == "catalog_package" then
        if self:isMuOs() then
            return self:muosCatalogPackageFolder()
        else
            return path.join({ saveDir, "cache", "catalog_package" })
        end
    elseif id == "coreinfo" then
        if self:isMuOs() then
            return self:muosCoreInfoFolder()
        else
            return self.configManager:get("env_muos_info_core_path")
        end
    elseif id == "assign" then
        if self:isMuOs() then
            return self:muosAssignPath()
        else
            return self.configManager:get("env_muos_assign_path")
        end
    elseif id == "cache" then
        return path.join({ saveDir, "cache" })
    elseif id == "file_scraper" then
        return path.join({ saveDir, "media" })
    elseif id == "initialized_db" then
        return path.join({ saveDir, "initialized_db" })
    elseif id == "initialized_conf" then
        return path.join({ saveDir, "initialized_conf" })
    elseif id == "initialized_mix_presets" then
        return path.join({ saveDir, "initialized_mix_presets" })
    end

    error("Unknown path requested: " .. id)
end

---@return string absolute path to the catalog folder
function M:muosCatalogFolder(force)
    local paths = {
        "/opt/muos/share/info/catalogue",
        "/run/muos/storage/info/catalogue",
        path.join({ self.muosPaths.sd2, "MUOS", "info", "catalogue" }),
        path.join({ self.muosPaths.sd1, "MUOS", "info", "catalogue" }),
    }

    -- cached
    if self.catalogFolderPath then
        return self.catalogFolderPath
    end

    for _, pth in ipairs(paths) do
        if filesystem.getInfo(pth, "directory") then
            self.catalogFolderPath = pth
            return self.catalogFolderPath
        end
    end

    -- if this fallback is ever triggered then it will lead to an error, as the file does not exist
    error("Catalog folder path could not be found. Filesystem is corrupt or unsupported muos verson")
end

function M:muosCatalogPackageFolder()
    local paths = {
        -- "/opt/muos/share/package/catalogue",
        -- "/run/muos/storage/package/catalogue",
        path.join({ self.muosPaths.sd2, "MUOS", "package", "catalogue" }),
        path.join({ self.muosPaths.sd1, "MUOS", "package", "catalogue" }),
    }

    -- cached
    if self.catalogPackageFolderPath then
        return self.catalogPackageFolderPath
    end

    for _, pth in ipairs(paths) do
        if filesystem.getInfo(pth, "directory") then
            self.catalogPackageFolderPath = pth
            return self.catalogPackageFolderPath
        end
    end

    -- if this fallback is ever triggered then it will lead to an error, as the file does not exist
    error("Catalog Package folder path could not be found. Filesystem is corrupt or unsupported muos verson")
end

---@return string absolute path to the rom folder
function M:muosRomFolder()
    local sd2RomsFolder = path.join({ self.muosPaths.sd2, "ROMS" })
    local sd2RomsFolderExists = filesystem.getInfo(sd2RomsFolder, "directory")

    if sd2RomsFolderExists then
        -- if has any folders then assume this is where the roms are?...
        if #filesystem.getDirectoryItems(sd2RomsFolder, "directory") > 0 then
            return sd2RomsFolder
        end
    end

    return path.join({ self.muosPaths.sd1, "ROMS" })
end

---@return string absolute path to the core(info) folder
function M:muosCoreInfoFolder()
    local coreFolderPaths = {
        "/opt/muos/share/info/core",
        "/run/muos/storage/info/core",
        path.join({ self.muosPaths.sd2, "MUOS", "info", "core" }),
        path.join({ self.muosPaths.sd1, "MUOS", "info", "core" }),
    }

    -- cached
    if self.coreFolderPath then
        return self.coreFolderPath
    end

    for _, pth in ipairs(coreFolderPaths) do
        if filesystem.getInfo(pth, "directory") then
            self.coreFolderPath = pth
            return self.coreFolderPath
        end
    end

    -- if this fallback is ever triggered then it will lead to an error, as the file does not exist
    error("Core folder path could not be found. Filesystem is corrupt or unsupported muos verson")
end

function M:muosAssignPath()
    -- >= canada goose path
    local assignPath = "/opt/muos/share/info/assign/assign.json"

    -- < canada goose paths
    local legacyAssignPaths = { "MUOS/info/assign/assign.json", "MUOS/info/assign.json" }

    -- cached
    if self.assignPath then
        return self.assignPath
    end

    if filesystem.getInfo(assignPath, "file") then
        self.assignPath = assignPath
        return self.assignPath
    end

    for _, pth in ipairs(legacyAssignPaths) do
        -- sd2
        local sd2Path = path.join({ self.muosPaths.sd2, pth })
        if filesystem.getInfo(sd2Path, "file") then
            self.assignPath = sd2Path
            return self.assignPath
        end

        -- sd1
        local sd1Path = path.join({ self.muosPaths.sd1, pth })
        if filesystem.getInfo(sd1Path, "file") then
            self.assignPath = sd1Path
            return self.assignPath
        end
    end

    -- if this fallback is ever triggered then it will lead to an error, as the file does not exist
    error("assign.json path could not be found. filesystem is corrupt or unsupported muos verson")
end

---@return string
function M:getVersion()
    return "0.1.0"
end

---@param key string
---@return any
function M:getConfig(key)
    return self.configManager:get(key)
end

return M
