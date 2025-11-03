--[[
	MainServer.lua
	Main server entry point - Connects all systems
	SIMPLE, CLEAN, OPTIMIZED
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for modules to load with error handling
print("Loading modules...")

local function safeRequire(module, name)
	local success, result = pcall(function()
		return require(module)
	end)
	if success then
		print("✓", name, "loaded")
		return result
	else
		warn("✗ Failed to load", name, ":", result)
		warn("   Expected path:", module:GetFullName())
		return nil
	end
end

local DataManager = safeRequire(script.Parent:WaitForChild("Core"):WaitForChild("DataManager"), "DataManager")
local RollingSystem = safeRequire(script.Parent:WaitForChild("Core"):WaitForChild("RollingSystem"), "RollingSystem")
local StealingSystem = safeRequire(script.Parent:WaitForChild("Core"):WaitForChild("StealingSystem"), "StealingSystem")
local BaseManager = safeRequire(script.Parent:WaitForChild("Systems"):WaitForChild("BaseManager"), "BaseManager")
local RebirthHandler = safeRequire(script.Parent:WaitForChild("Systems"):WaitForChild("RebirthHandler"), "RebirthHandler")
local StatsManager = safeRequire(script.Parent:WaitForChild("Leaderboards"):WaitForChild("StatsManager"), "StatsManager")
local BrainrotData = safeRequire(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotData"), "BrainrotData")
local Config = safeRequire(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"), "Config")

-- OPTIONAL: BrainrotModelReplicator (for 3D viewport feature)
local BrainrotModelReplicator = nil
local replicatorModule = script.Parent:FindFirstChild("Systems") and script.Parent.Systems:FindFirstChild("BrainrotModelReplicator")
if replicatorModule then
	BrainrotModelReplicator = safeRequire(replicatorModule, "BrainrotModelReplicator")
else
	warn("⚠️ BrainrotModelReplicator not found - 3D viewport feature disabled (rolling still works with static images)")
end

-- Verify CRITICAL modules loaded (BrainrotModelReplicator is optional)
if not (DataManager and RollingSystem and StealingSystem and BaseManager and RebirthHandler and StatsManager and BrainrotData and Config) then
	error("❌ Critical modules failed to load! Check the Output above for details.")
end

-- Create Events folder
local eventsFolder = Instance.new("Folder")
eventsFolder.Name = "Events"
eventsFolder.Parent = ReplicatedStorage

-- Create RemoteEvents
local remoteEvents = {
	-- Client → Server
	RollBrainrot = Instance.new("RemoteEvent"),
	KeepBrainrot = Instance.new("RemoteEvent"),
	SkipBrainrot = Instance.new("RemoteEvent"),
	ProcessRebirth = Instance.new("RemoteEvent"),
	ToggleAutoRoll = Instance.new("RemoteEvent"),
	ToggleFastRoll = Instance.new("RemoteEvent"),

	-- Server → Client
	RollResult = Instance.new("RemoteEvent"),
	UpdateServerLuck = Instance.new("RemoteEvent"),
	SendNotification = Instance.new("RemoteEvent"),
	StealAlert = Instance.new("RemoteEvent"),
}

-- Create RemoteFunctions
local remoteFunctions = {
	GetPlayerData = Instance.new("RemoteFunction"),
	GetIndexData = Instance.new("RemoteFunction"),
	GetRebirthStatus = Instance.new("RemoteFunction"),
}

-- Parent all remotes
for name, remote in pairs(remoteEvents) do
	remote.Name = name
	remote.Parent = eventsFolder
end

for name, remote in pairs(remoteFunctions) do
	remote.Name = name
	remote.Parent = eventsFolder
end

print("✓ RemoteEvents created")

-- ==================== SERVER HANDLERS ====================

-- Handle roll request
remoteEvents.RollBrainrot.OnServerEvent:Connect(function(player)
	-- Rate limit check (simple)
	local character = player.Character
	if not character then return end

	-- Calculate luck
	local luck = RollingSystem.CalculateLuck(player)

	-- Roll brainrot
	local result = RollingSystem.RollBrainrot(luck)

	if result then
		-- Increment rolls
		DataManager.IncrementRolls(player)

		-- Send result to client
		remoteEvents.RollResult:FireClient(player, result)
	end
end)

-- Handle keep brainrot
remoteEvents.KeepBrainrot.OnServerEvent:Connect(function(player, brainrotID, frame)
	-- Validate
	if not brainrotID or not frame then return end

	-- Check if player has space
	local hasSpace, floor, padNumber = DataManager.HasAvailablePad(player)

	if hasSpace then
		-- Assign to pad
		DataManager.AssignToPad(player, floor, padNumber, brainrotID, frame)
		BaseManager.PlaceBrainrot(player, floor, padNumber, brainrotID, frame)

		-- Notify client
		remoteEvents.SendNotification:FireClient(player, "Added to base!", "Success")
	else
		-- No space - would show replacement GUI here
		remoteEvents.SendNotification:FireClient(player, "Base is full!", "Error")
	end
end)

-- Handle skip brainrot
remoteEvents.SkipBrainrot.OnServerEvent:Connect(function(player)
	-- Just acknowledge, nothing to do
	print(player.Name, "skipped a brainrot")
end)

-- Handle rebirth request
remoteEvents.ProcessRebirth.OnServerEvent:Connect(function(player)
	local success, message = RebirthHandler.ProcessRebirth(player)

	if success then
		remoteEvents.SendNotification:FireClient(player, message, "Success")
	else
		remoteEvents.SendNotification:FireClient(player, message, "Error")
	end
end)

-- Handle auto roll toggle
remoteEvents.ToggleAutoRoll.OnServerEvent:Connect(function(player, enabled)
	local data = DataManager.GetData(player)
	if data then
		data.ActivePerks.AutoRoll = enabled
		print(player.Name, "toggled AutoRoll:", enabled)
	end
end)

-- Handle fast roll toggle
remoteEvents.ToggleFastRoll.OnServerEvent:Connect(function(player, enabled)
	local data = DataManager.GetData(player)
	if data then
		data.ActivePerks.FastRoll = enabled
		print(player.Name, "toggled FastRoll:", enabled)
	end
end)

-- ==================== REMOTE FUNCTIONS ====================

-- Get player data
remoteFunctions.GetPlayerData.OnServerInvoke = function(player)
	return DataManager.GetData(player)
end

-- Get index data
remoteFunctions.GetIndexData.OnServerInvoke = function(player)
	local data = DataManager.GetData(player)
	if data then
		return data.Index
	end
	return {}
end

-- Get rebirth status
remoteFunctions.GetRebirthStatus.OnServerInvoke = function(player)
	local canRebirth, message = RebirthHandler.CanRebirth(player)
	local collected, total = RebirthHandler.GetProgress(player)

	return {
		CanRebirth = canRebirth,
		Message = message,
		Collected = collected,
		Total = total,
		Progress = collected / total
	}
end

-- ==================== INITIALIZATION ====================

-- Initialize systems
print("Initializing systems...")

-- OPTIONAL: Replicate brainrot models to ReplicatedStorage for client ViewportFrames
if BrainrotModelReplicator then
	BrainrotModelReplicator.Init()
else
	warn("⚠️ Skipping model replication - BrainrotModelReplicator not loaded")
end

StealingSystem.Init()
StatsManager.Init()
print("✓ Systems initialized")

-- Player added handler (load base)
Players.PlayerAdded:Connect(function(player)
	-- Wait for data to load
	local profile = DataManager.GetProfile(player)
	if profile then
		task.wait(1) -- Small delay for workspace to load

		-- Load base from data
		local data = DataManager.GetData(player)
		if data then
			BaseManager.LoadBase(player, data)
		end
	end
end)

print("✓ MainServer loaded successfully!")
