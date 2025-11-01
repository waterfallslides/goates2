--[[
	COUNTDOWN GUI CLIENT SCRIPT
	Displays countdown timer when player joins a queue
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for remote events
local remoteEventsFolder = ReplicatedStorage:WaitForChild("LobbyQueueEvents", 10)
if not remoteEventsFolder then
	warn("[CountdownGUI] LobbyQueueEvents folder not found!")
	return
end

local CountdownEvent = remoteEventsFolder:WaitForChild("CountdownUpdate", 10)
local QueueJoinEvent = remoteEventsFolder:WaitForChild("QueueJoin", 10)
local QueueLeaveEvent = remoteEventsFolder:WaitForChild("QueueLeave", 10)

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LobbyQueueGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "CountdownFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 180)
mainFrame.Position = UDim2.new(0.5, -175, 0.05, 0)  -- Even higher on screen (5% from top)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = mainFrame

-- Add border stroke for cartoony effect
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 4
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = mainFrame

-- Queue type label
local queueTypeLabel = Instance.new("TextLabel")
queueTypeLabel.Name = "QueueTypeLabel"
queueTypeLabel.Size = UDim2.new(1, 0, 0, 50)
queueTypeLabel.Position = UDim2.new(0, 0, 0, 5)
queueTypeLabel.BackgroundTransparency = 1
queueTypeLabel.Text = "SOLO QUEUE"
queueTypeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
queueTypeLabel.TextSize = 28
queueTypeLabel.Font = Enum.Font.FredokaOne  -- More cartoony font
queueTypeLabel.Parent = mainFrame

-- Add text stroke for cartoony effect
local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Thickness = 3
titleStroke.Parent = queueTypeLabel

-- Countdown label
local countdownLabel = Instance.new("TextLabel")
countdownLabel.Name = "CountdownLabel"
countdownLabel.Size = UDim2.new(1, 0, 0, 80)
countdownLabel.Position = UDim2.new(0, 0, 0, 50)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Text = "20"
countdownLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
countdownLabel.TextSize = 64
countdownLabel.Font = Enum.Font.FredokaOne  -- More cartoony font
countdownLabel.Parent = mainFrame

-- Add thick text stroke for cartoony effect
local countdownStroke = Instance.new("UIStroke")
countdownStroke.Color = Color3.fromRGB(0, 0, 0)
countdownStroke.Thickness = 5
countdownStroke.Parent = countdownLabel

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 40)
statusLabel.Position = UDim2.new(0, 0, 0, 135)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Waiting for players..."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 20
statusLabel.Font = Enum.Font.FredokaOne  -- More cartoony font
statusLabel.Parent = mainFrame

-- Add text stroke for cartoony effect
local statusStroke = Instance.new("UIStroke")
statusStroke.Color = Color3.fromRGB(0, 0, 0)
statusStroke.Thickness = 2
statusStroke.Parent = statusLabel

-- Queue colors
local QueueColors = {
	Solo = Color3.fromRGB(0, 170, 255),
	Duo = Color3.fromRGB(0, 255, 0),
	Squad = Color3.fromRGB(255, 170, 0)
}

-- Handle queue join event
if QueueJoinEvent then
	QueueJoinEvent.OnClientEvent:Connect(function(queueType, playersInQueue, maxPlayers)
		print("[CountdownGUI] Joined " .. queueType .. " queue (" .. playersInQueue .. "/" .. maxPlayers .. ")")

		-- Update GUI
		queueTypeLabel.Text = string.upper(queueType) .. " QUEUE"
		statusLabel.Text = "Players: " .. playersInQueue .. "/" .. maxPlayers

		-- Set color based on queue type
		if QueueColors[queueType] then
			mainFrame.BackgroundColor3 = Color3.fromRGB(
				QueueColors[queueType].R * 255 * 0.2,
				QueueColors[queueType].G * 255 * 0.2,
				QueueColors[queueType].B * 255 * 0.2
			)
			queueTypeLabel.TextColor3 = QueueColors[queueType]
		end
	end)
end

-- Handle countdown updates
if CountdownEvent then
	CountdownEvent.OnClientEvent:Connect(function(timeRemaining, queueType)
		-- Show GUI if hidden
		if not mainFrame.Visible then
			mainFrame.Visible = true
		end

		-- Update countdown
		countdownLabel.Text = tostring(timeRemaining)

		-- Change color based on time remaining
		if timeRemaining <= 5 then
			countdownLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
			statusLabel.Text = "Teleporting soon!"
		elseif timeRemaining <= 10 then
			countdownLabel.TextColor3 = Color3.fromRGB(255, 170, 0) -- Orange
			statusLabel.Text = "Get ready..."
		else
			countdownLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
			statusLabel.Text = "Starting game..."
		end

		-- Hide GUI when countdown reaches 0
		if timeRemaining == 0 then
			statusLabel.Text = "Teleporting now!"
			task.wait(1)
			mainFrame.Visible = false
		end
	end)
end

-- Handle queue leave event
if QueueLeaveEvent then
	QueueLeaveEvent.OnClientEvent:Connect(function()
		print("[CountdownGUI] Left queue - hiding GUI")
		mainFrame.Visible = false
	end)
end

print("[CountdownGUI] Client GUI initialized!")
