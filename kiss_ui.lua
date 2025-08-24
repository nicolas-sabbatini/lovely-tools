---@alias layout_direction "bottom_top" | "left_right" | "right_left" | "top_bottom"

---@alias sizing_mod.fit_content {t: "fit_content"}
---@alias sizing_mod.fixed {t: "fixed", size: number}
---@alias sizing_mod.grow {t: "grow", min?: number, max?: number}
---@alias sizing_mod sizing_mod.fit_content | sizing_mod.fixed | sizing_mod.grow

---@alias sizing { width: sizing_mod, height: sizing_mod }

---@alias edges { left: number, top: number, right: number, bottom: number }

---@class ui_component
---@field parent ui_component?
---@field children ui_component[]
---@field child_gap number
---@field layout layout_direction
---@field padding edges
---@field sizing sizing
---@field text string|table
---@field text_align love.AlignMode
---@field font love.Font
---@field background_color table
---@field line_color table
---@field corner_radius number
---@field update fun(self: ui_component, x_mouse: number, y_mouse: number)?
---@field custom_draw fun(self: ui_component)?
---@field size { width: number, height: number }
---@field position { x: number, y: number }
---@field is_hover boolean

---@class ui_component.configuration
---@field child_gap number?
---@field layout layout_direction?
---@field padding edges?
---@field sizing sizing?
---@field text string|table|nil
---@field text_align love.AlignMode?
---@field font love.Font?
---@field background_color table?
---@field line_color table?
---@field corner_radius number?
---@field update fun(self: ui_component, x_mouse: number, y_mouse: number)?
---@field custom_draw fun(self: ui_component)?

---@param component ui_component
local function draw_tree(component)
	if component.custom_draw then
		component:custom_draw()
	else
		love.graphics.setColor(component.background_color)
		love.graphics.rectangle(
			"fill",
			component.position.x,
			component.position.y,
			component.size.width,
			component.size.height,
			component.corner_radius,
			component.corner_radius,
			1000
		)
		love.graphics.setColor(component.line_color)
		love.graphics.rectangle(
			"line",
			component.position.x,
			component.position.y,
			component.size.width,
			component.size.height,
			component.corner_radius,
			component.corner_radius,
			1000
		)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(
			component.text,
			component.font,
			component.position.x + component.padding.left,
			component.position.y + component.padding.top,
			component.size.width - component.padding.right - component.padding.left,
			component.text_align
		)
	end
	for _, child in ipairs(component.children) do
		draw_tree(child)
	end
end

