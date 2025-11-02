--[[
    Stats UI (Client-Side)
    Displays player stats and day/night status
    (Inventory now uses default Roblox system)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Wait for Remote Events
local eventsFolder = ReplicatedStorage:WaitForChild("GameStateEvents", 10)
if not eventsFolder then
    warn("[InventoryUI] GameStateEvents folder not found!")
    return
end

local StatsUpdateEvent = eventsFolder:WaitForChild("StatsUpdate", 5)
local DayNightEvent = eventsFolder:WaitForChild("DayNightTransition", 5)
local TimeUpdateEvent = eventsFolder:WaitForChild("TimeUpdate", 5)

-- Create main ScreenGui (stats only)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatsUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 5
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

-- Create stats panel (top left)
local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsPanel"
statsFrame.Size = UDim2.new(0, 250, 0, 120)
statsFrame.Position = UDim2.new(0, 10, 0, 10)
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statsFrame.BackgroundTransparency = 0.2
statsFrame.BorderSizePixel = 0
statsFrame.Parent = screenGui

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsFrame

-- Health label
local healthLabel = Instance.new("TextLabel")
healthLabel.Name = "HealthLabel"
healthLabel.Size = UDim2.new(1, -20, 0, 30)
healthLabel.Position = UDim2.new(0, 10, 0, 10)
healthLabel.BackgroundTransparency = 1
healthLabel.Text = "❤️ Health: 100/100"
healthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
healthLabel.TextXAlignment = Enum.TextXAlignment.Left
healthLabel.Font = Enum.Font.GothamBold
healthLabel.TextSize = 18
healthLabel.Parent = statsFrame

-- Hunger label
local hungerLabel = Instance.new("TextLabel")
hungerLabel.Name = "HungerLabel"
hungerLabel.Size = UDim2.new(1, -20, 0, 30)
hungerLabel.Position = UDim2.new(0, 10, 0, 45)
hungerLabel.BackgroundTransparency = 1
hungerLabel.Text = "🍖 Hunger: 100/100"
hungerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
hungerLabel.TextXAlignment = Enum.TextXAlignment.Left
hungerLabel.Font = Enum.Font.GothamBold
hungerLabel.TextSize = 18
hungerLabel.Parent = statsFrame

-- Day/Night status label
local dayNightLabel = Instance.new("TextLabel")
dayNightLabel.Name = "DayNightLabel"
dayNightLabel.Size = UDim2.new(1, -20, 0, 30)
dayNightLabel.Position = UDim2.new(0, 10, 0, 80)
dayNightLabel.BackgroundTransparency = 1
dayNightLabel.Text = "☀️ DAY - 5:00"
dayNightLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
dayNightLabel.TextXAlignment = Enum.TextXAlignment.Left
dayNightLabel.Font = Enum.Font.GothamBold
dayNightLabel.TextSize = 18
dayNightLabel.Parent = statsFrame

-- Function to format time
local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%d:%02d", minutes, secs)
end

-- Update stats display
local function updateStats(stats)
    if not stats then return end

    healthLabel.Text = string.format("❤️ Health: %d/%d", math.floor(stats.Health), stats.MaxHealth)
    hungerLabel.Text = string.format("🍖 Hunger: %d/%d", math.floor(stats.Hunger), stats.MaxHunger)

    -- Color based on values
    local healthPercent = stats.Health / stats.MaxHealth
    if healthPercent > 0.6 then
        healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    elseif healthPercent > 0.3 then
        healthLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    else
        healthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end

    local hungerPercent = stats.Hunger / stats.MaxHunger
    if hungerPercent > 0.6 then
        hungerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    elseif hungerPercent > 0.3 then
        hungerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    else
        hungerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- Update day/night display
local function updateDayNight(isDay, timeRemaining)
    if isDay then
        dayNightLabel.Text = "☀️ DAY - " .. formatTime(timeRemaining)
        dayNightLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

        -- Animate color change
        local tween = TweenService:Create(statsFrame, TweenInfo.new(1), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        })
        tween:Play()
    else
        dayNightLabel.Text = "🌙 NIGHT - " .. formatTime(timeRemaining)
        dayNightLabel.TextColor3 = Color3.fromRGB(150, 150, 255)

        -- Animate color change
        local tween = TweenService:Create(statsFrame, TweenInfo.new(1), {
            BackgroundColor3 = Color3.fromRGB(20, 20, 40)
        })
        tween:Play()
    end
end

-- Listen to events
if StatsUpdateEvent then
    StatsUpdateEvent.OnClientEvent:Connect(updateStats)
end

if DayNightEvent then
    DayNightEvent.OnClientEvent:Connect(updateDayNight)
end

if TimeUpdateEvent then
    TimeUpdateEvent.OnClientEvent:Connect(function(isDay, timeRemaining)
        if isDay then
            dayNightLabel.Text = "☀️ DAY - " .. formatTime(timeRemaining)
        else
            dayNightLabel.Text = "🌙 NIGHT - " .. formatTime(timeRemaining)
        end
    end)
end

print("[StatsUI] Stats display initialized! (Using default Roblox inventory)")
