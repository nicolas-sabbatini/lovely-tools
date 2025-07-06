--- Tape.lua - A flexible and easy-to-use logging library for LÖVE2D games.
---
--- This library provides a set of functions for logging messages to the console,
--- a file, or both. It supports different log levels, formatted messages,
--- assertion checks, and convenient table and call counting utilities.
---
--- module Tape
--- @author Nicolas Sabbatini
--- @copyright 2025, Nicolas Sabbatini
--- @license MIT License
--- @version 1.0.1

local logFile = "log.log"
local logLevel = 3
local logOutput = "all"

local labels = {}

--- @enum (key) Tape.Level
--- Defines the severity levels for log messages.
--- Higher numbers indicate more verbose logging.
local LogLevel = {
	error = 1, -- Critical errors that prevent normal operation.
	warning = 2, -- Issues that don't prevent operation but should be addressed.
	debug = 3, -- Detailed information for debugging purposes.
}

--- @enum (key) Tape.Output
--- Defines the available output destinations for log messages.
local LogOutput = {
	--- Outputs log messages to both the console and the log file.
	all = function(message)
		print(message)
		love.filesystem.append(logFile, message .. "\r\n")
	end,
	--- Outputs log messages only to the log file.
	file = function(message)
		love.filesystem.append(logFile, message .. "\r\n")
	end,
	--- Outputs log messages only to the console (standard output).
	console = function(message)
		print(message)
	end,
}

--- ANSI escape codes for coloring console output.
--- These colors are applied to the log level header in the console.
local colors = {
	error = "\27[31;1m", -- Red and bold
	warning = "\27[33;1m", -- Yellow and bold
	debug = "\27[34;1m", -- Blue and bold
}

--- @class Tape
Tape = {
	_LICENSE = "MIT License - Copyright (c) 2024",
	_URL = "https://github.com/nicolas-sabbatini/lovely-tools",
	_VERSION = "v1.0.1",
}

--- Records any number of arguments to the currently configured output.
--- Each argument is converted to a string and separated by a tab.
---
--- @param ... any Any number of values to be recorded.
--- @usage
--- `Tape.record("This is a simple record.", 123, true)`
function Tape.record(...)
	local logMessage = ""
	for _, v in ipairs({ ... }) do
		logMessage = logMessage .. tostring(v) .. "\t"
	end
	LogOutput[logOutput](logMessage)
end

--- Initializes the Tape logging library.
--- Sets up the logging output, file path, minimum log level, and file buffering.
--- If the specified log file does not exist and the output is not 'console',
--- it will be created in LÖVE2D's save directory.
---
--- @param output Tape.Output | nil Where to record the logs.
---                                 Defaults to `"all"` (console and file).
--- @param path string | nil The file name for saving logs.
---                          This file is created inside the game's save directory.
---                          Defaults to `"log.log"`.
--- @param level Tape.Level | nil The minimum log level to be recorded.
---                               Messages with a lower severity will be ignored.
---                               Defaults to `"debug"`.
--- @param mode "full"|"line"|"no"|nil Sets the buffering mode for the output file.
---                                     Refer to `io.stdout:setvbuf` for details.
---                                     Defaults to `"no"` (unbuffered).
--- @usage
--- `Tape.init("file", "game_logs.txt", "warning", "line")`
--- `Tape.init("console", nil, "error")`
function Tape.init(output, path, level, mode)
	logOutput = output or "all"
	logFile = path or "log.log"
	-- Ensure the level is a valid key for LogLevel before accessing.
	logLevel = LogLevel[level] or LogLevel.debug
	io.stdout:setvbuf(mode or "no")

	-- Create log file if output involves file logging and it doesn't exist.
	if logOutput ~= "console" then
		local pathOfFileDir = love.filesystem.getRealDirectory(logFile)
		local pathOfSaveDir = love.filesystem.getSaveDirectory()
		local exists = pathOfFileDir ~= nil and pathOfFileDir == pathOfSaveDir

		if not exists then
			love.filesystem.newFile(logFile)
		end
	end
end

--- Records a new log entry with a specified level and formatted message.
--- The message is formatted using `string.format` and includes a timestamp
--- and colored level header (for console output).
--- Messages with a level lower than the configured `logLevel` will be ignored.
---
--- @param level Tape.Level The severity level of the log entry.
--- @param message string The format string for the log message, similar to `string.format`.
--- @param ... any Values to format the string with.
--- @usage
--- `Tape.log("error", "Failed to load asset: %s", "player.png")`
--- `Tape.log("debug", "Player position: X=%d, Y=%d", player.x, player.y)`
function Tape.log(level, message, ...)
	-- Only log if the message's level is equal to or higher than the current logLevel.
	if not LogLevel[level] or logLevel < LogLevel[level] then
		return
	end
	-- Construct the header with color codes and timestamp.
	local header = string.format("%s[%s - %s]\27[0m ", colors[level], level, os.date("%H:%M:%S"))
	local formatMessage = string.format(message, ...)
	Tape.record(header, formatMessage)
