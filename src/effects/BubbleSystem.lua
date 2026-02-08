local BubbleSystem = {}
BubbleSystem.__index = BubbleSystem


function BubbleSystem.new()
    local self = setmetatable({}, BubbleSystem)

    self.Bubbles = {}

    self.BubbleTexture = love.graphics.newImage(
        "src/assets/effects/Bubble1PX.png"
    )
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


function BubbleSystem:SpawnBubble(x, y, CenterX, CenterY)
    local Bubble = {}

    Bubble.x = x
    Bubble.y = y
    Bubble.Age = 0

    Bubble.LifetimeSeconds =
        self.MinLifetimeSeconds +
        love.math.random() *
        (self.MaxLifetimeSeconds - self.MinLifetimeSeconds)

    local dx = x - CenterX
    local dy = y - CenterY
    local len = math.sqrt(dx * dx + dy * dy)

    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    Bubble.VelocityX = dx * self.InitialImpulseStrength
    Bubble.VelocityY = self.StartVelocity + dy * self.InitialImpulseStrength

    Bubble.JitterSeed = (love.math.random() - 0.5) * 2

    table.insert(self.Bubbles, Bubble)
end


function BubbleSystem:SpawnBubbles(x, y, rangeX, rangeY, amount)
    rangeX = rangeX or 0
    rangeY = rangeY or 0
    amount = amount or 1

    for i = 1, amount do
        local bx =
            x + (love.math.random() - 0.5) * 2 * rangeX
        local by =
            y + (love.math.random() - 0.5) * 2 * rangeY

        self:SpawnBubble(bx, by, x, y)
    end
end


function BubbleSystem:Update(dt)
    for i = #self.Bubbles, 1, -1 do
        local Bubble = self.Bubbles[i]

        Bubble.Age = Bubble.Age + dt

        if Bubble.Age >= Bubble.LifetimeSeconds then
            table.remove(self.Bubbles, i)
        else
            Bubble.VelocityY =
                Bubble.VelocityY + self.VerticalAcceleration * dt

            Bubble.x = Bubble.x + Bubble.VelocityX * dt
            Bubble.y = Bubble.y - Bubble.VelocityY * dt

            local LifeT = Bubble.Age / Bubble.LifetimeSeconds
            Bubble.x =
                Bubble.x +
                Bubble.JitterSeed *
                self.JitterStrength *
                dt *
                (1 - LifeT)
        end
    end
end


function BubbleSystem:Draw()
    for i = 1, #self.Bubbles do
        local Bubble = self.Bubbles[i]
        local Alpha =
            1 - (Bubble.Age / Bubble.LifetimeSeconds)

        love.graphics.setColor(1, 1, 1, Alpha)

        love.graphics.draw(
            self.BubbleTexture,
            Bubble.x,
            Bubble.y,
            0,
            self.Size,
            self.Size,
            0.5,
            0.5
        )
    end

    love.graphics.setColor(1, 1, 1, 1)
end


return BubbleSystem
