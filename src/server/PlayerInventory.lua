--[[
    Player Inventory System
    Manages player inventory with food collection limits and consumption
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load food configuration
local FoodConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FoodConfig"))

local PlayerInventory = {}
PlayerInventory.__index = PlayerInventory

function PlayerInventory.new()
    local self = setmetatable({}, PlayerInventory)

    -- Player inventory storage
    -- Structure: [player] = { [foodType] = count }
    self.Inventories = {}

    -- Player stats storage
    -- Structure: [player] = { Health = 100, Hunger = 100, MaxHealth = 100, MaxHunger = 100 }
    self.PlayerStats = {}

    -- Create or get Remote Events
    local eventsFolder = ReplicatedStorage:FindFirstChild("GameStateEvents")
    if not eventsFolder then
        eventsFolder = Instance.new("Folder")
        eventsFolder.Name = "GameStateEvents"
        eventsFolder.Parent = ReplicatedStorage
    end

    -- Remote Events
    self.InventoryUpdateEvent = self:GetOrCreateEvent(eventsFolder, "InventoryUpdate")
    self.StatsUpdateEvent = self:GetOrCreateEvent(eventsFolder, "StatsUpdate")
    self.FoodCollectedEvent = self:GetOrCreateEvent(eventsFolder, "FoodCollected")
    self.CollectionFailedEvent = self:GetOrCreateEvent(eventsFolder, "CollectionFailed")

    -- Initialize for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:InitializePlayer(player)
    end

    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        self:InitializePlayer(player)
    end)

    -- Cleanup when player leaves
    Players.PlayerRemoving:Connect(function(player)
        self:CleanupPlayer(player)
    end)

    print("[PlayerInventory] System initialized!")

    return self
end

-- Helper to get or create remote event
function PlayerInventory:GetOrCreateEvent(parent, name)
    local event = parent:FindFirstChild(name)
    if not event then
        event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = parent
    end
    return event
end

-- Initialize player inventory and stats
function PlayerInventory:InitializePlayer(player)
    -- Initialize empty inventory
    self.Inventories[player] = {}

    -- Initialize stats
    self.PlayerStats[player] = {
        Health = 100,
        Hunger = 100,
        MaxHealth = 100,
        MaxHunger = 100
    }

    -- Send initial data to client
    self:SendInventoryUpdate(player)
    self:SendStatsUpdate(player)

    print("[PlayerInventory] Initialized inventory for player:", player.Name)
end

-- Cleanup player data
function PlayerInventory:CleanupPlayer(player)
    self.Inventories[player] = nil
    self.PlayerStats[player] = nil

    print("[PlayerInventory] Cleaned up inventory for player:", player.Name)
end

-- Get player inventory
function PlayerInventory:GetInventory(player)
    return self.Inventories[player] or {}
end

-- Get player stats
function PlayerInventory:GetStats(player)
    return self.PlayerStats[player] or { Health = 100, Hunger = 100, MaxHealth = 100, MaxHunger = 100 }
end

-- Count different food types in inventory
function PlayerInventory:GetInventoryTypeCount(player)
    local inventory = self:GetInventory(player)
    local count = 0

    for foodType, amount in pairs(inventory) do
        if amount > 0 then
            count = count + 1
        end
    end

    return count
end

-- Check if player can collect food
function PlayerInventory:CanCollectFood(player, foodType)
    local inventory = self:GetInventory(player)
    local currentTypeCount = self:GetInventoryTypeCount(player)
    local maxTypes = FoodConfig.InventoryLimits.MaxDifferentTypes

    -- Check if food type already in inventory
    if inventory[foodType] and inventory[foodType] > 0 then
        -- Check stack limit
        local foodData = FoodConfig.FoodTypes[foodType]
        if foodData and inventory[foodType] >= foodData.MaxStack then
            return false, "Stack limit reached for " .. foodData.DisplayName
        end
        return true
    end

    -- Check if player has room for new food type
    if currentTypeCount >= maxTypes then
        return false, "Inventory full! Max " .. maxTypes .. " different food types"
    end

    return true
end

-- Add food to player inventory
function PlayerInventory:CollectFood(player, foodType)
    local canCollect, reason = self:CanCollectFood(player, foodType)

    if not canCollect then
        -- Notify player of failure
        self.CollectionFailedEvent:FireClient(player, reason)
        return false, reason
    end

    local inventory = self:GetInventory(player)
    local foodData = FoodConfig.FoodTypes[foodType]

    if not foodData then
        warn("[PlayerInventory] Invalid food type:", foodType)
        return false, "Invalid food type"
    end

    -- Add to inventory
    inventory[foodType] = (inventory[foodType] or 0) + 1

    -- Send updates to client
    self:SendInventoryUpdate(player)
    self.FoodCollectedEvent:FireClient(player, foodType, foodData.DisplayName)

    print("[PlayerInventory]", player.Name, "collected", foodData.DisplayName, "- Count:", inventory[foodType])

    return true
end

-- Remove food from inventory (when consumed)
function PlayerInventory:RemoveFood(player, foodType, amount)
    amount = amount or 1

    local inventory = self:GetInventory(player)

    if not inventory[foodType] or inventory[foodType] < amount then
        return false, "Not enough " .. foodType
    end

    inventory[foodType] = inventory[foodType] - amount

    -- Remove entry if count reaches 0
    if inventory[foodType] <= 0 then
        inventory[foodType] = nil
    end

    self:SendInventoryUpdate(player)

    return true
end

-- Consume food (restore health and hunger)
function PlayerInventory:ConsumeFood(player, foodType)
    local inventory = self:GetInventory(player)

    if not inventory[foodType] or inventory[foodType] <= 0 then
        return false, "Don't have any " .. foodType
    end

    local foodData = FoodConfig.FoodTypes[foodType]
    if not foodData then
        return false, "Invalid food type"
    end

    -- Remove from inventory
    local removed, reason = self:RemoveFood(player, foodType, 1)
    if not removed then
        return false, reason
    end

    -- Restore health and hunger
    local stats = self:GetStats(player)
    stats.Health = math.min(stats.MaxHealth, stats.Health + foodData.HealthRestore)
    stats.Hunger = math.min(stats.MaxHunger, stats.Hunger + foodData.HungerRestore)

    -- Update player's actual health if they have a humanoid
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + foodData.HealthRestore)
        end
    end

    -- Send updates
    self:SendStatsUpdate(player)

    print("[PlayerInventory]", player.Name, "consumed", foodData.DisplayName,
          "- Health:", stats.Health, "Hunger:", stats.Hunger)

    return true
