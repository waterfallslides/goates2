# ✅ Using Your Own Food Models - ALREADY SET UP!

## Good News! 🎉

The food system is **already configured** to use your own custom models! You don't need to change any code - just add your models to a folder and the system will automatically use them.

---

## Quick Start (3 Steps)

### Step 1: Create the Folder
In **ReplicatedStorage**, create a folder named exactly: **`FoodModels`**

### Step 2: Add Your Food Models
Put your 5 food models/parts inside **ReplicatedStorage/FoodModels** with these **exact names**:

| Model Name | Required Name |
|------------|---------------|
| Your bread model | `Bread` |
| Your apple model | `Apple` |
| Your meat model | `CookedMeat` |
| Your canned food model | `CannedFood` |
| Your water bottle model | `WaterBottle` |

### Step 3: Done!
That's it! The system will automatically find and use your models when spawning food.

---

## Important Model Requirements

### ✅ Your food can be:

1. **Single Part** - Just a Part or MeshPart (easiest!)
2. **Model** - Multiple parts grouped together

### ✅ Requirements:

1. **If it's a Model:**
   - Set a PrimaryPart (right-click model → Set PrimaryPart)
   - Choose the main/center part

2. **If it's a single Part/MeshPart:**
   - No PrimaryPart needed! Just add it directly
   - Make sure `CanCollide = true`
   - Make sure `Anchored = false`

3. **All food:**
   - Will spawn on the ground automatically (uses raycast)
   - Should have `CanCollide = true` to not fall through floor
   - Should have `Anchored = false` to allow physics

### ⚠️ DO NOT add these (auto-added by system):
- ClickDetector ❌
- ProximityPrompt ❌
- BillboardGui (label above food) ❌
- Attributes ❌

The system adds these automatically!

---

## Example Structure

```
ReplicatedStorage
└── FoodModels (Folder you create)
    ├── Bread (MeshPart, Part, or Model)
    ├── Apple (MeshPart, Part, or Model)
    ├── CookedMeat (MeshPart, Part, or Model)
    ├── CannedFood (MeshPart, Part, or Model)
    └── WaterBottle (MeshPart, Part, or Model)
```

**Works with:**
- ✅ Single MeshPart (most common for imported models)
- ✅ Single Part
- ✅ Model with multiple parts
- ✅ Unions

---

## Testing

1. Add your 5 food models to **ReplicatedStorage/FoodModels**
2. Press **Play**
3. Check Output - you should see:
   ```
   [FoodSpawner] Using custom food models from ReplicatedStorage/FoodModels
   ```
4. Wait for day to start - your models will spawn!

---

## If You Don't Have Models Yet

**No problem!** The system has a fallback:
- If **FoodModels** folder doesn't exist, it creates simple colored cubes
- You can test the system immediately
- Add your custom models later whenever you're ready

You'll see this message:
```
[FoodSpawner] FoodModels folder not found! Using default parts.
```

---

## Simple Example: Creating a Basic Apple

```lua
-- Create in Roblox Studio Command Bar or Script:

-- 1. Create the model
local apple = Instance.new("Model")
apple.Name = "Apple"

-- 2. Create the main part
local part = Instance.new("Part")
part.Name = "ApplePart"
part.Size = Vector3.new(1.5, 1.5, 1.5)
part.Shape = Enum.PartType.Ball
part.Color = Color3.fromRGB(220, 20, 60)  -- Red
part.CanCollide = true
part.Anchored = false
part.Parent = apple

-- 3. Set PrimaryPart
apple.PrimaryPart = part

-- 4. Move to correct location
apple.Parent = game.ReplicatedStorage.FoodModels

-- Done! System will now use this model for Apple
```

---

## Using MeshParts / Imported Models

If you have models from Blender or the Roblox Toolbox:

1. **Import/insert your model** into Workspace
2. **Group it as a Model** (if not already)
3. **Set the main MeshPart as PrimaryPart**
4. **Rename the model** to one of the food names
5. **Move to ReplicatedStorage/FoodModels**

---

## Troubleshooting

### "FoodModels folder not found"
- **Solution:** Create folder named exactly `FoodModels` (case-sensitive) in ReplicatedStorage

### Food doesn't spawn / invisible
- **Solution:** Make sure model/part is named exactly: `Bread`, `Apple`, `CookedMeat`, `CannedFood`, or `WaterBottle`

### "Missing PrimaryPart" warning
- **If using a Model:** Right-click model → Set PrimaryPart → choose main part
- **If using a single MeshPart/Part:** This is fine! System handles it automatically

### Food falls through floor
- **Solution:** Set `CanCollide = true` on your part/MeshPart
- **Note:** System uses raycast to find ground, spawns 2 studs above it

### Food spawns in the air
- **This is normal!** Food falls to the ground naturally
- Make sure your map has a floor/terrain for food to land on

### Food spawns too close together
- System now uses 10 stud minimum spacing
- Increase `MIN_SPAWN_DISTANCE` in FoodSpawner.lua if needed

### Wrong food spawns
- **Solution:** Check that each model/part has the correct unique name

---

## Where to Get Food Models

- **Roblox Toolbox** - Search "food", "bread", "apple" (Insert → Toolbox)
- **Free Models** - Many creators share food models
- **Create your own** - Use Parts, Unions, or import from Blender

---

## Advanced: Size & Appearance

You can make your models any size! The system will use them as-is.

**Recommended sizes:**
- Small foods (apple, water): 1-2 studs
- Medium foods (bread, canned): 2-3 studs
- Large foods (meat): 2-4 studs

**Add effects to your models:**
- ParticleEmitters (steam, sparkles)
- PointLights (glowing)
- Textures/Decals
- Multiple colored parts

All effects will be preserved when spawned!

---

## Summary

✅ System is already set up to use your models
✅ Just add them to ReplicatedStorage/FoodModels
✅ Use exact names: Bread, Apple, CookedMeat, CannedFood, WaterBottle
✅ Set PrimaryPart on each model
✅ System auto-adds ClickDetector, ProximityPrompt, Labels
✅ Falls back to simple parts if models not found

**That's it! No code changes needed.** 🎮
