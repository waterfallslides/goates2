--[[
    Food Configuration Module
    Defines all food types, their stats, rarities, and spawn weights
]]

local FoodConfig = {}

-- Rarity weights for spawn distribution
FoodConfig.RarityWeights = {
    common = 50,      -- 50% chance
    uncommon = 30,    -- 30% chance
    rare = 20         -- 20% chance
}

-- Food type definitions with stats and properties
FoodConfig.FoodTypes = {
    Bread = {
        Name = "Bread",
        DisplayName = "🍞 Bread",
        HealthRestore = 20,
        HungerRestore = 30,  -- Percentage (30%)
        Rarity = "common",
        Color = Color3.fromRGB(210, 180, 140),  -- Tan
        Size = Vector3.new(2, 1, 2),
        MaxStack = 10
    },
    Apple = {
        Name = "Apple",
        DisplayName = "🍎 Apple",
        HealthRestore = 15,
        HungerRestore = 20,  -- Percentage (20%)
        Rarity = "common",
        Color = Color3.fromRGB(220, 20, 60),  -- Crimson red
        Size = Vector3.new(1.5, 1.5, 1.5),
        MaxStack = 10
    },
    CookedMeat = {
        Name = "CookedMeat",
        DisplayName = "🍖 Cooked Meat",
        HealthRestore = 40,
        HungerRestore = 50,  -- Percentage (50%)
        Rarity = "rare",
        Color = Color3.fromRGB(139, 69, 19),  -- Saddle brown
        Size = Vector3.new(2, 1.5, 2),
        MaxStack = 5
    },
    CannedFood = {
        Name = "CannedFood",
        DisplayName = "🥫 Canned Food",
        HealthRestore = 25,
        HungerRestore = 40,  -- Percentage (40%)
        Rarity = "uncommon",
        Color = Color3.fromRGB(192, 192, 192),  -- Silver
        Size = Vector3.new(1.5, 2, 1.5),
        MaxStack = 8
    },
    WaterBottle = {
        Name = "WaterBottle",
        DisplayName = "💧 Water Bottle",
        HealthRestore = 10,
        HungerRestore = 25,  -- Percentage (25%)
        Rarity = "uncommon",
        Color = Color3.fromRGB(135, 206, 250),  -- Light sky blue
        Size = Vector3.new(1, 2.5, 1),
        MaxStack = 10
    }
}

-- Inventory limits
FoodConfig.InventoryLimits = {
    MaxDifferentTypes = 3,  -- Maximum 3 different food types
}

-- Get food by rarity tier
function FoodConfig:GetFoodByRarity(rarity)
    local foods = {}
    for name, data in pairs(self.FoodTypes) do
        if data.Rarity == rarity then
            table.insert(foods, name)
        end
    end
    return foods
end

-- Get random food type based on rarity weights
function FoodConfig:GetRandomFoodType()
    local totalWeight = 0
    for _, weight in pairs(self.RarityWeights) do
        totalWeight = totalWeight + weight
    end

    local random = math.random(1, totalWeight)
    local currentWeight = 0

    for rarity, weight in pairs(self.RarityWeights) do
        currentWeight = currentWeight + weight
        if random <= currentWeight then
            local foodsInRarity = self:GetFoodByRarity(rarity)
            if #foodsInRarity > 0 then
                return foodsInRarity[math.random(1, #foodsInRarity)]
            end
        end
    end

    -- Fallback to random food
    local allFoods = {}
    for name, _ in pairs(self.FoodTypes) do
        table.insert(allFoods, name)
    end
    return allFoods[math.random(1, #allFoods)]
end

return FoodConfig
