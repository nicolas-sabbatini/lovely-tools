--[[
dice_bag.lua v0.0.1

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

local dice_bag = {}

--- Rolls an unknown type of dice a specified number of times.
---
--- This function simulates rolling a custom dice with a given range and optional bonus.
--- It returns the total sum of all rolls and a list of each individual roll result.
---
---@param min number The minimum possible value of the dice (inclusive).
---@param max number The maximum possible value of the dice (inclusive).
---@param bonus number? An optional bonus added to each roll. Defaults to 0 if not provided.
---@param amount number? The number of dice to roll. Defaults to 1 if not provided.
---@return number total The total sum of all rolls including bonuses.
---@return number[] rolls A list containing the result of each individual dice roll with bonuses applied.
---@throws error If the amount of dice is less than 1.
---@throws error If the max value is less than the min value.
function dice_bag.unknownDice(min, max, bonus, amount)
	local b = bonus or 0
	local a = amount or 1
	assert(min <= max, "Max value must be greater or equal than min")
	assert(a > 0, "You can't roll 0 or negative amounts of dice")
	local total = 0
	local rolls = {}
	for _ = 1, a do
		local roll = love.math.random(min, max) + b
		total = total + roll
		table.insert(rolls, roll)
	end
	return total, rolls
end

--- Rolls a specified number of fair d4 dice.
---
--- This function rolls four-sided dice with optional bonuses added to each roll.
--- It returns the total sum of all rolls and a list of each individual roll result.
---
---@param bonus number? An optional bonus added to each roll. Defaults to 0 if not provided.
---@param amount number? The number of dice to roll. Defaults to 1 if not provided.
---@return number total The total sum of all rolls including bonuses.
---@return number[] rolls A list containing the result of each individual dice roll with bonuses applied.
---@throws error If the amount of dice is less than 1.
function dice_bag.d4(bonus, amount)
	return dice_bag.unknownDice(1, 4, bonus, amount)
end

--- Rolls a specified number of fair d6 dice.
---
--- This function rolls six-sided dice with optional bonuses added to each roll.
--- It returns the total sum of all rolls and a list of each individual roll result.
---
---@param bonus number? An optional bonus added to each roll. Defaults to 0 if not provided.
---@param amount number? The number of dice to roll. Defaults to 1 if not provided.
---@return number total The total sum of all rolls including bonuses.
---@return number[] rolls A list containing the result of each individual dice roll with bonuses applied.
---@throws error If the amount of dice is less than 1.
function dice_bag.d6(bonus, amount)
	return dice_bag.unknownDice(1, 6, bonus, amount)
end

--- Rolls a specified number of fair d8 dice.
---
--- This function rolls eight-sided dice with optional bonuses added to each roll.
--- It returns the total sum of all rolls and a list of each individual roll result.
---
---@param bonus number? An optional bonus added to each roll. Defaults to 0 if not provided.
---@param amount number? The number of dice to roll. Defaults to 1 if not provided.
---@return number total The total sum of all rolls including bonuses.
---@return number[] rolls A list containing the result of each individual dice roll with bonuses applied.
---@throws error If the amount of dice is less than 1.
function dice_bag.d8(bonus, amount)
	return dice_bag.unknownDice(1, 8, bonus, amount)
end

--- Rolls a specified number of fair d10 dice.
---
--- This function rolls ten-sided dice with optional bonuses added to each roll.
--- It returns the total sum of all rolls and a list of each individual roll result.
---
---@param bonus number? An optional bonus added to each roll. Defaults to 0 if not provided.
---@param amount number? The number of dice to roll. Defaults to 1 if not provided.
---@return number total The total sum of all rolls including bonuses.
---@return number[] rolls A list containing the result of each individual dice roll with bonuses applied.
---@throws error If the amount of dice is less than 1.
function dice_bag.d10(bonus, amount)
	return dice_bag.unknownDice(1, 10, bonus, amount)
end

--- Rolls a specified number of fair d12 dice.
---
--- This function rolls twelve-sided dice with optional bonuses added to each roll.
--- It returns the total sum of all rolls and a list of each individual roll result.
---
---@param bonus number? An optional bonus added to each roll. Defaults to 0 if not provided.
---@param amount number? The number of dice to roll. Defaults to 1 if not provided.
---@return number total The total sum of all rolls including bonuses.
---@return number[] rolls A list containing the result of each individual dice roll with bonuses applied.
---@throws error If the amount of dice is less than 1.
function dice_bag.d12(bonus, amount)
	return dice_bag.unknownDice(1, 12, bonus, amount)
end

--- Rolls a specified number of fair d20 dice.
---
--- This function rolls twenty-sided dice with optional bonuses added to each roll.
--- It returns the total sum of all rolls and a list of each individual roll result.
---
---@param bonus number? An optional bonus added to each roll. Defaults to 0 if not provided.
---@param amount number? The number of dice to roll. Defaults to 1 if not provided.
---@return number total The total sum of all rolls including bonuses.
---@return number[] rolls A list containing the result of each individual dice roll with bonuses applied.
---@throws error If the amount of dice is less than 1.
function dice_bag.d20(bonus, amount)
	return dice_bag.unknownDice(1, 20, bonus, amount)
end

--- Rolls a specified number of fair d100 dice.
---
--- This function rolls one hundred sided dice with optional bonuses added to each roll.
--- It returns the total sum of all rolls and a list of each individual roll result.
---
---@param bonus number? An optional bonus added to each roll. Defaults to 0 if not provided.
---@param amount number? The number of dice to roll. Defaults to 1 if not provided.
---@return number total The total sum of all rolls including bonuses.
---@return number[] rolls A list containing the result of each individual dice roll with bonuses applied.
---@throws error If the amount of dice is less than 1.
function dice_bag.d100(bonus, amount)
	return dice_bag.unknownDice(1, 100, bonus, amount)
end

return dice_bag
