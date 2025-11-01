--[[
	Day/Night Cycle Manager
	Manages the day/night cycle system for the bunker survival game

	Features:
	- Day phase: 180 seconds (3 minutes)
	- Night phase: 300 seconds (5 minutes)
	- Day counter starting at 1
	- Automatic phase transitions
	- Player rewards and game events
	- Client notifications and warnings
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

-- Configuration
local DAY_DURATION = 180  -- 3 minutes
local NIGHT_DURATION = 300  -- 5 minutes
local DAY_CLOCKTIME = 12  -- Noon
local NIGHT_CLOCKTIME = 0  -- Midnight
local COINS_PER_DAY = 75  -- Coins awarded to alive players each day

-- State Variables
local CurrentPhase = "Day"  -- "Day" or "Night"
local CurrentDay = 1
local TimeRemaining = DAY_DURATION
local CycleRunning = false

-- RemoteEvents folder (create if it doesn't exist)
local DayNightEvents = ReplicatedStorage:FindFirstChild("DayNightEvents")
if not DayNightEvents then
	DayNightEvents = Instance.new("Folder")
	DayNightEvents.Name = "DayNightEvents"
	DayNightEvents.Parent = ReplicatedStorage
	print("[DayNightCycle] Created DayNightEvents folder in ReplicatedStorage")
end

-- Create RemoteEvents
local function createRemoteEvent(name)
	local existing = DayNightEvents:FindFirstChild(name)
	if existing then
		return existing
	end
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = DayNightEvents
	print("[DayNightCycle] Created RemoteEvent:", name)
	return remoteEvent
end

local PhaseChangeEvent = createRemoteEvent("PhaseChange")
local TimerUpdateEvent = createRemoteEvent("TimerUpdate")
local WarningEvent = createRemoteEvent("Warning")

-- Placeholder functions for game systems (to be implemented later)
local function awardCoinsToPlayer(player, amount)
	-- TODO: Implement coin system
	-- For now, just log it
	print(string.format("[DayNightCycle] Would award %d coins to %s", amount, player.Name))
end

local function repairBunker()
	-- TODO: Implement bunker repair system
	print("[DayNightCycle] Bunker repair triggered")
end

local function spawnFood()
	-- TODO: Implement food spawn system
	print("[DayNightCycle] Food spawn triggered")
end

local function removeAllFood()
	-- TODO: Implement food removal system
	-- This should remove all food items from the map
	print("[DayNightCycle] All food removed from map")
end

local function spawnMonsters()
	-- TODO: Implement monster spawn system
	print("[DayNightCycle] Monster spawn triggered")
end

-- Get all alive players
local function getAlivePlayers()
	local alivePlayers = {}
	for _, player in ipairs(Players:GetPlayers()) do
		-- TODO: Add actual alive check when health/death system is implemented
		-- For now, assume all players are alive
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			local humanoid = player.Character.Humanoid
			if humanoid.Health > 0 then
				table.insert(alivePlayers, player)
			end
		end
	end
	return alivePlayers
end

-- Start Day Phase
local function startDay()
	CurrentPhase = "Day"
	TimeRemaining = DAY_DURATION

	-- Set lighting to day
	Lighting.ClockTime = DAY_CLOCKTIME

	-- Award coins to all alive players
	local alivePlayers = getAlivePlayers()
	for _, player in ipairs(alivePlayers) do
		awardCoinsToPlayer(player, COINS_PER_DAY)
	end

	-- Trigger bunker repair
	repairBunker()

	-- Trigger food spawn
	spawnFood()

	-- Increment day counter
	CurrentDay = CurrentDay + 1

	-- Notify all clients
	PhaseChangeEvent:FireAllClients("Day", CurrentDay, TimeRemaining)

	print(string.format("[DayNightCycle] Day %d started - %d seconds", CurrentDay, DAY_DURATION))
end

-- Start Night Phase
local function startNight()
	CurrentPhase = "Night"
	TimeRemaining = NIGHT_DURATION

	-- Set lighting to night
	Lighting.ClockTime = NIGHT_CLOCKTIME

	-- Remove all food from map
	removeAllFood()

	-- Trigger monster spawn
	spawnMonsters()

	-- Notify all clients
	PhaseChangeEvent:FireAllClients("Night", CurrentDay, TimeRemaining)

	print(string.format("[DayNightCycle] Night %d started - %d seconds", CurrentDay, NIGHT_DURATION))
end

-- Send warning to all players
local function sendWarning(message, secondsRemaining)
	WarningEvent:FireAllClients(message, secondsRemaining)
	print(string.format("[DayNightCycle] Warning sent: %s (%d seconds)", message, secondsRemaining))
end

-- Main cycle loop
local function runCycle()
	if CycleRunning then
		warn("[DayNightCycle] Cycle is already running!")
		return
	end

	CycleRunning = true

	-- Initialize with Day 1
	CurrentDay = 0  -- Will be incremented to 1 in startDay()
	startDay()

	-- Main loop
	task.spawn(function()
		while CycleRunning do
			task.wait(1)  -- Update every second

			TimeRemaining = TimeRemaining - 1

			-- Send timer update to clients every second
			TimerUpdateEvent:FireAllClients(CurrentPhase, CurrentDay, TimeRemaining)

			-- Check for warnings (only before night)
			if CurrentPhase == "Day" then
				if TimeRemaining == 30 then
					sendWarning("Night is coming in 30 seconds!", 30)
				elseif TimeRemaining == 10 then
					sendWarning("Night is coming in 10 seconds!", 10)
				end
			end

			-- Check if phase is over
			if TimeRemaining <= 0 then
				if CurrentPhase == "Day" then
					startNight()
				else
					startDay()
				end
			end
		end
	end)

	print("[DayNightCycle] Cycle started successfully")
end

-- Stop the cycle
local function stopCycle()
	CycleRunning = false
	print("[DayNightCycle] Cycle stopped")
end

-- Public API
return {
	Start = runCycle,
	Stop = stopCycle,
	GetCurrentPhase = function() return CurrentPhase end,
	GetCurrentDay = function() return CurrentDay end,
	GetTimeRemaining = function() return TimeRemaining end,
}
