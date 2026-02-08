local collisions = require("src.helper.collisions")
local map = require("src.mechanics.map")
local MusicManager = require("src.helper.MusicManager")
local UnderwaterLoop = require("src.helper.UnderwaterLoop")

local playerEntity = require("src.entities.player")
local Mine = require("src.entities.Mine")
local Harpooner = require("src.entities.Harpooner")

BubbleSystem = require("src.effects.BubbleSystem")
Bubbles = BubbleSystem.new()

explosions = explosions or {}
enemies = enemies or {}
projectiles = projectiles or {}

local SpawnTimer = 0
local SpawnIntervalMin = 1.2
local SpawnIntervalMax = 2.4
local SpawnDistanceMin = 180
local SpawnDistanceMax = 260

local function RandRange(a, b)
    return a + love.math.random() * (b - a)
end

local function SpawnHarpoonerNearPlayer(p)
    if not p then return end
    if not enemies then return end

    local angle = love.math.random() * math.pi * 2
    local dist = RandRange(SpawnDistanceMin, SpawnDistanceMax)

    local x = p.x + math.cos(angle) * dist
    local y = p.y + math.sin(angle) * dist

    table.insert(enemies, Harpooner.new(x, y))
end

local function updateExplosions(dt)
    for i = #explosions, 1, -1 do
        local e = explosions[i]
        e:update(dt)
        if e.dead then table.remove(explosions, i) end
    end
end

local function drawExplosions()
    for i = 1, #explosions do
        explosions[i]:draw()
    end
end

local function updateEnemies(dt, player)
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy:update(dt, player)
        if enemy.dead then table.remove(enemies, i) end
    end
end

local function updateProjectiles(dt)
    for i = #projectiles, 1, -1 do
        local p = projectiles[i]
        p:update(dt)
        if p.dead or p.y < 0 then table.remove(projectiles, i) end
    end
end

local function drawEnemies()
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end
end

local function drawProjectiles()
    for _, p in ipairs(projectiles) do
        p:draw()
    end
end

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

local function drawMap()
    for _, layer in ipairs(tiles) do
        for y, row in ipairs(layer) do
            for x, tile in ipairs(row) do
                if tile ~= 0 and tile ~= -1 then
                    love.graphics.draw(tileset, mapQuads[tile + 1], (x - 1) * tileSize, (y - 1) * tileSize)
                end
            end
        end
    end
end

local function isSolid(tile)
    return tile ~= 0 and tile ~= -1
end

local function checkTileCollision(entity)
    for _, layer in ipairs(tiles) do
        for y, row in ipairs(layer) do
            for x, tile in ipairs(row) do
                if isSolid(tile) then
                    local tileRect = { x = (x - 1) * tileSize, y = (y - 1) * tileSize, w = tileSize, h = tileSize }
                    if collisions.checkCollision(entity, tileRect) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local player = playerEntity.new(300, 100)

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

    enemies = {}
    projectiles = {}
    explosions = {}

    table.insert(enemies, Mine.new(300, 50))
    table.insert(enemies, Harpooner.new(500, 50))

    SpawnTimer = RandRange(SpawnIntervalMin, SpawnIntervalMax)
end

function love.draw()
    camera:attach()
    drawMap()
    drawExplosions()
    drawEnemies()
    drawProjectiles()
    player.draw()
    Bubbles:Draw()

    love.graphics.rectangle("line", player.collisions.x, player.collisions.y, player.collisions.w, player.collisions.h)

    camera:detach()
end

function love.update(dt)
    updateExplosions(dt)

    local oldX = player.x
    local oldY = player.y

    player.update(dt)

    player.collisions.x = player.x - player.collisions.w / 2
    player.collisions.y = player.y - player.collisions.h / 2

    if checkTileCollision(player.collisions) then
        player.x = oldX
        player.y = oldY
        player.collisions.x = player.x - player.collisions.w / 2
        player.collisions.y = player.y - player.collisions.h / 2
    end

    camera:follow(player, dt)

    Bubbles:Update(dt)
    updateEnemies(dt, player)
    updateProjectiles(dt)

    Underwater:Update(dt, player)

    if player and player.HealthComponent and not player.HealthComponent.dead then
        SpawnTimer = SpawnTimer - dt
        if SpawnTimer <= 0 then
            SpawnHarpoonerNearPlayer(player)
            SpawnTimer = RandRange(SpawnIntervalMin, SpawnIntervalMax)
        end
    end
end
