function updateAll(dt)

    --if pause.active == false then
        updateGame(dt)
    --end
    
    pause:update(dt)
    death:update(dt)
    inventory:update(dt)
    menu:update(dt)
    intro:update(dt)
    endScreen:update(dt)
    menuMusic:update(dt)
    dj.cleanup()
    if gameMap then gameMap:update(dt) end
    checkWindowSize()

end

function updateGame(dt)
    if death and death.active then
        flux.update(dt)
        return
    end

    tutorialDialog:update(dt)

    if tutorialDialog.active then
        flux.update(dt)
        return
    end

    if inventory.active then
        flux.update(dt)
        return
    end

    miscUpdate(dt)
    if globalStun > 0 then return end

    flux.update(dt)

    player:update(dt)
    world:update(dt)
    walls:update(dt)
    blasts:update(dt)
    effects:update(dt)
    enemies:update(dt)
    enemies:destroyDead()
    projectiles:update(dt)

    cam:update(dt)
    shake:update(dt)
    shaders:update(dt)
    triggers:update(dt)
    particles:update(dt)
    particleWorld:update(dt)
end
