-- code for rendering a progress bar
local colors = require("util.colors")
local ModalBar = require("gui.progress.modal_bar")
local ModalLoader = require("gui.progress.modal_loader")
local NullProgress = require("gui.progress.null")

---@class ProgressRenderer

local M = class({
    name = "ProgressRenderer",
})

function M:new(flux, systemeventsubscriber)
    self.flux = flux
    self.systemeventsubscriber = systemeventsubscriber

    self.progressMap = {}

    self.systemeventsubscriber:subscribe("progress_created", function(progress)
        self:register(progress)
    end)

    self.systemeventsubscriber:subscribe("progress_destroyed", function(key)
        self:deRegister(key)
    end)
end

function M:register(progress)
    local widget = nil -- create null widget
    if progress.tags.style == "modal" then
        if progress:count() > 1 then
            widget = ModalBar(progress, self.flux, {})
        else
            widget = ModalLoader(progress, {})
        end
    end
    if widget == nil then
        widget = NullProgress()
    end
    self.progressMap[progress.key] = widget
end

function M:deRegister(key)
    self.progressMap[key] = nil
end

function M:update(dt)
    for k, widget in pairs(self.progressMap) do
        widget:update(dt)
    end
end

function M:draw()
    for k, widget in pairs(self.progressMap) do
        widget:draw()
    end
end

return M
