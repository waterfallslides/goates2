--[[
	RollHandler.lua
	Hooks up existing rolling GUI with animations
	SIMPLE, CLEAN, OPTIMIZED

	Place in: StarterGui.neww.DiceFrame (or wherever RollingFrame is) as LocalScript
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
local skipBrainrotEvent = events:WaitForChild("SkipBrainrot")

-- Get modules
local brainrotData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotData"))

-- Find the RollingFrame (adjust path if needed)
local rollingFrame = script.Parent:WaitForChild("RollingFrame")

-- Get UI elements
local brainrotImage = rollingFrame:WaitForChild("BrainrotImage")
local keepButton = rollingFrame:WaitForChild("Keep")
local rollButton = rollingFrame:WaitForChild("Roll")
local rarityLabel = rollingFrame:WaitForChild("Rarity")
local rollingLabel = rollingFrame:WaitForChild("Rolling") -- Shows brainrot name
local nameLabel = rollingFrame:WaitForChild("Name")

-- State
local isRolling = false
local currentResult = nil

-- Simple animations
local function animateButton(button)
	-- Bounce effect on click
	local originalSize = button.Size

	TweenService:Create(button, TweenInfo.new(0.1), {
		Size = originalSize - UDim2.new(0.05, 0, 0.05, 0)
	}):Play()

	task.wait(0.1)

	TweenService:Create(button, TweenInfo.new(0.1), {
		Size = originalSize
	}):Play()
end

local function animateHover(button, isEntering)
	if isEntering then
		TweenService:Create(button, TweenInfo.new(0.2), {
			Size = button.Size + UDim2.new(0.02, 0, 0.02, 0),
			BackgroundTransparency = 0
		}):Play()
	else
		TweenService:Create(button, TweenInfo.new(0.2), {
			Size = button.Size - UDim2.new(0.02, 0, 0.02, 0),
			BackgroundTransparency = 0
		}):Play()
	end
end

-- Roll animation (simple flicker)
local function playRollAnimation()
	rollingLabel.Text = "ROLLING..."

	-- Flicker effect - show random brainrots
	for i = 1, 15 do
		local randomBrainrot = brainrotData.Brainrots[math.random(1, #brainrotData.Brainrots)]

		-- Set to placeholder/black
		brainrotImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		brainrotImage.ImageColor3 = Color3.new(0, 0, 0)

		-- Quick scale pulse
		TweenService:Create(brainrotImage, TweenInfo.new(0.08), {
			Size = UDim2.new(0.9, 0, 0.9, 0)
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
	rollingLabel.Text = result.DisplayName or "???"
	nameLabel.Text = result.DisplayName or "???"
	rarityLabel.Text = result.Rarity .. " - " .. result.Frame
	rarityLabel.TextColor3 = result.Color

	-- Pop-in animation
	brainrotImage.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(brainrotImage, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()

	-- Glow effect on rarity label
	TweenService:Create(rarityLabel, TweenInfo.new(0.5), {
		TextTransparency = 0,
		TextStrokeTransparency = 0
	}):Play()

	-- Show keep button, hide roll button
	keepButton.Visible = true
	rollButton.Visible = false

	-- Fade in keep button
	keepButton.BackgroundTransparency = 1
	TweenService:Create(keepButton, TweenInfo.new(0.3), {
		BackgroundTransparency = 0
	}):Play()
end

-- Hide result (reset to initial state)
local function hideResult()
	keepButton.Visible = false
	rollButton.Visible = true

	brainrotImage.Image = ""
	rollingLabel.Text = "Press Roll!"
	nameLabel.Text = ""
	rarityLabel.Text = ""
end

-- Setup hover effects
rollButton.MouseEnter:Connect(function()
	animateHover(rollButton, true)
end)

rollButton.MouseLeave:Connect(function()
	animateHover(rollButton, false)
end)

keepButton.MouseEnter:Connect(function()
	animateHover(keepButton, true)
end)

keepButton.MouseLeave:Connect(function()
	animateHover(keepButton, false)
end)

-- Roll button click
rollButton.MouseButton1Click:Connect(function()
	if isRolling then return end

	isRolling = true
	animateButton(rollButton)

	-- Fire to server
	rollBrainrotEvent:FireServer()
end)

-- Keep button click
keepButton.MouseButton1Click:Connect(function()
	if not currentResult then return end

	animateButton(keepButton)

	-- Send to server
	keepBrainrotEvent:FireServer(currentResult.BrainrotID, currentResult.Frame)

	-- Hide result
	hideResult()
	currentResult = nil
	isRolling = false
end)

-- Handle roll result from server
rollResultEvent.OnClientEvent:Connect(function(result)
	currentResult = result

	-- Play animation
	playRollAnimation()

	-- Show result
	showResult(result)

	isRolling = false
end)

-- Initialize
hideResult()
print("✓ RollHandler loaded and connected to existing GUI")
