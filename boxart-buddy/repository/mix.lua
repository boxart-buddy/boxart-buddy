local json = require("lib.json")

---@class MixRepository
local M = class({
    name = "MixRepository",
})

function M:new(database)
    self.database = database
end

function M:getPresets(strategyName)
    local presets = {}
    local selectSql = "SELECT * FROM mix WHERE strategy = :strategy"
    local result = self.database:blockingSelect(selectSql, { strategy = strategyName })
    if not next(result) then
        return {}
    end
    for _, row in ipairs(result) do
        table.insert(presets, {
            name = row.preset,
            hard = row.hard == 1,
            selected = row.selected == 1,
            values = json.decode(row.preset_values),
        })
    end

    return presets
end

function M:getPresetValues(strategyName, presetName)
    local selectSql = "SELECT * FROM mix WHERE strategy = :strategy AND preset = :preset LIMIT 1"
    local result, error = self.database:blockingSelect(selectSql, { strategy = strategyName, preset = presetName })
    if not next(result) then
        return nil
    end

    return result[1].preset_values
end

function M:getSelectedPreset()
    local selectSql = "SELECT * FROM mix WHERE selected = 1 LIMIT 1"
    local result = self.database:blockingSelect(selectSql)
    if not next(result) then
        return nil
    end

    return {
        strategy = result[1].strategy,
        name = result[1].preset,
        values = json.decode(result[1].preset_values),
        hard = result[1].hard,
        selected = result[1].selected,
    }
end

---If presetName already exists then entry will be overwritten
---@param strategyName string
---@param presetName string
---@param values table
---@return nil
function M:savePreset(strategyName, presetName, values, selected, hard)
    if selected == nil then
        selected = false
    end
    if hard == nil then
        hard = false
    end
    local insertSql =
        "INSERT INTO mix (strategy, preset, preset_values, selected, hard) VALUES (:strategy, :preset, :preset_values, :selected, :hard)"
    return self.database:blockingExec(insertSql, {
        strategy = strategyName,
        preset = presetName,
        preset_values = json.encode(values),
        selected = selected,
        hard = hard,
    })
end

function M:selectPreset(strategyName, presetName)
    -- first deleselect all others
    local resetSql = "UPDATE mix SET selected = 0"
    self.database:blockingExec(resetSql, { strategy = strategyName, preset = presetName })

    local updateSql = "UPDATE mix SET selected = 1 WHERE strategy = :strategy AND preset = :preset"
    return self.database:blockingExec(updateSql, { strategy = strategyName, preset = presetName })
end

function M:deletePreset(strategyName, presetName)
    local deleteSql = "DELETE FROM mix WHERE strategy = :strategy AND preset = :preset"
    return self.database:blockingExec(deleteSql, { strategy = strategyName, preset = presetName })
end

function M:importPresets()
    local hardPresets = require("dat.mix_preset")
    for strategyName, presets in pairs(hardPresets) do
        for _, presetFields in ipairs(presets) do
            local existing = self:getPresetValues(strategyName, presetFields.name)
            if existing == nil then
                local selected = false
                -- hardcode an initial selection
                if presetFields.name == "Fullscreen + box/wheel" then
                    selected = true
                end
                self:savePreset(strategyName, presetFields.name, presetFields.values, selected, true)
            end
        end
    end
end

return M
