--[[
	Day/Night Cycle GUI
	Client-side GUI for displaying day/night cycle information

	Features:
	- Displays current phase (Day/Night)
	- Shows current day number
	- Countdown timer to next phase
	- Warning notifications before night
	- Cartoony design matching existing lobby GUI
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local DayNightEvents = ReplicatedStorage:WaitForChild("DayNightEvents")
local PhaseChangeEvent = DayNightEvents:WaitForChild("PhaseChange")
local TimerUpdateEvent = DayNightEvents:WaitForChild("TimerUpdate")
local WarningEvent = DayNightEvents:WaitForChild("Warning")

-- State variables
local CurrentPhase = "Day"
local CurrentDay = 1
local TimeRemaining = 180

-- Create GUI
local function createGUI()
	-- Create ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DayNightGUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Main Frame (positioned at top-right)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 250, 0, 140)
	mainFrame.Position = UDim2.new(1, -260, 0, 10)  -- Top-right corner with 10px padding
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	mainFrame.BackgroundTransparency = 0.2
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	-- Add rounded corners
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = mainFrame

	-- Add thick black border (cartoony style)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 4
	uiStroke.Color = Color3.fromRGB(0, 0, 0)
	uiStroke.Parent = mainFrame

	-- Phase Label (Day/Night)
	local phaseLabel = Instance.new("TextLabel")
	phaseLabel.Name = "PhaseLabel"
	phaseLabel.Size = UDim2.new(1, -20, 0, 35)
	phaseLabel.Position = UDim2.new(0, 10, 0, 10)
	phaseLabel.BackgroundTransparency = 1
	phaseLabel.Font = Enum.Font.FredokaOne
	phaseLabel.Text = "DAY"
	phaseLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
	phaseLabel.TextSize = 28
	phaseLabel.TextStrokeTransparency = 0
	phaseLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	phaseLabel.Parent = mainFrame

	-- Day Number Label
	local dayLabel = Instance.new("TextLabel")
	dayLabel.Name = "DayLabel"
	dayLabel.Size = UDim2.new(1, -20, 0, 25)
	dayLabel.Position = UDim2.new(0, 10, 0, 45)
	dayLabel.BackgroundTransparency = 1
	dayLabel.Font = Enum.Font.FredokaOne
	dayLabel.Text = "Day 1"
	dayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	dayLabel.TextSize = 20
	dayLabel.TextStrokeTransparency = 0
	dayLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	dayLabel.Parent = mainFrame

	-- Timer Label (countdown)
	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.new(1, -20, 0, 40)
	timerLabel.Position = UDim2.new(0, 10, 0, 75)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Font = Enum.Font.FredokaOne
	timerLabel.Text = "3:00"
	timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	timerLabel.TextSize = 36
	timerLabel.TextStrokeTransparency = 0
	timerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	timerLabel.Parent = mainFrame

	-- Status Label (below timer)
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -20, 0, 20)
	statusLabel.Position = UDim2.new(0, 10, 0, 115)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.FredokaOne
	statusLabel.Text = "until night"
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.TextSize = 14
	statusLabel.TextStrokeTransparency = 0
	statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	statusLabel.Parent = mainFrame

	return {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		PhaseLabel = phaseLabel,
		DayLabel = dayLabel,
		TimerLabel = timerLabel,
		StatusLabel = statusLabel
	}
end

-- Format time as MM:SS
local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%d:%02d", minutes, secs)
end

-- Get color for timer based on time remaining
local function getTimerColor(phase, timeRemaining)
	if phase == "Day" then
		if timeRemaining > 30 then
			return Color3.fromRGB(100, 255, 100)  -- Green
		elseif timeRemaining > 10 then
			return Color3.fromRGB(255, 180, 50)  -- Orange
		else
			return Color3.fromRGB(255, 80, 80)  -- Red
		end
	else  -- Night
		return Color3.fromRGB(100, 150, 255)  -- Blue
	end
end

-- Update GUI
local function updateGUI(gui)
	-- Update phase label
	if CurrentPhase == "Day" then
		gui.PhaseLabel.Text = "☀ DAY"
		gui.PhaseLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
		gui.StatusLabel.Text = "until night"
	else
		gui.PhaseLabel.Text = "🌙 NIGHT"
		gui.PhaseLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
		gui.StatusLabel.Text = "until dawn"
	end

	-- Update day number
	gui.DayLabel.Text = "Day " .. CurrentDay

	-- Update timer
	gui.TimerLabel.Text = formatTime(TimeRemaining)
	gui.TimerLabel.TextColor3 = getTimerColor(CurrentPhase, TimeRemaining)
end

-- Show warning notification
local function showWarning(message, duration)
	local gui = playerGui:FindFirstChild("DayNightGUI")
	if not gui then return end

	-- Create warning frame
	local warningFrame = Instance.new("Frame")
	warningFrame.Name = "WarningFrame"
	warningFrame.Size = UDim2.new(0, 400, 0, 80)
	warningFrame.Position = UDim2.new(0.5, -200, 0, -100)  -- Start above screen
	warningFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	warningFrame.BackgroundTransparency = 0.1
	warningFrame.BorderSizePixel = 0
	warningFrame.ZIndex = 10
	warningFrame.Parent = gui

	-- Add rounded corners
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = warningFrame

	-- Add thick black border
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 5
	uiStroke.Color = Color3.fromRGB(0, 0, 0)
	uiStroke.Parent = warningFrame

	-- Warning text
	local warningText = Instance.new("TextLabel")
	warningText.Size = UDim2.new(1, -20, 1, -20)
	warningText.Position = UDim2.new(0, 10, 0, 10)
	warningText.BackgroundTransparency = 1
	warningText.Font = Enum.Font.FredokaOne
	warningText.Text = "⚠ " .. message
	warningText.TextColor3 = Color3.fromRGB(255, 255, 255)
	warningText.TextSize = 24
	warningText.TextStrokeTransparency = 0
	warningText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	warningText.TextWrapped = true
	warningText.Parent = warningFrame

	-- Animate in
	local tweenIn = TweenService:Create(
		warningFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, -200, 0, 100)}
	)
	tweenIn:Play()

	-- Wait and animate out
	task.wait(duration or 3)
	local tweenOut = TweenService:Create(
		warningFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Position = UDim2.new(0.5, -200, 0, -100)}
	)
	tweenOut:Play()
	tweenOut.Completed:Connect(function()
		warningFrame:Destroy()
	end)
end

-- Initialize
local gui = createGUI()
print("[DayNightGUI] GUI created successfully")

-- Handle phase change
PhaseChangeEvent.OnClientEvent:Connect(function(phase, day, timeRemaining)
	CurrentPhase = phase
	CurrentDay = day
	TimeRemaining = timeRemaining
	updateGUI(gui)
	print(string.format("[DayNightGUI] Phase changed to %s (Day %d)", phase, day))
end)

-- Handle timer update
TimerUpdateEvent.OnClientEvent:Connect(function(phase, day, timeRemaining)
	CurrentPhase = phase
	CurrentDay = day
	TimeRemaining = timeRemaining
	updateGUI(gui)
end)

-- Handle warnings
WarningEvent.OnClientEvent:Connect(function(message, seconds)
	print("[DayNightGUI] Warning received:", message)
	showWarning(message, 3)
end)

print("[DayNightGUI] Client initialized and listening for events")
