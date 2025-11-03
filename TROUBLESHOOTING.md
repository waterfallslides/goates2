# Troubleshooting Guide - RNG Brainrot Stealing Game

This guide helps you fix common errors when running the game in Roblox Studio.

---

## 🔧 Quick Fix Steps

### Step 1: Run SetupVerification Script FIRST

Before running the main game, run the setup verification:

1. Find `SetupVerification.lua` in `ServerScriptService/Server/`
2. Right-click → Run Script
3. Check Output for any ✗ errors
4. Fix all errors before continuing

---

## ❌ Common Errors and Solutions

### Error: "Attempted to call require with invalid argument(s)"

**Location:** MainServer:13 or DataManager:16

**Cause:** Missing modules or incorrect folder structure

**Fix:**
1. Verify folder structure matches EXACTLY:
   ```
   ServerScriptService/
   └── Server/
       ├── Core/ (Folder)
       ├── Systems/ (Folder)
       ├── Leaderboards/ (Folder)
       └── MainServer (Script)
   ```

2. Check that all modules are **ModuleScripts** (blue icon), not Scripts
3. Run SetupVerification.lua to see what's missing

---

### Error: "Infinite yield possible on 'ReplicatedStorage:WaitForChild("Events")'"

**Location:** GUI LocalScripts

**Cause:** MainServer failed to run, so Events folder wasn't created

**Fix:**
1. Check ServerScriptService Output for MainServer errors
2. Fix MainServer issues first (see above)
3. Make sure MainServer is a **Script** (not ModuleScript)
4. The Events folder is created automatically by MainServer

---

### Error: "ProfileService not found"

**Location:** DataManager

**Current Status:** ✅ **FIXED** - Now uses mock fallback

**What happens now:**
- If ProfileService is NOT installed: Uses MockProfileService (NO data persistence, testing only)
- If ProfileService IS installed: Uses real ProfileService (data saves properly)

**To install real ProfileService:**
1. Download from: https://github.com/MadStudioRoblox/ProfileService
2. Place in ServerStorage as "ProfileService" (ModuleScript)
3. Restart game

**Temporary solution for testing:**
- The game will run with MockProfileService
- You'll see: "⚠️ USING MOCK PROFILESERVICE - NO DATA PERSISTENCE!"
- Data will NOT save between sessions
- Perfect for testing game mechanics

---

### Error: "BrainrotData module not found"

**Cause:** Modules folder not in ReplicatedStorage

**Fix:**
1. Create `Modules` folder in ReplicatedStorage
2. Add `BrainrotData` as ModuleScript
3. Add `Config` as ModuleScript
4. Verify with SetupVerification

---

### Error: "Brainrot model not found in ServerStorage"

**Cause:** Missing brainrot models

**Fix:**
1. Create folder structure in ServerStorage:
   ```
   ServerStorage/
   └── Brainrots/
       ├── Common/
       ├── Rare/
       ├── Epic/
       ├── Legendary/
       ├── Mythic/
       ├── Secret/
       └── BrainrotGod/
   ```

2. Add at least one test model to Common folder
3. Update BrainrotData.lua with your model names

---

### Error: "Base not found for player"

**Cause:** No player bases in Workspace

**Fix:**
1. Create `Bases` folder in Workspace
2. Create a test base: `Base[YourUserId]`
   - Get your UserId from: https://www.roblox.com/users/[YourId]/profile
   - Example: `Base123456789`

3. Inside the base, create:
   ```
   Base123456789/
   ├── Floor1/
   │   └── SingersPodium/
   │       ├── 1 (Part)
   │       ├── 2 (Part)
   │       └── ... up to 10
   └── Floor2/
       └── SingersPodium/
           ├── 1 (Part)
           └── ... up to 8
   ```

4. Each numbered part is where brainrots will appear

---

### Error: "SlapTool not found"

**Cause:** Missing slap tool

**Fix:**
1. Create a Tool in ServerStorage named "SlapTool"
2. Add a Part named "Handle" (this is your bat model)
3. Add the SlapTool Script inside the Tool
4. GiveSlapTool will automatically clone it to players

---

### GUI Buttons Don't Work

**Cause:** LocalScripts in wrong location or wrong type

**Fix:**
1. Verify these are **LocalScripts** (green icon):
   - RollHandler
   - IndexHandler
   - RebirthUIHandler
   - OpenButtonsHandler
   - NotificationHandler

