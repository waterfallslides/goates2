--[[
    Inventory Tool System (Client-Side)
    Manages Tools for Roblox-style inventory with number keys and click to use
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Wait for Remote Events
local eventsFolder = ReplicatedStorage:WaitForChild("GameStateEvents", 10)
if not eventsFolder then
    warn("[InventoryToolSystem] GameStateEvents folder not found!")
    return
end

local InventoryUpdateEvent = eventsFolder:WaitForChild("InventoryUpdate", 5)
local ConsumeFoodFunction = ReplicatedStorage:WaitForChild("ConsumeFood", 10)

-- Get FoodConfig
local FoodConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FoodConfig"))

-- Track current inventory and equipped tool
local currentInventory = {}
local equippedSlot = nil
local inventoryTools = {}

-- Function to create a Tool for food
local function createFoodTool(foodType, slotNumber)
    local foodData = FoodConfig.FoodTypes[foodType]
    if not foodData then return nil end

    -- Create Tool
    local tool = Instance.new("Tool")
    tool.Name = foodData.DisplayName
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    -- Create Handle (what player holds)
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = foodData.Size * 0.5  -- Smaller for hand
    handle.Color = foodData.Color
    handle.CanCollide = false
    handle.Anchored = false
    handle.Parent = tool

    -- Add mesh if custom model exists
    local foodModelsFolder = ReplicatedStorage:FindFirstChild("FoodModels")
    if foodModelsFolder then
        local customModel = foodModelsFolder:FindFirstChild(foodType)
        if customModel and customModel:IsA("BasePart") then
            -- Clone mesh from custom model
            local mesh = customModel:FindFirstChildOfClass("SpecialMesh") or customModel:FindFirstChildOfClass("Mesh")
            if mesh then
                mesh:Clone().Parent = handle
            end
            -- Copy texture
            handle.Color = customModel.Color
            if customModel:FindFirstChildOfClass("Texture") then
                customModel:FindFirstChildOfClass("Texture"):Clone().Parent = handle
            end
        end
    end

    -- Store metadata
    tool:SetAttribute("FoodType", foodType)
    tool:SetAttribute("SlotNumber", slotNumber)

    -- Handle activation (click to consume)
    tool.Activated:Connect(function()
        print("[InventoryToolSystem] Consuming", foodType)
        if ConsumeFoodFunction then
            pcall(function()
                ConsumeFoodFunction:InvokeServer(foodType)
            end)
        end
    end)

    return tool
end

-- Function to equip tool for slot
local function equipSlot(slotNumber)
    if slotNumber < 1 or slotNumber > 3 then return end

    local foodData = currentInventory[slotNumber]
    if not foodData then
        -- Empty slot, unequip
        if equippedSlot then
            local currentTool = inventoryTools[equippedSlot]
            if currentTool and currentTool.Parent == character then
                humanoid:UnequipTools()
            end
            equippedSlot = nil
        end
        return
    end

    -- If already equipped, unequip
    if equippedSlot == slotNumber then
        local currentTool = inventoryTools[slotNumber]
        if currentTool and currentTool.Parent == character then
            humanoid:UnequipTools()
        end
        equippedSlot = nil
        return
    end

    -- Unequip previous
    if equippedSlot then
        local oldTool = inventoryTools[equippedSlot]
        if oldTool and oldTool.Parent == character then
            humanoid:UnequipTools()
        end
    end

    -- Equip new tool
    local tool = inventoryTools[slotNumber]
    if tool and tool.Parent == player.Backpack then
        humanoid:EquipTool(tool)
        equippedSlot = slotNumber
    end
end

-- Update inventory tools based on server data
local function updateInventoryTools(inventoryData)
    if not inventoryData then return end

    -- Store current inventory
    currentInventory = {}

    -- Remove old tools
    for slot, tool in pairs(inventoryTools) do
        if tool then
            tool:Destroy()
        end
    end
    inventoryTools = {}

    -- Create new tools for each item
    for i, itemData in ipairs(inventoryData) do
        if i <= 3 then
            currentInventory[i] = itemData

            local tool = createFoodTool(itemData.FoodType, i)
            if tool then
                tool.Parent = player.Backpack
                inventoryTools[i] = tool
            end
        end
    end

    -- Re-equip if something was equipped
    if equippedSlot then
        local stillExists = currentInventory[equippedSlot] ~= nil
        if stillExists then
            -- Re-equip same slot
            task.wait(0.1)
            equipSlot(equippedSlot)
        else
            equippedSlot = nil
        end
    end
end

-- Handle number key inputs (1, 2, 3)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local keyCode = input.KeyCode
    if keyCode == Enum.KeyCode.One then
        equipSlot(1)
    elseif keyCode == Enum.KeyCode.Two then
        equipSlot(2)
    elseif keyCode == Enum.KeyCode.Three then
        equipSlot(3)
    end
end)

-- Listen for inventory updates
if InventoryUpdateEvent then
    InventoryUpdateEvent.OnClientEvent:Connect(updateInventoryTools)
end

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    equippedSlot = nil

    -- Re-create tools in backpack
    task.wait(1)
    if #currentInventory > 0 then
        updateInventoryTools(currentInventory)
    end
end)

print("[InventoryToolSystem] Roblox-style inventory system initialized!")
print("[InventoryToolSystem] Press 1, 2, 3 to equip food. Click to consume!")
