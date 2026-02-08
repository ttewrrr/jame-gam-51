local camera = {}

camera.x = 0
camera.y = 0
camera.scale = 1
camera.smoothness = 10

-- map boundaries (in pixels)
camera.bounds = {
    xMin = 0,
    yMin = 0,
    xMax = 0,
    yMax = 0
}

-- Set boundaries based on all layers
function camera:setBounds(layers, tileSize)
    local maxWidth = 0
    local maxHeight = 0

    for _, layer in ipairs(layers) do
        local layerWidth = #layer[1] * tileSize
        local layerHeight = #layer * tileSize

        if layerWidth > maxWidth then maxWidth = layerWidth end
        if layerHeight > maxHeight then maxHeight = layerHeight end
    end

    self.bounds.xMin = 0
    self.bounds.yMin = 0
    self.bounds.xMax = maxWidth
    self.bounds.yMax = maxHeight
end

function camera:setPosition(x, y)
    self.x = x
    self.y = y
end

function camera:follow(target, dt)
    -- target must have x, y (center)
    self.x = self.x + (target.x - self.x) * self.smoothness * dt
    self.y = self.y + (target.y - self.y) * self.smoothness * dt

    -- apply bounds
    local screenW = love.graphics.getWidth() / self.scale
    local screenH = love.graphics.getHeight() / self.scale

    local halfW = screenW / 2
    local halfH = screenH / 2

    if self.x - halfW < self.bounds.xMin then
        self.x = self.bounds.xMin + halfW
    end
    if self.y - halfH < self.bounds.yMin then
        self.y = self.bounds.yMin + halfH
    end
    if self.x + halfW > self.bounds.xMax then
        self.x = self.bounds.xMax - halfW
    end
    if self.y + halfH > self.bounds.yMax then
        self.y = self.bounds.yMax - halfH
    end
end

function camera:attach()
    love.graphics.push()
    love.graphics.scale(self.scale)
    love.graphics.translate(
        -self.x + love.graphics.getWidth() / 2 / self.scale,
        -self.y + love.graphics.getHeight() / 2 / self.scale
    )
end

function camera:detach()
    love.graphics.pop()
end

return camera
