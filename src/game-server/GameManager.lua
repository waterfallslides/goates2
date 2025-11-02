--[[
    ROBLOX BUNKER SURVIVAL - GAME MANAGER
    Main server-side game coordinator

    Manages:
    - Game initialization when players teleport in
    - Mode detection (Solo/Duo/Squad)
    - Player spawning
    - Game state transitions
    - Server shutdown
]]

local GameManager = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Configuration
local CONFIG = {
    LOBBY_PLACE_ID = 0, -- Replace with actual lobby place ID
    MIN_PLAYERS_TO_START = 1,
    SERVER_TIMEOUT = 30, -- Seconds to wait for players before shutdown
}

-- Game State
GameManager.State = "WaitingForPlayers" -- WaitingForPlayers, Playing, GameOver
GameManager.Mode = "Solo" -- Solo, Duo, Squad
GameManager.CurrentDay = 1
GameManager.IsDay = true
GameManager.PhaseTime = 0
GameManager.PlayersAlive = {}
GameManager.AllPlayers = {}

-- Initialize game
function GameManager:Initialize()
    print("[GameManager] Initializing game server...")

    -- Create RemoteEvents folder
    self:CreateRemoteEvents()

    -- Setup player connections
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerJoin(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerLeave(player)
    end)

    -- Wait for initial players
    self:WaitForPlayers()
end

-- Create remote events for client communication
function GameManager:CreateRemoteEvents()
    local events = Instance.new("Folder")
    events.Name = "GameEvents"
    events.Parent = ReplicatedStorage

    local phaseUpdate = Instance.new("RemoteEvent")
    phaseUpdate.Name = "PhaseUpdate"
    phaseUpdate.Parent = events

    local dayUpdate = Instance.new("RemoteEvent")
    dayUpdate.Name = "DayUpdate"
    dayUpdate.Parent = events

    local playerDied = Instance.new("RemoteEvent")
    playerDied.Name = "PlayerDied"
    playerDied.Parent = events

    local gameOver = Instance.new("RemoteEvent")
    gameOver.Name = "GameOver"
    gameOver.Parent = events

    print("[GameManager] Remote events created")
end

-- Wait for players to join
function GameManager:WaitForPlayers()
    print("[GameManager] Waiting for players...")

    local timeWaited = 0
    local checkInterval = 1

    while #Players:GetPlayers() < CONFIG.MIN_PLAYERS_TO_START and timeWaited < CONFIG.SERVER_TIMEOUT do
        wait(checkInterval)
        timeWaited = timeWaited + checkInterval
    end

    if #Players:GetPlayers() >= CONFIG.MIN_PLAYERS_TO_START then
        -- Detect mode based on player count
        local playerCount = #Players:GetPlayers()
        if playerCount == 1 then
            self.Mode = "Solo"
        elseif playerCount == 2 then
            self.Mode = "Duo"
        else
            self.Mode = "Squad"
        end

        print("[GameManager] Starting game in " .. self.Mode .. " mode with " .. playerCount .. " players")
        self:StartGame()
    else
        print("[GameManager] Not enough players, shutting down server")
        self:ShutdownServer()
    end
end

-- Player joined
function GameManager:OnPlayerJoin(player)
    print("[GameManager] Player joined:", player.Name)

    table.insert(self.AllPlayers, player)
    table.insert(self.PlayersAlive, player)

    -- Initialize player data
    self:InitializePlayerData(player)

    -- If game is in progress, handle late join
    if self.State == "Playing" then
        -- Spawn player at their bunker
        self:SpawnPlayer(player)
    end
end

-- Player left
function GameManager:OnPlayerLeave(player)
    print("[GameManager] Player left:", player.Name)

    -- Remove from alive players
    for i, p in ipairs(self.PlayersAlive) do
        if p == player then
            table.remove(self.PlayersAlive, i)
            break
        end
    end

    -- Remove from all players
    for i, p in ipairs(self.AllPlayers) do
        if p == player then
            table.remove(self.AllPlayers, i)
            break
        end
    end

    -- Check if server should shut down
    if #self.AllPlayers == 0 then
        print("[GameManager] All players left, shutting down server in 5 seconds...")
        wait(5)
        self:ShutdownServer()
    elseif #self.PlayersAlive == 0 then
        print("[GameManager] All players dead, game over!")
        self:EndGame()
    end
end

