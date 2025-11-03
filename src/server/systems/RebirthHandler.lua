--[[
	RebirthHandler.lua
	Handles rebirth system
	SIMPLE, CLEAN, OPTIMIZED
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BrainrotData = require(ReplicatedStorage.Modules.BrainrotData)

local RebirthHandler = {}

-- Check if player can rebirth
function RebirthHandler.CanRebirth(player)
	local DataManager = require(script.Parent.Parent.Core.DataManager)
	local data = DataManager.GetData(player)

	if not data then return false, "Data not loaded" end

	-- Calculate total possible brainrots
	local totalBrainrots = #BrainrotData.Brainrots
	local totalFrames = 3 -- Normal, Gold, Diamond
	local totalPossible = totalBrainrots * totalFrames

	-- Count how many the player has
	local collected = 0
	for _ in pairs(data.Index) do
		collected = collected + 1
	end

	-- Check if all collected
	if collected >= totalPossible then
		return true, "Ready to rebirth!"
	else
		return false, string.format("Collect all brainrots first! (%d/%d)", collected, totalPossible)
	end
end

-- Get rebirth progress
function RebirthHandler.GetProgress(player)
	local DataManager = require(script.Parent.Parent.Core.DataManager)
	local data = DataManager.GetData(player)

	if not data then return 0, 0 end

	local totalBrainrots = #BrainrotData.Brainrots
	local totalFrames = 3
	local totalPossible = totalBrainrots * totalFrames

	local collected = 0
	for _ in pairs(data.Index) do
		collected = collected + 1
	end

	return collected, totalPossible
end

-- Process rebirth
function RebirthHandler.ProcessRebirth(player)
	local DataManager = require(script.Parent.Parent.Core.DataManager)
	local BaseManager = require(script.Parent.BaseManager)

	-- Check if can rebirth
	local canRebirth, message = RebirthHandler.CanRebirth(player)
	if not canRebirth then
		return false, message
	end

	-- Clear all pads visually
	BaseManager.ClearBase(player)

	-- Clear pad data
	DataManager.ClearAllPads(player)

	-- Increment rebirths
	local data = DataManager.GetData(player)
	if data then
		data.Rebirths = data.Rebirths + 1
		DataManager.UpdateField(player, "Rebirths", data.Rebirths)
	end

	print(player.Name, "rebirthed! New rebirth count:", data.Rebirths)

	return true, "Rebirth successful!"
end

return RebirthHandler
