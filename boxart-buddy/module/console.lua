---@class Console
---@field isOpen boolean
---@field isOpening boolean
---@field isClosing boolean
---@field updateInterval integer
---@field memoryUpdateInterval integer
---@field threadUpdateInterval integer
---@field consoleHeight integer
---@field consolePadding integer
---@field tweenTime integer
---@field maxLines integer
local M = class({
    name = "Console",
    defaults = {
        ["isOpen"] = false,
        ["isOpening"] = false,
        ["isClosing"] = false,
        ["updateInterval"] = 300,
        ["memoryUpdateInterval"] = 2000,
        ["threadUpdateInterval"] = 1000,
        -- config
        ["consoleHeight"] = SCREEN.h - SCREEN.hUnit(4.5),
        ["consolePadding"] = SCREEN.hUnit(1.2),
        ["tweenTime"] = 0.6,
        ["maxLines"] = 40, -- could be smaller unless scrollback implemented
    },
})

-- A non interactive quake like console for displaying messages
local colors = require("util.colors")
local ffi = require("ffi")

function M:new(environment, systemeventsubscriber, inputeventsubscriber, flux, thread)
    self.environment = environment
    self.systemeventsubscriber = systemeventsubscriber
    self.inputeventsubscriber = inputeventsubscriber
    self.flux = flux
    self.thread = thread

    -- start in the closed position
    self.consoleYClosedPosition = self.consoleHeight * -1
    self.consoleYPosition = self.consoleYClosedPosition

    self.messages = {}
    self.inputeventsubscriber:subscribe("input", function(e)
        if e.type == "toggle_console" then
            self:toggleOpen()
        end
    end)

    if love.graphics then
        self.consoleCanvas = love.graphics.newCanvas(SCREEN.w, self.consoleHeight)
    end

    self.threadCounts = {}
    self.threadPools = {}

    self.lastUpdated = 0
    self.threadLastUpdated = 0
    self.memoryLastUpdated = self.memoryUpdateInterval
end

function M:getProcessMemoryUsage()
    local os = jit and jit.os or ""
    if os == "Linux" then
        local fh = io.open("/proc/self/status", "r")
        if not fh then
            return nil
        end
        for line in fh:lines() do
            local vmrss = line:match("^VmRSS:%s+(%d+)%s+kB")
            if vmrss then
                fh:close()
                return tonumber(vmrss) / 1024 -- in MB
            end
        end
        fh:close()
        return nil
    elseif os == "OSX" then
        ffi.cdef([[
            int getpid(void);
        ]])
        local pid = ffi.C.getpid()
        local handle = io.popen("ps -o rss= -p " .. pid)
        if handle then
            local result = handle:read("*a")
            handle:close()
            local kb = tonumber(result:match("%S+"))
            if kb then
                return kb / 1024 -- MB
            end
        end
        return nil
    else
        return nil -- Unsupported OS
    end
end

