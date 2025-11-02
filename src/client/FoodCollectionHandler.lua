--[[
    Food Collection Handler (Client-Side)
    Handles food collection interactions and sends requests to server
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Wait for Remote Events folder
local eventsFolder = ReplicatedStorage:WaitForChild("GameStateEvents", 10)
if not eventsFolder then
    warn("[FoodCollectionHandler] GameStateEvents folder not found!")
    return
end

-- Create remote function for collection requests
local FoodFolder = Workspace:WaitForChild("FoodItems", 10)

-- Remote Function for requesting food collection
local CollectFoodFunction = Instance.new("RemoteFunction")
CollectFoodFunction.Name = "CollectFood"

-- Find or create in ReplicatedStorage
local existingFunction = ReplicatedStorage:FindFirstChild("CollectFood")
if existingFunction then
    CollectFoodFunction = existingFunction
else
    CollectFoodFunction.Parent = ReplicatedStorage
end

-- Listen for Remote Events
local FoodCollectedEvent = eventsFolder:WaitForChild("FoodCollected", 5)
local CollectionFailedEvent = eventsFolder:WaitForChild("CollectionFailed", 5)

-- Notification display
local function showNotification(message, success)
    local PlayerGui = player:WaitForChild("PlayerGui")

    -- Create or get notification ScreenGui
    local notificationGui = PlayerGui:FindFirstChild("FoodNotifications")
    if not notificationGui then
        notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "FoodNotifications"
        notificationGui.ResetOnSpawn = false
        notificationGui.DisplayOrder = 10
        notificationGui.Parent = PlayerGui
    end

    -- Create notification frame
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(0.5, -150, 0.85, 0)
    notification.BackgroundColor3 = success and Color3.fromRGB(46, 125, 50) or Color3.fromRGB(198, 40, 40)
    notification.BorderSizePixel = 0
    notification.Parent = notificationGui

    -- Round corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification

    -- Message label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = notification

    -- Animate in
    notification.BackgroundTransparency = 1
    label.TextTransparency = 1

    local tweenService = game:GetService("TweenService")
    local fadeIn = tweenService:Create(notification, TweenInfo.new(0.3), { BackgroundTransparency = 0 })
    local textFadeIn = tweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 0 })

    fadeIn:Play()
    textFadeIn:Play()

    -- Animate out after delay
    task.delay(2, function()
        local fadeOut = tweenService:Create(notification, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
        local textFadeOut = tweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 1 })

        fadeOut:Play()
        textFadeOut:Play()

        fadeOut.Completed:Wait()
        notification:Destroy()
    end)
end

-- Handle food collection success
if FoodCollectedEvent then
    FoodCollectedEvent.OnClientEvent:Connect(function(foodType, displayName)
        showNotification("✓ Collected " .. displayName, true)
        print("[FoodCollectionHandler] Collected:", displayName)
    end)
end

-- Handle food collection failure
if CollectionFailedEvent then
    CollectionFailedEvent.OnClientEvent:Connect(function(reason)
        showNotification("✗ " .. reason, false)
        print("[FoodCollectionHandler] Collection failed:", reason)
    end)
end

-- Setup food item interaction
local function setupFoodItem(foodItem)
    -- Handle both Models and Parts
    local primaryPart = nil
    if foodItem:IsA("Model") then
        primaryPart = foodItem.PrimaryPart
    elseif foodItem:IsA("BasePart") then
        primaryPart = foodItem
    end

    if not primaryPart then
        warn("[FoodCollectionHandler] Food item has no primary part:", foodItem.Name)
        return
    end

    -- Click Detector (search in primary part)
    local clickDetector = primaryPart:FindFirstChild("ClickDetector", true)
    if clickDetector then
        clickDetector.MouseClick:Connect(function(clickingPlayer)
            if clickingPlayer == player then
                local foodType = foodItem:GetAttribute("FoodType")
                if foodType and not foodItem:GetAttribute("Collected") then
                    -- Request collection from server
                    local success = CollectFoodFunction:InvokeServer(foodItem)
                end
            end
        end)
    end

    -- Proximity Prompt (search in primary part or descendants)
    local proximityPrompt = primaryPart:FindFirstChild("ProximityPrompt", true)
    if proximityPrompt then
        proximityPrompt.Triggered:Connect(function(triggeringPlayer)
            if triggeringPlayer == player then
                local foodType = foodItem:GetAttribute("FoodType")
                if foodType and not foodItem:GetAttribute("Collected") then
                    -- Request collection from server
                    local success = CollectFoodFunction:InvokeServer(foodItem)
                end
            end
        end)
    end
end

-- Monitor for new food items
if FoodFolder then
    -- Setup existing food items
    for _, foodItem in ipairs(FoodFolder:GetChildren()) do
        if foodItem:IsA("Model") or foodItem:IsA("BasePart") then
            setupFoodItem(foodItem)
        end
    end

    -- Setup new food items as they spawn
    FoodFolder.ChildAdded:Connect(function(child)
        if child:IsA("Model") or child:IsA("BasePart") then
            task.wait(0.1)  -- Small delay to ensure everything is set up
            setupFoodItem(child)
        end
    end)

    print("[FoodCollectionHandler] Monitoring food items in FoodItems folder")
else
    warn("[FoodCollectionHandler] FoodItems folder not found in Workspace!")
end

print("[FoodCollectionHandler] Client-side food collection initialized!")
