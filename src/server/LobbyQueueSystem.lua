--[[
	LOBBY QUEUE SYSTEM
	Server-side script for managing Solo/Duo/Squad lobby queues

	Features:
	- 3 touchable pads (Solo/Duo/Squad)
	- 20-second countdown timer
	- Automatic teleportation when countdown ends
	- Player caps: Solo = 1, Duo = 2, Squad = 4
	- Teleports even if not enough players
]]

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local GAME_PLACE_ID = game.PlaceId -- Change this to your target game place ID if different
local COUNTDOWN_TIME = 20

local QueueConfig = {
	Solo = {
		MaxPlayers = 1,
		PadName = "SoloPad",
		Color = Color3.fromRGB(0, 170, 255) -- Blue
	},
	Duo = {
		MaxPlayers = 2,
		PadName = "DuoPad",
		Color = Color3.fromRGB(0, 255, 0) -- Green
	},
	Squad = {
		MaxPlayers = 4,
		PadName = "SquadPad",
		Color = Color3.fromRGB(255, 170, 0) -- Orange
	}
}

-- Queue storage
local Queues = {
	Solo = {},
	Duo = {},
	Squad = {}
}

local ActiveCountdowns = {
	Solo = false,
	Duo = false,
	Squad = false
}

local PlayersInQueue = {} -- Tracks which queue each player is in
local PlayerDebounce = {} -- Debounce table to prevent spam
local PlayerTouchingPad = {} -- Tracks if player is currently on a pad
local LeaveTimers = {} -- Timers for delayed queue leaving
local PadCounters = {} -- Store billboard GUI references for each pad

-- Remote events for client communication
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "LobbyQueueEvents"
RemoteEvents.Parent = ReplicatedStorage

local CountdownEvent = Instance.new("RemoteEvent")
CountdownEvent.Name = "CountdownUpdate"
CountdownEvent.Parent = RemoteEvents

local QueueJoinEvent = Instance.new("RemoteEvent")
QueueJoinEvent.Name = "QueueJoin"
QueueJoinEvent.Parent = RemoteEvents

local QueueLeaveEvent = Instance.new("RemoteEvent")
QueueLeaveEvent.Name = "QueueLeave"
QueueLeaveEvent.Parent = RemoteEvents

-- Function to update pad counter display
local function updatePadCounter(queueType)
	local counter = PadCounters[queueType]
	if counter then
		local currentPlayers = #Queues[queueType]
		local maxPlayers = QueueConfig[queueType].MaxPlayers
		counter.Text = currentPlayers .. "/" .. maxPlayers .. " PLAYERS"
	end
end

-- Helper function to remove player from all queues
local function removePlayerFromQueues(player, notifyClient)
	if notifyClient == nil then notifyClient = true end

	for queueType, queue in pairs(Queues) do
		for i, queuedPlayer in ipairs(queue) do
			if queuedPlayer == player then
				table.remove(queue, i)
				print("[Queue] Removed " .. player.Name .. " from " .. queueType .. " queue")

				-- Notify client to hide GUI
				if notifyClient then
					QueueLeaveEvent:FireClient(player)
				end

				-- Update pad counter after removing player
				updatePadCounter(queueType)
				break
			end
		end
	end
	PlayersInQueue[player] = nil
end

