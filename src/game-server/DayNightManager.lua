--[[
    ROBLOX BUNKER SURVIVAL - DAY/NIGHT CYCLE MANAGER
    Manages the day/night cycle and phase transitions

    Day Phase: 3 minutes (180 seconds)
    - Players explore and collect food
    - Buy weapons and upgrades
    - Prepare for night

    Night Phase: 5 minutes (300 seconds)
    - Monsters spawn and attack
    - Players defend bunkers
    - Difficulty increases each night
]]

local DayNightManager = {}

-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- Configuration
local CONFIG = {
    DAY_DURATION = 180,    -- 3 minutes
    NIGHT_DURATION = 300,  -- 5 minutes
    WARNING_TIMES = {30, 10}, -- Warning at 30s and 10s before phase change
}

-- State
DayNightManager.CurrentDay = 1
DayNightManager.IsDay = true
DayNightManager.PhaseTime = 0
DayNightManager.IsRunning = false
DayNightManager.GameManager = nil
DayNightManager.MonstersManager = nil
DayNightManager.FoodManager = nil
DayNightManager.BunkerManager = nil

-- Initialize
function DayNightManager:Initialize(gameManager)
    self.GameManager = gameManager
    print("[DayNightManager] Initialized")

    -- Setup lighting
    self:SetupLighting()

    -- Create remote events
    self:CreateRemoteEvents()
end

-- Setup lighting for day/night
function DayNightManager:SetupLighting()
    Lighting.ClockTime = 12 -- Start at noon
    Lighting.Ambient = Color3.fromRGB(150, 150, 150)
    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    Lighting.Brightness = 2
    Lighting.GlobalShadows = true

    print("[DayNightManager] Lighting configured")
end

-- Create remote events
function DayNightManager:CreateRemoteEvents()
    local events = ReplicatedStorage:WaitForChild("GameEvents")

    -- Phase warning event
    local phaseWarning = Instance.new("RemoteEvent")
    phaseWarning.Name = "PhaseWarning"
    phaseWarning.Parent = events

    -- Phase timer event
    local phaseTimer = Instance.new("RemoteEvent")
    phaseTimer.Name = "PhaseTimer"
    phaseTimer.Parent = events

    print("[DayNightManager] Remote events created")
end

-- Start the day/night cycle
function DayNightManager:Start()
    if self.IsRunning then
        warn("[DayNightManager] Already running!")
        return
    end

    self.IsRunning = true
    self.CurrentDay = 1
    self.IsDay = true
    self.PhaseTime = 0

    print("[DayNightManager] Starting day/night cycle")

    -- Start first day
    self:StartDayPhase()

    -- Main loop
    RunService.Heartbeat:Connect(function(deltaTime)
        if not self.IsRunning then return end

        self:Update(deltaTime)
    end)
end

-- Stop the cycle
function DayNightManager:Stop()
    self.IsRunning = false
    print("[DayNightManager] Stopped day/night cycle")
end

-- Update loop
function DayNightManager:Update(deltaTime)
    self.PhaseTime = self.PhaseTime + deltaTime

    -- Get current phase duration
    local phaseDuration = self.IsDay and CONFIG.DAY_DURATION or CONFIG.NIGHT_DURATION

    -- Send timer update to clients every second
    if math.floor(self.PhaseTime) % 1 < deltaTime then
        local timeRemaining = phaseDuration - self.PhaseTime
        self:SendTimerUpdate(timeRemaining)
    end

    -- Check for warnings
    for _, warningTime in ipairs(CONFIG.WARNING_TIMES) do
        local timeRemaining = phaseDuration - self.PhaseTime
        if timeRemaining <= warningTime and timeRemaining > warningTime - deltaTime then
            self:SendPhaseWarning(warningTime)
        end
    end

    -- Check if phase should end
    if self.PhaseTime >= phaseDuration then
        if self.IsDay then
            self:StartNightPhase()
        else
            self:StartDayPhase()
        end
    end
end

-- Start day phase
function DayNightManager:StartDayPhase()
    self.IsDay = true
    self.PhaseTime = 0

    if self.CurrentDay > 1 then
        -- Award survival coins to all alive players
        if self.GameManager then
            self.GameManager:AwardCoinsToAll(75, "Survived the night")
        end

        -- Milestone bonus (every 5 days)
        if self.CurrentDay % 5 == 1 and self.CurrentDay > 1 then
            if self.GameManager then
                self.GameManager:AwardCoinsToAll(100, "Milestone bonus (Day " .. (self.CurrentDay - 1) .. ")")
            end
        end
    end

    print("[DayNightManager] === DAY " .. self.CurrentDay .. " STARTED ===")

    -- Set lighting to day
    self:SetDayLighting()

    -- Spawn food
    if self.FoodManager then
        self.FoodManager:SpawnFood()
    end

    -- Repair all bunkers
    if self.BunkerManager then
        self.BunkerManager:RepairAllBunkers()
    end

    -- Check for weapon tier unlocks
    if self.CurrentDay == 7 or self.CurrentDay == 14 or self.CurrentDay == 21 then
        print("[DayNightManager] New weapon tier unlocked on Day " .. self.CurrentDay .. "!")
        -- Weapon system will handle this
    end

    -- Notify clients
    self:NotifyDayStart()
