--[[
    Inventory Number Key Handler (Client-Side)
    Syncs number key presses with visual inventory slots
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Wait for the inventory UI to be created
task.wait(1)

local inventoryUI = PlayerGui:WaitForChild("InventoryStatsUI", 10)
if not inventoryUI then
    warn("[InventoryKeyHandler] InventoryStatsUI not found!")
    return
end

local hotbarFrame = inventoryUI:WaitForChild("HotbarInventory", 5)
if not hotbarFrame then
    warn("[InventoryKeyHandler] HotbarInventory not found!")
    return
end

local slotsContainer = hotbarFrame:WaitForChild("Slots", 5)
if not slotsContainer then
    warn("[InventoryKeyHandler] Slots container not found!")
    return
end

-- Track currently selected slot for visual feedback
local selectedSlot = nil

-- Function to update visual selection
local function updateSlotSelection(slotNumber)
    -- Clear all slot indicators
    for i = 1, 3 do
        local slot = slotsContainer:FindFirstChild("Slot" .. i)
        if slot then
            local indicator = slot:FindFirstChild("EquippedIndicator")
            if indicator then
                indicator.Visible = (i == slotNumber)
            end
        end
    end

    selectedSlot = slotNumber
end

-- Listen for number key presses
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local keyCode = input.KeyCode
    local slotNumber = nil

    if keyCode == Enum.KeyCode.One then
        slotNumber = 1
    elseif keyCode == Enum.KeyCode.Two then
        slotNumber = 2
    elseif keyCode == Enum.KeyCode.Three then
        slotNumber = 3
    end

    if slotNumber then
        -- Check if slot has food
        local slot = slotsContainer:FindFirstChild("Slot" .. slotNumber)
        if slot then
            local itemName = slot:FindFirstChild("ItemName")
            if itemName and itemName.Text ~= "Empty" then
                -- Toggle selection
                if selectedSlot == slotNumber then
                    updateSlotSelection(nil)
                else
                    updateSlotSelection(slotNumber)
                end
            end
        end
    end
end)

print("[InventoryKeyHandler] Number key handler initialized! Press 1, 2, 3 to select slots")
