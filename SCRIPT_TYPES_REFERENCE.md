# Script Type Reference - RNG Brainrot Stealing Game

This document specifies the exact script type for each file when importing into Roblox Studio.

---

## 📁 ReplicatedStorage (Shared Modules)

### ReplicatedStorage/Modules/

| File | Script Type | Description |
|------|-------------|-------------|
| **BrainrotData.lua** | 🟦 **ModuleScript** | Brainrot configs, rarities, weights |
| **Config.lua** | 🟦 **ModuleScript** | Game configuration settings |

**Location:**
```
ReplicatedStorage
└── Modules (Folder)
    ├── BrainrotData (ModuleScript)
    └── Config (ModuleScript)
```

---

## 🖥️ ServerScriptService (Server-Side)

### ServerScriptService/Server/Core/

| File | Script Type | Description |
|------|-------------|-------------|
| **DataManager.lua** | 🟦 **ModuleScript** | ProfileService data management |
| **RollingSystem.lua** | 🟦 **ModuleScript** | RNG rolling logic |
| **StealingSystem.lua** | 🟦 **ModuleScript** | Stealing mechanics |

### ServerScriptService/Server/Systems/

| File | Script Type | Description |
|------|-------------|-------------|
| **BaseManager.lua** | 🟦 **ModuleScript** | Brainrot placement on pads |
| **RebirthHandler.lua** | 🟦 **ModuleScript** | Rebirth validation & processing |

### ServerScriptService/Server/Leaderboards/

| File | Script Type | Description |
|------|-------------|-------------|
| **StatsManager.lua** | 🟦 **ModuleScript** | Leaderboard tracking |

### ServerScriptService/Server/Tools/

| File | Script Type | Description |
|------|-------------|-------------|
| **GiveSlapTool.lua** | 🟥 **Script** | Gives slap tool on spawn |

### ServerScriptService/Server/

| File | Script Type | Description |
|------|-------------|-------------|
| **MainServer.lua** | 🟥 **Script** | Main entry point, creates RemoteEvents |

**Location:**
```
ServerScriptService
└── Server (Folder)
    ├── Core (Folder)
    │   ├── DataManager (ModuleScript)
    │   ├── RollingSystem (ModuleScript)
    │   └── StealingSystem (ModuleScript)
    ├── Systems (Folder)
    │   ├── BaseManager (ModuleScript)
    │   └── RebirthHandler (ModuleScript)
    ├── Leaderboards (Folder)
    │   └── StatsManager (ModuleScript)
    ├── Tools (Folder)
    │   └── GiveSlapTool (Script)
    └── MainServer (Script)
```

---

## 💻 StarterGui (Client-Side)

### StarterGui/neww/ (Your existing GUI)

| File | Script Type | Parent Location | Description |
|------|-------------|-----------------|-------------|
| **RollHandler.lua** | 🟩 **LocalScript** | `neww/DiceFrame/` | Rolling UI & animations |
| **IndexHandler.lua** | 🟩 **LocalScript** | `neww/Index/` | Index display |
| **RebirthUIHandler.lua** | 🟩 **LocalScript** | `neww/Rebirth/` | Rebirth UI |
| **OpenButtonsHandler.lua** | 🟩 **LocalScript** | `neww/` | Open/close buttons |
| **NotificationHandler.lua** | 🟩 **LocalScript** | `StarterGui/` | Notification system |

**Location:**
```
StarterGui
├── NotificationHandler (LocalScript)
└── neww (ScreenGui)
    ├── DiceFrame (Frame)
    │   └── RollHandler (LocalScript)
    ├── Index (Frame)
    │   └── IndexHandler (LocalScript)
    ├── Rebirth (Frame)
    │   └── RebirthUIHandler (LocalScript)
    └── OpenButtonsHandler (LocalScript)
```

---

## 🔧 ServerStorage (Tools)

### ServerStorage/SlapTool/

| File | Script Type | Parent | Description |
|------|-------------|--------|-------------|
| **SlapTool.lua** | 🟥 **Script** | Inside Tool object | Slap detection logic |

**Location:**
```
ServerStorage
├── ProfileService (ModuleScript) - Install separately!
└── SlapTool (Tool)
    ├── Handle (Part) - Your bat model
    └── SlapTool (Script)
```

---

## 🎯 Quick Reference by Script Type

### 🟥 Script (Server-Side) - 3 files
1. `MainServer.lua` → ServerScriptService/Server/
2. `GiveSlapTool.lua` → ServerScriptService/Server/Tools/
3. `SlapTool.lua` → ServerStorage/SlapTool/ (inside Tool)

### 🟦 ModuleScript (Shared/Server) - 8 files
1. `BrainrotData.lua` → ReplicatedStorage/Modules/
2. `Config.lua` → ReplicatedStorage/Modules/
3. `DataManager.lua` → ServerScriptService/Server/Core/
4. `RollingSystem.lua` → ServerScriptService/Server/Core/
5. `StealingSystem.lua` → ServerScriptService/Server/Core/
6. `BaseManager.lua` → ServerScriptService/Server/Systems/
7. `RebirthHandler.lua` → ServerScriptService/Server/Systems/
8. `StatsManager.lua` → ServerScriptService/Server/Leaderboards/

### 🟩 LocalScript (Client-Side) - 5 files
1. `RollHandler.lua` → StarterGui/neww/DiceFrame/
2. `IndexHandler.lua` → StarterGui/neww/Index/
3. `RebirthUIHandler.lua` → StarterGui/neww/Rebirth/
4. `OpenButtonsHandler.lua` → StarterGui/neww/
5. `NotificationHandler.lua` → StarterGui/

---

## 📋 Import Checklist

Use this checklist when importing into Roblox Studio:

