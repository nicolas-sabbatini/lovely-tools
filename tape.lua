--[[
tape.lua v1.1.0

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

local logFile = "log.log"
local logLevel = 3
local logOutput = "all"

local labels = {}

--- Enumeration for log levels.
---@enum (key) Tape.Level
local LogLevel = {
	error = 1,
	warn = 2,
	debug = 3,
}

--- Enumeration for log output destinations.
---@enum (key) Tape.Output
local LogOutput = {
	all = function(message)
		print(message)
		love.filesystem.append(logFile, message)
	end,
	file = function(message)
		love.filesystem.append(logFile, message)
	end,
	console = function(message)
		print(message)
	end,
}

local colors = {
	error = "\27[31;1m",
	warn = "\27[33;1m",
	debug = "\27[34;1m",
}

Tape = {
	_LICENSE = "MIT License - Copyright (c) 2024",
	_URL = "https://github.com/nicolas-sabbatini/lovely-tools",
	_VERSION = "v1.0.0",
}

--- Logs a message with optional arguments.
---@param ... any Values to log.
function Tape.record(...)
	local logMessage = table.concat({ ... }, "\t") .. "\n"
	LogOutput[logOutput](logMessage)
end

--- Initializes the logging system.
---@param output Tape.Output|nil Log destination (default: "all").
---@param path string|nil File name for log storage (default: "log.log").
---@param level Tape.Level|nil Minimum log level to record (default: "debug").
---@param mode "full"|"line"|"no"|nil Buffering mode for output file (default: "no").
function Tape.init(output, path, level, mode)
	logOutput = output or "all"
	logFile = path or "log.log"
	logLevel = LogLevel[level] or LogLevel.debug
	io.stdout:setvbuf(mode or "no")

	if logOutput ~= "console" then
		local pathOfFileDir = love.filesystem.getRealDirectory(logFile)
		local pathOfSaveDir = love.filesystem.getSaveDirectory()
		if not (pathOfFileDir and pathOfFileDir == pathOfSaveDir) then
			love.filesystem.newFile(logFile)
		end
	end
end

--- Logs a formatted message at a given log level.
---@param level Tape.Level Log level.
---@param message string Format string.
---@param ... any Arguments for formatting.
function Tape.log(level, message, ...)
	if logLevel < LogLevel[level] then
		return
	end
	local header = string.format("%s[%s - %s]\27[0m ", colors[level], level, os.date("%H:%M:%S"))
	local formattedMessage = string.format(message, ...)
	Tape.record(header, formattedMessage)
end

--- Logs an assertion failure and halts execution if the condition is false.
---@param condition boolean Condition to assert.
---@param message string Error message.
function Tape.assert(condition, message)
	if not condition then
		local logMessage = string.format(
			"\27[41;1m[Assert - %s]\27[0m %s\r\n",
			os.date("%H:%M:%S"),
			debug.traceback(tostring(message))
		)
		Tape.record(logMessage)
		error(message)
	end
end

--- Clears the log file, if the output is not "console".
function Tape.clear()
	if logOutput == "console" then
		return
	end
	if love.filesystem.remove(logFile) then
		love.filesystem.newFile(logFile)
		Tape.log("debug", "Log file cleared")
	end
end

--- Records the number of times a label has been logged.
---@param label string Label to track.
---@param level Tape.Level|nil Optional log level.
function Tape.count(label, level)
	labels[label] = (labels[label] or 0) + 1
	if level then
		Tape.log(level, "[Count] %s %d", label, labels[label])
	end
end

local function tableToString(var, indent, parentIndent)
	if type(var) == "table" then
		local base = "{\n"
		for k, v in pairs(var) do
			base = base .. indent .. k .. " = " .. tableToString(v, indent .. "\t", indent) .. ",\n"
		end
		return base .. parentIndent .. "}"
	end
	return tostring(var)
end

--- Logs a table in a readable format.
---@param level Tape.Level Log level.
---@param table table Table to log.
function Tape.table(level, table)
	Tape.log(level, tableToString(table, "\t", ""))
end

--- Logs a debug message.
---@param message string Format string.
---@param ... any Arguments for formatting.
function Tape.debug(message, ...)
	Tape.log("debug", message, ...)
end

--- Logs an error message.
---@param message string Format string.
---@param ... any Arguments for formatting.
function Tape.error(message, ...)
	Tape.log("error", message, ...)
end

--- Logs a warning message.
---@param message string Format string.
---@param ... any Arguments for formatting.
function Tape.warn(message, ...)
	Tape.log("warn", message, ...)
end
