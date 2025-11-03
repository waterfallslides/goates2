--[[
	RollHandler.lua
	Handles rolling UI and animations
	SIMPLE, CLEAN, OPTIMIZED

	Place in: StarterGui.neww.DiceFrame.RollHandler (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local gui = script.Parent.Parent -- neww ScreenGui
local diceFrame = script.Parent -- DiceFrame

-- Get events
local events = ReplicatedStorage:WaitForChild("Events")
local rollBrainrotEvent = events:WaitForChild("RollBrainrot")
local rollResultEvent = events:WaitForChild("RollResult")
local keepBrainrotEvent = events:WaitForChild("KeepBrainrot")
local skipBrainrotEvent = events:WaitForChild("SkipBrainrot")

-- Get modules
local brainrotData = require(ReplicatedStorage.Modules.BrainrotData)
local config = require(ReplicatedStorage.Modules.Config)

-- UI elements (create these or find existing ones)
local rollButton = diceFrame:FindFirstChild("RollButton") or Instance.new("TextButton")
local autoRollButton = diceFrame:FindFirstChild("AutoRollButton") or Instance.new("TextButton")
local fastRollButton = diceFrame:FindFirstChild("FastRollButton") or Instance.new("TextButton")

-- Result display (create if not exists)
local resultFrame = diceFrame:FindFirstChild("ResultFrame")
if not resultFrame then
	resultFrame = Instance.new("Frame")
	resultFrame.Name = "ResultFrame"
	resultFrame.Size = UDim2.new(0, 300, 0, 400)
	resultFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
	resultFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	resultFrame.Visible = false
	resultFrame.Parent = diceFrame

	-- Image
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "BrainrotImage"
	imageLabel.Size = UDim2.new(0.8, 0, 0.5, 0)
	imageLabel.Position = UDim2.new(0.1, 0, 0.05, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Parent = resultFrame

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
	nameLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = resultFrame

	-- Rarity
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Size = UDim2.new(0.8, 0, 0.08, 0)
	rarityLabel.Position = UDim2.new(0.1, 0, 0.7, 0)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.TextColor3 = Color3.new(1, 1, 1)
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.Gotham
	rarityLabel.Parent = resultFrame

	-- Keep button
	local keepButton = Instance.new("TextButton")
	keepButton.Name = "KeepButton"
	keepButton.Size = UDim2.new(0.35, 0, 0.1, 0)
	keepButton.Position = UDim2.new(0.1, 0, 0.85, 0)
	keepButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	keepButton.Text = "Keep"
	keepButton.TextColor3 = Color3.new(1, 1, 1)
	keepButton.TextScaled = true
	keepButton.Font = Enum.Font.GothamBold
	keepButton.Parent = resultFrame

	-- Skip button
	local skipButton = Instance.new("TextButton")
	skipButton.Name = "SkipButton"
	skipButton.Size = UDim2.new(0.35, 0, 0.1, 0)
	skipButton.Position = UDim2.new(0.55, 0, 0.85, 0)
	skipButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	skipButton.Text = "Skip"
	skipButton.TextColor3 = Color3.new(1, 1, 1)
	skipButton.TextScaled = true
	skipButton.Font = Enum.Font.GothamBold
	skipButton.Parent = resultFrame
end

-- State
local isRolling = false
local autoRollEnabled = false
local fastRollEnabled = false
local currentResult = nil

-- Roll button click
rollButton.MouseButton1Click:Connect(function()
	if isRolling then return end

	isRolling = true
	rollButton.Text = "Rolling..."

	-- Fire to server
	rollBrainrotEvent:FireServer()
end)

-- Auto roll toggle
autoRollButton.MouseButton1Click:Connect(function()
	autoRollEnabled = not autoRollEnabled
	autoRollButton.BackgroundColor3 = autoRollEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)

	-- Notify server
	local toggleEvent = events:FindFirstChild("ToggleAutoRoll")
	if toggleEvent then
		toggleEvent:FireServer(autoRollEnabled)
	end

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
	fastRollButton.BackgroundColor3 = fastRollEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)

	-- Notify server
	local toggleEvent = events:FindFirstChild("ToggleFastRoll")
	if toggleEvent then
		toggleEvent:FireServer(fastRollEnabled)
	end
end)

-- Handle roll result
rollResultEvent.OnClientEvent:Connect(function(result)
	currentResult = result

	if fastRollEnabled then
		-- Show result instantly
		showResult(result)
	else
		-- Play animation
		playRollAnimation(result)
	end

	isRolling = false
	rollButton.Text = "Roll"
end)

-- Play roll animation
function playRollAnimation(result)
	-- Simple flicker animation
	local imageLabel = resultFrame.BrainrotImage

	-- Flicker through random brainrots
	for i = 1, 15 do
		local randomBrainrot = brainrotData.Brainrots[math.random(1, #brainrotData.Brainrots)]
		imageLabel.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Black placeholder
		task.wait(0.2)
	end

	-- Show final result
	showResult(result)
end

-- Show result
function showResult(result)
	local imageLabel = resultFrame.BrainrotImage
	local nameLabel = resultFrame.NameLabel
	local rarityLabel = resultFrame.RarityLabel

	-- Update UI
	imageLabel.Image = result.ImageId
	nameLabel.Text = result.DisplayName
	rarityLabel.Text = result.Rarity .. " - " .. result.Frame
	rarityLabel.TextColor3 = result.Color

	-- Show frame
	resultFrame.Visible = true
end

-- Keep button
resultFrame.KeepButton.MouseButton1Click:Connect(function()
	if not currentResult then return end

	-- Send to server
	keepBrainrotEvent:FireServer(currentResult.BrainrotID, currentResult.Frame)

	-- Hide result
	resultFrame.Visible = false
	currentResult = nil
end)

-- Skip button
resultFrame.SkipButton.MouseButton1Click:Connect(function()
	if not currentResult then return end

	-- Send to server
	skipBrainrotEvent:FireServer()

	-- Hide result
	resultFrame.Visible = false
	currentResult = nil
end)

print("✓ RollHandler loaded")
