--[[
    ROBLOX BUNKER SURVIVAL - GAME HUD
    Client-side HUD displaying game info

    Layout (Survival Theme):
    - Bottom Left: Health bar (red), Hunger bar (orange)
    - Top Right: Coins display
    - Top Left: Day counter + Timer
    - Center: Warning messages
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
local healthText = nil
local hungerText = nil
local coinsLabel = nil
local dayLabel = nil
local timerLabel = nil
local phaseLabel = nil
local warningLabel = nil

-- State
local currentHealth = 100
local maxHealth = 100
local currentHunger = 100
local currentCoins = 0
local currentDay = 1
local isDay = true
local timeRemaining = 180

-- Colors (Darker, more survival-themed)
local COLORS = {
    Health = Color3.fromRGB(200, 40, 40), -- Dark red
    HealthBg = Color3.fromRGB(40, 10, 10),
    Hunger = Color3.fromRGB(200, 120, 20), -- Dark orange
    HungerBg = Color3.fromRGB(40, 30, 5),
    Coins = Color3.fromRGB(255, 215, 0), -- Gold
    Day = Color3.fromRGB(255, 200, 100), -- Warm yellow
    Night = Color3.fromRGB(100, 150, 255), -- Cool blue
    Background = Color3.fromRGB(20, 20, 25),
    Border = Color3.fromRGB(60, 60, 70),
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

-- Create health bar (survival style, bottom left)
function GameHUD:CreateHealthBar()
    -- Container
    local container = Instance.new("Frame")
    container.Name = "HealthContainer"
    container.Size = UDim2.new(0, 300, 0, 40)
    container.Position = UDim2.new(0, 20, 1, -90)
    container.AnchorPoint = Vector2.new(0, 1)
    container.BackgroundColor3 = COLORS.Background
    container.BorderSizePixel = 0
    container.Parent = screenGui

    -- Border
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 2
    stroke.Parent = container

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container

    -- Icon (heart symbol)
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 5, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Text = "❤"
    icon.TextColor3 = COLORS.Health
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.Parent = container

    -- Background bar
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, -80, 0, 20)
    background.Position = UDim2.new(0, 40, 0.5, 0)
    background.AnchorPoint = Vector2.new(0, 0.5)
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

    -- Corner for bars
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 3)
    corner2.Parent = background

    local corner3 = Instance.new("UICorner")
    corner3.CornerRadius = UDim.new(0, 3)
    corner3.Parent = healthBar

    -- Text showing HP numbers
    healthText = Instance.new("TextLabel")
    healthText.Size = UDim2.new(0, 60, 1, 0)
    healthText.Position = UDim2.new(1, -65, 0, 0)
    healthText.BackgroundTransparency = 1
    healthText.Text = "100/100"
    healthText.TextColor3 = Color3.new(1, 1, 1)
    healthText.TextSize = 14
    healthText.Font = Enum.Font.GothamBold
    healthText.TextXAlignment = Enum.TextXAlignment.Right
    healthText.TextStrokeTransparency = 0.7
    healthText.Parent = container
end

-- Create hunger bar (survival style, below health)
function GameHUD:CreateHungerBar()
    -- Container
    local container = Instance.new("Frame")
    container.Name = "HungerContainer"
    container.Size = UDim2.new(0, 300, 0, 40)
    container.Position = UDim2.new(0, 20, 1, -45)
    container.AnchorPoint = Vector2.new(0, 1)
    container.BackgroundColor3 = COLORS.Background
    container.BorderSizePixel = 0
    container.Parent = screenGui

    -- Border
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 2
    stroke.Parent = container

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container

    -- Icon (food symbol)
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 5, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Text = "🍖"
    icon.TextColor3 = COLORS.Hunger
    icon.TextSize = 20
    icon.Font = Enum.Font.GothamBold
    icon.Parent = container

    -- Background bar
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, -80, 0, 20)
    background.Position = UDim2.new(0, 40, 0.5, 0)
    background.AnchorPoint = Vector2.new(0, 0.5)
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

    -- Corner for bars
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 3)
    corner2.Parent = background

    local corner3 = Instance.new("UICorner")
    corner3.CornerRadius = UDim.new(0, 3)
    corner3.Parent = hungerBar

    -- Text showing hunger percentage
    hungerText = Instance.new("TextLabel")
    hungerText.Size = UDim2.new(0, 60, 1, 0)
    hungerText.Position = UDim2.new(1, -65, 0, 0)
    hungerText.BackgroundTransparency = 1
    hungerText.Text = "100%"
    hungerText.TextColor3 = Color3.new(1, 1, 1)
    hungerText.TextSize = 14
    hungerText.Font = Enum.Font.GothamBold
    hungerText.TextXAlignment = Enum.TextXAlignment.Right
    hungerText.TextStrokeTransparency = 0.7
    hungerText.Parent = container
end

