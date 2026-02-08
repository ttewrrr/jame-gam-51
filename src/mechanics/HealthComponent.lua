local HealthComponent = {}
HealthComponent.__index = HealthComponent

local HealthBarFillTexture = nil
local HealthBarEmptyTexture = nil
local HealthBarWidth = 0
local HealthBarHeight = 0


local function LoadHealthBarTexturesIfNeeded()
    if HealthBarFillTexture then return end

    HealthBarFillTexture = love.graphics.newImage("src/assets/UIElements/HealthBar/HealthBar.png")
    HealthBarEmptyTexture = love.graphics.newImage("src/assets/UIElements/HealthBar/HealthBarEmpty.png")

    HealthBarFillTexture:setFilter("nearest", "nearest")
    HealthBarEmptyTexture:setFilter("nearest", "nearest")

    HealthBarWidth = HealthBarFillTexture:getWidth()
    HealthBarHeight = HealthBarFillTexture:getHeight()
end


function HealthComponent.new(Owner, MaxHealth, DamageBubbleTypeId)
    local self = setmetatable({}, HealthComponent)

    self.Owner = Owner

    self.MaxHealth = MaxHealth or 100
    self.Health = self.MaxHealth

    self.dead = false

    self.DamageBubbleTypeId = DamageBubbleTypeId or 1

    self.DrawHealthBar = true
    self.IsPlayer = false

    self.HealthBarScale = 1
    self.HealthBarOffsetY = 18

    self.PlayerUIX = 16
    self.PlayerUIY = 16

    LoadHealthBarTexturesIfNeeded()

    return self
end


function HealthComponent:EventAnyDamage(DMG, DamagedByObject, ImpactX, ImpactY)
    if self.dead then return end

    DMG = DMG or 0
    self.Health = self.Health - DMG

    if ImpactX and ImpactY then
        Bubbles:SpawnBubbles(
            ImpactX,
            ImpactY,
            4, 4,
            10,
            self.DamageBubbleTypeId
        )
    end

    if self.Health <= 0 then
        self.dead = true

        if self.Owner then
            Bubbles:SpawnBubbles(
                self.Owner.x,
                self.Owner.y,
                18, 18,
                60,
                self.DamageBubbleTypeId
            )
        end
    end
end


function HealthComponent:Draw()
    if not self.DrawHealthBar then return end
    if self.dead then return end
    if not self.Owner then return end

    local alpha = 1
    if self.MaxHealth > 0 then
        alpha = self.Health / self.MaxHealth
    end

    if alpha < 0 then alpha = 0 end
    if alpha > 1 then alpha = 1 end

    if self.IsPlayer then
        love.graphics.push()
        love.graphics.origin()

        local x = self.PlayerUIX
        local y = self.PlayerUIY

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            HealthBarEmptyTexture,
            x, y,
            0,
            self.HealthBarScale,
            self.HealthBarScale
        )

        local w = math.floor(HealthBarWidth * alpha)
        if w > 0 then
            local quad = love.graphics.newQuad(
                0, 0,
                w, HealthBarHeight,
                HealthBarFillTexture:getDimensions()
            )

            love.graphics.draw(
                HealthBarFillTexture,
                quad,
                x, y,
                0,
                self.HealthBarScale,
                self.HealthBarScale
            )
        end

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.pop()

        return
    end

    local x = self.Owner.x - (HealthBarWidth * 0.5 * self.HealthBarScale)
    local y = self.Owner.y - self.HealthBarOffsetY

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        HealthBarEmptyTexture,
        x, y,
        0,
        self.HealthBarScale,
        self.HealthBarScale
    )

    local w = math.floor(HealthBarWidth * alpha)
    if w > 0 then
        local quad = love.graphics.newQuad(
            0, 0,
            w, HealthBarHeight,
            HealthBarFillTexture:getDimensions()
        )

        love.graphics.draw(
            HealthBarFillTexture,
            quad,
            x, y,
            0,
            self.HealthBarScale,
            self.HealthBarScale
        )
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return HealthComponent
