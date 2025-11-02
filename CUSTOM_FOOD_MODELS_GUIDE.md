# Using Custom Food Models Guide

## Overview

The food system now supports **your own custom 3D models** instead of generating simple parts! You can create beautiful food models in Blender, import them to Roblox, and they'll automatically work with the collection system.

---

## Quick Setup

### Step 1: Create FoodModels Folder

1. In **ReplicatedStorage**, create a folder named: **`FoodModels`**

### Step 2: Add Your Food Models

Inside the **FoodModels** folder, add models (or parts) with these **exact names**:

- `Bread`
- `Apple`
- `CookedMeat`
- `CannedFood`
- `WaterBottle`

**Important:** The names must match exactly (case-sensitive)!

---

## Creating Food Models

### Option 1: Using Roblox Parts

1. Create a part or union in Roblox Studio
2. Shape/color it to look like food
3. Name it with one of the food names above
4. Move it into **ReplicatedStorage/FoodModels/**

### Option 2: Using Models (Recommended)

1. Create a **Model** in Workspace
2. Add parts, meshes, textures to make it look like food
3. **Set a PrimaryPart** (right-click model → Set PrimaryPart)
4. Name the model with one of the food names above
5. Move it into **ReplicatedStorage/FoodModels/**

### Option 3: Importing from Blender

1. Export your Blender model as `.fbx` or `.obj`
2. Import to Roblox via Asset Manager
3. Place imported MeshPart into a Model
4. Set the MeshPart as the PrimaryPart
5. Name and move to **ReplicatedStorage/FoodModels/**

---

## Important Requirements

### ✅ Every food model MUST have:

1. **A PrimaryPart** (if it's a Model)
   - Right-click the model
   - Select "Set PrimaryPart"
   - Choose the main part of your food

2. **CanCollide = true** on the PrimaryPart
   - So it doesn't fall through the floor

3. **Anchored = false** on all parts
   - So food can fall/move naturally

### ⚠️ DO NOT add these (system adds automatically):
- ClickDetector
- ProximityPrompt
- BillboardGui
- FoodType attribute

The system will automatically add these!

---

## Example Structure

```
ReplicatedStorage
└── FoodModels (Folder)
    ├── Bread (Model or Part)
    │   └── PrimaryPart (MeshPart or Part)
    ├── Apple (Model or Part)
    │   └── PrimaryPart (MeshPart or Part)
    ├── CookedMeat (Model or Part)
    │   └── PrimaryPart (MeshPart or Part)
    ├── CannedFood (Model or Part)
    │   └── PrimaryPart (MeshPart or Part)
    └── WaterBottle (Model or Part)
        └── PrimaryPart (MeshPart or Part)
```

---

## Testing Your Models

1. Place your models in **ReplicatedStorage/FoodModels/**
2. Start the game (Play)
3. Check Output for: `[FoodSpawner] Using custom food models from ReplicatedStorage/FoodModels`
4. Wait for day to start
5. Your custom models should spawn around the map!

---

## Fallback System

If you **don't** create a FoodModels folder, the system will:
- Create simple colored cubes/blocks
- Add sparkle effects
- Still work perfectly fine

This lets you test the system before creating fancy models!

---

## Troubleshooting

### "FoodModels folder not found" warning
**Solution:** Create the folder in ReplicatedStorage and name it exactly `FoodModels`

### Food model spawns but can't be clicked
**Solution:** Make sure your model has a PrimaryPart set

### Food falls through the floor
**Solution:** Set `CanCollide = true` on the PrimaryPart

### Food doesn't spawn at all
**Solution:** Check the name matches exactly: `Bread`, `Apple`, `CookedMeat`, `CannedFood`, `WaterBottle`

### Model looks wrong when spawned
**Solution:** Check that PrimaryPart is set to the main/center part of your model

---

## Advanced: Adding Special Effects

You can add effects to your models that will persist when spawned:

### Particles
```
Add ParticleEmitter to your model parts
```

### Sounds
```
Add Sound objects to PrimaryPart (they'll play on collection)
```

### Lights
```
Add PointLight or SurfaceLight for glowing effects
```

### Animations
```
Use TweenService in a Script (not LocalScript) attached to model
```

---

## Tips for Great Looking Food

1. **Scale appropriately** - Food should be 1-3 studs in size
2. **Use textures** - Add SurfaceAppearance for realistic looks
3. **Add details** - Small parts for steam, crumbs, etc.
4. **Color variety** - Make different rarities visually distinct
5. **Test in daylight** - Check how it looks with different lighting

---

## Where to Find Food Models

- **Roblox Toolbox** - Search for "food", "bread", "apple", etc.
- **Blender Models Lab** - Free 3D food models
- **TurboSquid** - Professional models (paid)
- **Create your own** - Most rewarding!

---

## Example: Simple Apple Model

```lua
-- Create in Command Bar or Script:
local apple = Instance.new("Model")
apple.Name = "Apple"

local part = Instance.new("Part")
part.Name = "PrimaryPart"
part.Size = Vector3.new(1.5, 1.5, 1.5)
part.Shape = Enum.PartType.Ball
part.Color = Color3.fromRGB(220, 20, 60)  -- Red
part.Material = Enum.Material.SmoothPlastic
part.CanCollide = true
part.Anchored = false
part.Parent = apple

-- Add stem
local stem = Instance.new("Part")
stem.Size = Vector3.new(0.2, 0.5, 0.2)
stem.Color = Color3.fromRGB(101, 67, 33)  -- Brown
stem.Position = part.Position + Vector3.new(0, 1, 0)
stem.Parent = apple

apple.PrimaryPart = part
apple.Parent = game.ReplicatedStorage.FoodModels
```

---

## Next Steps

1. Create your 5 food models
2. Place them in ReplicatedStorage/FoodModels
3. Set PrimaryParts
4. Test in game
5. Adjust sizes/colors as needed
6. Add special effects (optional)

Have fun creating! 🍞🍎🥫💧🍖
