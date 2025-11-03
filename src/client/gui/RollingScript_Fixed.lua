--[[
	RollingScript_Fixed.lua
	Properly connects DiceFrame and RollingFrame with show/hide logic

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
local rollingLabel = rollingFrame:WaitForChild("Rolling") -- Shows name
local nameLabel = rollingFrame:WaitForChild("Name")

-- State
local isRolling = false
local autoRollEnabled = false
local fastRollEnabled = false
local currentResult = nil

-- Initialize - hide elements that appear after roll
local function initializeUI()
	-- Hide RollingFrame initially
	rollingFrame.Visible = false

	-- Hide Keep button initially
	keepButton.Visible = false

	-- Clear labels
	rollingLabel.Text = ""
	nameLabel.Text = ""
	rarityLabel.Text = ""
	brainrotImage.Image = ""
end

-- Show RollingFrame and start rolling
local function startRolling()
	-- Show RollingFrame
	rollingFrame.Visible = true

	-- Hide Keep button during roll
	keepButton.Visible = false

	-- Show "ROLLING..." text
	rollingLabel.Text = "ROLLING..."
	nameLabel.Text = ""
	rarityLabel.Text = "???"
end

-- Hide RollingFrame (after keeping)
local function hideRollingFrame()
	rollingFrame.Visible = false
	keepButton.Visible = false
	brainrotImage.Image = ""
	rollingLabel.Text = ""
	nameLabel.Text = ""
	rarityLabel.Text = ""
end

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

		-- Small pulse
		TweenService:Create(brainrotImage, TweenInfo.new(0.08), {
			Size = UDim2.new(0.95, 0, 0.95, 0)
		}):Play()
		task.wait(0.08)

		TweenService:Create(brainrotImage, TweenInfo.new(0.07), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		task.wait(0.07)
	end
end

-- Show result after rolling
local function showResult(result)
	-- Update image
	brainrotImage.Image = result.ImageId
	brainrotImage.ImageColor3 = Color3.new(1, 1, 1)

	-- Update labels
	rollingLabel.Text = result.DisplayName
	nameLabel.Text = result.DisplayName
	rarityLabel.Text = result.Rarity .. " - " .. result.Frame
	rarityLabel.TextColor3 = result.Color

	-- Pop animation
	brainrotImage.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(brainrotImage, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()

	-- Show Keep button now
	keepButton.Visible = true
end

-- Roll button clicked
rollButton.MouseButton1Click:Connect(function()
	if isRolling then return end

	print("Roll button clicked!")
	isRolling = true
	buttonBounce(rollButton)

	-- Show RollingFrame and start animation
	startRolling()

	-- Tell server to roll
	rollBrainrotEvent:FireServer()
end)

-- Keep button clicked
keepButton.MouseButton1Click:Connect(function()
	if not currentResult then return end

	print("Keep button clicked!")
	buttonBounce(keepButton)

	-- Tell server to keep
	keepBrainrotEvent:FireServer(currentResult.BrainrotID, currentResult.Frame)

	-- Hide RollingFrame
	hideRollingFrame()

	-- Reset
	currentResult = nil
	isRolling = false
end)

-- AutoRoll button (if you have it)
if autoRollButton then
	autoRollButton.MouseButton1Click:Connect(function()
		autoRollEnabled = not autoRollEnabled
		buttonBounce(autoRollButton)

		print("AutoRoll toggled:", autoRollEnabled)

		-- Change color to show state
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
						print("AutoRoll triggered!")
						isRolling = true
						startRolling()
						rollBrainrotEvent:FireServer()
					end
				end
			end)
		end
	end)
else
	warn("AutoRoll button not found - skipping")
end

-- FastRoll button (if you have it)
if fastRollButton then
	fastRollButton.MouseButton1Click:Connect(function()
		fastRollEnabled = not fastRollEnabled
		buttonBounce(fastRollButton)

		print("FastRoll toggled:", fastRollEnabled)

		-- Change color to show state
		if fastRollEnabled then
			fastRollButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		else
			fastRollButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end

		-- Tell server
		toggleFastRoll:FireServer(fastRollEnabled)
	end)
else
	warn("FastRoll button not found - skipping")
end

-- Server sent a roll result
rollResultEvent.OnClientEvent:Connect(function(result)
	print("Received roll result:", result.DisplayName)
	currentResult = result

	-- Play flicker if not fast roll
	if not fastRollEnabled then
		flickerAnimation()
	end

	-- Show result
	showResult(result)

	isRolling = false
end)

-- Initialize UI on load
initializeUI()

print("✓ RollingScript connected to DiceFrame and RollingFrame")
print("  - Roll button:", rollButton and "Found" or "NOT FOUND")
print("  - Keep button:", keepButton and "Found" or "NOT FOUND")
print("  - AutoRoll button:", autoRollButton and "Found" or "NOT FOUND")
print("  - FastRoll button:", fastRollButton and "Found" or "NOT FOUND")
