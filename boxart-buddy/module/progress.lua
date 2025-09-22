---@class Progress
---@field tags table
---@field steps table
---@field current integer
local M = class({
    name = "Progress",
})

---@param key string
---@param steps table
---@param tags table
---@param text string
function M:new(key, steps, tags, text)
    self.key = key
    self.tags = tags or {}
    self.steps = steps
    self.text = text
    self.current = 0
    self.innerBarWidth = 0
    self.innerBarColor = nil
end

function M:addStep(step)
    if self.steps == nil then
        self.steps = {}
    end
    if type(self.steps) == "table" then
        table.insert(self.steps, step)
    elseif type(step) == "number" then
        self.steps = self.steps + step
    end
end

function M:addSteps(steps)
    if type(steps) == "table" then
        for _, step in ipairs(steps) do
            self:addStep(step)
        end
    elseif type(steps) == "number" then
        for i = 1, steps do
            self:addStep(1)
        end
    end
end

function M:setSteps(steps)
    self.steps = steps
end

function M:stepTextNumerical()
    if type(self.steps) == "number" then
        return string.format("%s/%s", self.current + 1, self.steps)
    end

    if type(self.steps) ~= "table" or self.steps[self.current + 1] == nil then
        return ""
    end

    return string.format("%s/%s", self.current + 1, #self.steps)
end

function M:stepText()
    if type(self.steps) == "number" then
        return string.format("%s/%s", self.current + 1, self.steps)
    end

    if type(self.steps) ~= "table" or self.steps[self.current + 1] == nil then
        return "missing steptext"
    end

    return self.steps[self.current + 1]
end

function M:progress()
    if self:isComplete() then
        return
        --error("Cannot progress an already complete progress counter")
    end
    self.current = self.current + 1
end

function M:isComplete()
    -- +1
    return (self.current == self:count())
end

function M:count() -- real number of steps
    if self.steps == nil then
        return 1
    end

    if type(self.steps) == "number" then
        return self.steps
    end

    return #self.steps
end

function M:percent()
    if self.current == 0 then
        return 0
    end

    return math.ceil((self.current / (self:count())) * 100)
end

return M
