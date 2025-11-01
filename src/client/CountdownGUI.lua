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

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LobbyQueueGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "CountdownFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Queue type label
local queueTypeLabel = Instance.new("TextLabel")
queueTypeLabel.Name = "QueueTypeLabel"
queueTypeLabel.Size = UDim2.new(1, 0, 0, 40)
queueTypeLabel.Position = UDim2.new(0, 0, 0, 10)
queueTypeLabel.BackgroundTransparency = 1
queueTypeLabel.Text = "SOLO QUEUE"
queueTypeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
queueTypeLabel.TextSize = 24
queueTypeLabel.Font = Enum.Font.GothamBold
queueTypeLabel.Parent = mainFrame

-- Countdown label
local countdownLabel = Instance.new("TextLabel")
countdownLabel.Name = "CountdownLabel"
countdownLabel.Size = UDim2.new(1, 0, 0, 60)
countdownLabel.Position = UDim2.new(0, 0, 0, 50)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Text = "20"
countdownLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
countdownLabel.TextSize = 48
countdownLabel.Font = Enum.Font.GothamBold
countdownLabel.Parent = mainFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 110)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Waiting for players..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 16
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

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

print("[CountdownGUI] Client GUI initialized!")
