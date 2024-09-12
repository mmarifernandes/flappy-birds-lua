local song = {}

local ambientSound = love.audio.newSource("assets/ambient.mp3", "static")
ambientSound:setVolume(0.2)
ambientSound:setLooping(true)

function song.updateMusicSpeed(score)
    local speed = 1 + (math.floor(score / 10) * 0.1)
    ambientSound:setPitch(speed)
end

function song.play()
    ambientSound:play()
end

return song