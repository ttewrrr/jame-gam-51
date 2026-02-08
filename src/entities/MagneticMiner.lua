local Enemy = require("src.helper.enemy")

local MagneticMiner = setmetatable({}, Enemy)
MagneticMiner.__index = MagneticMiner

local sprite = love.graphics.newImage("src/assets/MagneticMiner/MagneticMiner.png")

function MagneticMiner.new(x, y)
    local self = Enemy.new(x, y)
    setmetatable(self, MagneticMiner)

    self.sprite = sprite
    self.speed = 100
    self.hp = 100

    return self
end

return MagneticMiner