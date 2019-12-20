Enemy = {}
Enemy.__index = Enemy

function Enemy:new(x, y, speed, img)
    o = {
        x = x,
        y = y,
        width = 10,
        height = 15,
        speed = speed,
        img = img
    }

    setmetatable(o, self)
    self.__index = self

    return o
end

function Enemy:update(o, dt, speed)
    o.y = o.y + o.speed * dt * 100
end

function Enemy:draw(o)
    love.graphics.draw(o.img, o.x, o.y, 0, 1, 1, 0, 0)
end
