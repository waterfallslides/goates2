--[[
	GiveSlapTool.lua
	Gives Slap tool to all players on spawn
	SIMPLE, CLEAN, OPTIMIZED

	Place in: ServerScriptService
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Function to give slap tool
local function giveSlapTool(player)
	-- Wait for character
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5) -- Small delay

		-- Check if tool exists in ServerStorage
		local slapTool = ServerStorage:FindFirstChild("SlapTool")

		if slapTool then
			-- Clone to player's backpack
			local clone = slapTool:Clone()
			clone.Parent = player.Backpack
		else
			warn("SlapTool not found in ServerStorage!")
		end
	end)

	-- Give on initial spawn if already spawned
	if player.Character then
		local slapTool = ServerStorage:FindFirstChild("SlapTool")
		if slapTool then
			local clone = slapTool:Clone()
			clone.Parent = player.Backpack
		end
	end
end

-- Give to all players
Players.PlayerAdded:Connect(giveSlapTool)

-- Give to existing players (if script runs after players join)
for _, player in ipairs(Players:GetPlayers()) do
	giveSlapTool(player)
end

print("✓ GiveSlapTool loaded")
