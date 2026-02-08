local projectile = require("src.entities.projectile")
local HealthComponent = require("src.mechanics.HealthComponent")

local player = {}

local playerSprites = {}
shootSound = love.audio.newSource("src/sounds/real/PlayerFireGun.wav", "static")
shootSoundSonar = love.audio.newSource("src/sounds/real/PlayerFireSonarBlast.wav", "static")

function player.new(x, y)
    local self = setmetatable({}, player)
	
    self.x = x or 0
    self.y = y or 0
    self.rot = 0
    self.direction = 1
    self.idle = true
    self.collisions = {w = 20, h = 20}
    self.collisions.x = self.x - self.collisions.w / 2
    self.collisions.y = self.y - self.collisions.h / 2

    self.sprite = 1
	
    self.floatTime = 0
    self.floatOffset = 0

    self.shootTimer = 0
    self.shootCooldown = 0.4

    self.shootSpriteTimer = 0
    self.shootSpriteDuration = 0.08

    self.sonarTimer = 0
    self.sonarCooldown = 10.0

    self.SonarSequenceActive = false
    self.SonarSpriteStartId = 4
    self.SonarSpriteEndId = 7
    self.SonarFrameDelay = 0.1
    self.SonarFrameTimer = 0

	self.HealthComponent = HealthComponent.new(self, 300, 2)
    self.HealthComponent.IsPlayer = true
    self.HealthComponent.DrawHealthBar = true
    self.HealthComponent.HealthBarScale = 2

    function self.shoot()
        table.insert(projectiles, projectile.new(self.x, self.y, self.rot, self, 1))

        if not self.SonarSequenceActive then
            self.sprite = 2
            self.shootSpriteTimer = self.shootSpriteDuration
        end

        local s = shootSound:clone()
        s:play()

		Bubbles:SpawnBubbles(self.x, self.y, 6, 6, 5, 1)
    end

    function self.startSonarSequence()
        self.SonarSequenceActive = true
        self.SonarFrameTimer = self.SonarFrameDelay
        self.sprite = self.SonarSpriteStartId

        local s = shootSoundSonar:clone()
        s:play()
    end

    function self.updateSonarSequence(dt)
        if not self.SonarSequenceActive then return end

        self.SonarFrameTimer = self.SonarFrameTimer - dt
        if self.SonarFrameTimer > 0 then return end

        self.SonarFrameTimer = self.SonarFrameDelay

        if self.sprite < self.SonarSpriteEndId then
            self.sprite = self.sprite + 1
            return
        end

        table.insert(projectiles, projectile.new(self.x, self.y, self.rot, self, 10))
        Bubbles:SpawnBubbles(self.x, self.y, 10, 10, 10, 1)

        self.SonarSequenceActive = false
        self.sprite = 1
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

        if love.mouse.isDown(2) and self.sonarTimer <= 0 and not self.SonarSequenceActive then
            self.startSonarSequence()
            self.sonarTimer = self.sonarCooldown
        end

        function love.keyreleased(key)
            if key == "right" or key == "left" or key == "up" or key == "down" then
                self.idle = true
            end
        end

        local mouseWorldX = camera.x + (love.mouse.getX() / camera.scale) - (love.graphics.getWidth() / (2 * camera.scale))
        local mouseWorldY = camera.y + (love.mouse.getY() / camera.scale) - (love.graphics.getHeight() / (2 * camera.scale))
        
        local angleToMouse = math.atan2(mouseWorldY - self.y, mouseWorldX - self.x)
        if angleToMouse > math.pi / 2 or angleToMouse < -math.pi / 2 then
            self.flipX = -1
            self.rot = math.pi - angleToMouse
        else
            self.flipX = 1
            self.rot = angleToMouse
        end



        if self.idle then
            self.floatTime = self.floatTime + dt
            self.floatOffset = math.sin(self.floatTime * 2) * 4
            self.rot = angleToMouse
        else
            self.floatTime = 0
            self.floatOffset = (self.floatOffset or 0) * (1 - dt * 5)
            self.rot = angleToMouse
			
			if love.math.random() < 0.03 then
				Bubbles:SpawnBubbles(self.x, self.y, 6, 6, 1, 1)
			end
        end

        self.updateSonarSequence(dt)

        if not self.SonarSequenceActive then
            if self.shootSpriteTimer > 0 then
                self.shootSpriteTimer = self.shootSpriteTimer - dt
                if self.shootSpriteTimer <= 0 then
                    self.sprite = 1
                end
            end
        end

        if self.shootTimer > 0 then
            self.shootTimer = self.shootTimer - dt
        end

        if self.sonarTimer > 0 then
            self.sonarTimer = self.sonarTimer - dt
        end
    end

    return self
end

return player
