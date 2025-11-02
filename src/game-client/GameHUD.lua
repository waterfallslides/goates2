--[[
    ROBLOX BUNKER SURVIVAL - GAME HUD
    Client-side HUD displaying game info

    Layout:
    - Top Left: Health bar (red), Hunger bar (orange)
    - Top Right: Coins display
    - Top Center: "Day X" counter
    - Center Top: Phase timer (seconds until day/night)
]]

local GameHUD = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Local player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- HUD elements
local screenGui = nil
local healthBar = nil
local hungerBar = nil
local coinsLabel = nil
local dayLabel = nil
local timerLabel = nil
local warningLabel = nil

-- State
local currentHealth = 100
local maxHealth = 100
local currentHunger = 100
local currentCoins = 0
local currentDay = 1
local isDay = true
local timeRemaining = 180

-- Colors
local COLORS = {
    Health = Color3.fromRGB(255, 50, 50), -- Red
    HealthBg = Color3.fromRGB(80, 20, 20),
    Hunger = Color3.fromRGB(255, 170, 0), -- Orange
    HungerBg = Color3.fromRGB(80, 60, 0),
    Day = Color3.fromRGB(100, 200, 255), -- Light blue
    Night = Color3.fromRGB(150, 50, 200), -- Purple
    Warning = {
        [30] = Color3.fromRGB(255, 255, 0), -- Yellow
        [10] = Color3.fromRGB(255, 140, 0), -- Orange
        [0] = Color3.fromRGB(255, 0, 0), -- Red
    }
}

-- Initialize HUD
function GameHUD:Initialize()
    print("[GameHUD] Initializing...")

    self:CreateHUD()
    self:ConnectEvents()
    self:StartUpdateLoop()

    print("[GameHUD] HUD created successfully")
end

-- Create HUD elements
function GameHUD:CreateHUD()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameHUD"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Top Left: Health and Hunger bars
    self:CreateHealthBar()
    self:CreateHungerBar()

    -- Top Right: Coins
    self:CreateCoinsDisplay()

    -- Top Center: Day counter
    self:CreateDayLabel()

    -- Center Top: Timer
    self:CreateTimerLabel()

    -- Warning label
    self:CreateWarningLabel()
end

-- Create health bar
function GameHUD:CreateHealthBar()
    -- Container
    local container = Instance.new("Frame")
    container.Name = "HealthContainer"
    container.Size = UDim2.new(0, 250, 0, 35)
    container.Position = UDim2.new(0, 20, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 80, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "HEALTH"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.FredokaOne
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 0.5
    label.Parent = container

    -- Background bar
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 0, 12)
    background.Position = UDim2.new(0, 0, 0, 23)
    background.BackgroundColor3 = COLORS.HealthBg
    background.BorderSizePixel = 0
    background.Parent = container

    -- Health bar
    healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = COLORS.Health
    healthBar.BorderSizePixel = 0
    healthBar.Parent = background

    -- Border/stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 2
    stroke.Parent = background

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = background

    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 4)
    corner2.Parent = healthBar
end

-- Create hunger bar
function GameHUD:CreateHungerBar()
    -- Container
    local container = Instance.new("Frame")
    container.Name = "HungerContainer"
    container.Size = UDim2.new(0, 250, 0, 35)
    container.Position = UDim2.new(0, 20, 0, 65)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 80, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "HUNGER"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.FredokaOne
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 0.5
    label.Parent = container

    -- Background bar
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 0, 12)
    background.Position = UDim2.new(0, 0, 0, 23)
    background.BackgroundColor3 = COLORS.HungerBg
    background.BorderSizePixel = 0
    background.Parent = container

    -- Hunger bar
    hungerBar = Instance.new("Frame")
    hungerBar.Name = "HungerBar"
    hungerBar.Size = UDim2.new(1, 0, 1, 0)
    hungerBar.BackgroundColor3 = COLORS.Hunger
    hungerBar.BorderSizePixel = 0
    hungerBar.Parent = background

    -- Border/stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 2
    stroke.Parent = background

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = background

    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 4)
    corner2.Parent = hungerBar
