local player = {}

local playerSprites = {}

function player.new(x, y)
    self = setmetatable({}, player)

    self.Health = 100
    self.x = x or 0
    self.y = y or 0
    self.timer = 0
    self.direction = 1
    self.idle = true
    self.floatTime = 0
    self.floatOffset = 0
    self.rot = 0

    function self.load()
        playerSprite = love.graphics.newImage("src/assets/Player/PlayerSpritesheet.png")
        playerSprite:setFilter("nearest", "nearest")

        for i = 0, 6 do
            playerSprites[i + 1] = love.graphics.newQuad(i * 64, 0, 64, 64, playerSprite:getDimensions())
        end
    end

    function self.draw()
        love.graphics.print("Player x: ".. self.x .. " Player y: " .. self.y, 100, 100)
        love.graphics.draw(playerSprite, playerSprites[1], self.x, self.y + self.floatOffset, self.rot, self.direction, 1, 32, 32)
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
        if love.keyboard.isDown("space") then

        end

        function love.keyreleased(key)
            if key == "right" or key == "left" or key == "up" or key == "down" then
                self.idle = true
            end
        end

        if self.idle then
            self.floatTime = self.floatTime + dt
            self.floatOffset = math.sin(self.floatTime * 2) * 4
            self.rot = math.sin(self.floatTime * 2) * math.rad(1.5)
        else
            self.floatTime = 0
            self.floatOffset = (self.floatOffset or 0) * (1 - dt * 5)
            self.rot = (self.rot or 0) * (1 - dt * 5)
        end

        if not self.idle then
            --self.rot = math.rad(self.vy * 0.5)
            Bubbles:SpawnBubbles(self.x, self.y, 6, 6, 1)
        end
    end

    return self
end

return player
