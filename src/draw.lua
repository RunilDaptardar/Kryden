function drawBeforeCamera()
    menu:draw()
end

function drawCamera()

    if gamestate ~= 1 then return end
    setWhite()

    for _, layer in ipairs(gameMap.layers) do
        if layer.type == "tilelayer" and not layer.properties.hide then
            gameMap:drawLayer(layer)
        end
    end

    if gameMap.layers["Test"] then
        --gameMap:drawLayer(gameMap.layers["Test"])
    end

    walls:draw()
    effects:draw(-1) -- two layers of effects
    effects:draw(0)
    player:draw()
    enemies:draw()
    effects:drawDarkMagic()
    blasts:draw()
    projectiles:draw()
    effects:draw(1)
    particles:draw()

    if gameMap.dark then
        --love.graphics.setShader(shaders.trueLight)
        --love.graphics.rectangle("fill", -10, -10, 10000, 10000)
        --love.graphics.setShader()
        love.graphics.draw(sprites.effects.darkness, player:getX(), player:getY(), nil, nil, nil, sprites.effects.darkness:getWidth()/2, sprites.effects.darkness:getHeight()/2)
    end

end

function drawAfterCamera()
    curtain:draw()
    endScreen:draw()
    if gamestate == 0 then return end
    if gamestate == 1 then drawHUD() end
    intro:draw()
    tutorialDialog:draw()
    pause:draw()
    death:draw()
    inventory:draw()
end