end

-- Create coins display
function GameHUD:CreateCoinsDisplay()
    -- Container
    local container = Instance.new("Frame")
    container.Name = "CoinsContainer"
    container.Size = UDim2.new(0, 200, 0, 50)
    container.AnchorPoint = Vector2.new(1, 0)
    container.Position = UDim2.new(1, -20, 0, 20)
    container.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    container.BorderSizePixel = 0
    container.Parent = screenGui

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container

    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 215, 0) -- Gold
    stroke.Thickness = 3
    stroke.Parent = container

    -- Coin icon (text)
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.Position = UDim2.new(0, 5, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "💰"
    icon.TextSize = 30
    icon.Parent = container

    -- Coins label
    coinsLabel = Instance.new("TextLabel")
    coinsLabel.Size = UDim2.new(1, -50, 1, 0)
    coinsLabel.Position = UDim2.new(0, 50, 0, 0)
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Text = "0"
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.TextSize = 28
    coinsLabel.Font = Enum.Font.FredokaOne
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinsLabel.TextStrokeTransparency = 0.5
    coinsLabel.Parent = container
end

-- Create day label
function GameHUD:CreateDayLabel()
    dayLabel = Instance.new("TextLabel")
    dayLabel.Name = "DayLabel"
    dayLabel.Size = UDim2.new(0, 200, 0, 50)
    dayLabel.AnchorPoint = Vector2.new(0.5, 0)
    dayLabel.Position = UDim2.new(0.5, 0, 0, 20)
    dayLabel.BackgroundTransparency = 0.3
    dayLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    dayLabel.Text = "DAY 1"
    dayLabel.TextColor3 = COLORS.Day
    dayLabel.TextSize = 32
    dayLabel.Font = Enum.Font.FredokaOne
    dayLabel.TextStrokeTransparency = 0.3
    dayLabel.Parent = screenGui

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = dayLabel

    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 2
    stroke.Parent = dayLabel
end

-- Create timer label
function GameHUD:CreateTimerLabel()
    timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Size = UDim2.new(0, 150, 0, 40)
    timerLabel.AnchorPoint = Vector2.new(0.5, 0)
    timerLabel.Position = UDim2.new(0.5, 0, 0, 80)
    timerLabel.BackgroundTransparency = 0.3
    timerLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    timerLabel.Text = "3:00"
    timerLabel.TextColor3 = Color3.new(1, 1, 1)
    timerLabel.TextSize = 24
    timerLabel.Font = Enum.Font.FredokaOne
    timerLabel.TextStrokeTransparency = 0.3
    timerLabel.Parent = screenGui

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = timerLabel

    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 2
    stroke.Parent = timerLabel
end

-- Create warning label
function GameHUD:CreateWarningLabel()
    warningLabel = Instance.new("TextLabel")
    warningLabel.Name = "WarningLabel"
    warningLabel.Size = UDim2.new(0, 600, 0, 60)
    warningLabel.AnchorPoint = Vector2.new(0.5, 0)
    warningLabel.Position = UDim2.new(0.5, 0, 0.3, 0)
    warningLabel.BackgroundTransparency = 1
    warningLabel.Text = ""
    warningLabel.TextColor3 = Color3.new(1, 1, 1)
    warningLabel.TextSize = 36
    warningLabel.Font = Enum.Font.FredokaOne
    warningLabel.TextStrokeTransparency = 0.3
    warningLabel.TextTransparency = 1
    warningLabel.Parent = screenGui
end

-- Connect to server events
function GameHUD:ConnectEvents()
    local events = ReplicatedStorage:WaitForChild("GameEvents")

    -- Health update
    local healthUpdate = events:WaitForChild("HealthUpdate")
    healthUpdate.OnClientEvent:Connect(function(health)
        self:UpdateHealth(health)
    end)

    -- Hunger update
    local hungerUpdate = events:WaitForChild("HungerUpdate")
    hungerUpdate.OnClientEvent:Connect(function(hunger)
        self:UpdateHunger(hunger)
    end)

    -- Day update
    local dayUpdate = events:WaitForChild("DayUpdate")
    dayUpdate.OnClientEvent:Connect(function(day, isDayPhase)
        self:UpdateDay(day, isDayPhase)
    end)

    -- Phase timer
    local phaseTimer = events:WaitForChild("PhaseTimer")
    phaseTimer.OnClientEvent:Connect(function(data)
        self:UpdateTimer(data)
    end)

    -- Phase warning
    local phaseWarning = events:WaitForChild("PhaseWarning")
    phaseWarning.OnClientEvent:Connect(function(message, timeRemaining)
        self:ShowWarning(message)
    end)

    print("[GameHUD] Events connected")
end

-- Start update loop
function GameHUD:StartUpdateLoop()
    -- Monitor player's health from character
    task.spawn(function()
        while task.wait(0.1) do
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    if humanoid.Health ~= currentHealth or humanoid.MaxHealth ~= maxHealth then
                        currentHealth = humanoid.Health
                        maxHealth = humanoid.MaxHealth
                        self:UpdateHealth(currentHealth)
                    end
                end
            end

            -- Update coins from leaderstats
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local coins = leaderstats:FindFirstChild("Coins")
                if coins and coins.Value ~= currentCoins then
                    currentCoins = coins.Value
                    self:UpdateCoins(currentCoins)
                end
            end
        end
    end)
end

-- Update health bar
function GameHUD:UpdateHealth(health)
    currentHealth = health
    local healthPercent = currentHealth / maxHealth

    -- Tween bar size
    local tween = TweenService:Create(healthBar, TweenInfo.new(0.2), {
        Size = UDim2.new(healthPercent, 0, 1, 0)
    })
    tween:Play()
end

-- Update hunger bar
function GameHUD:UpdateHunger(hunger)
    currentHunger = hunger
    local hungerPercent = currentHunger / 100

    -- Tween bar size
    local tween = TweenService:Create(hungerBar, TweenInfo.new(0.2), {
        Size = UDim2.new(hungerPercent, 0, 1, 0)
    })
    tween:Play()

    -- Pulse if empty
    if currentHunger <= 0 then
        -- Add pulsing effect
        -- (Could implement this with a loop)
    end
end

-- Update coins
function GameHUD:UpdateCoins(coins)
    currentCoins = coins
    coinsLabel.Text = tostring(coins)

    -- Pulse effect on coin gain
    coinsLabel.TextSize = 32
    local tween = TweenService:Create(coinsLabel, TweenInfo.new(0.2), {
        TextSize = 28
    })
    tween:Play()
end

-- Update day
function GameHUD:UpdateDay(day, isDayPhase)
    currentDay = day
    isDay = isDayPhase

    dayLabel.Text = "DAY " .. day

    -- Change color based on phase
    if isDayPhase then
        dayLabel.TextColor3 = COLORS.Day
    else
        dayLabel.TextColor3 = COLORS.Night
    end
end

-- Update timer
function GameHUD:UpdateTimer(data)
    isDay = data.IsDay
    timeRemaining = data.TimeRemaining

    -- Format time as MM:SS
    local minutes = math.floor(timeRemaining / 60)
    local seconds = timeRemaining % 60
    timerLabel.Text = string.format("%d:%02d", minutes, seconds)

    -- Change color based on time remaining
    if timeRemaining <= 10 then
        timerLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
    elseif timeRemaining <= 30 then
        timerLabel.TextColor3 = Color3.fromRGB(255, 140, 0) -- Orange
    else
        timerLabel.TextColor3 = Color3.new(1, 1, 1) -- White
    end
end

-- Show warning
function GameHUD:ShowWarning(message)
    warningLabel.Text = message

    -- Fade in
    local fadeIn = TweenService:Create(warningLabel, TweenInfo.new(0.5), {
        TextTransparency = 0
    })
    fadeIn:Play()

    -- Wait
    task.wait(3)

    -- Fade out
    local fadeOut = TweenService:Create(warningLabel, TweenInfo.new(0.5), {
        TextTransparency = 1
    })
    fadeOut:Play()
end

return GameHUD
