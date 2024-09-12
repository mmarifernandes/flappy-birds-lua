local birdModule = require("bird")
local pipesModule = require("pipes")
local song = require("song")
local bird = birdModule.bird
local pipes = pipesModule.pipes

local ambiente = { background = love.graphics.newImage('assets/fundo.jpg') }
local logo = love.graphics.newImage('assets/flappy_kitty_logo.png')
local passSound = love.audio.newSource("assets/pass_sound.mp3", "static")
local flapSound = love.audio.newSource("assets/flap.mp3", "static")
local dieSound = love.audio.newSource("assets/die.mp3", "static")
local fonteFlappyBird = love.graphics.newFont('/assets/PressStart2P-Regular.ttf', 20)
local instructionFont = love.graphics.newFont(16)

local scoreAtual = 0
local bestScore = 0
local gravity = 600
local jump_force = -300
local gameState = "menu"
local score = 0
local scoreFont = love.graphics.newFont(32)

local canvas_height = love.graphics.getHeight()
local bgWidth = ambiente.background:getWidth()
local bgHeight = ambiente.background:getHeight()
local scaleX = 800 / bgWidth
local scaleY = 750 / bgHeight
local scale = math.max(scaleX, scaleY)
local bgX1 = 0
local bgX2 = bgWidth * scale
local backgroundSpeed = 100  -- velocidade do movimento do fundo
local logoScale = 0.35

local floatAmplitude = 10  -- amplitude da flutuação
local floatSpeed = 2       -- velocidade da flutuação
local logoY

local blinkTime = 0 -- animação de piscar texto
local blinkInterval = 0.5
local showText = true

function love.keypressed(key)
    if key == "space" then
        if gameState == "fail" or gameState == "menu" then
            resetGame()
            gameState = "playing"
        elseif gameState == "playing" and bird.alive then
            bird.dy = jump_force
            bird.jumping = true
            love.audio.play(flapSound)
        end
    end
end

-- atualiza o estado do jogo
function love.update(dt) -- dt = delta time (usado p atualizar o jogo)
    -- atualizar o tempo de piscar o texto
    blinkTime = blinkTime + dt
    if blinkTime >= blinkInterval then
        showText = not showText  -- alterna a visibilidade do texto
        blinkTime = 0  -- reinicia o temporizador
    end

    if gameState == "playing" and bird.alive then

        bgX1 = bgX1 - backgroundSpeed * dt
        bgX2 = bgX2 - backgroundSpeed * dt

        -- se o fundo sair da tela reposicionar à direita
        if bgX1 + bgWidth * scale <= 0 then
            bgX1 = bgX2 + bgWidth * scale - 15
        end
        if bgX2 + bgWidth * scale <= 0 then
            bgX2 = bgX1 + bgWidth * scale - 15
        end

        bird.dy = bird.dy + gravity * dt -- att velocidade vertical do gato
        bird.y = bird.y + bird.dy * dt -- att posicao y do gato

        if bird.y > canvas_height - bird.height then -- checa colisao em cima
            bird.y = canvas_height - bird.height
            resetGame()
            love.audio.play(dieSound)
            gameState = "fail"
        elseif bird.y < 0 then -- colisao embaixo
            resetGame()
            love.audio.play(dieSound)
            gameState = "fail"
        end

        birdModule.updateAnimation(dt)
        pipesModule.pipesUpdate(dt, score)

        -- passa por cada tubo e verifica
        for _, pipe in ipairs(pipes) do
            
            -- pontuação e se o predio passou completamente da posição x do gato
            if not pipe.scored and pipe.x + pipe.width < bird.x then
                score = score + 1
                pipe.scored = true
                love.audio.play(passSound)
            end

            if pipesModule.checkCollision(pipe, bird) then -- colisao com o gato
                bird.alive = false
                resetGame()
                love.audio.play(dieSound)
                gameState = "fail"
            end
        end

        song.updateMusicSpeed(score)

    elseif gameState == "fail" then
        if scoreAtual > bestScore then
            bestScore = scoreAtual
        end

    elseif gameState == "menu" then
        -- atualizar a flutuação da logo no menu
        local time = love.timer.getTime()
        logoY = love.graphics.getHeight() / 2 - logo:getHeight() * logoScale - 130 + math.sin(time * floatSpeed) * floatAmplitude
    end
end



function love.draw()

    love.graphics.draw(ambiente.background, bgX1, 0, 0, scale, scale)
    love.graphics.draw(ambiente.background, bgX2, 0, 0, scale, scale)

    if gameState == "fail" then

        love.graphics.setFont(instructionFont)
        love.graphics.setFont(fonteFlappyBird)
        love.graphics.printf("Você perdeu :( Aperte espaço para continuar...", 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), "center")
        love.graphics.printf("Sua pontuação foi: " .. scoreAtual, 10, 100, love.graphics.getWidth(), "center")
        love.graphics.printf("Sua melhor pontuação foi: " .. bestScore, 10, 140, love.graphics.getWidth(), "center")

    elseif gameState == "menu" then

        love.graphics.setFont(instructionFont)
        love.graphics.setFont(fonteFlappyBird)
        local logoX = (love.graphics.getWidth() - logo:getWidth() * logoScale) / 2
        love.graphics.draw(logo, logoX, logoY, 0, logoScale, logoScale)
        if showText then
            love.graphics.printf("Aperte espaço para começar!", 0, love.graphics.getHeight() / 2 + 300, love.graphics.getWidth(), "center")
        end
    elseif gameState == "playing" then

        bird.currentAnimation:draw(bird.currentImage, bird.x, bird.y, 0, 3, 3)
        pipesModule.pipesDraw()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(scoreFont)
        love.graphics.setFont(fonteFlappyBird)
        love.graphics.printf("Pontuação: " .. score, 10, 10, love.graphics.getWidth(), "left")
        love.graphics.printf("Melhor pontuação: " .. bestScore, 10, 50, love.graphics.getWidth(), "left")

        if scoreAtual > bestScore then
            bestScore = scoreAtual
        end
        scoreAtual = score
    end
end

function resetGame()
    score = 0
    bird.y = 100
    bird.dy = 0
    bird.alive = true
    birdModule.birdInit()
    pipesModule.pipesReset()
end

function love.load()
    song.play() 
    birdModule.birdInit()
    pipesModule.pipesInit()
end
