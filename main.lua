-- Importa os módulos bird e pipes
local birdModule = require("bird")
local pipesModule = require("pipes")

local bird = birdModule.bird
local pipes = pipesModule.pipes

local ambiente = {
    background = love.graphics.newImage('assets/fundo.jpg')
}
local instructionFont = love.graphics.newFont(24)  -- Fonte para as instruções

local gravity = 600  -- Valor da gravidade
local jump_force = -300  -- Força do pulo
local gameState = "menu"  -- Estado inicial do jogo (menu)
local score = 0  -- Inicializa a pontuação como 0
local scoreFont = love.graphics.newFont(32)  -- Fonte para a pontuação

local canvas_height = love.graphics.getHeight()

-- Função que reage às teclas pressionadas
function love.keypressed(key, scancode, isrepeat)
    if gameState == "menu" and key == "space" then
        gameState = "playing"  -- Muda o estado do jogo para "playing" ao pressionar espaço
    elseif gameState == "playing" then
        if (scancode == 'space' or scancode == 'up' or scancode == 'w') and bird.alive then
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
        elseif bird.y < 0 then
            resetGame()  -- Reinicia o jogo se tocar o topo
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
            end
        end
    end
end




-- Desenha o jogo na tela
-- Desenha o jogo na tela
function love.draw()
    if gameState == "menu" then

        love.graphics.draw(ambiente.background, 0, 0)  -- Desenha o fundo
        love.graphics.setFont(instructionFont)
        love.graphics.printf("Aperte espaço para começar!", 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), "center")
    
    elseif gameState == "playing" then
        love.graphics.draw(ambiente.background, 0, 0)  -- Desenha o fundo primeiro
        
        
        bird.currentAnimation:draw(bird.currentImage, bird.x, bird.y, 0, 3, 3)
        pipesModule.pipesDraw()  -- Desenha os canos
      
        love.graphics.setColor(1, 1, 1)
        
        love.graphics.setFont(scoreFont)
        love.graphics.printf("Pontuação: " .. score, 10, 10, love.graphics.getWidth(), "left")  -- Posição ajustada
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
    gameState = "menu"  -- Define o estado do jogo como menu
end

-- Carregamento inicial
function love.load()
    birdModule.birdInit()
    pipesModule.pipesInit()
end