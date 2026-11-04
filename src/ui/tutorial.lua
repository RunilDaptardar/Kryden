tutorialDialog = {}
tutorialDialog.active = false
tutorialDialog.state = "typing"
tutorialDialog.typeSpeed = 40
tutorialDialog.chars = 0
tutorialDialog.triggers = {}

tutorialDialog.dialogs = {
    SpawnDialog1 = {
        text = "\"Where... am I? How long have I been here?\""
    },
    SpawnDialog2 = {
        text = "\"These ruins... someone must have brought me here.\""
    },
    SpawnDialog3 = {
        text = "\"A broken sword... Why does it feel so familiar?\""
    },
    SpawnDialog4 = {
        text = "\"Something's moving beyond these walls. I'm not alone.\""
    },
    SpawnDialog5 = {
        text = "\"Whatever waits ahead... I can't stay here forever.\""
    },
}

function spawnTutorialDialogTrigger(x, y, width, height, id)
    if not tutorialDialog.dialogs[id] then return end
    table.insert(tutorialDialog.triggers, {
        x = x,
        y = y,
        width = width,
        height = height,
        id = id,
        dead = false
    })
end

function removeTutorialDialogTriggers()
    for i = #tutorialDialog.triggers, 1, -1 do
        table.remove(tutorialDialog.triggers, i)
    end
end

function tutorialDialog:start(id)
    local dialog = tutorialDialog.dialogs[id]
    if not dialog then return end

    tutorialDialog.active = true
    tutorialDialog.state = "typing"
    tutorialDialog.chars = 0
    tutorialDialog.current = dialog
    tutorialDialog.clickTimer = 0
    player.state = 12
end

function tutorialDialog:finishTyping()
    tutorialDialog.chars = #tutorialDialog.current.text
    tutorialDialog.state = "waiting"
end

function tutorialDialog:advance()
    if tutorialDialog.state == "typing" then
        tutorialDialog:finishTyping()
    elseif tutorialDialog.state == "waiting" then
        tutorialDialog:close()
    end
end

function tutorialDialog:close()
    tutorialDialog.active = false
    tutorialDialog.current = nil
    player.state = 0
end

function tutorialDialog:keypressed(key)
    if key == "escape" then
        tutorialDialog:close()
    elseif key == "space" or key == "return" or key == "e" or key == "j" then
        tutorialDialog:advance()
    end
end

function tutorialDialog:update(dt)
    if tutorialDialog.active then
        if tutorialDialog.state == "typing" then
            local before = math.floor(tutorialDialog.chars)
            tutorialDialog.chars = tutorialDialog.chars + dt * tutorialDialog.typeSpeed
            if math.floor(tutorialDialog.chars) ~= before then
                tutorialDialog.clickTimer = tutorialDialog.clickTimer - 1
                if tutorialDialog.clickTimer <= 0 then
                    dj.play(sounds.ui.click, "static", "effect", 0.25, 1 + math.random()/5)
                    tutorialDialog.clickTimer = 3
                end
            end
            if tutorialDialog.chars >= #tutorialDialog.current.text then
                tutorialDialog:finishTyping()
            end
        end
        return
    end

    local px = player:getX()
    local py = player:getY()
    for _, trigger in ipairs(tutorialDialog.triggers) do
        if not trigger.dead
        and px >= trigger.x and px <= trigger.x + trigger.width
        and py >= trigger.y and py <= trigger.y + trigger.height then
            trigger.dead = true
            tutorialDialog:start(trigger.id)
            break
        end
    end
end

function tutorialDialog:draw()
    if not tutorialDialog.active or not tutorialDialog.current then return end

    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local panelY = h * 0.5
    love.graphics.setColor(0, 0, 0, 0.82)
    love.graphics.rectangle("fill", 0, panelY, w, h - panelY)

    love.graphics.setColor(1, 1, 1, 0.12)
    love.graphics.rectangle("fill", 0, panelY, w, 2 * scale)

    local width = math.min(w * 0.8, 240 * scale)
    love.graphics.setFont(fonts.pause2)
    love.graphics.setColor(1, 1, 1, 1)
    local shown = string.sub(tutorialDialog.current.text, 1, math.floor(tutorialDialog.chars))
    love.graphics.printf(shown, w/2 - width/2, panelY + (h - panelY) * 0.38, width, "center")

    love.graphics.setFont(fonts.pause2)
    love.graphics.setColor(1, 1, 1, 0.35)
    love.graphics.printf("Space to continue     Esc to skip", w/2 - 4000, h - 16 * scale, 8000, "center")
end
