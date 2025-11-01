# Food Spawning & Collection System - Setup Guide

## Overview

This system implements a complete food spawning and collection mechanic with:
- **Day/Night cycle** that controls food spawning
- **5 food types** with different rarities and benefits
- **Object pooling** for performance optimization
- **Inventory management** with limits (max 3 different types)
- **Client-server architecture** with RemoteEvents

---

## File Structure

```
src/
├── shared/
│   └── FoodConfig.lua           # Food types, stats, and configuration
├── server/
│   ├── DayNightCycle.lua        # Day/night time management
│   ├── FoodSpawner.lua          # Food spawning with object pooling
│   ├── PlayerInventory.lua      # Player inventory and stats management
│   └── FoodSystemManager.lua    # Main orchestrator (START HERE)
└── client/
    ├── FoodCollectionHandler.lua # Food collection interactions
    └── InventoryUI.lua           # Inventory and stats UI display
```

---

## Installation in Roblox Studio

### Step 1: Set Up Server Scripts

1. **In ServerScriptService**, create a folder called `FoodSystem`
2. Add these server scripts to the folder:
   - `DayNightCycle.lua`
   - `FoodSpawner.lua`
   - `PlayerInventory.lua`
   - `FoodSystemManager.lua` (This should run automatically)

3. Make sure `FoodSystemManager` is a **Script** (not LocalScript)

### Step 2: Set Up Shared Modules

1. **In ReplicatedStorage**, create a folder called `Shared`
2. Add `FoodConfig.lua` as a **ModuleScript**

### Step 3: Set Up Client Scripts

1. **In StarterPlayer > StarterPlayerScripts**, add:
   - `FoodCollectionHandler.lua` (LocalScript)
   - `InventoryUI.lua` (LocalScript)

### Step 4: Adjust Module Paths

**IMPORTANT:** Update the require() paths in your scripts based on where you placed them.

For example, in `FoodSystemManager.lua`:
```lua
-- If your structure matches above:
local DayNightCycle = require(script.Parent.DayNightCycle)
local FoodSpawner = require(script.Parent.FoodSpawner)
local PlayerInventory = require(script.Parent.PlayerInventory)
```

In `FoodSpawner.lua`:
```lua
-- Adjust based on your folder structure
local FoodConfig = require(game.ReplicatedStorage.Shared.FoodConfig)
```

### Step 5: Verify Workspace Setup

The system will automatically create a **FoodItems** folder in Workspace when it runs.

---

## Food Types & Stats

| Food Type | HP | Hunger | Rarity | Max Stack |
|-----------|-----|---------|---------|-----------|
| 🍞 Bread | +20 | +30% | Common | 10 |
| 🍎 Apple | +15 | +20% | Common | 10 |
| 🥫 Canned Food | +25 | +40% | Uncommon | 8 |
| 💧 Water Bottle | +10 | +25% | Uncommon | 10 |
| 🍖 Cooked Meat | +40 | +50% | Rare | 5 |

---

## Configuration

### Day/Night Cycle Timing

Edit `DayNightCycle.lua` (lines 10-11):
```lua
local DAY_LENGTH = 300      -- 5 minutes (300 seconds)
local NIGHT_LENGTH = 180    -- 3 minutes (180 seconds)
```

### Food Spawning

Edit `FoodSpawner.lua` (lines 14-17):
```lua
local POOL_SIZE = 50          -- Total pool size
local SPAWN_COUNT_DAY = 30    -- Food items spawned per day
local SPAWN_AREA_SIZE = 200   -- Spawn area (200x200 studs)
local SPAWN_HEIGHT = 50       -- Height to spawn at
```

### Spawn Area Position

By default, food spawns around position (0, 50, 0). To change this, modify `FoodSystemManager.lua`:

```lua
-- After foodSpawner initialization
foodSpawner:SetSpawnArea(
    Vector3.new(100, 50, 100),  -- Center position
    300                          -- Area size
)
```

### Inventory Limits

Edit `FoodConfig.lua` (lines 54-56):
```lua
FoodConfig.InventoryLimits = {
    MaxDifferentTypes = 3,  -- Maximum 3 different food types
}
```

### Food Rarity Weights

Edit `FoodConfig.lua` (lines 10-14):
```lua
FoodConfig.RarityWeights = {
    common = 50,      -- 50% chance
    uncommon = 30,    -- 30% chance
    rare = 20         -- 20% chance
}
```

