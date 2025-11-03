--[[
	RebirthUIHandler.lua
	Handles rebirth UI
	SIMPLE, CLEAN, OPTIMIZED

	Place in: StarterGui.neww.Rebirth.RebirthUIHandler (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local rebirthFrame = script.Parent -- Rebirth frame

-- Get events
local events = ReplicatedStorage:WaitForChild("Events")
local processRebirthEvent = events:WaitForChild("ProcessRebirth")
local getRebirthStatus = events:WaitForChild("GetRebirthStatus")

-- UI elements
local rebirthButton = rebirthFrame:WaitForChild("Rebirth")
local closeButton = rebirthFrame:WaitForChild("Close")
local notEnoughLabel = rebirthFrame:WaitForChild("NotEnoughMoney") -- Repurpose as "not enough brainrots"
local barFrame = rebirthFrame:WaitForChild("Bar")
local barLabel = barFrame:WaitForChild("TextLabel")

-- Update UI
function updateUI()
	local status = getRebirthStatus:InvokeServer()

	if not status then return end

	-- Update progress bar
	local fillSize = status.Progress or 0
	barFrame.Size = UDim2.new(fillSize, 0, 1, 0)

	-- Update text
	barLabel.Text = string.format("%d/%d Collected", status.Collected, status.Total)

	-- Enable/disable rebirth button
	if status.CanRebirth then
		rebirthButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		notEnoughLabel.Visible = false
		rebirthButton.Active = true
	else
		rebirthButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		notEnoughLabel.Visible = true
		notEnoughLabel.Text = status.Message or "Collect all brainrots first!"
		rebirthButton.Active = false
	end
end

-- Rebirth button
rebirthButton.MouseButton1Click:Connect(function()
	if not rebirthButton.Active then return end

	-- Confirmation
	local confirm = true -- In real game, show confirmation dialog

	if confirm then
		processRebirthEvent:FireServer()
		rebirthFrame.Visible = false
	end
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
	rebirthFrame.Visible = false
end)

-- Update when opened
rebirthFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if rebirthFrame.Visible then
		updateUI()
	end
end)

print("✓ RebirthUIHandler loaded")
