# Fix Rolling Issues

## 🐛 Issues You Had:
1. ❌ Clicking Roll doesn't open RollingFrame
2. ❌ AutoRoll and FastRoll buttons don't work
3. ❌ Keep button and labels always visible (should be hidden until roll completes)

## ✅ Fixed Script: RollingScript_Fixed.lua

---

## 🔧 How to Fix

### Step 1: Remove Old Script

```
1. Go to: StarterGui → neww → DiceFrame
2. Find the "Rolling" LocalScript
3. Right-click → Delete (or just replace the code)
```

### Step 2: Add Fixed Script

```
1. If you deleted it: Insert Object → LocalScript, name it "Rolling"
2. Open: src/client/gui/RollingScript_Fixed.lua
3. Copy ALL the code
4. Paste into DiceFrame/Rolling
5. Save
```

---

## ✅ What the Fixed Script Does

### On Load:
- ✅ Hides RollingFrame
- ✅ Hides Keep button
- ✅ Clears all labels

### When You Click "Roll" in DiceFrame:
1. ✅ Shows RollingFrame
2. ✅ Shows "ROLLING..." text
3. ✅ Hides Keep button (not ready yet)
4. ✅ Sends request to server
5. ✅ Plays flicker animation
6. ✅ Result comes from server
7. ✅ Shows brainrot image
8. ✅ Shows brainrot name in Rolling label
9. ✅ Shows Keep button NOW

### When You Click "Keep" in RollingFrame:
1. ✅ Sends to server
2. ✅ Hides RollingFrame
3. ✅ Hides Keep button
4. ✅ Ready for next roll

### AutoRoll Button:
- ✅ Click → Toggles on/off
- ✅ When ON: Button turns green
- ✅ When ON: Automatically clicks Roll every 5 seconds
- ✅ When OFF: Button turns gray, stops rolling

### FastRoll Button:
- ✅ Click → Toggles on/off
- ✅ When ON: Button turns green, skips flicker animation
- ✅ When OFF: Button turns gray, plays animation

---

## 🔍 Debug Output

After adding the script, press Play and check Output:

**You should see:**
```
✓ RollingScript connected to DiceFrame and RollingFrame
  - Roll button: Found
  - Keep button: Found
  - AutoRoll button: Found (or NOT FOUND if you don't have it)
  - FastRoll button: Found (or NOT FOUND if you don't have it)
```

**When you click Roll:**
```
Roll button clicked!
```

**When server responds:**
```
Received roll result: SkibidiToilet
```

**When you click Keep:**
```
Keep button clicked!
```

**When you toggle AutoRoll:**
```
AutoRoll toggled: true
```

**When AutoRoll triggers:**
```
AutoRoll triggered!
```

---

## 🐛 If Buttons Still Don't Work

### Check Button Names

Your buttons in DiceFrame might have different names. Check:

**In DiceFrame:**
- Is the roll button named "Roll"? (line 28)
- Is AutoRoll button named "AutoRoll"? (line 29)
- Is FastRoll button named "FastRoll"? (line 30)

**In RollingFrame:**
- Is keep button named "Keep"? (line 36)
- Is the name label named "Rolling"? (line 38)

**If names are different, update the script:**

```lua
-- Line 28-30 in DiceFrame:
local rollButton = diceFrame:WaitForChild("Roll")  -- Change "Roll" to your button name
local autoRollButton = diceFrame:FindFirstChild("AutoRoll")  -- Change "AutoRoll"
local fastRollButton = diceFrame:FindFirstChild("FastRoll")  -- Change "FastRoll"

-- Line 36-39 in RollingFrame:
local keepButton = rollingFrame:WaitForChild("Keep")  -- Change "Keep"
local rollingLabel = rollingFrame:WaitForChild("Rolling")  -- Change "Rolling"
```

---

## 🎯 Expected Flow

### Initially:
- RollingFrame: Hidden ❌
- Keep button: Hidden ❌
- DiceFrame: Visible ✅
- Roll button: Visible ✅

### Click Roll:
- RollingFrame: Shows ✅
- Text says: "ROLLING..." ✅
- Image: Flickers 15 times ✅
- Keep button: Still hidden ❌

### Result Arrives:
- Image: Shows brainrot ✅
- Rolling label: Shows name ✅
- Rarity label: Shows rarity + frame ✅
- Keep button: NOW appears ✅

### Click Keep:
- RollingFrame: Hides ❌
- Keep button: Hides ❌
- Back to initial state

---

## ✅ Test Checklist

After adding fixed script:

- [ ] Press Play
- [ ] Check Output for "✓ RollingScript connected..."
- [ ] Click Roll in DiceFrame
- [ ] RollingFrame appears
- [ ] See "ROLLING..." text
- [ ] See flicker animation
- [ ] Result shows
- [ ] Keep button appears NOW (not before)
- [ ] Click Keep
- [ ] RollingFrame hides
- [ ] Click AutoRoll → Button turns green
- [ ] Rolls automatically every 5 seconds
- [ ] Click FastRoll → Button turns green
- [ ] Next roll skips animation

---

## 🎯 TL;DR

```
1. Delete old "Rolling" script in DiceFrame
2. Add RollingScript_Fixed.lua as "Rolling" in DiceFrame
3. Test: Click Roll → RollingFrame appears → Keep appears after roll
```

**This properly shows/hides elements and makes buttons work!** 🚀
