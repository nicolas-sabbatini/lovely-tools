---@class letterbox.Upscale.Base
---@field size letterbox.Rectangle
---@field postProcessing letterbox.PostProcessing?

---@class letterbox.Rig
---@field addChildren fun(self: letterbox.Rig, children: letterbox.Rig) Adds a child rig to the current rig.
---@field children letterbox.Rig[] The list of child rigs.
---@field draw fun(self: letterbox.Rig) Draws the current rig and its children on the screen.
---@field drawInsideRig fun(self: letterbox.Rig) Starts drawing inside the rig. The next draw call will modify the internal canvas of the rig. After making all desired modifications, you must call `stopDrawInsideRig`.
---@field drawPipeline letterbox.PostProcessing A list of all post-processing effects applied when the rig is drawn.
---@field name string The name of the rig.
---@field offset letterbox.Vector The offset of the rig.
---@field popPostProcessing fun(self: letterbox.Rig): love.Shader Removes and returns the last post-processing effect from the draw pipeline.
---@field pushPostProcessing fun(self: letterbox.Rig, shader: love.Shader) Adds a new post-processing effect to the end of the draw pipeline.
---@field removeChildren fun(self: letterbox.Rig, childName: string): letterbox.Rig? Removes a child rig by name. If the child does not exist, the function does nothing and returns `nil`.
---@field renderPriority number The render priority of this rig compared to its siblings. Higher values mean the rig is rendered later. By default, it is 9999
---@field resize fun(self: letterbox.Rig, newSize: letterbox.Rectangle) Resizes the rig to match the specified `newSize`
---@field scale letterbox.Vector The scale of the rig.
---@field size letterbox.Rectangle The size of the rig.
---@field sortChildren fun(self: letterbox.Rig) Sorts children according to their `renderPriority`.
---@field stopDrawInsideRig fun(self: letterbox.Rig) Stops drawing inside the rig. This function should be called after `drawInsideRig`.
---@field swapchainBack love.Canvas The back buffer of the swapchain.
---@field swapchainFront love.Canvas The front buffer of the swapchain.
---@field parentResizeCallback fun(self: letterbox.Rig, parentNewSize: letterbox.Rectangle) | nil Callback function triggered when the parent's size changes. If defined, it updates the rig's properties to adapt to the new parent size. This function may be `nil` if resizing is not applicable.

---@param self letterbox.Rig
local function draw(self)
	local current_render_target = love.graphics.getCanvas()
	local current_shader = love.graphics.getShader()
	love.graphics.setCanvas(self.swapchainBack)
	love.graphics.setShader()
	for _, child in ipairs(self.children) do
		child:draw()
	end
	for _, shader in pairs(self.drawPipeline) do
		love.graphics.setCanvas(self.swapchainFront)
		love.graphics.setShader(shader)
		love.graphics.draw(self.swapchainBack)
		local h = self.swapchainBack
		self.swapchainBack = self.swapchainFront
		self.swapchainFront = h
	end
	love.graphics.setCanvas(current_render_target)
	love.graphics.setShader(current_shader)
	love.graphics.push()
	love.graphics.translate(self.offset.x, self.offset.y)
	love.graphics.scale(self.scale.x, self.scale.y)
	love.graphics.draw(self.swapchainBack)
	love.graphics.pop()
end

---@param self letterbox.Rig
local function drawInsideRig(self)
	love.graphics.push()
	love.graphics.setCanvas(self.swapchainBack)
end

local function stopDrawInsideRig(_)
	love.graphics.pop()
	love.graphics.setCanvas()
end

---@param self letterbox.Rig
---@param child letterbox.Rig
local function addChildren(self, child)
	table.insert(self.children, child)
	self:sortChildren()
end

---@param self letterbox.Rig
local function sortChildren(self)
	table.sort(self.children, function(a, b)
		return a.renderPriority < b.renderPriority
	end)
end

---@param self letterbox.Rig
---@param childrenName string
---@return letterbox.Rig | nil
local function removeChildren(self, childrenName)
	for k, v in pairs(self.children) do
		if v.name == childrenName then
			return table.remove(self.children, k)
		end
	end
end

---@param self letterbox.Rig
---@param effect love.Shader
local function pushPostProcessing(self, effect)
	table.insert(self.drawPipeline, effect)
end

---@param self letterbox.Rig
---@return love.Shader | nil
local function popPostProcessing(self)
	return table.remove(self.drawPipeline)
end

---@param self letterbox.Rig
---@param newSize letterbox.Rectangle
local function resize(self, newSize)
	self.size = newSize
	self.swapchainBack = love.graphics.newCanvas(newSize.width, newSize.height)
	self.swapchainFront = love.graphics.newCanvas(newSize.width, newSize.height)
	for _, child in pairs(self.children) do
		if child.parentResizeCallback then
			child:parentResizeCallback(newSize)
		end
	end
end

---@param upscale letterbox.Upscale.Base
---@param name string
---@param renderPriority number
---@return letterbox.Rig
local function newBase(upscale, name, renderPriority)
	---@type letterbox.Rig
	local newRig = {
		addChildren = addChildren,
		children = {},
		draw = draw,
		drawInsideRig = drawInsideRig,
		drawPipeline = upscale.postProcessing or {},
		name = name,
		offset = { x = 0, y = 0 },
		popPostProcessing = popPostProcessing,
		pushPostProcessing = pushPostProcessing,
		removeChildren = removeChildren,
		renderPriority = renderPriority,
		scale = { x = 1, y = 1 },
		sortChildren = sortChildren,
		stopDrawInsideRig = stopDrawInsideRig,
		swapchainBack = love.graphics.newCanvas(upscale.size.width, upscale.size.height),
		swapchainFront = love.graphics.newCanvas(upscale.size.width, upscale.size.height),
		size = upscale.size,
		resize = resize,
		parentResizeCallback = nil,
	}
	return newRig
end

return newBase
