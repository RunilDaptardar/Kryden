inventory = {}

inventory.active = false
inventory.closing = false
inventory.alpha = 0
inventory.selected = 1
inventory.options = {}

function inventory:init()
    inventory.active = false
    inventory.closing = false
    inventory.alpha = 0
    inventory.selected = 1
    inventory.options = {
        { label = "Sword", sprite = sprites.items.sword },
        { label = string.format("Keys: %d", data.keys or 0), sprite = sprites.items.key },
        { label = string.format("Coins: %d", data.money or 0), sprite = sprites.hud.coin },
    }
end

function inventory:open()
    inventory:init()
    inventory.active = true
    dj.play(sounds.ui.menuOpen, "static", "effect")
    flux.to(inventory, 0.2, {alpha = 1}):ease("quadout")
end

function inventory:close()
    inventory.closing = true
    dj.play(sounds.ui.menuClose, "static", "effect")
    flux.to(inventory, 0.2, {alpha = 0}):ease("quadout"):oncomplete(function()
        inventory.active = false
        inventory.closing = false
    end)
end

function inventory:toggle()
    if inventory.active then
        if inventory.alpha == 1 then inventory:close() end
    elseif inventory.alpha == 0 then
        inventory:open()
    end
end

function inventory:keypressed(key)
    if inventory.closing or inventory.alpha < 1 then return end

    if key == "escape" or key == "tab" or key == "i" then
        inventory:close()
    elseif key == "w" or key == "up" then
        inventory.selected = (inventory.selected - 2) % #inventory.options + 1
    elseif key == "s" or key == "down" then
        inventory.selected = inventory.selected % #inventory.options + 1
    end
end

function inventory:update(dt)
end

function inventory:draw()
    if not inventory.active then return end

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    love.graphics.setColor(0, 0, 0, 0.8 * inventory.alpha)
    love.graphics.rectangle("fill", -10, -10, width + 20, height + 20)

    love.graphics.setColor(1, 1, 1, inventory.alpha)
    love.graphics.setFont(fonts.pause1)
    love.graphics.printf("Inventory", 0, height / 2 - 55 * scale, width, "center")

    love.graphics.setFont(fonts.pause2)
    for i, item in ipairs(inventory.options) do
        local y = height / 2 - 20 * scale + (i - 1) * 18 * scale
        local x = width / 2 - 70 * scale

        if i == inventory.selected then
            love.graphics.setColor(1, 1, 1, inventory.alpha)
        else
            love.graphics.setColor(1, 1, 1, 0.55 * inventory.alpha)
        end

        if item.sprite then
            love.graphics.draw(item.sprite, x, y, nil, scale, scale)
        end
        love.graphics.print(item.label, x + 16 * scale, y)
    end

    love.graphics.setColor(1, 1, 1, 0.7 * inventory.alpha)
    love.graphics.printf("Tab / I: Close", 0, height / 2 + 50 * scale, width, "center")
end
