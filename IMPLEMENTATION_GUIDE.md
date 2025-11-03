# RNG Brainrot Stealing Game - Implementation Guide

## 🎮 Overview
A complete Roblox RNG game where players roll for "brainrots", place them in bases, and steal from others.

**Status:** ✅ Core systems complete (excluding monetization)

---

## 📁 Project Structure

```
src/
├── replicated/
│   └── modules/
│       ├── BrainrotData.lua       # All brainrot configs, rarities, weights
│       └── Config.lua              # General game configuration
│
├── server/
│   ├── core/
│   │   ├── DataManager.lua        # ProfileService data management
│   │   ├── RollingSystem.lua      # RNG rolling logic
│   │   └── StealingSystem.lua     # Stealing mechanics
│   │
│   ├── systems/
│   │   ├── BaseManager.lua        # Brainrot placement on pads
│   │   └── RebirthHandler.lua     # Rebirth validation & processing
│   │
│   ├── leaderboards/
│   │   └── StatsManager.lua       # Tracks rolls, robux, playtime
│   │
│   ├── tools/
│   │   ├── SlapTool.lua           # Slap tool script
│   │   └── GiveSlapTool.lua       # Give tool on spawn
│   │
│   └── MainServer.lua             # Entry point, RemoteEvents setup
│
└── client/
    └── gui/
        ├── RollHandler.lua         # Rolling UI & animations
        ├── IndexHandler.lua        # Index display
        ├── RebirthUIHandler.lua    # Rebirth UI
        ├── OpenButtonsHandler.lua  # Open/close buttons
        └── NotificationHandler.lua # Notification popups
```

---

## 🚀 Setup Instructions

### 1. Install ProfileService
**CRITICAL:** Install ProfileService from https://github.com/MadStudioRoblox/ProfileService

Place the ProfileService module in:
```
ServerStorage/ProfileService
```

### 2. Create Workspace Structure
Create the following in Workspace:
```
Workspace/
└── Bases/
    ├── Base[PlayerUserId]/
    │   ├── Floor1/
    │   │   ├── SingersPodium/
    │   │   │   ├── 1 (Part)
    │   │   │   ├── 2 (Part)
    │   │   │   └── ... up to 10
    │   │   └── Lasers/ (optional)
    │   │
    │   └── Floor2/
    │       ├── SingersPodium/
    │       │   ├── 1 (Part)
    │       │   └── ... up to 8
    │       └── Lasers/ (optional)
```

### 3. Create Brainrot Models
In ServerStorage, create:
```
ServerStorage/
└── Brainrots/
    ├── Common/
    │   ├── SkibidiToilet (Model)
    │   └── Griddy (Model)
    ├── Rare/
    ├── Epic/
    ├── Legendary/
    ├── Mythic/
    ├── Secret/
    └── BrainrotGod/
```

Update `BrainrotData.lua` with your brainrot names and image IDs.

### 4. Create Slap Tool
In ServerStorage, create:
```
ServerStorage/
└── SlapTool (Tool)
    ├── Handle (Part) - The bat model
    └── SlapTool (Script) - Copy from src/server/tools/SlapTool.lua
```

### 5. Place Scripts in Roblox

#### ServerScriptService:
```
ServerScriptService/
├── Server/ (Folder)
│   ├── Core/
│   ├── Systems/
│   ├── Leaderboards/
│   ├── Tools/
│   └── MainServer.lua
```
Copy all files from `src/server/` into this structure.

#### ReplicatedStorage:
```
ReplicatedStorage/
├── Modules/
│   ├── BrainrotData.lua
│   └── Config.lua
└── Events/ (Created automatically by MainServer.lua)
```

#### StarterGui:
Place the GUI scripts in the existing GUI structure:
```
StarterGui/
└── neww (ScreenGui)
    ├── DiceFrame/
    │   └── RollHandler (LocalScript)
    ├── Index/
    │   └── IndexHandler (LocalScript)
    ├── Rebirth/
    │   └── RebirthUIHandler (LocalScript)
    ├── OpenButtonsHandler (LocalScript)
    └── NotificationHandler (LocalScript)
```

---

## ⚙️ How It Works

### Rolling System
1. Player clicks "Roll" button → Fires `RollBrainrot` RemoteEvent
2. Server calculates luck, performs RNG roll
3. Server sends result to client via `RollResult`
4. Client shows animation (or instant if Fast Roll)
5. Player chooses "Keep" or "Skip"
6. If Keep: Server assigns to available pad

**RNG Formula:**
- Rarities weighted: Common (50%) → BrainrotGod (0.4%)
- Frames weighted: Normal (85%), Gold (12%), Diamond (3%)
- Luck multiplier divides roll value (2x luck = 2x chance at rare items)

### Stealing System
1. Player walks to another's base
2. Holds "E" on ProximityPrompt (3 seconds)
3. Brainrot clones above thief's head
4. Original owner receives alert
5. Owner can slap with Slap tool to return brainrot
6. If thief reaches their base: Steal complete
7. Brainrot added to thief's data, removed from owner

