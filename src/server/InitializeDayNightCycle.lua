--[[
	Initialize Day/Night Cycle
	This script starts the day/night cycle system when the game begins

	Place this script in ServerScriptService in Roblox Studio
]]

-- Get the DayNightCycleManager module
local DayNightCycleManager = require(script.Parent.DayNightCycleManager)

-- Wait a moment for the game to fully initialize
task.wait(2)

-- Start the cycle
print("[InitializeDayNightCycle] Starting day/night cycle...")
DayNightCycleManager.Start()
print("[InitializeDayNightCycle] Day/night cycle started successfully!")
