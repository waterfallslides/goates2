# 🎨 Setup Brainrot Models - 3D ViewportFrame Images

Your rolling GUI now displays **actual 3D models** of brainrots instead of static images!

## 📦 Required Structure

Place your brainrot models in **ReplicatedStorage** with this structure:

```
ReplicatedStorage/
└── Brainrots/           ← Create this folder
    ├── Common/          ← Optional: Organize by rarity
    │   ├── SkibidiToilet (Model)
    │   └── Griddy (Model)
    ├── Rare/
    │   ├── OhioFinal (Model)
    │   └── Sigma (Model)
    ├── Epic/
    │   ├── Rizz (Model)
    │   └── Gyatt (Model)
    ├── Legendary/
    │   ├── Fanum (Model)
    │   └── Mewing (Model)
    ├── Mythic/
    │   └── Sussy (Model)
    ├── Secret/
    │   └── Edging (Model)
    └── BrainrotGod/
        └── BrainrotGod (Model)
```

**OR** place them directly in Brainrots/ without subfolders:

```
ReplicatedStorage/
└── Brainrots/
    ├── SkibidiToilet (Model)
    ├── Griddy (Model)
    ├── OhioFinal (Model)
    ├── Sigma (Model)
    └── ... etc
```

## 📋 Model Requirements

Each brainrot should be a **Model** containing:
- ✅ One or more Parts/MeshParts
- ✅ Properly positioned (centered)
- ✅ Named exactly as the ID in BrainrotData.lua

### Model Naming (IMPORTANT!)

The model names **must match** the IDs in `src/replicated/modules/BrainrotData.lua`:

```lua
{
    ID = "SkibidiToilet",  ← Model must be named "SkibidiToilet"
    DisplayName = "Skibidi Toilet",
    Rarity = "Common",
    ImageId = "rbxassetid://0"  ← No longer needed!
}
```

## 🎥 How It Works

The system automatically:
1. **Finds** the model in ReplicatedStorage/Brainrots/
2. **Clones** it into a ViewportFrame
3. **Positions** a camera to view it from the front
4. **Displays** it in your rolling GUI

### Camera Positioning

The camera automatically:
- Views the model from the **front** (negative LookVector direction)
- **Centers** on the model's bounding box
- **Zooms** to fit the entire model (distance = max size × 2.5)
- Uses **40° field of view** for better framing

## 🎨 Model Best Practices

### 1. Center Your Models
Make sure the model's pivot/origin is centered:
```
Right-click model → Set PivotPoint → Center
```

### 2. Face Forward
Models should face **forward** (negative Z direction) so the camera sees the front.

### 3. Appropriate Size
Models can be any size - the camera auto-adjusts. But keep them reasonable:
- **Too small:** Details might be hard to see
- **Too large:** May clip outside viewport
- **Recommended:** 5-20 studs in the largest dimension

### 4. Optimize Parts
Since these are cloned frequently:
- ✅ Use as few parts as possible
- ✅ Combine parts where feasible
- ✅ Use MeshParts instead of many individual parts
- ✅ Keep total part count under 50 per model

## 🔧 Customization

Want to adjust how models are displayed? Edit:
```
src/replicated/modules/BrainrotImageGenerator.lua
```

### Change Camera Distance
```lua
local distance = maxSize * 2.5  -- Line ~79
-- Change 2.5 to:
-- 2.0 = closer (zoomed in)
-- 3.0 = farther (zoomed out)
```

### Change Camera Angle
```lua
-- Line ~82-83
local cameraPosition = cf.Position + (cf.LookVector * -distance)
-- Adjust to change angle:
local cameraPosition = cf.Position + (cf.LookVector * -distance) + Vector3.new(0, 5, 0)  -- View from slightly above
```

### Change Field of View
```lua
camera.FieldOfView = 40  -- Line ~86
-- Smaller = zoomed in (30)
-- Larger = wide angle (50)
```

## 🐛 Troubleshooting

### "Model not found for brainrotID"

**Check:**
1. Model exists in ReplicatedStorage/Brainrots/
2. Model name **exactly matches** ID in BrainrotData.lua (case-sensitive!)
3. It's a Model, not a Folder or Part

**Fix:** Rename your model or update BrainrotData.lua

### Viewport shows black/empty

**Check:**
1. Model contains actual Parts/MeshParts
2. Parts have visible textures/colors
3. Model isn't microscopic or huge

**Fix:** Check model size and visibility

### Model appears from wrong angle

**Fix:** Rotate your model in Studio so it faces forward (negative Z direction)

### Model too small/large in viewport

**Fix:** Adjust camera distance multiplier in BrainrotImageGenerator.lua (line ~79)

### Performance issues

**Check:**
1. Each model has reasonable part count (<50 parts)
2. Not cloning too many at once
3. Old viewports are being cleaned up (script does this automatically)

**Fix:** Optimize models by combining parts

## ✅ Testing

1. **Place test model:**
   ```
   ReplicatedStorage → Brainrots → SkibidiToilet (Model)
   ```

2. **Play game**

3. **Click Roll**

4. **Check Output:**
   ```
   ✓ Created viewport for: SkibidiToilet
   ✨ Result shown: Skibidi Toilet - Common
   ```

5. **Should see:** 3D model displayed in RollingFrame!

## 🎯 Benefits Over Static Images

✅ **No manual screenshots needed**
✅ **Always up-to-date** - edit model, see changes immediately
✅ **3D rotation possible** (add rotation animation if desired)
✅ **No asset upload required** - no waiting for moderation
✅ **Dynamic lighting** - can add lights to viewport
✅ **Consistent framing** - automatic camera positioning

## 📝 Next Steps

1. Create ReplicatedStorage/Brainrots/ folder
2. Place all your brainrot models inside (as Models)
3. Name them to match IDs in BrainrotData.lua
4. Test rolling - should see 3D models!

**That's it!** No more managing image assets. 🚀