### Base System
- Each player has Base[UserId] in Workspace
- Floor1: 10 pads, Floor2: 8 pads (unlocked after rebirth)
- ProximityPrompts created on brainrots for stealing
- Brainrots load on player join

### Index System
- Tracks all collected brainrots
- Format: `BrainrotID_Frame` (e.g., "SkibidiToilet_Gold")
- Persists through rebirths
- Shows locked/unlocked in GUI

### Rebirth System
- Requires ALL brainrots collected (all rarities × all frames)
- Clears Floor1 and Floor2 pads
- Keeps Index intact
- Increments Rebirths counter
- Unlocks Floor2 on first rebirth

### Data Persistence
Uses ProfileService for:
- Auto-save every 120 seconds
- Manual save on: Roll kept, Steal, Rebirth
- Session locking prevents duplication
- Handles player leaving mid-steal

### Leaderboards
Three OrderedDataStores:
1. **Most Rolls** - Tracks TotalRolls
2. **Most Robux Spent** - Tracks RobuxSpent (ready for monetization)
3. **Most Playtime** - Tracks PlayTime in seconds

Updates every 5 minutes to optimize performance.

---

## 🎨 GUI System

### Existing GUI Structure
The GUI already exists in StarterGui.neww with:
- DiceFrame (Rolling UI)
- Index (Collection viewer)
- Rebirth (Rebirth UI)
- CashStore (Shop - not connected yet)
- LuckEvent (Server luck display)

### Scripts Created
1. **RollHandler** - Handles roll button, auto/fast roll toggles, result display
2. **IndexHandler** - Loads index, filters by frame (Normal/Gold/Diamond)
3. **RebirthUIHandler** - Shows progress, validates rebirth eligibility
4. **OpenButtonsHandler** - Simple open/close for main frames
5. **NotificationHandler** - Toast notifications for events

---

## 📊 Configuration

### Edit Rarity Chances
In `BrainrotData.lua`:
```lua
RarityWeights = {
    Common = 125,        -- Adjust these numbers
    Rare = 64,           -- to change drop rates
    Epic = 32,
    -- ...
}
```

### Edit Game Settings
In `Config.lua`:
```lua
Rolling = {
    DefaultRollTime = 3,      -- Animation duration
    AutoRollInterval = 5,     -- Time between auto rolls
}

Stealing = {
    ProximityPromptDuration = 3,  -- Hold time
    SlapDetectionRange = 10,      -- Slap range
}
```

---

## ✅ Testing Checklist

### Core Systems
- [ ] Player data loads on join
- [ ] Roll button works
- [ ] Brainrot appears on pad after Keep
- [ ] Index updates when brainrot kept
- [ ] Steal works (hold E, brainrot on head)
- [ ] Slap returns stolen brainrot
- [ ] Completing steal adds to thief's base
- [ ] Rebirth clears base when eligible

### GUI
- [ ] Roll animation plays (or skips with Fast Roll)
- [ ] Auto Roll continuously rolls
- [ ] Index shows locked/unlocked brainrots
- [ ] Frame filters work (Normal/Gold/Diamond)
- [ ] Rebirth button enables when eligible
- [ ] Notifications appear for events

### Edge Cases
- [ ] Player leaves mid-steal (brainrot returns)
- [ ] Base full on roll (shows error)
- [ ] Rebirth with items (clears properly)
- [ ] Multiple steals simultaneously
- [ ] Data persists on rejoin

---

## 🐛 Common Issues

### "Data not loaded"
- Ensure ProfileService is in ServerStorage
- Check DataStore name in Config.lua
- Enable Studio API Services in Game Settings

### "Brainrot model not found"
- Verify ServerStorage.Brainrots structure
- Match folder names to rarity names exactly
- Update BrainrotData.lua with correct IDs

### "Pad not found"
- Check Workspace.Bases structure
- Ensure pads are numbered 1-10 (Floor1) and 1-8 (Floor2)
- Verify SingersPodium exists in each floor

### ProximityPrompts not appearing
- Ensure StealingSystem.Init() is called in MainServer
- Check brainrot models have valid parts
- Verify MaxActivationDistance in Config

---

## 🎯 Next Steps (Monetization)

When ready to add monetization:
1. Create gamepasses in Roblox Creator Hub
2. Create dev products for purchases
3. Add ShopHandler.lua to handle purchases
4. Connect CashStore GUI to shop handler
5. Implement x2 Server Luck dev product
6. Add Starter Pack, Auto Roll, Fast Roll purchases

---

## 📝 Code Philosophy

✅ **SIMPLE** - One function = one purpose
✅ **CLEAN** - Clear variable names, commented sections
✅ **OPTIMIZED** - ProfileService, minimal RemoteEvents, efficient loops

---

## 🤝 Support

For issues or questions:
1. Check this guide first
2. Verify all setup steps completed
3. Test in Roblox Studio with 2+ players
4. Check Output for error messages

---

**Game Status:** Ready for testing! 🎉
**Missing:** Monetization systems only (as requested)
