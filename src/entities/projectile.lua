local projectile = {}

local ProjectileConfigs = {
    [1] = {TexturePath = "src/assets/Player/bullet.png", Damage = 25, HitRadius = 6, InitialFireVelocity = 600, DeaccelerationRate = 900, UseGravity = true, GravityAcceleration = 900, GravityAlpha = 0.35, BubbleSpawnChanceBase = 0.2, BubbleTypeId = 1, DestroyOnHit = true, Color = {1, 1, 1}, BubbleRangeX = 1, BubbleRangeY = 1},
    [5] = {TexturePath = "src/assets/Harpooner/HarpoonerHarpoon.png", Damage = 20, HitRadius = 7, InitialFireVelocity = 350, DeaccelerationRate = 220, UseGravity = true, GravityAcceleration = 900, GravityAlpha = 0.2, BubbleSpawnChanceBase = 0.1, BubbleTypeId = 1, DestroyOnHit = true, Color = {1, 1, 1}, BubbleRangeX = 4, BubbleRangeY = 4},
    [10] = {TexturePath = "src/assets/Player/SonarBlast.png", Damage = 110, HitRadius = 26, InitialFireVelocity = 280, DeaccelerationRate = -420, UseGravity = false, GravityAcceleration = 0, GravityAlpha = 0, BubbleSpawnChanceBase = 0.25, BubbleTypeId = 1, DestroyOnHit = true, Color = {0.6, 0.9, 1}, BubbleRangeX = 10, BubbleRangeY = 10}
}

local TextureCache = {}


local function GetTexture(Path)
    if not Path then return nil end
    if TextureCache[Path] then return TextureCache[Path] end
    local img = love.graphics.newImage(Path)
    img:setFilter("nearest", "nearest")
    TextureCache[Path] = img
    return img
end


local function Approach(CurrentValue, TargetValue, DeltaValue)
    if CurrentValue < TargetValue then return math.min(CurrentValue + DeltaValue, TargetValue) end
    if CurrentValue > TargetValue then return math.max(CurrentValue - DeltaValue, TargetValue) end
    return TargetValue
end


local function DistSq(ax, ay, bx, by)
    local dx = ax - bx
    local dy = ay - by
    return dx * dx + dy * dy
end


function projectile.new(entityX, entityY, entityRot, FiredByObject, ProjectileId)
    local self = {}

    self.x = entityX
    self.y = entityY
    self.rot = entityRot or 0

    self.FiredByObject = FiredByObject
    self.ProjectileId = ProjectileId or 1

    local cfg = ProjectileConfigs[self.ProjectileId] or ProjectileConfigs[1]

    self.Damage = cfg.Damage
    self.HitRadius = cfg.HitRadius

    self.InitialFireVelocity = cfg.InitialFireVelocity
    self.DeaccelerationRate = cfg.DeaccelerationRate

    self.UseGravity = cfg.UseGravity
    self.GravityAcceleration = cfg.GravityAcceleration
    self.GravityAlpha = cfg.GravityAlpha

    self.BubbleSpawnChanceBase = cfg.BubbleSpawnChanceBase
    self.BubbleTypeId = cfg.BubbleTypeId
    self.BubbleRangeX = cfg.BubbleRangeX or 1
    self.BubbleRangeY = cfg.BubbleRangeY or 1

    self.DestroyOnHit = cfg.DestroyOnHit

    self.Color = cfg.Color or {1, 1, 1}
    self.Texture = GetTexture(cfg.TexturePath)

    self.dead = false

    self.vx = math.cos(self.rot) * self.InitialFireVelocity
    self.vy = math.sin(self.rot) * self.InitialFireVelocity

    self.MaxSpeed = math.max(math.abs(self.InitialFireVelocity), 1)


    function self:TryHitTarget(Target)
        if not Target then return false end
        if Target == self.FiredByObject then return false end
        if not Target.HealthComponent then return false end
        if Target.HealthComponent.dead then return false end
        if Target.x == nil or Target.y == nil then return false end

        local r = self.HitRadius
        if DistSq(self.x, self.y, Target.x, Target.y) <= (r * r) then
            Target.HealthComponent:EventAnyDamage(self.Damage, self, self.x, self.y)
            if self.DestroyOnHit then self.dead = true end
            return true
        end

        return false
    end


    function self:CheckHits()
        if player and player ~= self.FiredByObject then
            if self:TryHitTarget(player) then return end
        end

        if enemies then
            for i = 1, #enemies do
                if self:TryHitTarget(enemies[i]) then return end
            end
        end
    end


    function self:update(dt)
        if self.dead then return end

        if self.UseGravity then
            self.vy = self.vy + (self.GravityAcceleration * self.GravityAlpha) * dt
        end

        if self.DeaccelerationRate >= 0 then
            self.vx = Approach(self.vx, 0, self.DeaccelerationRate * dt)
            self.vy = Approach(self.vy, 0, self.DeaccelerationRate * dt)
        else
            local ax = math.cos(self.rot) * (-self.DeaccelerationRate)
            local ay = math.sin(self.rot) * (-self.DeaccelerationRate)
            self.vx = self.vx + ax * dt
            self.vy = self.vy + ay * dt
        end

        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        local CurrentSpeed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
        local SpeedAlpha = math.min(CurrentSpeed / self.MaxSpeed, 1)

        if love.math.random() < self.BubbleSpawnChanceBase * SpeedAlpha then
            Bubbles:SpawnBubbles(self.x, self.y, self.BubbleRangeX, self.BubbleRangeY, 1, self.BubbleTypeId)
        end

        self:CheckHits()

        if self.DeaccelerationRate >= 0 then
            if math.abs(self.vx) < 1 and math.abs(self.vy) < 1 then self.dead = true end
        end
    end


    function self:draw()
        local c = self.Color
        love.graphics.setColor(c[1] or 1, c[2] or 1, c[3] or 1, 1)

        if self.Texture and type(self.Texture) == "userdata" and self.Texture.typeOf and self.Texture:typeOf("Drawable") then
            love.graphics.draw(self.Texture, self.x, self.y, self.rot, 1, 1, self.Texture:getWidth() * 0.5, self.Texture:getHeight() * 0.5)
        else
            love.graphics.circle("fill", self.x, self.y, 2)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end

    return self
end

return projectile
