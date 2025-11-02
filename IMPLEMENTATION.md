# ROBLOX BUNKER SURVIVAL - IMPLEMENTATION GUIDE

## CURRENT STATUS: Phase 1 - Core Systems Complete ✅

---

## 📦 WHAT'S BEEN IMPLEMENTED

### ✅ **Lobby System (COMPLETE)**
Located in: `src/server/` and `src/client/`

**Features:**
- 3 queue pads (Solo/Duo/Squad)
- 20-second countdown system
- Player capacity limits
- Real-time player counters on pads
- Cartoony GUI with visual feedback
- Teleportation to game servers

**Files:**
- `src/server/LobbyQueueSystem.lua` (399 lines)
- `src/server/CreateLobbyPads.lua` (100 lines)
- `src/client/CountdownGUI.lua` (173 lines)

---

### ✅ **Game Server Core Systems (NEW)**
Located in: `src/game-server/`

#### **1. Game Manager** (`GameManager.lua`)
Main server coordinator that handles:
- Game initialization
- Mode detection (Solo/Duo/Squad)
- Player spawning and data management
- Game state transitions (WaitingForPlayers → Playing → GameOver)
- Server shutdown when players leave
- Death handling and game over conditions
- Coin awarding system (server-validated)

**Key Functions:**
```lua
GameManager:Initialize()
GameManager:StartGame()
GameManager:OnPlayerDeath(player)
GameManager:AwardCoins(player, amount, reason)
GameManager:EndGame()
```

#### **2. Day/Night Manager** (`DayNightManager.lua`)
Manages the core gameplay cycle:
- **Day Phase:** 3 minutes (180 seconds)
  - Players explore and collect food
  - Buy weapons and upgrades
  - Prepare for night
- **Night Phase:** 5 minutes (300 seconds)
  - Monsters spawn and attack
  - Players defend bunkers
  - Difficulty increases

**Features:**
- Automatic phase transitions
- Lighting changes (day = bright, night = dark)
- Warning system (30s and 10s before phase change)
- Timer updates sent to clients
- Coin rewards at day start (75 coins for survival)
- Milestone bonuses (100 coins every 5 days)
- Weapon tier unlocks (Day 7, 14, 21)
- Boss night detection (every 7 days)

**Key Functions:**
```lua
DayNightManager:Start()
DayNightManager:StartDayPhase()
DayNightManager:StartNightPhase()
DayNightManager:IsBossNight()
```

#### **3. Player Data Manager** (`PlayerDataManager.lua`)
Manages player health and hunger:

**Hunger System:**
- Drains over time (100% → 0% in 8 minutes walking)
- Sprinting drains 2x faster
- Empty hunger = can't sprint + lose 2 HP every 5 seconds

**Health System:**
- 100 HP maximum
- Death at 0 HP
- Healing from food

**Food Types:**
- Bread: +20 HP, +30% hunger
- Apple: +15 HP, +20% hunger
- Cooked Meat: +40 HP, +50% hunger
- Canned Food: +25 HP, +40% hunger
- Water Bottle: +10 HP, +25% hunger

**Key Functions:**
```lua
PlayerDataManager:Initialize(gameManager)
PlayerDataManager:EatFood(player, foodType)
PlayerDataManager:SetHunger(player, hunger)
```

#### **4. Food Manager** (`FoodManager.lua`)
Handles food spawning and collection:

**Features:**
- Random spawn locations each day
- Different spawn distances based on rarity (rare = farther)
- Visual identification (colored spheres with labels)
- Glow effects for visibility
- Click/ProximityPrompt collection
- Inventory stacking

**Food Counts Per Day:**
- Bread: 8 (common)
- Apple: 10 (common)
- Cooked Meat: 3 (rare)
- Canned Food: 5 (uncommon)
- Water Bottle: 7 (common)

**Key Functions:**
```lua
FoodManager:SpawnFood()
FoodManager:CollectFood(player, foodPart)
FoodManager:RemoveAllFood()
```

#### **5. Monster Manager** (`MonsterManager.lua`)
Complete monster spawning and AI system:

**Monster Types:**
- **Basic Zombie:** 50 HP, 10 damage, slow (Day 1+)
- **Fast Zombie:** 35 HP, 8 damage, fast (Day 4+)
- **Tank Zombie:** 120 HP, 20 damage, slow, high bunker damage (Day 7+)
- **Crawler:** 40 HP, 12 damage, small hitbox (Day 10+)
- **Boss:** 300+ HP, 30 damage, spawns every 7 days

**Features:**
- Difficulty scaling per day (HP and damage increase)
- Boss HP scales with player count:
  - Solo: Base HP
  - Duo: Base HP × 1.5
  - Squad: Base HP × 2