end

--- Logs a debug message.
--- This is a convenience function equivalent to `Tape.log("debug", ...)`.
---
--- @param message string The format string for the log message.
--- @param ... any Values to format the string with.
--- @usage
--- `Tape.debug("Current FPS: %d", love.timer.getFPS())`
function Tape.debug(message, ...)
	Tape.log("debug", message, ...)
end

--- Logs a warning message.
--- This is a convenience function equivalent to `Tape.log("warning", ...)`.
---
--- @param message string The format string for the log message.
--- @param ... any Values to format the string with.
--- @usage
--- `Tape.warning("Deprecated function called: %s", "old_function()")`
function Tape.warning(message, ...)
	Tape.log("warning", message, ...)
end

--- Logs an error message.
--- This is a convenience function equivalent to `Tape.log("error", ...)`.
---
--- @param message string The format string for the log message.
--- @param ... any Values to format the string with.
--- @usage
--- `Tape.error("Critical error: %s", "Network disconnected")`
function Tape.error(message, ...)
	Tape.log("error", message, ...)
end

--- Asserts a condition, logging an error and halting the program if the condition is false.
--- This function is useful for debugging and validating critical assumptions.
--- If the `condition` is false, it records the error message along with a traceback
--- to the log output and then raises a Lua error, stopping script execution.
---
--- @param condition boolean The condition to test. If false, an error is triggered.
--- @param message string The error message to record and display if the condition is false.
--- @usage
--- `Tape.assert(player ~= nil, "Player object must exist!")`
--- `Tape.assert(type(config) == "table", "Configuration must be a table.")`
function Tape.assert(condition, message)
	if not condition then
		local logMessage = string.format(
			"\27[41;1m[Assert - %s]\27[0m %s\r\n", -- Red background, bold
			os.date("%H:%M:%S"),
			debug.traceback(tostring(message)) -- Include a traceback for better debugging
		)
		Tape.record(logMessage)
		error(message) -- Halts the program
	end
end

--- Clears the contents of the log file.
--- If the configured `logOutput` is `"console"`, this function does nothing.
--- If the file is successfully removed, a new empty log file is created.
--- A debug message is logged upon successful file deletion.
---
--- @usage
--- `Tape.clear()`-- Clears the log.log file
function Tape.clear()
	if logOutput == "console" then
		return
	end
	local success = love.filesystem.remove(logFile)
	if success then
		-- Recreate the file immediately after removal to ensure it exists for subsequent writes.
		---@diagnostic disable-next-line: redefined-local
		local success, err = love.filesystem.newFile(logFile)
		if success then
			Tape.log("debug", "Log file '%s' cleared and recreated.", logFile)
		else
			Tape.log("error", "Failed to recreate log file '%s' after clearing: %s", logFile, err)
		end
	else
		Tape.log("error", "Failed to clear log file '%s'.", logFile)
	end
end

--- Records the number of times this line (with a given label) has been called.
--- The internal counter for the `label` increments with each call.
--- If a `level` is provided and is not nil or lower than the current `logLevel`,
--- a log message displaying the count is generated.
---
--- @param label string The unique label to identify and track the count for.
--- @param level Tape.Level | nil The log level for displaying the count message.
---                               If `nil`, the count increments silently without logging.
---                               If its severity is lower than the current `logLevel`,
---                               the message will not be displayed, but the count still increments.
--- @usage
--- `Tape.count("Update Loop Calls", "debug")`
--- `Tape.count("Player Jumped")` -- Increments silently
function Tape.count(label, level)
	-- Initialize label count if it doesn't exist.
	if not labels[label] then
		labels[label] = 0
	end
	labels[label] = labels[label] + 1

	-- Log the count only if a level is provided.
	if level then
		Tape.log(level, "[Count] %s: %d", label, labels[label])
	end
end

--- Logs a table in a human-readable, pretty-printed format.
--- **Warning:** This function does not handle recursive tables and will crash
--- if a recursive table is passed as an argument due to infinite recursion.
---
--- @param level Tape.Level The log level for this table entry.
--- @param tbl table The table to be logged.
--- @usage
--- `local myTable = {
---     name = "Example",
---     id = 123,
---     data = { a = 1, b = "hello" }
--- }
--- Tape.table("debug", myTable)`
function Tape.table(level, tbl)
	local function tableToString(var, indent, parentIndent)
		if type(var) == "table" then
			local base = "{\r\n"
			for k, v in pairs(var) do
				local keyStr = tostring(k)
				base = base .. indent .. keyStr .. " = " .. tableToString(v, indent .. "\t", indent) .. ",\r\n"
			end
			return base .. parentIndent .. "}"
		end
		if type(var) == "string" then
			return string.format('"%s"', var)
		end
		return tostring(var)
	end

	-- Initial call with root table and base indentation.
	Tape.log(level, tableToString(tbl, "\t", ""))
end
