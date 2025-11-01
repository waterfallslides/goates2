# Quick Start Guide - Lobby Queue System

## 🚀 5-Minute Setup

### 1️⃣ Create the Pads (30 seconds)

Open **Roblox Studio** → Open **Command Bar** (View → Command Bar)

Copy & paste this into Command Bar, press Enter:

```lua
-- Copy entire contents of src/server/CreateLobbyPads.lua here
```

**Result**: 3 colored pads appear in Workspace > Lobby

---

### 2️⃣ Add Server Script (1 minute)

1. **ServerScriptService** → Insert **Script** (not LocalScript)
2. Name it: `LobbyQueueSystem`
3. Copy `src/server/LobbyQueueSystem.lua` into it
4. **Change line 20** if teleporting to different place:
   ```lua
   local GAME_PLACE_ID = 123456789  -- Your target Place ID
   ```

---

### 3️⃣ Add Client Script (1 minute)

1. **StarterPlayer** → **StarterPlayerScripts** → Insert **LocalScript**
2. Name it: `CountdownGUI`
3. Copy `src/client/CountdownGUI.lua` into it

---

### 4️⃣ Test It! (1 minute)

1. Press **F5** (Play)
2. Walk onto any colored pad
3. Watch the countdown GUI appear
4. Countdown goes from 20 → 0

✅ **Done!** Your lobby queue system is working!

---

## 🎨 The Pads

| Pad | Color | Capacity | Location |
|-----|-------|----------|----------|
| **Solo** | 🔵 Blue | 1 player | Position (0, 1, 0) |
| **Duo** | 🟢 Green | 2 players | Position (15, 1, 0) |
| **Squad** | 🟠 Orange | 4 players | Position (30, 1, 0) |

---

## 📱 How It Works

```
Player steps on pad
    ↓
20-second countdown starts
    ↓
GUI shows time remaining
    ↓
Timer hits 0
    ↓
TeleportService → Reserved Server
```

---

## ⚙️ Common Customizations

### Change Countdown Time

**File**: `src/server/LobbyQueueSystem.lua`
**Line**: 21
```lua
local COUNTDOWN_TIME = 20  -- Change this number
```

### Change Player Limits

**File**: `src/server/LobbyQueueSystem.lua`
**Lines**: 23-35
```lua
Solo = { MaxPlayers = 1 },  -- Change these
Duo = { MaxPlayers = 2 },
Squad = { MaxPlayers = 4 }
```

### Change Pad Positions

**File**: `src/server/CreateLobbyPads.lua`
**Lines**: 30, 37, 44
```lua
Position = Vector3.new(0, 1, 0),  -- X, Y, Z coordinates
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Pads don't exist | Run CreateLobbyPads.lua in Command Bar |
| GUI doesn't show | Check CountdownGUI is in StarterPlayerScripts |
| Teleport fails | Publish game + enable API Services in settings |
| Script errors | Check Output window (F9) for error messages |

---

## 📚 Full Documentation

- **README.md** - Complete setup guide & features
- **TESTING_GUIDE.md** - Comprehensive testing procedures

---

## ✅ Checklist

- [ ] Pads created (blue, green, orange)
- [ ] Server script in ServerScriptService
- [ ] Client script in StarterPlayerScripts
- [ ] Tested in Studio (F5)
- [ ] Works correctly

**Total Setup Time: ~5 minutes** ⏱️

---

Need help? Check the full **README.md** for detailed instructions!
