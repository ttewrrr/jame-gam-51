local projectile = require("src.entities.projectile")
local HealthComponent = require("src.mechanics.HealthComponent")

local player = {}

local playerSprites = {}
shootSound = love.audio.newSource("src/sounds/real/PlayerFireGun.wav", "static")

function player.new(x, y)
    local self = setmetatable({}, player)
	
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
	
	self.HealthComponent = HealthComponent.new(self, 100, 2) --max hp, damage par, 2 is blood 3 is sparks for mines or other stuff	
    self.HealthComponent.IsPlayer = true
    self.HealthComponent.DrawHealthBar = true
    self.HealthComponent.HealthBarScale = 2
	
		--To Apply Damage to stuff from enemy projectile
	--player.HealthComponent:EventAnyDamage(25,projectile self,projectile.x,projectile.y)

    function self.shoot()
        table.insert(projectiles, projectile.new(self.x, self.y, self.rot))
        self.sprite = 2
        self.sprite = 1
        local s = shootSound:clone()
        s:play()
		Bubbles:SpawnBubbles(self.x, self.y, 6, 6, 5, 1)
    end

    function self.load()
        playerSprite = love.graphics.newImage("src/assets/Player/PlayerSpritesheet.png")
        playerSprite:setFilter("nearest", "nearest")

        for i = 0, 6 do
            playerSprites[i + 1] = love.graphics.newQuad(i * 64, 0, 64, 64, playerSprite:getDimensions())
        end
    end

    function self.draw()
        
        if self.HealthComponent.dead then
	    return
	    end
        self.HealthComponent:Draw()
        --love.graphics.print("Player x: ".. self.x .. " Player y: " .. self.y, 100, 100)
        love.graphics.draw(playerSprite, playerSprites[self.sprite], self.x, self.y + self.floatOffset, self.rot, 1, 1, 32, 32)
    end

    function self.update(dt)
	
		if self.HealthComponent.dead then
		return
		end

	
		if love.keyboard.isDown("o") then
		self.HealthComponent:EventAnyDamage(1, nil, self.x, self.y)
		end
	
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
            self.rot = angleToMouse
        else
            self.floatTime = 0
            self.floatOffset = (self.floatOffset or 0) * (1 - dt * 5)
            self.rot = angleToMouse
			
			if love.math.random() < 0.1 then
				Bubbles:SpawnBubbles(self.x, self.y, 6, 6, 1, 1)
			end
			
        end

        if self.shootTimer > 0 then
            self.shootTimer = self.shootTimer - dt
        end
    end

    return self
end

return player
