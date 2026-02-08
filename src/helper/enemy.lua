local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y)
    local self = setmetatable({}, Enemy)

    self.x = x or 0
    self.y = y or 0
    self.sprite = nil
    self.speed = 100
    self.hp = 100
    self.dead = false

    return self
end

function Enemy:update(dt)
end

function Enemy:draw()
    if self.sprite then
        self.sprite:setFilter("nearest", "nearest")
        love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
    end
end

return Enemy