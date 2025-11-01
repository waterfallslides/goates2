# Day/Night Cycle System - Setup Instructions

This guide explains how to set up the day/night cycle system in your Roblox game.

## Overview

The day/night cycle system consists of:
- **Day Phase**: 180 seconds (3 minutes) - Safe time for gathering resources
- **Night Phase**: 300 seconds (5 minutes) - Dangerous time with monsters
- **Day Counter**: Tracks which day the players are on (starts at Day 1)
- **Warnings**: Players get notified 30 and 10 seconds before night falls
- **GUI Display**: Shows current phase, day number, and countdown timer

## Files Created

1. `src/server/DayNightCycleManager.lua` - Core cycle logic (ModuleScript)
2. `src/server/InitializeDayNightCycle.lua` - Initialization script (Script)
3. `src/client/DayNightGUI.lua` - Client-side GUI (LocalScript)

## Installation Steps

### Step 1: Set up Server Scripts

1. Open Roblox Studio and your game
2. In the Explorer, navigate to **ServerScriptService**
3. Create a **ModuleScript** named `DayNightCycleManager`
   - Copy the contents of `src/server/DayNightCycleManager.lua` into it
4. Create a **Script** named `InitializeDayNightCycle`
   - Copy the contents of `src/server/InitializeDayNightCycle.lua` into it
   - Make sure this script is a **child of ServerScriptService** (not inside the ModuleScript)

### Step 2: Set up Client Script

1. In the Explorer, navigate to **StarterPlayer** → **StarterPlayerScripts**
2. Create a **LocalScript** named `DayNightGUI`
3. Copy the contents of `src/client/DayNightGUI.lua` into it

### Step 3: Verify Structure

Your Roblox Studio hierarchy should look like this:

```
ServerScriptService
├── DayNightCycleManager (ModuleScript)
├── InitializeDayNightCycle (Script)
├── LobbyQueueSystem (Script) [existing]
└── CreateLobbyPads (ModuleScript) [existing]

StarterPlayer
└── StarterPlayerScripts
    ├── DayNightGUI (LocalScript)
    └── CountdownGUI (LocalScript) [existing]

ReplicatedStorage
├── DayNightEvents (Folder) [auto-created by scripts]
│   ├── PhaseChange (RemoteEvent)
│   ├── TimerUpdate (RemoteEvent)
│   └── Warning (RemoteEvent)
└── LobbyQueueEvents (Folder) [existing]
```

## How It Works

### Day Phase (180 seconds)
When a new day starts:
- ☀ Lighting is set to noon (ClockTime = 12)
- 💰 All alive players receive 75 coins
- 🔧 Bunker repair function is triggered (placeholder)
- 🍎 Food spawns on the map (placeholder)
- 📈 Day counter increments

### Night Phase (300 seconds)
When night falls:
- 🌙 Lighting is set to midnight (ClockTime = 0)
- 🍎 All food is removed from the map (placeholder)
- 👹 Monsters spawn (placeholder)

### Warnings
- ⚠️ 30 seconds before night: "Night is coming in 30 seconds!"
- ⚠️ 10 seconds before night: "Night is coming in 10 seconds!"

### GUI Display
The GUI appears in the top-right corner and shows:
- Current phase (Day or Night)
- Current day number
- Countdown to next phase
- Dynamic color coding:
  - Green: Safe (>30 seconds remaining)
  - Orange: Caution (10-30 seconds)
  - Red: Danger (<10 seconds)

## Customization

You can customize the cycle durations by editing these values in `DayNightCycleManager`:

```lua
local DAY_DURATION = 180  -- Change day length (in seconds)
local NIGHT_DURATION = 300  -- Change night length (in seconds)
local COINS_PER_DAY = 75  -- Change coin reward amount
```

## Integration with Other Systems

The following functions are currently **placeholders** (TODO):

1. **Coin System** (`awardCoinsToPlayer`)
   - Implement player coin storage (leaderstats or DataStore)
   - Award coins when day starts

2. **Bunker Repair** (`repairBunker`)
   - Implement bunker damage/repair mechanics
   - Reset bunker health at day start

3. **Food Spawning** (`spawnFood`)
   - Implement food item spawning system
   - Place food at random locations during day

4. **Food Removal** (`removeAllFood`)
   - Find all food items in workspace
   - Remove them when night starts

5. **Monster Spawning** (`spawnMonsters`)
   - Implement monster/enemy spawning system
   - Spawn monsters at night based on difficulty

6. **Player Alive Check** (`getAlivePlayers`)
   - Currently checks if player has character with health > 0
   - You may want to add more sophisticated alive/dead tracking

## Testing

1. Start a test server in Roblox Studio
2. Wait 2 seconds for initialization
3. You should see:
   - Console message: "[DayNightCycle] Day 1 started"
   - GUI appears in top-right corner showing "DAY", "Day 1", and countdown
4. After 150 seconds (2.5 minutes), you'll get a 30-second warning
5. After 170 seconds, you'll get a 10-second warning
6. After 180 seconds, night begins
7. After 300 more seconds (5 minutes), day 2 begins

## Troubleshooting

### GUI doesn't appear
- Make sure `DayNightGUI` is a **LocalScript** in **StarterPlayerScripts**
- Check the console for any error messages
- Verify RemoteEvents are created in ReplicatedStorage

### Cycle doesn't start
- Make sure `InitializeDayNightCycle` is a **Script** (not LocalScript)
- Check that `DayNightCycleManager` is a **ModuleScript**
- Look for console errors in the server output

### RemoteEvents not found
- The server script automatically creates the RemoteEvents
- Wait a moment after starting the server
- Check ReplicatedStorage for the "DayNightEvents" folder

## Next Steps

To complete the game, implement these systems:
1. Coin/currency system for player rewards
2. Food spawning and collection mechanics
3. Bunker building and repair system
4. Monster AI and spawning system
5. Player health and death mechanics
6. Win/lose conditions

## Notes

- The cycle starts automatically 2 seconds after the server begins
- The first day starts at Day 1 (not Day 0)
- Lighting changes are handled automatically by the server
- All players see the same phase and countdown
- The GUI uses the same cartoony style as the lobby queue GUI
