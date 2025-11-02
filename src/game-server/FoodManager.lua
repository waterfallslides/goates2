--[[
    ROBLOX BUNKER SURVIVAL - FOOD MANAGER
    Manages food spawning and collection

    Food Types:
    - Bread: +20 HP, +30% hunger (common)
    - Apple: +15 HP, +20% hunger (common)
    - CookedMeat: +40 HP, +50% hunger (rare)
    - CannedFood: +25 HP, +40% hunger (uncommon)
    - WaterBottle: +10 HP, +25% hunger (common)

    Spawning:
    - Uses existing food models from ServerStorage/ReplicatedStorage
    - Random locations across map
    - Same amount regardless of player count
    - New spawn locations each day
    - Removed at night start
]]

local FoodManager = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Configuration
local CONFIG = {
    -- Food spawn amounts per day
    FOOD_COUNTS = {
        Bread = 8,
        Apple = 10,
        CookedMeat = 3,
        CannedFood = 5,
        WaterBottle = 7,
    },

    -- Food rarity (affects spawn distance from center)
    RARITY = {
        Bread = "common",
        Apple = "common",
        CookedMeat = "rare",
        CannedFood = "uncommon",
        WaterBottle = "common",
    },

    -- Spawn area
    SPAWN_AREA_SIZE = 200, -- Studs radius from center
    SPAWN_HEIGHT = 5, -- Height above terrain

    -- Food model properties
    FOOD_COLLECTION_DISTANCE = 10,

    -- Model storage location
    MODELS_FOLDER_NAME = "FoodModels", -- Look for this folder in ServerStorage or ReplicatedStorage
}

-- State
FoodManager.SpawnedFood = {} -- Tracks all spawned food
FoodManager.FoodFolder = nil
FoodManager.FoodModels = {} -- Cache of food models

-- Initialize
function FoodManager:Initialize()
    print("[FoodManager] Initialized")

    -- Create food folder in workspace
    self.FoodFolder = Instance.new("Folder")
    self.FoodFolder.Name = "Food"
    self.FoodFolder.Parent = workspace

    -- Load food models
    self:LoadFoodModels()

    -- Create remote events
    self:CreateRemoteEvents()
end

