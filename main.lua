function love.load()
    math.randomseed(os.time())

    d1 = 0
    d2 = 0
    colliderToggle = false

    require("src/startup/gameStart")
    gameStart()
    createNewSave()

    loadMap("menu")
    menu:open()

    dj.volume("effect", 1)

end

function love.update(dt)
    updateAll(dt)
end

function love.draw()
    drawBeforeCamera()

    cam:attach()
        drawCamera()
        if colliderToggle then
            world:draw()
            particleWorld:draw()
        end
    cam:detach()

    drawAfterCamera()

    --debug:d()
    --debug:single()
end

function love.keypressed(key)
    if key == 'q' then
        --colliderToggle = not (colliderToggle and true);
    end

    if tutorialDialog.active then
        tutorialDialog:keypressed(key)
        return
    end

    if gamestate == 3 then
        endScreen:keypressed(key)
        return
    end

    if death.active then
        death:keypressed(key)
        return
    end

    if pause.active then
        pause:keypressed(key)
        return
    end

    if inventory.active then
        inventory:keypressed(key)
        return
    end

    if key == 'backspace' and love.system.getOS() ~= "Web" then
        if fullscreen then
            local newWidth = 1920
            local newHeight = 1080
            local fractionW = love.graphics.getWidth()*0.9
            local fractionH = love.graphics.getHeight()*0.9
            if fractionW < newWidth then
                newWidth = fractionW
            end
            if fractionH < newHeight then
                newHeight = fractionH
            end

            setWindowSize(false, newWidth, newHeight)
        else
            setWindowSize(true)
        end
        reinitSize()
        return
    end

    if gamestate == 0 then
        menu:keypressed(key)
        return
    end

    if intro.active then
        intro:keypressed(key)
        return
    end

    if key == 'escape' or key == 'return' then
        pause:toggle()
    elseif key == 'tab' or key == 'i' then
        inventory:toggle()
    elseif key == 'space' then
        player:roll()
    elseif key == 'j' then
        player:swingSword()
    end
end

function love.mousepressed( x, y, button )
    if gamestate == 3 then
        endScreen:mousepressed(button)
        return
    end

    if death.active then
        if button == 1 then death:click() end
        return
    end

    if inventory.active then return end

    if pause.active then
        if button == 1 then pause:click() end
        return
    end

    if gamestate == 0 then
        menu:mousepressed(button)
        return
    end

    if intro.active then
        if button == 1 then intro:advance() end
        return
    end

    if button == 1 then
        player:swingSword()
    end
end
