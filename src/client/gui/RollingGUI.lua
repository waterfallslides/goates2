--[[
	RollingGUI.lua
	Complete rolling interface with animations
	SIMPLE, CLEAN, OPTIMIZED

	Place in: StarterGui/RollingGUI (LocalScript)
	This creates a standalone rolling interface
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get events
local events = ReplicatedStorage:WaitForChild("Events")
local rollBrainrotEvent = events:WaitForChild("RollBrainrot")
local rollResultEvent = events:WaitForChild("RollResult")
local keepBrainrotEvent = events:WaitForChild("KeepBrainrot")
local skipBrainrotEvent = events:WaitForChild("SkipBrainrot")
local toggleAutoRoll = events:WaitForChild("ToggleAutoRoll")
local toggleFastRoll = events:WaitForChild("ToggleFastRoll")

-- Get modules
local brainrotData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotData"))
local config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RollingGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main rolling frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 50)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🎲 ROLL FOR BRAINROT"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Display area
local displayFrame = Instance.new("Frame")
displayFrame.Name = "DisplayFrame"
displayFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
displayFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
displayFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
displayFrame.BorderSizePixel = 0
displayFrame.Parent = mainFrame

local displayCorner = Instance.new("UICorner")
displayCorner.CornerRadius = UDim.new(0, 8)
displayCorner.Parent = displayFrame

-- Brainrot image
local brainrotImage = Instance.new("ImageLabel")
brainrotImage.Name = "BrainrotImage"
brainrotImage.Size = UDim2.new(0.8, 0, 0.6, 0)
brainrotImage.Position = UDim2.new(0.1, 0, 0.05, 0)
brainrotImage.BackgroundTransparency = 1
brainrotImage.Image = ""
brainrotImage.ScaleType = Enum.ScaleType.Fit
brainrotImage.Parent = displayFrame

-- Name label
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "NameLabel"
nameLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
nameLabel.Position = UDim2.new(0.05, 0, 0.68, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "???"
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Parent = displayFrame

-- Rarity label
local rarityLabel = Instance.new("TextLabel")
rarityLabel.Name = "RarityLabel"
rarityLabel.Size = UDim2.new(0.9, 0, 0.12, 0)
rarityLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
rarityLabel.BackgroundTransparency = 1
rarityLabel.Text = ""
rarityLabel.TextColor3 = Color3.new(1, 1, 1)
rarityLabel.TextScaled = true
rarityLabel.Font = Enum.Font.Gotham
rarityLabel.Parent = displayFrame

-- Button container
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(0.9, 0, 0.25, 0)
buttonContainer.Position = UDim2.new(0.05, 0, 0.68, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

-- Roll button
local rollButton = Instance.new("TextButton")
rollButton.Name = "RollButton"
rollButton.Size = UDim2.new(1, 0, 0.3, 0)
rollButton.Position = UDim2.new(0, 0, 0, 0)
rollButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
rollButton.Text = "🎲 ROLL"
rollButton.TextColor3 = Color3.new(1, 1, 1)
rollButton.TextScaled = true
rollButton.Font = Enum.Font.GothamBold
rollButton.Parent = buttonContainer

local rollCorner = Instance.new("UICorner")
rollCorner.CornerRadius = UDim.new(0, 8)
rollCorner.Parent = rollButton

-- Keep button (hidden initially)
local keepButton = Instance.new("TextButton")
keepButton.Name = "KeepButton"
keepButton.Size = UDim2.new(0.48, 0, 0.3, 0)
keepButton.Position = UDim2.new(0, 0, 0.35, 0)
keepButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
keepButton.Text = "✓ KEEP"
keepButton.TextColor3 = Color3.new(1, 1, 1)
keepButton.TextScaled = true
keepButton.Font = Enum.Font.GothamBold
keepButton.Visible = false
keepButton.Parent = buttonContainer

local keepCorner = Instance.new("UICorner")
keepCorner.CornerRadius = UDim.new(0, 8)
keepCorner.Parent = keepButton

-- Skip button (hidden initially)
local skipButton = Instance.new("TextButton")
skipButton.Name = "SkipButton"
skipButton.Size = UDim2.new(0.48, 0, 0.3, 0)
skipButton.Position = UDim2.new(0.52, 0, 0.35, 0)
skipButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
skipButton.Text = "✗ SKIP"
skipButton.TextColor3 = Color3.new(1, 1, 1)
skipButton.TextScaled = true
skipButton.Font = Enum.Font.GothamBold
skipButton.Visible = false
skipButton.Parent = buttonContainer

local skipCorner = Instance.new("UICorner")
skipCorner.CornerRadius = UDim.new(0, 8)
skipCorner.Parent = skipButton

-- Toggle buttons
local autoRollButton = Instance.new("TextButton")
autoRollButton.Name = "AutoRollButton"
autoRollButton.Size = UDim2.new(0.48, 0, 0.25, 0)
autoRollButton.Position = UDim2.new(0, 0, 0.72, 0)
autoRollButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
autoRollButton.Text = "⚡ AUTO ROLL: OFF"
autoRollButton.TextColor3 = Color3.new(1, 1, 1)
autoRollButton.TextScaled = true
autoRollButton.Font = Enum.Font.Gotham
autoRollButton.Parent = buttonContainer

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 8)
autoCorner.Parent = autoRollButton

local fastRollButton = Instance.new("TextButton")
fastRollButton.Name = "FastRollButton"
fastRollButton.Size = UDim2.new(0.48, 0, 0.25, 0)
fastRollButton.Position = UDim2.new(0.52, 0, 0.72, 0)
fastRollButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
fastRollButton.Text = "⚡ FAST ROLL: OFF"
fastRollButton.TextColor3 = Color3.new(1, 1, 1)
fastRollButton.TextScaled = true
fastRollButton.Font = Enum.Font.Gotham
fastRollButton.Parent = buttonContainer

local fastCorner = Instance.new("UICorner")
fastCorner.CornerRadius = UDim.new(0, 8)
fastCorner.Parent = fastRollButton

-- State
local isRolling = false
local autoRollEnabled = false
local fastRollEnabled = false
local currentResult = nil

-- Animation functions
local function playFlickerAnimation()
	for i = 1, 15 do
		local randomBrainrot = brainrotData.Brainrots[math.random(1, #brainrotData.Brainrots)]
		brainrotImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		brainrotImage.ImageColor3 = Color3.new(0, 0, 0)
		nameLabel.Text = "???"
		rarityLabel.Text = "ROLLING..."
		task.wait(0.15)
	end
end

local function showResult(result)
	-- Update image
	brainrotImage.Image = result.ImageId
	brainrotImage.ImageColor3 = Color3.new(1, 1, 1)

	-- Update labels
	nameLabel.Text = result.DisplayName
	rarityLabel.Text = result.Rarity .. " - " .. result.Frame
	rarityLabel.TextColor3 = result.Color

	-- Show keep/skip buttons
	keepButton.Visible = true
	skipButton.Visible = true
	rollButton.Visible = false

	-- Tween in
	TweenService:Create(displayFrame, TweenInfo.new(0.3), {BackgroundColor3 = result.Color}):Play()
end

local function hideResult()
	keepButton.Visible = false
	skipButton.Visible = false
	rollButton.Visible = true

	brainrotImage.Image = ""
	nameLabel.Text = "Press Roll!"
	rarityLabel.Text = ""

	TweenService:Create(displayFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
end

-- Button hover effects
local function setupHoverEffect(button, normalColor, hoverColor)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = hoverColor,
			Size = button.Size + UDim2.new(0, 0, 0.02, 0)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = normalColor,
			Size = button.Size - UDim2.new(0, 0, 0.02, 0)
		}):Play()
	end)
end

setupHoverEffect(rollButton, Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 180, 255))
setupHoverEffect(keepButton, Color3.fromRGB(0, 200, 0), Color3.fromRGB(0, 230, 0))
setupHoverEffect(skipButton, Color3.fromRGB(200, 0, 0), Color3.fromRGB(230, 0, 0))

-- Roll button click
rollButton.MouseButton1Click:Connect(function()
	if isRolling then return end

	isRolling = true
	rollButton.Text = "ROLLING..."

	rollBrainrotEvent:FireServer()
end)

-- Keep button click
keepButton.MouseButton1Click:Connect(function()
	if not currentResult then return end

	keepBrainrotEvent:FireServer(currentResult.BrainrotID, currentResult.Frame)
	hideResult()
	currentResult = nil
	isRolling = false
	rollButton.Text = "🎲 ROLL"
end)

-- Skip button click
skipButton.MouseButton1Click:Connect(function()
	if not currentResult then return end

	skipBrainrotEvent:FireServer()
	hideResult()
	currentResult = nil
	isRolling = false
	rollButton.Text = "🎲 ROLL"
end)

-- Auto roll toggle
autoRollButton.MouseButton1Click:Connect(function()
	autoRollEnabled = not autoRollEnabled

	if autoRollEnabled then
		autoRollButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		autoRollButton.Text = "⚡ AUTO ROLL: ON"
	else
		autoRollButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		autoRollButton.Text = "⚡ AUTO ROLL: OFF"
	end

	toggleAutoRoll:FireServer(autoRollEnabled)

	-- Start auto rolling
	if autoRollEnabled then
		task.spawn(function()
			while autoRollEnabled do
				task.wait(config.Rolling.AutoRollInterval)
				if autoRollEnabled and not isRolling then
					rollBrainrotEvent:FireServer()
				end
			end
		end)
	end
end)

-- Fast roll toggle
fastRollButton.MouseButton1Click:Connect(function()
	fastRollEnabled = not fastRollEnabled

	if fastRollEnabled then
		fastRollButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		fastRollButton.Text = "⚡ FAST ROLL: ON"
	else
		fastRollButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		fastRollButton.Text = "⚡ FAST ROLL: OFF"
	end

	toggleFastRoll:FireServer(fastRollEnabled)
end)

-- Handle roll result
rollResultEvent.OnClientEvent:Connect(function(result)
	currentResult = result

	if fastRollEnabled then
		showResult(result)
	else
		playFlickerAnimation()
		showResult(result)
	end

	isRolling = false
	rollButton.Text = "🎲 ROLL"
end)

-- Initialize
hideResult()
print("✓ RollingGUI loaded")
