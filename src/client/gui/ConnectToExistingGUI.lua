--[[
	ConnectToExistingGUI.lua
	ONLY connects YOUR existing GUI to server - NO GUI CREATION AT ALL

	Place in: StarterGui/neww/ as LocalScript
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local gui = script.Parent -- neww

-- Get events
local events = ReplicatedStorage:WaitForChild("Events")
local rollBrainrotEvent = events:WaitForChild("RollBrainrot")
local rollResultEvent = events:WaitForChild("RollResult")
local keepBrainrotEvent = events:WaitForChild("KeepBrainrot")
local toggleAutoRoll = events:WaitForChild("ToggleAutoRoll")
local toggleFastRoll = events:WaitForChild("ToggleFastRoll")

-- Get modules
local brainrotData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotData"))

-- Find YOUR DiceFrame
local diceFrame = gui:WaitForChild("DiceFrame")
local rollButton = diceFrame:WaitForChild("Roll")
local autoRollButton = diceFrame:FindFirstChild("AutoRoll")
local fastRollButton = diceFrame:FindFirstChild("FastRoll")

-- Find YOUR RollingFrame
local rollingFrame = gui:WaitForChild("RollingFrame")
local brainrotImage = rollingFrame:WaitForChild("BrainrotImage")
local keepButton = rollingFrame:WaitForChild("Keep")
local rarityLabel = rollingFrame:WaitForChild("Rarity")
local rollingLabel = rollingFrame:WaitForChild("Rolling")
local nameLabel = rollingFrame:WaitForChild("Name")

-- State
local isRolling = false
local autoRollEnabled = false
local fastRollEnabled = false
local currentResult = nil

-- Simple animations
local function animateButton(button)
	local originalSize = button.Size
	TweenService:Create(button, TweenInfo.new(0.1), {Size = originalSize * 0.95}):Play()
	task.wait(0.1)
	TweenService:Create(button, TweenInfo.new(0.1), {Size = originalSize}):Play()
end

local function flickerAnimation()
	for i = 1, 15 do
		brainrotImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		brainrotImage.ImageColor3 = Color3.new(0, 0, 0)
		task.wait(0.08)
		TweenService:Create(brainrotImage, TweenInfo.new(0.07), {Size = UDim2.new(1, 0, 1, 0)}):Play()
		task.wait(0.07)
	end
end

-- Roll button
rollButton.MouseButton1Click:Connect(function()
	if isRolling then return end

	isRolling = true
	animateButton(rollButton)
	rollBrainrotEvent:FireServer()
end)

-- Keep button
keepButton.MouseButton1Click:Connect(function()
	if not currentResult then return end

	animateButton(keepButton)
	keepBrainrotEvent:FireServer(currentResult.BrainrotID, currentResult.Frame)

	currentResult = nil
	isRolling = false
end)

-- AutoRoll button (if exists)
if autoRollButton then
	autoRollButton.MouseButton1Click:Connect(function()
		autoRollEnabled = not autoRollEnabled
		animateButton(autoRollButton)

		autoRollButton.BackgroundColor3 = autoRollEnabled
			and Color3.fromRGB(0, 200, 0)
			or Color3.fromRGB(100, 100, 100)

		toggleAutoRoll:FireServer(autoRollEnabled)

		if autoRollEnabled then
			task.spawn(function()
				while autoRollEnabled do
					task.wait(5)
					if not isRolling and autoRollEnabled then
						rollBrainrotEvent:FireServer()
					end
				end
			end)
		end
	end)
end

-- FastRoll button (if exists)
if fastRollButton then
	fastRollButton.MouseButton1Click:Connect(function()
		fastRollEnabled = not fastRollEnabled
		animateButton(fastRollButton)

		fastRollButton.BackgroundColor3 = fastRollEnabled
			and Color3.fromRGB(0, 200, 0)
			or Color3.fromRGB(100, 100, 100)

		toggleFastRoll:FireServer(fastRollEnabled)
	end)
end

-- Handle server response
rollResultEvent.OnClientEvent:Connect(function(result)
	currentResult = result

	-- Play animation if not fast roll
	if not fastRollEnabled then
		rollingLabel.Text = "ROLLING..."
		flickerAnimation()
	end

	-- Show result
	brainrotImage.Image = result.ImageId
	brainrotImage.ImageColor3 = Color3.new(1, 1, 1)
	rollingLabel.Text = result.DisplayName
	nameLabel.Text = result.DisplayName
	rarityLabel.Text = result.Rarity .. " - " .. result.Frame
	rarityLabel.TextColor3 = result.Color

	-- Pop animation
	brainrotImage.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(brainrotImage, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()

	isRolling = false
end)

print("✓ Connected to YOUR DiceFrame and RollingFrame - NO GUI CREATED")
