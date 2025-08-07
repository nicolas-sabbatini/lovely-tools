--[[
pizza.lua v0.0.1

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

---@class pizza.slice
---@field cellWidth number Width of a single cell.
---@field cellHeight number Height of a single cell.
---@field minCellWidth number Minimum allowed width.
---@field minCellHeight number Minimum allowed height.
---@field source love.Image The image source for rendering.
---@field quads love.Quad[] Array of quads used for rendering.
---@field render fun(self: pizza.slice, x: number, y: number, width: number, height: number) Renders the slice at the given position.

local slice = {
	---Renders the slice at the specified position.
	---@param self pizza.slice
	---@param x number X-coordinate.
	---@param y number Y-coordinate.
	---@param width number
	---@param height number
	render = function(self, x, y, width, height)
		assert(width >= self.minCellWidth and height >= self.minCellHeight, "The render dimensions are too small.")

		local bg_scale_x = width / self.cellWidth
		local bg_scale_y = height / self.cellHeight
		local side_scale_x = (width - self.cellWidth * 2) / self.cellWidth
		local side_scale_y = (height - self.cellHeight * 2) / self.cellHeight
		local end_x = x + width - self.cellWidth
		local end_y = y + height - self.cellHeight

		-- Background
		love.graphics.draw(self.source, self.quads[5], x, y, 0, bg_scale_x, bg_scale_y)
		-- Sides
		love.graphics.draw(self.source, self.quads[2], x + self.cellWidth, y, 0, side_scale_x, 1)
		love.graphics.draw(self.source, self.quads[4], x, y + self.cellHeight, 0, 1, side_scale_y)
		love.graphics.draw(self.source, self.quads[8], x + self.cellWidth, end_y, 0, side_scale_x, 1)
		love.graphics.draw(self.source, self.quads[6], end_x, y + self.cellHeight, 0, 1, side_scale_y)
		-- Corners
		love.graphics.draw(self.source, self.quads[1], x, y)
		love.graphics.draw(self.source, self.quads[3], end_x, y)
		love.graphics.draw(self.source, self.quads[7], x, end_y)
		love.graphics.draw(self.source, self.quads[9], end_x, end_y)
	end,
}

---@class pizza
local pizza = {}

---Creates a slice from a texture.
---@param texture love.Image Source image.
---@return pizza.slice New slice object.
function pizza.fromTexture(texture)
	local w, h = texture:getDimensions()
	local cw, ch = math.floor(w / 3), math.floor(h / 3)
	local minW, minH = cw * 2, ch * 2
	local quads = {}
	for y = 0, 2 do
		for x = 0, 2 do
			table.insert(quads, love.graphics.newQuad(x * cw, y * ch, cw, ch, texture))
		end
	end

	local newSlice = {
		cellWidth = cw,
		cellHeight = ch,
		minCellWidth = minW,
		minCellHeight = minH,
		source = texture,
		quads = quads,
	}
	return setmetatable(newSlice, { __index = slice })
end

---Creates a slice from a specific rectangular area of a texture.
---@param texture love.Image Source image.
---@param tx number X position in the texture.
---@param ty number Y position in the texture.
---@param tw number Width of the section.
---@param th number Height of the section.
---@return pizza.slice New slice object.
function pizza.fromRec(texture, tx, ty, tw, th)
	local cw, ch = tw / 3, th / 3
	local minW, minH = cw * 2, ch * 2
	local quads = {}
	for y = 0, 2 do
		for x = 0, 2 do
			table.insert(quads, love.graphics.newQuad(tx + x * cw, ty + y * ch, cw, ch, texture))
		end
	end

	local newSlice = {
		cellWidth = cw,
		cellHeight = ch,
		minCellWidth = minW,
		minCellHeight = minH,
		source = texture,
		quads = quads,
	}
	return setmetatable(newSlice, { __index = slice })
end

return pizza
