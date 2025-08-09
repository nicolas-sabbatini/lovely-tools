--[[
letterbox.lua v2.0.0

The MIT License (MIT)

Copyright (c) 2025 Nicolás Sabbatini

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

---@alias Letterbox.StretchMode 'letterbox' | 'pixel_perfect' | 'keep_width' | 'keep_height' | 'stretch'
---@alias Letterbox.Rig { canvas: love.Canvas, shaders: love.Shader[] }

---@type { [string]:  Letterbox.Rig}
local canvases = {}
---@type love.Canvas
local intermediate
---@type number, number, number, number
local offset_x, offset_y, scale_x, scale_y
---@type Letterbox.StretchMode
local mode = "letterbox"
---@type Letterbox.Rig | nil
local active = nil

--- Letterbox v2.0.0
--- This small library that provides a simple way to handle aspect ratio and resolution scaling
--- in Love2D games. It allows you to define a virtual resolution for your game and
--- then automatically handles scaling and positioning the game canvas to fit the
--- window, preserving the aspect ratio. It supports various scaling algorithms and
--- post-processing shaders.
---
--- GitHub: [https://github.com/nicolas-sabbatini/lovely-tools](https://github.com/nicolas-sabbatini/lovely-tools)
---
--- License: MIT License (c) 2025
---@class Letterbox
local letterbox = {
	_LICENSE = "MIT License - Copyright (c) 2025",
	_URL = "https://github.com/nicolas-sabbatini/lovely-tools",
	_VERSION = "v2.0.0",
}

--- Initializes the letterbox system with a base resolution and optional settings.
--- This should be called once, typically in `love.load()`.
---@param width number The virtual width of your game.
---@param height number The virtual height of your game.
---@param stretch_mode? Letterbox.StretchMode The scaling algorithm to use. Defaults to 'letterbox'.
---@param shaders? love.Shader | love.Shader[] A single shader or a list of shaders to apply to the main canvas.
function letterbox.init(width, height, stretch_mode, shaders)
	assert(not intermediate, "The system is already initialized")
	mode = stretch_mode or "letterbox"

	if type(shaders) ~= "table" then
		shaders = shaders and { shaders } or {}
	end
	canvases.main = { canvas = love.graphics.newCanvas(width, height), shaders = shaders }
	intermediate = love.graphics.newCanvas(width, height)

	local sw, sh = love.graphics.getDimensions()
	letterbox.resize(sw, sh)
end

--- Gets the current virtual width of the game canvas.
---@return number width The width of the canvas.
function letterbox.get_width()
	return intermediate:getWidth()
end

--- Gets the current virtual height of the game canvas.
---@return number height The height of the canvas.
function letterbox.get_height()
	return intermediate:getHeight()
end

--- Gets the current virtual dimensions of the game canvas.
---@return number width, number height The width and height of the canvas.
function letterbox.get_size()
	return intermediate:getDimensions()
end

--- Retrieves a specific canvas rig by its name.
---@param name string The name of the rig to retrieve.
---@return Letterbox.Rig rig The canvas rig.
function letterbox.get_canvas(name)
	return canvases[name]
end

--- Converts screen coordinates (e.g., mouse position) to game world coordinates.
---@param point_x number The x-coordinate on the screen.
---@param point_y number The y-coordinate on the screen.
---@return number x, number y The corresponding x and y coordinates in the game world.
function letterbox.to_game(point_x, point_y)
	local x = (point_x - offset_x) / scale_x
	local y = (point_y - offset_y) / scale_y
	return x, y
end

--- Converts game world coordinates to screen coordinates.
---@param point_x number The x-coordinate in the game world.
---@param point_y number The y-coordinate in the game world.
---@return number x, number y The corresponding x and y coordinates on the screen.
function letterbox.to_screen(point_x, point_y)
	local x = (point_x * scale_x) + offset_x
	local y = (point_y * scale_y) + offset_y
	return x, y
end

--- Recalculates the scale and offset based on the new window dimensions.
--- This should be called from `love.resize()`.
---@param new_width number The new width of the window.
---@param new_height number The new height of the window.
function letterbox.resize(new_width, new_height)
	local width, height = intermediate:getDimensions()

	if mode == "letterbox" or mode == "pixel_perfect" then
		local min_scale = math.min(new_width / width, new_height / height)
		if mode == "pixel_perfect" then
			if min_scale > 1 then
				min_scale = math.floor(min_scale)
			else
				min_scale = math.floor(min_scale * 10) / 10
			end
		end
		scale_x = min_scale
		scale_y = min_scale
	elseif mode == "keep_width" then
		local scale = new_width / width
		scale_x = scale
		scale_y = scale
	elseif mode == "keep_height" then
		local scale = new_height / height
		scale_x = scale
		scale_y = scale
	elseif mode == "stretch" then
		scale_x = new_width / width
		scale_y = new_height / height
	end

	offset_x = (new_width - (width * scale_x)) / 2
	offset_y = (new_height - (height * scale_y)) / 2
end

--- Resizes all managed canvases to a new virtual resolution.
---@param new_width number The new virtual width.
---@param new_height number The new virtual height.
function letterbox.set_size(new_width, new_height)
	intermediate = love.graphics.newCanvas(new_width, new_height)
	for key, _ in pairs(canvases) do
		canvases[key].canvas = love.graphics.newCanvas(new_width, new_height)
	end

	local sw, sh = love.graphics.getDimensions()
	letterbox.resize(sw, sh)
end

--- Changes the scaling algorithm and immediately applies it.
---@param stretch_mode Letterbox.StretchMode The new scaling algorithm to use.
function letterbox.set_stretch_mode(stretch_mode)
	mode = stretch_mode

	local sw, sh = love.graphics.getDimensions()
	letterbox.resize(sw, sh)
end

--- Starts rendering to a specified canvas. All subsequent drawing operations will be on this canvas.
--- This should be called at the beginning of `love.draw()`.
---@param name? string The name of the canvas rig to draw to. Defaults to "main".
function letterbox.start(name)
	assert(not active, "Can't start a drawing when another canvas is active.")
	name = name or "main"
	active = canvases[name]
	love.graphics.push()
	love.graphics.setCanvas(active.canvas)
end

--- Finishes the rendering process for the active canvas, applying any associated shaders.
--- This should be called after all game world drawing is done, but before `letterbox.present()`.
function letterbox.finish()
	assert(active, "Can't finish a drawing when there are no active canvas.")
	for _, shader in pairs(active.shaders) do
		love.graphics.setCanvas(intermediate)
		love.graphics.setShader(shader)
		love.graphics.clear()
		love.graphics.draw(active.canvas)
		local temp = intermediate
		intermediate = active.canvas
		active.canvas = temp
	end
	love.graphics.setShader()
	love.graphics.setCanvas()
	love.graphics.pop()
	active = nil
end

--- Draws the final, scaled canvas to the screen.
--- This should be the last drawing call in `love.draw()`.
---@param name? string The name of the canvas rig to present. Defaults to "main".
function letterbox.present(name)
	name = name or "main"
	love.graphics.draw(canvases[name].canvas, offset_x, offset_y, 0, scale_x, scale_y)
end

--- Adds a new canvas rig for multi-pass rendering or different drawing targets.
---@param name string A unique name for the new rig.
---@param shaders? love.Shader | love.Shader[] A single shader or a list of shaders for this rig.
function letterbox.add_rig(name, shaders)
	local width, height = intermediate:getDimensions()
	if type(shaders) ~= "table" then
		shaders = shaders and { shaders } or {}
	end
	canvases[name] = { canvas = love.graphics.newCanvas(width, height), shaders = shaders }
end

return letterbox