-- Load food models from storage
function FoodManager:LoadFoodModels()
    -- Try ServerStorage first
    local modelsFolder = ServerStorage:FindFirstChild(CONFIG.MODELS_FOLDER_NAME)

    -- If not in ServerStorage, try ReplicatedStorage
    if not modelsFolder then
        modelsFolder = ReplicatedStorage:FindFirstChild(CONFIG.MODELS_FOLDER_NAME)
    end

    if not modelsFolder then
        warn("[FoodManager] Food models folder '" .. CONFIG.MODELS_FOLDER_NAME .. "' not found!")
        warn("[FoodManager] Please create a folder named '" .. CONFIG.MODELS_FOLDER_NAME .. "' in ServerStorage or ReplicatedStorage")
        warn("[FoodManager] Will use fallback simple models")
        return
    end

    -- Load each food type model
    for foodType, _ in pairs(CONFIG.FOOD_COUNTS) do
        local model = modelsFolder:FindFirstChild(foodType)
        if model then
            self.FoodModels[foodType] = model
            print("[FoodManager] Loaded model for: " .. foodType)
        else
            warn("[FoodManager] Model not found for: " .. foodType)
        end
    end

    print("[FoodManager] Loaded " .. #self.FoodModels .. " food models")
end

-- Create remote events
function FoodManager:CreateRemoteEvents()
    local events = ReplicatedStorage:WaitForChild("GameEvents")

    -- Food collected event
    local foodCollected = Instance.new("RemoteEvent")
    foodCollected.Name = "FoodCollected"
    foodCollected.Parent = events

    -- Handle food collection
    foodCollected.OnServerEvent:Connect(function(player, foodPart)
        self:CollectFood(player, foodPart)
    end)

    print("[FoodManager] Remote events created")
end

-- Spawn all food for the day
function FoodManager:SpawnFood()
    print("[FoodManager] Spawning food for the day...")

    -- Remove any existing food
    self:RemoveAllFood()

    -- Spawn each food type
    for foodType, count in pairs(CONFIG.FOOD_COUNTS) do
        for i = 1, count do
            self:SpawnFoodItem(foodType)
        end
    end

    print("[FoodManager] Spawned " .. #self.SpawnedFood .. " food items")
end

-- Spawn a single food item
function FoodManager:SpawnFoodItem(foodType)
    -- Get random spawn position
    local position = self:GetRandomSpawnPosition(CONFIG.RARITY[foodType])

    local food

    -- Try to clone existing model
    if self.FoodModels[foodType] then
        food = self.FoodModels[foodType]:Clone()
        food.Name = foodType

        -- Position the cloned model
        if food:IsA("Model") and food.PrimaryPart then
            food:SetPrimaryPartCFrame(CFrame.new(position))
        elseif food:IsA("Model") then
            -- If no PrimaryPart, try to find the main part
            local mainPart = food:FindFirstChildWhichIsA("BasePart")
            if mainPart then
                food:MoveTo(position)
            end
        elseif food:IsA("BasePart") then
            food.Position = position
            food.Anchored = true
        end
    else
        -- Fallback: Create simple part if model not found
        warn("[FoodManager] No model found for " .. foodType .. ", using fallback")
        food = Instance.new("Part")
        food.Name = foodType
        food.Size = Vector3.new(2, 2, 2)
        food.Position = position
        food.Anchored = true
        food.CanCollide = false
        food.Material = Enum.Material.SmoothPlastic
        food.Shape = Enum.PartType.Ball
        food.BrickColor = BrickColor.Random()

        -- Add label for fallback
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Size = UDim2.new(0, 100, 0, 40)
        billboardGui.StudsOffset = Vector3.new(0, 2, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = food

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = foodType
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Parent = billboardGui
    end

    -- Add proximity prompt for collection (works on both Models and Parts)
    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.ActionText = "Collect"
    proximityPrompt.ObjectText = foodType
    proximityPrompt.MaxActivationDistance = CONFIG.FOOD_COLLECTION_DISTANCE
    proximityPrompt.HoldDuration = 0
    proximityPrompt.RequiresLineOfSight = false

    -- Find where to parent the proximity prompt
    if food:IsA("Model") then
        local primaryPart = food.PrimaryPart or food:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            proximityPrompt.Parent = primaryPart
        else
            proximityPrompt.Parent = food
        end
    else
        proximityPrompt.Parent = food
    end

    -- Handle proximity prompt
    proximityPrompt.Triggered:Connect(function(player)
        self:CollectFood(player, food)
    end)

    -- Add to folder
    food.Parent = self.FoodFolder

    -- Track spawned food
    table.insert(self.SpawnedFood, food)

    return food
end

-- Get random spawn position based on rarity
function FoodManager:GetRandomSpawnPosition(rarity)
    local spawnRadius = CONFIG.SPAWN_AREA_SIZE

    -- Rare items spawn farther from center
    if rarity == "rare" then
        spawnRadius = spawnRadius * 0.8 -- Further out
    elseif rarity == "uncommon" then
        spawnRadius = spawnRadius * 0.6
    else -- common
        spawnRadius = spawnRadius * 0.4 -- Closer to center
    end

    -- Random position in circle
    local angle = math.random() * math.pi * 2
    local distance = math.random() * spawnRadius

    local x = math.cos(angle) * distance
    local z = math.sin(angle) * distance
    local y = CONFIG.SPAWN_HEIGHT

    -- Check if there's a map center marker
    local mapCenter = workspace:FindFirstChild("MapCenter")
    if mapCenter then
        return mapCenter.Position + Vector3.new(x, y, z)
    else
        return Vector3.new(x, y, z)
    end
end

-- Collect food
function FoodManager:CollectFood(player, foodPart)
    if not foodPart or not foodPart.Parent then
        return -- Already collected
    end

    local foodType = foodPart.Name

    print("[FoodManager] Player " .. player.Name .. " collected " .. foodType)

    -- Add to player's inventory
    -- (This will be handled by InventoryManager when implemented)
    -- For now, just remove the food
    self:AddFoodToInventory(player, foodType)

    -- Remove food from world
    foodPart:Destroy()

    -- Remove from tracking
    for i, food in ipairs(self.SpawnedFood) do
        if food == foodPart then
            table.remove(self.SpawnedFood, i)
            break
        end
    end

    -- Notify client
    local events = ReplicatedStorage:FindFirstChild("GameEvents")
    if events then
        local foodCollected = events:FindFirstChild("FoodCollected")
        if foodCollected then
            foodCollected:FireClient(player, foodType)
        end
    end
end

-- Add food to player inventory (temporary until InventoryManager)
function FoodManager:AddFoodToInventory(player, foodType)
    -- Create inventory folder if it doesn't exist
    local playerData = player:FindFirstChild("PlayerData")
    if not playerData then
        playerData = Instance.new("Folder")
        playerData.Name = "PlayerData"
        playerData.Parent = player
    end

    local inventory = playerData:FindFirstChild("Inventory")
    if not inventory then
        inventory = Instance.new("Folder")
        inventory.Name = "Inventory"
        inventory.Parent = playerData
    end

    -- Check if player already has this food type
    local foodStack = inventory:FindFirstChild(foodType)
    if foodStack then
        -- Increment stack count
        foodStack.Value = foodStack.Value + 1
    else
        -- Create new stack
        foodStack = Instance.new("IntValue")
        foodStack.Name = foodType
        foodStack.Value = 1
        foodStack.Parent = inventory
    end

    print("[FoodManager] Added " .. foodType .. " to " .. player.Name .. "'s inventory (Total: " .. foodStack.Value .. ")")
end

-- Remove all food
function FoodManager:RemoveAllFood()
    print("[FoodManager] Removing all food from map")

    -- Destroy all spawned food
    for _, food in ipairs(self.SpawnedFood) do
        if food and food.Parent then
            food:Destroy()
        end
    end

    -- Clear tracking
    self.SpawnedFood = {}

    -- Clear folder
    if self.FoodFolder then
        self.FoodFolder:ClearAllChildren()
    end
end

-- Get food count
function FoodManager:GetFoodCount()
    return #self.SpawnedFood
end

return FoodManager