---

## How It Works

### Day/Night Cycle
1. Game starts with **Day** (5 minutes default)
2. When day starts → Food spawns across the map
3. When night starts → All food is removed
4. Cycle repeats indefinitely

### Food Collection
1. Player clicks food OR uses proximity prompt (mobile/console)
2. Client sends request to server via RemoteFunction
3. Server checks inventory limits:
   - Max 3 different food types
   - Each type has stack limit
4. If allowed, food is added to inventory and removed from world
5. Client receives notification and UI updates

### Object Pooling
- Pre-creates 50 food objects (configurable)
- Reuses objects instead of creating/destroying
- Improves performance significantly
- Automatically expands pool if needed

---

## Remote Events & Functions

The system creates these in **ReplicatedStorage**:

### Folder: GameStateEvents
- `DayNightTransition` (RemoteEvent) - Day/night changes
- `TimeUpdate` (RemoteEvent) - Time remaining updates
- `InventoryUpdate` (RemoteEvent) - Player inventory changes
- `StatsUpdate` (RemoteEvent) - Health/hunger updates
- `FoodCollected` (RemoteEvent) - Successful collection
- `CollectionFailed` (RemoteEvent) - Collection failure messages

### RemoteFunction
- `CollectFood` - Handles food collection requests

---

## UI Elements

### Stats Panel (Top Left)
- ❤️ Health display
- 🍖 Hunger display
- ☀️/🌙 Day/Night status with timer

### Inventory Panel (Top Right)
- 🎒 Shows collected food
- Displays quantity (x5, x10, etc.)
- Shows current slot usage (2/3)

### Notifications (Bottom Center)
- Green: Successful collection
- Red: Failed collection (with reason)
- Auto-fades after 2 seconds

---

## Testing in Studio

1. **Press Play** in Roblox Studio
2. Check Output for initialization messages:
   ```
   [FoodSystemManager] Initializing Food System...
   [DayNightCycle] System started!
   [DayNightCycle] Day has started!
   [FoodSpawner] Spawning 30 food items...
   ```

3. **Look for food items** in Workspace > FoodItems folder
4. **Click on food** to collect it
5. **Check UI** in top-left and top-right corners
6. **Wait for night** to see food despawn

### Common Issues

**Food doesn't spawn:**
- Check Output for errors
- Verify `FoodSystemManager` is running in ServerScriptService
- Check module require() paths

**Can't collect food:**
- Check if inventory is full (3/3 types)
- Look for error messages in Output
- Verify RemoteFunction "CollectFood" exists in ReplicatedStorage

**UI not showing:**
- Verify client scripts are in StarterPlayerScripts
- Check for errors in Output (F9)
- Make sure scripts are LocalScripts

---

## Advanced Customization

### Add New Food Type

1. Edit `FoodConfig.lua`:
```lua
Pizza = {
    Name = "Pizza",
    DisplayName = "🍕 Pizza",
    HealthRestore = 35,
    HungerRestore = 45,
    Rarity = "rare",
    Color = Color3.fromRGB(255, 140, 0),
    Size = Vector3.new(2.5, 0.5, 2.5),
    MaxStack = 6
}
```

### Change Food Appearance

Edit the `CreateFoodObject()` function in `FoodSpawner.lua` to add custom meshes, decals, or special effects.

### Add Hunger Decay

In `PlayerInventory.lua`, add a timer loop:
```lua
task.spawn(function()
    while true do
        task.wait(10)  -- Every 10 seconds
        for player, stats in pairs(self.PlayerStats) do
            self:UpdateStats(player, 0, -5)  -- Decrease hunger by 5
        end
    end
end)
```

---

## Performance Considerations

- **Object Pooling**: Reuses 50 objects instead of creating/destroying
- **Batch Spawning**: Adds small delays to avoid lag spikes
- **Efficient Updates**: Only sends UI updates when values change
- **Local Calculations**: Client handles UI rendering

Expected performance:
- 30 food items: ~0.1ms per frame
- 100+ food items: May need to increase pool size

---

## Credits

- Food system with day/night cycle
- Object pooling implementation
- Client-server architecture with RemoteEvents
- Mobile-friendly with ProximityPrompts

---

## Support

For issues or questions:
1. Check Output (F9) for error messages
2. Verify all scripts are in correct locations
3. Check require() paths match your folder structure
4. Test in both Studio and actual game server

Happy developing! 🎮