---@param component ui_component
local function calculate_min_size_width(component)
	if component.sizing.width.t == "fixed" then
		component.size.width = component.sizing.width.size
	elseif component.sizing.width.t == "fit_content" or component.sizing.width.t == "grow" then
		local end_size = component.padding.right + component.padding.left
		if #component.children > 0 then
			if component.layout == "left_right" or component.layout == "right_left" then
				end_size = end_size + (component.child_gap * (#component.children - 1))
				for _, child in ipairs(component.children) do
					end_size = end_size + child.size.width
				end
			else
				local max = 0
				for _, child in ipairs(component.children) do
					max = math.max(max, child.size.width)
				end
				end_size = end_size + max
			end
		end
		component.size.width = end_size
	end

	if component.text then
		component.size.width = math.max(
			component.size.width,
			component.font:getWidth("M") + component.padding.left + component.padding.right
		)
	end

	if component.sizing.width.t == "grow" and component.sizing.width.min then
		if component.sizing.width.min then
			---@diagnostic disable-next-line: assign-type-mismatch
			component.size.width = component.size.width > component.sizing.width.min and component.size.width
				or component.sizing.width.min
		else
			component.sizing.width.min = component.size.width
		end
	end
end

---@param component ui_component
local function calculate_max_size_width(component)
	if #component.children == 0 then
		return
	end
	if component.layout == "left_right" or component.layout == "right_left" then
		local grow = {}
		local remaining_width = component.size.width
			- component.padding.left
			- component.padding.right
			- (component.child_gap * (#component.children - 1))
		for _, child in ipairs(component.children) do
			remaining_width = remaining_width - child.size.width
			if child.sizing.width.t == "grow" then
				table.insert(grow, child)
			end
		end
		-- IEEE 754 64-bit binary format error 0.001 is small enough
		while remaining_width > 0.001 and #grow > 0 do
			local small = grow[1].size.width
			local second_small = 999999999999
			local add_width = remaining_width
			for _, v in ipairs(grow) do
				if v.size.width < small then
					second_small = small
					small = v.size.width
				elseif v.size.width > small then
					second_small = v.size.width
					add_width = second_small - small
				end
			end
			add_width = math.min(add_width, remaining_width / #grow)
			local remove = {}
			for i, v in ipairs(grow) do
				if v.size.width == small then
					local limit = v.sizing.width.max and v.sizing.width.max or 999999999999
					if v.size.width + add_width > limit then
						remaining_width = remaining_width - (v.sizing.width.max - v.size.width)
						v.size.width = v.sizing.width.max
						table.insert(remove, 1, i)
					else
						v.size.width = v.size.width + add_width
						remaining_width = remaining_width - add_width
					end
				end
			end
			for _, v in ipairs(remove) do
				table.remove(grow, v)
			end
		end
	else
		local max_width = component.size.width - component.padding.left - component.padding.right
		for _, child in ipairs(component.children) do
			if child.sizing.width.t == "grow" then
				child.size.width = child.sizing.width.max and math.min(child.sizing.width.max, max_width) or max_width
			end
		end
	end

	for _, child in ipairs(component.children) do
		calculate_max_size_width(child)
	end
end

---@param component ui_component
local function calculate_min_size_height(component)
	for _, child in ipairs(component.children) do
		calculate_min_size_height(child)
	end
	if component.sizing.height.t == "fixed" then
		component.size.height = component.sizing.height.size
	elseif component.sizing.height.t == "fit_content" or component.sizing.height.t == "grow" then
		local end_size = component.padding.top + component.padding.bottom
		if #component.children > 0 then
			if component.layout == "top_bottom" or component.layout == "bottom_top" then
				end_size = end_size + (component.child_gap * (#component.children - 1))
				for _, child in ipairs(component.children) do
					end_size = end_size + child.size.height
				end
			else
				local max = 0
				for _, child in ipairs(component.children) do
					max = math.max(max, child.size.height)
				end
				end_size = end_size + max
			end
		end
		component.size.height = end_size
	end

	if component.text then
		local text = component.text
		if type(component.text) == "table" then
			text = ""
			---@diagnostic disable-next-line: param-type-mismatch
			for k, v in ipairs(component.text) do
				if math.fmod(k, 2) == 0 then
					text = text .. v
				end
			end
		end
		---@diagnostic disable-next-line: param-type-mismatch
		local width = component.font:getWidth(text)
		local height = component.font:getHeight() * (component.font:getLineHeight() + 0.1)
		local total_text_height = (
			math.ceil(width / (component.size.width - component.padding.left - component.padding.right)) * height
		)
			+ component.padding.top
			+ component.padding.bottom
		component.size.height = math.max(component.size.height, total_text_height)
	end

	if component.sizing.height.t == "grow" then
		if component.sizing.height.min then
			---@diagnostic disable-next-line: assign-type-mismatch
			component.size.height = component.size.height > component.sizing.height.min and component.size.height
				or component.sizing.height.min
		else
			component.sizing.height.min = component.size.height
		end
		if component.sizing.height.max then
			component.size.height = component.size.height > component.sizing.height.max and component.sizing.height.max
				or component.size.height
		end
	end
end

---@param component ui_component
local function calculate_max_size_height(component)
	if #component.children == 0 then
		return
	end
	if component.layout == "top_bottom" or component.layout == "bottom_top" then
		local grow = {}
		local remaining_height = component.size.height
			- component.padding.top
			- component.padding.bottom
			- (component.child_gap * (#component.children - 1))
		for _, child in ipairs(component.children) do
			remaining_height = remaining_height - child.size.height
			if child.sizing.height.t == "grow" then
				table.insert(grow, child)
			end
		end
		-- IEEE 754 64-bit binary format error 0.001 is small enough
		while remaining_height > 0.001 and #grow > 0 do
			local small = grow[1].size.height
			local second_small = 999999999999
			local add_height = remaining_height
			for _, v in ipairs(grow) do
				if v.size.height < small then
					second_small = small
					small = v.size.height
				elseif v.size.height > small then
					second_small = v.size.height
					add_height = second_small - small
				end
			end
			add_height = math.min(add_height, remaining_height / #grow)
			local remove = {}
			for i, v in ipairs(grow) do
				if v.size.height == small then
					local limit = v.sizing.height.max and v.sizing.height.max or 999999999999
					if v.size.height + add_height > limit then
						remaining_height = remaining_height - (v.sizing.height.max - v.size.height)
						v.size.height = v.sizing.height.max
						table.insert(remove, 1, i)
					else
						v.size.height = v.size.height + add_height
						remaining_height = remaining_height - add_height
					end
				end
			end
			for _, v in ipairs(remove) do
				table.remove(grow, v)
			end
		end
	else
		local max_height = component.size.height - component.padding.top - component.padding.bottom
		for _, child in ipairs(component.children) do
			if child.sizing.height.t == "grow" then
				child.size.height = child.sizing.height.max and math.min(child.sizing.height.max, max_height)
					or max_height
			end
		end
	end

	for _, child in ipairs(component.children) do
		calculate_max_size_height(child)
	end
end

---@param component ui_component
---@param origin_x number
---@param origin_y number
---@return number, number
local function calculate_child_origin(component, origin_x, origin_y)
	if component.layout == "left_right" or component.layout == "top_bottom" then
		return origin_x + component.padding.left, origin_y + component.padding.top
	elseif component.layout == "right_left" then
		local child_offset = component.children[1] and component.children[1].size.width or 0
		return origin_x + component.size.width - component.padding.left - child_offset, origin_y + component.padding.top
	elseif component.layout == "bottom_top" then
		local child_offset = component.children[1] and component.children[1].size.height or 0
		return origin_x + component.padding.left,
			origin_y + component.size.height - component.padding.bottom - child_offset
	else
		error("Unknown layout direction")
	end
end

---@param component ui_component
---@param child_index number
---@param child_x number
---@param child_y number
---@return number, number
local function add_gap(component, child_index, child_x, child_y)
	if component.layout == "left_right" then
		child_x = child_x + component.children[child_index].size.width + component.child_gap
	elseif component.layout == "right_left" then
		local child_width = component.children[child_index + 1] and component.children[child_index + 1].size.width or 0
		child_x = child_x - child_width - component.child_gap
	elseif component.layout == "top_bottom" then
		child_y = child_y + component.children[child_index].size.height + component.child_gap
	elseif component.layout == "bottom_top" then
		local child_height = component.children[child_index + 1] and component.children[child_index + 1].size.height
			or 0
		child_y = child_y - child_height - component.child_gap
	else
		error("Unknown layout direction")
	end
	return child_x, child_y
end

---@param component ui_component
---@param origin_x number
---@param origin_y number
local function calculate_positions(component, origin_x, origin_y, mouse_x, mouse_y)
	component.position.x = origin_x
	component.position.y = origin_y

	component.is_hover = mouse_x >= origin_x
		and mouse_x <= component.size.width + origin_x
		and mouse_y >= origin_y
		and mouse_y <= component.size.height + origin_y

	if component.update then
		component:update(mouse_x, mouse_y)
	end

	local child_x, child_y = calculate_child_origin(component, origin_x, origin_y)
	for i, child in ipairs(component.children) do
		calculate_positions(child, child_x, child_y, mouse_x, mouse_y)
		child_x, child_y = add_gap(component, i, child_x, child_y)
	end
end

-- Ui tree functions
---@class ui_tree
---@field root ui_component?
---@field stack ui_component[]
---@field open fun(self: ui_tree, data: ui_component.configuration)
---@field close fun(self: ui_tree)
---@field calculate_layout fun(self: ui_tree, mouse_x: number, mouse_y: number)
---@field draw fun(self: ui_tree)

---@param self ui_tree
---@param data ui_component.configuration
local function open(self, data)
	table.insert(self.stack, {
		parent = self.stack[#self.stack] or nil,
		children = {},
		size = { width = 0, height = 0 },
		position = { x = 0, y = 0 },
		is_hover = false,
		-- config variables
		child_gap = data.child_gap or 0,
		layout = data.layout or "left_right",
		padding = data.padding or { left = 0, top = 0, right = 0, bottom = 0 },
		sizing = data.sizing or { width = { t = "fit_content" }, height = { t = "fit_content" } },
		text = data.text or "",
		text_align = data.text_align or "left",
		font = data.font or love.graphics.getFont(),
		background_color = data.background_color or { 1, 1, 1, 0 },
		line_color = data.line_color or { 1, 1, 1, 0 },
		corner_radius = data.corner_radius or 0,
		update = data.update or nil,
		custom_draw = data.custom_draw or nil,
	})
	if #self.stack == 1 then
		self.root = self.stack[1]
	else
		table.insert(self.stack[#self.stack - 1].children, self.stack[#self.stack])
		self.stack[#self.stack].parent = self.stack[#self.stack - 1]
	end
end

---@param self ui_tree
local function close(self)
	local closed = table.remove(self.stack, #self.stack)
	calculate_min_size_width(closed)
end

---@param self ui_tree
---@param mouse_x number
---@param mouse_y number
local function calculate_layout(self, mouse_x, mouse_y)
	if #self.stack > 0 then
		error("You must close all gui components before calculate the layout")
	end

	if self.root then
		calculate_max_size_width(self.root)
		calculate_min_size_height(self.root)
		calculate_max_size_height(self.root)
		calculate_positions(self.root, 0, 0, mouse_x, mouse_y)
	end
end

---@param self ui_tree
local function draw(self)
	if self.root then
		draw_tree(self.root)
	end
end

---@return ui_tree
local function new_tree()
	return {
		root = nil,
		stack = {},
		open = open,
		close = close,
		calculate_layout = calculate_layout,
		draw = draw,
	}
end

return new_tree
