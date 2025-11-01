--[[
	LOBBY PADS CREATOR UTILITY
	Run this script once in Roblox Studio Command Bar to create the lobby pads

	Usage:
	1. Open Roblox Studio
	2. Open the Command Bar (View -> Command Bar)
	3. Copy and paste this entire script into the Command Bar
	4. Press Enter to run it

	This will create 3 pads in the Workspace:
	- SoloPad (Blue)
	- DuoPad (Green)
	- SquadPad (Orange)
]]

local function createLobbyPads()
	local workspace = game:GetService("Workspace")

	-- Create lobby folder
	local lobby = workspace:FindFirstChild("Lobby")
	if not lobby then
		lobby = Instance.new("Folder")
		lobby.Name = "Lobby"
		lobby.Parent = workspace
	end

	-- Pad configurations
	local pads = {
		{
			Name = "SoloPad",
			Color = Color3.fromRGB(0, 170, 255), -- Blue
			Position = Vector3.new(0, 1, 0),
			Text = "SOLO\n[1 PLAYER]"
		},
		{
			Name = "DuoPad",
			Color = Color3.fromRGB(0, 255, 0), -- Green
			Position = Vector3.new(15, 1, 0),
			Text = "DUO\n[2 PLAYERS]"
		},
		{
			Name = "SquadPad",
			Color = Color3.fromRGB(255, 170, 0), -- Orange
			Position = Vector3.new(30, 1, 0),
			Text = "SQUAD\n[4 PLAYERS]"
		}
	}

	-- Create each pad
	for _, padConfig in ipairs(pads) do
		-- Delete existing pad if it exists
		local existingPad = lobby:FindFirstChild(padConfig.Name)
		if existingPad then
			existingPad:Destroy()
		end

		-- Create pad
		local pad = Instance.new("Part")
		pad.Name = padConfig.Name
		pad.Size = Vector3.new(10, 1, 10)
		pad.Position = padConfig.Position
		pad.Anchored = true
		pad.CanCollide = true
		pad.Material = Enum.Material.Neon
		pad.Color = padConfig.Color
		pad.Parent = lobby

		-- Create text billboard
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "PadLabel"
		billboard.Size = UDim2.new(0, 200, 0, 100)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = pad

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = padConfig.Text
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextSize = 24
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextStrokeTransparency = 0.5
		textLabel.Parent = billboard

		print("Created " .. padConfig.Name)
	end

	print("✓ All lobby pads created successfully!")
	print("→ Pads are located in Workspace > Lobby")
end

-- Run the function
createLobbyPads()
