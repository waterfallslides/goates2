--[[
	RollingScript.lua
	THE ONLY SCRIPT YOU NEED - Connects YOUR existing DiceFrame and RollingFrame
	CREATES ZERO GUI ELEMENTS - Only connects to YOUR existing GUI

	🔧 Installation:
	   Place in: StarterGui/neww/DiceFrame/ as LocalScript

	📋 Requirements:
	   YOUR GUI must have:
	   - DiceFrame/ with Roll, AutoRoll (optional), FastRoll (optional) buttons
	   - RollingFrame/ with BrainrotImage, Keep, Rarity, Rolling, Name elements
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ==================== FIND ELEMENTS ====================

print("🔧 Starting RollingScript...")

-- Helper function: Find element or show clear error
local function findOrWarn(parent, name, elementType, required)
	local element = parent:FindFirstChild(name)
	if element then
		print("  ✓", name, "found:", element.ClassName)
		return element
	else
		if required then
			warn("  ❌", name, "not found in", parent.Name, "! Available children:")
			for _, child in ipairs(parent:GetChildren()) do
				print("      -", child.Name, "(" .. child.ClassName .. ")")
			end
			error("Missing required element: " .. name)
		else
			warn("  ⚠️", name, "not found (optional) - skipping")
			return nil
		end
	end
end

-- Get events with timeout
local events = ReplicatedStorage:WaitForChild("Events", 5)
if not events then
	error("❌ Events folder not found in ReplicatedStorage! Is the server running?")
end

local rollBrainrotEvent = events:WaitForChild("RollBrainrot", 5)
local rollResultEvent = events:WaitForChild("RollResult", 5)
local keepBrainrotEvent = events:WaitForChild("KeepBrainrot", 5)
local toggleAutoRoll = events:FindFirstChild("ToggleAutoRoll")
local toggleFastRoll = events:FindFirstChild("ToggleFastRoll")

if not (rollBrainrotEvent and rollResultEvent and keepBrainrotEvent) then
	error("❌ Required events not found! Is MainServer running?")
end

print("  ✓ Events found")

-- Get modules
local brainrotData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotData"))
local brainrotImageGen = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotImageGenerator"))
print("  ✓ Modules loaded")

-- Find YOUR DiceFrame (this script is IN DiceFrame)
local diceFrame = script.Parent
print("📦 DiceFrame:", diceFrame.Name)

local rollButton = findOrWarn(diceFrame, "Roll", "TextButton", true)
local autoRollButton = findOrWarn(diceFrame, "AutoRoll", "TextButton", false)
local fastRollButton = findOrWarn(diceFrame, "FastRoll", "TextButton", false)

-- Find YOUR RollingFrame (sibling of DiceFrame)
local gui = diceFrame.Parent -- neww
print("📦 GUI:", gui.Name)

local rollingFrame = findOrWarn(gui, "RollingFrame", "Frame", true)
local brainrotImage = findOrWarn(rollingFrame, "BrainrotImage", "ImageLabel", true)
local keepButton = findOrWarn(rollingFrame, "Keep", nil, true)  -- Can be ImageButton or TextButton
local rarityLabel = findOrWarn(rollingFrame, "Rarity", "TextLabel", true)
local rollingLabel = findOrWarn(rollingFrame, "Rolling", nil, false)  -- Optional, can be any type (also acts as Roll button in RollingFrame)
local nameLabel = findOrWarn(rollingFrame, "Name", "TextLabel", true)

print("✅ All required elements found! Setting up connections...")

-- ==================== STATE ====================

local isRolling = false
local autoRollEnabled = false
local fastRollEnabled = false
local currentResult = nil

-- ==================== HELPER FUNCTIONS ====================

-- Safely set text only if element supports it
local function safeSetText(element, text)
	if element and (element:IsA("TextLabel") or element:IsA("TextButton")) then
		element.Text = text
	elseif element then
		-- Element exists but doesn't support Text (like ImageButton)
		-- Just skip it silently
		print("  ℹ️ Skipping text set on", element.Name, "(not a text element)")
	end
end

-- ==================== UI MANAGEMENT ====================

-- Initialize - hide elements that appear after roll
local function initializeUI()
	-- Hide RollingFrame initially
	rollingFrame.Visible = false

	-- Hide Keep button initially (only show after roll completes)
	keepButton.Visible = false

	-- Show Rolling button initially (for starting rolls from RollingFrame)
	if rollingLabel then
		rollingLabel.Visible = true
	end

	-- Clear all labels and viewports
	safeSetText(rollingLabel, "")
	nameLabel.Text = ""
	rarityLabel.Text = ""
	brainrotImage.Image = ""

	-- Remove any existing viewports
	for _, child in ipairs(brainrotImage:GetChildren()) do
		if child:IsA("ViewportFrame") then
			child:Destroy()
		end
	end

	print("🎨 UI initialized - RollingFrame hidden, ready to roll!")
end

-- Show RollingFrame and start rolling
local function startRolling()
	-- Show RollingFrame
	rollingFrame.Visible = true

	-- Hide Keep button during roll (only show after success)
	keepButton.Visible = false

	-- Show "ROLLING..." text and make Rolling button visible during animation
	if rollingLabel then
		rollingLabel.Visible = true
		safeSetText(rollingLabel, "ROLLING...")
	end
	nameLabel.Text = ""
	rarityLabel.Text = "???"

	print("▶ RollingFrame shown, rolling started...")
end

-- Hide RollingFrame (after keeping)
local function hideRollingFrame()
	rollingFrame.Visible = false
	keepButton.Visible = false

	-- Clear viewport and image
	brainrotImage.Image = ""
	for _, child in ipairs(brainrotImage:GetChildren()) do
		if child:IsA("ViewportFrame") then
			child:Destroy()
		end
	end

	safeSetText(rollingLabel, "")
	nameLabel.Text = ""
	rarityLabel.Text = ""

	print("◼ RollingFrame hidden, ready for next roll")
end

-- ==================== ANIMATIONS ====================

-- Simple button bounce animation
local function buttonBounce(button)
	if not button then return end

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
	-- Create viewport to display the 3D model
	local viewport = brainrotImageGen.SetupViewportInImage(brainrotImage, result.BrainrotID)

	if not viewport then
		-- Fallback to static image if viewport fails
		brainrotImage.Image = result.ImageId
		brainrotImage.ImageColor3 = Color3.new(1, 1, 1)
		print("⚠️ Viewport creation failed, using static image")
	else
		print("✓ Viewport created for:", result.BrainrotID)
	end

	-- Hide "Rolling" button when roll finishes
	if rollingLabel then
		rollingLabel.Visible = false
	end

	-- Update labels
	nameLabel.Text = result.DisplayName
	rarityLabel.Text = result.Rarity .. " - " .. result.Frame
	rarityLabel.TextColor3 = result.Color

	-- Pop animation
	brainrotImage.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(brainrotImage, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()

	-- NOW show Keep button (only after successful roll)
	keepButton.Visible = true

	print("✨ Result shown:", result.DisplayName, "-", result.Rarity)
end

-- ==================== BUTTON HANDLERS ====================

-- Roll button clicked
rollButton.MouseButton1Click:Connect(function()
	if isRolling then
		print("⚠️ Already rolling, please wait...")
		return
	end

	print("▶ Roll button clicked")
	isRolling = true
	buttonBounce(rollButton)

	-- Show RollingFrame and start animation
	startRolling()

	-- Tell server to roll
	rollBrainrotEvent:FireServer()
end)

-- Keep button clicked
keepButton.MouseButton1Click:Connect(function()
	if not currentResult then
		print("⚠️ No result to keep")
		return
	end

	print("▶ Keep button clicked")
	buttonBounce(keepButton)

	-- Tell server to keep
	keepBrainrotEvent:FireServer(currentResult.BrainrotID, currentResult.Frame)

	-- Hide RollingFrame
	hideRollingFrame()

	-- Reset
	currentResult = nil
	isRolling = false
end)

-- Rolling button (in RollingFrame) clicked - starts a new roll
if rollingLabel and rollingLabel:IsA("ImageButton") or rollingLabel and rollingLabel:IsA("TextButton") then
	rollingLabel.MouseButton1Click:Connect(function()
		if isRolling then
			print("⚠️ Already rolling, please wait...")
			return
		end

		print("▶ Rolling button (RollingFrame) clicked - starting new roll")
		isRolling = true
		buttonBounce(rollingLabel)

		-- Show RollingFrame and start animation
		startRolling()

		-- Tell server to roll
		rollBrainrotEvent:FireServer()
	end)
end

-- AutoRoll button (if you have it)
if autoRollButton and toggleAutoRoll then
	autoRollButton.MouseButton1Click:Connect(function()
		autoRollEnabled = not autoRollEnabled
		buttonBounce(autoRollButton)

		print("▶ AutoRoll toggled:", autoRollEnabled)

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
						print("▶ AutoRoll triggered")
						isRolling = true
						startRolling()
						rollBrainrotEvent:FireServer()
					end
				end
			end)
		end
	end)
else
	if not autoRollButton then
		print("  ℹ️ AutoRoll button not found - feature disabled")
	end
end

-- FastRoll button (if you have it)
if fastRollButton and toggleFastRoll then
	fastRollButton.MouseButton1Click:Connect(function()
		fastRollEnabled = not fastRollEnabled
		buttonBounce(fastRollButton)

		print("▶ FastRoll toggled:", fastRollEnabled)

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
	if not fastRollButton then
		print("  ℹ️ FastRoll button not found - feature disabled")
	end
end

-- ==================== SERVER EVENTS ====================

-- Server sent a roll result
rollResultEvent.OnClientEvent:Connect(function(result)
	print("▶ Received result:", result.DisplayName)
	currentResult = result

	-- Play flicker if not fast roll
	if not fastRollEnabled then
		flickerAnimation()
	end

	-- Show result
	showResult(result)

	isRolling = false
end)

-- ==================== INITIALIZATION ====================

-- Initialize UI on load
initializeUI()

print("✅ RollingScript fully connected and ready!")
print("   Click Roll to test!")
