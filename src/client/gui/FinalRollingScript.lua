--[[
	FinalRollingScript.lua
	ONLY CONNECTS YOUR EXISTING DICEFRAME AND ROLLINGFRAME
	CREATES ZERO GUI ELEMENTS

	Place in: StarterGui/neww/DiceFrame/ as LocalScript
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Get events
local events = ReplicatedStorage:WaitForChild("Events")
local rollBrainrotEvent = events:WaitForChild("RollBrainrot")
local rollResultEvent = events:WaitForChild("RollResult")
local keepBrainrotEvent = events:WaitForChild("KeepBrainrot")
local toggleAutoRoll = events:WaitForChild("ToggleAutoRoll")
local toggleFastRoll = events:WaitForChild("ToggleFastRoll")

-- Get modules
local brainrotData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotData"))

-- Find YOUR DiceFrame (this script is IN DiceFrame)
local diceFrame = script.Parent
local rollButton = diceFrame:WaitForChild("Roll")
local autoRollButton = diceFrame:FindFirstChild("AutoRoll")
local fastRollButton = diceFrame:FindFirstChild("FastRoll")

-- Find YOUR RollingFrame (sibling of DiceFrame)
local gui = diceFrame.Parent -- neww
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

-- Simple button bounce animation
local function buttonBounce(button)
	local original = button.Size
	TweenService:Create(button, TweenInfo.new(0.1), {
		Size = original * 0.95
	}):Play()
	task.wait(0.1)
	TweenService:Create(button, TweenInfo.new(0.1), {
		Size = original
	}):Play()
end

-- Flicker animation on YOUR image
local function flickerAnimation()
	for i = 1, 15 do
		brainrotImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		brainrotImage.ImageColor3 = Color3.new(0, 0, 0)
		task.wait(0.15)
	end
end

-- Roll button clicked
rollButton.MouseButton1Click:Connect(function()
	if isRolling then return end

	isRolling = true
	buttonBounce(rollButton)

	-- Tell server to roll
	rollBrainrotEvent:FireServer()
end)

-- Keep button clicked
keepButton.MouseButton1Click:Connect(function()
	if not currentResult then return end

	buttonBounce(keepButton)

	-- Tell server to keep
	keepBrainrotEvent:FireServer(currentResult.BrainrotID, currentResult.Frame)

	-- Reset
	currentResult = nil
	isRolling = false
end)

-- AutoRoll button (if you have it)
if autoRollButton then
	autoRollButton.MouseButton1Click:Connect(function()
		autoRollEnabled = not autoRollEnabled
		buttonBounce(autoRollButton)

		-- Change color
		if autoRollEnabled then
			autoRollButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		else
			autoRollButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end

		-- Tell server
		toggleAutoRoll:FireServer(autoRollEnabled)

		-- Auto roll loop
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

-- FastRoll button (if you have it)
if fastRollButton then
	fastRollButton.MouseButton1Click:Connect(function()
		fastRollEnabled = not fastRollEnabled
		buttonBounce(fastRollButton)

		-- Change color
		if fastRollEnabled then
			fastRollButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		else
			fastRollButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end

		-- Tell server
		toggleFastRoll:FireServer(fastRollEnabled)
	end)
end

-- Server sent a roll result
rollResultEvent.OnClientEvent:Connect(function(result)
	currentResult = result

	-- Update YOUR labels
	rollingLabel.Text = result.DisplayName
	nameLabel.Text = result.DisplayName
	rarityLabel.Text = result.Rarity .. " - " .. result.Frame
	rarityLabel.TextColor3 = result.Color

	-- Play flicker if not fast roll
	if not fastRollEnabled then
		rollingLabel.Text = "ROLLING..."
		flickerAnimation()
	end

	-- Show result in YOUR image
	brainrotImage.Image = result.ImageId
	brainrotImage.ImageColor3 = Color3.new(1, 1, 1)

	-- Pop animation on YOUR image
	brainrotImage.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(brainrotImage, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()

	-- Update labels again after flicker
	rollingLabel.Text = result.DisplayName

	isRolling = false
end)

print("✓ Connected to YOUR DiceFrame and RollingFrame")
