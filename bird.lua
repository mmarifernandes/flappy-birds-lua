-- local = let do js
local bird = {
    sprite = love.graphics.newImage('assets/gato.png')
}

local canvas_height = love.graphics.getHeight()

local function birdInit()
    -- Define o tamanho do pássaro com base na imagem
    bird.width = bird.sprite:getWidth() * 0.2
    bird.height = bird.sprite:getHeight() * 0.2
    bird.x = 150
    bird.y = (canvas_height - bird.height) / 2

    bird.min_speed = 25
    bird.max_speed = 250
    bird.speed = bird.min_speed
    bird.bump_height = 25

    bird.dy = 0  -- Velocidade vertical
    bird.alive = true
end

-- Exporta as funções e propriedades do pássaro
return {
    bird = bird,
    birdInit = birdInit
}
