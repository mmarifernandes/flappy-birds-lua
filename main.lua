-- local = let do js

local bird = {
    sprite = love.graphics.newImage('assets/gato.png')
}

function love.draw()
    love.graphics.draw(bird.sprite, 300, 200, 0, 0.2, 0.2)
end