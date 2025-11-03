--[[
	BrainrotModelReplicator.lua
	Copies brainrot models from ServerStorage to ReplicatedStorage
	This allows clients to use them in ViewportFrames
	SIMPLE, CLEAN, OPTIMIZED

	Place in: ServerScriptService/Server/Systems/BrainrotModelReplicator
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotModelReplicator = {}

--[[
	Copies all brainrot models from ServerStorage to ReplicatedStorage
	Maintains the same folder structure (rarity subfolders)
]]
function BrainrotModelReplicator.ReplicateModels()
	print("📦 Replicating brainrot models to ReplicatedStorage...")

	-- Find source folder
	local serverBrainrots = ServerStorage:FindFirstChild("Brainrots")
	if not serverBrainrots then
		warn("❌ Brainrots folder not found in ServerStorage!")
		warn("   Expected: ServerStorage/Brainrots/")
		return false
	end

	-- Create or find destination folder
	local replicatedBrainrots = ReplicatedStorage:FindFirstChild("BrainrotModels")
	if replicatedBrainrots then
		-- Clear existing models (in case of reload)
		replicatedBrainrots:ClearAllChildren()
	else
		replicatedBrainrots = Instance.new("Folder")
		replicatedBrainrots.Name = "BrainrotModels"
		replicatedBrainrots.Parent = ReplicatedStorage
	end

	local modelCount = 0

	-- Function to clone a model (deep copy)
	local function cloneModelForClient(model)
		local clone = model:Clone()

		-- Remove scripts from the clone (clients don't need them in viewport)
		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("BaseScript") then
				descendant:Destroy()
			end
		end

		return clone
	end

	-- Copy all brainrot models
	for _, child in ipairs(serverBrainrots:GetChildren()) do
		if child:IsA("Folder") then
			-- This is a rarity folder (Common, Rare, etc.)
			local rarityFolder = Instance.new("Folder")
			rarityFolder.Name = child.Name
			rarityFolder.Parent = replicatedBrainrots

			-- Copy all models in this rarity
			for _, brainrotModel in ipairs(child:GetChildren()) do
				if brainrotModel:IsA("Model") then
					local clone = cloneModelForClient(brainrotModel)
					clone.Parent = rarityFolder
					modelCount = modelCount + 1
					print("  ✓ Copied:", child.Name, "/", brainrotModel.Name)
				end
			end
		elseif child:IsA("Model") then
			-- Model directly in Brainrots folder (no rarity subfolder)
			local clone = cloneModelForClient(child)
			clone.Parent = replicatedBrainrots
			modelCount = modelCount + 1
			print("  ✓ Copied:", child.Name)
		end
	end

	print("✅ Replicated", modelCount, "brainrot models to ReplicatedStorage/BrainrotModels/")
	return true
end

--[[
	Initialize - Call this from MainServer
]]
function BrainrotModelReplicator.Init()
	return BrainrotModelReplicator.ReplicateModels()
end

print("✓ BrainrotModelReplicator loaded")

return BrainrotModelReplicator
