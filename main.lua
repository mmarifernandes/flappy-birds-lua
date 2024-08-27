-- local = let do js

local bird = {
    sprite = love.graphics.newImage('assets/gato.png')
}

local ambiente = {
    background = love.graphics.newImage('assets/fundo.jpg')
}
local instructionFont = love.graphics.newFont(24)  -- Fonte para as instruções

local gravity = 600  -- Valor da gravidade
local jump_force = -300  -- Força do pulo
local gameState = "menu"  -- Estado inicial do jogo (menu)

local function birdInit()
    bird.width = 25
    bird.height = 25
    bird.x = 150
    bird.y = (750 - bird.height) / 2

    bird.min_speed = 25
    bird.max_speed = 250
    bird.speed = bird.min_speed
    bird.bump_height = 25

    bird.dy = 0  -- Velocidade vertical
    bird.alive = true
end

-- Inicializa o pássaro uma vez
birdInit()


function love.keypressed(key, scancode, isrepeat)
    if gameState == "menu" and key == "space" then
        gameState = "playing"  -- Muda o estado do jogo para "playing" ao pressionar Enter
    elseif gameState == "playing" then
        if (scancode == 'space' or scancode == 'up' or scancode == 'w') and bird.alive then
            bird.dy = jump_force  -- Aplica a força do pulo ao pássaro
        end
    end
end


function love.update(dt)
    if gameState == "playing" and bird.alive then
        bird.dy = bird.dy + gravity * dt  -- Aplica gravidade ao pássaro
        bird.y = bird.y + bird.dy * dt  -- Atualiza a posição vertical do pássaro

        -- Limita o pássaro a não sair da tela
        if bird.y > love.graphics.getHeight() - bird.height then
            bird.y = love.graphics.getHeight() - bird.height
            bird.dy = 0  -- Reseta a velocidade vertical se tocar o chão
        elseif bird.y < 0 then
            bird.y = 0
            bird.dy = 0  -- Impede que o pássaro suba além da tela
        end
    end
end

function love.draw()
    if gameState == "menu" then
        love.graphics.draw(ambiente.background, 0, 0)
        love.graphics.setFont(instructionFont)
        love.graphics.printf("Aperte espaço para começar!", 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), "center")
    elseif gameState == "playing" then
        -- Desenha o pássaro
        love.graphics.draw(ambiente.background, 0, 0)
        love.graphics.draw(bird.sprite, bird.x, bird.y, 0, 0.2, 0.2)
    end
end