--[[
    Food Spawner System with Object Pooling
    Manages spawning, pooling, and cleanup of food items
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- Load food configuration
local FoodConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FoodConfig"))

local FoodSpawner = {}
FoodSpawner.__index = FoodSpawner

-- Configuration
local POOL_SIZE = 50          -- Total pool size for all food types
local SPAWN_COUNT_DAY = 30    -- Number of food items to spawn during day
local SPAWN_AREA_SIZE = 200   -- Size of spawn area (200x200 studs)
local SPAWN_HEIGHT = 50       -- Height to spawn food at (will fall down)

function FoodSpawner.new()
    local self = setmetatable({}, FoodSpawner)

    self.FoodPool = {}           -- Pool of inactive food objects
    self.ActiveFood = {}         -- Currently active food in world
    self.FoodFolder = nil        -- Folder to hold all food items
    self.SpawnAreaCenter = Vector3.new(0, SPAWN_HEIGHT, 0)  -- Default center

    self:Initialize()

    return self
end

-- Initialize the food system
function FoodSpawner:Initialize()
    -- Create folder for food items in workspace
    self.FoodFolder = Workspace:FindFirstChild("FoodItems")
    if not self.FoodFolder then
        self.FoodFolder = Instance.new("Folder")
        self.FoodFolder.Name = "FoodItems"
        self.FoodFolder.Parent = Workspace
    end

    -- Pre-create pool of food objects
    self:CreatePool()

    print("[FoodSpawner] Initialized with pool size:", POOL_SIZE)
end

-- Create the object pool
function FoodSpawner:CreatePool()
    for i = 1, POOL_SIZE do
        local foodItem = self:CreateFoodObject()
        foodItem.Parent = nil  -- Keep in memory but not in workspace
        table.insert(self.FoodPool, foodItem)
    end
end

-- Create a single food object (reusable template)
function FoodSpawner:CreateFoodObject()
    local part = Instance.new("Part")
    part.Name = "Food"
    part.Anchored = false
    part.CanCollide = true
    part.Material = Enum.Material.SmoothPlastic
    part.Shape = Enum.PartType.Block
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth

    -- Add click detector for collection
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 10
    clickDetector.Parent = part

    -- Add proximity prompt for mobile/console support
    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.ActionText = "Collect"
    proximityPrompt.ObjectText = "Food"
    proximityPrompt.MaxActivationDistance = 10
    proximityPrompt.HoldDuration = 0.3
    proximityPrompt.Parent = part

    -- Add billboard GUI for display name
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FoodLabel"
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Food"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.5
    label.Parent = billboard

    -- Add sparkle effect
    local sparkle = Instance.new("Sparkles")
    sparkle.SparkleColor = Color3.new(1, 1, 0)
    sparkle.Enabled = true
    sparkle.Parent = part

    return part
end

-- Get a food object from pool
function FoodSpawner:GetFromPool()
    if #self.FoodPool > 0 then
        return table.remove(self.FoodPool)
    end

    -- Pool exhausted, create new object
    warn("[FoodSpawner] Pool exhausted, creating new food object")
    return self:CreateFoodObject()
end

-- Return food object to pool
function FoodSpawner:ReturnToPool(foodItem)
    -- Remove from active list
    local index = table.find(self.ActiveFood, foodItem)
    if index then
        table.remove(self.ActiveFood, index)
    end

    -- Reset and return to pool
    foodItem.Parent = nil
    foodItem:SetAttribute("FoodType", nil)
    foodItem:SetAttribute("Collected", nil)

    table.insert(self.FoodPool, foodItem)
end

-- Configure food item with specific type
function FoodSpawner:ConfigureFoodItem(foodItem, foodType)
    local foodData = FoodConfig.FoodTypes[foodType]
    if not foodData then
        warn("[FoodSpawner] Invalid food type:", foodType)
        return
    end

    -- Set attributes for identification
    foodItem:SetAttribute("FoodType", foodType)
    foodItem:SetAttribute("Collected", false)

    -- Set appearance
    foodItem.Size = foodData.Size
    foodItem.Color = foodData.Color

    -- Update label
    local billboard = foodItem:FindFirstChild("FoodLabel")
    if billboard then
        local label = billboard:FindFirstChild("TextLabel")
        if label then
            label.Text = foodData.DisplayName
        end
    end

    -- Update sparkle color based on rarity
    local sparkle = foodItem:FindFirstChild("Sparkles")
    if sparkle then
        if foodData.Rarity == "common" then
            sparkle.SparkleColor = Color3.fromRGB(200, 200, 200)  -- White
        elseif foodData.Rarity == "uncommon" then
            sparkle.SparkleColor = Color3.fromRGB(100, 255, 100)  -- Green
        elseif foodData.Rarity == "rare" then
            sparkle.SparkleColor = Color3.fromRGB(255, 215, 0)    -- Gold
        end
    end

    -- Update proximity prompt
    local prompt = foodItem:FindFirstChild("ProximityPrompt")
    if prompt then
        prompt.ObjectText = foodData.DisplayName
    end
end

-- Get random spawn position within area
function FoodSpawner:GetRandomSpawnPosition()
    local halfSize = SPAWN_AREA_SIZE / 2
    local randomX = math.random(-halfSize, halfSize)
    local randomZ = math.random(-halfSize, halfSize)

    return self.SpawnAreaCenter + Vector3.new(randomX, 0, randomZ)
end

-- Spawn a single food item
function FoodSpawner:SpawnFood(foodType, position)
    local foodItem = self:GetFromPool()
    self:ConfigureFoodItem(foodItem, foodType)

    -- Set position and add to world
    foodItem.Position = position or self:GetRandomSpawnPosition()
    foodItem.Parent = self.FoodFolder

    -- Add to active list
    table.insert(self.ActiveFood, foodItem)

    return foodItem
end

-- Spawn multiple food items
function FoodSpawner:SpawnFoodBatch(count)
    count = count or SPAWN_COUNT_DAY

    print("[FoodSpawner] Spawning", count, "food items...")

    for i = 1, count do
        local foodType = FoodConfig:GetRandomFoodType()
        local position = self:GetRandomSpawnPosition()

        self:SpawnFood(foodType, position)

        -- Small delay to avoid lag spike
        if i % 10 == 0 then
            task.wait()
        end
    end

    print("[FoodSpawner] Spawned", count, "food items. Active:", #self.ActiveFood, "Pool:", #self.FoodPool)
end

-- Remove all active food items
function FoodSpawner:ClearAllFood()
    print("[FoodSpawner] Clearing all food items...")

    local count = #self.ActiveFood

    -- Return all active food to pool
    while #self.ActiveFood > 0 do
        local foodItem = self.ActiveFood[1]
        self:ReturnToPool(foodItem)
    end

    print("[FoodSpawner] Cleared", count, "food items. Pool:", #self.FoodPool)
end

-- Remove a specific food item (when collected)
function FoodSpawner:RemoveFood(foodItem)
    if foodItem and foodItem:GetAttribute("Collected") ~= true then
        foodItem:SetAttribute("Collected", true)
        self:ReturnToPool(foodItem)
        return true
    end
    return false
end

-- Set spawn area center
function FoodSpawner:SetSpawnArea(center, size)
    self.SpawnAreaCenter = center or self.SpawnAreaCenter
    SPAWN_AREA_SIZE = size or SPAWN_AREA_SIZE

    print("[FoodSpawner] Spawn area set to center:", self.SpawnAreaCenter, "size:", SPAWN_AREA_SIZE)
end

-- Get statistics
function FoodSpawner:GetStats()
    return {
        ActiveFood = #self.ActiveFood,
        PoolSize = #self.FoodPool,
        TotalObjects = #self.ActiveFood + #self.FoodPool
    }
end

return FoodSpawner
