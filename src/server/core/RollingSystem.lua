--[[
	RollingSystem.lua
	Handles RNG rolling for brainrots
	SIMPLE, CLEAN, OPTIMIZED
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BrainrotData = require(ReplicatedStorage.Modules.BrainrotData)

local RollingSystem = {}

-- Server luck multiplier (can be increased via purchases)
RollingSystem.ServerLuckMultiplier = 1

-- Roll a brainrot with RNG
function RollingSystem.RollBrainrot(luckMultiplier)
	luckMultiplier = luckMultiplier or 1

	-- Step 1: Roll rarity
	local rarity = RollingSystem.RollRarity(luckMultiplier)

	-- Step 2: Roll frame type
	local frame = RollingSystem.RollFrame()

	-- Step 3: Select random brainrot of that rarity
	local brainrotsOfRarity = BrainrotData.GetBrainrotsByRarity(rarity)
	if #brainrotsOfRarity == 0 then
		warn("No brainrots found for rarity:", rarity)
		return nil
	end

	local brainrot = brainrotsOfRarity[math.random(1, #brainrotsOfRarity)]

	return {
		BrainrotID = brainrot.ID,
		DisplayName = brainrot.DisplayName,
		Rarity = rarity,
		Frame = frame,
		ImageId = brainrot.ImageId,
		Color = BrainrotData.RarityColors[rarity]
	}
end

-- Roll rarity based on weights and luck
function RollingSystem.RollRarity(luckMultiplier)
	local totalWeight = BrainrotData.GetTotalRarityWeight()
	local roll = math.random() * totalWeight

	-- Apply luck (shifts roll towards higher rarities)
	if luckMultiplier > 1 then
		-- Luck makes it more likely to hit rarer items
		roll = roll / luckMultiplier
	end

	local cumulativeWeight = 0

	-- Iterate from rarest to common (reverse order for luck boost)
	for i = #BrainrotData.Rarities, 1, -1 do
		local rarity = BrainrotData.Rarities[i]
		local weight = BrainrotData.RarityWeights[rarity]
		cumulativeWeight = cumulativeWeight + weight

		if roll <= cumulativeWeight then
			return rarity
		end
	end

	-- Fallback to Common
	return "Common"
end

-- Roll frame type
function RollingSystem.RollFrame()
	local totalWeight = BrainrotData.GetTotalFrameWeight()
	local roll = math.random() * totalWeight
	local cumulativeWeight = 0

	for frame, weight in pairs(BrainrotData.FrameWeights) do
		cumulativeWeight = cumulativeWeight + weight
		if roll <= cumulativeWeight then
			return frame
		end
	end

	return "Normal" -- Fallback
end

-- Calculate luck multiplier for a player
function RollingSystem.CalculateLuck(player)
	-- Base luck is server luck
	local totalLuck = RollingSystem.ServerLuckMultiplier

	-- Add gamepass luck bonuses here if needed (skip for now, no monetization)

	return totalLuck
end

-- Increase server luck (called when someone purchases x2 luck)
function RollingSystem.IncreaseServerLuck()
	RollingSystem.ServerLuckMultiplier = RollingSystem.ServerLuckMultiplier * 2
	print("Server luck increased to:", RollingSystem.ServerLuckMultiplier)

	-- Notify all players (will be handled by RemoteEvent)
	return RollingSystem.ServerLuckMultiplier
end

return RollingSystem