- Targeting priority:
  1. Players outside bunkers first
  2. If all inside → distribute evenly to bunkers
- Pathfinding and movement AI
- Attack cooldowns based on attack speed
- Health bars above monsters
- Coin drops on death

**Scaling Formula:**
```lua
Monster HP = BaseHP × (1 + Day × 0.15)
Monster Damage = BaseDamage × (1 + Day × 0.10)
Total Count = 3 + floor(Day / 3)
Boss Night = Every 7 days (Day 7, 14, 21, ...)
```

**Key Functions:**
```lua
MonsterManager:SpawnMonsters(day)
MonsterManager:SpawnBoss(day)
MonsterManager:DamageMonster(monsterData, damage, attacker)
MonsterManager:KillMonster(monsterData, killer)
```

#### **6. Server Initialization** (`init.server.lua`)
Main entry point that:
- Loads all manager modules
- Initializes systems in correct order
- Links managers together
- Starts the game and day/night cycle

---

### ✅ **Client Systems (NEW)**
Located in: `src/game-client/`

#### **Game HUD** (`GameHUD.lua`)
Complete in-game interface:

**Display Elements:**
- **Top Left:**
  - Health bar (red) with label
  - Hunger bar (orange) with label
- **Top Right:**
  - Coins display with gold icon
- **Top Center:**
  - Day counter ("DAY X")
  - Color changes: Day = blue, Night = purple
- **Center Top:**
  - Phase timer (MM:SS format)
  - Color changes: White → Orange (30s) → Red (10s)
- **Center Screen:**
  - Warning messages (fade in/out)

**Features:**
- Smooth animations with TweenService
- Real-time updates from server
- FredokaOne font for cartoony aesthetic
- Rounded corners and strokes
- Responsive to server events

**Server Events Handled:**
- `HealthUpdate` - Updates health bar
- `HungerUpdate` - Updates hunger bar
- `DayUpdate` - Updates day label and color
- `PhaseTimer` - Updates countdown timer
- `PhaseWarning` - Shows warning messages

#### **Client Initialization** (`init.client.lua`)
Client-side entry point that:
- Waits for game events from server
- Initializes HUD
- Connects to server systems

---

## 📂 FILE STRUCTURE

```
goates2/
├── src/
│   ├── server/                    # Lobby system (existing)
│   │   ├── LobbyQueueSystem.lua   (399 lines)
│   │   └── CreateLobbyPads.lua    (100 lines)
│   │
│   ├── client/                    # Lobby client (existing)
│   │   └── CountdownGUI.lua       (173 lines)
│   │
│   ├── game-server/               # Game server systems (NEW)
│   │   ├── init.server.lua        - Server entry point
│   │   ├── GameManager.lua        - Game state coordinator
│   │   ├── DayNightManager.lua    - Day/night cycle
│   │   ├── PlayerDataManager.lua  - Health/hunger/stats
│   │   ├── FoodManager.lua        - Food spawning
│   │   └── MonsterManager.lua     - Monster AI/spawning
│   │
│   └── game-client/               # Game client systems (NEW)
│       ├── init.client.lua        - Client entry point
│       └── GameHUD.lua            - In-game HUD
│
├── README.md                      - Original documentation
├── QUICKSTART.md                  - 5-minute setup guide
├── TESTING_GUIDE.md               - Testing procedures
└── IMPLEMENTATION.md              - This file
```

**Total Lines of Code:**
- Lobby System: 672 lines
- Game Server: ~1500+ lines
- Game Client: ~500+ lines
- **Total: 2600+ lines**

---

## 🎮 HOW IT WORKS

