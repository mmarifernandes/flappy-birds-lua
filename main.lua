-- Importa os módulos bird e pipes
local birdModule = require("bird")
local pipesModule = require("pipes")
local fonteFlappyBird = love.graphics.newFont('/assets/PressStart2P-Regular.ttf', 20)
local scoreAtual = 0
local bird = birdModule.bird
local pipes = pipesModule.pipes

local ambiente = {
    background = love.graphics.newImage('assets/fundo.jpg')
}
local instructionFont = love.graphics.newFont(16)  -- Fonte para as instruções

local gravity = 600  -- Valor da gravidade
local jump_force = -300  -- Força do pulo
local gameState = "menu"  -- Estado inicial do jogo (menu)
local score = 0  -- Inicializa a pontuação como 0
local scoreFont = love.graphics.newFont(32)  -- Fonte para a pontuação

local canvas_height = love.graphics.getHeight()

-- Função que reage às teclas pressionadas
function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        if gameState == "fail" or gameState == "menu" then
            resetGame()
            gameState = "playing"
        elseif gameState == "playing" and bird.alive then
            bird.dy = jump_force
            bird.jumping = true
        end
    end
end

-- Atualiza o estado do jogo
function love.update(dt)
    if gameState == "playing" and bird.alive then
        bird.dy = bird.dy + gravity * dt  -- Aplica gravidade ao pássaro
        bird.y = bird.y + bird.dy * dt  -- Atualiza a posição vertical do pássaro

        if bird.y > canvas_height - bird.height then
            bird.y = canvas_height - bird.height
            resetGame()  -- Reinicia o jogo se tocar embaixo
            gameState = "fail"  -- Altera o estado para "fail"
        elseif bird.y < 0 then
            resetGame()  -- Reinicia o jogo se tocar o topo
            gameState = "fail"  -- Altera o estado para "fail"
        end

        birdModule.updateAnimation(dt)
        pipesModule.pipesUpdate(dt)

        -- Verifica colisão do pássaro com cada cano
        for _, pipe in ipairs(pipes) do
            if not pipe.scored and pipe.x + pipe.width < bird.x then
                score = score + 1  -- Incrementa a pontuação
                pipe.scored = true  -- Marca o cano como "pontuado" para não contar novamente
            end   

            if pipesModule.checkCollision(pipe, bird) then
                bird.alive = false
                resetGame()  -- Reinicia o jogo se houver colisão
                gameState = "fail"  -- Altera o estado para "fail"
            end
        end
    end
end

-- Desenha o jogo na tela
function love.draw()
    love.graphics.draw(ambiente.background, 0, 0)  -- Desenha o fundo

    if gameState == "fail" then
        love.graphics.setFont(instructionFont)
        love.graphics.setFont(fonteFlappyBird)
        love.graphics.printf("Você perdeu :( Aperte espaço para continuar...", 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), "center")
        love.graphics.printf("Sua pontuação foi: " .. scoreAtual, 10, 100, love.graphics.getWidth(), "center")  -- Posição ajustada

    elseif gameState == "menu" then
        love.graphics.setFont(instructionFont)
        love.graphics.setFont(fonteFlappyBird)
        love.graphics.printf("Aperte espaço para começar!", 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), "center")
    elseif gameState == "playing" then
        bird.currentAnimation:draw(bird.currentImage, bird.x, bird.y, 0, 3, 3)
        pipesModule.pipesDraw()  -- Desenha os canos
      
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(scoreFont)
        love.graphics.setFont(fonteFlappyBird)
        love.graphics.printf("Pontuação: " .. score, 10, 10, love.graphics.getWidth(), "left")  -- Posição ajustada
        scoreAtual = score
    end
end

-- Reinicia o jogo
function resetGame()
    score = 0  -- Reseta a pontuação
    bird.y = 0
    bird.dy = 0
    bird.alive = true
    birdModule.birdInit()
    pipesModule.pipesReset()
end

-- Carregamento inicial
function love.load()

    birdModule.birdInit()
    pipesModule.pipesInit()
end
