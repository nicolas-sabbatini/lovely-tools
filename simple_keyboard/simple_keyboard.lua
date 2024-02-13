local SimpleKeyboard = {
	_LICENSE = "MIT License - Copyright (c) 2024",
	_URL = "https://github.com/nicolas-sabbatini/lovely-tools",
	_VERSION = "v3.0.0",
}
SimpleKeyboard.__index = SimpleKeyboard

-- Create a new instance of simple keyboard.
-- @*param* `keys` (string or table) — The keys to bind.
-- @*return* `instance` — The new instance of simpleKey.
function SimpleKeyboard.createInstance(keys)
	local instance = setmetatable({
		keysPressed = {},
		keysJustPressed = {},
		keysJustReleased = {},
	}, SimpleKeyboard)
	instance:keyBind(keys)
	return instance
end

-- Check if a key is dawn, this key don't need to be bound.
-- This function is a wrapper for *love.keyboard.isDown(key)*.
-- @*param* `key` — The key to check.
-- @*return* `down` — True if the key is down, false if not.
function SimpleKeyboard:checkDown(key)
	return love.keyboard.isDown(key)
end

-- Bind a key or a table of keys to the instance.
-- @*param* `keys` (string or table) — The keys to bind.
function SimpleKeyboard:keyBind(keys)
	if not keys then
		return
	elseif type(keys) ~= "table" then
		keys = { keys }
	end
	for _, k in pairs(keys) do
		self.keysPressed[k] = false
		self.keysJustReleased[k] = false
		self.keysJustPressed[k] = false
	end
end

-- Unbind a key or a table of keys in the instance.
-- @*param* `keys` (string or table) — The keys to unbind.
function SimpleKeyboard:keyUnbind(keys)
	if not keys then
		return
	elseif type(keys) ~= "table" then
		keys = { keys }
	end
	for _, k in pairs(keys) do
		self.keysPressed[k] = nil
		self.keysJustReleased[k] = nil
		self.keysJustPressed[k] = nil
	end
end

-- Update the state of all bound keys.
function SimpleKeyboard:updateInput()
	for k, previus in pairs(self.keysPressed) do
		self.keysPressed[k] = love.keyboard.isDown(k)
		self.keysJustReleased[k] = previus and not self.keysPressed[k]
		self.keysJustPressed[k] = (not previus) and self.keysPressed[k]
	end
end

-- Return true if is the first frame the bound key is down.
-- @*param* `key` — The key to check.
-- @*return* `down` — True if the key is down, false if not.
function SimpleKeyboard:justPressed(key)
	return self.keysJustPressed[key]
end

-- Return true if a bound key is down.
-- @*param* `key` — The key to check.
-- @*return* `down` — True if the key is down, false if not.
function SimpleKeyboard:isDown(key)
	return self.keysPressed[key]
end

-- Return true if is the first frame the bound key is released.
-- @*param* `key` — The key to check.
-- @*return* `down` — True if the key is released, false if not.
function SimpleKeyboard:justReleased(key)
	return self.keysJustReleased[key]
end

return SimpleKeyboard
