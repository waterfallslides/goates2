# 🎨 Setup Brainrot Models - 3D ViewportFrame Images

Your rolling GUI and Index now display **actual 3D models** of brainrots instead of static images!

## 📦 Required Structure

Place your brainrot models in **ServerStorage** with this structure:

```
ServerStorage/
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
ServerStorage/
└── Brainrots/
    ├── SkibidiToilet (Model)
    ├── Griddy (Model)
    ├── OhioFinal (Model)
    ├── Sigma (Model)
    └── ... etc
```

## 🔄 How It Works (ServerStorage → ReplicatedStorage)

**Why ServerStorage?**
- Your base system uses ServerStorage/Brainrots/ to spawn brainrots on bases
- The server automatically **replicates** these models to ReplicatedStorage on startup
- Clients can then access them for ViewportFrames

**Automatic Replication:**
1. Server starts → BrainrotModelReplicator runs
2. Copies all models from ServerStorage/Brainrots/ → ReplicatedStorage/BrainrotModels/
3. Removes scripts from copies (clients don't need them)
4. Maintains folder structure (rarity subfolders)
5. Clients now have access for ViewportFrames!

**You don't need to do anything!** The server handles replication automatically. ✅

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
1. **Server replicates** models from ServerStorage → ReplicatedStorage/BrainrotModels/
2. **Client finds** the model in ReplicatedStorage/BrainrotModels/
3. **Clones** it into a ViewportFrame
4. **Positions** a camera to view it from the front
5. **Displays** it in your rolling GUI and Index!

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
1. Model exists in **ServerStorage/Brainrots/**
2. Server successfully replicated models (check Output for "✅ Replicated X brainrot models")
3. Model name **exactly matches** ID in BrainrotData.lua (case-sensitive!)
4. It's a Model, not a Folder or Part

**Fix:** Rename your model or update BrainrotData.lua

### "BrainrotModels folder not found in ReplicatedStorage"

**Check:**
1. Models exist in ServerStorage/Brainrots/
2. MainServer is running (look for "✅ Replicated X brainrot models" in Output)
3. BrainrotModelReplicator loaded successfully

**Fix:** Make sure ServerStorage/Brainrots/ folder exists with models inside

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
   ServerStorage → Brainrots → SkibidiToilet (Model)
   ```

2. **Play game**

3. **Check Output - Server should show:**
   ```
   📦 Replicating brainrot models to ReplicatedStorage...
     ✓ Copied: SkibidiToilet
   ✅ Replicated 1 brainrot models to ReplicatedStorage/BrainrotModels/
   ```

4. **Click Roll**

5. **Check Output - Client should show:**
   ```
   ✓ Viewport created for: SkibidiToilet
   ✨ Result shown: Skibidi Toilet - Common
   ```

6. **Should see:** 3D model displayed in RollingFrame!

7. **Open Index GUI:** Models should also appear in your collection!

## 🎯 Benefits Over Static Images

✅ **No manual screenshots needed**
✅ **Always up-to-date** - edit model, see changes immediately
✅ **3D rotation possible** (add rotation animation if desired)
✅ **No asset upload required** - no waiting for moderation
✅ **Dynamic lighting** - can add lights to viewport
✅ **Consistent framing** - automatic camera positioning

## 📝 Next Steps

1. Create **ServerStorage/Brainrots/** folder
2. Place all your brainrot models inside (as Models)
3. Organize by rarity (optional): Common/, Rare/, Epic/, etc.
4. Name them to match IDs in BrainrotData.lua
5. Play game - server automatically replicates models
6. Test rolling and Index - should see 3D models!

## 🎯 Where Models Are Used

✅ **Rolling GUI** - Shows 3D model when you roll
✅ **Index GUI** - Shows 3D models in your collection
✅ **Player Bases** - Server spawns actual models from ServerStorage

**One location (ServerStorage), three uses!** No more managing image assets. 🚀
