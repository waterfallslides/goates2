--[[
	NotificationHandler.lua
	Handles notification popups
	SIMPLE, CLEAN, OPTIMIZED

	Place in: StarterGui.NotificationHandler (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get events
local events = ReplicatedStorage:WaitForChild("Events")
local sendNotificationEvent = events:WaitForChild("SendNotification")
local stealAlertEvent = events:WaitForChild("StealAlert")

-- Notification container
local notificationContainer = Instance.new("ScreenGui")
notificationContainer.Name = "NotificationContainer"
notificationContainer.ResetOnSpawn = false
notificationContainer.Parent = playerGui

local notificationsFrame = Instance.new("Frame")
notificationsFrame.Name = "NotificationsFrame"
notificationsFrame.Size = UDim2.new(0.3, 0, 1, 0)
notificationsFrame.Position = UDim2.new(0.7, 0, 0, 0)
notificationsFrame.BackgroundTransparency = 1
notificationsFrame.Parent = notificationContainer

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.Parent = notificationsFrame

-- Create notification
function createNotification(message, notifType)
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(1, 0, 0, 60)
	notification.BackgroundColor3 = getColorForType(notifType)
	notification.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notification

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.9, 0, 1, 0)
	label.Position = UDim2.new(0.05, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = notification

	notification.Parent = notificationsFrame

	-- Tween in
	notification.Position = UDim2.new(1, 0, 0, 0)
	TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()

	-- Auto dismiss after 4 seconds
	task.delay(4, function()
		local tweenOut = TweenService:Create(notification, TweenInfo.new(0.3), {
			Position = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1
		})
		tweenOut:Play()
		tweenOut.Completed:Wait()
		notification:Destroy()
	end)
end

-- Get color based on type
function getColorForType(notifType)
	if notifType == "Success" then
		return Color3.fromRGB(0, 200, 0)
	elseif notifType == "Error" then
		return Color3.fromRGB(200, 0, 0)
	elseif notifType == "Warning" then
		return Color3.fromRGB(255, 165, 0)
	else
		return Color3.fromRGB(50, 50, 200)
	end
end

-- Listen for notifications
sendNotificationEvent.OnClientEvent:Connect(function(message, notifType)
	createNotification(message, notifType or "Info")
end)

-- Listen for steal alerts
stealAlertEvent.OnClientEvent:Connect(function(brainrotID)
	createNotification("Your " .. brainrotID .. " is being stolen!", "Warning")

	-- Play warning sound (optional)
	-- local sound = Instance.new("Sound")
	-- sound.SoundId = "rbxassetid://0" -- Add sound ID
	-- sound.Parent = workspace
	-- sound:Play()
end)

print("✓ NotificationHandler loaded")
