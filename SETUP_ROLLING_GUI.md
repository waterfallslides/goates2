# ✅ Setup Rolling GUI - Simple 2-Minute Fix

## 🎯 The Problem

Your rolling GUI exists but buttons don't work because there's no script connecting them to the server.

## ✅ The Solution

ONE script that connects YOUR existing GUI to the server with:
- ✅ Proper show/hide logic for RollingFrame
- ✅ Keep button only appears AFTER roll completes
- ✅ Clear error messages if elements are missing
- ✅ AutoRoll and FastRoll support (optional)
- ✅ Simple animations (bounce, flicker, pop)
- ✅ Zero GUI creation - uses YOUR GUI only

---

## 🔧 Installation (2 Minutes)

### Step 1: Add The Script

```
1. Go to: StarterGui → neww → DiceFrame
2. Right-click on DiceFrame
3. Insert Object → LocalScript
4. Name it: "Rolling"
5. Open file: src/client/gui/RollingScript.lua
6. Copy ALL the code
7. Paste into your "Rolling" script in Studio
8. Save
```

### Step 2: Test

```
1. Press Play in Studio
2. Check Output window - you should see:
   ✅ RollingScript fully connected and ready!
3. Click Roll button
4. RollingFrame should appear with flicker animation
5. Result shows → Keep button appears
6. Click Keep → RollingFrame hides
```

**That's it!** 🚀

---

## 📋 What You'll See in Output

### ✅ If Everything Works:

```
🔧 Starting RollingScript...
  ✓ Events found
  ✓ Modules loaded
📦 DiceFrame: DiceFrame
  ✓ Roll found: TextButton
  ⚠️ AutoRoll not found (optional) - skipping
  ⚠️ FastRoll not found (optional) - skipping
📦 GUI: neww
  ✓ RollingFrame found: Frame
  ✓ BrainrotImage found: ImageLabel
  ✓ Keep found: TextButton
  ✓ Rarity found: TextLabel
  ✓ Rolling found: TextLabel
  ✓ Name found: TextLabel
✅ All required elements found! Setting up connections...
🎨 UI initialized - RollingFrame hidden, ready to roll!
✅ RollingScript fully connected and ready!
   Click Roll to test!
```

### ❌ If Something is Missing:

```
  ❌ BrainrotImage not found in RollingFrame! Available children:
      - Image (ImageLabel)        <-- Aha! Use "Image" instead
      - Keep (TextButton)
      - Rarity (TextLabel)
      - Rolling (TextLabel)
      - Name (TextLabel)
```

The script will tell you EXACTLY what's wrong!

---

## 🐛 Troubleshooting

### Error: "BrainrotImage not found"

**The script lists available children. Look at the output and find your image element.**

For example, if output shows:
```
Available children:
    - Image (ImageLabel)
```

Then edit the script (line 73) to use "Image" instead of "BrainrotImage":
```lua
local brainrotImage = findOrWarn(rollingFrame, "Image", "ImageLabel", true)
```

### Error: "RollingFrame not found"

Check your GUI structure. The script expects:
```
StarterGui/
└── neww/              ← ScreenGui
    ├── DiceFrame/     ← Frame with buttons
    │   └── Rolling    ← Your script goes HERE
    └── RollingFrame/  ← Frame that shows during roll
```

If your frame has a different name, update line 72:
```lua
local rollingFrame = findOrWarn(gui, "YourFrameName", "Frame", true)
```

### Error: "Events folder not found"

**Server isn't running!** The server creates the Events folder.

Fix: Make sure MainServer.lua is running in ServerScriptService/Server/

### Buttons Don't Respond

Check button names match:
- Roll button must be named "Roll" (line 68)
- Keep button must be named "Keep" (line 74)
- AutoRoll button must be named "AutoRoll" (line 69)
- FastRoll button must be named "FastRoll" (line 70)

Update the script if your buttons have different names.

---

## 🎮 How It Works

### Initially:
- ❌ RollingFrame: Hidden
- ❌ Keep button: Hidden
- ✅ DiceFrame: Visible with Roll button

### Click Roll:
1. Roll button bounces
2. RollingFrame appears
3. "ROLLING..." text shows
4. Keep button still hidden ❌
5. Flicker animation plays (15 frames)
6. Server sends result
7. Result shows in image and labels
8. Keep button NOW appears ✅

### Click Keep:
1. Keep button bounces
2. Server saves brainrot to base
3. RollingFrame hides
4. Keep button hides
5. Ready for next roll

### AutoRoll (Optional):
- Click → Toggles on/off
- Green = ON, auto-rolls every 5 seconds
- Gray = OFF

### FastRoll (Optional):
- Click → Toggles on/off
- Green = ON, skips flicker animation
- Gray = OFF

---

## 📊 Your GUI Structure

**Required Structure:**
```
StarterGui/
└── neww/ (ScreenGui)
    ├── DiceFrame/ (Frame)
    │   ├── Rolling (LocalScript) ← THE SCRIPT GOES HERE
    │   ├── Roll (TextButton) ← Required
    │   ├── AutoRoll (TextButton) ← Optional
    │   └── FastRoll (TextButton) ← Optional
    │
    └── RollingFrame/ (Frame)
        ├── BrainrotImage (ImageLabel) ← Required
        ├── Keep (TextButton) ← Required
        ├── Rarity (TextLabel) ← Required
        ├── Rolling (TextLabel) ← Required
        └── Name (TextLabel) ← Required
```

**Script location:** `DiceFrame/Rolling`

---

## ✅ What This Script Does

- ✅ Connects YOUR Roll button → Server
- ✅ Connects YOUR Keep button → Server
- ✅ Shows/hides YOUR RollingFrame properly
- ✅ Updates YOUR image when result comes
- ✅ Updates YOUR labels (Rarity, Rolling, Name)
- ✅ Simple bounce animation on buttons
- ✅ Simple flicker on YOUR image
- ✅ AutoRoll and FastRoll support (if you have those buttons)

## ❌ What This Script Does NOT Do

- ❌ Create frames
- ❌ Create buttons
- ❌ Create labels
- ❌ Create images
- ❌ Create ScreenGui
- ❌ Create ANYTHING

**100% uses YOUR existing GUI!**

---

## 🎯 TL;DR

```
1. Add src/client/gui/RollingScript.lua to DiceFrame as "Rolling" LocalScript
2. Press Play
3. Check Output for success message or errors
4. If errors, script tells you exactly what's missing
5. Fix element names if needed
6. Working!
```

**One script. Zero GUI creation. YOUR GUI works.** 🚀
