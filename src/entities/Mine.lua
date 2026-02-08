local Enemy = require("src.helper.enemy")

local Mine = setmetatable({}, Enemy)
Mine.__index = Mine

local sprite = love.graphics.newImage("src/assets/Mine.png")

function Mine.new(x, y)
    local self = Enemy.new(x, y, {spriteType = "single"})
    setmetatable(self, Mine)

    self.sprite = sprite
    self.speed = 100
    self.hp = 10000

    return self
end

function Mine:update(dt)
    if self.y < 250 then
        self.y = self.y + self.speed * dt
        if self.y > 250 then
            self.y = 250
        end
    end
end

return Mine