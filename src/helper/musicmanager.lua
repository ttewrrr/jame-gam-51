local MusicManager = {}
MusicManager.__index = MusicManager

function MusicManager.new()
    local self = setmetatable({}, MusicManager)

    self.CurrentMusic = love.audio.newSource(
        "src/sounds/FrogmanFullMix.mp3",
        "stream"
    )

    self.CurrentMusic:setLooping(true)
    self.CurrentMusic:setVolume(0.6)

    return self
end


function MusicManager:Play()
    if not self.CurrentMusic:isPlaying() then
        self.CurrentMusic:play()
    end
end


function MusicManager:Stop()
    if self.CurrentMusic:isPlaying() then
        self.CurrentMusic:stop()
    end
end


function MusicManager:SetVolume(v)
    self.CurrentMusic:setVolume(v)
end


return MusicManager
