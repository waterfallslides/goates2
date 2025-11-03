# New Features Setup Guide

## 🎉 What's New

### 1. ✅ PlayerSpawner - Spawn at Your Base
Players now spawn at their own base instead of the default spawn!

### 2. ✅ RollingGUI - Beautiful Rolling Interface
Brand new rolling interface with animations and visual feedback!

### 3. ✅ Index Template Auto-Creation
No more "Template not found" errors - creates automatically!

---

## 📥 Setup Instructions

### 1. PlayerSpawner (Server-Side)

**File:** `src/server/PlayerSpawner.lua`

**How to add:**
```
1. Go to ServerScriptService → Server
2. Right-click → Insert Object → Script (red icon)
3. Name it "PlayerSpawner"
4. Copy code from src/server/PlayerSpawner.lua
5. Paste into the Script
```

**Location:**
```
ServerScriptService/
└── Server/
    ├── PlayerSpawner (Script) ← NEW!
    └── MainServer (Script)
```

**What it does:**
- Automatically spawns players at their base on join
- Looks for Base[UserId] in Workspace.Bases/
- Spawns at SpawnLocation or Floor1 if it exists
- Falls back to any part in base if no spawn point

---

### 2. RollingGUI (Client-Side)

**File:** `src/client/gui/RollingGUI.lua`

**How to add:**
```
1. Go to StarterGui
2. Right-click → Insert Object → LocalScript (green icon)
3. Name it "RollingGUI"
4. Copy code from src/client/gui/RollingGUI.lua
5. Paste into the LocalScript
```

**Location:**
```
StarterGui/
├── RollingGUI (LocalScript) ← NEW!
├── NotificationHandler (LocalScript)
└── neww (ScreenGui)
```

**Features:**
- ✨ Beautiful animated interface
- 🎲 Roll button with visual feedback
- ⚡ Auto Roll toggle
- ⚡ Fast Roll toggle (skip animation)
- ✓ Keep button
- ✗ Skip button
- 🎨 Hover effects on all buttons
- 🌈 Color-coded rarities
- 📊 Flicker animation during roll

**Optional:** You can disable the old rolling system in `neww/DiceFrame/RollHandler` or keep both!

---

### 3. Index Template Fix (Auto-Applied)

**File:** `src/client/gui/IndexHandler.lua` (updated)

**What changed:**
- Automatically creates Template if missing
- No more "Infinite yield on Template" errors
- Creates proper frame structure with image, name, rarity labels

**Update method:**
```
1. Find StarterGui → neww → Index → IndexHandler
2. Replace the code with updated version from src/client/gui/IndexHandler.lua
```

---

## 🎮 How to Use New Features

### RollingGUI

**When you join the game:**
1. You'll see a new rolling interface in the center of screen
2. Click **"🎲 ROLL"** to roll for a brainrot
3. Watch the flicker animation (or instant if Fast Roll enabled)
4. Click **"✓ KEEP"** to add to your base
5. Click **"✗ SKIP"** to pass

**Toggles:**
- **Auto Roll**: Automatically rolls every 5 seconds
- **Fast Roll**: Skip animation, show result instantly

### PlayerSpawner

**Automatic:**
- Join game → Spawn at your base
- Respawn → Spawn at your base
- No setup needed!

**Requirements:**
- Must have `Workspace/Bases/Base[YourUserId]/` folder
- Base should have a SpawnLocation part (optional)

---

## 🔧 Configuration

### Rolling Animation Speed

Edit `RollingGUI.lua` line ~220:
```lua
task.wait(0.15)  -- Change this number (seconds between flickers)
```

### Auto Roll Interval

Already configured in `Config.lua`:
```lua
AutoRollInterval = 5, -- seconds
```

### Spawn Height

Edit `PlayerSpawner.lua` lines with `+ Vector3.new(0, 5, 0)`:
```lua
return part.CFrame + Vector3.new(0, 5, 0)  -- Change 5 to desired height
```

---

## ✅ Testing Checklist

### RollingGUI
- [ ] GUI appears when joining game
- [ ] Roll button works
- [ ] Flicker animation plays
- [ ] Keep button adds to base
- [ ] Skip button closes result
- [ ] Auto Roll toggles on/off
- [ ] Fast Roll skips animation
- [ ] Hover effects work on buttons

### PlayerSpawner
- [ ] Spawn at base on join
- [ ] Spawn at base on respawn
- [ ] No errors in Output
- [ ] Works even without SpawnLocation part

### Index Template
- [ ] No "Infinite yield on Template" errors
- [ ] Index opens without issues
- [ ] Brainrots display correctly

---

## 🎨 Customization Ideas

### Change RollingGUI Colors

Edit colors in `RollingGUI.lua`:
```lua
-- Main background
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Roll button
rollButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)

-- Keep button (green)
keepButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

-- Skip button (red)
skipButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
```

### Move RollingGUI Position

Edit position in `RollingGUI.lua`:
```lua
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
-- Format: UDim2.new(X scale, X offset, Y scale, Y offset)

-- Examples:
-- Top-left: UDim2.new(0, 10, 0, 10)
-- Top-right: UDim2.new(1, -410, 0, 10)
-- Bottom-center: UDim2.new(0.5, -200, 1, -610)
```

### Change RollingGUI Size

Edit size in `RollingGUI.lua`:
```lua
mainFrame.Size = UDim2.new(0, 400, 0, 600)
-- Format: UDim2.new(X scale, X pixels, Y scale, Y pixels)

-- Examples:
-- Smaller: UDim2.new(0, 300, 0, 500)
-- Larger: UDim2.new(0, 500, 0, 700)
```

---

## 🐛 Troubleshooting

### RollingGUI Not Appearing

**Check:**
1. Is it in StarterGui as a LocalScript?
2. Look for "✓ RollingGUI loaded" in Output
3. Check for errors in Output
4. Make sure Events folder exists (created by MainServer)

**Fix:**
```
- Verify MainServer ran successfully first
- Check ReplicatedStorage has Events folder
- Ensure all RemoteEvents exist
```

### Not Spawning at Base

**Check:**
1. Does `Workspace/Bases/` exist?
2. Does `Base[YourUserId]` exist?
3. Look for "✓ Spawned [Name] at their base" in Output

**Fix:**
```
- Create Bases folder in Workspace
- Create Base123456789 (replace with your UserId)
- Add a part named "SpawnLocation" in the base
```

### Index Template Still Missing

**Check:**
1. Did you update IndexHandler.lua?
2. Look for "✓ Created Index Template" in Output

**Fix:**
```
- Replace entire IndexHandler.lua with new version
- Restart game to apply changes
```

---

## 📊 File Summary

| File | Type | Location | Purpose |
|------|------|----------|---------|
| PlayerSpawner.lua | Script | ServerScriptService/Server/ | Spawn players at base |
| RollingGUI.lua | LocalScript | StarterGui/ | Rolling interface |
| IndexHandler.lua | LocalScript | StarterGui/neww/Index/ | Updated to create template |

---

## 🎯 What's Working Now

After adding these files:

✅ Players spawn at their base (not random spawn)
✅ Beautiful rolling GUI with animations
✅ Auto Roll and Fast Roll features
✅ No more Index Template errors
✅ Hover effects on buttons
✅ Color-coded rarity display
✅ Keep/Skip buttons for results

---

## 🚀 Next Steps

1. **Add PlayerSpawner** to spawn at your base
2. **Add RollingGUI** for better rolling experience
3. **Update IndexHandler** to fix template error
4. **Test in game** - everything should work!

---

**Enjoy your improved RNG Brainrot game!** 🎮✨
