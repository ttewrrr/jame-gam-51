local function loadCSVMap(filename)
    local data = love.filesystem.read(filename)

    local map = {}

    for line in data:gmatch("[^\r\n]+") do
        local row = {}
        for value in line:gmatch("([^,]+)") do
            table.insert(row, tonumber(value) or -1)
        end
        table.insert(map, row)
    end

    return map
end

local groundTiles = loadCSVMap("src/maps/MapCSV/Map_Ground.csv")
 
local backgroundTiles = loadCSVMap("src/maps/MapCSV/Map_Backround.csv")

local tiles = {
    backgroundTiles,
    groundTiles
}

return {
    tileSize = 16,
    tiles = tiles
}
