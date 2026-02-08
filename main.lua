local playerEntity = require("src.entities.player")
local Mine = require("src.entities.Mine")
local MagneticMiner = require("src.entities.Mine")
BubbleSystem = require("src.effects.BubbleSystem")
Bubbles = BubbleSystem.new()

local player = playerEntity.new(50, 200)

enemies = {}

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

function drawEnemies()
    for _, enemy in ipairs(enemies) do
        enemy:draw()
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
    drawEnemies()
    Bubbles:Draw()
end

function love.update(dt)
    player.update(dt)
    updateEnemies(dt)
    Bubbles:Update(dt)
end