function M:add(message)
    if #self.messages == self.maxLines then
        table.remove(self.messages, 1)
    end
    table.insert(self.messages, #self.messages + 1, message)
    --self.dirty = true
end

function M:update(dt)
    self.lastUpdated = self.lastUpdated + (dt * 1000)
    self.memoryLastUpdated = self.memoryLastUpdated + (dt * 1000)
    self.threadLastUpdated = self.threadLastUpdated + (dt * 1000)

    local font = ASSETS.font.inconsolita.medium(FONTSIZE.xs)

    if self.isOpening or self.isClosing or self.lastUpdated > self.updateInterval then
        self.lastUpdated = 0

        if not self.isOpen and not self.isOpening then
            -- totally closed no need to render anything
            return
        end

        if self.memoryLastUpdated > self.memoryUpdateInterval then
            self.memoryLastUpdated = 0
            local procMemory = self:getProcessMemoryUsage() or 0
            self.processMemory = string.format("%.2f MB", procMemory)
            self.memory = string.format("%.2f MB", collectgarbage("count") / 1024)

            --self:add(pretty.string(love.graphics.getStats()))
        end

        if self.threadLastUpdated > self.threadUpdateInterval then
            self.threadLastUpdated = 0
            self.threadCounts = self.thread:getCounts()
            self.threadPools = self.thread:getThreadPoolsDebug()
        end

        local memBoxHeight = SCREEN.hUnit(1.2)

        -- draw box
        love.graphics.setCanvas(self.consoleCanvas)
        love.graphics.clear(0, 0, 0, 0)

        love.graphics.setColor(colors.consoleBg)
        love.graphics.rectangle("fill", 0, 0, SCREEN.w, self.consoleHeight)
        love.graphics.setColor(colors.consoleStroke)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", 0, 0, SCREEN.w, self.consoleHeight)
        love.graphics.setLineWidth(1)
        local allText = ""

        for index, msg in ipairs(self.messages) do
            allText = allText .. msg .. "\n"
        end

        local textObject = love.graphics.newText(font)
        textObject:addf({ colors.consoleText, allText }, SCREEN.w - (self.consolePadding * 2), "left", 0, 0)

        local textHeight = textObject:getHeight()
        local textY = self.consoleHeight - textHeight - memBoxHeight

        love.graphics.setColor(colors.white)
        love.graphics.draw(textObject, self.consolePadding, textY)

        -- draw 'memory use' box
        love.graphics.setColor(colors.consoleStroke)
        love.graphics.rectangle("fill", 0, self.consoleHeight - memBoxHeight, SCREEN.w, memBoxHeight)
        local memTextObject = love.graphics.newText(font)
        local memText = string.format("Memory Use: %s (love2d) / %s (system)", self.memory, self.processMemory)
        memTextObject:addf({ colors.white, memText }, SCREEN.w - (self.consolePadding * 2), "right", 0, 0)
        love.graphics.setColor(colors.white)
        love.graphics.draw(memTextObject, self.consolePadding, self.consoleHeight - memBoxHeight)

        -- draw "threads" box if needed
        if next(self.threadCounts) then
            local threadText = "CHANNELS\n"

            for threadKeyAndChannel, num in pairs(self.threadCounts) do
                threadText = threadText .. string.format("%s(%s)\n", threadKeyAndChannel, num)
            end

            local threadTextObject = love.graphics.newText(font)
            threadTextObject:addf(
                { colors.white, threadText },
                SCREEN.w - (self.consolePadding * 2),
                "right",
                0,
                self.consolePadding / 2
            )
            local threadTextHeight = threadTextObject:getHeight()
            local threadTextWidth = threadTextObject:getWidth()

            love.graphics.setColor(colors.consoleBg)
            love.graphics.rectangle(
                "fill",
                SCREEN.w - threadTextWidth - (self.consolePadding * 2) - 1,
                SCREEN.h / 3,
                threadTextWidth + (self.consolePadding * 2),
                threadTextHeight + self.consolePadding
            )
            love.graphics.setColor(colors.white)
            love.graphics.draw(threadTextObject, self.consolePadding, SCREEN.h / 3)
        end
        -- end threads box

        -- pools box
        if self.environment:getConfig("ui_thread_pool_console") then
            local poolText = ""
            for threadKey, msg in pairs(self.threadPools) do
                poolText = poolText .. string.format("%s: %s\n", threadKey, msg)
            end
            local poolTextObject = love.graphics.newText(font)
            poolTextObject:addf(
                { colors.white, poolText },
                SCREEN.w - (self.consolePadding * 2),
                "left",
                0,
                self.consolePadding / 2
            )
            local poolTextHeight = poolTextObject:getHeight()
            local poolTextWidth = SCREEN.w

            love.graphics.setColor({ colors.consoleBg[1], colors.consoleBg[2], colors.consoleBg[3], 1 })
            love.graphics.rectangle(
                "fill",
                0,
                1,
                poolTextWidth + (self.consolePadding * 2),
                poolTextHeight + self.consolePadding
            )
            love.graphics.setColor(colors.white)
            love.graphics.draw(poolTextObject, self.consolePadding, self.consolePadding)
        end

        love.graphics.setCanvas()
    end
end

function M:toggleOpen()
    if self.isOpen and not self.isClosing then
        -- close it down
        self.isClosing = true
        self.systemeventsubscriber:publish("console_close")
        self.flux
            .to(self, self.tweenTime, { consoleYPosition = self.consoleYClosedPosition })
            :ease("quartin")
            :oncomplete(function()
                self.isOpen = false
                self.isClosing = false
                return
            end)
    elseif not self.isOpen and not self.isOpening then
        -- open it up
        self.isOpening = true
        self.systemeventsubscriber:publish("console_open")
        self.flux.to(self, self.tweenTime, { consoleYPosition = 0 }):ease("quartout"):oncomplete(function()
            self.isOpen = true
            self.isOpening = false
            return
        end)
    end
end

function M:draw()
    love.graphics.setCanvas()
    -- the -3 stops the top outer line of the console showing which looks better IMO
    love.graphics.draw(self.consoleCanvas, 0, self.consoleYPosition - 3)
end

return M
