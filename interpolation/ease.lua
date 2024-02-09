local function linear(percent)
	return percent
end

local function quadraticIn(percent)
	return percent * percent
end

local function quadraticOut(percent)
	return -(percent - 1) * (percent - 1) + 1
end

local function quadraticInOut(percent)
	if percent < 0.5 then
		return 2 * percent * percent
	else
		return -2 * (percent - 1) * (percent - 1) + 1
	end
end

local function cubicIn(percent)
	return percent * percent * percent
end

local function cubicOut(percent)
	return (percent - 1) * (percent - 1) * (percent - 1) + 1
end

local function cubicInOut(percent)
	if percent < 0.5 then
		return 4 * percent * percent * percent
	else
		return 4 * (percent - 1) * (percent - 1) * (percent - 1) + 1
	end
end

local function quarticIn(percent)
	return percent * percent * percent * percent
end

local function quarticOut(percent)
	return -(percent - 1) * (percent - 1) * (percent - 1) * (percent - 1) + 1
end

local function quarticInOut(percent)
	if percent < 0.5 then
		return 8 * percent * percent * percent * percent
	else
		return -8 * (percent - 1) * (percent - 1) * (percent - 1) * (percent - 1) + 1
	end
end

local function quinticIn(percent)
	return percent * percent * percent * percent * percent
end

local function quinticOut(percent)
	return (percent - 1) * (percent - 1) * (percent - 1) * (percent - 1) * (percent - 1) + 1
end

local function quinticInOut(percent)
	if percent < 0.5 then
		return 16 * percent * percent * percent * percent * percent
	else
		return 16 * (percent - 1) * (percent - 1) * (percent - 1) * (percent - 1) * (percent - 1) + 1
	end
end

local function sineIn(percent)
	return math.sin((percent - 1) * math.pi / 2) + 1
end

local function sineOut(percent)
	return math.sin(percent * (math.pi / 2))
end

local function sineInOut(percent)
	return -0.5 * (math.cos(math.pi * percent) - 1)
end

local function circularIn(percent)
	return 1 - math.sqrt(1 - percent * percent)
end

local function circularOut(percent)
	return math.sqrt(1 - (percent - 1) * (percent - 1))
end

local function circularInOut(percent)
	if percent < 0.5 then
		return 0.5 * (1 - math.sqrt(1 - 4 * percent * percent))
	else
		return 0.5 * (math.sqrt(-((2 * percent) - 3) * ((2 * percent) - 1)) + 1)
	end
end

local function exponentialIn(percent)
	return math.pow(2, 10 * percent - 10)
end

local function exponentialOut(percent)
	return 1 - math.pow(2, -10 * percent)
end

local function exponentialInOut(percent)
	if percent < 0.5 then
		return 0.5 * math.pow(2, 20 * percent - 10)
	else
		return 1 - 0.5 * math.pow(2, -20 * percent + 10)
	end
end

local function easeInBack(percent)
	local c1 = 1.70158
	local c2 = c1 + 1
	return c2 * percent * percent * percent - c1 * percent * percent
end

local function easeOutBack(percent)
	local c1 = 1.70158
	local c2 = c1 + 1
	return 1 + c2 * (percent - 1) * (percent - 1) * (percent - 1) + c1 * (percent - 1) * (percent - 1)
end

local function easeInOutBack(percent)
	local c1 = 1.70158
	local c2 = c1 * 1.525
	if percent < 0.5 then
		return 0.5 * ((2 * percent) * (2 * percent) * ((c2 + 1) * 2 * percent - c2))
	else
		return 0.5 * ((2 * percent - 2) * (2 * percent - 2) * ((c2 + 1) * (percent * 2 - 2) + c2) + 2)
	end
end

local function easeInElastic(percent)
	local c = (2 * math.pi) / 3
	return -math.pow(2, 10 * percent - 10) * math.sin((percent * 10 - 10.75) * c)
end

local function easeOutElastic(percent)
	local c = (2 * math.pi) / 3
	return math.pow(2, -10 * percent) * math.sin((percent * 10 - 0.75) * c) + 1
end

local function easeInOutElastic(percent)
	local c = (2 * math.pi) / 4.5
	if percent < 0.5 then
		return -0.5 * math.pow(2, 20 * percent - 10) * math.sin((20 * percent - 11.125) * c)
	else
		return math.pow(2, -20 * percent + 10) * math.sin((20 * percent - 11.125) * c) * 0.5 + 1
	end
end

local function easeOutBounce(percent)
	if percent < 1 / 2.75 then
		return 7.5625 * percent * percent
	elseif percent < 2 / 2.75 then
		percent = percent - 1.5 / 2.75
		return 7.5625 * percent * percent + 0.75
	elseif percent < 2.5 / 2.75 then
		percent = percent - 2.25 / 2.75
		return 7.5625 * percent * percent + 0.9375
	else
		percent = percent - 2.625 / 2.75
		return 7.5625 * percent * percent + 0.984375
	end
end

local function easeInBounce(percent)
	return 1 - easeOutBounce(1 - percent)
end

local function easeInOutBounce(percent)
	if percent < 0.5 then
		return 0.5 * easeInBounce(percent * 2)
	else
		return 0.5 * easeOutBounce(percent * 2 - 1) + 0.5
	end
end

return {
	linear = linear,
	quadraticIn = quadraticIn,
	quadraticOut = quadraticOut,
	quadraticInOut = quadraticInOut,
	cubicIn = cubicIn,
	cubicOut = cubicOut,
	cubicInOut = cubicInOut,
	quarticIn = quarticIn,
	quarticOut = quarticOut,
	quarticInOut = quarticInOut,
	quinticIn = quinticIn,
	quinticOut = quinticOut,
	quinticInOut = quinticInOut,
	sineIn = sineIn,
	sineOut = sineOut,
	sineInOut = sineInOut,
	circularIn = circularIn,
	circularOut = circularOut,
	circularInOut = circularInOut,
	exponentialIn = exponentialIn,
	exponentialOut = exponentialOut,
	exponentialInOut = exponentialInOut,
	easeInBack = easeInBack,
	easeOutBack = easeOutBack,
	easeInOutBack = easeInOutBack,
	easeInElastic = easeInElastic,
	easeOutElastic = easeOutElastic,
	easeInOutElastic = easeInOutElastic,
	easeInBounce = easeInBounce,
	easeOutBounce = easeOutBounce,
	easeInOutBounce = easeInOutBounce,
}
