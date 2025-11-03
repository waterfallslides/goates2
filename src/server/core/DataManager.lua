--[[
	DataManager.lua
	Handles all player data using ProfileService
	SIMPLE, CLEAN, OPTIMIZED

	NOTE: Install ProfileService via Wally or copy the module to ServerScriptService
	Get it from: https://github.com/MadStudioRoblox/ProfileService
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Try to load ProfileService, fall back to mock if not found
local ProfileService
local profileServiceModule = ServerStorage:FindFirstChild("ProfileService")

if profileServiceModule then
	ProfileService = require(profileServiceModule)
	print("✓ ProfileService loaded")
else
	warn("⚠️ ProfileService not found! Using mock (NO DATA PERSISTENCE)")
	ProfileService = require(script.Parent.Parent.MockProfileService)
end

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local DataManager = {}
DataManager.Profiles = {}

-- ProfileStore
local ProfileStore = ProfileService.GetProfileStore(
	Config.DataStore.Name,
	Config.DefaultPlayerData
)

-- Load player data
function DataManager.LoadProfile(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill missing data

		profile:ListenToRelease(function()
			DataManager.Profiles[player] = nil
			player:Kick("Data session released")
		end)

		if player:IsDescendantOf(Players) then
			DataManager.Profiles[player] = profile
			DataManager.SetupLeaderstats(player, profile.Data)
			return profile
		else
			profile:Release()
		end
	else
		player:Kick("Failed to load data. Rejoin!")
	end

	return nil
end

-- Setup leaderstats
function DataManager.SetupLeaderstats(player, data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = data.Rebirths
	rebirths.Parent = leaderstats
end

-- Get player data
function DataManager.GetData(player)
	local profile = DataManager.Profiles[player]
	return profile and profile.Data or nil
end

-- Get profile
function DataManager.GetProfile(player)
	return DataManager.Profiles[player]
end

-- Save data manually
function DataManager.SaveData(player)
	local profile = DataManager.Profiles[player]
	if profile then
		-- Data auto-saves with ProfileService, but we can force reconcile
		profile:Reconcile()
		return true
	end
	return false
end

-- Update specific field
function DataManager.UpdateField(player, field, value)
	local data = DataManager.GetData(player)
	if data then
		data[field] = value

		-- Update leaderstats if it's Rebirths
		if field == "Rebirths" and player:FindFirstChild("leaderstats") then
			local rebirths = player.leaderstats:FindFirstChild("Rebirths")
			if rebirths then
				rebirths.Value = value
			end
		end

		return true
	end
	return false
end

-- Add to index
function DataManager.AddToIndex(player, brainrotID, frame)
	local data = DataManager.GetData(player)
	if data then
		local key = brainrotID .. "_" .. frame
		data.Index[key] = true
		return true
	end
	return false
end

-- Check if brainrot is in index
function DataManager.HasInIndex(player, brainrotID, frame)
	local data = DataManager.GetData(player)
	if data then
		local key = brainrotID .. "_" .. frame
		return data.Index[key] == true
	end
	return false
end

-- Assign brainrot to pad
function DataManager.AssignToPad(player, floor, padNumber, brainrotID, frame)
	local data = DataManager.GetData(player)
	if data then
		local floorData = floor == 1 and data.Floor1 or data.Floor2
		local key = brainrotID .. "_" .. frame
		floorData[padNumber] = key

		-- Also add to index
		data.Index[key] = true

		return true
	end
	return false
end

-- Remove from pad
function DataManager.RemoveFromPad(player, floor, padNumber)
	local data = DataManager.GetData(player)
	if data then
		local floorData = floor == 1 and data.Floor1 or data.Floor2
		floorData[padNumber] = nil
		return true
	end
	return false
end

-- Get pad content
function DataManager.GetPadContent(player, floor, padNumber)
	local data = DataManager.GetData(player)
	if data then
		local floorData = floor == 1 and data.Floor1 or data.Floor2
		return floorData[padNumber]
	end
	return nil
end

-- Check if player has available pad space
function DataManager.HasAvailablePad(player)
	local data = DataManager.GetData(player)
	if not data then return false end

	-- Check Floor1
	for i = 1, Config.Base.Floor1Pads do
		if not data.Floor1[i] then
			return true, 1, i
		end
	end

	-- Check Floor2 (if unlocked)
	if data.Rebirths > 0 then
		for i = 1, Config.Base.Floor2Pads do
			if not data.Floor2[i] then
				return true, 2, i
			end
		end
	end

	return false
end

-- Clear all pads (for rebirth)
function DataManager.ClearAllPads(player)
	local data = DataManager.GetData(player)
	if data then
		data.Floor1 = {}
		data.Floor2 = {}
		return true
	end
	return false
end

-- Increment rolls
function DataManager.IncrementRolls(player)
	local data = DataManager.GetData(player)
	if data then
		data.TotalRolls = data.TotalRolls + 1
		return data.TotalRolls
	end
	return 0
end

-- Handle player leaving (cleanup stolen brainrot)
function DataManager.HandlePlayerLeaving(player)
	-- Check if player is stealing something
	local character = player.Character
	if character and character:FindFirstChild("IsStealingBrainrot") then
		local stealInfo = character:FindFirstChild("StealInfo")
		if stealInfo then
			-- Return brainrot to original owner (handled by StealingSystem)
			local originalOwnerUserId = stealInfo:FindFirstChild("OriginalOwner")
			if originalOwnerUserId then
				-- We'll handle this in StealingSystem
			end
		end
	end

	-- Release profile
	local profile = DataManager.Profiles[player]
	if profile then
		profile:Release()
		DataManager.Profiles[player] = nil
	end
end

-- Player added handler
Players.PlayerAdded:Connect(function(player)
	DataManager.LoadProfile(player)
end)

-- Player removing handler
Players.PlayerRemoving:Connect(function(player)
	DataManager.HandlePlayerLeaving(player)
end)

return DataManager
