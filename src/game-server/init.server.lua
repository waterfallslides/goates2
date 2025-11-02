--[[
    ROBLOX BUNKER SURVIVAL - GAME SERVER INITIALIZATION
    Main entry point for the game server

    This script initializes all game systems and starts the game.
    Place this in ServerScriptService.
]]

print("========================================")
print("ROBLOX BUNKER SURVIVAL - GAME SERVER")
print("========================================")

-- Wait for services to load
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get script location
local gameServerFolder = script.Parent

-- Load all managers
print("[INIT] Loading managers...")

local GameManager = require(gameServerFolder.GameManager)
local DayNightManager = require(gameServerFolder.DayNightManager)
local PlayerDataManager = require(gameServerFolder.PlayerDataManager)
local FoodManager = require(gameServerFolder.FoodManager)
local MonsterManager = require(gameServerFolder.MonsterManager)

print("[INIT] Managers loaded successfully")

-- Initialize systems
print("[INIT] Initializing systems...")

-- 1. Initialize Game Manager (handles overall game state)
GameManager:Initialize()

-- 2. Initialize Player Data Manager (health, hunger)
PlayerDataManager:Initialize(GameManager)

-- 3. Initialize Food Manager
FoodManager:Initialize()

-- 4. Initialize Monster Manager
MonsterManager:Initialize(GameManager)

-- 5. Initialize Day/Night Manager (depends on GameManager)
DayNightManager:Initialize(GameManager)

-- Link managers together
DayNightManager.FoodManager = FoodManager
DayNightManager.MonstersManager = MonsterManager
DayNightManager.GameManager = GameManager
MonsterManager.GameManager = GameManager

print("[INIT] All systems initialized")

-- Wait a moment for players to load in
wait(3)

-- Start the game
print("[INIT] Starting game...")
GameManager:StartGame()

-- Start day/night cycle
DayNightManager:Start()

print("[INIT] Game server is now running!")
print("========================================")
