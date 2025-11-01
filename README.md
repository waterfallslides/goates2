# Roblox Bunker Survival - Lobby Queue System

A complete lobby queue system for Roblox with Solo/Duo/Squad matchmaking capabilities.

## Features

✅ **3 Queue Types**: Solo (1 player), Duo (2 players), Squad (4 players)
✅ **Touch-based Queue System**: Players simply step on a pad to join
✅ **20-Second Countdown**: Automatic countdown timer
✅ **Visual GUI**: Clean countdown display for all players
✅ **Auto-Teleport**: Uses TeleportService to move players to reserved servers
✅ **Flexible Queuing**: Teleports players even if queue isn't full

---

## 📁 Project Structure

```
goates2/
├── src/
│   ├── server/
│   │   ├── LobbyQueueSystem.lua      # Main server-side queue logic
│   │   └── CreateLobbyPads.lua       # Utility to create lobby pads
│   └── client/
│       └── CountdownGUI.lua          # Client-side countdown GUI
└── README.md
```

---

## 🚀 Installation & Setup

### Step 1: Create the Lobby Pads

1. Open **Roblox Studio**
2. Open your place/game
3. Open the **Command Bar** (View → Command Bar)
4. Copy the entire contents of `src/server/CreateLobbyPads.lua`
5. Paste into the Command Bar and press **Enter**

This will create 3 pads in `Workspace > Lobby`:
- **SoloPad** (Blue) - 1 player capacity
- **DuoPad** (Green) - 2 player capacity
- **SquadPad** (Orange) - 4 player capacity

### Step 2: Add Server Script

1. In **ServerScriptService**, create a new **Script** (not LocalScript)
2. Name it `LobbyQueueSystem`
3. Copy the contents of `src/server/LobbyQueueSystem.lua` into this script
4. **Important**: Update the `GAME_PLACE_ID` variable if you want to teleport to a different place

```lua
-- Line 20 in LobbyQueueSystem.lua
local GAME_PLACE_ID = game.PlaceId -- Change this to your target game place ID
```

### Step 3: Add Client GUI Script

1. In **StarterPlayer > StarterPlayerScripts**, create a new **LocalScript**
2. Name it `CountdownGUI`
3. Copy the contents of `src/client/CountdownGUI.lua` into this script

---

## 🎮 How It Works

### Player Experience

1. **Player steps on a pad** (Solo/Duo/Squad)
2. **GUI appears** showing:
   - Queue type (SOLO/DUO/SQUAD)
   - Number of players in queue
   - Countdown timer (20 seconds)
3. **Countdown starts** when first player joins
4. **Color changes** as countdown progresses:
   - 🟢 Green (20-11 seconds)
   - 🟠 Orange (10-6 seconds)
   - 🔴 Red (5-0 seconds)
5. **Automatic teleportation** when countdown reaches 0

### Technical Details

#### Server-Side (`LobbyQueueSystem.lua`)
- Detects when players touch pads via `.Touched` event
- Manages separate queues for each pad type
- Prevents players from being in multiple queues
- Starts 20-second countdown when players join
- Teleports all players in queue when countdown ends
- Creates reserved servers for matchmaking
- Handles player disconnections gracefully

#### Client-Side (`CountdownGUI.lua`)
- Listens for countdown updates from server
- Displays modern, clean countdown interface
- Updates colors based on time remaining
- Shows queue status and player count
- Auto-hides when teleportation begins

---

## ⚙️ Configuration

### Changing Player Limits

Edit the `QueueConfig` table in `LobbyQueueSystem.lua` (lines 22-36):

```lua
local QueueConfig = {
	Solo = {
		MaxPlayers = 1,  -- Change this number
		PadName = "SoloPad",
		Color = Color3.fromRGB(0, 170, 255)
	},
	Duo = {
		MaxPlayers = 2,  -- Change this number
		PadName = "DuoPad",
		Color = Color3.fromRGB(0, 255, 0)
	},
	Squad = {
		MaxPlayers = 4,  -- Change this number
		PadName = "SquadPad",
		Color = Color3.fromRGB(255, 170, 0)
	}
}
```

### Changing Countdown Time

Edit line 21 in `LobbyQueueSystem.lua`:

```lua
local COUNTDOWN_TIME = 20  -- Change to any number of seconds
```

### Changing Teleport Destination

Edit line 20 in `LobbyQueueSystem.lua`:

```lua
local GAME_PLACE_ID = 123456789  -- Replace with your Place ID
```

### Customizing Pad Appearance

Edit the `pads` table in `CreateLobbyPads.lua` (lines 27-49):

```lua
{
	Name = "SoloPad",
	Color = Color3.fromRGB(0, 170, 255),
	Position = Vector3.new(0, 1, 0),  -- Change position
	Text = "SOLO\n[1 PLAYER]"         -- Change text
}
```

---

## 🛠️ Troubleshooting

### Pads Don't Work
- ✅ Check that `LobbyQueueSystem` script is in **ServerScriptService**
- ✅ Check that pads exist in `Workspace > Lobby`
- ✅ Verify pad names match: `SoloPad`, `DuoPad`, `SquadPad`
- ✅ Check Output window for error messages

### GUI Doesn't Show
- ✅ Check that `CountdownGUI` script is in **StarterPlayer > StarterPlayerScripts**
- ✅ Verify it's a **LocalScript**, not a regular Script
- ✅ Check F9 console for client-side errors

### Teleport Fails
- ✅ Enable **Studio Access to API Services** (Game Settings → Security)
- ✅ Publish your game to Roblox
- ✅ Verify `GAME_PLACE_ID` is correct
- ✅ Test with real players, not Studio testing (TeleportService has limitations in Studio)

### Players Can't Join Queue
- ✅ Check that pad has `CanCollide = true`
- ✅ Verify the pad's `Touched` event is connected
- ✅ Check if queue is already full
- ✅ Look for errors in Output window

---

## 📋 Testing Checklist

- [ ] Pads appear in workspace with correct colors
- [ ] Touching a pad shows the GUI
- [ ] Countdown starts when player joins
- [ ] Countdown shows correct time (20 → 0)
- [ ] GUI colors change at 10s and 5s marks
- [ ] Multiple players can join same queue
- [ ] Queue respects player limits (Solo=1, Duo=2, Squad=4)
- [ ] Teleportation occurs when countdown reaches 0
- [ ] Players removed from queue when they leave
- [ ] Multiple queues can run simultaneously

---

## 🎯 Next Steps / Improvements

Here are some optional enhancements you could add:

- **Leave Queue Button**: Allow players to leave queue before countdown ends
- **Party System**: Let players form parties before queuing
- **Rank-Based Matchmaking**: Match players by skill level
- **Queue Notifications**: Sound effects when queue starts/ends
- **Anti-Abuse**: Cooldown to prevent queue spam
- **Analytics**: Track queue times and player counts
- **Custom Maps**: Teleport to different game modes
- **Queue History**: Show recently played matches

---

## 📝 Code Architecture

### Event Flow

```
Player Touches Pad
    ↓
Server: addPlayerToQueue()
    ↓
Server: startCountdown() [20 seconds]
    ↓
Server → Client: CountdownUpdate event (every second)
    ↓
Client: Update GUI display
    ↓
Server: TeleportService:TeleportAsync()
    ↓
Players teleported to new server
```

### Key Functions

**Server Side:**
- `addPlayerToQueue(player, queueType)` - Adds player to queue
- `removePlayerFromQueues(player)` - Removes player from all queues
- `startCountdown(queueType)` - Runs 20-second countdown
- `setupPad(pad, queueType)` - Sets up touch detection

**Client Side:**
- `CountdownEvent.OnClientEvent` - Updates GUI with countdown
- `QueueJoinEvent.OnClientEvent` - Shows queue join notification

---

## 📄 License

Free to use and modify for your Roblox games!

---

## 🤝 Support

For issues or questions, refer to the Roblox Developer Hub:
- [TeleportService Documentation](https://create.roblox.com/docs/reference/engine/classes/TeleportService)
- [RemoteEvents Guide](https://create.roblox.com/docs/scripting/events/remote)
- [GUI Tutorial](https://create.roblox.com/docs/tutorials/building/ui/creating-a-gui)

---

**Happy Coding! 🎮**