-- Initialize player data
function GameManager:InitializePlayerData(player)
    -- Create leaderstats
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats

    local day = Instance.new("IntValue")
    day.Name = "Day"
    day.Value = self.CurrentDay
    day.Parent = leaderstats

    -- Create player data folder
    local playerData = Instance.new("Folder")
    playerData.Name = "PlayerData"
    playerData.Parent = player

    -- Health (handled by Humanoid)
    -- Hunger
    local hunger = Instance.new("IntValue")
    hunger.Name = "Hunger"
    hunger.Value = 100
    hunger.Parent = playerData

    -- Alive status
    local alive = Instance.new("BoolValue")
    alive.Name = "Alive"
    alive.Value = true
    alive.Parent = playerData

    -- Inventory (will be managed by inventory system)
    local inventory = Instance.new("Folder")
    inventory.Name = "Inventory"
    inventory.Parent = playerData

    -- Stats tracking
    local stats = Instance.new("Folder")
    stats.Name = "Stats"
    stats.Parent = playerData

    local monstersKilled = Instance.new("IntValue")
    monstersKilled.Name = "MonstersKilled"
    monstersKilled.Value = 0
    monstersKilled.Parent = stats

    local damageDealt = Instance.new("IntValue")
    damageDealt.Name = "DamageDealt"
    damageDealt.Value = 0
    damageDealt.Parent = stats

    print("[GameManager] Initialized data for player:", player.Name)
end

-- Spawn player at their bunker
function GameManager:SpawnPlayer(player)
    -- This will be implemented when bunkers are created
    -- For now, spawn at workspace spawn location
    local spawnLocation = workspace:FindFirstChild("SpawnLocation")
    if spawnLocation then
        player.Character:SetPrimaryPartCFrame(spawnLocation.CFrame + Vector3.new(0, 5, 0))
    end
end

-- Start the game
function GameManager:StartGame()
    self.State = "Playing"
    print("[GameManager] Game started! Mode:", self.Mode)

    -- Initialize all systems
    -- Day/Night cycle will be started by DayNightManager
    -- Bunkers will be created by BunkerManager
    -- etc.

    -- Notify all players
    for _, player in ipairs(self.AllPlayers) do
        local events = ReplicatedStorage:WaitForChild("GameEvents")
        events.DayUpdate:FireClient(player, self.CurrentDay, true) -- Day 1, isDay = true
    end
end

-- End the game
function GameManager:EndGame()
    if self.State == "GameOver" then return end

    self.State = "GameOver"
    print("[GameManager] Game Over! Players survived " .. self.CurrentDay .. " days")

    -- Notify all players
    local events = ReplicatedStorage:FindFirstChild("GameEvents")
    if events then
        for _, player in ipairs(self.AllPlayers) do
            events.GameOver:FireClient(player, self.CurrentDay)
        end
    end

    -- Wait a bit for players to see results
    wait(10)

    -- Teleport players back to lobby
    self:TeleportToLobby()
end

-- Teleport players back to lobby
function GameManager:TeleportToLobby()
    local TeleportService = game:GetService("TeleportService")

    for _, player in ipairs(self.AllPlayers) do
        local success, err = pcall(function()
            TeleportService:Teleport(CONFIG.LOBBY_PLACE_ID, player)
        end)

        if not success then
            warn("[GameManager] Failed to teleport player to lobby:", err)
        end
    end

    -- Shutdown server after teleporting
    wait(5)
    self:ShutdownServer()
end

-- Shutdown server
function GameManager:ShutdownServer()
    print("[GameManager] Shutting down server...")
    wait(1)
    -- Server will automatically shut down when empty
end

-- Player died
function GameManager:OnPlayerDeath(player)
    print("[GameManager] Player died:", player.Name)

    -- Mark as dead
    local playerData = player:FindFirstChild("PlayerData")
    if playerData then
        local alive = playerData:FindFirstChild("Alive")
        if alive then
            alive.Value = false
        end
    end

    -- Remove from alive players
    for i, p in ipairs(self.PlayersAlive) do
        if p == player then
            table.remove(self.PlayersAlive, i)
            break
        end
    end

    -- Check game mode
    if self.Mode == "Solo" then
        -- Solo mode - game over
        print("[GameManager] Solo player died, game over!")
        self:EndGame()
    else
        -- Duo/Squad - start spectating
        print("[GameManager] Player will spectate teammates")

        -- Notify client to show spectate UI
        local events = ReplicatedStorage:FindFirstChild("GameEvents")
        if events then
            events.PlayerDied:FireClient(player, "Spectate")
        end

        -- Check if all players dead
        if #self.PlayersAlive == 0 then
            print("[GameManager] All players dead, game over!")
            self:EndGame()
        end
    end
end

-- Award coins to player
function GameManager:AwardCoins(player, amount, reason)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local coins = leaderstats:FindFirstChild("Coins")
        if coins then
            coins.Value = coins.Value + amount
            print("[GameManager] Awarded " .. amount .. " coins to " .. player.Name .. " (" .. reason .. ")")
        end
    end
end

-- Award coins to all alive players
function GameManager:AwardCoinsToAll(amount, reason)
    for _, player in ipairs(self.PlayersAlive) do
        self:AwardCoins(player, amount, reason)
    end
end

-- Get alive players
function GameManager:GetAlivePlayers()
    return self.PlayersAlive
end

-- Get all players
function GameManager:GetAllPlayers()
    return self.AllPlayers
end

return GameManager
