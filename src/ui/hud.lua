function drawHUD()
    drawHealth()
    drawBossHealthBar()
    drawMoney()
    drawWeaponSlot()
end

function drawBossHealthBar()
    local caedros = nil

    for _, enemy in ipairs(enemies) do
        if enemy.type == "caedros" and not enemy.dead then
            if enemy.caedrosPhase == "alert"
                or enemy.caedrosPhase == "chase"
                or enemy.caedrosPhase == "halfSwing"
                or enemy.caedrosPhase == "fullSwing" then
                caedros = enemy
                break
            end
        end
    end

    if caedros == nil then return end

    local width = 180 * scale
    local height = 2 * scale
    local x = (love.graphics.getWidth() - width) / 2
    local y = 7 * scale
    local healthPercent = math.max(0, math.min(1,
        caedros.health / (caedros.maxHealth or caedros.health)
    ))

    love.graphics.setColor(0.025, 0.02, 0.04, 0.95)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0.48, 0.18, 0.78, 1)
    love.graphics.rectangle("fill", x, y, width * healthPercent, height)
    love.graphics.setColor(0.78, 0.58, 0.95, 0.9)
    love.graphics.rectangle("line", x, y, width, height)

    local name = "CAEDROS"
    love.graphics.setFont(fonts.ammo)
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.print(name, x + (width - love.graphics.getFont():getWidth(name)) / 2,
        y - 7 * scale)
    setWhite()
end

function drawHealth()
    local x = 6 * scale
    local y = 6 * scale
    local width = 24 * scale
    local height = 2 * scale
    local healthPercent = math.max(0, math.min(100, player.health / data.maxHealth * 100))

    love.graphics.setColor(0.08, 0.08, 0.08, 0.85)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", x, y, width * healthPercent / 100, height)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", x, y, width, height)
end

function drawWeaponSlot()
    local width = 48 * scale
    local height = 18 * scale
    local x = 6 * scale
    local y = love.graphics.getHeight() - height - 6 * scale

    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.setFont(fonts.ammo)
    love.graphics.setFont(fonts.ammo)
    local weaponName = "broken blade"
    love.graphics.print(
        weaponName,
        x + (width - love.graphics.getFont():getWidth(weaponName)) / 2,
        y - 7 * scale
    )

    local sword = sprites.items.sword
    local swordScale = math.min(width / sword:getWidth(), height / sword:getHeight()) * 0.8
    love.graphics.draw(
        sword,
        x + width / 2,
        y + height / 2,
        nil,
        swordScale,
        swordScale,
        sword:getWidth() / 2,
        sword:getHeight() / 2
    )
end

function drawMoney()
    local mx = love.graphics.getWidth() - 23*scale
    local my = love.graphics.getHeight() - 10*scale
    local tx = love.graphics.getWidth() - 12*scale
    local ty = love.graphics.getHeight() - 11*scale
    setWhite()
    love.graphics.draw(sprites.hud.coin, mx, my, nil, 1.5*scale)
    love.graphics.setFont(fonts.coins)
    love.graphics.print(data.money, tx, ty)
end
