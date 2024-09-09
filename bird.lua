local anim8 = require 'libraries/anim8'

local bird = {
    x = 100,
    y = 100,
    width = 32,
    height = 32,
    dy = 0,
    alive = true,
    jumping = false,
    animations = {},
    currentAnimation = nil,
    currentImage = nil,
    jumpImage = nil,
    fallImage = nil
}

local function loadSpriteSheet(path, frameWidth, frameHeight)
    local image = love.graphics.newImage(path)
    local grid = anim8.newGrid(frameWidth, frameHeight, image:getWidth(), image:getHeight())
    return image, grid
end

local function birdInit()
    -- Carregue imagens e grades
    bird.jumpImage, bird.jumpGrid = loadSpriteSheet('assets/cat_jump.png', 32, 32)
    bird.fallImage, bird.fallGrid = loadSpriteSheet('assets/cat_fall.png', 32, 32)

    -- Inicialize animações com o grid correto
    bird.animations.jump = anim8.newAnimation(bird.jumpGrid('1-4', 1), 0.1)
    bird.animations.fall = anim8.newAnimation(bird.fallGrid('1-4', 1), 0.1)

    -- Define animação inicial
    bird.currentAnimation = bird.animations.jump
    bird.currentImage = bird.jumpImage
end

local function updateAnimation(dt)
    if bird.dy < 0 and bird.currentAnimation ~= bird.animations.jump then
        bird.currentAnimation = bird.animations.jump
        bird.currentImage = bird.jumpImage
    elseif bird.dy >= 0 and bird.currentAnimation ~= bird.animations.fall then
        bird.currentAnimation = bird.animations.fall
        bird.currentImage = bird.fallImage
    end

    if bird.currentAnimation then
        bird.currentAnimation:update(dt)
    end
end

return {
    bird = bird,
    birdInit = birdInit,
    updateAnimation = updateAnimation
}
