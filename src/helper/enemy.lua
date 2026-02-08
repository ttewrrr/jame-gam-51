local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, sprite, options)
    local self = setmetatable({}, Enemy)

    self.x = x or 0
    self.y = y or 0
    self.speed = 100
    self.hp = 100
    self.dead = false

    self.floatTime = 0
    self.floatOffset = 0

    self.rot = 0

    self.shootTimer = 0
    self.shootCooldown = 0.8

    self.flipX = false
    self.flipY = false

    self.spriteType = options and options.spriteType or "single"
    self.sprite = sprite

    if self.spriteType == "sheet" and options and options.quads then
        self.quads = options.quads
        self.currentQuad = 1
    end

    return self
end

function Enemy:update(dt)
end

function Enemy:draw()
    if self.sprite then
        self.sprite:setFilter("nearest", "nearest")
        if self.spriteType == "single" then
            love.graphics.draw(self.sprite, self.x, self.y + self.floatOffset, self.rot, 1, 1, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
        elseif self.spriteType == "sheet" and self.quads then
            love.graphics.draw(self.sprite, self.quads[self.currentQuad], self.x, self.y + self.floatOffset, self.rot, self.flipX and -1 or 1, 1, 32, 32)
        end
    end
end

return Enemy