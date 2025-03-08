--[[
letterbox.lua v0.3.0

The MIT License (MIT)

Copyright (c) 2024 Nicolás Sabbatini

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

---@class letterbox.Rectangle
---@field width number The width of the rectangle.
---@field height number The height of the rectangle.

---@alias letterbox.PostProcessing love.Shader[] A list of post-processing effects.

---@alias letterbox.Vector {x: number, y: number} An `x`, `y` pair

local function uuid()
	return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function(c)
		local v = (c == "x") and love.math.random(0, 0xf) or love.math.random(8, 0xb)
		return string.format("%x", v)
	end)
end

local modules = (...) and (...):gsub("%.init$", "") .. "." or ""

local newBase = require(modules .. "base")
local newNormal = require(modules .. "normal")
local newPixelPerfect = require(modules .. "pixel-perfect")
local newConstatnt = require(modules .. "constant")

local letterbox = {
	_LICENSE = "MIT License - Copyright (c) 2024",
	_URL = "https://github.com/nicolas-sabbatini/lovely-tools",
	_VERSION = "v0.3.0",
}

---Creates a new camera rig
---@overload fun(upscale: letterbox.Upscale.Normal, name?: string, renderPriority?: number): letterbox.Rig.Normal
---@overload fun(upscale: letterbox.Upscale.PixelPerfect, name?: string, renderPriority?: number): letterbox.Rig.PixelPerfect
---@overload fun(upscale: letterbox.Upscale.Constant, name?: string, renderPriority?: number): letterbox.Rig.Constant
---@overload fun(upscale: letterbox.Upscale.Base, name?: string, renderPriority?: number): letterbox.Rig
function letterbox.newLetterbox(upscale, name, renderPriority)
	local n = name or uuid()
	local rp = renderPriority or 9999
	local base = newBase(upscale, n, rp)
	if upscale.type and upscale.type == "normal" then
		return newNormal(base, upscale)
	elseif upscale.type and upscale.type == "pixel-perfect" then
		return newPixelPerfect(base, upscale)
	elseif upscale.type and upscale.type == "constant" then
		return newConstatnt(base, upscale)
	end
	return base
end

return letterbox