### Game Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. LOBBY                                                    │
├─────────────────────────────────────────────────────────────┤
│ - Players join lobby                                        │
│ - Step on queue pad (Solo/Duo/Squad)                        │
│ - 20-second countdown                                       │
│ - Teleport to game server                                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. GAME INITIALIZATION                                      │
├─────────────────────────────────────────────────────────────┤
│ - GameManager detects mode (Solo/Duo/Squad)                │
│ - PlayerDataManager initializes health/hunger              │
│ - DayNightManager starts on Day 1                          │
│ - HUD appears for all players                               │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. DAY PHASE (3 minutes)                                    │
├─────────────────────────────────────────────────────────────┤
│ - Food spawns around map                                    │
│ - Players collect food (click/proximity)                    │
│ - Hunger drains over time                                   │
│ - Players can eat food to restore hunger/health            │
│ - Lighting: Bright and sunny                               │
│ - Warning at 30s and 10s before night                       │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. NIGHT PHASE (5 minutes)                                  │
├─────────────────────────────────────────────────────────────┤
│ - All food removed from map                                 │
│ - Monsters spawn around perimeter                           │
│ - Monsters target players or bunkers                        │
│ - Players fight monsters (coins on kill)                    │
│ - Lighting: Dark and dangerous                              │
│ - Boss spawns every 7 days                                  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. DAY STARTS AGAIN                                         │
├─────────────────────────────────────────────────────────────┤
│ - Day counter increases                                     │
│ - All alive players get 75 coins                            │
│ - Food respawns                                             │
│ - Bunkers auto-repair (when implemented)                    │
│ - Weapon tiers unlock (Day 7, 14, 21)                       │
│ - Cycle repeats with increased difficulty                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. GAME OVER                                                │
├─────────────────────────────────────────────────────────────┤
│ Solo: Player dies → Game over                               │
│ Duo/Squad: All players die → Game over                      │
│ - Show death screen with stats                              │
│ - Option to revive (Dev Product) or return to lobby         │
│ - Teleport back to lobby                                    │
│ - Server shuts down                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 INSTALLATION GUIDE

### **Step 1: Lobby Setup**
1. Open Roblox Studio
2. Create two places:
   - **Lobby Place** (main game)
   - **Game Place** (survival gameplay)

3. In Lobby Place:
   - Run `src/server/CreateLobbyPads.lua` in Command Bar
   - This creates 3 queue pads in Workspace
   - Place `src/server/LobbyQueueSystem.lua` in ServerScriptService
   - Place `src/client/CountdownGUI.lua` in StarterPlayer > StarterPlayerScripts

4. Update `GAME_PLACE_ID` in `LobbyQueueSystem.lua` (line 18) to your Game Place ID

### **Step 2: Game Server Setup**
1. In Game Place:
   - Create folder structure in ServerScriptService:
     ```
     ServerScriptService/
     └── GameServer/
         ├── init.server.lua
         ├── GameManager.lua
         ├── DayNightManager.lua
         ├── PlayerDataManager.lua
         ├── FoodManager.lua
         └── MonsterManager.lua
     ```
   - Copy all files from `src/game-server/` into this folder

2. In StarterPlayer > StarterPlayerScripts:
   - Create folder structure:
     ```
     StarterPlayerScripts/
     └── GameClient/
         ├── init.client.lua
         └── GameHUD.lua
     ```
   - Copy all files from `src/game-client/` into this folder

### **Step 3: Map Setup (Basic)**
1. In Game Place workspace:
   - Create a baseplate or terrain
   - Add a Part named "MapCenter" at position (0, 0, 0)
   - Add a SpawnLocation for players

2. Optional (for better testing):
   - Create a "Bunkers" folder in Workspace
   - Food will spawn around MapCenter automatically

### **Step 4: Publish and Test**
1. Publish both places
2. Enable Team Create (optional)
3. Test in Lobby Place:
   - Step on a queue pad
   - Wait for countdown
   - You should teleport to Game Place
   - Game should start automatically

---

## ⚙️ CONFIGURATION

### Day/Night Timing
In `DayNightManager.lua` (lines 15-17):
```lua
CONFIG = {
    DAY_DURATION = 180,    -- 3 minutes (change to test)
    NIGHT_DURATION = 300,  -- 5 minutes
    WARNING_TIMES = {30, 10}, -- Warnings before phase change
}
```

### Hunger Settings
In `PlayerDataManager.lua` (lines 14-20):
```lua
CONFIG = {
    MAX_HEALTH = 100,
    MAX_HUNGER = 100,
    HUNGER_DRAIN_RATE = 0.208, -- Adjust for faster/slower drain
    HUNGER_DRAIN_SPRINT_MULTIPLIER = 2,
    STARVATION_DAMAGE = 2,
    STARVATION_INTERVAL = 5,
}
```

### Food Spawning
In `FoodManager.lua` (lines 28-34):
```lua
FOOD_COUNTS = {
    Bread = 8,        -- Increase for more food
    Apple = 10,
    CookedMeat = 3,
    CannedFood = 5,
    WaterBottle = 7,
},
```

### Monster Difficulty
In `MonsterManager.lua` (lines 26-77):
- Edit `MONSTER_DATA` table to adjust HP, damage, speed, etc.
- Boss scaling: lines 138-148

---

## 🧪 TESTING CHECKLIST

### ✅ **Core Systems**
- [x] Server starts without errors
- [x] Day/night cycle runs automatically
- [x] Lighting changes between day/night
- [x] Timer counts down correctly
- [x] Day counter increments

