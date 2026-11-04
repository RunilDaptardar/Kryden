menuMusic = {}
menuMusic.fadeTimer = 0
menuMusic.fadeDuration = 0
menuMusic.fadeReset = false

local function getMenuMusicChannel()
    local channels = dj.findTag("menuMusic")
    for _, channel in ipairs(channels) do
        return dj.channels[channel]
    end
end

function menuMusic:start(reset)
    self.fadeTimer = 0
    self.fadeDuration = 0
    self.fadeReset = false

    local channel = getMenuMusicChannel()
    if channel then
        if reset then
            channel[1]:seek(0)
            dj.stop("menuMusic")
            channel = nil
        else
            channel[1]:setLooping(true)
            channel[1]:setVolume(1)
            channel[1]:play()
            dj.volume("menuMusic", 1)
            return
        end
    end

    local channelIndex = dj.play(sounds.ui.menuMusic, "stream", "menuMusic", 1, 1)
    dj.channels[channelIndex][1]:setLooping(true)
    dj.volume("menuMusic", 1)
end

function menuMusic:fadeOut(duration, resetAfter, stopAtEnd)
    self.fadeTimer = duration
    self.fadeDuration = duration
    self.fadeReset = resetAfter == true
    if stopAtEnd == nil then stopAtEnd = true end
    self.stopAtEnd = stopAtEnd
end

function menuMusic:update(dt)
    if self.fadeTimer <= 0 then return end

    self.fadeTimer = math.max(0, self.fadeTimer - dt)
    local volume = 1
    if self.fadeDuration > 0 then
        volume = self.fadeTimer / self.fadeDuration
    end
    dj.volume("menuMusic", volume)

    if self.fadeTimer == 0 then
        if self.fadeReset then
            self:start(true)
        elseif self.stopAtEnd then
            dj.stop("menuMusic")
        end
        self.fadeDuration = 0
        self.fadeReset = false
    end
end
