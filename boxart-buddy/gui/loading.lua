local M = class({
    name = "Loading",
})

---@param canvas love.Canvas
---@param image love.Image|string
---@param options table|nil
function M:new(canvas, image, options)
    options = options or {}
    self.canvas = canvas

    -- load if a path was provided
    if type(image) == "string" then
        image = love.graphics.newImage(image)
    end
    self.image = image

    self.frameWidth = options.frameWidth or 64
    self.frameHeight = options.frameHeight or 64
    self.fps = options.fps or 16
    self.x = options.x or 0
    self.y = options.y or 0
    self.scale = options.scale or 1
    self.color = options.color or { 1, 1, 1, 1 }
    self.center = (options.center ~= false)
    self.playing = (options.playing ~= false)

    self.timer = 0
    self.current = 1

    local iw, ih = self.image:getDimensions()
    self.frames = math.floor(iw / self.frameWidth + 0.0001)
    if self.frames < 1 then
        self.frames = 1
    end

    self.quads = {}
    for i = 0, self.frames - 1 do
        local q = love.graphics.newQuad(i * self.frameWidth, 0, self.frameWidth, self.frameHeight, iw, ih)
        self.quads[#self.quads + 1] = q
    end
end

function M:update(dt)
    if not self.playing or self.fps <= 0 or #self.quads <= 1 then
        return
    end
    self.timer = self.timer + dt
    local frameTime = 1 / self.fps
    while self.timer >= frameTime do
        self.timer = self.timer - frameTime
        self.current = self.current + 1
        if self.current > #self.quads then
            self.current = 1
        end
    end
end

function M:draw(x, y)
    local lg = love.graphics
    local px = x or self.x
    local py = y or self.y

    local ox, oy = 0, 0
    if self.center then
        ox = self.frameWidth / 2
        oy = self.frameHeight / 2
    end

    lg.setCanvas(self.canvas)
    lg.push("all")
    lg.setColor(self.color)
    lg.draw(self.image, self.quads[self.current], px, py, 0, self.scale, self.scale, ox, oy)
    lg.pop()
    lg.setCanvas()
end

return M
