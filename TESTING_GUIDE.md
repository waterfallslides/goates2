# Lobby Queue System - Testing Guide

This guide will help you test the lobby queue system thoroughly.

## 🧪 Testing in Roblox Studio

### Test 1: Basic Setup Verification

**Objective**: Verify all components are installed correctly

1. Open Roblox Studio
2. Check **Workspace > Lobby** - Should contain:
   - ✅ SoloPad (Blue)
   - ✅ DuoPad (Green)
   - ✅ SquadPad (Orange)
3. Check **ServerScriptService**:
   - ✅ LobbyQueueSystem script exists
4. Check **StarterPlayer > StarterPlayerScripts**:
   - ✅ CountdownGUI LocalScript exists
5. Check **ReplicatedStorage** (created at runtime):
   - ✅ LobbyQueueEvents folder (appears when server runs)

**Expected Result**: All components present in correct locations

---

### Test 2: Solo Queue (1 Player)

**Objective**: Test solo queue with exactly 1 player

**Steps**:
1. Press **Play** (F5) in Studio
2. Move character onto the **SoloPad** (blue pad)
3. Observe the countdown GUI appears
4. Wait for countdown to reach 0

**Expected Results**:
- ✅ GUI shows "SOLO QUEUE"
- ✅ GUI shows "Players: 1/1"
- ✅ Countdown starts at 20 seconds
- ✅ Countdown counts down: 20, 19, 18... 0
- ✅ GUI color changes:
  - Green (20-11s)
  - Orange (10-6s)
  - Red (5-0s)
- ✅ Output shows teleport attempt (will fail in Studio - this is normal)

**Console Output Should Show**:
```
[Queue] Added [YourName] to Solo queue (1/1)
[Queue] Starting countdown for Solo queue
[Queue] Countdown finished for Solo queue, teleporting 1 players
```

---

### Test 3: Duo Queue (2 Players - Partial Fill)

**Objective**: Test duo queue with only 1 player (should still teleport)

**Steps**:
1. Press **Play** (F5) in Studio
2. Move character onto the **DuoPad** (green pad)
3. Observe GUI
4. Wait for countdown

