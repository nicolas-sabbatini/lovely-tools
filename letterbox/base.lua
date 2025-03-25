---@class letterbox.Upscale.Base
---@field size letterbox.Rectangle
---@field postProcessing letterbox.PostProcessing?
---@field renderPriority number?
---@field zoom number?
---@field look letterbox.Vector?

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
---@field renderPriority number The render priority of this rig compared to its siblings. Higher values mean the rig is rendered later. By default, it is 0
---@field resize fun(self: letterbox.Rig, newSize: letterbox.Rectangle) Resizes the rig to match the specified `newSize`
---@field scale letterbox.Vector The scale of the rig.
---@field size letterbox.Rectangle The size of the rig.
---@field sortChildren fun(self: letterbox.Rig) Sorts children according to their `renderPriority`.
---@field stopDrawInsideRig fun(self: letterbox.Rig, previus: love.Canvas?) Stops drawing inside the rig. This function should be called after `drawInsideRig`. It's sets the render target to previus.
---@field swapchainBack love.Canvas The back buffer of the swapchain.
---@field swapchainFront love.Canvas The front buffer of the swapchain.
---@field parentResizeCallback fun(self: letterbox.Rig, parentNewSize: letterbox.Rectangle) | nil Callback function triggered when the parent's size changes. If defined, it updates the rig's properties to adapt to the new parent size. This function may be `nil` if resizing is not applicable.
---@field zoom number The zoom level applied to the rig.
---@field zoomBy fun(self: letterbox.Rig, delta: number) Changes the zoom level by adding the `delta` value to its current value.
---@field look letterbox.Vector The position where the center of the camera is located.
---@field lookBy fun(self: letterbox.Rig, delta: letterbox.Vector) Moves the `look` position by adding the `delta` vector to its current value.
---@field parentToRigsWorld fun(self: letterbox.Rig, px: number, py: number): {name: string, coordinates: letterbox.Vector}[] Transforms the given `coordinates` from the parent's coordinate system into the local rig coordinate system.
---@field parentToRigsScreen fun(self: letterbox.Rig, px: number, py: number): {name: string, coordinates: letterbox.Vector}[] Transforms the given `coordinates` from the parent's screen coordinates into the local rig screen coordinates.

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
	love.graphics.scale(self.zoom, self.zoom)
	local offsetX = ((self.size.width / 2) / self.zoom) - self.look.x
	local offsetY = ((self.size.height / 2) / self.zoom) - self.look.y
	love.graphics.translate(offsetX, offsetY)
end

local function stopDrawInsideRig(_, previus)
	love.graphics.pop()
	love.graphics.setCanvas(previus)
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

---@param self letterbox.Rig
---@param delta letterbox.Vector
local function lookBy(self, delta)
	self.look.x = self.look.x + delta.x
	self.look.y = self.look.y + delta.y
end

---@param self letterbox.Rig
---@param delta number
local function zoomBy(self, delta)
	self.zoom = math.max(self.zoom + delta, 0.1)
end

---@param self letterbox.Rig
---@param px number
---@param py number
---@return {name: string, coordinates: letterbox.Vector}[]
local function parentToRigsWorld(self, px, py)
	local x = (px - self.offset.x) / self.scale.x
	local y = (py - self.offset.y) / self.scale.y
	if x < 0 or x > self.size.width or y < 0 or y > self.size.height then
		return {}
	end
	local localC = {
		name = self.name,
		coordinates = {
			x = ((x - self.size.width / 2) / self.zoom) + self.look.x,
			y = ((y - self.size.height / 2) / self.zoom) + self.look.y,
		},
	}
	for i = #self.children, 1, -1 do
		local cc = self.children[i]:parentToRigsWorld(x, y)
		if #cc ~= 0 then
			table.insert(cc, 1, localC)
			return cc
		end
	end
	return { localC }
end

---@param self letterbox.Rig
---@param px number
---@param py number
---@return {name: string, coordinates: letterbox.Vector}[]
local function parentToRigsScreen(self, px, py)
	local x = (px - self.offset.x) / self.scale.x
	local y = (py - self.offset.y) / self.scale.y
	if x < 0 or x > self.size.width or y < 0 or y > self.size.height then
		return {}
	end
	local localC = {
		name = self.name,
		coordinates = {
			x = x,
			y = y,
		},
	}
	for i = #self.children, 1, -1 do
		local cc = self.children[i]:parentToRigsScreen(x, y)
		if #cc ~= 0 then
			table.insert(cc, 1, localC)
			return cc
		end
	end
	return { localC }
end

---@param upscale letterbox.Upscale.Base
---@param name string
---@return letterbox.Rig
local function newBase(upscale, name)
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
		renderPriority = upscale.renderPriority or 0,
		scale = { x = 1, y = 1 },
		sortChildren = sortChildren,
		stopDrawInsideRig = stopDrawInsideRig,
		swapchainBack = love.graphics.newCanvas(upscale.size.width, upscale.size.height),
		swapchainFront = love.graphics.newCanvas(upscale.size.width, upscale.size.height),
		size = upscale.size,
		resize = resize,
		parentResizeCallback = nil,
		zoom = upscale.zoom or 1,
		zoomBy = zoomBy,
		look = upscale.look or { x = upscale.size.width / 2, y = upscale.size.height / 2 },
		lookBy = lookBy,
		parentToRigsWorld = parentToRigsWorld,
		parentToRigsScreen = parentToRigsScreen,
	}
	return newRig
end

return newBase
