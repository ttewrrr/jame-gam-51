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

local tiles = loadCSVMap("src/maps/map1.csv")

return {
    tileSize = 16,
    tiles = tiles
}
