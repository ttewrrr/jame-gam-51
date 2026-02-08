local UnderwaterLoop = {}
UnderwaterLoop.__index = UnderwaterLoop

local function Clamp(x, a, b)
    if x < a then return a end
    if x > b then return b end
    return x
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

function UnderwaterLoop.new()
    local self = setmetatable({}, UnderwaterLoop)

    self.Source = love.audio.newSource("src/sounds/real/Underwaterloop.wav", "stream")
    self.Source:setLooping(true)
    self.Source:setVolume(1)

    self.StandPitch = 1.0
    self.MovePitch = 1.3

    self.SpeedForMaxPitch = 120
    self.PitchSmoothness = 10

    self.CurrentPitch = self.StandPitch
    self.Source:setPitch(self.CurrentPitch)

    self.LastX = nil
    self.LastY = nil

    return self
end

function UnderwaterLoop:Play()
    if not self.Source:isPlaying() then
        self.Source:play()
    end
end

function UnderwaterLoop:Stop()
    if self.Source:isPlaying() then
        self.Source:stop()
    end
end

function UnderwaterLoop:Update(dt, player)
    if not player then return end

    if self.LastX == nil then
        self.LastX = player.x
        self.LastY = player.y
        self:Play()
        return
    end

    local dx = player.x - self.LastX
    local dy = player.y - self.LastY
    self.LastX = player.x
    self.LastY = player.y

    local speed = math.sqrt(dx * dx + dy * dy) / math.max(dt, 0.0001)

    local t = Clamp(speed / self.SpeedForMaxPitch, 0, 1)
    local targetPitch = Lerp(self.StandPitch, self.MovePitch, t)

    local smoothT = Clamp(self.PitchSmoothness * dt, 0, 1)
    self.CurrentPitch = Lerp(self.CurrentPitch, targetPitch, smoothT)

    self.Source:setPitch(self.CurrentPitch)

    if not self.Source:isPlaying() then
        self.Source:play()
    end
end

return UnderwaterLoop