end

-- Start night phase
function DayNightManager:StartNightPhase()
    self.IsDay = false
    self.PhaseTime = 0

    print("[DayNightManager] === NIGHT " .. self.CurrentDay .. " STARTED ===")

    -- Set lighting to night
    self:SetNightLighting()

    -- Remove all food
    if self.FoodManager then
        self.FoodManager:RemoveAllFood()
    end

    -- Spawn monsters
    if self.MonstersManager then
        self.MonstersManager:SpawnMonsters(self.CurrentDay)
    end

    -- Notify clients
    self:NotifyNightStart()

    -- Increment day counter (for next day)
    self.CurrentDay = self.CurrentDay + 1
end

-- Set day lighting
function DayNightManager:SetDayLighting()
    local TweenService = game:GetService("TweenService")

    -- Tween to day lighting
    local goal = {
        ClockTime = 12,
        Brightness = 2
    }

    local tween = TweenService:Create(Lighting, TweenInfo.new(3), goal)
    tween:Play()

    -- Immediately set ambient
    Lighting.Ambient = Color3.fromRGB(150, 150, 150)
    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
end

-- Set night lighting
function DayNightManager:SetNightLighting()
    local TweenService = game:GetService("TweenService")

    -- Tween to night lighting
    local goal = {
        ClockTime = 0,
        Brightness = 0.5
    }

    local tween = TweenService:Create(Lighting, TweenInfo.new(3), goal)
    tween:Play()

    -- Set darker ambient
    Lighting.Ambient = Color3.fromRGB(50, 50, 80)
    Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 80)
end

-- Send timer update to clients
function DayNightManager:SendTimerUpdate(timeRemaining)
    local events = ReplicatedStorage:FindFirstChild("GameEvents")
    if not events then return end

    local timerEvent = events:FindFirstChild("PhaseTimer")
    if not timerEvent then return end

    -- Send to all players
    for _, player in ipairs(game.Players:GetPlayers()) do
        timerEvent:FireClient(player, {
            IsDay = self.IsDay,
            TimeRemaining = math.max(0, math.floor(timeRemaining)),
            CurrentDay = self.CurrentDay
        })
    end
end

-- Send phase warning
function DayNightManager:SendPhaseWarning(timeRemaining)
    local events = ReplicatedStorage:FindFirstChild("GameEvents")
    if not events then return end

    local warningEvent = events:FindFirstChild("PhaseWarning")
    if not warningEvent then return end

    local message = ""
    if self.IsDay then
        if timeRemaining == 30 then
            message = "Night approaching in 30 seconds"
        elseif timeRemaining == 10 then
            message = "Night approaching in 10 seconds"
        end
    else
        if timeRemaining == 30 then
            message = "Day breaking in 30 seconds"
        elseif timeRemaining == 10 then
            message = "Day breaking in 10 seconds"
        end
    end

    print("[DayNightManager] Warning: " .. message)

    -- Send to all players
    for _, player in ipairs(game.Players:GetPlayers()) do
        warningEvent:FireClient(player, message, timeRemaining)
    end
end

-- Notify day start
function DayNightManager:NotifyDayStart()
    local events = ReplicatedStorage:FindFirstChild("GameEvents")
    if not events then return end

    local dayUpdate = events:FindFirstChild("DayUpdate")
    if dayUpdate then
        for _, player in ipairs(game.Players:GetPlayers()) do
            dayUpdate:FireClient(player, self.CurrentDay, true)
        end
    end

    -- Also send warning
    local warningEvent = events:FindFirstChild("PhaseWarning")
    if warningEvent then
        for _, player in ipairs(game.Players:GetPlayers()) do
            warningEvent:FireClient(player, "Day is breaking...", 0)
        end
    end
end

-- Notify night start
function DayNightManager:NotifyNightStart()
    local events = ReplicatedStorage:FindFirstChild("GameEvents")
    if not events then return end

    local dayUpdate = events:FindFirstChild("DayUpdate")
    if dayUpdate then
        for _, player in ipairs(game.Players:GetPlayers()) do
            dayUpdate:FireClient(player, self.CurrentDay, false)
        end
    end

    -- Also send warning
    local warningEvent = events:FindFirstChild("PhaseWarning")
    if warningEvent then
        for _, player in ipairs(game.Players:GetPlayers()) do
            warningEvent:FireClient(player, "NIGHT HAS FALLEN", 0)
        end
    end
end

-- Get current phase info
function DayNightManager:GetPhaseInfo()
    return {
        CurrentDay = self.CurrentDay,
        IsDay = self.IsDay,
        PhaseTime = self.PhaseTime,
        TimeRemaining = (self.IsDay and CONFIG.DAY_DURATION or CONFIG.NIGHT_DURATION) - self.PhaseTime
    }
end

-- Check if it's a boss night
function DayNightManager:IsBossNight()
    return self.CurrentDay % 7 == 0
end

return DayNightManager
