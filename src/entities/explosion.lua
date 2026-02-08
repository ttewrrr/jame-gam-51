local explosion = {}

local ExplosionSprite = nil
local ExplosionQuads = nil
local ExplosionFrameCount = 7
local ExplosionFrameSize = 48

local ExplosionSounds = nil

local function LoadAssetsIfNeeded()
    if ExplosionSprite then return end

    ExplosionSprite = love.graphics.newImage("src/assets/MineExplosion.png")
    ExplosionSprite:setFilter("nearest", "nearest")

    ExplosionQuads = {}
    for i = 0, ExplosionFrameCount - 1 do
        ExplosionQuads[i + 1] = love.graphics.newQuad(
            i * ExplosionFrameSize, 0,
            ExplosionFrameSize, ExplosionFrameSize,
            ExplosionSprite:getDimensions()
        )
    end

    ExplosionSounds = {
        love.audio.newSource("src/sounds/real/MineExplode1.wav", "static"),
        love.audio.newSource("src/sounds/real/MineExplode2.wav", "static"),
        love.audio.newSource("src/sounds/real/MineExplode3.wav", "static")
    }
end

local function DistSq(ax, ay, bx, by)
    local dx = ax - bx
    local dy = ay - by
    return dx * dx + dy * dy
end

function explosion.new(x, y, Radius, Damage)
    LoadAssetsIfNeeded()

    local self = {}

    self.x = x or 0
    self.y = y or 0

    self.Radius = Radius or 80
    self.Damage = Damage or 80

    self.Duration = 1.0
    self.Age = 0

    self.dead = false
    self.DidDamage = false

    local s = ExplosionSounds[love.math.random(1, #ExplosionSounds)]:clone()
    s:setPitch(1 + (love.math.random() - 0.5) * 0.08)
    s:play()

    function self:ApplyDamageOnce()
        if self.DidDamage then return end
        self.DidDamage = true

        local r2 = self.Radius * self.Radius

        if player and player.HealthComponent and not player.HealthComponent.dead then
            if DistSq(self.x, self.y, player.x, player.y) <= r2 then
                player.HealthComponent:EventAnyDamage(self.Damage, self, self.x, self.y)
            end
        end

        if enemies then
            for i = 1, #enemies do
                local e = enemies[i]
                if e and e.HealthComponent and not e.HealthComponent.dead and e.x and e.y then
                    if DistSq(self.x, self.y, e.x, e.y) <= r2 then
                        e.HealthComponent:EventAnyDamage(self.Damage, self, self.x, self.y)
                    end
                end
            end
        end
    end

    function self:update(dt)
        if self.dead then return end

        self.Age = self.Age + dt
        self:ApplyDamageOnce()

        if self.Age >= self.Duration then
            self.dead = true
        end
    end

    function self:draw()
        if self.dead then return end

        local frameTime = self.Duration / ExplosionFrameCount
        local frame = math.floor(self.Age / frameTime) + 1
        if frame < 1 then frame = 1 end
        if frame > ExplosionFrameCount then frame = ExplosionFrameCount end

        love.graphics.draw(
            ExplosionSprite,
            ExplosionQuads[frame],
            self.x, self.y,
            0,
            1, 1,
            ExplosionFrameSize * 0.5,
            ExplosionFrameSize * 0.5
        )
    end

    return self
end

return explosion
