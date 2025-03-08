---@class letterbox.Upscale.PixelPerfect: letterbox.Upscale.Base
---@field type 'pixel-perfect' The type of upscale mode.
---@field parent letterbox.Rectangle The parent rectangle to which this upscale method applies.

---@class letterbox.Rig.PixelPerfect: letterbox.Rig
---@field parent letterbox.Rectangle The parent rectangle to which this rig belongs.
---@field reCalculateVariables fun(self: letterbox.Rig.PixelPerfect) Recalculates the rig's variables to maintain the correct aspect ratio.
---@field parentResizeCallback fun(self: letterbox.Rig.PixelPerfect, parentNewSize: letterbox.Rectangle) Callback function triggered when the parent's size changes. Recalculates the rig's variables to maintain the correct aspect ratio.

---@param self letterbox.Rig.PixelPerfect
---@param parent letterbox.Rectangle
local function parentResizeCallback(self, parent)
	self.parent = parent
	self:reCalculateVariables()
end

---@param self letterbox.Rig.PixelPerfect
local function reCalculateVariables(self)
	local newScaleFactor = math.min(self.parent.width / self.size.width, self.parent.height / self.size.height)
	if newScaleFactor > 1 then
		newScaleFactor = math.floor(newScaleFactor)
	else
		newScaleFactor = math.floor(newScaleFactor * 10) / 10
	end
	self.scale.x = newScaleFactor
	self.scale.y = newScaleFactor
	local new_width = self.size.width * newScaleFactor
	local new_height = self.size.height * newScaleFactor
	self.offset.x = (self.parent.width - new_width) / 2
	self.offset.y = (self.parent.height - new_height) / 2
end

---@param baseRig letterbox.Rig
---@param upscale letterbox.Upscale.PixelPerfect
---@return letterbox.Rig.PixelPerfect
local function newPixelPerfect(baseRig, upscale)
	---@type letterbox.Rig.PixelPerfect
	---@diagnostic disable-next-line: assign-type-mismatch
	local pixelPerfect = baseRig
	pixelPerfect.parent = upscale.parent
	pixelPerfect.reCalculateVariables = reCalculateVariables
	pixelPerfect.parentResizeCallback = parentResizeCallback
	pixelPerfect:reCalculateVariables()

	return pixelPerfect
end

return newPixelPerfect
