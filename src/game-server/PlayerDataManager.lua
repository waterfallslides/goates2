--[[
    ROBLOX BUNKER SURVIVAL - PLAYER DATA MANAGER
    Manages player health, hunger, and stats

    Hunger System:
    - Drains over time (100% → 0% in 8 minutes walking)
    - Sprinting drains 2x faster
    - Empty hunger = can't sprint + lose 2 HP every 5 seconds

    Health System:
    - 100 HP maximum
    - Death at 0 HP
    - Healing from food
]]

local PlayerDataManager = {}

-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local CONFIG = {
    MAX_HEALTH = 100,
    MAX_HUNGER = 100,
    HUNGER_DRAIN_RATE = 0.208, -- Per second walking (100% in 8 minutes = 480s)
    HUNGER_DRAIN_SPRINT_MULTIPLIER = 2,
    STARVATION_DAMAGE = 2,
    STARVATION_INTERVAL = 5, -- Seconds between starvation damage
}

-- State
PlayerDataManager.Players = {} -- Tracks player data
PlayerDataManager.GameManager = nil

-- Initialize
function PlayerDataManager:Initialize(gameManager)
    self.GameManager = gameManager
    print("[PlayerDataManager] Initialized")

    -- Create remote events
    self:CreateRemoteEvents()

    -- Setup player connections
    game.Players.PlayerAdded:Connect(function(player)
        self:SetupPlayer(player)
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        self:RemovePlayer(player)
    end)

    -- Start update loop
    self:StartUpdateLoop()
end

-- Create remote events
function PlayerDataManager:CreateRemoteEvents()
    local events = ReplicatedStorage:WaitForChild("GameEvents")

    -- Health update
    local healthUpdate = Instance.new("RemoteEvent")
    healthUpdate.Name = "HealthUpdate"
    healthUpdate.Parent = events

    -- Hunger update
    local hungerUpdate = Instance.new("RemoteEvent")
    hungerUpdate.Name = "HungerUpdate"
    hungerUpdate.Parent = events

    -- Eat food (client requests)
    local eatFood = Instance.new("RemoteEvent")
    eatFood.Name = "EatFood"
    eatFood.Parent = events

    -- Handle eat food requests
    eatFood.OnServerEvent:Connect(function(player, foodType)
        self:EatFood(player, foodType)
    end)

    print("[PlayerDataManager] Remote events created")
end

-- Setup player
function PlayerDataManager:SetupPlayer(player)
    print("[PlayerDataManager] Setting up player:", player.Name)

    -- Wait for character
    player.CharacterAdded:Connect(function(character)
        self:OnCharacterAdded(player, character)
    end)

    if player.Character then
        self:OnCharacterAdded(player, player.Character)
    end

    -- Initialize player tracking data
    self.Players[player.UserId] = {
        Player = player,
        Hunger = 100,
        StarvationTimer = 0,
        LastSprintState = false,
    }
end

-- Character added
function PlayerDataManager:OnCharacterAdded(player, character)
    local humanoid = character:WaitForChild("Humanoid")

    -- Set max health
    humanoid.MaxHealth = CONFIG.MAX_HEALTH
    humanoid.Health = CONFIG.MAX_HEALTH

    -- Handle death
    humanoid.Died:Connect(function()
        self:OnPlayerDeath(player)
    end)

    -- Monitor health changes
    humanoid.HealthChanged:Connect(function(health)
        self:OnHealthChanged(player, health)
    end)

    print("[PlayerDataManager] Character setup for:", player.Name)
end

-- Remove player
function PlayerDataManager:RemovePlayer(player)
    self.Players[player.UserId] = nil
end

-- Start update loop for hunger
function PlayerDataManager:StartUpdateLoop()
    RunService.Heartbeat:Connect(function(deltaTime)
        for userId, data in pairs(self.Players) do
            if data.Player and data.Player.Character then
                self:UpdateHunger(data, deltaTime)
            end
        end
    end)
end

