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

-- =========================
-- SPAWN TUNING
-- =========================
local SpawnTimer = 0
local SpawnIntervalMin = 1.2
local SpawnIntervalMax = 2.4
local SpawnDistanceMin = 180
local SpawnDistanceMax = 260

-- Mines (separate timer + distance)
local MineSpawnTimer = 0
local MineSpawnIntervalMin = 3.5
local MineSpawnIntervalMax = 6.5
local MineSpawnDistanceMin = 140
local MineSpawnDistanceMax = 240

local function RandRange(a, b)
    return a + love.math.random() * (b - a)
end

-- =========================
-- MAP DRAW / COLLISION
-- =========================
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

-- =========================
-- SPAWN HELPERS (NEW)
-- =========================
local function FindSpawnPosNearPlayer(p, distMin, distMax, tries, testW, testH)
    if not p then return nil end
    tries = tries or 12
    testW = testW or 32
    testH = testH or 32

    local lastX, lastY = p.x, p.y

    for _ = 1, tries do
        local angle = love.math.random() * math.pi * 2
        local dist = RandRange(distMin, distMax)

        local x = p.x + math.cos(angle) * dist
        local y = p.y + math.sin(angle) * dist

        lastX, lastY = x, y

        -- test rect to avoid spawning inside solid tiles
        local testRect = { x = x - testW / 2, y = y - testH / 2, w = testW, h = testH }
        if not checkTileCollision(testRect) then
            return x, y
        end
    end

    -- fallback: if all tries fail, spawn at last computed position
    return lastX, lastY
end

local function SpawnHarpoonerNearPlayer(p)
    if not p or not enemies then return end

    local x, y = FindSpawnPosNearPlayer(p, SpawnDistanceMin, SpawnDistanceMax, 12, 32, 32)
    table.insert(enemies, Harpooner.new(x, y))
end

local function SpawnMineNearPlayer(p)
    if not p or not enemies then return end

    -- If your mine is bigger/smaller, change 32,32 to match.
    local x, y = FindSpawnPosNearPlayer(p, MineSpawnDistanceMin, MineSpawnDistanceMax, 12, 32, 32)
    table.insert(enemies, Mine.new(x, y))
end

-- =========================
-- UPDATE/DRAW HELPERS
-- =========================
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

local function updateEnemies(dt, p)
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy:update(dt, p)
        if enemy.dead then table.remove(enemies, i) end
    end
end

local function updateProjectiles(dt)
    for i = #projectiles, 1, -1 do
        local pr = projectiles[i]
        pr:update(dt)
        if pr.dead or pr.y < 0 then table.remove(projectiles, i) end
    end
end

local function drawEnemies()
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end
end

local function drawProjectiles()
    for _, pr in ipairs(projectiles) do
        pr:draw()
    end
end

-- =========================
-- PLAYER
-- =========================
player = playerEntity.new(300, 100)

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

    -- initial enemies
    table.insert(enemies, Mine.new(300, 50))
    table.insert(enemies, Harpooner.new(500, 50))

    -- init timers
    SpawnTimer = RandRange(SpawnIntervalMin, SpawnIntervalMax)
    MineSpawnTimer = RandRange(MineSpawnIntervalMin, MineSpawnIntervalMax)
end

function love.draw()
    camera:attach()

    drawMap()
    drawExplosions()
    drawEnemies()
    drawProjectiles()
    player.draw()
    Bubbles:Draw()

    camera:detach()
end

function love.update(dt)
    updateExplosions(dt)

    -- pre-move collision snapshot
    player.collisions.x = player.x - player.collisions.w / 2
    player.collisions.y = player.y - player.collisions.h / 2
    local wasColliding = checkTileCollision(player.collisions)

    local oldX = player.x
    local oldY = player.y

    player.update(dt)

    -- post-move collision
    player.collisions.x = player.x - player.collisions.w / 2
    player.collisions.y = player.y - player.collisions.h / 2
    local isColliding = checkTileCollision(player.collisions)

    if isColliding and not wasColliding then
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

    -- =========================
    -- SPAWNING (Harpooners + Mines)
    -- =========================
    if player and player.HealthComponent and not player.HealthComponent.dead then
        -- Harpooners
        SpawnTimer = SpawnTimer - dt
        if SpawnTimer <= 0 then
            SpawnHarpoonerNearPlayer(player)
            SpawnTimer = RandRange(SpawnIntervalMin, SpawnIntervalMax)
        end

        -- Mines
        MineSpawnTimer = MineSpawnTimer - dt
        if MineSpawnTimer <= 0 then
            SpawnMineNearPlayer(player)
            MineSpawnTimer = RandRange(MineSpawnIntervalMin, MineSpawnIntervalMax)
        end
    end
end
