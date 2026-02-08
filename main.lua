local collisions = require("src.helper.collisions")
local map = require("src.mechanics.map")
local MusicManager = require("src.helper.MusicManager")
local UnderwaterLoop = require("src.helper.UnderwaterLoop")



tileSize = map.tileSize
tiles = map.tiles

tileset = love.graphics.newImage("src/assets/TILEMAP.png")
tileset:setFilter("nearest", "nearest")

local tilesPerRow = 14
rows = math.floor(tileset:getHeight() / tileSize)
local cols = tilesPerRow
mapQuads = {}

for i = 0, (rows * cols - 1) do
    local x = (i % cols) * tileSize
    local y = math.floor(i / cols) * tileSize
    mapQuads[i + 1] = love.graphics.newQuad(x, y, tileSize, tileSize, tileset)
end

local playerEntity = require("src.entities.player")
local Mine = require("src.entities.Mine")
local Harpooner = require("src.entities.Harpooner")
BubbleSystem = require("src.effects.BubbleSystem")
Bubbles = BubbleSystem.new()

local player = playerEntity.new(300, 100)

enemies = {}
projectiles = {}

table.insert(enemies, Mine.new(100, 50))
table.insert(enemies, Harpooner.new(100, 50))

function updateEnemies(dt, player)
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy:update(dt, player)
        if enemy.dead then
            table.remove(enemies, i)
        end
    end
end

function updateProjectiles(dt)
    for i = #projectiles, 1, -1 do
        local projectile = projectiles[i]
        projectile:update(dt)
        if projectile.dead or projectile.y < 0 then
		table.remove(projectiles, i)
end
		
    end
end

function drawEnemies()
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end
end

function drawProjectiles()
    for _, projectile in ipairs(projectiles) do
        projectile:draw()
    end
end

function drawMap()
    for _, layer in ipairs(tiles) do
        for y, row in ipairs(layer) do
            for x, tile in ipairs(row) do
                if tile ~= 0 and tile ~= -1 then
                    love.graphics.draw(tileset, mapQuads[tile +1], (x-1)* tileSize, (y-1)*tileSize)
                end
            end
        end
    end
end

local function isSolid(tile)
    return tile ~= 0 and tile ~= -1
end

function checkTileCollision(entity)
    for _, layer in ipairs(tiles) do
        for y, row in ipairs(layer) do
            for x, tile in ipairs(row) do
                if isSolid(tile) then
                    local tileRect = {
                        x = (x -1) * tileSize,
                        y = (y -1 ) * tileSize,
                        w = tileSize,
                        h = tileSize
                    }

                    if collisions.checkCollision(entity, tileRect) then
                        return true, tileRect
                    end
                end
            end
        end
    end
    return false
end

function love.load()
    Music = MusicManager.new()
    Music:Play()
    camera = require("lib.camera")
    camera.scale = 4
    local icon = love.image.newImageData("src/assets/gameicon/icon.png")
    love.window.setTitle("Wave To Glory")
    love.window.setIcon(icon)
    love.window.setMode(1920, 1080, {resizable = false, minwidth = 1280, minheight = 720})
    love.graphics.setBackgroundColor(0.1, 0.2, 0.5)

    local cursor = love.image.newImageData("src/assets/UIElements/TheGunCursor.png")
    customCursor = love.mouse.newCursor(cursor, 0, 0)
    love.mouse.setCursor(customCursor)

    player.load()

    Underwater = UnderwaterLoop.new()
    Underwater:Play()

    camera:setBounds(map.tiles, map.tileSize)
end

function love.draw()
    camera:attach()
    drawMap()
    drawEnemies()
    drawProjectiles()
    player.draw()
    Bubbles:Draw()

        love.graphics.rectangle(
        "line",
        player.collisions.x,
        player.collisions.y,
        player.collisions.w,
        player.collisions.h
    )
    camera.detach()
end

function love.update(dt)
    local oldX = player.x
    local oldY = player.y

    camera:follow(player, dt)
    player.update(dt)
    Bubbles:Update(dt)
    updateEnemies(dt, player )
    updateProjectiles(dt)

    player.collisions.x = player.x - player.collisions.w / 2
    player.collisions.y = player.y - player.collisions.h / 2
    local wasColliding = checkTileCollision(player.collisions)

    local oldX = player.x
    local oldY = player.y

    player.update(dt)

    player.collisions.x = player.x - player.collisions.w / 2
    player.collisions.y = player.y - player.collisions.h / 2
    local isColliding = checkTileCollision(player.collisions)

    Underwater:Update(dt, player)

    if isColliding and not wasColliding then
        player.x = oldX
        player.y = oldY
        player.collisions.x = player.x - player.collisions.w / 2
        player.collisions.y = player.y - player.collisions.h / 2
    end
end

