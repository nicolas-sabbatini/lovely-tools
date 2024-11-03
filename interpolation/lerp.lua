local ease = require("ease")

local Lerp = {
	_LICENSE = "MIT License - Copyright (c) 2024",
	_URL = "https://github.com/nicolas-sabbatini/lovely-tools",
	_VERSION = "v1.0.1",
	easeFunction = ease,
}

---Aplies the lerp function to the current lerp object
---@param percent number - The percentage of the lerp
---`If the percentage is greater than 1.0, the lerp will move to the next target`
---@return number - The interpolated value
local function lerp(self, percent)
	percent = percent - ((self.iter - 1) * (#self.targets - 1) + (self.currentTarget - 1))
	if percent >= 1.0 then
		if self.currentTarget < #self.targets - 1 then
			self.currentTarget = self.currentTarget + 1
		elseif self.repeatLerp then
			self.currentTarget = 1
			self.iter = self.iter + 1
		else
			return self.targets[self.currentTarget]
		end
		percent = 0.0
	end
	return self.targets[self.currentTarget]
		+ (self.targets[self.currentTarget + 1] - self.targets[self.currentTarget]) * self.easeFunction(percent)
end

---Creates a new lerp object
---@param targets number[]: A list of all the targets the lerp will interpolate to
---@param easeFunction any: The easeFunction to use for the lerp (linear by default)
---@param repeatLerp boolean: Whether or not the lerp should repeat (false by default)
---@return any: The new lerp object
function Lerp.new(targets, easeFunction, repeatLerp)
	assert(#targets > 1, "Lerp.new: targets must have at least 2 elements")
	return {
		currentTarget = 1,
		targets = targets,
		easeFunction = easeFunction or Lerp.easeFunction.linear,
		repeatLerp = repeatLerp or false,
		iter = 1,
		lerp = lerp,
	}
end

return Lerp