2. Check they're in StarterGui (not ServerScriptService)
3. Make sure they're inside the correct frames:
   - RollHandler → neww/DiceFrame/
   - IndexHandler → neww/Index/
   - RebirthUIHandler → neww/Rebirth/

---

### No Console Messages Appear

**Cause:** Scripts disabled or wrong type

**Fix:**
1. Check View → Output window is open
2. Verify scripts are enabled (not grayed out)
3. Check script types:
   - Blue icon = ModuleScript
   - Red icon = Script (server)
   - Green icon = LocalScript (client)

---

## 🛠️ Step-by-Step Debugging Process

### 1. Start Fresh
```
1. Clear Output window
2. Stop any running game
3. Run SetupVerification.lua
4. Fix ALL ✗ errors
```

### 2. Check Module Types
```
All files in Core/, Systems/, Leaderboards/ = ModuleScript (blue)
MainServer, GiveSlapTool = Script (red)
All GUI handlers = LocalScript (green)
```

### 3. Verify Folder Structure
```
Use SetupVerification to automatically check structure
OR manually verify against SCRIPT_TYPES_REFERENCE.md
```

### 4. Test in Order
```
1. Run SetupVerification → All ✓
2. Run MainServer → Should see "✓ MainServer loaded successfully!"
3. Test play → Data should load
4. Test GUI → Buttons should work
```

---

## 📋 Verification Checklist

Before asking for help, verify:

- [ ] Ran SetupVerification.lua
- [ ] All folders exist in correct locations
- [ ] All scripts are correct type (Script/LocalScript/ModuleScript)
- [ ] ReplicatedStorage has Modules folder with BrainrotData & Config
- [ ] ServerScriptService has Server folder with all subfolders
- [ ] StarterGui has neww ScreenGui with all LocalScripts
- [ ] ServerStorage has Brainrots folder (even if empty for testing)
- [ ] MockProfileService exists in Server folder (fallback)
- [ ] Output window shows "✓" messages, not ✗ errors

---

## 🎯 Quick Test Procedure

### Minimal Setup for Testing (No ProfileService, No Models)

1. **ReplicatedStorage:**
   - Create Modules folder
   - Add BrainrotData (ModuleScript)
   - Add Config (ModuleScript)

2. **ServerScriptService:**
   - Create Server folder with Core/, Systems/, Leaderboards/
   - Add all ModuleScripts
   - Add MainServer (Script)
   - Add MockProfileService (ModuleScript)

3. **StarterGui:**
   - Use existing neww GUI
   - Add LocalScripts to correct frames

4. **Run SetupVerification**
   - Should show ⚠️ warnings for missing Brainrots/Bases (OK for testing)
   - Should show ✓ for all modules

5. **Run MainServer**
   - Should see "⚠️ USING MOCK PROFILESERVICE"
   - Should see "✓ MainServer loaded successfully!"

6. **Test in Play Mode**
   - GUI should appear
   - Roll button should work (even without models)
   - No critical errors in Output

---

## 🆘 Still Having Issues?

### Check These Common Mistakes:

1. **Wrong script type**
   - ModuleScripts must have `return ModuleName` at end
   - Scripts run automatically
   - LocalScripts only work in StarterGui/StarterPlayer

2. **Wrong parent**
   - Server scripts → ServerScriptService
   - Client scripts → StarterGui
   - Shared modules → ReplicatedStorage

3. **Typos in names**
   - Folder names are case-sensitive
   - "Core" ≠ "core"
   - "Modules" ≠ "Module"

4. **Missing WaitForChild**
   - The fixed version uses WaitForChild everywhere
   - Old errors might be from old code

---

## 🔄 Latest Fixes Applied

✅ **MockProfileService** - Automatic fallback, no installation required for testing
✅ **Safe require()** - Better error messages showing exact paths
✅ **SetupVerification** - Automated checking script
✅ **WaitForChild()** - Prevents timing issues

---

## 📞 Getting Help

If you've tried everything above:

1. Run SetupVerification.lua
2. Copy the FULL Output
3. Take screenshot of your folder structure
4. Note which error appears FIRST (fix in order!)
5. Check IMPLEMENTATION_GUIDE.md for setup details

---

**Most issues are fixed by running SetupVerification and following its output!** 🎯
