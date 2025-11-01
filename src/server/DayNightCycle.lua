--[[
    Day/Night Cycle System
    Manages game time progression and triggers day/night events
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local DayNightCycle = {}
DayNightCycle.__index = DayNightCycle

-- Configuration
local DAY_LENGTH = 300      -- 5 minutes (300 seconds)
local NIGHT_LENGTH = 180    -- 3 minutes (180 seconds)

function DayNightCycle.new()
    local self = setmetatable({}, DayNightCycle)

    self.IsDay = true
    self.TimeRemaining = DAY_LENGTH
    self.TotalCycleTime = 0
    self.Listeners = {
        OnDayStart = {},
        OnNightStart = {},
        OnTimeUpdate = {}
    }

    -- Create or get Remote Events folder
    local eventsFolder = ReplicatedStorage:FindFirstChild("GameStateEvents")
    if not eventsFolder then
        eventsFolder = Instance.new("Folder")
        eventsFolder.Name = "GameStateEvents"
        eventsFolder.Parent = ReplicatedStorage
    end

    -- Create Remote Events
    self.DayNightEvent = eventsFolder:FindFirstChild("DayNightTransition")
    if not self.DayNightEvent then
        self.DayNightEvent = Instance.new("RemoteEvent")
        self.DayNightEvent.Name = "DayNightTransition"
        self.DayNightEvent.Parent = eventsFolder
    end

    self.TimeUpdateEvent = eventsFolder:FindFirstChild("TimeUpdate")
    if not self.TimeUpdateEvent then
        self.TimeUpdateEvent = Instance.new("RemoteEvent")
        self.TimeUpdateEvent.Name = "TimeUpdate"
        self.TimeUpdateEvent.Parent = eventsFolder
    end

    return self
end

-- Register callback for day start
function DayNightCycle:OnDayStart(callback)
    table.insert(self.Listeners.OnDayStart, callback)
end

-- Register callback for night start
function DayNightCycle:OnNightStart(callback)
    table.insert(self.Listeners.OnNightStart, callback)
end

-- Register callback for time updates
function DayNightCycle:OnTimeUpdate(callback)
    table.insert(self.Listeners.OnTimeUpdate, callback)
end

-- Fire all registered callbacks for an event
function DayNightCycle:FireEvent(eventName)
    for _, callback in ipairs(self.Listeners[eventName] or {}) do
        task.spawn(callback)
    end
end

-- Transition to day
function DayNightCycle:StartDay()
    self.IsDay = true
    self.TimeRemaining = DAY_LENGTH

    -- Update lighting
    Lighting.ClockTime = 12  -- Noon
    Lighting.Brightness = 2
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

    -- Notify all clients
    self.DayNightEvent:FireAllClients(true, DAY_LENGTH)

    -- Fire callbacks
    self:FireEvent("OnDayStart")

    print("[DayNightCycle] Day has started! Duration:", DAY_LENGTH, "seconds")
end

-- Transition to night
function DayNightCycle:StartNight()
    self.IsDay = false
    self.TimeRemaining = NIGHT_LENGTH

    -- Update lighting
    Lighting.ClockTime = 0  -- Midnight
    Lighting.Brightness = 0.5
    Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 75)

    -- Notify all clients
    self.DayNightEvent:FireAllClients(false, NIGHT_LENGTH)

    -- Fire callbacks
    self:FireEvent("OnNightStart")

    print("[DayNightCycle] Night has started! Duration:", NIGHT_LENGTH, "seconds")
end

-- Update cycle (called every frame)
function DayNightCycle:Update(deltaTime)
    self.TimeRemaining = self.TimeRemaining - deltaTime
    self.TotalCycleTime = self.TotalCycleTime + deltaTime

    -- Send time updates every second
    if math.floor(self.TotalCycleTime) > math.floor(self.TotalCycleTime - deltaTime) then
        self.TimeUpdateEvent:FireAllClients(self.IsDay, math.max(0, math.floor(self.TimeRemaining)))
        self:FireEvent("OnTimeUpdate")
    end

    -- Check for cycle transition
    if self.TimeRemaining <= 0 then
        if self.IsDay then
            self:StartNight()
        else
            self:StartDay()
        end
    end
end

-- Start the cycle system
function DayNightCycle:Start()
    -- Begin with day
    self:StartDay()

    -- Update loop
    RunService.Heartbeat:Connect(function(deltaTime)
        self:Update(deltaTime)
    end)

    print("[DayNightCycle] System started!")
end

-- Get current state
function DayNightCycle:GetState()
    return {
        IsDay = self.IsDay,
        TimeRemaining = self.TimeRemaining
    }
end

return DayNightCycle
