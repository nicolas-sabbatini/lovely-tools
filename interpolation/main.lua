local ease = require("ease")
local lerp = require("lerp")

local current = 19
local animations = {}
local percent = 0.0
local changeCooldown = 0.5
local lerperX = lerp.new({ 300, 600 }, ease.linear, true)
local lerperY = lerp.new({ 200, 400 }, ease[animations[current]], true)

local lerperA = lerp.new({ 20, 400, 780, 20 }, lerp.easeFunction.easeInOutElastic, true)

function love.load()
	for name, _ in pairs(ease) do
		table.insert(animations, name)
	end
	table.sort(animations)
end

function love.update(dt)
	changeCooldown = changeCooldown + dt
	percent = percent + dt * 0.75

	if love.keyboard.isDown("n") and changeCooldown > 0.5 then
		current = current + 1
		changeCooldown = 0.0
		if current > #animations then
			current = 1
		end
		lerperY.easeFunction = ease[animations[current]]
	end
	if love.keyboard.isDown("p") and changeCooldown > 0.5 then
		current = current - 1
		changeCooldown = 0.0
		if current < 1 then
			current = #animations
		end
		lerperY.easeFunction = ease[animations[current]]
	end
end

local function drawTrajectory()
	love.graphics.setColor(0.0, 0.0, 1.0)
	for i = 1, 1000 do
		local x = 300 + i * 0.3
		local y = 200 + 200 * ease[animations[current]](i / 1000)
		love.graphics.circle("fill", x, y, 2)
	end
end

function love.draw()
	-- Draw axis
	love.graphics.setColor(1, 0.0, 0.0)
	love.graphics.line(300, 200, 300, 400)
	love.graphics.line(300, 400, 600, 400)

	drawTrajectory()

	-- Draw Ball
	love.graphics.setColor(0.1, 1.0, 0.0)
	local currentX = lerperX:lerp(percent)
	local currentY = lerperY:lerp(percent)
	love.graphics.circle("fill", currentX, currentY, 15)

	local currentA = lerperA:lerp(percent)
	love.graphics.circle("fill", currentA, 100, 15)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print("N to next animation", 10, 10)
	love.graphics.print("P to previous animation", 10, 30)
	love.graphics.print("Current: " .. animations[current] .. "  #" .. current, 10, 50)
end
