--[[
	BaseManager.lua
	Handles brainrot placement on base pads
	SIMPLE, CLEAN, OPTIMIZED
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Modules.Config)
local BrainrotData = require(ReplicatedStorage.Modules.BrainrotData)

local BaseManager = {}

-- Get player's base
function BaseManager.GetPlayerBase(player)
	local bases = Workspace:FindFirstChild("Bases")
	if not bases then
		warn("Bases folder not found in Workspace")
		return nil
	end

	local baseName = "Base" .. player.UserId
	local base = bases:FindFirstChild(baseName)

	if not base then
		warn("Base not found for player:", player.Name, baseName)
		return nil
	end

	return base
end

-- Get specific pad
function BaseManager.GetPad(player, floor, padNumber)
	local base = BaseManager.GetPlayerBase(player)
	if not base then return nil end

	local floorName = "Floor" .. floor
	local floorFolder = base:FindFirstChild(floorName)
	if not floorFolder then
		warn("Floor not found:", floorName)
		return nil
	end

	local singersPodium = floorFolder:FindFirstChild("SingersPodium")
	if not singersPodium then
		warn("SingersPodium not found in", floorName)
		return nil
	end

	local pad = singersPodium:FindFirstChild(tostring(padNumber))
	return pad
end

-- Place brainrot on pad
function BaseManager.PlaceBrainrot(player, floor, padNumber, brainrotID, frame)
	local pad = BaseManager.GetPad(player, floor, padNumber)
	if not pad then
		warn("Pad not found:", floor, padNumber)
		return false
	end

	-- Clear existing brainrot
	BaseManager.ClearPad(pad)

	-- Get brainrot data
	local brainrot = BrainrotData.GetBrainrotByID(brainrotID)
	if not brainrot then
		warn("Brainrot not found:", brainrotID)
		return false
	end

	-- Get model from ServerStorage
	local brainrotModel = BaseManager.GetBrainrotModel(brainrot.Rarity, brainrotID)
	if not brainrotModel then
		warn("Brainrot model not found in ServerStorage:", brainrotID)
		return false
	end

	-- Clone and place
	local clone = brainrotModel:Clone()
	clone.Name = brainrotID
	clone.Parent = pad

	-- Position it on the pad
	if clone:IsA("Model") and clone.PrimaryPart then
		clone:SetPrimaryPartCFrame(pad.CFrame + Vector3.new(0, 2, 0))
	elseif clone:IsA("BasePart") then
		clone.CFrame = pad.CFrame + Vector3.new(0, 2, 0)
	end

	-- Add ownership tags
	local ownerTag = Instance.new("StringValue")
	ownerTag.Name = "Owner"
	ownerTag.Value = player.Name
	ownerTag.Parent = clone

	local frameTag = Instance.new("StringValue")
	frameTag.Name = "Frame"
	frameTag.Value = frame
	frameTag.Parent = clone

	-- Add ProximityPrompt for stealing
	BaseManager.AddProximityPrompt(clone, player, floor, padNumber)

	return true
end

-- Get brainrot model from ServerStorage
function BaseManager.GetBrainrotModel(rarity, brainrotID)
	local brainrots = ServerStorage:FindFirstChild("Brainrots")
	if not brainrots then
		warn("ServerStorage.Brainrots not found")
		return nil
	end

	local rarityFolder = brainrots:FindFirstChild(rarity)
	if not rarityFolder then
		warn("Rarity folder not found:", rarity)
		return nil
	end

	local model = rarityFolder:FindFirstChild(brainrotID)
	return model
end

-- Clear pad
function BaseManager.ClearPad(pad)
	-- Remove existing brainrot and proximity prompt
	for _, child in ipairs(pad:GetChildren()) do
		if child:IsA("Model") or child:IsA("BasePart") or child.Name == "ProximityPrompt" then
			child:Destroy()
		end
	end
end

-- Add proximity prompt for stealing
function BaseManager.AddProximityPrompt(brainrotModel, owner, floor, padNumber)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Steal"
	prompt.ObjectText = "Brainrot"
	prompt.HoldDuration = Config.Stealing.ProximityPromptDuration
	prompt.MaxActivationDistance = Config.Stealing.MaxActivationDistance
	prompt.RequiresLineOfSight = false

	-- Store metadata
	local ownerValue = Instance.new("ObjectValue")
	ownerValue.Name = "OriginalOwner"
	ownerValue.Value = owner
	ownerValue.Parent = prompt

	local floorValue = Instance.new("IntValue")
	floorValue.Name = "Floor"
	floorValue.Value = floor
	floorValue.Parent = prompt

	local padValue = Instance.new("IntValue")
	padValue.Name = "PadNumber"
	padValue.Value = padNumber
	padValue.Parent = prompt

	-- Find the main part to attach prompt to
	local attachPart
	if brainrotModel:IsA("Model") then
		attachPart = brainrotModel.PrimaryPart or brainrotModel:FindFirstChildWhichIsA("BasePart")
	else
		attachPart = brainrotModel
	end

	if attachPart then
		prompt.Parent = attachPart
	else
		warn("Could not find part to attach ProximityPrompt")
		prompt:Destroy()
	end
end

-- Load player's base from data
function BaseManager.LoadBase(player, data)
	-- Load Floor1
	for padNum, brainrotKey in pairs(data.Floor1) do
		if brainrotKey then
			local brainrotID, frame = brainrotKey:match("(.+)_(.+)")
			if brainrotID and frame then
				BaseManager.PlaceBrainrot(player, 1, padNum, brainrotID, frame)
			end
		end
	end

	-- Load Floor2 (if unlocked)
	if data.Rebirths > 0 then
		for padNum, brainrotKey in pairs(data.Floor2) do
			if brainrotKey then
				local brainrotID, frame = brainrotKey:match("(.+)_(.+)")
				if brainrotID and frame then
					BaseManager.PlaceBrainrot(player, 2, padNum, brainrotID, frame)
				end
			end
		end
	end
end

-- Clear entire base (for rebirth)
function BaseManager.ClearBase(player)
	local base = BaseManager.GetPlayerBase(player)
	if not base then return false end

	-- Clear Floor1
	for i = 1, Config.Base.Floor1Pads do
		local pad = BaseManager.GetPad(player, 1, i)
		if pad then
			BaseManager.ClearPad(pad)
		end
	end

	-- Clear Floor2
	for i = 1, Config.Base.Floor2Pads do
		local pad = BaseManager.GetPad(player, 2, i)
		if pad then
			BaseManager.ClearPad(pad)
		end
	end

	return true
end

return BaseManager
