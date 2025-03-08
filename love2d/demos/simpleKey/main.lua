local font, time, color

-- Load the library.
local simpleKeyboard = require("../../simple_keyboard")
-- Create the instance.
local instance = simpleKeyboard.createInstance({ "up", "down", "left", "right" })

function love.load()
	font = love.graphics.newFont(50)
	love.graphics.setFont(font)
	time = 1
	color = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } }
end

-- Change the text color based on the key state.
local function colorF(k)
	-- If the ket is not bound, return a black color.
	if instance:isDown(k) == nil then
		return { 0, 0, 0 }
	-- If the key is down, return a green color.
	elseif instance:isDown(k) then
		return { 0, 1, 0 }
	-- If the key was just pressed, return a blue color.
	elseif instance:justPressed(k) then
		return { 0, 0, 1 }
	-- If the key was just released, return a white color.
	elseif instance:justReleased(k) then
		return { 1, 1, 1 }
	-- Else return a red color.
	else
		return { 1, 0, 0 }
	end
end

function love.update(dt)
	-- Update the input.
	instance:updateInput()

	-- unbind and bind the space key.
	time = time - dt
	if time < 0 then
		if instance:isDown("space") ~= nil then
			instance:keyUnbind("space")
		else
			instance:keyBind("space")
		end
		time = 1
	end

	-- Update the colors.
	color[1] = colorF("up")
	color[2] = colorF("down")
	color[3] = colorF("left")
	color[4] = colorF("right")
	color[5] = colorF("space")
end

function love.draw()
	love.graphics.setColor(color[1])
	love.graphics.print("up", 100, 50)
	love.graphics.setColor(color[2])
	love.graphics.print("down", 100, 100)
	love.graphics.setColor(color[3])
	love.graphics.print("left", 100, 150)
	love.graphics.setColor(color[4])
	love.graphics.print("right", 100, 200)
	love.graphics.setColor(color[5])
	love.graphics.print("Space", 100, 250)
end
