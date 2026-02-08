-- Load map from JSON file
local json = require("lib/dkjson") -- Make sure you have a JSON module like rxi/json.lua
local mapDataRaw = love.filesystem.read("src/maps/map.json")
local mapData = json.decode(mapDataRaw)

-- Extract tiles and tile size
local tileSize = mapData.tileSize or 16
local tiles = mapData.tiles or {}

-- Return as a table
return {
    tileSize = tileSize,
    tiles = tiles
}
