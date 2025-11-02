--[[
    ROBLOX BUNKER SURVIVAL - GAME CLIENT INITIALIZATION
    Main client-side entry point

    Place this in StarterPlayer > StarterPlayerScripts
]]

print("[CLIENT] Initializing Bunker Survival client...")

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Get script location
local clientFolder = script.Parent

-- Load client modules
local GameHUD = require(clientFolder.GameHUD)

-- Wait for local player
local player = Players.LocalPlayer

-- Wait for game events to be created by server
repeat
    task.wait(0.1)
until ReplicatedStorage:FindFirstChild("GameEvents")

print("[CLIENT] Game events found, initializing HUD...")

-- Initialize HUD
GameHUD:Initialize()

print("[CLIENT] Client initialization complete!")
