--[[
	IndexHandler.lua
	Handles index display UI
	SIMPLE, CLEAN, OPTIMIZED

	Place in: StarterGui.neww.Index.IndexHandler (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local indexFrame = script.Parent -- Index frame

-- Get modules
local brainrotData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotData"))
local brainrotImageGen = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BrainrotImageGenerator"))

-- Get RemoteFunction
local events = ReplicatedStorage:WaitForChild("Events")
local getIndexData = events:WaitForChild("GetIndexData")

-- UI elements
local scrollingFrame = indexFrame:WaitForChild("ScrollingFrame")
local closeButton = indexFrame:WaitForChild("Close")

-- Get or create template
local template = scrollingFrame:FindFirstChild("Template")
if not template then
	-- Create template if it doesn't exist
	template = Instance.new("Frame")
	template.Name = "Template"
	template.Size = UDim2.new(0.3, -5, 0.3, -5)
	template.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	template.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = template

	local characterImage = Instance.new("ImageLabel")
	characterImage.Name = "Character"
	characterImage.Size = UDim2.new(0.9, 0, 0.6, 0)
	characterImage.Position = UDim2.new(0.05, 0, 0.05, 0)
	characterImage.BackgroundTransparency = 1
	characterImage.ScaleType = Enum.ScaleType.Fit
	characterImage.Parent = template

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
	nameLabel.Position = UDim2.new(0.05, 0, 0.68, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = template

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "Rarity"
	rarityLabel.Size = UDim2.new(0.9, 0, 0.12, 0)
	rarityLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.TextColor3 = Color3.new(1, 1, 1)
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.Gotham
	rarityLabel.Parent = template

	template.Parent = scrollingFrame
	print("✓ Created Index Template")
end

-- Hide template
template.Visible = false

-- Current filter
local currentFrame = "Normal"

-- Create frame filter buttons (if not exists)
local normalButton = indexFrame:FindFirstChild("NormalButton")
local goldButton = indexFrame:FindFirstChild("GoldButton")
local diamondButton = indexFrame:FindFirstChild("DiamondButton")

if not normalButton then
	-- Create filter buttons
	normalButton = Instance.new("TextButton")
	normalButton.Name = "NormalButton"
	normalButton.Size = UDim2.new(0.2, 0, 0.05, 0)
	normalButton.Position = UDim2.new(0.05, 0, 0.1, 0)
	normalButton.Text = "Normal"
	normalButton.Parent = indexFrame

	goldButton = Instance.new("TextButton")
	goldButton.Name = "GoldButton"
	goldButton.Size = UDim2.new(0.2, 0, 0.05, 0)
	goldButton.Position = UDim2.new(0.27, 0, 0.1, 0)
	goldButton.Text = "Gold"
	goldButton.Parent = indexFrame

	diamondButton = Instance.new("TextButton")
	diamondButton.Name = "DiamondButton"
	diamondButton.Size = UDim2.new(0.2, 0, 0.05, 0)
	diamondButton.Position = UDim2.new(0.49, 0, 0.1, 0)
	diamondButton.Text = "Diamond"
	diamondButton.Parent = indexFrame
end

-- Load index
function loadIndex()
	-- Clear existing entries
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") and child ~= template then
			child:Destroy()
		end
	end

	-- Get player's index
	local indexData = getIndexData:InvokeServer()

	-- Sort brainrots by rarity
	local sortedBrainrots = {}
	for _, rarity in ipairs(brainrotData.Rarities) do
		for _, brainrot in ipairs(brainrotData.Brainrots) do
			if brainrot.Rarity == rarity then
				table.insert(sortedBrainrots, brainrot)
			end
		end
	end

	-- Create entries
	for _, brainrot in ipairs(sortedBrainrots) do
		local key = brainrot.ID .. "_" .. currentFrame
		local isUnlocked = indexData[key] == true

		-- Clone template
		local entry = template:Clone()
		entry.Name = key
		entry.Visible = true

		-- Get elements
		local characterImage = entry:FindFirstChild("Character")
		local nameLabel = entry:FindFirstChild("Name")
		local rarityLabel = entry:FindFirstChild("Rarity")

		-- Update
		if isUnlocked then
			-- Create viewport to display the 3D model
			local viewport = brainrotImageGen.SetupViewportInImage(characterImage, brainrot.ID)
			if not viewport then
				-- Fallback to static image if viewport fails
				characterImage.Image = brainrot.ImageId
				print("⚠️ Index: Viewport creation failed for", brainrot.ID, "- using static image")
			end

			nameLabel.Text = brainrot.DisplayName
			rarityLabel.Text = brainrot.Rarity
			rarityLabel.TextColor3 = brainrotData.RarityColors[brainrot.Rarity]
		else
			-- Locked - show placeholder
			characterImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
			characterImage.ImageColor3 = Color3.new(0, 0, 0)
			nameLabel.Text = "???"
			rarityLabel.Text = brainrot.Rarity
			rarityLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
		end

		entry.Parent = scrollingFrame
	end

	print("Index loaded with", #sortedBrainrots, "entries for frame:", currentFrame)
end

-- Filter buttons
normalButton.MouseButton1Click:Connect(function()
	currentFrame = "Normal"
	loadIndex()
end)

goldButton.MouseButton1Click:Connect(function()
	currentFrame = "Gold"
	loadIndex()
end)

diamondButton.MouseButton1Click:Connect(function()
	currentFrame = "Diamond"
	loadIndex()
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
	indexFrame.Visible = false
end)

-- Load on open
indexFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if indexFrame.Visible then
		loadIndex()
	end
end)

print("✓ IndexHandler loaded")
