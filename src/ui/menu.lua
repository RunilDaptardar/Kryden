menu = {}

-- "main": Play / Controls / Quit
-- "controls": list of controls with a Back option
menu.screen = "main"
menu.selected = 1
menu.alpha = 0
menu.leaving = false

menu.controls = {
    { "Move", "WASD / Arrow Keys" },
    { "Sword", "Left Click / J" },
    { "Roll", "Space" },
    { "Pause", "Esc / Return" },
    { "Inventory", "Tab / I" },
}
if love.system.getOS() ~= "Web" then
    table.insert(menu.controls, { "Fullscreen", "BackSpace" })
end

function menu:open(resetMusic)
    menu.screen = "main"
    menu.selected = 1
    menu.leaving = false
    menu.alpha = 0
    love.graphics.setBackgroundColor(26/255, 26/255, 26/255)
    if resetMusic then
        menuMusic:start(false)
    else
        menuMusic:start(false)
    end
    flux.to(menu, 0.4, {alpha = 1}):ease("quadout")
end

function menu:getOptions()
    if menu.screen == "controls" then
        return {
            { label = "Back", action = function() menu.screen = "main" menu.selected = 2 end },
        }
    end

    local options = {
        { label = "Play", action = function() menu:play() end },
        { label = "Controls", action = function() menu.screen = "controls" menu.selected = 1 end },
    }
    if love.system.getOS() ~= "Web" then
        table.insert(options, { label = "Quit", action = function() love.event.quit() end })
    end
    return options
end

function menu:play()
    menu.leaving = true
    flux.to(menu, 0.5, {alpha = 0}):ease("quadin"):oncomplete(function() intro:start() end)
end

function menu:select(index)
    local option = menu:getOptions()[index]
    if option == nil then return end
    dj.play(sounds.ui.select, "static", "effect")
    option.action()
end

function menu:keypressed(key)
    if menu.leaving then return end

    local count = #menu:getOptions()
    if key == 'escape' then
        if menu.screen == "controls" then
            menu:select(1)
        elseif love.system.getOS() ~= "Web" then
            love.event.quit()
        end
    elseif key == 'w' or key == 'up' then
        menu.selected = (menu.selected - 2) % count + 1
        dj.play(sounds.ui.click, "static", "effect")
    elseif key == 's' or key == 'down' then
        menu.selected = menu.selected % count + 1
        dj.play(sounds.ui.click, "static", "effect")
    elseif key == 'return' or key == 'space' or key == 'e' then
        menu:select(menu.selected)
    end
end

function menu:mousepressed(button)
    if menu.leaving or button ~= 1 then return end
    local hovered = menu:getHoverIndex()
    if hovered then menu:select(hovered) end
end

function menu:getLineHeight()
    return 16 * scale
end

-- Screen-space top of the option at this index
function menu:getOptionY(index)
    local top = love.graphics.getHeight()/2 + 10 * scale
    if menu.screen == "controls" then
        top = love.graphics.getHeight()/2 + (#menu.controls * 12 - 12) * scale
    end
    return top + (index - 1) * menu:getLineHeight()
end

function menu:getHoverIndex()
    local mx, my = love.mouse.getPosition()
    local width = 90 * scale
    local left = love.graphics.getWidth()/2 - width/2
    for i,_ in ipairs(menu:getOptions()) do
        local oy = menu:getOptionY(i)
        if mx >= left and mx <= left + width and my >= oy and my < oy + menu:getLineHeight() then
            return i
        end
    end
end

function menu:update(dt)
    if gamestate ~= 0 or menu.leaving then return end

    local hovered = menu:getHoverIndex()
    if hovered and hovered ~= menu.selected then
        menu.selected = hovered
        dj.play(sounds.ui.click, "static", "effect")
    end
end

function menu:draw()
    if gamestate ~= 0 then return end

    local w = love.graphics.getWidth()
    local cy = love.graphics.getHeight()/2

    love.graphics.setColor(1, 1, 1, menu.alpha)
    love.graphics.setFont(fonts.title)
    love.graphics.printf("Kryden", w/2 - 4000, cy - 50 * scale, 8000, "center")

    if menu.screen == "controls" then
        love.graphics.setFont(fonts.pause2)
        for i,c in ipairs(menu.controls) do
            local y = cy - 20 * scale + (i - 1) * 12 * scale
            love.graphics.setColor(1, 1, 1, 0.6 * menu.alpha)
            love.graphics.printf(c[1], w/2 - 4000 - 6 * scale, y, 4000, "right")
            love.graphics.setColor(1, 1, 1, menu.alpha)
            love.graphics.printf(c[2], w/2 + 6 * scale, y, 4000, "left")
        end
    else
        love.graphics.setColor(1, 1, 1, 0.6 * menu.alpha)
        love.graphics.setFont(fonts.pause2)
        love.graphics.printf("v0", w/2 - 4000, cy - 26 * scale, 8000, "center")
    end

    love.graphics.setFont(fonts.pause1)
    for i,o in ipairs(menu:getOptions()) do
        local label = o.label
        if i == menu.selected then
            love.graphics.setColor(1, 1, 1, menu.alpha)
            label = "> " .. label .. " <"
        else
            love.graphics.setColor(1, 1, 1, 0.55 * menu.alpha)
        end
        love.graphics.printf(label, w/2 - 4000, menu:getOptionY(i), 8000, "center")
    end
end
