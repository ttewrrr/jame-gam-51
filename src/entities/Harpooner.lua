local projectile = require("src.entities.projectile")
local Enemy = require("src.helper.enemy")
local HealthComponent = require("src.mechanics.HealthComponent")

-- =========================
-- VISUALS & SOUNDS PER ID
-- =========================
local EnemyVisualById = {
    [0] = {SpritePath = "src/assets/Harpooner/Harpooner.png", FireSound = "src/sounds/real/HarpoonFire.wav"},
    [1] = {SpritePath = "src/assets/WelrodGunner/WelrodGunner.png", FireSound = "src/sounds/real/EnemyFireGun.wav"},
    [2] = {SpritePath = "src/assets/MagneticMiner/MagneticMiner.png", FireSound = "src/sounds/real/EnemyFireSonar.wav"}
}

-- =========================
-- BEHAVIOR TUNING PER ID
-- =========================
local EnemyTuningById = {
    [0] = {ChaseRange = 320, IdleRange = 200, MoveSpeed = 20, ShootCooldown = 2.0, ProjectileId = 5,  MoveBubbleChance = 0.03,  MoveBubbleAmount = 1},
    [1] = {ChaseRange = 360, IdleRange = 260, MoveSpeed = 18, ShootCooldown = 0.2, ProjectileId = 1,  MoveBubbleChance = 0.015, MoveBubbleAmount = 1},
    [2] = {ChaseRange = 200, IdleRange = 300, MoveSpeed = 14, ShootCooldown = 6.0, ProjectileId = 10, MoveBubbleChance = 0.01,  MoveBubbleAmount = 2}
}

local Harpooner = setmetatable({}, Enemy)
Harpooner.__index = Harpooner

local function RandomEnemyId()
    return love.math.random(0, 2)
end

-- =========================
-- CONSTRUCTOR
-- =========================
function Harpooner.new(x, y, EnemyId)
    if EnemyId == nil then EnemyId = RandomEnemyId() end

    local visual = EnemyVisualById[EnemyId] or EnemyVisualById[0]
    local tuning = EnemyTuningById[EnemyId] or EnemyTuningById[0]

    local sprite = love.graphics.newImage(visual.SpritePath)
    sprite:setFilter("nearest", "nearest")

    local quads = {}
    for i = 0, 3 do
        quads[#quads + 1] = love.graphics.newQuad(i * 64, 0, 64, 64, sprite:getDimensions())
    end

    local self = Enemy.new(x, y, sprite, {spriteType = "sheet", quads = quads})
    setmetatable(self, Harpooner)

    self.EnemyId = EnemyId

    self.ChaseRange = tuning.ChaseRange
    self.IdleRange = tuning.IdleRange
    self.speed = tuning.MoveSpeed
    self.ProjectileId = tuning.ProjectileId
    self.shootCooldown = tuning.ShootCooldown
    self.shootTimer = 0
    self.MoveBubbleChance = tuning.MoveBubbleChance
    self.MoveBubbleAmount = tuning.MoveBubbleAmount

    self.state = "idle"
    self.animationTimer = 0

    self.FireSound = love.audio.newSource(visual.FireSound, "static")

    self.HealthComponent = HealthComponent.new(self, 100, 2)
    self.HealthComponent:SetSounds("src/sounds/real/EnemySubHit1.wav", "src/sounds/real/RegularEnemyDeath.wav")

    return self
end

-- =========================
-- UPDATE
-- =========================
function Harpooner:update(dt, player)
    if self.HealthComponent.dead then
        self.dead = true
        return
    end

    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    self.flipX = dx < 0

    if dist <= self.ChaseRange then
        self.state = "chase"
    elseif dist > self.IdleRange then
        self.state = "idle"
    end

    if self.state == "idle" then
        self.currentQuad = 1
        self.floatTime = (self.floatTime or 0) + dt
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

            local s = self.FireSound:clone()
            s:setPitch(0.95 + love.math.random() * 0.1)
            s:play()
        end
    end
end

return Harpooner
