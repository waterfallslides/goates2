--[[
	SlapTool.lua
	Tool for slapping thieves - Place this in StarterPack or give to players on spawn
	SIMPLE, CLEAN, OPTIMIZED

	NOTE: This script should be placed inside a Tool object in StarterPack
	The Tool should have a Handle part (the bat model)
]]

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Get StealingSystem
local StealingSystem = require(game.ServerScriptService.Server.Core.StealingSystem)
local Config = require(ReplicatedStorage.Modules.Config)

local equipped = false
local lastHit = 0
local COOLDOWN = 0.5 -- seconds

-- Tool activated (swing)
tool.Activated:Connect(function()
	local player = Players:GetPlayerFromCharacter(tool.Parent)
	if not player then return end

	local now = tick()
	if now - lastHit < COOLDOWN then return end
	lastHit = now

	-- Check for nearby players
	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Find nearby players
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local otherCharacter = otherPlayer.Character
			if otherCharacter then
				local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
				if otherRoot then
					local distance = (rootPart.Position - otherRoot.Position).Magnitude

					-- Within slap range
					if distance <= Config.Stealing.SlapDetectionRange then
						-- Check if they're stealing
						local isStealingTag = otherCharacter:FindFirstChild("IsStealingBrainrot")
						if isStealingTag then
							-- Attempt slap
							StealingSystem.HandleSlap(player, otherPlayer)
						end
					end
				end
			end
		end
	end
end)

-- Handle touch detection (alternative method)
handle.Touched:Connect(function(hit)
	if not equipped then return end

	local character = hit.Parent
	if not character then return end

	local otherPlayer = Players:GetPlayerFromCharacter(character)
	if not otherPlayer then return end

	local player = Players:GetPlayerFromCharacter(tool.Parent)
	if not player or otherPlayer == player then return end

	-- Check cooldown
	local now = tick()
	if now - lastHit < COOLDOWN then return end
	lastHit = now

	-- Check if stealing
	local isStealingTag = character:FindFirstChild("IsStealingBrainrot")
	if isStealingTag then
		StealingSystem.HandleSlap(player, otherPlayer)
	end
end)

tool.Equipped:Connect(function()
	equipped = true
end)

tool.Unequipped:Connect(function()
	equipped = false
end)
