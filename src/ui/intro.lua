intro = {}

-- Story shown when Play is pressed. Each page types out one entry at a time,
-- then clears before the next page. Styles: "heading", "body", "tagline"
intro.pages = {
    {
        { style = "heading", text = "THE FALLEN KINGDOM" },
        { style = "body", text = "\"There was once a kingdom that knew no darkness.\"" },
        { style = "body", text = "A land of great kings, forgotten legends, and promises meant to endure beyond time." },
        { style = "body", text = "But even the greatest kingdoms are not beyond betrayal." },
    },
    {
        { style = "body", text = "One night, the kingdom fell." },
        { style = "body", text = "Its people vanished. Its history was buried. And a strange mist swallowed everything that remained." },
        { style = "body", text = "They called it the Veil." },
    },
    {
        { style = "body", text = "Years passed. The roads were forgotten. The names of the fallen faded into silence." },
        { style = "body", text = "Yet beyond the mist, something still stirs." },
        { style = "body", text = "And now, one soul returns to a land that should have remained lost." },
    },
    {
        { style = "tagline", text = "\"Some truths were never meant to stay buried.\"" },
    },
}

intro.typeSpeed = 40 -- characters per second
intro.lineHold = 1.2 -- seconds a finished line waits before the next one starts
intro.pageHold = 2.5 -- seconds a finished page stays up before it clears

-- "typing": current entry is being typed out
-- "waiting": current entry is finished, waiting to advance
-- "turning": page text fades before the next page
-- "fading": final page fades before the reveal
-- "revealing": black circle opens up onto the game
intro.active = false
intro.state = "typing"

function intro:start()
    gamestate = 2
    menuMusic:start(false)
    intro.active = true
    intro.pageIndex = 1
    intro.lineIndex = 1
    intro.clickTimer = 0
    intro.textAlpha = 1
    intro.holeRad = 0
    intro:startTyping()
    startFresh(1)
end

function intro:currentPage()
    return intro.pages[intro.pageIndex]
end

function intro:currentEntry()
    return intro:currentPage()[intro.lineIndex]
end

function intro:startTyping()
    intro.chars = 0
    intro.state = "typing"
end

function intro:finishTyping()
    intro.chars = #intro:currentEntry().text
    intro.state = "waiting"
    if intro.lineIndex < #intro:currentPage() then
        intro.waitTimer = intro.lineHold
    else
        intro.waitTimer = intro.pageHold
    end
end

function intro:keypressed(key)
    if key == 'escape' then
        intro:finish()
    elseif key == 'space' or key == 'return' or key == 'e' or key == 'j' then
        intro:advance()
    end
end

-- Finish the current entry, or move to the next one if it's already finished
function intro:advance()
    if intro.state == "typing" then
        intro:finishTyping()
    elseif intro.state == "waiting" then
        intro:nextLine()
    end
end

function intro:nextLine()
    if intro.lineIndex < #intro:currentPage() then
        intro.lineIndex = intro.lineIndex + 1
        intro:startTyping()
    elseif intro.pageIndex < #intro.pages then
        intro.state = "turning"
        flux.to(intro, 0.5, {textAlpha = 0}):ease("quadout"):oncomplete(function()
            intro.pageIndex = intro.pageIndex + 1
            intro.lineIndex = 1
            intro.textAlpha = 1
            intro:startTyping()
        end)
    else
        intro:finish()
    end
end

function intro:finish()
    if intro.state == "fading" or intro.state == "revealing" then return end
    intro.state = "fading"
    menuMusic:fadeOut(1.8, false)
    flux.to(intro, 1.8, {textAlpha = 0}):ease("quadout"):oncomplete(function()
        intro.state = "holding"
        intro.holdTimer = 0.5
    end)
end

function intro:reveal()
    intro.state = "revealing"

    -- Load the first map behind the black overlay, with the player frozen until it opens
    triggerTransition(data.map, data.playerX, data.playerY)
    player.state = 12
    love.graphics.setBackgroundColor(96/255, 174/255, 140/255)
    cam.smoother = Camera.smooth.none()

    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local maxRad = math.sqrt(w*w + h*h)
    flux.to(intro, 1.4, {holeRad = maxRad}):ease("quadin"):oncomplete(function()
        intro.active = false
        player.state = 0
        cam.smoother = Camera.smooth.damped(8)
    end)
