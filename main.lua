local map = require("src.mechanics.map")

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

local player = playerEntity.new(50, 200)

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

function love.load()
    local icon = love.image.newImageData("src/assets/gameicon/icon.png")
    love.window.setTitle("Wave To Glory")
    love.window.setIcon(icon)
    love.window.setMode(1920, 1080, {resizable = false, minwidth = 1280, minheight = 720})
    love.graphics.setBackgroundColor(0.1, 0.2, 0.5)

    local cursor = love.image.newImageData("src/assets/UIElements/TheGunCursor.png")
    customCursor = love.mouse.newCursor(cursor, 0, 0)
    love.mouse.setCursor(customCursor)

    player.load()
end

function love.draw()
    love.graphics.scale(4, 4)

    drawMap()
    drawEnemies()
    drawProjectiles()
    player.draw()
    Bubbles:Draw()
end

function love.update(dt)
    player.update(dt)
    Bubbles:Update(dt)
    updateEnemies(dt, player )
    updateProjectiles(dt)
end
