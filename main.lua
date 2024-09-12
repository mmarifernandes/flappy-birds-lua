local birdModule = require("bird")
local pipesModule = require("pipes")
local song = require("song")
local fonteFlappyBird = love.graphics.newFont('/assets/PressStart2P-Regular.ttf', 20)
local scoreAtual = 0
local bestScore = 0
local bird = birdModule.bird
local pipes = pipesModule.pipes
local passSound = love.audio.newSource("assets/pass_sound.mp3", "static")
local flapSound = love.audio.newSource("assets/flap.mp3", "static")
local dieSound = love.audio.newSource("assets/die.mp3", "static")
local ambiente = {
    background = love.graphics.newImage('assets/fundo.jpg')
}
local logo = love.graphics.newImage('assets/flappy_kitty_logo.png')
local instructionFont = love.graphics.newFont(16)
local gravity = 600
local jump_force = -300
local gameState = "menu"
local score = 0
local scoreFont = love.graphics.newFont(32)
local canvas_height = love.graphics.getHeight()

-- Função que reage às teclas pressionadas
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

-- Atualiza o estado do jogo
function love.update(dt)
    if gameState == "playing" and bird.alive then
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
            if not pipe.scored and pipe.x + pipe.width < bird.x then
                score = score + 1
                pipe.scored = true
                love.audio.play(passSound)
            end

            if pipesModule.checkCollision(pipe, bird) then
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
    end
end

local bgWidth = ambiente.background:getWidth()
local bgHeight = ambiente.background:getHeight()
local scaleX = 800 / bgWidth
local scaleY = 750 / bgHeight
local scale = math.max(scaleX, scaleY)
local logoScale = 0.35

function love.draw()
    love.graphics.draw(ambiente.background, 0, 0, 0, scale, scale)

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
        local logoY = love.graphics.getHeight() / 2 - logo:getHeight() * logoScale - 130
        love.graphics.draw(logo, logoX, logoY, 0, logoScale, logoScale)
        -- love.graphics.printf("Flappy Kitty =^._.^=", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
        love.graphics.printf("Aperte espaço para começar!", 0, love.graphics.getHeight() / 2 + 300, love.graphics.getWidth(), "center")
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

-- Reinicia o jogo
function resetGame()
    score = 0
    bird.y = 100
    bird.dy = 0
    bird.alive = true
    birdModule.birdInit()
    pipesModule.pipesReset()
end

-- Carregamento inicial
function love.load()
    song.play()  -- Inicia a reprodução da música de fundo
    birdModule.birdInit()
    pipesModule.pipesInit()
end
