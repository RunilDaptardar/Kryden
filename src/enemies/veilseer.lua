local function veilseerInit(enemy, x, y, args)
    enemy.physics = world:newBSGRectangleCollider(x, y, 12, 16, 3)
    enemy.physics:setCollisionClass('Enemy')
    enemy.physics:setFixedRotation(true)
    enemy.physics:setMass(1)
    enemy.physics:setLinearDamping(2)
    enemy.physics.parent = enemy

    enemy.form = 1
    enemy.sprite = sprites.enemies.veilseer
    if args and args.form ~= nil then
        enemy.form = args.form
    end

    enemy.health = 10
    enemy.contactDamage = 10
    enemy.speed = 0
    enemy.maxSpeed = 16
    enemy.magnitude = 240
    enemy.dir = vector(0, 1)
    enemy.viewDistance = 80
    enemy.loseDistance = 200
    enemy.chase = false

    if enemy.form == 2 then
        enemy.health = 10
        enemy.magnitude = 360
    elseif enemy.form == 3 then
        enemy.health = 10
        enemy.magnitude = 400
    end

    enemy.grid = anim8.newGrid(40, 40, enemy.sprite:getWidth(), enemy.sprite:getHeight())
    enemy.anim = anim8.newAnimation(enemy.grid('1-4', 1), 0.3)

    enemy.floatTime = 0.7
    enemy.floatY = 0
    enemy.floatMax = 1.5

    enemy.veilseerPhase = "idle"
    enemy.veilseerCycleTimer = 0
    enemy.veilseerDashCycleTimer = 0
    enemy.veilseerDashTimer = 0
    enemy.veilseerReturnTimer = 0
    enemy.veilseerAlertTimer = 0
    enemy.veilseerDashTraveled = 0
    enemy.veilseerHomeX = x
    enemy.veilseerHomeY = y
    enemy.veilseerDashOriginX = x
    enemy.veilseerDashOriginY = y
    enemy.veilseerDashDirection = vector(0, 1)

    local dashSpeed = 160
    local dashTime = 0.33
    local returnTime = 0.8
    local cycleTime = 5.0

    enemy:floatUp(enemy.floatMax, true)

    function enemy:update(dt)
        enemy:moveLogic(dt)
        self:setScaleX()

        if self.dead or self.stunTimer > 0 or self.dizzyTimer > 0 then
            self.physics:setLinearVelocity(0, 0)
            return
        end

        local ex, ey = self.physics:getPosition()
        local px, py = player:getPosition()
        local playerDistance = distanceBetween(ex, ey, px, py)

        if self.veilseerPhase == "idle" then
            self.physics:setLinearVelocity(0, 0)
            if playerDistance <= self.viewDistance then
                self.veilseerCycleTimer = 0
                self.veilseerDashCycleTimer = 0
                self.state = 99
                self.veilseerPhase = "alerted"
                self.veilseerAlertTimer = 0.5
            end
            return
        end

        if self.veilseerPhase == "alerted" then
            self.physics:setLinearVelocity(0, 0)
            self.state = 99
            self.veilseerAlertTimer = self.veilseerAlertTimer - dt
            if playerDistance > self.loseDistance then
                self.veilseerPhase = "idle"
                self.veilseerAlertTimer = 0
                self.state = 1
                return
            end
            if self.veilseerAlertTimer <= 0 then
                self.veilseerPhase = "approach"
                self.veilseerCycleTimer = 0
                self.veilseerDashCycleTimer = 0
                self.state = 100
            end
            return
        end

        if playerDistance > self.loseDistance
            and (self.veilseerPhase == "approach" or self.veilseerPhase == "dash"
                or self.veilseerPhase == "return" or self.veilseerPhase == "cooldown") then
            self.veilseerPhase = "idle"
            self.veilseerCycleTimer = 0
            self.state = 1
            self.physics:setLinearVelocity(0, 0)
            return
        end

        self.veilseerCycleTimer = self.veilseerCycleTimer + dt
        self.veilseerDashCycleTimer = self.veilseerDashCycleTimer + dt

        if self.veilseerPhase == "approach" then
            local toPlayer = getFromToVector(ex, ey, px, py)
            if toPlayer:len() > 0 then
                toPlayer:normalizeInplace()
                self.physics:setLinearVelocity(toPlayer.x * self.maxSpeed, toPlayer.y * self.maxSpeed)
            end

            if self.veilseerDashCycleTimer >= cycleTime then
                self.veilseerDashOriginX = ex
                self.veilseerDashOriginY = ey
                self.veilseerDashDirection = getFromToVector(ex, ey, px, py):normalized()
                self.veilseerDashTimer = dashTime
                self.veilseerDashTraveled = 0
                self.veilseerPhase = "dash"
                self.veilseerDashCycleTimer = 0
                self.veilseerCycleTimer = 0
            end

        elseif self.veilseerPhase == "dash" then
            self.physics:setLinearVelocity(
                self.veilseerDashDirection.x * dashSpeed,
                self.veilseerDashDirection.y * dashSpeed
            )
            self.veilseerDashTimer = self.veilseerDashTimer - dt

            if distanceBetween(ex, ey, px, py) < 12 then
                player:hurt(self.contactDamage or 10, ex, ey)
                self.veilseerPhase = "return"
                self.veilseerReturnTimer = returnTime
                self.physics:setLinearVelocity(0, 0)
            elseif self.veilseerDashTimer <= 0 then
                self.veilseerPhase = "return"
                self.veilseerReturnTimer = returnTime
            end

        elseif self.veilseerPhase == "return" then
            local toOrigin = getFromToVector(ex, ey, self.veilseerDashOriginX, self.veilseerDashOriginY)
            self.veilseerReturnTimer = self.veilseerReturnTimer - dt

            if toOrigin:len() < 8 or self.veilseerReturnTimer <= 0 then
                self.physics:setPosition(self.veilseerDashOriginX, self.veilseerDashOriginY)
                self.physics:setLinearVelocity(0, 0)
                self.veilseerPhase = "cooldown"
                self.veilseerCycleTimer = 0
                self.veilseerDashCycleTimer = 0
            else
                toOrigin:normalizeInplace()
                self.physics:setLinearVelocity(toOrigin.x * self.maxSpeed * 2, toOrigin.y * self.maxSpeed * 2)
            end

        elseif self.veilseerPhase == "cooldown" then
            local toPlayer = getFromToVector(ex, ey, px, py)
            if toPlayer:len() > 0 then
                toPlayer:normalizeInplace()
                self.physics:setLinearVelocity(toPlayer.x * self.maxSpeed, toPlayer.y * self.maxSpeed)
            end
        end

        if self.veilseerPhase == "cooldown" and self.veilseerDashCycleTimer >= cycleTime then
            self.veilseerCycleTimer = 0
            self.veilseerDashOriginX = ex
            self.veilseerDashOriginY = ey
            self.veilseerDashDirection = getFromToVector(ex, ey, px, py):normalized()
            self.veilseerDashTimer = dashTime
            self.veilseerDashTraveled = 0
            self.veilseerPhase = "dash"
            self.veilseerDashCycleTimer = 0
        end
    end

    function enemy:draw()
        setWhite()
        local ex, ey = self.physics:getPosition()
        love.graphics.draw(sprites.enemies.eyeShadow, ex, ey+10, nil, nil, nil, sprites.enemies.eyeShadow:getWidth()/2, sprites.enemies.eyeShadow:getHeight()/2)
        if self.flashTimer > 0 then
            love.graphics.setColor(223/255,106/255,106/255,1)
        end
        if self.dizzyTimer == 0 then
            self.anim:draw(self.sprite, ex, ey-self.floatY, nil, 0.5, 0.5, 20, 20)
        else
            love.graphics.draw(sprites.enemies.veilseerDead, ex, ey+3, nil, 0.5, 0.5, 20, 20)
        end
        setWhite()
        if self.state == 99 then
            love.graphics.draw(sprites.enemies.alert, ex, ey-14.5, nil, nil, nil, sprites.enemies.alert:getWidth()/2, sprites.enemies.alert:getHeight()/2)
        end
    end

    function enemy:die()
        local ex, ey = self.physics:getPosition()
        local args = {}
        args.form = self.form
        effects:spawn("veilseerDeath", ex, ey+3, args)
    end

    return enemy

end

return veilseerInit