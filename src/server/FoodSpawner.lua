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
local SPAWN_HEIGHT = 100      -- Height to spawn food at (will fall down)
local MIN_SPAWN_DISTANCE = 10 -- Minimum distance between food spawns (studs)

function FoodSpawner.new()
    local self = setmetatable({}, FoodSpawner)

    self.FoodPool = {}           -- Pool of inactive food objects
    self.ActiveFood = {}         -- Currently active food in world
    self.FoodFolder = nil        -- Folder to hold all food items
    self.FoodModelsFolder = nil  -- Folder containing custom food models
    self.SpawnAreaCenter = Vector3.new(0, SPAWN_HEIGHT, 0)  -- Default center
    self.SpawnPositions = {}     -- Track spawn positions to avoid overlap

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

    -- Look for custom food models in ReplicatedStorage
    self.FoodModelsFolder = ReplicatedStorage:FindFirstChild("FoodModels")

    if self.FoodModelsFolder then
        print("[FoodSpawner] Using custom food models from ReplicatedStorage/FoodModels")
    else
        warn("[FoodSpawner] FoodModels folder not found in ReplicatedStorage! Using default parts.")
        warn("[FoodSpawner] Create a 'FoodModels' folder in ReplicatedStorage with food models named: Bread, Apple, CookedMeat, CannedFood, WaterBottle")
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
    -- This is now just a placeholder - actual models set during Configure
    local model = Instance.new("Model")
    model.Name = "Food"

    -- Create a primary part placeholder (will be replaced by actual model)
    local primaryPart = Instance.new("Part")
    primaryPart.Name = "PrimaryPart"
    primaryPart.Size = Vector3.new(2, 2, 2)
    primaryPart.Anchored = false
    primaryPart.CanCollide = true
    primaryPart.Parent = model
    model.PrimaryPart = primaryPart

    return model
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

    -- Clear existing contents
    foodItem:ClearAllChildren()

    -- Try to use custom model first
    local customModel = nil
    if self.FoodModelsFolder then
        customModel = self.FoodModelsFolder:FindFirstChild(foodType)
    end

    local mainPart = nil

    if customModel then
        -- Check if custom model is a single Part/MeshPart or a Model
        if customModel:IsA("BasePart") then
            -- It's a single part (MeshPart or Part)
            local clonedPart = customModel:Clone()
            clonedPart.Name = "FoodPart"
            clonedPart.Anchored = false
            clonedPart.CanCollide = true
            clonedPart.Parent = foodItem
            foodItem.PrimaryPart = clonedPart
            mainPart = clonedPart
        else
            -- It's a Model - clone all children
            for _, child in ipairs(customModel:GetChildren()) do
                child:Clone().Parent = foodItem
            end

            -- Find or create primary part
            local primaryPart = foodItem:FindFirstChildWhichIsA("BasePart") or foodItem:FindFirstChild("PrimaryPart")
            if primaryPart then
                foodItem.PrimaryPart = primaryPart
                mainPart = primaryPart
            end
        end
    else
        -- Fallback: Create default part
        local part = Instance.new("Part")
        part.Name = "FoodPart"
        part.Size = foodData.Size
        part.Color = foodData.Color
        part.Anchored = false
        part.CanCollide = true
        part.Material = Enum.Material.SmoothPlastic
        part.TopSurface = Enum.SurfaceType.Smooth
        part.BottomSurface = Enum.SurfaceType.Smooth
        part.Parent = foodItem
        foodItem.PrimaryPart = part
        mainPart = part

        -- Add sparkle effect for fallback
        local sparkle = Instance.new("Sparkles")
        if foodData.Rarity == "common" then
            sparkle.SparkleColor = Color3.fromRGB(200, 200, 200)
        elseif foodData.Rarity == "uncommon" then
            sparkle.SparkleColor = Color3.fromRGB(100, 255, 100)
        elseif foodData.Rarity == "rare" then
            sparkle.SparkleColor = Color3.fromRGB(255, 215, 0)
        end
        sparkle.Parent = part
    end

    -- Set attributes for identification (on the model itself)
    foodItem:SetAttribute("FoodType", foodType)
    foodItem:SetAttribute("Collected", false)

    -- Ensure primary part exists
    if not mainPart or not foodItem.PrimaryPart then
        warn("[FoodSpawner] No PrimaryPart found for", foodType)
        return
    end

    -- Add click detector to primary part if not exists
    local clickDetector = mainPart:FindFirstChild("ClickDetector")
    if not clickDetector then
        clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 10
        clickDetector.Parent = mainPart
    end

    -- Add proximity prompt to primary part if not exists
    local proximityPrompt = mainPart:FindFirstChild("ProximityPrompt")
    if not proximityPrompt then
        proximityPrompt = Instance.new("ProximityPrompt")
        proximityPrompt.ActionText = "Collect"
        proximityPrompt.ObjectText = foodData.DisplayName
        proximityPrompt.MaxActivationDistance = 10
        proximityPrompt.HoldDuration = 0.3
        proximityPrompt.Parent = mainPart
    else
        proximityPrompt.ObjectText = foodData.DisplayName
    end

    -- Add or update billboard GUI
    local billboard = mainPart:FindFirstChild("FoodLabel")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "FoodLabel"
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = mainPart

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = foodData.DisplayName
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0.5
        label.Parent = billboard
    else
        local label = billboard:FindFirstChild("TextLabel")
        if label then
            label.Text = foodData.DisplayName
        end
    end
