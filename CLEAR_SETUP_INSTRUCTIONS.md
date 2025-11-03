# 🎯 CLEAR SETUP INSTRUCTIONS

## Your GUI Structure (What You Already Have)

```
StarterGui/
└── neww (ScreenGui)
    ├── DiceFrame (Frame) - Has Roll, AutoRoll, FastRoll buttons
    │   ├── Roll (TextButton)
    │   ├── AutoRoll (TextButton) - Optional
    │   └── FastRoll (TextButton) - Optional
    │
    └── RollingFrame (Frame) - Shows during roll animation
        ├── BrainrotImage (ImageLabel)
        ├── Keep (TextButton)
        ├── Rarity (TextLabel)
        ├── Rolling (TextLabel)
        └── Name (TextLabel)
```

---

## ✅ STEP-BY-STEP SETUP (2 Minutes)

### Step 1: Add the Script

```
1. Open Roblox Studio
2. Go to: StarterGui → neww (your ScreenGui)
3. Right-click on "neww"
4. Insert Object → LocalScript
5. Name it "RollHandler"
```

### Step 2: Copy the Code

```
6. Open the file: src/client/gui/RollHandler_Clean.lua
7. Copy ALL the code
8. Paste into your new RollHandler script
```

### Step 3: Test

```
9. Press Play
10. Look for: "✓ RollHandler connected to DiceFrame + RollingFrame"
11. Click Roll button in DiceFrame
12. Watch RollingFrame animate
13. Click Keep button when done
```

---

## 📍 Exact Location

**The script goes HERE:**

```
StarterGui/
└── neww (ScreenGui)
    ├── RollHandler (LocalScript) ← PUT IT HERE!
    ├── DiceFrame (Frame)
    └── RollingFrame (Frame)
```

**NOT in DiceFrame!**
**NOT in RollingFrame!**
**Directly in neww!**

---

## 🎮 What It Does

### DiceFrame Buttons:
- ✅ **Roll** → Sends to server, triggers animation
- ✅ **AutoRoll** → Toggles on/off, rolls every 5 seconds
- ✅ **FastRoll** → Skips animation, instant result

### RollingFrame Elements:
- ✅ **BrainrotImage** → Shows flicker animation, then result
- ✅ **Keep** → Saves brainrot to your base
- ✅ **Rarity** → Shows rarity + frame, color-coded
- ✅ **Rolling** → Shows "ROLLING..." then brainrot name
- ✅ **Name** → Shows brainrot name

### Animations:
- ✅ Button click bounce
- ✅ Roll flicker (15 frames)
- ✅ Result pop-in
- ✅ AutoRoll/FastRoll color change (green when on)

---

## ⚙️ How It Works

### When You Click "Roll":
1. DiceFrame Roll button clicked
2. Sends request to server
3. RollingFrame becomes visible
4. Plays flicker animation (15 times)
5. Shows result with pop animation
6. Keep button appears

### When You Click "Keep":
1. Keep button clicked
2. Sends to server
3. Adds to your base
4. RollingFrame hides
5. Ready for next roll

### When You Toggle "AutoRoll":
1. AutoRoll button clicked
2. Button turns green
3. Rolls automatically every 5 seconds
4. Click again to turn off (gray)

### When You Toggle "FastRoll":
1. FastRoll button clicked
2. Button turns green
3. Skips flicker animation
4. Shows result instantly

---

## 🔧 NO GUI CREATED

**The script does NOT create any GUI elements!**

It only:
- ✅ Finds your existing DiceFrame
- ✅ Finds your existing RollingFrame
- ✅ Connects buttons to server
- ✅ Adds simple animations
- ✅ Shows/hides RollingFrame at right times

**Uses 100% what you already built!**

---

## 🐛 Troubleshooting

### Error: "DiceFrame is not a valid member"

**Your DiceFrame might have a different name.**

**Fix:** Update line 21:
```lua
local diceFrame = gui:WaitForChild("DiceFrame")
-- Change "DiceFrame" to your actual frame name
```

### Error: "RollingFrame is not a valid member"

**Your RollingFrame might have a different name.**

**Fix:** Update line 22:
```lua
local rollingFrame = gui:WaitForChild("RollingFrame")
-- Change "RollingFrame" to your actual frame name
```

### AutoRoll/FastRoll Not Working

**These are optional! If you don't have them, that's fine.**

The script checks:
```lua
if autoRollButton then
    -- Only runs if button exists
end
```

**If you DO have them but they're named differently:**

Update lines 25-26:
```lua
local autoRollButton = diceFrame:FindFirstChild("AutoRoll")
local fastRollButton = diceFrame:FindFirstChild("FastRoll")
-- Change "AutoRoll" and "FastRoll" to your actual button names
```

### RollingFrame Not Showing

**Check:**
1. Is RollingFrame.Visible = false initially?
2. Does it have BrainrotImage, Keep, Rarity, Rolling, Name?

**The script shows it when rolling starts.**

### Buttons Not Responding

**Check:**
1. Are they TextButtons (not TextLabels)?
2. Active property enabled?
3. Correct names: "Roll", "Keep", "AutoRoll", "FastRoll"?

---

## 🎨 Customize (Optional)

### Animation Speed

**Flicker faster/slower** (line ~69):
```lua
task.wait(0.08)  -- Change to 0.05 (faster) or 0.15 (slower)
```

### AutoRoll Interval

**Roll more/less often** (line ~145):
```lua
task.wait(5)  -- Change to 3 (faster) or 10 (slower)
```

### Button Colors

**AutoRoll/FastRoll colors when active** (lines ~140, ~162):
```lua
BackgroundColor3 = Color3.fromRGB(0, 200, 0)  -- Green when on
BackgroundColor3 = Color3.fromRGB(100, 100, 100)  -- Gray when off
```

### Disable Animations

**No flicker animation:**
```lua
-- Comment out lines 66-76 (the for loop in playRollAnimation)
```

**No button bounce:**
```lua
-- Remove animateButton(rollButton) calls
```

---

## ✅ Final Checklist

Before testing:

- [ ] Script placed in: StarterGui/neww/RollHandler
- [ ] Script is a LocalScript (green icon)
- [ ] DiceFrame exists with Roll button
- [ ] RollingFrame exists with all elements
- [ ] MainServer is running (Events folder exists)
- [ ] No errors in Output

Press Play:

- [ ] See: "✓ RollHandler connected..."
- [ ] Click Roll → Animation plays
- [ ] Result shows in RollingFrame
- [ ] Keep button works
- [ ] AutoRoll toggles (if you have it)
- [ ] FastRoll skips animation (if you have it)

---

## 📊 File Summary

| File | What It Does |
|------|--------------|
| **RollHandler_Clean.lua** | Hooks up your GUI to server |
| **Location** | StarterGui/neww/ (as LocalScript) |
| **Creates GUI?** | NO - uses your existing frames |
| **Lines of code** | ~180 |
| **Dependencies** | DiceFrame, RollingFrame, Events |

---

## 🎯 TL;DR

```
1. StarterGui → neww → Insert LocalScript
2. Name it "RollHandler"
3. Copy code from: src/client/gui/RollHandler_Clean.lua
4. Paste
5. Press Play
6. Done!
```

**That's it! No GUI creation, just connection!** 🚀
