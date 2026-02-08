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
<<<<<<< HEAD
local MagneticMiner = require("src.entities.MagneticMiner")
local projectile = require("src.entities.projectile")
=======
local MagneticMiner = require("src.entities.Mine")
BubbleSystem = require("src.effects.BubbleSystem")
Bubbles = BubbleSystem.new()
>>>>>>> 4ba03988a78a34c7cedc897a9795482eb5ed9a0b

local player = playerEntity.new(50, 200)

enemies = {}
projectiles = {}

table.insert(enemies, Mine.new(100, 50))
table.insert(enemies, MagneticMiner.new(100, 50))

function updateEnemies(dt)
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy:update(dt)
        if enemy.dead then
            table.remove(enemies, i)
        end
    end
end

function updateProjectiles(dt)
    for i = #projectiles, 1, -1 do
        local projectile = projectiles[i]
        projectile:update(dt)
        if projectile.y < 0 then
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
    for y, row in ipairs(tiles) do
        for x, tile in ipairs(row) do
            if tile ~= 0 then
                love.graphics.draw(tileset, mapQuads[tile], (x-1)* tileSize, (y-1)*tileSize)
            end
        end
    end
end

function love.load()
    love.window.setTitle("Game")
    love.window.setMode(1920, 1080, {resizable = true, minwidth = 1280, minheight = 720})
    love.graphics.setBackgroundColor(0.1, 0.2, 0.5)

    player.load()
end

function love.draw()
    love.graphics.scale(4, 4)

    player.draw()
    drawMap()
    drawEnemies()
<<<<<<< HEAD
    drawProjectiles()
=======
    Bubbles:Draw()
>>>>>>> 4ba03988a78a34c7cedc897a9795482eb5ed9a0b
end

function love.update(dt)
    player.update(dt)
    updateEnemies(dt)
<<<<<<< HEAD
    updateProjectiles(dt)
end
=======
    Bubbles:Update(dt)
end
>>>>>>> 4ba03988a78a34c7cedc897a9795482eb5ed9a0b
