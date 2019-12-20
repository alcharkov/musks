require('enemy')

function love.load()
    love.window.setMode(500, 800, {resizable=false, vsync=false, minwidth=250, minheight=400})
    love.window.setTitle("Musks")
    enemies = {}
    player = {}
    player.shots = {}

    player.speed = 500
    player.img = love.graphics.newImage("images/Spaceship_tut.png")
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() * 0.8
    backgroundPosition = -love.graphics.getHeight()
    foregroundPosition = -love.graphics.getHeight()*2

    background = love.graphics.newImage("images/background.png")
    foreground = love.graphics.newImage("images/background.png")
    audio_shoot = love.audio.newSource("audio/146730__leszek-szary__shoot.wav", "static")

    explosion_img = love.graphics.newImage("images/explosion.png")
    explosion_sprite = love.graphics.newQuad(0, 0, 32, 32, explosion_img:getDimensions())
    audio_explosion = love.audio.newSource("audio/268557__cydon__explosion-001.mp3", "static")

    screenCenter = love.graphics.getWidth() / 2

    local xPos = love.math.random(love.graphics.getWidth())
    local enemySpeed = love.math.random(1, 10)
    asteroid_tiny = love.graphics.newImage("images/asteroid_tiny.png")
    table.insert(enemies, Enemy:new(xPos, 0, enemySpeed, asteroid_tiny))

    level = 0
    exp = 0

    collisionX = 0
    collisionY = 0

    collided = false
end

function love.update(dt)
    --Keyboard events
    if love.keyboard.isDown("up") then
        if player.y > 0 then
            player.y = player.y - player.speed * dt
        end
    end
    if love.keyboard.isDown("down") then
        if player.y + player.img:getHeight() < love.graphics.getHeight() then
            player.y = player.y + player.speed * dt
        end
    end
    if love.keyboard.isDown("left") then
        if player.x > 0 then
            player.x = player.x - player.speed * dt
        end
    end
    if love.keyboard.isDown("right") then
        if player.x + player.img:getWidth() < love.graphics.getWidth() then
            player.x = player.x + player.speed * dt
        end
    end

    --Shots
    for _, v in ipairs(player.shots) do
       v.y = v.y - dt * 2000
    end

    --Scrolling
    if backgroundPosition < love.graphics.getHeight() then
        backgroundPosition = backgroundPosition + 100 * dt
        foregroundPosition = foregroundPosition + 100 * dt
    end

    if backgroundPosition >=0 then
        backgroundPosition = -love.graphics.getHeight()
    elseif foregroundPosition >= -love.graphics.getHeight() then
        foregroundPosition = -love.graphics.getHeight()*2
    end
    
    --Enemies
    for c, enemy in ipairs(enemies) do
        if checkCollision(player.x, player.y, player.img:getWidth(), player.img:getHeight(),
                enemy.x, enemy.y, enemy.width, enemy.height) then
            collisionX = player.x
            collisionY = player.y
            audio_explosion:stop()
            audio_explosion:play()
            collided = true
            --TODO: remove duplicate
            --Create new enemy
            table.remove(enemies, c)
            local xPos = love.math.random(love.graphics.getWidth())
            local enemySpeed = love.math.random(1, 10)
            table.insert(enemies, Enemy:new(xPos, -100, enemySpeed, asteroid_tiny))
        elseif   enemy.y > love.graphics.getHeight() then
            --TODO: remove duplicate
            --Create new enemy
            table.remove(enemies, c)
            local xPos = love.math.random(love.graphics.getWidth())
            local enemySpeed = love.math.random(1, 10)
            table.insert(enemies, Enemy:new(xPos, -100, enemySpeed, asteroid_tiny))
        else
            Enemy:update(enemy, dt)
        end
    end
end

function love.keyreleased(key)
    if (key == " " or key == "space") then
        audio_shoot:stop()
        audio_shoot:play()
        shoot()
    end
end

function love.draw()
    drawBackground()
    drawSpaceship()
    drawShots()
    drawEnemies()
    drawExplosion()
end

function drawBackground()
    --Calculate background
    local sx = love.graphics.getWidth() / background:getWidth()
    local sy = love.graphics.getHeight() / background:getHeight()
    --Draw background
    love.graphics.draw(background, 0, backgroundPosition, 0, sx, sy*2)
    love.graphics.draw(foreground, 0, foregroundPosition, 0, sx, sy*2)
end

function drawSpaceship()
    love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 0)
end

function drawShots()
    for _, v in ipairs(player.shots) do
        love.graphics.rectangle("fill", v.x, v.y, 4, 4)
    end
end

function drawEnemies()
    for _, enemy in ipairs(enemies) do
        Enemy:draw(enemy)
    end
end

function drawExplosion()
    if collided then
        love.graphics.draw(explosion_img, explosion_sprite, collisionX, collisionY)
        collided = false
    end
end

function shoot()
    local shots = {}
    local spaceship_center = player.img:getWidth() / 2
    shots.x = player.x + spaceship_center
    shots.y = player.y

    table.insert(player.shots, shots)
end

function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
