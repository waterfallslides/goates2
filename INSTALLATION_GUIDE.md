# Quick Installation Guide - Food System

## ⚠️ IMPORTANT: Script Types Matter!

In Roblox, there are different script types. Here's what each file should be:

---

## 📁 File Structure & Types

### **ServerScriptService** (or ServerScriptService/FoodSystem folder)

1. **FoodSystemManager** → ⚡ **Script** (runs automatically)
2. **DayNightCycle** → 📦 **ModuleScript**
3. **FoodSpawner** → 📦 **ModuleScript**
4. **PlayerInventory** → 📦 **ModuleScript**

### **ReplicatedStorage/Shared** folder

5. **FoodConfig** → 📦 **ModuleScript**

### **StarterPlayer/StarterPlayerScripts**

6. **FoodCollectionHandler** → 🎮 **LocalScript**
7. **InventoryUI** → 🎮 **LocalScript**

---

## 🔧 Step-by-Step Installation in Roblox Studio

### Step 1: Create Folders

1. In **ServerScriptService**, create a folder: `FoodSystem`
2. In **ReplicatedStorage**, create a folder: `Shared`

### Step 2: Add Server Scripts

In **ServerScriptService/FoodSystem**:

1. **Right-click** → Insert Object → **Script**
   - Name it: `FoodSystemManager`
   - Paste code from `FoodSystemManager.lua`

2. **Right-click** → Insert Object → **ModuleScript**
   - Name it: `DayNightCycle`
   - Paste code from `DayNightCycle.lua`

3. **Right-click** → Insert Object → **ModuleScript**
   - Name it: `FoodSpawner`
   - Paste code from `FoodSpawner.lua`

4. **Right-click** → Insert Object → **ModuleScript**
   - Name it: `PlayerInventory`
   - Paste code from `PlayerInventory.lua`

### Step 3: Add Shared Module

In **ReplicatedStorage/Shared**:

1. **Right-click** → Insert Object → **ModuleScript**
   - Name it: `FoodConfig`
   - Paste code from `FoodConfig.lua`

### Step 4: Add Client Scripts

In **StarterPlayer/StarterPlayerScripts**:

1. **Right-click** → Insert Object → **LocalScript**
   - Name it: `FoodCollectionHandler`
   - Paste code from `FoodCollectionHandler.lua`

2. **Right-click** → Insert Object → **LocalScript**
   - Name it: `InventoryUI`
   - Paste code from `InventoryUI.lua`

3. **Right-click** → Insert Object → **LocalScript**
   - Name it: `InventoryToolSystem`
   - Paste code from `InventoryToolSystem.lua`

4. **Right-click** → Insert Object → **LocalScript**
   - Name it: `InventoryKeyHandler`
   - Paste code from `InventoryKeyHandler.lua`

---

## ✅ Verification Checklist

After installation, verify your hierarchy looks like this:

```
ServerScriptService
└── FoodSystem (Folder)
    ├── FoodSystemManager (Script) ⚡
    ├── DayNightCycle (ModuleScript) 📦
    ├── FoodSpawner (ModuleScript) 📦
    └── PlayerInventory (ModuleScript) 📦

ReplicatedStorage
└── Shared (Folder)
    └── FoodConfig (ModuleScript) 📦

StarterPlayer
└── StarterPlayerScripts
    ├── FoodCollectionHandler (LocalScript) 🎮
    ├── InventoryUI (LocalScript) 🎮
    ├── InventoryToolSystem (LocalScript) 🎮
    └── InventoryKeyHandler (LocalScript) 🎮
```

---

## 🎮 Testing

Press **Play** in Studio and check the **Output** window (View → Output or Ctrl+F9):

You should see:
```
[FoodSystemManager] Initializing Food System...
[PlayerInventory] System initialized!
[FoodSpawner] Initialized with pool size: 50
[DayNightCycle] System started!
[DayNightCycle] Day has started! Duration: 300 seconds
[FoodSpawner] Spawning 30 food items...
[FoodCollectionHandler] Client-side food collection initialized!
[InventoryUI] Inventory and stats UI initialized!
```

---

## 🐛 Common Errors & Fixes

### Error: "Attempted to call require with invalid argument(s)"
**Cause:** You created a **Script** instead of a **ModuleScript**
**Fix:** Delete the script, create a **ModuleScript**, paste code again

### Error: "Shared is not a valid member of ServerScriptService"
**Cause:** FoodConfig is in the wrong location
**Fix:** Make sure FoodConfig is in **ReplicatedStorage/Shared/** (not ServerScriptService)

### Error: "FoodConfig is not a valid member of Folder"
**Cause:** Wrong script type (Script instead of ModuleScript)
**Fix:** Delete and recreate as ModuleScript

### Error: No food spawning
**Cause:** FoodSystemManager might not be running
**Fix:** Make sure it's a regular **Script** (not ModuleScript), and it's in ServerScriptService

---

## 📝 Quick Reference

| File Name | Type | Location |
|-----------|------|----------|
| FoodSystemManager | ⚡ Script | ServerScriptService/FoodSystem |
| DayNightCycle | 📦 ModuleScript | ServerScriptService/FoodSystem |
| FoodSpawner | 📦 ModuleScript | ServerScriptService/FoodSystem |
| PlayerInventory | 📦 ModuleScript | ServerScriptService/FoodSystem |
| FoodConfig | 📦 ModuleScript | ReplicatedStorage/Shared |
| FoodCollectionHandler | 🎮 LocalScript | StarterPlayerScripts |
| InventoryUI | 🎮 LocalScript | StarterPlayerScripts |
| InventoryToolSystem | 🎮 LocalScript | StarterPlayerScripts |
| InventoryKeyHandler | 🎮 LocalScript | StarterPlayerScripts |

---

Good luck! 🚀
