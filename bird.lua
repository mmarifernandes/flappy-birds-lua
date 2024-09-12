local anim8 = require 'libraries/anim8'

local bird = {
    x = 100,
    y = 100,
    width = 32,
    height = 32,
    dy = 0, -- vel vertical
    alive = true,
    jumping = false,
    animations = {}, -- tabela para armazenar as animações do pássaro
    currentAnimation = nil, -- animação atual
    currentImage = nil, -- imagem atual
    jumpImage = nil, 
    fallImage = nil
}

-- função para carregar uma folha de sprites (spritesheet)
-- 'path' é o caminho para o arquivo de imagem
-- 'frameWidth' e 'frameHeight' são as dimensões de cada quadro da animação
local function loadSpriteSheet(path, frameWidth, frameHeight)
    local image = love.graphics.newImage(path)
    local grid = anim8.newGrid(frameWidth, frameHeight, image:getWidth(), image:getHeight()) -- cria uma grid para mapear os quadros da animação
    return image, grid -- retorna a imagem e a grid para uso nas animações
end

local function birdInit()
    -- imagens e grades
    bird.jumpImage, bird.jumpGrid = loadSpriteSheet('assets/cat_jump.png', 32, 32)
    bird.fallImage, bird.fallGrid = loadSpriteSheet('assets/cat_fall.png', 32, 32)

    -- animações de pulo e queda com quadros de 1 a 4, a cada 0.1s
    bird.animations.jump = anim8.newAnimation(bird.jumpGrid('1-4', 1), 0.1)
    bird.animations.fall = anim8.newAnimation(bird.fallGrid('1-4', 1), 0.1)

    -- define animação inicial
    bird.currentAnimation = bird.animations.jump
    bird.currentImage = bird.jumpImage
end

-- atualiza a animação do gato com base na sua velocidade vertical (dy)
local function updateAnimation(dt)
    -- se o gato tá subindo (dy < 0) e não tá na animação de pulo, muda para a animação de pulo
    if bird.dy < 0 and bird.currentAnimation ~= bird.animations.jump then
        bird.currentAnimation = bird.animations.jump
        bird.currentImage = bird.jumpImage
    -- se o gato tá caindo (dy >= 0) e não tá na animação de queda, muda para a animação de queda
    elseif bird.dy >= 0 and bird.currentAnimation ~= bird.animations.fall then
        bird.currentAnimation = bird.animations.fall
        bird.currentImage = bird.fallImage
    end

    -- atualiza a animação atual
    if bird.currentAnimation then
        bird.currentAnimation:update(dt)
    end
end

return {
    bird = bird,
    birdInit = birdInit,
    updateAnimation = updateAnimation
}