-- Helper function to add player to queue
local function addPlayerToQueue(player, queueType)
	-- Remove from other queues first
	removePlayerFromQueues(player)

	-- Check if queue is full
	if #Queues[queueType] >= QueueConfig[queueType].MaxPlayers then
		print("[Queue] " .. queueType .. " queue is full!")
		return false
	end

	-- Add to queue
	table.insert(Queues[queueType], player)
	PlayersInQueue[player] = queueType
	print("[Queue] Added " .. player.Name .. " to " .. queueType .. " queue (" .. #Queues[queueType] .. "/" .. QueueConfig[queueType].MaxPlayers .. ")")

	-- Notify player they joined queue
	QueueJoinEvent:FireClient(player, queueType, #Queues[queueType], QueueConfig[queueType].MaxPlayers)

	-- Update pad counter
	updatePadCounter(queueType)

	return true
end

-- Countdown function
local function startCountdown(queueType)
	if ActiveCountdowns[queueType] then
		print("[Queue] Countdown already active for " .. queueType)
		return
	end

	ActiveCountdowns[queueType] = true
	print("[Queue] Starting countdown for " .. queueType .. " queue")

	local queue = Queues[queueType]

	-- Start countdown
	for i = COUNTDOWN_TIME, 0, -1 do
		-- Notify all players in queue of countdown
		for _, player in ipairs(queue) do
			if player and player.Parent then
				CountdownEvent:FireClient(player, i, queueType)
			end
		end

		task.wait(1)

		-- Check if queue is empty (all players left)
		if #queue == 0 then
			print("[Queue] All players left " .. queueType .. " queue, cancelling countdown")
			ActiveCountdowns[queueType] = false
			return
		end
	end

	-- Countdown finished, teleport players
	print("[Queue] Countdown finished for " .. queueType .. ", teleporting " .. #queue .. " players")

	-- Clean up players list (remove any who left)
	local playersToTeleport = {}
	for i = #queue, 1, -1 do
		if queue[i] and queue[i].Parent then
			table.insert(playersToTeleport, queue[i])
		else
			table.remove(queue, i)
		end
	end

	-- Teleport players
	if #playersToTeleport > 0 then
		local success, errorMessage = pcall(function()
			-- Create teleport options
			local teleportOptions = Instance.new("TeleportOptions")
			teleportOptions.ShouldReserveServer = true

			-- Attempt teleport
			local code = TeleportService:TeleportAsync(GAME_PLACE_ID, playersToTeleport, teleportOptions)
			print("[Queue] Successfully teleported " .. #playersToTeleport .. " players from " .. queueType .. " queue (Code: " .. tostring(code) .. ")")
		end)

		if not success then
			warn("[Queue] Failed to teleport players: " .. tostring(errorMessage))
		end
	end

	-- Clear queue and reset countdown
	Queues[queueType] = {}
	ActiveCountdowns[queueType] = false

	-- Clear player tracking
	for _, player in ipairs(playersToTeleport) do
		PlayersInQueue[player] = nil
	end

	-- Update pad counter to show 0 players
	updatePadCounter(queueType)
end

-- Setup touch detection for a pad
local function setupPad(pad, queueType)
	if not pad then
		warn("[Queue] Pad not found: " .. QueueConfig[queueType].PadName)
		return
	end

	-- Set pad color
	pad.BrickColor = BrickColor.new(QueueConfig[queueType].Color)
	pad.Material = Enum.Material.Neon

	-- Create player counter billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerCounter"
	billboard.Size = UDim2.new(0, 200, 0, 80)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = pad

	local counterLabel = Instance.new("TextLabel")
	counterLabel.Name = "CounterLabel"
	counterLabel.Size = UDim2.new(1, 0, 1, 0)
	counterLabel.BackgroundTransparency = 1
	counterLabel.Text = "0/" .. QueueConfig[queueType].MaxPlayers .. " PLAYERS"
	counterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	counterLabel.TextSize = 32
	counterLabel.Font = Enum.Font.FredokaOne
	counterLabel.Parent = billboard

	-- Add text stroke for better visibility
	local counterStroke = Instance.new("UIStroke")
	counterStroke.Color = Color3.fromRGB(0, 0, 0)
	counterStroke.Thickness = 4
	counterStroke.Parent = counterLabel

	-- Store reference to counter
	PadCounters[queueType] = counterLabel

	-- Store players currently on this pad
	local playersOnPad = {}

	-- Function to check if player is actually on pad
	local function isPlayerOnPad(player)
		local character = player.Character
		if not character then return false end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return false end

		-- Check if player's position is within pad bounds
		local padPos = pad.Position
		local padSize = pad.Size
		local playerPos = humanoidRootPart.Position

		local xDiff = math.abs(playerPos.X - padPos.X)
		local zDiff = math.abs(playerPos.Z - padPos.Z)
		local yDiff = playerPos.Y - padPos.Y

		return xDiff <= padSize.X / 2 and zDiff <= padSize.Z / 2 and yDiff >= 0 and yDiff <= 10
	end

	-- Create touch detection with debounce
	pad.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local player = Players:GetPlayerFromCharacter(character)
			if player then
				-- Mark player as on pad
				playersOnPad[player] = true

				-- Cancel any pending leave timer
				if LeaveTimers[player] then
					task.cancel(LeaveTimers[player])
					LeaveTimers[player] = nil
				end

				-- Only add to queue if not already in this queue
				if PlayersInQueue[player] ~= queueType then
					-- Debounce check
					if PlayerDebounce[player] then
						return
					end
					PlayerDebounce[player] = true

					-- Add player to queue
					local added = addPlayerToQueue(player, queueType)

					if added then
						-- Start countdown if this is the first player or queue is full
						if #Queues[queueType] == QueueConfig[queueType].MaxPlayers then
							if not ActiveCountdowns[queueType] then
								task.spawn(function()
									startCountdown(queueType)
								end)
							end
						elseif #Queues[queueType] == 1 then
							-- Start countdown even with one player
							if not ActiveCountdowns[queueType] then
								task.spawn(function()
									startCountdown(queueType)
								end)
							end
						end
					end

					-- Reset debounce after delay
					task.delay(2, function()
						PlayerDebounce[player] = nil
					end)
				end
			end
		end
	end)

	-- Continuously check if players are still on pad
	task.spawn(function()
		while true do
			task.wait(0.5) -- Check every half second

			for player, _ in pairs(playersOnPad) do
				if not isPlayerOnPad(player) then
					playersOnPad[player] = nil

					-- Only remove if in this queue
					if PlayersInQueue[player] == queueType then
						-- Remove immediately (no delay)
						removePlayerFromQueues(player, true)
					end
				end
			end
		end
	end)

	print("[Queue] Setup complete for " .. queueType .. " pad")
end

-- Wait for workspace to load
task.wait(2)

-- Setup all pads
local workspace = game:GetService("Workspace")
local lobbyFolder = workspace:FindFirstChild("Lobby") or workspace

for queueType, config in pairs(QueueConfig) do
	local pad = lobbyFolder:FindFirstChild(config.PadName)
	setupPad(pad, queueType)
end

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	removePlayerFromQueues(player)
end)

print("[Queue] Lobby Queue System initialized!")