### ReplicatedStorage
- [ ] Create `Modules` folder
- [ ] Insert `BrainrotData` as ModuleScript
- [ ] Insert `Config` as ModuleScript

### ServerScriptService
- [ ] Create `Server` folder
- [ ] Create `Core` folder inside Server
  - [ ] Insert `DataManager` as ModuleScript
  - [ ] Insert `RollingSystem` as ModuleScript
  - [ ] Insert `StealingSystem` as ModuleScript
- [ ] Create `Systems` folder inside Server
  - [ ] Insert `BaseManager` as ModuleScript
  - [ ] Insert `RebirthHandler` as ModuleScript
- [ ] Create `Leaderboards` folder inside Server
  - [ ] Insert `StatsManager` as ModuleScript
- [ ] Create `Tools` folder inside Server
  - [ ] Insert `GiveSlapTool` as Script
- [ ] Insert `MainServer` as Script in Server folder

### StarterGui
- [ ] Find existing `neww` ScreenGui
- [ ] Find `DiceFrame`
  - [ ] Insert `RollHandler` as LocalScript
- [ ] Find `Index` frame
  - [ ] Insert `IndexHandler` as LocalScript
- [ ] Find `Rebirth` frame
  - [ ] Insert `RebirthUIHandler` as LocalScript
- [ ] In `neww` ScreenGui root
  - [ ] Insert `OpenButtonsHandler` as LocalScript
- [ ] In StarterGui root
  - [ ] Insert `NotificationHandler` as LocalScript

### ServerStorage
- [ ] Install ProfileService as ModuleScript (from GitHub)
- [ ] Create `SlapTool` as Tool object
  - [ ] Create `Handle` as Part (your bat model)
  - [ ] Insert `SlapTool` as Script inside Tool

---

## 🔍 How to Create Each Type in Roblox Studio

### ModuleScript 🟦
1. Right-click parent location
2. Insert Object → ModuleScript
3. Rename to file name (e.g., "DataManager")
4. Paste code, keeping `return ModuleName` at end

### Script 🟥
1. Right-click parent location
2. Insert Object → Script
3. Rename to file name (e.g., "MainServer")
4. Paste code

### LocalScript 🟩
1. Right-click parent location
2. Insert Object → LocalScript
3. Rename to file name (e.g., "RollHandler")
4. Paste code

---

## ⚠️ Common Mistakes to Avoid

❌ **Wrong:** Putting LocalScripts in ServerScriptService
✅ **Right:** LocalScripts only in StarterGui, StarterPlayer, or ReplicatedFirst

❌ **Wrong:** Putting Server Scripts in StarterGui
✅ **Right:** Server Scripts only in ServerScriptService or Workspace

❌ **Wrong:** Creating Script instead of ModuleScript for modules
✅ **Right:** Files with `return ModuleName` must be ModuleScripts

❌ **Wrong:** Forgetting to install ProfileService
✅ **Right:** ProfileService MUST be in ServerStorage as ModuleScript

---

## 🎯 Visual Reference

```
🌳 Game (Workspace)
│
├── 📁 ReplicatedStorage (Shared between client/server)
│   └── 📁 Modules
│       ├── 🟦 BrainrotData (ModuleScript)
│       └── 🟦 Config (ModuleScript)
│
├── 📁 ServerScriptService (Server only)
│   └── 📁 Server
│       ├── 📁 Core
│       │   ├── 🟦 DataManager (ModuleScript)
│       │   ├── 🟦 RollingSystem (ModuleScript)
│       │   └── 🟦 StealingSystem (ModuleScript)
│       ├── 📁 Systems
│       │   ├── 🟦 BaseManager (ModuleScript)
│       │   └── 🟦 RebirthHandler (ModuleScript)
│       ├── 📁 Leaderboards
│       │   └── 🟦 StatsManager (ModuleScript)
│       ├── 📁 Tools
│       │   └── 🟥 GiveSlapTool (Script)
│       └── 🟥 MainServer (Script)
│
├── 📁 ServerStorage (Storage for server)
│   ├── 🟦 ProfileService (ModuleScript) - Install separately
│   └── 🔧 SlapTool (Tool)
│       ├── 📦 Handle (Part)
│       └── 🟥 SlapTool (Script)
│
└── 📁 StarterGui (Client UI)
    ├── 🟩 NotificationHandler (LocalScript)
    └── 🖼️ neww (ScreenGui)
        ├── 🟩 OpenButtonsHandler (LocalScript)
        ├── 📁 DiceFrame
        │   └── 🟩 RollHandler (LocalScript)
        ├── 📁 Index
        │   └── 🟩 IndexHandler (LocalScript)
        └── 📁 Rebirth
            └── 🟩 RebirthUIHandler (LocalScript)
```

---

## 🎓 Legend

| Icon | Type | Runs On | Description |
|------|------|---------|-------------|
| 🟥 | Script | Server | Executes on server only |
| 🟩 | LocalScript | Client | Executes on each player's client |
| 🟦 | ModuleScript | Both | Shared code, used by require() |
| 📁 | Folder | N/A | Organization only |
| 🔧 | Tool | Both | Player equipment |
| 📦 | Part | Both | Physical object |
| 🖼️ | ScreenGui | Client | UI container |

---

## 💡 Pro Tips

1. **Test after each section** - Import ReplicatedStorage first, test, then ServerScriptService, etc.
2. **Check Output** - Look for "✓ [Name] loaded" messages
3. **Module order matters** - MainServer.lua must run AFTER all modules exist
4. **LocalScripts won't run in wrong location** - Must be in StarterGui, StarterPlayer, or player's Backpack
5. **Use Ctrl+Shift+F** - Search all scripts for "require()" to verify module paths

---

This reference should make it crystal clear what type each script needs to be! 🎉
