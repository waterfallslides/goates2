--[[
	StealingSystem.lua
	Handles stealing brainrots from other players
	SIMPLE, CLEAN, OPTIMIZED
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.Modules.Config)
local BrainrotData = require(ReplicatedStorage.Modules.BrainrotData)

local StealingSystem = {}

-- Initialize proximity prompt listeners
function StealingSystem.Init()
	-- We'll connect to ProximityPrompts dynamically when they're created
	-- Listen for all ProximityPrompts in workspace
	Workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("ProximityPrompt") and descendant:FindFirstChild("OriginalOwner") then
			StealingSystem.ConnectPrompt(descendant)
		end
	end)
end

-- Connect proximity prompt
function StealingSystem.ConnectPrompt(prompt)
	prompt.Triggered:Connect(function(playerWhoTriggered)
		local originalOwner = prompt:FindFirstChild("OriginalOwner")
		local floor = prompt:FindFirstChild("Floor")
		local padNumber = prompt:FindFirstChild("PadNumber")

		if originalOwner and floor and padNumber then
			-- Don't allow stealing from yourself
			if originalOwner.Value == playerWhoTriggered then
				return
			end

			-- Start steal
			StealingSystem.StartSteal(
				playerWhoTriggered,
				originalOwner.Value,
				floor.Value,
				padNumber.Value,
				prompt.Parent
			)
		end
	end)
end

-- Start stealing process
function StealingSystem.StartSteal(thief, originalOwner, floor, padNumber, brainrotModel)
	-- Validate
	if not thief or not originalOwner or not brainrotModel then
		return
	end

	local character = thief.Character
	if not character then return end

	-- Check if already stealing
	if character:FindFirstChild("IsStealingBrainrot") then
		return
	end

	-- Get brainrot info
	local brainrotID = brainrotModel.Name
	local frameTag = brainrotModel:FindFirstChild("Frame")
	local frame = frameTag and frameTag.Value or "Normal"

	-- Create stealing tag
	local stealTag = Instance.new("BoolValue")
	stealTag.Name = "IsStealingBrainrot"
	stealTag.Parent = character

	-- Store steal info
	local stealInfo = Instance.new("Folder")
	stealInfo.Name = "StealInfo"
	stealInfo.Parent = character

	local ownerValue = Instance.new("StringValue")
	ownerValue.Name = "OriginalOwner"
	ownerValue.Value = originalOwner.Name
	ownerValue.Parent = stealInfo

	local ownerUserIdValue = Instance.new("IntValue")
	ownerUserIdValue.Name = "OriginalOwnerUserId"
	ownerUserIdValue.Value = originalOwner.UserId
	ownerUserIdValue.Parent = stealInfo

	local brainrotValue = Instance.new("StringValue")
	brainrotValue.Name = "BrainrotID"
	brainrotValue.Value = brainrotID
	brainrotValue.Parent = stealInfo

	local frameValue = Instance.new("StringValue")
	frameValue.Name = "Frame"
	frameValue.Value = frame
	frameValue.Parent = stealInfo

	local floorValue = Instance.new("IntValue")
	floorValue.Name = "Floor"
	floorValue.Value = floor
	floorValue.Parent = stealInfo

	local padValue = Instance.new("IntValue")
	padValue.Name = "PadNumber"
	padValue.Value = padNumber
	padValue.Parent = stealInfo

	-- Clone brainrot above thief's head
	local clone = brainrotModel:Clone()
	clone.Name = "StolenBrainrot"

	-- Remove proximity prompt from clone
	for _, child in ipairs(clone:GetDescendants()) do
		if child:IsA("ProximityPrompt") then
			child:Destroy()
		end
	end

	-- Weld to head
	local head = character:FindFirstChild("Head")
	if head then
		clone.Parent = character

		if clone:IsA("Model") and clone.PrimaryPart then
			-- Weld model
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = head
			weld.Part1 = clone.PrimaryPart
			weld.Parent = clone.PrimaryPart

			clone:SetPrimaryPartCFrame(head.CFrame + Vector3.new(0, 3, 0))
		elseif clone:IsA("BasePart") then
			-- Weld part
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = head
			weld.Part1 = clone
			weld.Parent = clone

			clone.CFrame = head.CFrame + Vector3.new(0, 3, 0)
		end
	end

	-- Remove original brainrot from pad (visual only, not data yet)
	brainrotModel:Destroy()

	-- Notify original owner
	local remoteEvent = ReplicatedStorage:FindFirstChild("StealAlert")
	if remoteEvent then
		remoteEvent:FireClient(originalOwner, brainrotID)
	end

	print(thief.Name, "started stealing", brainrotID, "from", originalOwner.Name)
end

-- Handle slap detection
function StealingSystem.HandleSlap(attacker, victim)
	-- Check if victim is stealing
	if not victim or not victim.Character then return false end

	local character = victim.Character
	local stealTag = character:FindFirstChild("IsStealingBrainrot")

	if not stealTag then return false end

	local stealInfo = character:FindFirstChild("StealInfo")
	if not stealInfo then return false end

	-- Verify attacker is the original owner
	local originalOwnerName = stealInfo:FindFirstChild("OriginalOwner")
	if not originalOwnerName or originalOwnerName.Value ~= attacker.Name then
		return false
	end

	-- Return brainrot
	StealingSystem.ReturnStolenBrainrot(victim)

	-- Notify victim
	local remoteEvent = ReplicatedStorage:FindFirstChild("SendNotification")
	if remoteEvent then
		remoteEvent:FireClient(victim, "You were slapped!", "Warning")
	end

	print(attacker.Name, "slapped", victim.Name, "and returned the brainrot")

	return true