**Expected Results**:
- ✅ GUI shows "DUO QUEUE"
- ✅ GUI shows "Players: 1/2"
- ✅ Countdown still starts (doesn't wait for 2nd player)
- ✅ Player gets teleported after 20 seconds

---

### Test 4: Squad Queue (4 Players - Partial Fill)

**Objective**: Test squad queue with only 1 player

**Steps**:
1. Press **Play** (F5) in Studio
2. Move character onto the **SquadPad** (orange pad)
3. Wait for countdown

**Expected Results**:
- ✅ GUI shows "SQUAD QUEUE"
- ✅ GUI shows "Players: 1/4"
- ✅ Countdown starts immediately
- ✅ Teleport attempt after 20 seconds

---

### Test 5: Multiple Players in Same Queue

**Objective**: Test queue with multiple players

**Steps**:
1. Press **Play** (F5) with **2 players** selected (or use Studio's multiplayer testing)
2. Have both players step on the **DuoPad**
3. Observe both GUIs

**Expected Results**:
- ✅ First player: "Players: 1/2"
- ✅ Second player: "Players: 2/2"
- ✅ Countdown starts after first player joins
- ✅ Both players see same countdown
- ✅ Both players teleported together

---

### Test 6: Switching Queues

**Objective**: Verify players can't be in multiple queues

**Steps**:
1. Step on **SoloPad** (blue)
2. Immediately step on **DuoPad** (green)
3. Check console output

**Expected Results**:
- ✅ Player removed from Solo queue
- ✅ Player added to Duo queue
- ✅ Only one countdown GUI visible
- ✅ Console shows: "Removed [Name] from Solo queue"

---

### Test 7: Queue Full Scenario

**Objective**: Test max player limits

**Steps**:
1. Use **Local Server** with 5 players
2. Have 1 player join **SoloPad**
3. Have another player try to join **SoloPad**

**Expected Results**:
- ✅ First player joins successfully
- ✅ Second player cannot join (queue full message in console)
- ✅ Console: "Solo queue is full!"

---

### Test 8: Player Leaves Before Countdown Ends

**Objective**: Test queue cleanup when players leave

**Steps**:
1. Join a queue (any type)
2. Wait 10 seconds into countdown
3. Press **Stop** or reset character
4. Check console

**Expected Results**:
- ✅ Player removed from queue
- ✅ Console: "Removed [Name] from [QueueType] queue"
- ✅ If all players leave, countdown cancels

---

### Test 9: Multiple Queues Running Simultaneously

**Objective**: Verify all 3 queues can run at same time

**Steps**:
1. Use **Local Server** with 3+ players
2. Have Player 1 join SoloPad
3. Have Player 2 join DuoPad
4. Have Player 3 join SquadPad
5. Observe all countdowns

**Expected Results**:
- ✅ All 3 countdowns run independently
- ✅ Each player sees their own queue's countdown
- ✅ All teleports trigger at correct times
- ✅ No interference between queues

---

## 🌐 Testing in Published Game

**Note**: TeleportService only works in published games, not Studio testing!

### Test 10: Actual Teleportation

**Objective**: Test real teleportation functionality

**Prerequisites**:
- Game must be published to Roblox
- Studio Access to API Services enabled (Game Settings → Security)
- GAME_PLACE_ID correctly set in script

**Steps**:
1. Publish game to Roblox
2. Join game from Roblox website (not Studio)
3. Step on any queue pad
4. Wait for countdown
5. Observe teleportation

**Expected Results**:
- ✅ Countdown works as normal
- ✅ At 0 seconds, screen shows "Teleporting..."
- ✅ Player teleported to new server instance
- ✅ All players in queue teleported together
- ✅ Reserved server created (players spawn together)

---

## 📊 Console Monitoring

### What to Look For

**Good Output** ✅:
```
[Queue] Setup complete for Solo pad
[Queue] Setup complete for Duo pad
[Queue] Setup complete for Squad pad
[Queue] Lobby Queue System initialized!
[Queue] Added PlayerName to Solo queue (1/1)
[Queue] Starting countdown for Solo queue
[Queue] Countdown finished for Solo queue, teleporting 1 players
[Queue] Successfully teleported 1 players from Solo queue (Code: ...)
```

**Error Output** ⚠️:
```
[Queue] Pad not found: SoloPad
```
→ **Solution**: Run CreateLobbyPads.lua to create pads

```
Failed to teleport players: ...
```
→ **Solution**:
- Publish game to Roblox
- Enable API Services in settings
- Test from Roblox website, not Studio

---

## 🐛 Common Issues & Solutions

### Issue: "Pad not found" error

**Cause**: Pads don't exist in workspace
**Solution**: Run `CreateLobbyPads.lua` in Command Bar

### Issue: GUI doesn't appear

**Cause**: LocalScript not in correct location
**Solution**: Move `CountdownGUI` to StarterPlayer > StarterPlayerScripts

### Issue: Countdown doesn't start

**Cause**: Server script not running
**Solution**:
- Check script is in ServerScriptService
- Check for errors in Output (F9)
- Verify script is enabled (not disabled)

### Issue: Teleport fails in Studio

**Cause**: TeleportService limitations in Studio
**Solution**: This is **NORMAL** - test in published game instead

### Issue: Multiple countdowns show at once

**Cause**: Player in multiple queues
**Solution**: This shouldn't happen - check console for errors

---

## ✅ Final Checklist

Before marking as complete, verify:

- [ ] All 3 pads exist with correct names and colors
- [ ] Server script runs without errors
- [ ] Client GUI appears when joining queue
- [ ] Countdown counts from 20 to 0
- [ ] Console shows clear queue messages
- [ ] Player can switch between queues
- [ ] Player removed from queue when leaving game
- [ ] Multiple queues can run simultaneously
- [ ] GUI colors change correctly (green→orange→red)
- [ ] Published game teleports successfully

---

## 📝 Test Results Template

Use this template to document your testing:

```
Date: __________
Tester: __________

Test 1 - Basic Setup: [ ] Pass [ ] Fail
Test 2 - Solo Queue: [ ] Pass [ ] Fail
Test 3 - Duo Queue (Partial): [ ] Pass [ ] Fail
Test 4 - Squad Queue (Partial): [ ] Pass [ ] Fail
Test 5 - Multiple Players: [ ] Pass [ ] Fail
Test 6 - Switching Queues: [ ] Pass [ ] Fail
Test 7 - Queue Full: [ ] Pass [ ] Fail
Test 8 - Player Leaves: [ ] Pass [ ] Fail
Test 9 - Multiple Queues: [ ] Pass [ ] Fail
Test 10 - Live Teleport: [ ] Pass [ ] Fail

Notes:
_________________________________
_________________________________
_________________________________
```

---

**Good luck testing! 🎮**
