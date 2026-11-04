local function caedrosInit(enemy, x, y, args)
    enemy.physics = world:newCircleCollider(x, y, 25)
    enemy.physics:setCollisionClass('Boss')
    enemy.physics:setFixedRotation(true)
    enemy.physics:setMass(4)
    enemy.physics:setLinearDamping(8)
    enemy.physics.parent = enemy

    enemy.sprite = sprites.bosses.caedros
    enemy.drawScale = 0.75
    enemy.grid = anim8.newGrid(128, 128, enemy.sprite:getWidth(), enemy.sprite:getHeight())
    enemy.animations = {}
    enemy.animations.idle = anim8.newAnimation(enemy.grid('1-6', 1), 0.18)
    enemy.animations.alert = anim8.newAnimation(enemy.grid('1-6', 2), 0.25)
    enemy.animations.walkDown = anim8.newAnimation(enemy.grid('1-6', 3), 0.12)
    enemy.animations.walkUp = anim8.newAnimation(enemy.grid('1-6', 4), 0.12)
    enemy.animations.halfSwing = anim8.newAnimation(enemy.grid('1-6', 5), 0.09)
    enemy.animations.fullSwing = anim8.newAnimation(
        enemy.grid('1-6', 6),
        0.05,
        function(animation)
            animation:pauseAtEnd()
        end
    )
    enemy.anim = enemy.animations.idle

    enemy.health = 100
    enemy.maxHealth = 100
    enemy.magnitude = 30.4
    enemy.maxSpeed = 30.4
    enemy.viewDistance = 60
    enemy.loseDistance = 220
    enemy.scaleX = 1
    enemy.caedrosPhase = "idle"
    enemy.caedrosAlertTimer = 0
    enemy.caedrosAttackTimer = 0
    enemy.caedrosAttackHit = false
    enemy.caedrosAttackDir = vector(1, 0)
    enemy.caedrosSliceSpawned = false
    enemy.caedrosAttackCooldown = 5
    enemy.caedrosNextAttack = "halfSwing"

    function enemy:hit(damage, dir, stun, dizziness)
        self.health = self.health - damage
        self.stunTimer = 0
        self.dizzyTimer = 0
        self.flashTimer = damage > 0 and 0.175 or 0
        shake:start(0.08, 0.75, 0.015)
        self.physics:applyLinearImpulse(
            (dir:normalized() * (self.health <= 0 and 180 or 45)):unpack()
        )

        if damage > 0 then
            for i = 1, 10 do
                effects:spawn("damage", self.physics:getX(), self.physics:getY(), {dir = dir})
            end
        end

        globalStun = 0
        dj.play(sounds.enemies.hurt, "static", "effect", 1, 1 + math.random()/4)
    end

    function enemy:wanderUpdate(dt)
    end

    function enemy:genericUpdate(dt)
        if self.flashTimer > 0 then
            self.flashTimer = self.flashTimer - dt
            if self.flashTimer < 0 then
                self.flashTimer = 0
            end
        end
    end

    local function setCaedrosAnimation(self, animation)
        if self.anim ~= animation then
            self.anim = animation
            self.anim:gotoFrame(1)
            self.anim:resume()
        end
    end

    function enemy:update(dt)
        if self.dead then return end
        self.stunTimer = 0
        self.dizzyTimer = 0
        if self.health <= 0 then
            self.dead = true
            local ex, ey = self.physics:getPosition()
            particleEvent("death", ex, ey)
            dj.play(sounds.enemies.die, "static", "effect")
            return
        end

        local ex, ey = self.physics:getPosition()
        local px, py = player:getPosition()
        local distance = distanceBetween(ex, ey, px, py)

        if self.caedrosPhase == "idle" then
            self.physics:setLinearVelocity(0, 0)
            self.physics:setPosition(self.startX, self.startY)
            setCaedrosAnimation(self, self.animations.idle)
            if distance <= self.viewDistance then
                self.caedrosPhase = "alert"
                self.caedrosAlertTimer = 1.5
                self.state = 99
                setCaedrosAnimation(self, self.animations.alert)
            end
        elseif self.caedrosPhase == "alert" then
            self.physics:setLinearVelocity(0, 0)
            setCaedrosAnimation(self, self.animations.alert)
            self.caedrosAlertTimer = self.caedrosAlertTimer - dt
            if self.caedrosAlertTimer <= 0 then
                self.caedrosPhase = "chase"
                self.state = 100
            end
        elseif distance > self.loseDistance then
            self.caedrosPhase = "idle"
            self.state = 1
            self.physics:setLinearVelocity(0, 0)
        elseif self.caedrosPhase == "chase" then
            self.caedrosAttackCooldown = self.caedrosAttackCooldown - dt

            if self.caedrosAttackCooldown <= 0 then
                self.caedrosAttackCooldown = 5
                self.caedrosAttackDir = getFromToVector(ex, ey, px, py):normalized()
                self.caedrosAttackTimer = 0.54
                self.caedrosAttackHit = false
                self.caedrosSliceSpawned = false
                self.physics:setLinearVelocity(0, 0)

                if self.caedrosNextAttack == "halfSwing" then
                    self.caedrosPhase = "halfSwing"
                    self.caedrosNextAttack = "fullSwing"
                    setCaedrosAnimation(self, self.animations.halfSwing)
                else
                    self.caedrosPhase = "fullSwing"
                    self.caedrosNextAttack = "halfSwing"
                    setCaedrosAnimation(self, self.animations.fullSwing)
                end
            else
                local direction = getFromToVector(ex, ey, px, py):normalized()
                self.physics:setLinearVelocity(direction.x * self.maxSpeed, direction.y * self.maxSpeed)

                if math.abs(py - ey) > math.abs(px - ex) and py < ey then
                    setCaedrosAnimation(self, self.animations.walkUp)
                else
                    setCaedrosAnimation(self, self.animations.walkDown)
                end

                if px < ex then self.scaleX = -1 else self.scaleX = 1 end
            end
        elseif self.caedrosPhase == "halfSwing" then
            self.physics:setLinearVelocity(0, 0)
            setCaedrosAnimation(self, self.animations.halfSwing)
            self.caedrosAttackTimer = self.caedrosAttackTimer - dt

            if not self.caedrosSliceSpawned then
                effects:spawn("caedrosSlice180", ex, ey, {
                    dir = self.caedrosAttackDir,
                    scale = self.drawScale,
                    layer = 0
                })
                self.caedrosSliceSpawned = true
            end

            if not self.caedrosAttackHit and self.caedrosAttackTimer < 0.35
                and distanceBetween(ex, ey, player:getX(), player:getY()) <= 52 then
                player:hurt(20, ex, ey)
                self.caedrosAttackHit = true
            end

            if self.caedrosAttackTimer <= 0 then
                self.caedrosPhase = "chase"
                self.state = 100
                self.caedrosAttackCooldown = 5
            end
        elseif self.caedrosPhase == "fullSwing" then
            self.physics:setLinearVelocity(0, 0)
            setCaedrosAnimation(self, self.animations.fullSwing)
            self.caedrosAttackTimer = self.caedrosAttackTimer - dt

            if not self.caedrosSliceSpawned then
                effects:spawn("caedrosSlice360", ex, ey, {
                    dir = self.caedrosAttackDir,
                    scale = self.drawScale,
                    layer = 0
                })
                self.caedrosSliceSpawned = true
            end

            if not self.caedrosAttackHit and self.caedrosAttackTimer < 0.35
                and distanceBetween(ex, ey, player:getX(), player:getY()) <= 56 then
                player:hurt(30, ex, ey)
                self.caedrosAttackHit = true
            end

            if self.caedrosAttackTimer <= 0 then
                self.caedrosPhase = "chase"
                self.state = 100
                self.caedrosAttackCooldown = 5
            end
        end

        if px < ex then self.scaleX = -1 else self.scaleX = 1 end
        self.anim:update(dt)
    end

    function enemy:draw()
        setWhite()
        local ex, ey = self.physics:getPosition()
        love.graphics.draw(
            sprites.enemies.shadowMed,
            ex,
            ey + 18,
            nil,
            1.35,
            1.35,
            sprites.enemies.shadowMed:getWidth() / 2,
            sprites.enemies.shadowMed:getHeight() / 2
        )

        if (self.caedrosPhase == "halfSwing" or self.caedrosPhase == "fullSwing")
            and self.anim.position >= 5 then
            local sword = sprites.bosses.caedrosGreatsword
            local swordDir = self.caedrosAttackDir
            local swordRot = math.atan2(swordDir.y, swordDir.x)
            local swordDistance = 42 * self.drawScale
            love.graphics.draw(
                sword,
                ex + swordDir.x * swordDistance,
                ey + swordDir.y * swordDistance - 2,
                swordRot,
                self.drawScale,
                self.drawScale,
                sword:getWidth() / 2,
                sword:getHeight() / 2
            )
        end

        if self.flashTimer > 0 then
            love.graphics.setColor(223/255, 106/255, 106/255, 1)
        end
        self.anim:draw(
            self.sprite,
            ex,
            ey,
            nil,
            self.scaleX * self.drawScale,
            self.drawScale,
            64,
            64
        )
        setWhite()
        if self.caedrosPhase == "alert" then
            love.graphics.draw(
                sprites.enemies.alert,
                ex,
                ey - 25,
                0,
                1,
                1,
                sprites.enemies.alert:getWidth() / 2,
                sprites.enemies.alert:getHeight() / 2
            )
        end
    end

    return enemy
end

return caedrosInit