end

-- Raycast to find ground level
function FoodSpawner:FindGroundPosition(position)
    local rayOrigin = Vector3.new(position.X, position.Y, position.Z)
    local rayDirection = Vector3.new(0, -200, 0)  -- Cast down 200 studs

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {self.FoodFolder}

    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if rayResult then
        -- Found ground, spawn 2 studs above it
        return rayResult.Position + Vector3.new(0, 2, 0)
    else
        -- No ground found, use default height
        return Vector3.new(position.X, 5, position.Z)
    end
end

-- Check if position is too close to existing spawns
function FoodSpawner:IsPositionValid(position)
    for _, existingPos in ipairs(self.SpawnPositions) do
        local distance = (position - existingPos).Magnitude
        if distance < MIN_SPAWN_DISTANCE then
            return false
        end
    end
    return true
end

-- Get random spawn position within area with spacing
function FoodSpawner:GetRandomSpawnPosition()
    local halfSize = SPAWN_AREA_SIZE / 2
    local attempts = 0
    local maxAttempts = 20

    while attempts < maxAttempts do
        -- Generate random X and Z with more spread
        local randomX = math.random(-halfSize, halfSize)
        local randomZ = math.random(-halfSize, halfSize)

        local position = Vector3.new(
            self.SpawnAreaCenter.X + randomX,
            self.SpawnAreaCenter.Y,
            self.SpawnAreaCenter.Z + randomZ
        )

        -- Find ground at this position
        local groundPosition = self:FindGroundPosition(position)

        -- Check if position is valid (not too close to others)
        if self:IsPositionValid(groundPosition) then
            table.insert(self.SpawnPositions, groundPosition)
            return groundPosition
        end

        attempts = attempts + 1
    end

    -- If we couldn't find a good position, just return a random one
    local randomX = math.random(-halfSize, halfSize)
    local randomZ = math.random(-halfSize, halfSize)
    local fallbackPos = Vector3.new(
        self.SpawnAreaCenter.X + randomX,
        self.SpawnAreaCenter.Y,
        self.SpawnAreaCenter.Z + randomZ
    )
    return self:FindGroundPosition(fallbackPos)
end

-- Spawn a single food item
function FoodSpawner:SpawnFood(foodType, position)
    local foodItem = self:GetFromPool()
    self:ConfigureFoodItem(foodItem, foodType)

    -- Set position and add to world
    if foodItem.PrimaryPart then
        foodItem:MoveTo(position or self:GetRandomSpawnPosition())
    end
    foodItem.Parent = self.FoodFolder

    -- Add to active list
    table.insert(self.ActiveFood, foodItem)

    return foodItem
end

-- Spawn multiple food items
function FoodSpawner:SpawnFoodBatch(count)
    count = count or SPAWN_COUNT_DAY

    print("[FoodSpawner] Spawning", count, "food items...")

    -- Clear previous spawn positions
    self.SpawnPositions = {}

    for i = 1, count do
        local foodType = FoodConfig:GetRandomFoodType()
        local position = self:GetRandomSpawnPosition()

        self:SpawnFood(foodType, position)

        -- Small delay to avoid lag spike and allow physics to settle
        if i % 5 == 0 then
            task.wait(0.1)
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

    -- Clear spawn positions tracking
    self.SpawnPositions = {}

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
