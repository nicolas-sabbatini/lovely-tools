require("globals")

function love.resize(w, h)
	PUSH:resize(w, h)
end

function love.focus(f)
	IN_FOCUS = f
end

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	PUSH:setupScreen(GAME_WIDTH, GAME_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true,
	})
end

function love.update(dt) end

function love.draw()
	love.graphics.clear(0.0, 0.0, 0.0)
	PUSH:start()
	love.graphics.clear(1.0, 1.0, 1.0)
	PUSH:finish()
end