end

-- Update player stats (hunger decay, etc.)
function PlayerInventory:UpdateStats(player, healthChange, hungerChange)
    local stats = self:GetStats(player)

    if healthChange then
        stats.Health = math.clamp(stats.Health + healthChange, 0, stats.MaxHealth)
    end

    if hungerChange then
        stats.Hunger = math.clamp(stats.Hunger + hungerChange, 0, stats.MaxHunger)
    end

    self:SendStatsUpdate(player)
end

-- Send inventory update to client
function PlayerInventory:SendInventoryUpdate(player)
    local inventory = self:GetInventory(player)

    -- Convert to serializable format
    local inventoryData = {}
    for foodType, count in pairs(inventory) do
        table.insert(inventoryData, {
            FoodType = foodType,
            Count = count,
            DisplayName = FoodConfig.FoodTypes[foodType].DisplayName
        })
    end

    self.InventoryUpdateEvent:FireClient(player, inventoryData)
end

-- Send stats update to client
function PlayerInventory:SendStatsUpdate(player)
    local stats = self:GetStats(player)
    self.StatsUpdateEvent:FireClient(player, stats)
end

-- Get inventory summary for display
function PlayerInventory:GetInventorySummary(player)
    local inventory = self:GetInventory(player)
    local summary = {}

    for foodType, count in pairs(inventory) do
        local foodData = FoodConfig.FoodTypes[foodType]
        if foodData then
            table.insert(summary, {
                Type = foodType,
                Name = foodData.DisplayName,
                Count = count,
                MaxStack = foodData.MaxStack,
                HealthRestore = foodData.HealthRestore,
                HungerRestore = foodData.HungerRestore
            })
        end
    end

    return summary
end

return PlayerInventory
