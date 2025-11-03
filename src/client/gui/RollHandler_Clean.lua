--[[
	RollHandler.lua
	Hooks up YOUR existing DiceFrame + RollingFrame
	NO GUI CREATION - Uses what you built!

	Place in: StarterGui/neww/ as LocalScript
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local gui = script.Parent -- neww ScreenGui

-- Get events
local events = ReplicatedStorage:WaitForChild("Events")
local rollBrainrotEvent = events:WaitForChild("RollBrainrot")
local rollResultEvent = events:WaitForChild("RollResult")
local keepBrainrotEvent = events:WaitForChild("KeepBrainrot")
local toggleAutoRoll = events:WaitForChild("ToggleAutoRoll")
local toggleFastRoll = events:WaitForChild("ToggleFastRoll")

-- Get modules
local brainrotData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotData"))

-- Get YOUR frames
local diceFrame = gui:WaitForChild("DiceFrame")
local rollingFrame = gui:WaitForChild("RollingFrame")

-- Get DiceFrame buttons
local rollButton = diceFrame:WaitForChild("Roll")
local autoRollButton = diceFrame:FindFirstChild("AutoRoll")
local fastRollButton = diceFrame:FindFirstChild("FastRoll")

-- Get RollingFrame elements
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

-- Simple button animation
local function animateButton(button)
	local originalSize = button.Size
	TweenService:Create(button, TweenInfo.new(0.1), {
		Size = originalSize - UDim2.new(0, 4, 0, 4)
	}):Play()
	task.wait(0.1)
	TweenService:Create(button, TweenInfo.new(0.1), {
		Size = originalSize
	}):Play()
end

-- Roll animation (simple flicker)
local function playRollAnimation()
	rollingLabel.Text = "ROLLING..."
	rarityLabel.Text = "???"
	nameLabel.Text = "???"

	-- Show rolling frame
	rollingFrame.Visible = true

	-- Flicker 15 times
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

-- Show result
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

	-- Show keep button
	keepButton.Visible = true
end

-- Hide rolling frame
local function hideRollingFrame()
	rollingFrame.Visible = false
	keepButton.Visible = false
	brainrotImage.Image = ""
	rollingLabel.Text = ""
	nameLabel.Text = ""
	rarityLabel.Text = ""
end

-- Roll button click
rollButton.MouseButton1Click:Connect(function()
	if isRolling then return end

	isRolling = true
	animateButton(rollButton)

	rollBrainrotEvent:FireServer()
end)

-- Keep button click
keepButton.MouseButton1Click:Connect(function()
	if not currentResult then return end

	animateButton(keepButton)
	keepBrainrotEvent:FireServer(currentResult.BrainrotID, currentResult.Frame)

	hideRollingFrame()
	currentResult = nil
	isRolling = false
end)

-- Auto roll toggle
if autoRollButton then
	autoRollButton.MouseButton1Click:Connect(function()
		autoRollEnabled = not autoRollEnabled
		animateButton(autoRollButton)

		-- Visual feedback (change color or text)
		if autoRollEnabled then
			autoRollButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		else
			autoRollButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end

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

-- Fast roll toggle
if fastRollButton then
	fastRollButton.MouseButton1Click:Connect(function()
		fastRollEnabled = not fastRollEnabled
		animateButton(fastRollButton)

		if fastRollEnabled then
			fastRollButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		else
			fastRollButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end

		toggleFastRoll:FireServer(fastRollEnabled)
	end)
end

-- Handle roll result from server
rollResultEvent.OnClientEvent:Connect(function(result)
	currentResult = result

	if fastRollEnabled then
		-- Skip animation, show result instantly
		rollingFrame.Visible = true
		showResult(result)
	else
		-- Play animation then show result
		playRollAnimation()
		showResult(result)
	end

	isRolling = false
end)

-- Initialize
hideRollingFrame()
print("✓ RollHandler connected to DiceFrame + RollingFrame")
