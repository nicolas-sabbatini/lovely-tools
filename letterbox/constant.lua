---@class letterbox.Upscale.Constant: letterbox.Upscale.Base
---@field type 'constant' The type of upscale mode.
---@field position letterbox.Vector The position of the rig.

---@class letterbox.Rig.Constant: letterbox.Rig
---@field move fun(self: letterbox.Rig.Constant, newPosition: letterbox.Vector) Moves the top-left corner of the rig to the specified coordinates (`x`, `y`).

---@param self letterbox.Rig.Constant
---@param newPosition letterbox.Vector
local function move(self, newPosition)
	self.offset = newPosition
end

---@param baseRig letterbox.Rig
---@param upscale letterbox.Upscale.Constant
---@return letterbox.Rig.Constant
local function newConstant(baseRig, upscale)
	---@type letterbox.Rig.Constant
	---@diagnostic disable-next-line: assign-type-mismatch
	local constant = baseRig
	constant.move = move
	constant.offset = upscale.position
	return constant
end

return newConstant
