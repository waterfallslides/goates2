--[[
	Config.lua
	General game configuration settings
	SIMPLE, CLEAN, OPTIMIZED
]]

local Config = {}

-- Data settings
Config.DataStore = {
	Name = "PlayerData_v1",
	AutoSaveInterval = 120, -- seconds
}

-- Base settings
Config.Base = {
	Floor1Pads = 10,
	Floor2Pads = 8,
	BasePath = "Workspace.Bases.Base", -- Base[PlayerUserId]
}

-- Rolling settings
Config.Rolling = {
	DefaultRollTime = 3, -- seconds
	FastRollTime = 0, -- instant
	AutoRollInterval = 5, -- seconds
}

-- Stealing settings
Config.Stealing = {
	ProximityPromptDuration = 3, -- seconds to hold E
	MaxActivationDistance = 10, -- studs
	SlapDetectionRange = 10, -- studs
}

-- Leaderboard settings
Config.Leaderboards = {
	UpdateInterval = 300, -- 5 minutes (in seconds)
	TopPlayersCount = 10,
}

-- Stats tracking
Config.Stats = {
	PlaytimeUpdateInterval = 60, -- Update playtime every 60 seconds
}

-- Default player data structure
Config.DefaultPlayerData = {
	Rebirths = 0,
	TotalRolls = 0,
	RobuxSpent = 0,
	PlayTime = 0,
	Index = {},
	Floor1 = {},
	Floor2 = {},
	GamepassesOwned = {},
	ActivePerks = {
		AutoRoll = false,
		FastRoll = false
	}
}

return Config
