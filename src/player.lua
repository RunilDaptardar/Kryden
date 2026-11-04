player = world:newBSGRectangleCollider(234, 184, 12, 12, 3)
player.x = 0
player.y = 0
player.dir = "up"
player.dirX = 1
player.dirY = -1
player.prevDirX = 1
player.prevDirY = 1
player.scaleX = 1
player.speed = 48
player.animSpeed = 0.14
player.walking = false
player.animTimer = 0
player.health = 100
player.contactDamage = 12.5
player.stunTimer = 0
player.damagedTimer = 0
player.damagedBool = 1
player.damagedFlashTime = 0.05
player.invincible = 0 -- timer
player.holdSprite = sprites.items.heart
player.attackDir = vector(1, 0)
player.comboCount = 0
player.baseDamping = 12
player.dustTimer = 0
player.rollDelayTimer = 0
player.rotateMargin = 0.25

-- 0 = Normal gameplay
-- 0.5 = Rolling
-- 1 = Sword swing
-- 10 = Damage stun
-- 11 = Hold item
-- 12 = Transition
player.state = -1

player:setCollisionClass("Player")
player:setFixedRotation(true)
player:setLinearDamping(player.baseDamping)

player.grid = anim8.newGrid(38, 42, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

player.animations = {}
player.animations.downRight = anim8.newAnimation(player.grid('1-6', 1), player.animSpeed)
player.animations.downLeft = anim8.newAnimation(player.grid('1-6', 1), player.animSpeed)
player.animations.upRight = anim8.newAnimation(player.grid('1-6', 2), player.animSpeed)
player.animations.upLeft = anim8.newAnimation(player.grid('1-6', 2), player.animSpeed)
player.animations.swordDownRight = anim8.newAnimation(player.grid('1-6', 1), player.animSpeed)
player.animations.swordDownLeft = anim8.newAnimation(player.grid('1-6', 1), player.animSpeed)
player.animations.swordUpRight = anim8.newAnimation(player.grid('1-6', 2), player.animSpeed)
player.animations.swordUpLeft = anim8.newAnimation(player.grid('1-6', 2), player.animSpeed)
player.animations.useDownRight = anim8.newAnimation(player.grid('1-6', 1), player.animSpeed)
player.animations.useDownLeft = anim8.newAnimation(player.grid('1-6', 1), player.animSpeed)
player.animations.useUpRight = anim8.newAnimation(player.grid('1-6', 2), player.animSpeed)
player.animations.useUpLeft = anim8.newAnimation(player.grid('1-6', 2), player.animSpeed)
player.animations.hold = anim8.newAnimation(player.grid('1-6', 1), player.animSpeed)
player.animations.rollDown = anim8.newAnimation(player.grid('1-6', 4), 0.11)
player.animations.rollUp = anim8.newAnimation(player.grid('1-6', 5), 0.11)
player.animations.stopDown = anim8.newAnimation(player.grid('1-6', 6), 0.22, function() player.anim = player.animations.idleDown end)
player.animations.stopUp = anim8.newAnimation(player.grid('1-6', 7), 0.22, function() player.anim = player.animations.idleUp end)
player.animations.idleDown = anim8.newAnimation(player.grid('1-6', 8), {1.2, 0.1, 1.0, 0.1, 0.8, 0.1})
player.animations.idleUp = anim8.newAnimation(player.grid('1-6', 9), 0.22)

player.anim = player.animations.idleUp

player.buffer = {} -- input buffer

function player:update(dt)

    if pause.active then player.anim:update(dt) end
    if player.state == -1 or gamestate == 0 or inventory.active then return end

    if player.stunTimer > 0 then
        player.stunTimer = player.stunTimer - dt
    end
    if player.stunTimer < 0 then
        player.stunTimer = 0
        if player.state == 10 then
            player.state = 0
            player:setLinearVelocity(0, 0)
        end
    end
    
    if player.damagedTimer > 0 then
        player.damagedTimer = player.damagedTimer - dt
        player.damagedFlashTime = player.damagedFlashTime - dt
        if player.damagedFlashTime < 0 then
            player.damagedFlashTime = 0.05
            player.damagedBool = player.damagedBool * -1
        end
    end
    if player.damagedTimer < 0 then
        player.damagedTimer = 0
        --world:collisionClear()
        world:collisionEventsClear()
    end

    if player.rollDelayTimer > 0 then
        player.rollDelayTimer = player.rollDelayTimer - dt
    end

    if player.state == 0 then

        player:setLinearDamping(player.baseDamping)

        player.prevDirX = player.dirX
        player.prevDirY = player.dirY
    
        local dirX = 0
        local dirY = 0

        if pause.active then return end

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            dirX = 1
            player.dirX = 1
        end

        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            dirX = -1
            player.dirX = -1
        end

        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            dirY = 1
            player.dirY = 1
        end

        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            dirY = -1
            player.dirY = -1
        end

        if dirY == 0 and dirX ~= 0 then
            player.dirY = 1
        end

        if player.walking then
            if player.dirX == 1 then
                if player.dirY == 1 then
                    player.anim = player.animations.downRight
                else
                    player.anim = player.animations.upRight
                end
            else
                if player.dirY == 1 then
                    player.anim = player.animations.downLeft
                else
                    player.anim = player.animations.upLeft
                end
            end
        end

        local vec = vector(dirX, dirY):normalized() * player.speed
        if vec.x ~= 0 or vec.y ~= 0 then
            player:setLinearVelocity(vec.x, vec.y)
        end

        if player.walking then
            player.dustTimer = player.dustTimer - dt
            if player.dustTimer < 0 then
                player.dustTimer = 0.22
                effects:spawn("walkDust", player:getX(), player:getY()+6, {dir = vec:normalized()})
            end
        else
            player.dustTimer = 0
        end

        if dirX == 0 and dirY == 0 then
            if player.walking then
                player.walking = false
                player:justStop()
            end
        else
            player.walking = true
        end

        player.anim:update(dt)

        player:checkDamage()
        player:checkTransition()

        if data.keys and data.keys > 0 then
            if player:enter('Wall') then
                local w = player:getEnterCollisionData('Wall')
                if w.collider.type == "lockedDoor" then
                    w.collider.dead = true
                end
            end
        end

    elseif player.state == 0.5 then

        player:checkTransition()
        player.anim:update(dt)

        player.animTimer = player.animTimer - dt
        if player.animTimer < 0 then
            player.state = 0
            player.animTimer = 0
            player.rollDelayTimer = 0.3
        end

    elseif player.state >= 1 and player.state < 2 then

        player.animTimer = player.animTimer - dt
        player:checkDamage()

        if player.state == 1 then
            player:setLinearVelocity((player.attackDir*player.speed):unpack())
        elseif player.state == 1.1 then
            player:setLinearVelocity(0, 0)
        end

        if player.animTimer < 0 then
            if player.state == 1 then
                player.state = 1.1
                player.anim:gotoFrame(2)
                -- animTimer for finished sword swing stance
                player.animTimer = 0.25
                effects:spawn("slice", player:getX(), player:getY()+1, player.attackDir)
                player:swordDamage()
            elseif player.state == 1.1 then
                player.state = 0
                player:resetAnimation(player.dir)
            end
        end

    elseif player.state == 11 then -- got an item

        player.animTimer = player.animTimer - dt

        if player.animTimer < 0 then
            player.state = 0
            player:resetAnimation(player.dir)
        end
    
    elseif player.state == 11.1 then -- got an item (delay)

        player.animTimer = player.animTimer - dt

        if player.animTimer < 0 then
            player:gotItem(player.holdSprite)
        end

    elseif player.state == 12 then -- transition

        player:setLinearVelocity(0, 0)
        player:resetAnimation(player.dir)

    end

    player:processBuffer(dt)

end

function player:draw()

    if player.stunTimer > 0 then
        love.graphics.setColor(223/255,106/255,106/255,1)
    elseif player.damagedTimer > 0 then
        local alpha = 0.8
        if player.damagedBool < 0 then alpha = 0.55 end
        love.graphics.setColor(1,1,1,alpha)
    else
        love.graphics.setColor(1,1,1,1)
    end

    -- Sword sprite
    local swSpr = sprites.items.sword
    local swX = 0
    local swY = 0
    local swLayer = -1

    local swordRot = 0
    if player.state == 1.1 then
        local tempVec = 0
        if player.comboCount % 2 == 0 then
            tempVec = player.attackDir:rotated(math.pi/2)
        else
            tempVec = player.attackDir:rotated(math.pi/-2)
        end
        swordRot = math.atan2(tempVec.y, tempVec.x)
        swX = tempVec.x * 12
        swY = tempVec.y * 12

        if swY > 0 then
            swLayer = 1
        end
    end

    local px = player:getX()
    local py = player:getY()+1

    love.graphics.draw(sprites.playerShadow, px, py+7, nil, nil, nil, sprites.playerShadow:getWidth()/2, sprites.playerShadow:getHeight()/2)

    if player.state == 1.1 and swLayer == -1 then
        love.graphics.draw(swSpr, px+swX, py+swY, swordRot, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    if player.stunTimer > 0 then love.graphics.setShader(shaders.whiteout) end

    player.anim:draw(sprites.playerSheet, player:getX(), player:getY()-2, nil, player.dirX * 0.5, 0.5, 19, 21)

    love.graphics.setShader()

    if player.state == 1.1 and swLayer == 1 then
        love.graphics.draw(swSpr, px+swX, py+swY, swordRot, nil, nil, swSpr:getWidth()/2, swSpr:getHeight()/2)
    end

    if player.state == 11 then
        love.graphics.draw(player.holdSprite, player:getX(), player:getY()-18, nil, nil, nil, player.holdSprite:getWidth()/2, player.holdSprite:getHeight()/2)
    end

end

function player:checkDamage()
    if player.damagedTimer > 0 then return end

    local hitEnemies = world:queryCircleArea(player:getX(), player:getY(), 5, {'Enemy'})
    local hitBosses = world:queryCircleArea(player:getX(), player:getY(), 5, {'Boss'})
    for _, boss in ipairs(hitBosses) do table.insert(hitEnemies, boss) end
    if #hitEnemies > 0 then
        local e = hitEnemies[1]
        if e.parent.dizzyTimer <= 0 and e.parent.stunTimer <= 0 then
            local damage = e.parent.contactDamage or player.contactDamage
            player:hurt(damage, e:getX(), e:getY())
        end
    end

    -- to fix the overlap issue, check distance as well
    for _,e in ipairs(enemies) do
        if e.physics and distanceBetween(e.physics:getX(), e.physics:getY(), player:getX(), player:getY()) < 4 then
            player:hurt(e.contactDamage or player.contactDamage, e.physics:getX(), e.physics:getY())
        end
    end

    if player:enter('Projectile') then
        local e = player:getEnterCollisionData('Projectile')
        e.collider.dead = true
        player:hurt(player.contactDamage, e.collider:getX(), e.collider:getY())
    end
end

function player:checkTransition()
    if player:enter('Transition') then
        local t = player:getEnterCollisionData('Transition')
        if t.collider.type == "instant" then
            triggerTransition(t.collider.id, t.collider.destX, t.collider.destY)
        else
            curtain:call(t.collider.id, t.collider.destX, t.collider.destY, t.collider.type)
        end
        --triggerTransition(t.collider.id, t.collider.destX, t.collider.destY)
    end
end

function player:hurt(damage, srcX, srcY)
    if player.damagedTimer > 0 then return end
    player.damagedTimer = 2
    shake:start(0.1, 2, 0.03)
    particleEvent("playerHit", player:getX(), player:getY())
    dj.play(sounds.player.hurt, "static", "effect")
    player.health = math.max(0, player.health - damage)
    if player.health <= 0 and death then
        death:open()
        return
    end
    player.state = 10 -- damaged
    player:setLinearVelocity((getFromToVector(srcX, srcY, player:getX(), player:getY()) * 300):unpack())
    player.stunTimer = 0.075
end

function player:swingSword()

    -- The player can only swing their sword if the player.state is 0 (regular gameplay)
    if player.state ~= 0 then
        player:addToBuffer("sword")
        return
    end

    player.comboCount = player.comboCount + 1

    player.attackDir = toMouseVector(player:getX(), player:getY())
    player:setDirFromVector(player.attackDir)

    player.state = 1

    if player.dirX == 1 then
        if player.dirY == 1 then
            player.anim = player.animations.swordDownRight
        else
            player.anim = player.animations.swordUpRight
        end
    else
        if player.dirY == 1 then
            player.anim = player.animations.swordDownLeft
        else
            player.anim = player.animations.swordUpLeft
        end
    end

    --player.anim:gotoFrame(1)
    -- animTimer for sword wind-up
    player.animTimer = 0.075

end

function player:swordDamage()
    -- Query for enemies to hit with the sword
    --local hitEnemies = world:queryCircleArea(player:getX(), player:getY(), 24, {'Enemy'})

    local px, py = player:getPosition()
    local dir = player.attackDir:normalized()
    local rightDir = dir:rotated(math.pi/2)
    local leftDir = dir:rotated(math.pi/-2)
    local polygon = {
        px + dir.x*20,
        py + dir.y*20,
        px + dir:rotated(math.pi/8).x*20,
        py + dir:rotated(math.pi/8).y*20,
        px + dir:rotated(math.pi/4).x*20,
        py + dir:rotated(math.pi/4).y*20,
        px + dir:rotated(3*math.pi/8).x*20,
        py + dir:rotated(3*math.pi/8).y*20,
        px + rightDir.x*22,
        py + rightDir.y*22,
        px + rightDir.x*22 + rightDir:rotated(math.pi/2).x*6,
        py + rightDir.y*22 + rightDir:rotated(math.pi/2).y*6,
        px + leftDir.x*22 + leftDir:rotated(math.pi/-2).x*6,
        py + leftDir.y*22 + leftDir:rotated(math.pi/-2).y*6,
        px + leftDir.x*22,
        py + leftDir.y*22,
        px + dir:rotated(3*math.pi/-8).x*20,
        py + dir:rotated(3*math.pi/-8).y*20,
        px + dir:rotated(math.pi/-4).x*20,
        py + dir:rotated(math.pi/-4).y*20,
        px + dir:rotated(math.pi/-8).x*20,
        py + dir:rotated(math.pi/-8).y*20,
    }

    local range = math.random()/4
    dj.play(sounds.items.sword, "static", "effect", 1, 1+range)

    local hitEnemies = world:queryPolygonArea(polygon, {'Enemy'})
    local hitBosses = world:queryPolygonArea(polygon, {'Boss'})
    for _, boss in ipairs(hitBosses) do table.insert(hitEnemies, boss) end
    for _,e in ipairs(hitEnemies) do
        local knockbackDir = getPlayerToSelfVector(e:getX(), e:getY())
        e.parent:hit(1, knockbackDir, 0.1)
    end

    -- Without bombs, the sword breaks rocks and cracked walls (locked doors still need a key)
    local hitWalls = world:queryPolygonArea(polygon, {'Wall'})
    for _,w in ipairs(hitWalls) do
        if w.breakable and w.type ~= "lockedDoor" then
            w.dead = true
        end
    end
end

function player:resetAnimation(direction)
    --player.anim = player.animations[direction]
    if player.dirX == 1 then
        if player.dirY == 1 then
            player.anim = player.animations.idleDown
        else
            player.anim = player.animations.idleUp
        end
    else
        if player.dirY == 1 then
            player.anim = player.animations.idleDown
        else
            player.anim = player.animations.idleUp
        end
    end
    player.anim:gotoFrame(1)
end

function player:gotItem(spr, delay)
    if delay then
        player.state = 11.1
        player.animTimer = 0.5
        player.holdSprite = spr
        return
    end
    player.holdSprite = spr
    player.state = 11
    player.animTimer = 1
    player.dir = "down"
    player.anim = player.animations.hold
    player:setLinearVelocity(0, 0)
end

function player:interact()
    -- query for interactable walls
    local interactables = world:queryCircleArea(player:getX(), player:getY(), 12, {'Wall'})
    for _,i in ipairs(interactables) do
        if i.parent then
            i.parent:interact()
        end
    end
end

function player:roll()
    if player.state ~= 0 or player.rollDelayTimer > 0 then
        player:addToBuffer("roll")
        return
    end

    if pause.active then player:justIdle() return end

    local dirX = 0
    local dirY = 0

    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        dirX = 1
    end

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        dirX = -1
    end

    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        dirY = 1
    end

    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        dirY = -1
    end

    if dirX == 0 and dirY == 0 then return end -- must have some direction to roll

    player.state = 0.5
    player.animTimer = 0.3

    if dirY < 0 then
        player.anim = player.animations.rollUp
    else
        player.anim = player.animations.rollDown
    end
    player.anim:gotoFrame(1)

    player:setLinearDamping(1.75)
    local dirVec = vector(dirX, dirY):normalized()*85.3334
    player:setLinearVelocity(dirVec.x, dirVec.y)

    local range = math.random()/5
    dj.play(sounds.player.roll, "static", "effect", 1, 1+range)
    effects:spawn("walkDust", player:getX(), player:getY()+6, {dir = dirVec, scale = 0.8})
    effects:spawn("walkDust", player:getX(), player:getY()+6, {dir = dirVec:rotated(math.pi/8), scale = 0.6})
    effects:spawn("walkDust", player:getX(), player:getY()+6, {dir = dirVec:rotated(math.pi/-8), scale = 0.6})
    effects:spawn("walkDust", player:getX(), player:getY()+6, {dir = dirVec:rotated(math.pi/4), scale = 0.6})
    effects:spawn("walkDust", player:getX(), player:getY()+6, {dir = dirVec:rotated(math.pi/-4), scale = 0.6})
end

function player:setDirFromVector(vec)
    local rad = math.atan2(vec.y, vec.x)
    if rad >= player.rotateMargin*-1 and rad < math.pi/2 then
        player.dirX = 1
        player.dirY = 1
    elseif (rad >= math.pi/2 and rad < math.pi) or (rad < (math.pi - player.rotateMargin)*-1) then
        player.dirX = -1
        player.dirY = 1
    elseif rad < 0 and rad > math.pi/-2 then
        player.dirX = 1
        player.dirY = -1
    else
        player.dirX = -1
        player.dirY = -1
    end
end

function player:justStop()
    if player.prevDirY < 0 then
        player.anim = player.animations.stopUp
    else
        player.anim = player.animations.stopDown
    end
    player.anim:gotoFrame(1)
end

function player:justIdle()
    if player.prevDirY < 0 then
        player.anim = player.animations.idleUp
    else
        player.anim = player.animations.idleDown
    end
    --player.anim:gotoFrame(1)
end

function player:processBuffer(dt)
    for i=#player.buffer,1,-1 do
        player.buffer[i][2] = player.buffer[i][2] - dt
    end
    for i=#player.buffer,1,-1 do
        if player.buffer[i][2] <= 0 then
            table.remove(player.buffer, i)
        end
    end

    if player.state == 0 then
        player:useBuffer()
    end
end

function player:addToBuffer(action)
    if action == "roll" and player.state == 0.5 then
        table.insert(player.buffer, {action, 0.1})
    else
        table.insert(player.buffer, {action, 0.25})
    end
end

function player:useBuffer()
    local action = nil
    if #player.buffer > 0 then
        action = player.buffer[1][1]
    end

    -- clear buffer
    for k,v in pairs(player.buffer) do player.buffer[k]=nil end

    if action == nil then return end

    if action == "sword" then
        player:swingSword()
    elseif action == "roll" then
        player:roll()
    end
end
