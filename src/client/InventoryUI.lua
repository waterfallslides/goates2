--[[
    Inventory and Stats UI (Client-Side)
    Displays player inventory in hotbar style, stats, and day/night status
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

-- Get FoodConfig for icons
local FoodConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FoodConfig"))

-- Get ConsumeFood RemoteFunction
local ConsumeFoodFunction = ReplicatedStorage:WaitForChild("ConsumeFood", 10)

-- Track equipped item
local equippedSlot = nil

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryStatsUI"
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

-- Create hotbar inventory (bottom center - Roblox style)
local hotbarFrame = Instance.new("Frame")
hotbarFrame.Name = "HotbarInventory"
hotbarFrame.Size = UDim2.new(0, 320, 0, 90)
hotbarFrame.Position = UDim2.new(0.5, 0, 1, -100)
hotbarFrame.AnchorPoint = Vector2.new(0.5, 0)
hotbarFrame.BackgroundTransparency = 1
hotbarFrame.Parent = screenGui

-- Inventory title
local inventoryTitle = Instance.new("TextLabel")
inventoryTitle.Name = "Title"
inventoryTitle.Size = UDim2.new(1, 0, 0, 20)
inventoryTitle.Position = UDim2.new(0, 0, 0, 0)
inventoryTitle.BackgroundTransparency = 1
inventoryTitle.Text = "INVENTORY (0/3)"
inventoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
inventoryTitle.Font = Enum.Font.GothamBold
inventoryTitle.TextSize = 14
inventoryTitle.TextStrokeTransparency = 0.5
inventoryTitle.Parent = hotbarFrame

-- Create slots container
local slotsContainer = Instance.new("Frame")
slotsContainer.Name = "Slots"
slotsContainer.Size = UDim2.new(1, 0, 0, 70)
slotsContainer.Position = UDim2.new(0, 0, 0, 20)
slotsContainer.BackgroundTransparency = 1
slotsContainer.Parent = hotbarFrame

local slotsLayout = Instance.new("UIListLayout")
slotsLayout.FillDirection = Enum.FillDirection.Horizontal
slotsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
slotsLayout.SortOrder = Enum.SortOrder.LayoutOrder
slotsLayout.Padding = UDim.new(0, 10)
slotsLayout.Parent = slotsContainer

-- Create 3 inventory slots
local inventorySlots = {}
for i = 1, 3 do
    local slot = Instance.new("Frame")
    slot.Name = "Slot" .. i
    slot.Size = UDim2.new(0, 90, 0, 70)
    slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    slot.BorderSizePixel = 2
    slot.BorderColor3 = Color3.fromRGB(70, 70, 70)
    slot.LayoutOrder = i
    slot.Parent = slotsContainer

    local slotCorner = Instance.new("UICorner")
    slotCorner.CornerRadius = UDim.new(0, 6)
    slotCorner.Parent = slot

    -- Icon/Emoji
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(1, -10, 0, 35)
    icon.Position = UDim2.new(0, 5, 0, 5)
    icon.BackgroundTransparency = 1
    icon.Text = "?"
    icon.TextColor3 = Color3.fromRGB(150, 150, 150)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 28
    icon.Parent = slot

    -- Item name
    local itemName = Instance.new("TextLabel")
    itemName.Name = "ItemName"
    itemName.Size = UDim2.new(1, -10, 0, 15)
    itemName.Position = UDim2.new(0, 5, 0, 40)
    itemName.BackgroundTransparency = 1
    itemName.Text = "Empty"
    itemName.TextColor3 = Color3.fromRGB(150, 150, 150)
    itemName.Font = Enum.Font.Gotham
    itemName.TextSize = 10
    itemName.TextScaled = true
    itemName.Parent = slot

    -- Quantity label (bottom right)
    local quantity = Instance.new("TextLabel")
    quantity.Name = "Quantity"
    quantity.Size = UDim2.new(0, 25, 0, 15)
    quantity.Position = UDim2.new(1, -30, 1, -20)
    quantity.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    quantity.BackgroundTransparency = 0.3
    quantity.BorderSizePixel = 0
    quantity.Text = ""
    quantity.TextColor3 = Color3.fromRGB(255, 255, 255)
    quantity.Font = Enum.Font.GothamBold
    quantity.TextSize = 12
    quantity.Visible = false
    quantity.Parent = slot

    local qtyCorner = Instance.new("UICorner")
    qtyCorner.CornerRadius = UDim.new(0, 4)
    qtyCorner.Parent = quantity

    -- Equipped indicator (checkmark)
    local equippedIndicator = Instance.new("TextLabel")
    equippedIndicator.Name = "EquippedIndicator"
    equippedIndicator.Size = UDim2.new(0, 20, 0, 20)
    equippedIndicator.Position = UDim2.new(0, 5, 0, 5)
    equippedIndicator.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
    equippedIndicator.BackgroundTransparency = 0.2
    equippedIndicator.Text = "✓"
    equippedIndicator.TextColor3 = Color3.new(1, 1, 1)
    equippedIndicator.Font = Enum.Font.GothamBold
    equippedIndicator.TextSize = 14
    equippedIndicator.Visible = false
    equippedIndicator.Parent = slot

    local eqCorner = Instance.new("UICorner")
    eqCorner.CornerRadius = UDim.new(0, 4)
    eqCorner.Parent = equippedIndicator

    -- Store reference
    inventorySlots[i] = {
        Frame = slot,
        Icon = icon,
        ItemName = itemName,
        Quantity = quantity,
        EquippedIndicator = equippedIndicator,
        FoodType = nil,
        Button = nil  -- Will be created when slot has item
    }
end

-- Function to format time
local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%d:%02d", minutes, secs)
end

-- Function to get emoji/icon for food type
local function getFoodIcon(foodType)
    local icons = {
        Bread = "🍞",
        Apple = "🍎",
        CookedMeat = "🍖",
        CannedFood = "🥫",
        WaterBottle = "💧"
    }
    return icons[foodType] or "🍴"
end

-- Function to get short name for food
local function getShortName(displayName)
    -- Remove emoji from display name
    local name = displayName:gsub("[%z\1-\127\194-\244][\128-\191]*", "")
    return name:match("^%s*(.-)%s*$") -- Trim whitespace
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

-- Function to equip/unequip or consume food
local function handleSlotClick(slotIndex)
    local slot = inventorySlots[slotIndex]

    if not slot.FoodType then
        -- Empty slot, do nothing
        return
    end

    -- If this slot is already equipped, consume the food
    if equippedSlot == slotIndex then
        print("[InventoryUI] Consuming", slot.FoodType)

        if ConsumeFoodFunction then
            local success = pcall(function()
                ConsumeFoodFunction:InvokeServer(slot.FoodType)
            end)

            if success then
                -- Unequip after consuming
                slot.EquippedIndicator.Visible = false
                equippedSlot = nil
            end
        end
    else
        -- Unequip previous slot
        if equippedSlot then
            inventorySlots[equippedSlot].EquippedIndicator.Visible = false
        end

        -- Equip this slot
        equippedSlot = slotIndex
        slot.EquippedIndicator.Visible = true

        print("[InventoryUI] Equipped", slot.FoodType)
    end
end

-- Update inventory display (hotbar slots)
local function updateInventory(inventoryData)
    if not inventoryData then return end

    -- Update title
    inventoryTitle.Text = string.format("INVENTORY (%d/3)", #inventoryData)

    -- Clear all slots first
    for i = 1, 3 do
        local slot = inventorySlots[i]
        slot.Icon.Text = "?"
        slot.Icon.TextColor3 = Color3.fromRGB(100, 100, 100)
        slot.ItemName.Text = "Empty"
        slot.ItemName.TextColor3 = Color3.fromRGB(150, 150, 150)
        slot.Quantity.Visible = false
        slot.Quantity.Text = ""
        slot.FoodType = nil
        slot.Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        slot.Frame.BorderColor3 = Color3.fromRGB(70, 70, 70)

        -- Remove old button if exists
        if slot.Button then
            slot.Button:Destroy()
            slot.Button = nil
        end

        -- Hide equipped indicator if this slot is not equipped anymore
        if equippedSlot ~= i then
            slot.EquippedIndicator.Visible = false
        end
    end

    -- Fill slots with inventory items
    for i, itemData in ipairs(inventoryData) do
        if i <= 3 then
            local slot = inventorySlots[i]
            local foodData = FoodConfig.FoodTypes[itemData.FoodType]

            if foodData then
                -- Set icon
                slot.Icon.Text = getFoodIcon(itemData.FoodType)

                -- Color based on rarity
                if foodData.Rarity == "common" then
                    slot.Icon.TextColor3 = Color3.fromRGB(200, 200, 200)
                    slot.Frame.BorderColor3 = Color3.fromRGB(150, 150, 150)
                elseif foodData.Rarity == "uncommon" then
                    slot.Icon.TextColor3 = Color3.fromRGB(100, 255, 100)
                    slot.Frame.BorderColor3 = Color3.fromRGB(100, 255, 100)
                elseif foodData.Rarity == "rare" then
                    slot.Icon.TextColor3 = Color3.fromRGB(255, 215, 0)
                    slot.Frame.BorderColor3 = Color3.fromRGB(255, 215, 0)
                end

                -- Set item name
                slot.ItemName.Text = getShortName(itemData.DisplayName)
                slot.ItemName.TextColor3 = Color3.fromRGB(255, 255, 255)

                -- Set quantity
                if itemData.Count > 1 then
                    slot.Quantity.Text = "x" .. itemData.Count
                    slot.Quantity.Visible = true
                end

                -- Highlight slot
                slot.Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

                -- Store food type
                slot.FoodType = itemData.FoodType

                -- Create invisible button for clicking
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 1, 0)
                button.BackgroundTransparency = 1
                button.Text = ""
                button.ZIndex = 10
                button.Parent = slot.Frame
                slot.Button = button

                -- Handle click
                button.MouseButton1Click:Connect(function()
                    handleSlotClick(i)
                end)

                -- Animate slot appearance
                local originalSize = slot.Frame.Size
                slot.Frame.Size = UDim2.new(0, 70, 0, 50)
                local tween = TweenService:Create(slot.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                    Size = originalSize
                })
                tween:Play()
            end
        end
    end

    -- Clear equipped slot if food no longer exists
    if equippedSlot then
        local slotStillHasFood = false
        for _, itemData in ipairs(inventoryData) do
            if inventorySlots[equippedSlot].FoodType == itemData.FoodType then
                slotStillHasFood = true
                break
            end
        end

        if not slotStillHasFood then
            inventorySlots[equippedSlot].EquippedIndicator.Visible = false
            equippedSlot = nil
        end
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

print("[InventoryUI] Hotbar-style inventory UI initialized!")