end

function intro:update(dt)
    if not intro.active then return end

    if intro.state == "typing" then
        local before = math.floor(intro.chars)
        intro.chars = intro.chars + dt * intro.typeSpeed

        -- soft tick every few characters
        if math.floor(intro.chars) ~= before then
            intro.clickTimer = intro.clickTimer - 1
            if intro.clickTimer <= 0 then
                dj.play(sounds.ui.click, "static", "effect", 0.25, 1 + math.random()/5)
                intro.clickTimer = 3
            end
        end

        if intro.chars >= #intro:currentEntry().text then
            intro:finishTyping()
        end
    elseif intro.state == "waiting" then
        intro.waitTimer = intro.waitTimer - dt
        if intro.waitTimer <= 0 then
            intro:nextLine()
        end
    elseif intro.state == "holding" then
        intro.holdTimer = intro.holdTimer - dt
        if intro.holdTimer <= 0 then
            intro:reveal()
        end
    end
end

function intro:getFont(style)
    if style == "heading" then return fonts.introHeading end
    if style == "tagline" then return fonts.introTagline end
    return fonts.pause2
end

-- Draws one entry, wrapped to width, showing only its first `chars` characters.
-- Wrapping is worked out on the full text so words don't jump lines while typing.
function intro:drawEntry(entry, chars, x, y, width, alpha)
    local font = intro:getFont(entry.style)
    local _, wrapped = font:getWrap(entry.text, width)
    love.graphics.setFont(font)

    local searchFrom = 1
    for i, line in ipairs(wrapped) do
        -- find where this wrapped line starts in the full text to know how much of it is typed
        local lineStart = string.find(entry.text, line, searchFrom, true) or searchFrom
        searchFrom = lineStart + #line
        if chars < lineStart then break end
        local shown = string.sub(line, 1, chars - lineStart + 1)
        local ly = y + (i - 1) * font:getHeight()

        if entry.style == "tagline" then
            -- VT323 has no bold weight, so thicken it with a second offset pass
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.printf(shown, x + math.max(1, scale * 0.25), ly, width, "center")
        elseif entry.style == "heading" then
            love.graphics.setColor(0.85, 0.75, 0.55, alpha)
        else
            love.graphics.setColor(1, 1, 1, alpha)
        end
        love.graphics.printf(shown, x, ly, width, "center")
    end
end

function intro:getEntryHeight(entry, width)
    local font = intro:getFont(entry.style)
    local _, wrapped = font:getWrap(entry.text, width)
    local gap = 6 * scale
    if entry.style == "heading" then gap = 12 * scale end
    return #wrapped * font:getHeight() + gap
end

function intro:draw()
    if not intro.active then return end

    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    if intro.state == "revealing" then
        -- Black everywhere except a growing circle around the player
        local px, py = cam:cameraCoords(player:getX(), player:getY())
        love.graphics.stencil(function()
            love.graphics.circle("fill", px, py, intro.holeRad)
        end, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", -10, -10, w + 20, h + 20)
        love.graphics.setStencilTest()
        return
    end

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", -10, -10, w + 20, h + 20)

    -- Lay out the whole page up front so it stays centered as entries appear
    local page = intro:currentPage()
    local function entryWidth(entry)
        -- the tagline gets extra room so it stays on one line
        if entry.style == "tagline" then return w * 0.9 end
        return math.min(w * 0.8, 240 * scale)
    end
    local total = 0
    for _, entry in ipairs(page) do
        total = total + intro:getEntryHeight(entry, entryWidth(entry))
    end

    local y = h/2 - total/2
    for i = 1, intro.lineIndex do
        local entry = page[i]
        local chars = #entry.text
        if i == intro.lineIndex then chars = math.floor(intro.chars) end

        local alpha = intro.textAlpha
        if i < intro.lineIndex and entry.style == "body" then alpha = alpha * 0.6 end

        local width = entryWidth(entry)
        intro:drawEntry(entry, chars, w/2 - width/2, y, width, alpha)
        y = y + intro:getEntryHeight(entry, width)
    end

    love.graphics.setFont(fonts.pause2)
    love.graphics.setColor(1, 1, 1, 0.35 * intro.textAlpha)
    love.graphics.printf("Space to continue     Esc to skip", w/2 - 4000, h - 16 * scale, 8000, "center")
end
