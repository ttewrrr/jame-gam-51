local projectile = {}

function projectile.new(entityX, entityY, entityRot)
    local self = {}

    self.x = entityX
    self.y = entityY
    self.rot = entityRot or 0

    self.InitialFireVelocity = 600
    self.DeaccelerationRate = 900

    self.UseGravity = true
    self.GravityAcceleration = 900
    self.GravityAlpha = 0.35

    self.BubbleSpawnChanceBase = 0.2

    self.dead = false

    self.vx = math.cos(self.rot) * self.InitialFireVelocity
    self.vy = math.sin(self.rot) * self.InitialFireVelocity

    self.MaxSpeed = self.InitialFireVelocity

    local function Approach(CurrentValue, TargetValue, DeltaValue)
        if CurrentValue < TargetValue then
            return math.min(CurrentValue + DeltaValue, TargetValue)
        elseif CurrentValue > TargetValue then
            return math.max(CurrentValue - DeltaValue, TargetValue)
        end
        return TargetValue
    end

    function self:update(dt)
        if self.dead then
            return
        end

        if self.UseGravity then
            self.vy = self.vy + (self.GravityAcceleration * self.GravityAlpha) * dt
        end

        self.vx = Approach(self.vx, 0, self.DeaccelerationRate * dt)
        self.vy = Approach(self.vy, 0, self.DeaccelerationRate * dt)

        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        local CurrentSpeed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
        local SpeedAlpha = math.min(CurrentSpeed / self.MaxSpeed, 1)

        if love.math.random() < self.BubbleSpawnChanceBase * SpeedAlpha then
            Bubbles:SpawnBubbles(self.x, self.y, 1, 1, 1, 1)
        end

        if math.abs(self.vx) < 1 and math.abs(self.vy) < 1 then
            self.dead = true
        end
    end

    function self:draw()
        love.graphics.circle("fill", self.x, self.y, 1)
    end

    return self
end

return projectile
