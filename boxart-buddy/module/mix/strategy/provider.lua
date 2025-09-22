---@class MixStrategyProvider
local M = class({ name = "MixStrategyProvider" })

function M:new(mediaTypeProvider, database)
    self.mediaTypeProvider = mediaTypeProvider
    self.mixRepository = require("repository.mix")(database)

    self.strategies = require("dat.mix_strategy_definition")

    if not next(self.strategies) then
        error("FAILURE TO LOAD MIX STRATEGIES")
    end
end

---Returns strategy names sorted by order
---@return table
function M:getStrategyNames()
    local items = {}
    for name, spec in pairs(self.strategies) do
        table.insert(items, { order = tonumber(spec.order) or math.huge, name = name })
    end
    table.sort(items, function(a, b)
        if a.order == b.order then
            return a.name < b.name -- tie‑break alphabetically
        end
        return a.order < b.order
    end)
    local names = {}
    for i, item in ipairs(items) do
        names[i] = item.name
    end
    return names
end

function M:getKeyedStrategies()
    local keyed = {}
    for key, v in pairs(self.strategies) do
        keyed[key] = v.strategy
    end

    return keyed
end

function M:getPresets(currentStrategy)
    return self.mixRepository:getPresets(currentStrategy) or {}
end

function M:getSelectedPreset()
    return self.mixRepository:getSelectedPreset()
end

function M:getPresetByName(currentStrategy, name)
    local pre = self:getPresets(currentStrategy)
    if not pre then
        error("There are no presets for this strategy" .. currentStrategy)
    end
    for _, p in ipairs(pre) do
        if p.name == name then
            return p
        end
    end
    return nil
end

function M:getOptions(strategyName)
    if not self.strategies[strategyName] then
        error("cannot get options for unknown strategy: " .. strategyName)
    end

    local list = self.strategies[strategyName].options
    self:insertSpecialValues(list)

    return list
end

--- Modifys 't' to add values based on 'specialValues'
function M:insertSpecialValues(t)
    for k, v in pairs(t) do
        if type(v) == "table" then
            self:insertSpecialValues(v) -- we need to go deeper
        end
    end
    if t.specialValue then
        -- replace specialValues
        if t.specialValue == "insetMediaTypes" then
            t.values = self.mediaTypeProvider:getInsetMediaTypes()
            -- hack in 'platform_logo' option :/
            table.insert(t.values, "platform_color")
            table.insert(t.values, "platform_white")
            table.insert(t.values, "platform_alt")
            table.insert(t.values, "platform_retro")
            -- hack in 'none' option :/
            table.insert(t.values, "none")
        end
    end
end

return M
