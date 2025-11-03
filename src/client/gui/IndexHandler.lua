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
local brainrotData = require(ReplicatedStorage.Modules.BrainrotData)

-- Get RemoteFunction
local events = ReplicatedStorage:WaitForChild("Events")
local getIndexData = events:WaitForChild("GetIndexData")

-- UI elements
local scrollingFrame = indexFrame:WaitForChild("ScrollingFrame")
local template = scrollingFrame:WaitForChild("Template")
local closeButton = indexFrame:WaitForChild("Close")

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
			characterImage.Image = brainrot.ImageId
			nameLabel.Text = brainrot.DisplayName
			rarityLabel.Text = brainrot.Rarity
			rarityLabel.TextColor3 = brainrotData.RarityColors[brainrot.Rarity]
		else
			characterImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Black
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
