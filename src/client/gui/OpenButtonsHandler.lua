--[[
	OpenButtonsHandler.lua
	Handles open/close buttons for main UI frames
	SIMPLE, CLEAN, OPTIMIZED

	Place in: StarterGui.neww.OpenButtonsHandler (LocalScript)
]]

local gui = script.Parent -- neww ScreenGui

-- Get buttons
local openIndexButton = gui:WaitForChild("OpenIndex")
local openRebirthsButton = gui:WaitForChild("OpenRebirths")
local openStoreButton = gui:WaitForChild("OpenStore")

-- Get frames
local indexFrame = gui:WaitForChild("Index")
local rebirthFrame = gui:WaitForChild("Rebirth")
local cashStoreFrame = gui:WaitForChild("CashStore")

-- Open Index
openIndexButton.MouseButton1Click:Connect(function()
	indexFrame.Visible = not indexFrame.Visible
end)

-- Open Rebirth
openRebirthsButton.MouseButton1Click:Connect(function()
	rebirthFrame.Visible = not rebirthFrame.Visible
end)

-- Open Store
openStoreButton.MouseButton1Click:Connect(function()
	cashStoreFrame.Visible = not cashStoreFrame.Visible
end)

print("✓ OpenButtonsHandler loaded")
