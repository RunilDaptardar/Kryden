death = {}

death.active = false
death.closing = false
death.alpha = 0
death.selected = 1

function death:init()
    death.active = false
    death.closing = false
    death.scale = scale
    death.alpha = 0
    death.trueY = 0 * death.scale
    death.fadeY = 40 * death.scale
    death.y = death.fadeY

    if windowWidth < windowHeight then
        death.scale = scale * 0.8
    end

    death.lineHeight = 16 * death.scale
    death.optionWidth = 90 * death.scale
    death.options = {
        { label = "Continue", action = function() death:continue() end },
    }
    death.selected = 1
end

function death:open()
    if death.active then return end
    death:init()
    pause.active = false
    pause.closing = false
    inventory.active = false
    player.health = 0
    player.state = -1
    player:setLinearVelocity(0, 0)
    death.active = true
    dj.play(sounds.ui.menuOpen, "static", "effect")
    flux.to(death, 0.25, {alpha = 1}):ease("quadout")
    flux.to(death, 0.25, {y = death.trueY}):ease("quadout")
end

function death:continue()
    for i = #flux.tweens, 1, -1 do
        local tween = flux.tweens[i]
        if tween.obj == curtain then
            tween:stop()
        end
    end
    curtain.state = 0
    curtain.alpha = 0
    curtain.rad = 0

    createNewSave(1)
    startFresh(1)
    player.health = data.maxHealth
    gamestate = 1
    player.state = 0
    death:init()
    love.graphics.setBackgroundColor(26/255, 26/255, 26/255)
    loadMap(data.map, data.playerX, data.playerY)
end

function death:keypressed(key)
    if death.closing or death.alpha < 1 then return end

    if key == 'return' or key == 'space' or key == 'e' then
        death:select(death.selected)
    elseif key == 'w' or key == 'up' then
        death.selected = (death.selected - 2) % #death.options + 1
        dj.play(sounds.ui.click, "static", "effect")
    elseif key == 's' or key == 'down' then
        death.selected = death.selected % #death.options + 1
        dj.play(sounds.ui.click, "static", "effect")
    end
end

function death:select(index)
    if death.options[index] == nil then return end
    dj.play(sounds.ui.select, "static", "effect")
    death.options[index].action()
end

function death:getOptionY(index)
    local cy = love.graphics.getHeight()/2
    return death.y + cy + (index - 1) * death.lineHeight - death.lineHeight
end

function death:getHoverIndex()
    local mx, my = love.mouse.getPosition()
    local left = love.graphics.getWidth()/2 - death.optionWidth/2
    for i,_ in ipairs(death.options) do
        local oy = death:getOptionY(i)
        if mx >= left and mx <= left + death.optionWidth and my >= oy and my < oy + death.lineHeight then
            return i
        end
    end
end

function death:click()
    if death.closing or death.alpha < 1 then return end
    local hovered = death:getHoverIndex()
    if hovered then death:select(hovered) end
end

function death:update(dt)
    if not death.active or death.closing then return end

    local hovered = death:getHoverIndex()
    if hovered and hovered ~= death.selected then
        death.selected = hovered
        dj.play(sounds.ui.click, "static", "effect")
    end
end

function death:draw()
    if not death.active then return end

    love.graphics.setColor(0, 0, 0, 0.7 * death.alpha)
    love.graphics.rectangle("fill", -10, -10, love.graphics.getWidth() + 20, love.graphics.getHeight() + 20)

    local cy = love.graphics.getHeight()/2

    love.graphics.setColor(0.9, 0.08, 0.08, death.alpha)
    love.graphics.setFont(fonts.pause1)
    love.graphics.printf("You Died", love.graphics.getWidth()/2 - 4000, death.y + cy - 40 * death.scale, 8000, "center")

    for i,o in ipairs(death.options) do
        if i == death.selected then
            love.graphics.setColor(1, 1, 1, death.alpha)
            love.graphics.printf("> " .. o.label .. " <", love.graphics.getWidth()/2 - 4000, death:getOptionY(i), 8000, "center")
        else
            love.graphics.setColor(1, 1, 1, 0.55 * death.alpha)
            love.graphics.printf(o.label, love.graphics.getWidth()/2 - 4000, death:getOptionY(i), 8000, "center")
        end
    end

    love.graphics.setColor(1, 1, 1, 0.7 * death.alpha)
    love.graphics.setFont(fonts.pause2)
    love.graphics.printf("Reset the game", love.graphics.getWidth()/2 - 4000, death.y + cy + 50 * death.scale, 8000, "center")
end
