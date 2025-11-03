--[[
	BrainrotData.lua
	Contains all brainrot configurations, rarities, and RNG weights
	SIMPLE, CLEAN, OPTIMIZED
]]

local BrainrotData = {}

-- Rarity tiers (in order from common to rarest)
BrainrotData.Rarities = {
	"Common",
	"Rare",
	"Epic",
	"Legendary",
	"Mythic",
	"Secret",
	"BrainrotGod"
}

-- Rarity weights for RNG (higher = more common)
BrainrotData.RarityWeights = {
	Common = 125,        -- ~50%
	Rare = 64,           -- ~25%
	Epic = 32,           -- ~12.5%
	Legendary = 16,      -- ~6.25%
	Mythic = 4,          -- ~1.5%
	Secret = 2,          -- ~0.75%
	BrainrotGod = 1      -- ~0.4%
}

-- Frame types and their weights
BrainrotData.FrameWeights = {
	Normal = 85,   -- ~85%
	Gold = 12,     -- ~12%
	Diamond = 3    -- ~3%
}

-- Rarity colors for UI (RGB)
BrainrotData.RarityColors = {
	Common = Color3.fromRGB(155, 155, 155),
	Rare = Color3.fromRGB(85, 170, 255),
	Epic = Color3.fromRGB(170, 0, 255),
	Legendary = Color3.fromRGB(255, 170, 0),
	Mythic = Color3.fromRGB(255, 85, 255),
	Secret = Color3.fromRGB(255, 0, 0),
	BrainrotGod = Color3.fromRGB(255, 215, 0)
}

-- Brainrot definitions
-- NOTE: Add your brainrots here based on ServerStorage.Brainrots structure
-- Path format: game.ServerStorage.Brainrots.[RarityFolder].[BrainrotModel]
BrainrotData.Brainrots = {
	-- COMMON
	{
		ID = "SkibidiToilet",
		DisplayName = "Skibidi Toilet",
		Rarity = "Common",
		ImageId = "rbxassetid://0" -- Replace with actual asset ID
	},
	{
		ID = "Griddy",
		DisplayName = "Griddy",
		Rarity = "Common",
		ImageId = "rbxassetid://0"
	},

	-- RARE
	{
		ID = "OhioFinal",
		DisplayName = "Ohio Final Boss",
		Rarity = "Rare",
		ImageId = "rbxassetid://0"
	},
	{
		ID = "Sigma",
		DisplayName = "Sigma Male",
		Rarity = "Rare",
		ImageId = "rbxassetid://0"
	},

	-- EPIC
	{
		ID = "Rizz",
		DisplayName = "Rizz Master",
		Rarity = "Epic",
		ImageId = "rbxassetid://0"
	},
	{
		ID = "Gyatt",
		DisplayName = "Gyatt",
		Rarity = "Epic",
		ImageId = "rbxassetid://0"
	},

	-- LEGENDARY
	{
		ID = "Fanum",
		DisplayName = "Fanum Tax Collector",
		Rarity = "Legendary",
		ImageId = "rbxassetid://0"
	},
	{
		ID = "Mewing",
		DisplayName = "Mewing Master",
		Rarity = "Legendary",
		ImageId = "rbxassetid://0"
	},

	-- MYTHIC
	{
		ID = "Sussy",
		DisplayName = "Sussy Baka",
		Rarity = "Mythic",
		ImageId = "rbxassetid://0"
	},

	-- SECRET
	{
		ID = "Edging",
		DisplayName = "Edging Champion",
		Rarity = "Secret",
		ImageId = "rbxassetid://0"
	},

	-- BRAINROT GOD
	{
		ID = "BrainrotGod",
		DisplayName = "BRAINROT GOD",
		Rarity = "BrainrotGod",
		ImageId = "rbxassetid://0"
	}
}

-- Helper function: Get brainrot by ID
function BrainrotData.GetBrainrotByID(id)
	for _, brainrot in ipairs(BrainrotData.Brainrots) do
		if brainrot.ID == id then
			return brainrot
		end
	end
	return nil
end

-- Helper function: Get all brainrots of a specific rarity
function BrainrotData.GetBrainrotsByRarity(rarity)
	local result = {}
	for _, brainrot in ipairs(BrainrotData.Brainrots) do
		if brainrot.Rarity == rarity then
			table.insert(result, brainrot)
		end
	end
	return result
end

-- Calculate total weight for rarities
function BrainrotData.GetTotalRarityWeight()
	local total = 0
	for _, weight in pairs(BrainrotData.RarityWeights) do
		total = total + weight
	end
	return total
end

-- Calculate total weight for frames
function BrainrotData.GetTotalFrameWeight()
	local total = 0
	for _, weight in pairs(BrainrotData.FrameWeights) do
		total = total + weight
	end
	return total
end

return BrainrotData
