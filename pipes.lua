local pipes = {}
local canvas_width = love.graphics.getWidth()
local canvas_height = love.graphics.getHeight()
local pipeTexture = love.graphics.newImage("assets/building texture.png")

-- inicializa os canos
local function pipesInit()
    pipes.clock = 0  -- tempo decorrido desde o ultimo cano gerado
    pipes.gen_rate = 1.5  -- tempo para gerar um novo cano
end

-- reseta os canos
local function pipesReset()
    pipes.clock = 0
    while #pipes > 0 do
        table.remove(pipes, 1)
    end
end


local function pipeCreate()
    local pipe = {}
    pipe.width = 70
    pipe.height1 = math.random(100, canvas_height - 300)  -- altura do cano cima
    pipe.empty_space = 250 
    pipe.height2 = canvas_height - pipe.height1 - pipe.empty_space  -- altura do cano baixo
    pipe.x = canvas_width  -- posicao inicial do cano 
    pipe.speed = -200  
    pipe.scored = false

    return pipe
end

-- atualiza os canos
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
    else
        pipes.gen_rate = 1.5
    end

    for _, pipe in ipairs(pipes) do
        pipe.speed = currentSpeed
    end

-- gera um novo cano conforme o tempo passa
    if pipes.clock > pipes.gen_rate then
        pipes.clock = 0
        table.insert(pipes, pipeCreate()) 
    end

-- move os canos
    for k, pipe in ipairs(pipes) do
        pipe.x = pipe.x + pipe.speed * dt
    end

-- remove canos fora da tela
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

-- desenha os canos na tela
local function pipesDraw()
    for _, pipe in ipairs(pipes) do
        love.graphics.setColor(love.math.colorFromBytes(128, 234, 255)) 
        love.graphics.draw(pipeTexture, pipe.x, 0, 0, pipe.width / pipeTexture:getWidth(), pipe.height1 / pipeTexture:getHeight())
        love.graphics.draw(pipeTexture, pipe.x, canvas_height - pipe.height2, 0, pipe.width / pipeTexture:getWidth(), pipe.height2 / pipeTexture:getHeight())
    end
    love.graphics.setColor(1, 1, 1)
end

-- verifica colisão do pássaro com os canos
local function checkCollision(pipe, bird)
    local bird_width = bird.width + 25
    local bird_height = bird.height + 50

    -- superior
    if bird.x < pipe.x + pipe.width and
       bird.x + bird_width > pipe.x and
       bird.y + 30 < pipe.height1 then
        return true
    end

    -- inferior
    if bird.x + 30 < pipe.x + pipe.width and
       bird.x + bird_width > pipe.x and
       bird.y + bird_height > canvas_height - pipe.height2 then
        return true
    end

    return false
end

return {
    pipes = pipes,
    pipesInit = pipesInit,
    pipesReset = pipesReset,
    pipesUpdate = pipesUpdate,
    pipesDraw = pipesDraw,
    checkCollision = checkCollision
}
