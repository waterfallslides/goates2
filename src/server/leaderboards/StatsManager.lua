--[[
	StatsManager.lua
	Tracks player stats for leaderboards
	SIMPLE, CLEAN, OPTIMIZED
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Modules.Config)

local StatsManager = {}

-- OrderedDataStores for leaderboards
local RollsLeaderboard = DataStoreService:GetOrderedDataStore("RollsLeaderboard")
local RobuxLeaderboard = DataStoreService:GetOrderedDataStore("RobuxLeaderboard")
local PlaytimeLeaderboard = DataStoreService:GetOrderedDataStore("PlaytimeLeaderboard")

-- Track playtime
function StatsManager.StartPlaytimeTracking()
	game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
		for _, player in ipairs(Players:GetPlayers()) do
			local DataManager = require(script.Parent.Parent.Core.DataManager)
			local data = DataManager.GetData(player)

			if data then
				data.PlayTime = data.PlayTime + deltaTime
			end
		end
	end)
end

-- Update leaderboard for a player
function StatsManager.UpdateLeaderboard(player, statType, value)
	pcall(function()
		if statType == "Rolls" then
			RollsLeaderboard:SetAsync("Player_" .. player.UserId, value)
		elseif statType == "Robux" then
			RobuxLeaderboard:SetAsync("Player_" .. player.UserId, value)
		elseif statType == "Playtime" then
			PlaytimeLeaderboard:SetAsync("Player_" .. player.UserId, math.floor(value))
		end
	end)
end

-- Get top players for a stat
function StatsManager.GetTopPlayers(statType, count)
	count = count or Config.Leaderboards.TopPlayersCount

	local success, pages
	pcall(function()
		if statType == "Rolls" then
			pages = RollsLeaderboard:GetSortedAsync(false, count)
		elseif statType == "Robux" then
			pages = RobuxLeaderboard:GetSortedAsync(false, count)
		elseif statType == "Playtime" then
			pages = PlaytimeLeaderboard:GetSortedAsync(false, count)
		end
	end)

	if not success or not pages then
		return {}
	end

	local topPlayers = {}
	local entries = pages:GetCurrentPage()

	for rank, entry in ipairs(entries) do
		local userId = tonumber(entry.key:match("%d+"))
		local username = "Unknown"

		pcall(function()
			username = Players:GetNameFromUserIdAsync(userId)
		end)

		table.insert(topPlayers, {
			Rank = rank,
			Username = username,
			Value = entry.value,
			UserId = userId
		})
	end

	return topPlayers
end

-- Update all leaderboards periodically
function StatsManager.StartLeaderboardUpdates()
	task.spawn(function()
		while true do
			task.wait(Config.Leaderboards.UpdateInterval)

			-- Update all players' stats to leaderboards
			for _, player in ipairs(Players:GetPlayers()) do
				local DataManager = require(script.Parent.Parent.Core.DataManager)
				local data = DataManager.GetData(player)

				if data then
					StatsManager.UpdateLeaderboard(player, "Rolls", data.TotalRolls)
					StatsManager.UpdateLeaderboard(player, "Robux", data.RobuxSpent)
					StatsManager.UpdateLeaderboard(player, "Playtime", data.PlayTime)
				end
			end

			print("Leaderboards updated!")
		end
	end)
end

-- Initialize
function StatsManager.Init()
	StatsManager.StartPlaytimeTracking()
	StatsManager.StartLeaderboardUpdates()
end

return StatsManager
