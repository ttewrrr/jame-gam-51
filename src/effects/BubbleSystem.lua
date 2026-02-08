local BubbleSystem = {}
BubbleSystem.__index = BubbleSystem


BubbleSystem.TypeColors = {
    [1] = {1, 1, 1}, --bubble
    [2] = {1, 0.1, 0.1}, --blood
    [3] = {1, 0.9, 0.1} --spark
}


function BubbleSystem.new()
    local self = setmetatable({}, BubbleSystem)

    self.Bubbles = {}

    self.BubbleTexture = love.graphics.newImage("src/assets/effects/Bubble1PX.png")
    self.BubbleTexture:setFilter("nearest", "nearest")

    self.MinLifetimeSeconds = 0.6
    self.MaxLifetimeSeconds = 1.4

    self.StartVelocity = 20
    self.VerticalAcceleration = 60
    self.Size = 1

    self.JitterStrength = 4
    self.InitialImpulseStrength = 25

    return self
end


function BubbleSystem:SpawnBubble(x, y, CenterX, CenterY, BubbleTypeId)
    local Bubble = {}

    Bubble.TypeId = BubbleTypeId or 1
    Bubble.Color = BubbleSystem.TypeColors[Bubble.TypeId] or {1, 1, 1}

    Bubble.x = x
    Bubble.y = y
    Bubble.Age = 0

    local MinLifetimeSeconds = self.MinLifetimeSeconds
    local MaxLifetimeSeconds = self.MaxLifetimeSeconds
    local StartVelocity = self.StartVelocity
    local VerticalAcceleration = self.VerticalAcceleration
    local JitterStrength = self.JitterStrength
    local InitialImpulseStrength = self.InitialImpulseStrength

    if Bubble.TypeId == 2 then
        MinLifetimeSeconds = 1.4
        MaxLifetimeSeconds = 2.4
        StartVelocity = 0
        VerticalAcceleration = 0
        JitterStrength = 16
        InitialImpulseStrength = 2
    end

    if Bubble.TypeId == 3 then
        MinLifetimeSeconds = 0.12
        MaxLifetimeSeconds = 0.3
        StartVelocity = 0
        VerticalAcceleration = 0
        JitterStrength = 6
        InitialImpulseStrength = 220
    end

    Bubble.LifetimeSeconds = MinLifetimeSeconds + love.math.random() * (MaxLifetimeSeconds - MinLifetimeSeconds)

    local dx = x - CenterX
    local dy = y - CenterY
    local len = math.sqrt(dx * dx + dy * dy)

    if len > 0 then dx = dx / len dy = dy / len end

    Bubble.VelocityX = dx * InitialImpulseStrength
    Bubble.VelocityY = StartVelocity + dy * InitialImpulseStrength
    Bubble.VerticalAcceleration = VerticalAcceleration

    Bubble.JitterSeed = (love.math.random() - 0.5) * 2
    Bubble.JitterStrength = JitterStrength

    table.insert(self.Bubbles, Bubble)
end


function BubbleSystem:SpawnBubbles(x, y, rangeX, rangeY, amount, BubbleTypeId)
    rangeX = rangeX or 0
    rangeY = rangeY or 0
    amount = amount or 1

    for i = 1, amount do
        local bx = x + (love.math.random() - 0.5) * 2 * rangeX
        local by = y + (love.math.random() - 0.5) * 2 * rangeY
        self:SpawnBubble(bx, by, x, y, BubbleTypeId)
    end
end


function BubbleSystem:Update(dt)
    for i = #self.Bubbles, 1, -1 do
        local Bubble = self.Bubbles[i]

        Bubble.Age = Bubble.Age + dt

        if Bubble.Age >= Bubble.LifetimeSeconds then
            table.remove(self.Bubbles, i)
        else
            Bubble.VelocityY = Bubble.VelocityY + (Bubble.VerticalAcceleration or 0) * dt
            Bubble.x = Bubble.x + Bubble.VelocityX * dt
            Bubble.y = Bubble.y - Bubble.VelocityY * dt

            local LifeT = Bubble.Age / Bubble.LifetimeSeconds
            Bubble.x = Bubble.x + Bubble.JitterSeed * (Bubble.JitterStrength or 0) * dt * (1 - LifeT)
        end
    end
end


function BubbleSystem:Draw()
    for i = 1, #self.Bubbles do
        local Bubble = self.Bubbles[i]
        local Alpha = 1 - (Bubble.Age / Bubble.LifetimeSeconds)
        local c = Bubble.Color

        love.graphics.setColor(c[1], c[2], c[3], Alpha)
        love.graphics.draw(self.BubbleTexture, Bubble.x, Bubble.y, 0, self.Size, self.Size, 0.5, 0.5)
    end

    love.graphics.setColor(1, 1, 1, 1)
end


return BubbleSystem
