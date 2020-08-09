local Player = {}
Player.__index = Player

local ACCELERATION = 600.0
local MAX_SPEED = 100.0
local DRAG = 500.0

function Player.new(x, y, world)
    local p ={}
    setmetatable(p, Player)
    p.body = love.physics.newBody(world, x, y, 'dynamic')
    p.shape = love.physics.newCircleShape(6)
    p.fixture = love.physics.newFixture(p.body, p.shape, 1)
    p.vel = {x = 0, y = 0}
    return p
end

function Player.update(self, dt)
    -- Calculamos el vector de direccion
    local x, y = 0, 0
    if( KEY_TABLE['a']) then
        x = x - 1
    end
    if( KEY_TABLE['d']) then
        x = x + 1
    end
    if( KEY_TABLE['w']) then
        y = y - 1
    end
    if( KEY_TABLE['s']) then
        y = y + 1
    end
    -- Calculamos las magnitudes de los vectores
    local mag_input = math.sqrt(x^2 + y^2)
    local mag_vel = math.sqrt(self.vel.x^2 + self.vel.y^2)
    if mag_input ~= 0 then
        -- Creo el nuevo vector de aceleracion y se lo sumo a la velocidad
        x = ((x / mag_input) * ACCELERATION * dt) + self.vel.x
        y = ((y / mag_input) * ACCELERATION * dt) + self.vel.y
        -- Calculo la magnitud del nuevo vector
        mag_input = math.sqrt(x^2 + y^2)
        -- Si la magnitud del vector es mayor a la magnitud maxima
        if mag_input > MAX_SPEED then
            x = (x / mag_input) * MAX_SPEED
            y = (y / mag_input) * MAX_SPEED
        end
        self.vel.x = x
        self.vel.y = y
    elseif mag_vel ~= 0 then
        -- Creo el nuevo vector de aceleracion y se lo sumo a la velocidad
        x = (-(self.vel.x / mag_vel) * DRAG * dt) + self.vel.x
        y = (-(self.vel.y / mag_vel) * DRAG * dt) + self.vel.y
        -- Calculo la magnitud del nuevo vector
        mag_input = math.sqrt(x^2 + y^2)
        -- Si la magnitud del vector es mayor a la magnitud de la velocidad
        if mag_input < mag_vel then
            self.vel.x = x
            self.vel.y = y
        else
            self.vel.x = 0
            self.vel.y = 0
        end
    end
    -- Move
    self.body:setLinearVelocity(self.vel.x, self.vel.y)
end

function Player.draw(self)
    local x, y = self.body:getPosition()
    love.graphics.rectangle('fill', 16, 16, x-8, y-8)
end

function Player.getPosition(self)
    return self.body:getPosition()
end

return Player