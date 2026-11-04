function createNewSave(fileNumber)

    -- This represents the save data
    data = {}
    data.saveCount = 0 -- times the game was saved
    data.progress = 0 -- milestone tracker
    data.playerX = 0 -- player's X position
    data.playerY = 0 -- player's Y position
    data.maxHealth = 100
    data.money = 0 -- amount of currency
    data.keys = 0 -- number of keys
    data.map = "" -- currently loaded map
    data.outfit = 1 -- which cloak is equipped

    if fileNumber == nil then fileNumber = 1 end
    data.fileNumber = fileNumber -- which file are we using

    -- table that keeps track of breakables that have been destroyed
    data.breakables = {}

end

function saveGame()
    data.saveCount = data.saveCount + 1
    data.playerX = player:getX()
    data.playerY = player:getY()
    data.map = loadedMap

    if data.fileNumber == 1 then
        love.filesystem.write("file1.lua", table.show(data, "data"))
    elseif data.fileNumber == 2 then
        love.filesystem.write("file2.lua", table.show(data, "data"))
    elseif data.fileNumber == 3 then
        love.filesystem.write("file3.lua", table.show(data, "data"))
    end
end
  
function loadGame(fileNumber)
    if fileNumber == 1 then
        if love.filesystem.getInfo("file1.lua") ~= nil then
            local data = love.filesystem.load("file1.lua")
            data()
        else
            startFresh(1)
            return "No data found for save file #1"
        end
    elseif fileNumber == 2 then
        if love.filesystem.getInfo("file2.lua") ~= nil then
            local data = love.filesystem.load("file2.lua")
            data()
        else
            startFresh(2)
            return "No data found for save file #2"
        end
    elseif fileNumber == 3 then
        if love.filesystem.getInfo("file3.lua") ~= nil then
            local data = love.filesystem.load("file3.lua")
            data()
        else
            startFresh(3)
            return "No data found for save file #3"
        end
    end

    if data.maxHealth ~= 100 then
        data.maxHealth = 100
        player.health = data.maxHealth
    end

    --loadMap(data.map, data.playerX, data.playerY)
    player.direction = "up"
    --player.state = 0
    --gamestate = 1
end

function startFresh(fileNumber)
    createNewSave(fileNumber)
    data.map = "spawnCave"
    data.playerX = nil
    data.playerY = nil
    player.state = 0
end
