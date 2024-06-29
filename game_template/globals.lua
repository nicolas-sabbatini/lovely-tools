-- Game settings
-- This is the default game windows size
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 608
-- This is the game size
-- Tile set 32x32 = 25x19
GAME_WIDTH = 800
GAME_HEIGHT = 608

-- On focus Variable
IN_FOCUS = false

-- Push library
PUSH = require("vendors/push")

function GET_MOUSE_POSITION()
	if not IN_FOCUS then
		return nil, nil
	end
	local x, y = love.mouse.getPosition()
	local p_x, p_y = PUSH:toGame(x, y)
	if not p_x and x < WINDOW_WIDTH / 2 then
		p_x = 0
	end
	if not p_x and x > WINDOW_WIDTH / 2 then
		p_x = GAME_WIDTH
	end
	if not p_y and y < WINDOW_HEIGHT / 2 then
		p_y = 0
	end
	if not p_y and y > WINDOW_HEIGHT / 2 then
		p_y = GAME_HEIGHT
	end
	return p_x, p_y
end

-- Camera
local camera = require("vendors.camera")

function SCREEN_TO_GAME_CAMERA(cam)
	if not IN_FOCUS then
		return nil, nil
	end
	local x, y = GET_MOUSE_POSITION()
	return cam:worldCoords(x, y, 0, 0, GAME_WIDTH, GAME_HEIGHT)
end

function ATTACH_GAME_CAMERA(cam)
	cam:attach(0, 0, GAME_WIDTH, GAME_HEIGHT, true)
end

function DETACH_GAME_CAMERA(cam)
	cam:detach()
end

function NEW_CAMERA()
	return camera.new(GAME_WIDTH, GAME_HEIGHT)
end