end

-- Return stolen brainrot to original owner
function StealingSystem.ReturnStolenBrainrot(thief)
	local character = thief.Character
	if not character then return end

	local stealInfo = character:FindFirstChild("StealInfo")
	if not stealInfo then return end

	-- Get info
	local brainrotID = stealInfo:FindFirstChild("BrainrotID")
	local frame = stealInfo:FindFirstChild("Frame")
	local floor = stealInfo:FindFirstChild("Floor")
	local padNumber = stealInfo:FindFirstChild("PadNumber")
	local originalOwnerUserId = stealInfo:FindFirstChild("OriginalOwnerUserId")

	if not brainrotID or not frame or not floor or not padNumber or not originalOwnerUserId then
		return
	end

	-- Find original owner
	local originalOwner = Players:GetPlayerByUserId(originalOwnerUserId.Value)

	-- Remove from thief
	local stolenModel = character:FindFirstChild("StolenBrainrot")
	if stolenModel then
		stolenModel:Destroy()
	end

	character:FindFirstChild("IsStealingBrainrot"):Destroy()
	stealInfo:Destroy()

	-- Return to pad if owner still in game
	if originalOwner then
		local BaseManager = require(script.Parent.Parent.Systems.BaseManager)
		BaseManager.PlaceBrainrot(
			originalOwner,
			floor.Value,
			padNumber.Value,
			brainrotID.Value,
			frame.Value
		)
	end
end

-- Check if thief reached their base (complete steal)
function StealingSystem.CheckThiefReachedBase(thief)
	local character = thief.Character
	if not character then return false end

	local stealTag = character:FindFirstChild("IsStealingBrainrot")
	if not stealTag then return false end

	-- Check if thief is in their own base (simple distance check to base center)
	local BaseManager = require(script.Parent.Parent.Systems.BaseManager)
	local base = BaseManager.GetPlayerBase(thief)

	if not base then return false end

	local basePart = base.PrimaryPart or base:FindFirstChildWhichIsA("BasePart")
	if not basePart then return false end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end

	local distance = (rootPart.Position - basePart.Position).Magnitude

	-- If within 50 studs of base, steal is complete
	if distance < 50 then
		StealingSystem.CompleteSteal(thief)
		return true
	end

	return false
end

-- Complete steal (thief successfully returned to base)
function StealingSystem.CompleteSteal(thief)
	local character = thief.Character
	if not character then return end

	local stealInfo = character:FindFirstChild("StealInfo")
	if not stealInfo then return end

	-- Get info
	local brainrotID = stealInfo:FindFirstChild("BrainrotID")
	local frame = stealInfo:FindFirstChild("Frame")
	local originalOwnerUserId = stealInfo:FindFirstChild("OriginalOwnerUserId")

	if not brainrotID or not frame or not originalOwnerUserId then return end

	-- Get managers
	local DataManager = require(script.Parent.DataManager)
	local BaseManager = require(script.Parent.Parent.Systems.BaseManager)

	-- Check if thief has available space
	local hasSpace, targetFloor, targetPad = DataManager.HasAvailablePad(thief)

	if not hasSpace then
		-- TODO: Show replacement GUI
		-- For now, just cancel the steal
		local remoteEvent = ReplicatedStorage:FindFirstChild("SendNotification")
		if remoteEvent then
			remoteEvent:FireClient(thief, "No space! Base is full.", "Error")
		end

		-- Attempt to return to original owner
		local originalOwner = Players:GetPlayerByUserId(originalOwnerUserId.Value)
		if originalOwner then
			local floorVal = stealInfo:FindFirstChild("Floor")
			local padVal = stealInfo:FindFirstChild("PadNumber")
			if floorVal and padVal then
				BaseManager.PlaceBrainrot(
					originalOwner,
					floorVal.Value,
					padVal.Value,
					brainrotID.Value,
					frame.Value
				)
			end
		end

		-- Clean up
		character:FindFirstChild("StolenBrainrot"):Destroy()
		character:FindFirstChild("IsStealingBrainrot"):Destroy()
		stealInfo:Destroy()

		return
	end

	-- Add to thief's base and data
	DataManager.AssignToPad(thief, targetFloor, targetPad, brainrotID.Value, frame.Value)
	BaseManager.PlaceBrainrot(thief, targetFloor, targetPad, brainrotID.Value, frame.Value)

	-- Remove from original owner's data
	local originalOwner = Players:GetPlayerByUserId(originalOwnerUserId.Value)
	if originalOwner then
		local floorVal = stealInfo:FindFirstChild("Floor")
		local padVal = stealInfo:FindFirstChild("PadNumber")
		if floorVal and padVal then
			DataManager.RemoveFromPad(originalOwner, floorVal.Value, padVal.Value)
		end
	end

	-- Clean up
	character:FindFirstChild("StolenBrainrot"):Destroy()
	character:FindFirstChild("IsStealingBrainrot"):Destroy()
	stealInfo:Destroy()

	-- Notify thief
	local remoteEvent = ReplicatedStorage:FindFirstChild("SendNotification")
	if remoteEvent then
		remoteEvent:FireClient(thief, "Steal successful!", "Success")
	end

	print(thief.Name, "successfully stole", brainrotID.Value)
end

-- Monitor for thief returning to base (Heartbeat check)
game:GetService("RunService").Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		StealingSystem.CheckThiefReachedBase(player)
	end
end)

return StealingSystem