-- Update hunger for a player
function PlayerDataManager:UpdateHunger(playerData, deltaTime)
    local player = playerData.Player
    if not player or not player.Character then return end

    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    -- Check if sprinting
    local isSprinting = false
    if humanoid.WalkSpeed > 16 then -- Default walk speed is 16
        isSprinting = true
    end

    -- Calculate hunger drain
    local drainRate = CONFIG.HUNGER_DRAIN_RATE
    if isSprinting then
        drainRate = drainRate * CONFIG.HUNGER_DRAIN_SPRINT_MULTIPLIER
    end

    -- Drain hunger
    playerData.Hunger = math.max(0, playerData.Hunger - (drainRate * deltaTime))

    -- Handle empty hunger
    if playerData.Hunger <= 0 then
        -- Prevent sprinting
        if humanoid.WalkSpeed > 16 then
            humanoid.WalkSpeed = 16 -- Reset to walk speed
        end

        -- Starvation damage
        playerData.StarvationTimer = playerData.StarvationTimer + deltaTime
        if playerData.StarvationTimer >= CONFIG.STARVATION_INTERVAL then
            humanoid.Health = humanoid.Health - CONFIG.STARVATION_DAMAGE
            playerData.StarvationTimer = 0
            print("[PlayerDataManager] Starvation damage to:", player.Name)
        end
    else
        playerData.StarvationTimer = 0
    end

    -- Update client every second
    if math.floor(tick()) % 1 == 0 then
        self:SendHungerUpdate(player, playerData.Hunger)
    end
end

-- Player ate food
function PlayerDataManager:EatFood(player, foodType)
    local playerData = self.Players[player.UserId]
    if not playerData then return end

    -- Get food data
    local foodData = self:GetFoodData(foodType)
    if not foodData then
        warn("[PlayerDataManager] Unknown food type:", foodType)
        return
    end

    -- Check if player has this food in inventory
    -- (This will be handled by InventoryManager later)
    -- For now, just apply effects

    -- Restore hunger
    playerData.Hunger = math.min(CONFIG.MAX_HUNGER, playerData.Hunger + foodData.HungerRestore)

    -- Heal player
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + foodData.HealthRestore)
        end
    end

    print("[PlayerDataManager] Player " .. player.Name .. " ate " .. foodType)

    -- Send updates
    self:SendHungerUpdate(player, playerData.Hunger)
end

-- Get food data
function PlayerDataManager:GetFoodData(foodType)
    local foodDatabase = {
        Bread = { HealthRestore = 20, HungerRestore = 30 },
        Apple = { HealthRestore = 15, HungerRestore = 20 },
        CookedMeat = { HealthRestore = 40, HungerRestore = 50 },
        CannedFood = { HealthRestore = 25, HungerRestore = 40 },
        WaterBottle = { HealthRestore = 10, HungerRestore = 25 },
    }

    return foodDatabase[foodType]
end

-- Send hunger update to client
function PlayerDataManager:SendHungerUpdate(player, hunger)
    local events = ReplicatedStorage:FindFirstChild("GameEvents")
    if not events then return end

    local hungerUpdate = events:FindFirstChild("HungerUpdate")
    if hungerUpdate then
        hungerUpdate:FireClient(player, hunger)
    end
end

-- Send health update to client
function PlayerDataManager:SendHealthUpdate(player, health)
    local events = ReplicatedStorage:FindFirstChild("GameEvents")
    if not events then return end

    local healthUpdate = events:FindFirstChild("HealthUpdate")
    if healthUpdate then
        healthUpdate:FireClient(player, health)
    end
end

-- Health changed
function PlayerDataManager:OnHealthChanged(player, health)
    self:SendHealthUpdate(player, health)
end

-- Player death
function PlayerDataManager:OnPlayerDeath(player)
    print("[PlayerDataManager] Player died:", player.Name)

    if self.GameManager then
        self.GameManager:OnPlayerDeath(player)
    end
end

-- Give starting items to player
function PlayerDataManager:GiveStartingItems(player)
    -- This will be handled by InventoryManager
    -- Starting items: Wooden Sword + 3-4 food items
    print("[PlayerDataManager] Giving starting items to:", player.Name)
end

-- Get player hunger
function PlayerDataManager:GetHunger(player)
    local playerData = self.Players[player.UserId]
    if playerData then
        return playerData.Hunger
    end
    return 0
end

-- Set player hunger
function PlayerDataManager:SetHunger(player, hunger)
    local playerData = self.Players[player.UserId]
    if playerData then
        playerData.Hunger = math.clamp(hunger, 0, CONFIG.MAX_HUNGER)
        self:SendHungerUpdate(player, playerData.Hunger)
    end
end

return PlayerDataManager
