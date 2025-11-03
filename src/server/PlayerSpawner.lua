--[[
	PlayerSpawner.lua
	Spawns players at their own base
	SIMPLE, CLEAN, OPTIMIZED

	Place in: ServerScriptService/Server/PlayerSpawner as Script (NOT ModuleScript)
	This runs independently - MainServer doesn't need to require it
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Get player's base
local function getPlayerBase(player)
	local bases = Workspace:FindFirstChild("Bases")
	if not bases then
		warn("Bases folder not found in Workspace")
		return nil
	end

	local baseName = "Base" .. player.UserId
	local base = bases:FindFirstChild(baseName)

	if not base then
		warn("Base not found for player:", player.Name, "- Looking for:", baseName)
		return nil
	end

	return base
end

-- Get spawn location in base
local function getSpawnLocation(base)
	-- Try to find a spawn point
	local spawnPoint = base:FindFirstChild("SpawnLocation")
		or base:FindFirstChild("Spawn")
		or base:FindFirstChild("Floor1")

	if spawnPoint and spawnPoint:IsA("BasePart") then
		return spawnPoint.CFrame + Vector3.new(0, 5, 0)
	elseif spawnPoint then
		-- If it's a model/folder, find a part inside
		local part = spawnPoint:FindFirstChildWhichIsA("BasePart", true)
		if part then
			return part.CFrame + Vector3.new(0, 5, 0)
		end
	end

	-- Fallback: use base's primary part or any part
	if base:IsA("Model") and base.PrimaryPart then
		return base.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
	end

	local basePart = base:FindFirstChildWhichIsA("BasePart", true)
	if basePart then
		return basePart.CFrame + Vector3.new(0, 5, 0)
	end

	warn("Could not find spawn location in base for player")
	return nil
end

-- Spawn player at their base
local function spawnPlayerAtBase(player)
	local character = player.Character
	if not character then return false end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return false end

	-- Get player's base
	local base = getPlayerBase(player)
	if not base then
		warn("Could not spawn player at base - base not found")
		return false
	end

	-- Get spawn location
	local spawnCFrame = getSpawnLocation(base)
	if not spawnCFrame then
		warn("Could not determine spawn location in base")
		return false
	end

	-- Teleport player
	humanoidRootPart.CFrame = spawnCFrame
	print("✓ Spawned", player.Name, "at their base")

	return true
end

-- Handle player spawning
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		-- Wait a moment for character to fully load
		task.wait(0.5)

		-- Spawn at base
		spawnPlayerAtBase(player)
	end)
end)

print("✓ PlayerSpawner loaded")
