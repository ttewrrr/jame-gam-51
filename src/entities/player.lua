local projectile = require("src.entities.projectile")

local player = {}

local playerSprites = {}

shootSound = love.audio.newSource("src/sounds/real/PlayerFireGun.wav", "static")

function player.new(x, y)
    local self = setmetatable({}, player)

    self.Health = 100
    self.x = x or 0
    self.y = y or 0
    self.rot = 0
    self.direction = 1
    self.idle = true

    self.sprite = 1

    self.floatTime = 0
    self.floatOffset = 0
    self.shootTimer = 0
    self.shootCooldown = 0.4


    function self.shoot()
        table.insert(projectiles, projectile.new(self.x, self.y, self.rot, -400))
        self.sprite = 2
        self.sprite = 1
        local s = shootSound:clone()
        s:play()
    end

    function self.load()
        playerSprite = love.graphics.newImage("src/assets/Player/PlayerSpritesheet.png")
        playerSprite:setFilter("nearest", "nearest")

        for i = 0, 6 do
            playerSprites[i + 1] = love.graphics.newQuad(i * 64, 0, 64, 64, playerSprite:getDimensions())
        end
    end

    function self.draw()
        love.graphics.print("Player x: ".. self.x .. " Player y: " .. self.y, 100, 100)
        love.graphics.draw(playerSprite, playerSprites[self.sprite], self.x, self.y + self.floatOffset, self.rot, 1, 1, 32, 32)
    end

    function self.update(dt)
        if love.keyboard.isDown("right") then
            self.x = self.x + 100 * dt
            self.direction = 1
            self.idle = false
        end
        if love.keyboard.isDown("left") then
            self.x = self.x - 100 * dt
            self.direction = -1
            self.idle = false
        end
        if love.keyboard.isDown("up") then
            self.y = self.y - 100 * dt
            self.idle = false
        end
        if love.keyboard.isDown("down") then
            self.y = self.y + 100 * dt
            self.idle = false
        end
        if love.mouse.isDown(1) and self.shootTimer <= 0 then
            self.shoot()
            self.shootTimer = self.shootCooldown
        end

        function love.keyreleased(key)
            if key == "right" or key == "left" or key == "up" or key == "down" then
                self.idle = true
            end
        end

        local angleToMouse = math.atan2(love.mouse.getY()/ 4 - self.y, love.mouse.getX() / 4 - self.x)

        if self.idle then
            self.floatTime = self.floatTime + dt
            self.floatOffset = math.sin(self.floatTime * 2) * 4
            --self.rot = math.sin(self.floatTime * 2) * math.rad(1.5)
            self.rot = angleToMouse
        else
            self.floatTime = 0
            self.floatOffset = (self.floatOffset or 0) * (1 - dt * 5)
            --self.rot = (self.rot or 0) * (1 - dt * 5)
            self.rot = angleToMouse
        end

        if self.shootTimer > 0 then
            self.shootTimer = self.shootTimer - dt
        end
    end

    return self
end

return player