### ✅ **Player Systems**
- [x] Health bar updates
- [x] Hunger drains over time
- [x] Starvation damage when hunger empty
- [x] Coins display updates
- [x] Player death triggers game over

### ✅ **Food System**
- [ ] Food spawns at day start
- [ ] Food can be collected
- [ ] Food disappears at night
- [ ] Eating food restores hunger/health
- [ ] Food stacks in inventory

### ✅ **Monster System**
- [ ] Monsters spawn at night start
- [ ] Monsters move towards players
- [ ] Monsters attack players
- [ ] Monsters damage players
- [ ] Killing monsters awards coins
- [ ] Boss spawns on Day 7
- [ ] Boss has scaled HP

### ⚠️ **Not Yet Implemented**
- [ ] Bunkers (structures not built)
- [ ] Weapons (no combat system yet)
- [ ] Weapon shops
- [ ] Bunker upgrades (tycoon system)
- [ ] Inventory GUI
- [ ] Death screen UI
- [ ] Spectate mode (Duo/Squad)
- [ ] Revive system
- [ ] Leaderboards
- [ ] Badges
- [ ] Gamepasses
- [ ] DataStore persistence

---

## 🔧 WHAT STILL NEEDS TO BE BUILT

### **Phase 2 - Combat & Bunkers**
1. **Bunker System:**
   - Create bunker structures (doors, walls)
   - Tycoon upgrade system (red floor parts)
   - Bunker health and breach mechanics
   - Auto-repair at day start

2. **Weapon System:**
   - 15 weapons with stats
   - Weapon shops around map
   - Combat mechanics (clicking to attack)
   - Damage to monsters
   - Tier unlocks (Day 7, 14, 21)

3. **Inventory System:**
   - 2 weapon slots, 3 food type slots
   - Inventory GUI
   - Weapon switching
   - Food management

### **Phase 3 - Team Modes**
1. **Duo Mode:**
   - 2 bunkers on map
   - Spectate system when dead
   - Revive dev product

2. **Squad Mode:**
   - 4 bunkers on map
   - Team coordination
   - Shared objectives

3. **Trading:**
   - Drop items on ground
   - Other players can pick up
   - 2-minute despawn timer

### **Phase 4 - Monetization & Polish**
1. **Dev Products:**
   - Revive purchase
   - Integration with death screen

2. **Gamepasses:**
   - Double Coins
   - Starter Pack
   - Extra Inventory
   - VIP Bunker
   - Speed Boost
   - Boss Hunter

3. **UI Polish:**
   - Death screen with stats
   - Spectate UI
   - Shop GUI
   - Inventory GUI
   - Better HUD animations

4. **Leaderboards:**
   - 3 separate boards (Solo/Duo/Squad)
   - DataStore integration
   - Personal best tracking

5. **Badges:**
   - Achievement system
   - Badge tracking
   - Award on milestones

### **Phase 5 - Audio & Effects**
1. **Sound Effects:**
   - Weapon swings/hits
   - Monster growls
   - Coin earning sound
   - Food eating
   - Phase transitions

2. **Music:**
   - Lobby music
   - Day music
   - Night music
   - Boss music

3. **Visual Effects:**
   - Damage numbers
   - Screen shake
   - Blood particles
   - Coin sparkles
   - Revive effect

### **Phase 6 - Balance & Optimization**
1. Anti-exploit hardening
2. Object pooling for monsters/food
3. Pathfinding optimization
4. Difficulty tuning
5. Economy balancing
6. Performance optimization

---

## 🐛 KNOWN ISSUES

1. **Bunkers don't exist yet** - Monsters will target players only
2. **No weapons** - Players can't fight back yet
3. **Food collection** - Works but inventory is basic (just IntValues)
4. **Monster pathfinding** - Simple MoveTo (not advanced pathfinding yet)
5. **Server shutdown** - Needs lobby place ID configured

---

## 📞 SUPPORT

For issues or questions:
1. Check this documentation
2. Review code comments in each file
3. Test in Roblox Studio with detailed output
4. Check server/client logs for errors

---

## 📝 VERSION HISTORY

**v0.5 - Core Systems (Current)**
- ✅ Game Manager
- ✅ Day/Night Cycle
- ✅ Health/Hunger System
- ✅ Food Spawning
- ✅ Monster AI
- ✅ Boss Fights
- ✅ Coin Economy
- ✅ In-Game HUD

**v0.1 - Lobby System**
- ✅ Queue pads
- ✅ Countdown
- ✅ Teleportation

---

**Last Updated:** November 2025
**Status:** Phase 1 Complete - Ready for Phase 2 (Combat & Bunkers)