-- Create coins display (bottom left, above health bar)
function GameHUD:CreateCoinsDisplay()
    -- Container
    local container = Instance.new("Frame")
    container.Name = "CoinsContainer"
    container.Size = UDim2.new(0, 300, 0, 40)
    container.Position = UDim2.new(0, 20, 1, -135)
    container.AnchorPoint = Vector2.new(0, 1)
    container.BackgroundColor3 = COLORS.Background
    container.BorderSizePixel = 0
    container.Parent = screenGui

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container

    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 2
    stroke.Parent = container

    -- Coin icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 8, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Text = "💰"
    icon.TextSize = 20
    icon.Parent = container

    -- Coins label
    coinsLabel = Instance.new("TextLabel")
    coinsLabel.Size = UDim2.new(1, -45, 1, 0)
    coinsLabel.Position = UDim2.new(0, 40, 0, 0)
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Text = "0"
    coinsLabel.TextColor3 = COLORS.Coins
    coinsLabel.TextSize = 18
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinsLabel.TextStrokeTransparency = 0.7
    coinsLabel.Parent = container
end

-- Create day and timer display (top center)
function GameHUD:CreateDayLabel()
    -- Container for day/timer info
    local container = Instance.new("Frame")
    container.Name = "DayTimerContainer"
    container.Size = UDim2.new(0, 220, 0, 80)
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.Position = UDim2.new(0.5, 0, 0, 20)
    container.BackgroundColor3 = COLORS.Background
    container.BorderSizePixel = 0
    container.Parent = screenGui

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container

    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 2
    stroke.Parent = container

    -- Day label (top section)
    dayLabel = Instance.new("TextLabel")
    dayLabel.Name = "DayLabel"
    dayLabel.Size = UDim2.new(1, -20, 0, 35)
    dayLabel.Position = UDim2.new(0, 10, 0, 5)
    dayLabel.BackgroundTransparency = 1
    dayLabel.Text = "DAY 1"
    dayLabel.TextColor3 = COLORS.Day
    dayLabel.TextSize = 24
    dayLabel.Font = Enum.Font.GothamBold
    dayLabel.TextXAlignment = Enum.TextXAlignment.Center
    dayLabel.TextStrokeTransparency = 0.7
    dayLabel.Parent = container

    -- Phase label (small text above timer)
    phaseLabel = Instance.new("TextLabel")
    phaseLabel.Name = "PhaseLabel"
    phaseLabel.Size = UDim2.new(1, -20, 0, 15)
    phaseLabel.Position = UDim2.new(0, 10, 0, 40)
    phaseLabel.BackgroundTransparency = 1
    phaseLabel.Text = "Daytime"
    phaseLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    phaseLabel.TextSize = 12
    phaseLabel.Font = Enum.Font.Gotham
    phaseLabel.TextXAlignment = Enum.TextXAlignment.Center
    phaseLabel.TextStrokeTransparency = 0.7
    phaseLabel.Parent = container

    -- Timer label (bottom section)
    timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Size = UDim2.new(1, -20, 0, 25)
    timerLabel.Position = UDim2.new(0, 10, 0, 52)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "3:00"
    timerLabel.TextColor3 = Color3.new(1, 1, 1)
    timerLabel.TextSize = 20
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.TextXAlignment = Enum.TextXAlignment.Center
    timerLabel.TextStrokeTransparency = 0.7
    timerLabel.Parent = container
end

-- Placeholder for timer (kept for compatibility)
function GameHUD:CreateTimerLabel()
    -- Timer is now part of day label container
end

-- Create warning label (center screen)
function GameHUD:CreateWarningLabel()
    warningLabel = Instance.new("TextLabel")
    warningLabel.Name = "WarningLabel"
    warningLabel.Size = UDim2.new(0, 600, 0, 80)
    warningLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    warningLabel.Position = UDim2.new(0.5, 0, 0.4, 0)
    warningLabel.BackgroundTransparency = 1
    warningLabel.Text = ""
    warningLabel.TextColor3 = Color3.new(1, 1, 1)
    warningLabel.TextSize = 32
    warningLabel.Font = Enum.Font.GothamBold
    warningLabel.TextStrokeTransparency = 0.5
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

    -- Update text
    if healthText then
        healthText.Text = math.floor(currentHealth) .. "/" .. maxHealth
    end
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

    -- Update text
    if hungerText then
        hungerText.Text = math.floor(currentHunger) .. "%"
    end

    -- Change color if low
    if currentHunger <= 20 then
        hungerBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red when very low
    else
        hungerBar.BackgroundColor3 = COLORS.Hunger
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

    if dayLabel then
        dayLabel.Text = "DAY " .. day

        -- Change color based on phase
        if isDayPhase then
            dayLabel.TextColor3 = COLORS.Day
        else
            dayLabel.TextColor3 = COLORS.Night
        end
    end

    -- Update phase label
    if phaseLabel then
        if isDayPhase then
            phaseLabel.Text = "Daytime - Gather Resources"
        else
            phaseLabel.Text = "Nighttime - Defend!"
        end
    end
end

-- Update timer
function GameHUD:UpdateTimer(data)
    isDay = data.IsDay
    timeRemaining = data.TimeRemaining

    if not timerLabel then return end

    -- Format time as MM:SS
    local minutes = math.floor(timeRemaining / 60)
    local seconds = timeRemaining % 60
    timerLabel.Text = string.format("%d:%02d", minutes, seconds)

    -- Change color based on time remaining
    if timeRemaining <= 10 then
        timerLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red
    elseif timeRemaining <= 30 then
        timerLabel.TextColor3 = Color3.fromRGB(255, 160, 50) -- Orange
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
