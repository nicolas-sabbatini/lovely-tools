--[[
state_manager.lua v0.1.0

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

---@alias StateManager.StateNames 'onEnter'| 'onUpdate'| 'onDraw' | 'onLeave'

---@class StateManager.State
---@field enter fun(self: StateManager.State)
---@field update fun(self: StateManager.State, dt)
---@field draw fun(self: StateManager.State)
---@field leave fun(self: StateManager.State)
---@field bind fun(self: StateManager.State, state: StateManager.StateNames, fun: fun())
---@field private onEnter fun()[]
---@field private onUpdate fun()[]
---@field private onDraw fun()[]
---@field private onLeave fun()[]

local function enter(self)
	for _, fun in pairs(self.onEnter) do
		fun()
	end
end

local function update(self, dt)
	for _, fun in pairs(self.onUpdate) do
		fun(dt)
	end
end

local function draw(self)
	for _, fun in pairs(self.onDraw) do
		fun()
	end
end

local function leave(self)
	for _, fun in pairs(self.onLeave) do
		fun()
	end
end

local function bind(self, state, fun)
	table.insert(self[state], fun)
end

---@param onEnter fun()[] | nil
---@param onUpdate fun()[] | nil
---@param onDraw fun()[] | nil
---@param onLeave fun()[] | nil
---@return StateManager.State
local function new_state(onEnter, onUpdate, onDraw, onLeave)
	return {
		onEnter = onEnter or {},
		onUpdate = onUpdate or {},
		onDraw = onDraw or {},
		onLeave = onLeave or {},
		bind = bind,
		enter = enter,
		update = update,
		draw = draw,
		leave = leave,
	}
end

local state_manager = {
	states = {
		empty = new_state(),
	},
	current_state = "empty",
	_LICENSE = "MIT License - Copyright (c) 2024",
	_URL = "https://github.com/nicolas-sabbatini/lovely-tools",
	_VERSION = "v0.1.0",
}

---Creates a new state in the state manager
---@param name string
---@param onEnter fun()[] | nil
---@param onUpdate fun()[] | nil
---@param onDraw fun()[] | nil
---@param onLeave fun()[] | nil
function state_manager:add_state(name, onEnter, onUpdate, onDraw, onLeave)
	self.states[name] = new_state(onEnter, onUpdate, onDraw, onLeave)
end

---Add a function to the state
---@param name string
---@param state StateManager.StateNames
---@param fun fun()
function state_manager:bind(name, state, fun)
	self.states[name]:bind(state, fun)
end

---Change the current state and execute the required function
---@param name string
function state_manager:set_state(name)
	self.states[self.current_state]:leave()
	self.current_state = name
	self.states[name]:enter()
end

---Execute the update functions of the current state
---@param dt number
function state_manager:update(dt)
	self.states[self.current_state]:update(dt)
end

---Execute the update functions of the current state
function state_manager:draw()
	self.states[self.current_state]:draw()
end

return state_manager
