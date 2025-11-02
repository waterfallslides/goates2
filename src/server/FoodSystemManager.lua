--[[
    Food System Manager
    Main server script that orchestrates all food-related systems
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load modules
local DayNightCycle = require(script.Parent.DayNightCycle)
local FoodSpawner = require(script.Parent.FoodSpawner)
local PlayerInventory = require(script.Parent.PlayerInventory)

print("[FoodSystemManager] Initializing Food System...")

-- Initialize systems
local dayNightCycle = DayNightCycle.new()
local foodSpawner = FoodSpawner.new()
local playerInventory = PlayerInventory.new()

-- Create RemoteFunction for food collection
local collectFoodFunction = ReplicatedStorage:FindFirstChild("CollectFood")
if not collectFoodFunction then
    collectFoodFunction = Instance.new("RemoteFunction")
    collectFoodFunction.Name = "CollectFood"
    collectFoodFunction.Parent = ReplicatedStorage
end

-- Create RemoteFunction for food consumption
local consumeFoodFunction = ReplicatedStorage:FindFirstChild("ConsumeFood")
if not consumeFoodFunction then
    consumeFoodFunction = Instance.new("RemoteFunction")
    consumeFoodFunction.Name = "ConsumeFood"
    consumeFoodFunction.Parent = ReplicatedStorage
end

-- Handle food collection requests from clients
collectFoodFunction.OnServerInvoke = function(player, foodItem)
    -- Validate input
    if not player or not player.Parent then
        return false
    end

    if not foodItem or not foodItem.Parent then
        return false
    end

    if not (foodItem:IsA("Model") or foodItem:IsA("BasePart")) then
        warn("[FoodSystemManager] Invalid food item type from player:", player.Name)
        return false
    end

    -- Get food type (check both Model and PrimaryPart)
    local foodType = foodItem:GetAttribute("FoodType")

    if not foodType and foodItem:IsA("Model") and foodItem.PrimaryPart then
        foodType = foodItem.PrimaryPart:GetAttribute("FoodType")
    end

    if not foodType then
        warn("[FoodSystemManager] Food item missing FoodType attribute")
        return false
    end

    -- Check if already collected (check both)
    local collected = foodItem:GetAttribute("Collected")
    if not collected and foodItem:IsA("Model") and foodItem.PrimaryPart then
        collected = foodItem.PrimaryPart:GetAttribute("Collected")
    end

    if collected == true then
        return false
    end

    -- Try to collect food (checks inventory limits)
    local success, reason = playerInventory:CollectFood(player, foodType)

    if success then
        -- Remove food from world
        foodSpawner:RemoveFood(foodItem)
        print("[FoodSystemManager]", player.Name, "collected", foodType)
        return true
    else
        print("[FoodSystemManager]", player.Name, "failed to collect", foodType, "-", reason)
        return false
    end
end

-- Handle food consumption requests from clients
consumeFoodFunction.OnServerInvoke = function(player, foodType)
    if not foodType then
        warn("[FoodSystemManager] Invalid food type from player:", player.Name)
        return false
    end

    -- Try to consume food from inventory
    local success, reason = playerInventory:ConsumeFood(player, foodType)

    if success then
        print("[FoodSystemManager]", player.Name, "consumed", foodType)
        return true
    else
        print("[FoodSystemManager]", player.Name, "failed to consume", foodType, "-", reason or "unknown error")
        return false
    end
end

-- Connect day/night events to food spawning
dayNightCycle:OnDayStart(function()
    print("[FoodSystemManager] Day started - spawning food!")
    foodSpawner:SpawnFoodBatch()

    local stats = foodSpawner:GetStats()
    print("[FoodSystemManager] Active food:", stats.ActiveFood, "Pool:", stats.PoolSize)
end)

dayNightCycle:OnNightStart(function()
    print("[FoodSystemManager] Night started - clearing food!")
    foodSpawner:ClearAllFood()

    local stats = foodSpawner:GetStats()
    print("[FoodSystemManager] Active food:", stats.ActiveFood, "Pool:", stats.PoolSize)
end)

-- Optional: Print stats periodically
task.spawn(function()
    while true do
        task.wait(60)  -- Every minute

        local foodStats = foodSpawner:GetStats()
        local cycleState = dayNightCycle:GetState()

        print(string.format(
            "[FoodSystemManager] Stats - Active Food: %d | Pool: %d | %s - %.0fs remaining",
            foodStats.ActiveFood,
            foodStats.PoolSize,
            cycleState.IsDay and "DAY" or "NIGHT",
            cycleState.TimeRemaining
        ))
    end
end)

-- Start the day/night cycle
dayNightCycle:Start()

print("[FoodSystemManager] Food System fully initialized and running!")

-- Return manager for external access if needed
return {
    DayNightCycle = dayNightCycle,
    FoodSpawner = foodSpawner,
    PlayerInventory = playerInventory
}
