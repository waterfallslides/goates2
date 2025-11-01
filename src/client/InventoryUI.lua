--[[
    Inventory and Stats UI (Client-Side)
    Displays player inventory, stats (health, hunger), and day/night status
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

local InventoryUpdateEvent = eventsFolder:WaitForChild("InventoryUpdate", 5)
local StatsUpdateEvent = eventsFolder:WaitForChild("StatsUpdate", 5)
local DayNightEvent = eventsFolder:WaitForChild("DayNightTransition", 5)
local TimeUpdateEvent = eventsFolder:WaitForChild("TimeUpdate", 5)

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryStatsUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 5
screenGui.Parent = PlayerGui

-- Create stats panel (top left)
local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsPanel"
statsFrame.Size = UDim2.new(0, 250, 0, 120)
statsFrame.Position = UDim2.new(0, 10, 0, 10)
statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statsFrame.BackgroundTransparency = 0.3
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

-- Create inventory panel (top right)
local inventoryFrame = Instance.new("Frame")
inventoryFrame.Name = "InventoryPanel"
inventoryFrame.Size = UDim2.new(0, 300, 0, 200)
inventoryFrame.Position = UDim2.new(1, -310, 0, 10)
inventoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inventoryFrame.BackgroundTransparency = 0.3
inventoryFrame.BorderSizePixel = 0
inventoryFrame.Parent = screenGui

local inventoryCorner = Instance.new("UICorner")
inventoryCorner.CornerRadius = UDim.new(0, 8)
inventoryCorner.Parent = inventoryFrame

-- Inventory title
local inventoryTitle = Instance.new("TextLabel")
inventoryTitle.Name = "Title"
inventoryTitle.Size = UDim2.new(1, -20, 0, 30)
inventoryTitle.Position = UDim2.new(0, 10, 0, 5)
inventoryTitle.BackgroundTransparency = 1
inventoryTitle.Text = "🎒 INVENTORY (0/3)"
inventoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
inventoryTitle.TextXAlignment = Enum.TextXAlignment.Left
inventoryTitle.Font = Enum.Font.GothamBold
inventoryTitle.TextSize = 20
inventoryTitle.Parent = inventoryFrame

-- Inventory items container
local itemsContainer = Instance.new("ScrollingFrame")
itemsContainer.Name = "ItemsContainer"
itemsContainer.Size = UDim2.new(1, -20, 1, -45)
itemsContainer.Position = UDim2.new(0, 10, 0, 35)
itemsContainer.BackgroundTransparency = 1
itemsContainer.BorderSizePixel = 0
itemsContainer.ScrollBarThickness = 6
itemsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
itemsContainer.Parent = inventoryFrame

local itemsLayout = Instance.new("UIListLayout")
itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
itemsLayout.Padding = UDim.new(0, 5)
itemsLayout.Parent = itemsContainer

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

-- Update inventory display
local function updateInventory(inventoryData)
    if not inventoryData then return end

    -- Clear existing items
    for _, child in ipairs(itemsContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Update title with count
    inventoryTitle.Text = string.format("🎒 INVENTORY (%d/3)", #inventoryData)

    -- Create item entries
    for i, itemData in ipairs(inventoryData) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = "Item_" .. itemData.FoodType
        itemFrame.Size = UDim2.new(1, 0, 0, 40)
        itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        itemFrame.BackgroundTransparency = 0.5
        itemFrame.BorderSizePixel = 0
        itemFrame.Parent = itemsContainer

        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 6)
        itemCorner.Parent = itemFrame

        -- Food name and count
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = itemData.DisplayName
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 16
        nameLabel.Parent = itemFrame

        -- Count label
        local countLabel = Instance.new("TextLabel")
        countLabel.Size = UDim2.new(0.3, -10, 1, 0)
        countLabel.Position = UDim2.new(0.7, 0, 0, 0)
        countLabel.BackgroundTransparency = 1
        countLabel.Text = "x" .. itemData.Count
        countLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        countLabel.TextXAlignment = Enum.TextXAlignment.Right
        countLabel.Font = Enum.Font.GothamBold
        countLabel.TextSize = 18
        countLabel.Parent = itemFrame
    end

    -- Update canvas size
    itemsContainer.CanvasSize = UDim2.new(0, 0, 0, itemsLayout.AbsoluteContentSize.Y)
end

-- Update day/night display
local function updateDayNight(isDay, timeRemaining)
    if isDay then
        dayNightLabel.Text = "☀️ DAY - " .. formatTime(timeRemaining)
        dayNightLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

        -- Animate color change
        local tween = TweenService:Create(statsFrame, TweenInfo.new(1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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

if InventoryUpdateEvent then
    InventoryUpdateEvent.OnClientEvent:Connect(updateInventory)
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

print("[InventoryUI] Inventory and stats UI initialized!")
