---@class letterbox.Upscale.Normal: letterbox.Upscale.Base
---@field type 'normal' The type of upscale mode.
---@field parent letterbox.Rectangle The parent rectangle to which this upscale method applies.

---@class letterbox.Rig.Normal: letterbox.Rig
---@field parent letterbox.Rectangle The parent rectangle to which this rig belongs.
---@field reCalculateVariables fun(self: letterbox.Rig.Normal) Recalculates the rig's variables to maintain the correct aspect ratio.
---@field parentResizeCallback fun(self: letterbox.Rig.Normal, parentNewSize: letterbox.Rectangle) Callback function triggered when the parent's size changes. Recalculates the rig's variables to maintain the correct aspect ratio.

---@param self letterbox.Rig.Normal
---@param parent letterbox.Rectangle
local function parentResizeCallback(self, parent)
	self.parent = parent
	self:reCalculateVariables()
end

---@param self letterbox.Rig.Normal
local function reCalculateVariables(self)
	local newScaleFactor = math.min(self.parent.width / self.size.width, self.parent.height / self.size.height)
	self.scale.x = newScaleFactor
	self.scale.y = newScaleFactor
	local newWidth = self.size.width * newScaleFactor
	local newHeight = self.size.height * newScaleFactor
	self.offset.x = (self.parent.width - newWidth) / 2
	self.offset.y = (self.parent.height - newHeight) / 2
end

---@param baseRig letterbox.Rig
---@param upscale letterbox.Upscale.Normal
---@return letterbox.Rig.Normal
local function newNormal(baseRig, upscale)
	---@type letterbox.Rig.Normal
	---@diagnostic disable-next-line: assign-type-mismatch
	local normal = baseRig
	normal.parent = upscale.parent
	normal.reCalculateVariables = reCalculateVariables
	normal.parentResizeCallback = parentResizeCallback
	normal:reCalculateVariables()

	return normal
end

return newNormal
