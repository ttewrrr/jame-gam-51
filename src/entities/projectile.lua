local projectile = {}

local projectileSprite = love.graphics.newImage("src/assets/Player/bullet.png")

function projectile.new(entityX, entityY, entityRot)
    local self = setmetatable({}, projectile)

    self.speed = 200
    self.x = entityX or 0
    self.y = entityY or 0

    self.vx = math.cos(entityRot) * self.speed
    self.vy = math.sin(entityRot) * self.speed

    function self.draw()
        projectileSprite:setFilter("nearest", "nearest")
        love.graphics.draw(projectileSprite, self.x + 60 , self.y - 18, 2)
    end

    function self:update(dt)
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
    end

    return self
end

return projectile