local projectile = require("src.entities.projectile")
local Enemy = require("src.helper.enemy")
local HealthComponent = require("src.mechanics.HealthComponent")

local shootSound = love.audio.newSource("src/sounds/real/EnemyFireGun.wav", "static")

local Harpooner = setmetatable({}, Enemy)
Harpooner.__index = Harpooner

local sprite = love.graphics.newImage("src/assets/Harpooner/Harpooner.png")
local eQuads = {}

for i = 0, 3 do
    table.insert(eQuads, love.graphics.newQuad(i * 64, 0, 64, 64, sprite:getDimensions()))
end


local EnemyTuningById = {
    [0] = {ChaseRange = 520, IdleRange = 200, MoveSpeed = 20, ShootCooldown = 2, ProjectileId = 5, MoveBubbleChance = 0.03, MoveBubbleAmount = 1},
    [1] = {ChaseRange = 860, IdleRange = 260, MoveSpeed = 18, ShootCooldown = 0.2, ProjectileId = 1, MoveBubbleChance = 0.015, MoveBubbleAmount = 1}
}


function Harpooner.new(x, y, EnemyId)
    local self = Enemy.new(x, y, sprite, {spriteType = "sheet", quads = eQuads})
    setmetatable(self, Harpooner)

    self.EnemyId = EnemyId or 0
    local t = EnemyTuningById[self.EnemyId] or EnemyTuningById[0]

    self.ChaseRange = t.ChaseRange
    self.IdleRange = t.IdleRange
    self.speed = t.MoveSpeed

    self.ProjectileId = t.ProjectileId
    self.shootCooldown = t.ShootCooldown
    self.shootTimer = 0

    self.MoveBubbleChance = t.MoveBubbleChance
    self.MoveBubbleAmount = t.MoveBubbleAmount

    self.state = "idle"
    self.animationTimer = 0

    self.HealthComponent = HealthComponent.new(self, 100, 2)
    self.HealthComponent:SetSounds("src/sounds/real/EnemySubHit1.wav", "src/sounds/real/RegularEnemyDeath.wav")

    return self
end


function Harpooner:update(dt, player)
    if self.HealthComponent.dead then
        self.dead = true
        return
    end

    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx*dx + dy*dy)

    self.flipX = dx < 0
    self.flipY = dy < 0

    if dist <= self.ChaseRange then
        self.state = "chase"
    elseif dist <= self.IdleRange then
        self.state = "idle"
    end

    if self.state == "idle" then
        self.currentQuad = 1
        self.floatTime = self.floatTime + dt
        self.floatOffset = math.sin(self.floatTime * 2) * 4
    elseif self.state == "chase" then
        self.floatTime = 0
        self.floatOffset = (self.floatOffset or 0) * (1 - dt * 5)

        if love.math.random() < self.MoveBubbleChance then
            Bubbles:SpawnBubbles(self.x, self.y, 4, 4, self.MoveBubbleAmount, 1)
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
            table.insert(projectiles, projectile.new(self.x, self.y, angle, self, self.ProjectileId))
            self.shootTimer = 0

            local s = shootSound:clone()
            s:play()
        end
    end
end

return Harpooner
