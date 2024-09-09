local pipes = {}  -- Canos (retângulos)
local canvas_width = love.graphics.getWidth()
local canvas_height = love.graphics.getHeight()
local pipeTexture = love.graphics.newImage("assets/building texture.png")

-- Inicializa os canos
local function pipesInit()
    pipes.clock = 0  -- Tempo decorrido desde o último cano gerado
    pipes.gen_rate = 1.5  -- Tempo (em segundos) para gerar um novo cano
end

-- Reseta os canos
local function pipesReset()
    pipes.clock = 0
    while #pipes > 0 do
        table.remove(pipes, 1)  -- Remove todos os canos da tabela
    end
end

-- Cria canos em posições aleatórias
local function pipeCreate()
    local pipe = {}
    pipe.width = 70
    pipe.height1 = math.random(100, canvas_height - 250)  -- Altura do cano superior (cano 1)
    pipe.empty_space = 250  -- Espaço entre o cano superior e o inferior
    pipe.height2 = canvas_height - pipe.height1 - pipe.empty_space  -- Altura do cano inferior (cano 2)
    pipe.x = canvas_width  -- Posição inicial do cano (fora da tela à direita)
    pipe.speed = -200  -- Velocidade de movimento dos canos para a esquerda
    pipe.scored = false

    return pipe
end

local function pipesUpdate(dt, score)
    pipes.clock = pipes.clock + dt

    local baseSpeed = -200 
    local speedMultiplier = 1 + math.floor(score / 10) * 0.3 
    local currentSpeed = baseSpeed * speedMultiplier

    if score >= 50 then
        pipes.gen_rate = 1.0
    elseif score >= 30 then
        pipes.gen_rate = 1.0
    elseif score >= 20 then
        pipes.gen_rate = 1.0
    elseif score >= 10 then
        pipes.gen_rate = 1.2
    end


    for _, pipe in ipairs(pipes) do
        pipe.speed = currentSpeed
    end

    -- Gera um novo cano conforme o tempo passa
    if pipes.clock > pipes.gen_rate then
        pipes.clock = 0
        table.insert(pipes, pipeCreate())  -- Adiciona um novo cano
    end

    -- Move os canos
    for k, pipe in ipairs(pipes) do
        pipe.x = pipe.x + pipe.speed * dt
    end

    -- Remove canos fora da tela
    local dead_pipes_count = 0
    for k, pipe in ipairs(pipes) do
        if pipe.x < -pipe.width then
            dead_pipes_count = dead_pipes_count + 1
        else
            break
        end
    end

    for _ = 1, dead_pipes_count do
        table.remove(pipes, 1)
    end
end


-- Desenha os canos na tela
local function pipesDraw(score)
    for _, pipe in ipairs(pipes) do
        love.graphics.setColor(love.math.colorFromBytes(128, 234, 255)) 
        love.graphics.draw(pipeTexture, pipe.x, 0, 0, pipe.width / pipeTexture:getWidth(), pipe.height1 / pipeTexture:getHeight())
        love.graphics.draw(pipeTexture, pipe.x, canvas_height - pipe.height2, 0, pipe.width / pipeTexture:getWidth(), pipe.height2 / pipeTexture:getHeight())
    end

    love.graphics.setColor(1, 1, 1)  -- Reseta a cor do cano pra branco (pra conseguir desenhar novos depois)
end

-- Verifica colisão do pássaro com os canos
local function checkCollision(pipe, bird)
    local bird_width = bird.width 
    local bird_height = bird.height

    -- Verifica colisão com o cano superior
    if bird.x < pipe.x + pipe.width and
       bird.x + bird_width > pipe.x and
       bird.y < pipe.height1 then
        return true
    end

    -- Verifica colisão com o cano inferior
    if bird.x < pipe.x + pipe.width and
       bird.x + bird_width > pipe.x and
       bird.y + bird_height > canvas_height - pipe.height2 then
        return true
    end

    return false
end

-- Exporta as funções e propriedades dos canos
return {
    pipes = pipes,
    pipesInit = pipesInit,
    pipesReset = pipesReset,
    pipesUpdate = pipesUpdate,
    pipesDraw = pipesDraw,
    checkCollision = checkCollision
}
