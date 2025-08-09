local letterbox = require("../../../letterbox")

local shader_aberrations

local canvas = {
	"main",
	"aberrations",
	"ctr",
	"convination",
}

local texts = {
	"No shader",
	"Aberrations shader",
	"Ctr shader",
	"Aberrations shader + crt shader",
}

local colors = {
	{ love.math.colorFromBytes(0xda, 0x5d, 0x86) },
	{ love.math.colorFromBytes(0x1e, 0x86, 0xbe) },
	{ love.math.colorFromBytes(0x25, 0xb7, 0x86) },
	{ love.math.colorFromBytes(0x25, 0xaa, 0xe1) },
}

local heart = love.graphics.newImage("heart.png")
local hsx = 30 / heart:getWidth()
local hsy = 30 / heart:getHeight()

local logo = love.graphics.newImage("logo.png")
local lx = (800 - logo:getWidth()) / 2
local ly = (600 - logo:getHeight()) / 2

local selected = 0

local t = 1
local time = 0

function love.load()
	love.window.setMode(800, 600)
	letterbox.init(800, 600)

	local shader_ctr = love.filesystem.read("ctr.glsl")
	shader_ctr = love.graphics.newShader(shader_ctr)
	shader_ctr:send("iResolution", { 800, 600 })
	letterbox.add_rig("ctr", shader_ctr)

	shader_aberrations = love.filesystem.read("aberrations.glsl")
	shader_aberrations = love.graphics.newShader(shader_aberrations)
	shader_aberrations:send("time", time)
	letterbox.add_rig("aberrations", shader_aberrations)

	letterbox.add_rig("convination", { shader_aberrations, shader_ctr })
end

function love.update(dt)
	time = time + dt
	t = t + dt
	if t > 0.5 and love.keyboard.isDown("space") then
		t = 0
		selected = math.fmod(selected + 1, #canvas)
	end
	shader_aberrations:send("time", love.timer.getTime())
end

function love.draw()
	letterbox.start(canvas[selected + 1])
	love.graphics.clear(love.math.colorFromBytes(0xb1, 0xe3, 0xfa))
	for x = 0, 40 do
		for y = 0, 30 do
			local offset = math.fmod(x + y, #colors)
			local sin = math.sin(time + ((math.pi * (offset / 4)) / 2)) * 10
			love.graphics.setColor(colors[offset + 1])
			love.graphics.draw(heart, x * 40 + 5, y * 40 + 5 + sin, 0, hsx, hsy)
		end
	end
	love.graphics.setColor(0, 0, 0)
	love.graphics.draw(logo, lx, ly)
	love.graphics.setColor(1, 1, 1)

	letterbox.finish()

	love.graphics.clear()
	letterbox.present(canvas[selected + 1])
	love.graphics.setColor(love.math.colorFromBytes(0xda, 0x5d, 0x86))
	love.graphics.rectangle("fill", 280, 5, 240, 40, 15)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", 280, 5, 240, 40, 15)
	love.graphics.printf(texts[selected + 1], 0, 17, 800, "center")
	love.graphics.setColor(1, 1, 1)
end
