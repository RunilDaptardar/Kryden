function loadMap(mapName, destX, destY)
    destroyAll()

    if menuMusic and mapName ~= "menu" and menuMusic.fadeTimer <= 0 then
        menuMusic:fadeOut(0.5, false)
    end

    if player and data and data.maxHealth then
        player.health = data.maxHealth
    end

    if destX and destY then
        player:setPosition(destX, destY)
    end

    loadedMap = mapName
    gameMap = sti("maps/" .. mapName .. ".lua")

    if not destX and not destY and gameMap.layers["Transitions"] then
        for _, obj in pairs(gameMap.layers["Transitions"].objects) do
            if obj.name == "spawn" then
                local spawnX = obj.x + obj.width / 2
                local spawnY = obj.y + obj.height / 2
                player:setPosition(spawnX, spawnY)
                break
            end
        end
    end

    if not destX and not destY then
        local spawnLayer = gameMap.layers["Spawn"] or gameMap.layers["Spawns"]
        if spawnLayer then
            for _, obj in pairs(spawnLayer.objects) do
                local spawnX = obj.x + (obj.width or 0) / 2
                local spawnY = obj.y + (obj.height or 0) / 2
                player:setPosition(spawnX, spawnY)
                break
            end
        end
    end

    for _, layer in ipairs(gameMap.layers) do
        if layer.type == "objectgroup" and layer.name then
            local layerName = layer.name:lower()
            if layerName == "walls" or layerName == "collisions" then
                for _, obj in pairs(layer.objects) do
                    if obj.shape ~= "rectangle" or not obj.width or not obj.height then
                        print("Skipping unsupported collision object on layer " .. layer.name)
                    else
                        spawnWall(obj.x, obj.y, obj.width, obj.height, obj.name, obj.type)
                    end
                end
            end
        end
    end

    if gameMap.layers["Enemies"] then
        for i, obj in pairs(gameMap.layers["Enemies"].objects) do
            local args = {}
            if obj.properties.form then args.form = obj.properties.form end
            spawnEnemy(obj.x, obj.y, obj.name, args)
        end
    end

    if gameMap.layers["Bosses"] then
        for i, obj in pairs(gameMap.layers["Bosses"].objects) do
            local args = {}
            if obj.properties.form then args.form = obj.properties.form end
            spawnEnemy(obj.x, obj.y, obj.name, args)
        end
    end

    if gameMap.layers["Transitions"] then
        for i, obj in pairs(gameMap.layers["Transitions"].objects) do
            spawnTransition(obj.x, obj.y, obj.width, obj.height, obj.name, obj.properties.destX, obj.properties.destY, obj.type)
        end
    end

    if gameMap.layers["DialogTriggers"] then
        for i, obj in pairs(gameMap.layers["DialogTriggers"].objects) do
            spawnTutorialDialogTrigger(obj.x, obj.y, obj.width, obj.height, obj.name)
        end
    end

    if gameMap.layers["Triggers"] then
        for i, obj in pairs(gameMap.layers["Triggers"].objects) do
            spawnTrigger(obj.x, obj.y, obj.name)
        end
    end

    if gameMap.properties.dark then
        gameMap.dark = gameMap.properties.dark
    else
        gameMap.dark = false
    end

end