pause = {}

pause.active = false
pause.closing = false
pause.alpha = 0
pause.options = {}
pause.selected = 1

function pause:init()
    pause.active = false
    pause.closing = false
    pause.scale = scale
    pause.alpha = 0

    pause.trueY = 0 * pause.scale
    pause.fadeY = 40 * pause.scale
    pause.y = pause.fadeY

    if windowWidth < windowHeight then
        -- assumes main scale of 8
        pause.scale = scale * 0.8
    end

    pause.lineHeight = 16 * pause.scale
    pause.optionWidth = 90 * pause.scale

    pause.options = {
        { label = "Resume", action = function() pause:close() end },
        { label = "Quit to Title", action = function() pause:quitToTitle() end },
    }
    if love.system.getOS() ~= "Web" then
        table.insert(pause.options, { label = "Quit Game", action = function() love.event.quit() end })
    end

    pause.selected = 1
end

function pause:open()
    pause:init()
    dj.play(sounds.ui.menuOpen, "static", "effect")
    self.active = true
    flux.to(pause, 0.25, {alpha = 1}):ease("quadout")
    flux.to(pause, 0.25, {y = pause.trueY}):ease("quadout")

    player.walking = false
    local pvx, pvy = player:getLinearVelocity()
    if math.abs(pvx) > 0.1 or math.abs(pvy) > 0.1 then
        player:justStop()
    else
        player:justIdle()
    end
end

function pause:close()
    pause.closing = true
    dj.play(sounds.ui.menuClose, "static", "effect")
    flux.to(pause, 0.25, {alpha = 0}):ease("quadout"):oncomplete(function()
        pause.active = false
        pause.closing = false
    end)
    flux.to(pause, 0.25, {y = pause.fadeY}):ease("quadout")
end

function pause:toggle()
    if self.active then
        if pause.alpha == 1 then
            pause:close()
        end
    else
        if pause.alpha <= 0 then
            pause:open()
        end
    end
end

function pause:quitToTitle()
    pause:init()
    gamestate = 0
    player.state = -1
    player:setLinearVelocity(0, 0)
    createNewSave()
    player.health = data.maxHealth
    love.graphics.setBackgroundColor(26/255, 26/255, 26/255)
    loadMap("menu")
    menu:open()
end

function pause:select(index)
    if pause.options[index] == nil then return end
    dj.play(sounds.ui.select, "static", "effect")
    pause.options[index].action()
end

function pause:keypressed(key)
    if pause.closing or pause.alpha < 1 then return end

    if key == 'escape' then
        pause:close()
    elseif key == 'w' or key == 'up' then
        pause.selected = (pause.selected - 2) % #pause.options + 1
        dj.play(sounds.ui.click, "static", "effect")
    elseif key == 's' or key == 'down' then
        pause.selected = pause.selected % #pause.options + 1
        dj.play(sounds.ui.click, "static", "effect")
    elseif key == 'return' or key == 'space' or key == 'e' then
        pause:select(pause.selected)
    end
end

function pause:click()
    if pause.closing or pause.alpha < 1 then return end
    local hovered = pause:getHoverIndex()
    if hovered then pause:select(hovered) end
end

-- Screen-space top of the option at this index
function pause:getOptionY(index)
    local cy = love.graphics.getHeight()/2
    return pause.y + cy + (index - 1) * pause.lineHeight - pause.lineHeight
end

function pause:getHoverIndex()
    local mx, my = love.mouse.getPosition()
    local left = love.graphics.getWidth()/2 - pause.optionWidth/2
    for i,_ in ipairs(pause.options) do
        local oy = pause:getOptionY(i)
        if mx >= left and mx <= left + pause.optionWidth and my >= oy and my < oy + pause.lineHeight then
            return i
        end
    end
end

function pause:update(dt)
    if pause.active == false or pause.closing then return end

    local hovered = pause:getHoverIndex()
    if hovered and hovered ~= pause.selected then
        pause.selected = hovered
        dj.play(sounds.ui.click, "static", "effect")
    end
end

function pause:draw()
    if self.active then
        love.graphics.setColor(0,0,0,0.7 * pause.alpha)
        love.graphics.rectangle("fill", -10, -10, love.graphics.getWidth() + 20, love.graphics.getHeight() + 20)

        local cy = love.graphics.getHeight()/2

        love.graphics.setColor(1,1,1,pause.alpha)
        love.graphics.setFont(fonts.pause1)
        love.graphics.printf("Paused", love.graphics.getWidth()/2 - 4000, self.y + (cy - 40 * pause.scale), 8000, "center")

        for i,o in ipairs(pause.options) do
            local label = o.label
            if i == pause.selected then
                love.graphics.setColor(1,1,1,pause.alpha)
                label = "> " .. label .. " <"
            else
                love.graphics.setColor(1,1,1,0.55 * pause.alpha)
            end
            love.graphics.printf(label, love.graphics.getWidth()/2 - 4000, pause:getOptionY(i), 8000, "center")
        end

        love.graphics.setColor(1,1,1,0.7 * pause.alpha)
        love.graphics.setFont(fonts.pause2)
        love.graphics.printf("Left Click / J: Sword     Space: Roll", love.graphics.getWidth()/2 - 4000, self.y + (cy + 50 * pause.scale), 8000, "center")
    end
end
