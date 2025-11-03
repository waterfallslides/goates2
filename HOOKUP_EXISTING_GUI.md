# Hook Up Your Existing Rolling GUI

## 🎯 Quick Setup

You already have the GUI built! Just need to connect it to the rolling system.

---

## 📁 Your GUI Structure

```
DiceFrame/ (or parent of RollingFrame)
└── RollingFrame/
    ├── BrainrotImage (ImageLabel)
    ├── Keep (TextButton)
    ├── Roll (TextButton)
    ├── Rarity (TextLabel)
    ├── Rolling (TextLabel) - shows name
    └── Name (TextLabel)
```

---

## ✅ How to Connect

### Step 1: Add the Handler Script

```
1. Find your RollingFrame in StarterGui
2. Go to its parent (probably DiceFrame)
3. Add a LocalScript (or replace existing "Rolling" script)
4. Name it "RollHandler" (or keep "Rolling")
5. Copy code from: src/client/gui/RollHandler_Updated.lua
6. Paste into the script
```

**Location:** `StarterGui/neww/DiceFrame/RollHandler` (LocalScript)

---

## 🎨 Simple Animations Added

### Button Click Animation
- Quick shrink on click
- Bounces back
- Feels responsive

### Button Hover Animation
- Slight grow when hovering
- Shrink when mouse leaves
- Smooth transitions

### Roll Animation
- Flickers through 15 random brainrots
- Each flicker has small pulse
- Creates "slot machine" effect
- Total duration: ~2.3 seconds

### Result Pop-In
- Brainrot image scales from 0 to full size
- "Back" easing for slight overshoot
- Smooth and satisfying
- Rarity label fades in with glow

---

## 🔧 How It Works

### When You Click "Roll":
1. ✅ Button bounces (animation)
2. ✅ Sends request to server
3. ✅ Shows "ROLLING..." text
4. ✅ Plays flicker animation (15 frames)
5. ✅ Server sends result
6. ✅ Image pops in with result
7. ✅ Shows Keep button, hides Roll button

### When You Click "Keep":
1. ✅ Button bounces (animation)
2. ✅ Sends brainrot to server
3. ✅ Adds to your base
4. ✅ Resets GUI for next roll

---

## 📝 Script Customization

### Change Animation Speed

**Flicker speed** (line ~50):
```lua
task.wait(0.08)  -- Change to 0.05 for faster, 0.15 for slower
```

**Button bounce** (line ~31):
```lua
TweenInfo.new(0.1)  -- Change to 0.05 for faster, 0.2 for slower
```

### Change Hover Effect Size

**Line ~40:**
```lua
Size = button.Size + UDim2.new(0.02, 0, 0.02, 0)  -- Change 0.02 to bigger/smaller
```

### Disable Specific Animations

**No flicker animation:**
```lua
-- Comment out line ~67-84 (the for loop)
-- Just call showResult(result) directly
```

**No hover effects:**
```lua
-- Comment out lines ~105-117 (MouseEnter/MouseLeave)
```

**No button bounce:**
```lua
-- Replace animateButton(rollButton) with nothing
```

---

## 🎮 Features Connected

✅ **Roll Button** → Fires to server, triggers animation
✅ **Keep Button** → Sends to server, adds to base
✅ **BrainrotImage** → Shows result with animation
✅ **Name/Rolling Labels** → Display brainrot name
✅ **Rarity Label** → Shows rarity + frame, color-coded
✅ **Animations** → Simple, smooth, not crazy

---

## 🔍 Troubleshooting

### Script Can't Find RollingFrame

**Error:** "RollingFrame is not a valid member"

**Fix:** Update line 19:
```lua
-- If RollingFrame is directly in script.Parent:
local rollingFrame = script.Parent:WaitForChild("RollingFrame")

-- If it's somewhere else:
local rollingFrame = script.Parent.Parent:WaitForChild("RollingFrame")
-- Or:
local rollingFrame = player.PlayerGui.neww.DiceFrame.RollingFrame
```

### Buttons Not Responding

**Check:**
1. Are Roll and Keep TextButtons (not TextLabels)?
2. Do they have the exact names "Roll" and "Keep"?
3. Is Active property enabled on buttons?

**Fix:**
```lua
-- Add after getting buttons (line ~26):
rollButton.Active = true
keepButton.Active = true
```

### Animation Too Fast/Slow

**Adjust timing:**
```lua
-- Line ~50 (flicker speed)
task.wait(0.08)  -- Your preference: 0.05-0.2

-- Line ~65 (pop-in duration)
TweenInfo.new(0.3, ...)  -- Your preference: 0.2-0.5
```

---

## ⚙️ AutoRoll & FastRoll (Optional)

If you have AutoRoll/FastRoll buttons in DiceFrame, add this:

```lua
-- After line 27, add:
local autoRollButton = script.Parent:FindFirstChild("AutoRollButton")
local fastRollButton = script.Parent:FindFirstChild("FastRollButton")

-- Add at end of script:
local autoRollEnabled = false
local fastRollEnabled = false

if autoRollButton then
	autoRollButton.MouseButton1Click:Connect(function()
		autoRollEnabled = not autoRollEnabled

		-- Visual feedback
		autoRollButton.BackgroundColor3 = autoRollEnabled
			and Color3.fromRGB(0, 200, 0)
			or Color3.fromRGB(100, 100, 100)

		-- Tell server
		local toggleAuto = events:FindFirstChild("ToggleAutoRoll")
		if toggleAuto then toggleAuto:FireServer(autoRollEnabled) end

		-- Auto roll loop
		if autoRollEnabled then
			task.spawn(function()
				while autoRollEnabled do
					task.wait(5) -- 5 seconds between rolls
					if not isRolling and autoRollEnabled then
						rollBrainrotEvent:FireServer()
					end
				end
			end)
		end
	end)
end

if fastRollButton then
	fastRollButton.MouseButton1Click:Connect(function()
		fastRollEnabled = not fastRollEnabled

		fastRollButton.BackgroundColor3 = fastRollEnabled
			and Color3.fromRGB(0, 200, 0)
			or Color3.fromRGB(100, 100, 100)

		local toggleFast = events:FindFirstChild("ToggleFastRoll")
		if toggleFast then toggleFast:FireServer(fastRollEnabled) end
	end)
end

-- Update playRollAnimation function to check fastRollEnabled:
-- if fastRollEnabled then skip animation
```

---

## 📊 Testing Checklist

- [ ] Click Roll button → Animation plays
- [ ] Flicker shows random brainrots
- [ ] Result pops in smoothly
- [ ] Keep button appears after roll
- [ ] Click Keep → Adds to base
- [ ] Hover over buttons → Slight grow effect
- [ ] Click buttons → Bounce effect
- [ ] Rarity shows correct color
- [ ] No errors in Output

---

## 🎯 What You Get

**Simple, Clean Animations:**
- ✨ Button hover (grow/shrink)
- 🎬 Button click bounce
- 🎰 Roll flicker effect (slot machine style)
- 📈 Result pop-in with overshoot
- 🌈 Rarity color glow

**All using your existing GUI!** No new elements created.

---

## 💡 Pro Tip

The animations use TweenService which is smooth and performant. If you want different effects:

**Bounce:** `Enum.EasingStyle.Back`
**Smooth:** `Enum.EasingStyle.Quad`
**Elastic:** `Enum.EasingStyle.Elastic`
**Linear:** `Enum.EasingStyle.Linear`

Change on line 65:
```lua
TweenInfo.new(0.3, Enum.EasingStyle.Back, ...)
--                 ^^^^ Change this
```

---

**Ready to test!** Just add the script and press Play! 🚀
