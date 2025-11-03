# Quick Fix Guide - Your Specific Errors

Based on the errors you showed me, here's what to do:

---

## 🚨 Error 1: "Attempted to call require" - MainServer:13

**What it means:** MainServer can't find the module files

**Fix (Choose ONE):**

### Option A: Run Setup Verification (RECOMMENDED)
```
1. Find: ServerScriptService/Server/SetupVerification
2. Right-click → Run Script
3. Look at Output - it will show EXACTLY what's missing
4. Fix the ✗ errors it shows
```

### Option B: Manual Check
Make sure this structure exists EXACTLY:
```
ServerScriptService/
└── Server/ (Folder)
    ├── Core/ (Folder)
    │   ├── DataManager (ModuleScript) ← Must be ModuleScript!
    │   ├── RollingSystem (ModuleScript)
    │   └── StealingSystem (ModuleScript)
    ├── Systems/ (Folder)
    │   ├── BaseManager (ModuleScript)
    │   └── RebirthHandler (ModuleScript)
    ├── Leaderboards/ (Folder)
    │   └── StatsManager (ModuleScript)
    ├── MockProfileService (ModuleScript) ← NEW! Must exist
    └── MainServer (Script) ← Must be Script, not ModuleScript!
```

**Common mistakes:**
- ❌ Put scripts in ServerScriptService root → ✅ Put in Server folder
- ❌ Made MainServer a ModuleScript → ✅ Must be Script (red icon)
- ❌ Made modules Scripts → ✅ Must be ModuleScripts (blue icon)

---

## 🚨 Error 2: "Attempted to call require" - DataManager:16

**What it means:** ProfileService not installed

**Fix:** ✅ **ALREADY FIXED IN LATEST CODE!**

The new code automatically uses MockProfileService if ProfileService isn't found.

**What you'll see now:**
```
⚠️ ProfileService not found! Using mock (NO DATA PERSISTENCE)
⚠️⚠️⚠️ USING MOCK PROFILESERVICE - NO DATA PERSISTENCE! ⚠️⚠️⚠️
```

This is **NORMAL** for testing! The game will run fine, just won't save data.

**To get real data saving later:**
1. Download ProfileService: https://github.com/MadStudioRoblox/ProfileService
2. Place in ServerStorage as "ProfileService" (ModuleScript)
3. Restart game - it will auto-detect and use it

---

## 🚨 Error 3: "Infinite yield - Events"

**What it means:** MainServer failed to create the Events folder

**Fix:** Fix Errors 1 & 2 first!

This error happens BECAUSE MainServer crashed. Once MainServer runs successfully, this error will disappear.

**How to verify it's fixed:**
1. Look for this in Output: `✓ RemoteEvents created`
2. Check ReplicatedStorage - should have "Events" folder
3. The "Infinite yield" warnings will stop

---

## ✅ Step-by-Step Fix Process

### 1️⃣ Update to Latest Code
Make sure you have the latest files:
- ✅ MockProfileService.lua
- ✅ Updated MainServer.lua (with safeRequire)
- ✅ Updated DataManager.lua (with auto-fallback)
- ✅ SetupVerification.lua

### 2️⃣ Run Setup Verification
```
1. Open Roblox Studio
2. Find ServerScriptService/Server/SetupVerification
3. Right-click → Run Script
4. Read Output carefully
5. Fix ALL ✗ errors
```

### 3️⃣ Check Module Types
```
Right-click each file → Properties → ClassName should be:

MainServer.lua → Script
GiveSlapTool.lua → Script
All files in Core/ → ModuleScript
All files in Systems/ → ModuleScript
All files in Leaderboards/ → ModuleScript
MockProfileService.lua → ModuleScript

All GUI handlers → LocalScript
```

### 4️⃣ Test Run
```
1. Clear Output window
2. Press Play
3. Look for these messages:
   ✓ Loading modules...
   ✓ DataManager loaded (or Mock warning - OK!)
   ✓ RollingSystem loaded
   ✓ StealingSystem loaded
   ✓ BaseManager loaded
   ✓ RebirthHandler loaded
   ✓ StatsManager loaded
   ✓ BrainrotData loaded
   ✓ Config loaded
   ✓ RemoteEvents created
   ✓ MainServer loaded successfully!
```

---

## 🎯 Expected Output (Success)

```
Loading modules...
⚠️ ProfileService not found! Using mock (NO DATA PERSISTENCE)
⚠️⚠️⚠️ USING MOCK PROFILESERVICE - NO DATA PERSISTENCE! ⚠️⚠️⚠️
✓ DataManager loaded
✓ RollingSystem loaded
✓ StealingSystem loaded
✓ BaseManager loaded
✓ RebirthHandler loaded
✓ StatsManager loaded
✓ BrainrotData loaded
✓ Config loaded
✓ RemoteEvents created
Initializing systems...
✓ Systems initialized
✓ MainServer loaded successfully!
✓ OpenButtonsHandler loaded
```

**The "MOCK PROFILESERVICE" warning is OK for testing!**

---

## 🎯 Expected Output (With ProfileService)

```
Loading modules...
✓ ProfileService loaded
✓ DataManager loaded
✓ RollingSystem loaded
... (same as above)
```

No mock warnings = real data persistence working!

---

## 📁 Minimal ReplicatedStorage Setup

At minimum, you need:
```
ReplicatedStorage/
└── Modules/ (Folder)
    ├── BrainrotData (ModuleScript)
    └── Config (ModuleScript)
```

**If missing:**
1. Create "Modules" folder in ReplicatedStorage
2. Create ModuleScript named "BrainrotData"
3. Paste content from src/replicated/modules/BrainrotData.lua
4. Create ModuleScript named "Config"
5. Paste content from src/replicated/modules/Config.lua

---

## 🆘 Still Getting Errors?

**Run this checklist:**
- [ ] SetupVerification shows all ✓ for critical items
- [ ] MainServer is a Script (not ModuleScript)
- [ ] All Core/Systems modules are ModuleScripts
- [ ] MockProfileService exists in Server folder
- [ ] Modules folder exists in ReplicatedStorage
- [ ] Output shows "Loading modules..." when you play

**If YES to all above but still errors:**
1. Copy the EXACT error from Output
2. Note the line number
3. Take screenshot of your folder structure
4. Check TROUBLESHOOTING.md for that specific error

---

## 💡 Pro Tips

1. **Clear Output before each test** - Makes it easier to see new errors
2. **Fix errors in order** - First error often causes others
3. **Green = Client, Red = Server, Blue = Module** - Check icon colors
4. **SetupVerification is your friend** - Run it often!
5. **Mock is OK for testing** - Don't worry about ProfileService until ready

---

## 🎉 Success Indicator

When everything works, you'll see:
- ✅ No red errors in Output
- ✅ "✓ MainServer loaded successfully!" message
- ✅ GUI appears in test play
- ✅ Roll button exists (even if models missing)

**You can test core mechanics without:**
- Brainrot models
- Player bases
- ProfileService

Just ignore the ⚠️ warnings for those!

---

**TL;DR:** Run SetupVerification.lua and fix what it tells you to fix! 🚀
