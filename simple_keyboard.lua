--[[
simple_keyboard.lua v4.0.0

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

local keysPressed = {}
local keysJustPressed = {}
local keysJustReleased = {}
local mousePressed = { false, false, false }
local mouseJustPressed = {}
local mouseJustReleased = {}

---@class SimpleKeyboard.Keyboard
local keyboard = {}

---Binds one or more keys for tracking.
---After binding, their state will be tracked and accessible using `isDown`, `justPressed`, etc.
---This must be called before checking key states.
---@param keys love.KeyConstant | love.KeyConstant[] Key or list of keys to bind.
function keyboard.bind(keys)
	if not keys then
		return
	end
	if type(keys) ~= "table" then
		keys = { keys }
	end
	for _, k in pairs(keys) do
		keysPressed[k] = false
		keysJustReleased[k] = false
		keysJustPressed[k] = false
	end
end

---Unbinds one or more previously bound keys.
---@param keys love.KeyConstant | love.KeyConstant[] Key or list of keys to unbind.
function keyboard.unbind(keys)
	if not keys then
		return
	end
	if type(keys) ~= "table" then
		keys = { keys }
	end
	for _, k in pairs(keys) do
		keysPressed[k] = nil
		keysJustReleased[k] = nil
		keysJustPressed[k] = nil
	end
end

---Returns true if the key was just pressed this frame.
---Requires the key to have been bound with `bind`.
---@param key love.KeyConstant The key to check.
---@return boolean True if the key was just pressed.
function keyboard.justPressed(key)
	return keysJustPressed[key]
end

---Returns true if the key is currently being held down.
---Requires the key to have been bound with `bind`.
---@param key love.KeyConstant The key to check.
---@return boolean True if the key is down.
function keyboard.isDown(key)
	return keysPressed[key]
end

---Returns true if the key was just released this frame.
---Requires the key to have been bound with `bind`.
---@param key love.KeyConstant The key to check.
---@return boolean True if the key was just released.
function keyboard.justReleased(key)
	return keysJustReleased[key]
end

---@class SimpleKeyboard.Mouse
local mouse = {}

---Returns true if the mouse button was just pressed this frame.
---@param button number Mouse button index (1 = left, 2 = right, 3 = middle).
---@return boolean True if the button was just pressed.
function mouse.justPressed(button)
	return mouseJustPressed[button]
end

---Returns true if the mouse button is currently held down.
---@param button number Mouse button index (1 = left, 2 = right, 3 = middle).
---@return boolean True if the button is down.
function mouse.isDown(button)
	return mousePressed[button]
end

---Returns true if the mouse button was just released this frame.
---@param button number Mouse button index (1 = left, 2 = right, 3 = middle).
---@return boolean True if the button was just released.
function mouse.justReleased(button)
	return mouseJustReleased[button]
end

--- SimpleKeyboard v4.0.0
---
--- A lightweight and simple input tracking helper for Love2D that tracks keyboard
--- and mouse states, including "just pressed" and "just released" events.
---
--- GitHub: [https://github.com/nicolas-sabbatini/lovely-tools](https://github.com/nicolas-sabbatini/lovely-tools)
---
--- License: MIT License (c) 2025
---@class SimpleKeyboard
local SimpleKeyboard = {
	_LICENSE = "MIT License - Copyright (c) 2024",
	_URL = "https://github.com/nicolas-sabbatini/lovely-tools",
	_VERSION = "v4.0.0",
	keyboard = keyboard,
	mouse = mouse,
}

---Updates the state of all bound keys and mouse buttons.
---This function should be called once per frame, typically at the beginning of `love.update(dt)`.
function SimpleKeyboard.updateInput()
	for k, previous in pairs(keysPressed) do
		local current = love.keyboard.isDown(k)
		keysPressed[k] = current
		keysJustReleased[k] = previous and not current
		keysJustPressed[k] = not previous and current
	end
	for k, previous in pairs(mousePressed) do
		local current = love.mouse.isDown(k)
		mousePressed[k] = current
		mouseJustReleased[k] = previous and not current
		mouseJustPressed[k] = not previous and current
	end
end

return SimpleKeyboard
