local birdModule = require("bird")
local pipesModule = require("pipes")
local fonteFlappyBird = love.graphics.newFont('/assets/PressStart2P-Regular.ttf', 20)
local scoreAtual = 0
local bird = birdModule.bird
local pipes = pipesModule.pipes
local passSound = love.audio.newSource("assets/pass_sound.mp3", "static")  -- Carrega o som de passar
local flapSound = love.audio.newSource("assets/flap.mp3", "static")  -- Carrega o som de passar
local dieSound = love.audio.newSource("assets/die.mp3", "static")  -- Carrega o som de passar
local ambientSound = love.audio.newSource("assets/ambient.mp3", "static")  -- Carrega o som de passar
    ambientSound:setVolume(0.2)  -- Ajusta o volume (0.0 a 1.0, onde 1.0 é o volume máximo)
    ambientSound:setLooping(true)  -- Define a música para repetir
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
            love.audio.play(flapSound)  -- Toca o som de passar

        end
    end
end

-- Atualiza o estado do jogo
function love.update(dt)
    if gameState == "playing" and bird.alive then
        -- Aplica gravidade ao pássaro
        bird.dy = bird.dy + gravity * dt
        bird.y = bird.y + bird.dy * dt

        if bird.y > canvas_height - bird.height then
            bird.y = canvas_height - bird.height
            resetGame()
            love.audio.play(dieSound)
            gameState = "fail"

        elseif bird.y < 0 then
            resetGame()
            love.audio.play(dieSound)
            gameState = "fail"
        end

        birdModule.updateAnimation(dt)
        pipesModule.pipesUpdate(dt, score)

        for _, pipe in ipairs(pipes) do
            -- Verifica se o pássaro passou pelo cano para aumentar a pontuação
            if not pipe.scored and pipe.x + pipe.width < bird.x then
                score = score + 1
                pipe.scored = true
                love.audio.play(passSound)
            end

            -- Verifica colisão com o cano
            if pipesModule.checkCollision(pipe, bird) then
                bird.alive = false
                resetGame()
                love.audio.play(dieSound)
                gameState = "fail"
            end
        end
    end
end

local bgWidth = ambiente.background:getWidth()
local bgHeight = ambiente.background:getHeight()
local scaleX = 800 / bgWidth
local scaleY = 750 / bgHeight
local scale = math.max(scaleX, scaleY)  -- Mantém a imagem proporcional

function love.draw()

    love.graphics.draw(ambiente.background, 0, 0, 0, scale, scale) -- Desenha o fundo

    if gameState == "fail" then
        love.graphics.setFont(instructionFont)
        love.graphics.setFont(fonteFlappyBird)
        love.graphics.printf("Você perdeu :( Aperte espaço para continuar...", 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), "center")
        love.graphics.printf("Sua pontuação foi: " .. scoreAtual, 10, 100, love.graphics.getWidth(), "center")  -- Posição ajustada

    elseif gameState == "menu" then
        love.graphics.setFont(instructionFont)
        love.graphics.setFont(fonteFlappyBird)
        love.graphics.printf("Flappy Kitty =^._.^=", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
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
    ambientSound:play()  -- Inicia a reprodução da música de fundo
    birdModule.birdInit()
    pipesModule.pipesInit()
end
