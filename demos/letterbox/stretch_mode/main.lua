local letterbox = require("../../../letterbox")

local strech_mode = {
	"letterbox",
	"pixel_perfect",
	"keep_width",
	"keep_height",
	"stretch",
}

local selected = 0
local t = 1
local tmx, tmy = 0, 0
local cmx, cmy = 0, 0
local sx, sy = 0, 0

function love.resize(w, h)
	letterbox.resize(w, h)
end

function love.load()
	love.window.setMode(800, 600, {
		resizable = true,
	})

	letterbox.init(800, 600, strech_mode[selected + 1])
end

function love.update(dt)
	t = t + dt
	if t > 0.5 and love.keyboard.isDown("space") then
		t = 0
		selected = math.fmod(selected + 1, #strech_mode)
		letterbox.set_stretch_mode(strech_mode[selected + 1])
	end

	tmx, tmy = love.mouse.getPosition()
	cmx, cmy = letterbox.to_game(tmx, tmy)
	sx, sy = letterbox.to_screen(cmx, cmy)
end

function love.draw()
	letterbox.start()
	love.graphics.clear(love.math.colorFromBytes(0xb1, 0xe3, 0xfa))
	love.graphics.setColor(0, 0, 0)
	love.graphics.printf(strech_mode[selected + 1], 50, 250, 700, "center")
	love.graphics.printf("Press space to change the strech mode", 50, 300, 700, "center")
	love.graphics.setColor(1, 1, 1)

	letterbox.finish()

	love.graphics.clear()
	letterbox.present()

	love.graphics.setColor(love.math.colorFromBytes(0xda, 0x5d, 0x86))
	love.graphics.rectangle("fill", 0, 5, 240, 40 + 17 * 2, 15)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", 0, 5, 240, 40 + 17 * 2, 15)
	love.graphics.printf("mouse pos:" .. tostring(tmx) .. ":" .. tostring(tmy), 0, 17, 240, "center")
	love.graphics.printf(
		"canvas pos:" .. string.format("%d", cmx) .. ":" .. string.format("%d", cmy),
		0,
		17 * 2,
		240,
		"center"
	)
	love.graphics.printf(
		"screen pos:" .. string.format("%d", sx) .. ":" .. string.format("%d", sy),
		0,
		17 * 3,
		240,
		"center"
	)
	love.graphics.setColor(1, 1, 1)
end
