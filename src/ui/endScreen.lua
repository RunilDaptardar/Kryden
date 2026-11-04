endScreen = {}
endScreen.active = false
endScreen.alpha = 0
endScreen.textAlpha = 0
endScreen.selected = 1
endScreen.leaving = false

function endScreen:start()
    endScreen.active = true
    endScreen.alpha = 0
    endScreen.textAlpha = 0
    endScreen.selected = 1
    endScreen.leaving = false
    gamestate = 3
    menuMusic:start(false)
    player.state = 12
    player:setLinearVelocity(0, 0)
    flux.to(endScreen, 0.6, {alpha = 1, textAlpha = 1}):ease("quadout")
end

function endScreen:update(dt)
end

function endScreen:getOptions()
    local options = {
        {label = "Main Menu", action = function()
            if endScreen.leaving then return end
            endScreen.leaving = true
            menuMusic:fadeOut(1.8, false, false)
            flux.to(endScreen, 1.8, {textAlpha = 0}):ease("quadout"):oncomplete(function()
                endScreen.active = false
                gamestate = 0
                player.state = -1
                loadMap("menu")
                menu:open(true)
            end)
        end}
    }
    if love.system.getOS() ~= "Web" then
        table.insert(options, {
            label = "Quit",
            action = function() love.event.quit() end
        })
    end
    return options
end

function endScreen:keypressed(key)
    local options = endScreen:getOptions()
    if key == "w" or key == "up" then
        endScreen.selected = (endScreen.selected - 2) % #options + 1
    elseif key == "s" or key == "down" then
        endScreen.selected = endScreen.selected % #options + 1
    elseif key == "return" or key == "space" or key == "e" then
        options[endScreen.selected].action()
    elseif key == "escape" and love.system.getOS() ~= "Web" then
        love.event.quit()
    end
end

function endScreen:mousepressed(button)
    if button ~= 1 then return end
    local mx, my = love.mouse.getPosition()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local y = h/2 + 70 * scale
    for i, option in ipairs(endScreen:getOptions()) do
        local lineY = y + (i - 1) * 16 * scale
        if my >= lineY and my <= lineY + 16 * scale
        and mx >= w/2 - 200 and mx <= w/2 + 200 then
            endScreen.selected = i
            option.action()
            break
        end
    end
end

function endScreen:draw()
    if not endScreen.active then return end

    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(0, 0, 0, endScreen.alpha)
    love.graphics.rectangle("fill", -10, -10, w + 20, h + 20)

    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1, endScreen.textAlpha)
    love.graphics.printf("To Be Continued", w/2 - 4000, h/2 - 40 * scale, 8000, "center")

    love.graphics.setFont(fonts.pause1)
    local y = h/2 + 70 * scale
    for i, option in ipairs(endScreen:getOptions()) do
        local label = option.label
        if i == endScreen.selected then
            label = "> " .. label .. " <"
            love.graphics.setColor(1, 1, 1, endScreen.textAlpha)
        else
            love.graphics.setColor(1, 1, 1, 0.55 * endScreen.textAlpha)
        end
        love.graphics.printf(label, w/2 - 4000, y + (i - 1) * 16 * scale, 8000, "center")
    end
end
