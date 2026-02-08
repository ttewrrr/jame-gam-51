local Enemy = require("src.helper.enemy")
local HealthComponent = require("src.mechanics.HealthComponent")
local Explosion = require("src.entities.explosion")

local Mine = setmetatable({}, Enemy)
Mine.__index = Mine

local sprite = love.graphics.newImage("src/assets/Mine.png")
sprite:setFilter("nearest", "nearest")

local function Clamp(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

local function CircleRectOverlap(cx, cy, r, rect)
    local closestX = Clamp(cx, rect.x, rect.x + rect.w)
    local closestY = Clamp(cy, rect.y, rect.y + rect.h)
    local dx = cx - closestX
    local dy = cy - closestY
    return (dx * dx + dy * dy) <= (r * r)
end

local function DistSq(ax, ay, bx, by)
    local dx = ax - bx
    local dy = ay - by
    return dx * dx + dy * dy
end

function Mine.new(x, y)
    local self = Enemy.new(x, y, {spriteType = "single"})
    setmetatable(self, Mine)

    self.sprite = sprite

    self.MaxHealth = 60
    self.LowHpExplodeThreshold = 10

    self.ContactRadius = 26
    self.ExplosionRadius = 80
    self.ExplosionDamage = 80

    self.Exploded = false
    self.dead = false

    self.HealthComponent = HealthComponent.new(self, self.MaxHealth, 3)
    self.HealthComponent.DrawHealthBar = false
    self.HealthComponent:SetSounds("src/sounds/real/EnemySubHit1.wav", "src/sounds/real/RegularEnemyDeath.wav")

    return self
end

function Mine:Explode()
    if self.Exploded then return end
    self.Exploded = true

    if explosions then
        table.insert(explosions, Explosion.new(self.x, self.y, self.ExplosionRadius, self.ExplosionDamage))
    end

    self.dead = true
end

function Mine:TouchesTarget(Target)
    if not Target then return false end
    if Target == self then return false end

    if Target.collisions and Target.collisions.x and Target.collisions.y and Target.collisions.w and Target.collisions.h then
        return CircleRectOverlap(self.x, self.y, self.ContactRadius, Target.collisions)
    end

    if Target.x and Target.y then
        return DistSq(self.x, self.y, Target.x, Target.y) <= (self.ContactRadius * self.ContactRadius)
    end

    return false
end

function Mine:CheckContactExplode()
    if player and player.HealthComponent and not player.HealthComponent.dead then
        if self:TouchesTarget(player) then
            self:Explode()
            return
        end
    end

    if enemies then
        for i = 1, #enemies do
            local e = enemies[i]
            if e and e ~= self then
                if self:TouchesTarget(e) then
                    self:Explode()
                    return
                end
            end
        end
    end
end

function Mine:update(dt, playerArg)
    if self.dead then return end

    if self.HealthComponent.dead then
        self:Explode()
        return
    end

    if self.HealthComponent.Health <= self.LowHpExplodeThreshold then
        self:Explode()
        return
    end

    self:CheckContactExplode()
end

return Mine
