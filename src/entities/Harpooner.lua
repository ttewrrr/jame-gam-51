local projectile = require("src.entities.projectile")
local Enemy = require("src.helper.enemy")

local Harpooner = setmetatable({}, Enemy)
Harpooner.__index = Harpooner

local sprite = love.graphics.newImage("src/assets/Harpooner/Harpooner.png")
local eQuads = {}

for i= 0, 3 do
    table.insert(eQuads, love.graphics.newQuad(i * 64, 0, 64, 64, sprite:getDimensions()))
end

function Harpooner.new(x, y)
    local self = Enemy.new(x, y, sprite, {spriteType = "sheet", quads = eQuads})
    setmetatable(self, Harpooner)

    self.speed = 20
    self.hp = 100
    self.state = "idle"
    self.animationTimer = 0

    return self
end

function Harpooner:update(dt, player)
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx*dx + dy*dy)

    if dist <= 120 then
        self.state = "chase"
    elseif dist <= 200 then
        self.state = "idle"
    end

        if self.state == "idle" then
            self.currentQuad = 1
            self.floatTime = self.floatTime + dt
            self.floatOffset = math.sin(self.floatTime * 2) * 4
        elseif self.state == "chase" then
            self.floatTime = 0
            self.floatOffset = (self.floatOffset or 0) * (1 - dt * 5)
			
			if love.math.random() < 0.1 then
				Bubbles:SpawnBubbles(self.x, self.y, 6, 6, 1)
			end

            self.animationTimer = self.animationTimer + dt
            if self.animationTimer >= 0.3 then
                self.currentQuad = self.currentQuad == 1 and 2 or 1
                self.animationTimer = self.animationTimer - 0.3
            end

            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt

            self.shootTimer = self.shootTimer + dt
            if self.shootTimer >= self.shootCooldown then
                table.insert(projectiles, projectile.new(self.x, self.y, 0, -400))
                self.shootTimer = 0
            end
        end
end

return Harpooner