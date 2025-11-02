--[[
    ROBLOX BUNKER SURVIVAL - MONSTER MANAGER
    Manages monster spawning, AI, and combat

    Monster Types:
    - Basic Zombie: 50 HP, 10 damage/hit, slow
    - Fast Zombie: 35 HP, 8 damage/hit, fast (Day 4+)
    - Tank Zombie: 120 HP, 20 damage/hit, slow (Day 7+)
    - Crawler: 40 HP, 12 damage/hit, small (Day 10+)
    - Boss: Spawns every 7 days

    Targeting Priority:
    1. Players outside bunkers
    2. If all inside → distribute evenly to bunkers
]]

local MonsterManager = {}

-- Services
local ServerStorage = game:GetService("ServerStorage")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

-- Monster data
local MONSTER_DATA = {
    BasicZombie = {
        Name = "Basic Zombie",
        Health = 50,
        Damage = 10,
        AttackSpeed = 1, -- Attacks per second
        WalkSpeed = 12,
        Color = Color3.fromRGB(100, 150, 100),
        Size = Vector3.new(2, 5, 2),
        CoinDrop = 10,
        StructureDamage = 8,
    },
    FastZombie = {
        Name = "Fast Zombie",
        Health = 35,
        Damage = 8,
        AttackSpeed = 1.5,
        WalkSpeed = 22,
        Color = Color3.fromRGB(150, 100, 100),
        Size = Vector3.new(1.8, 5, 1.8),
        CoinDrop = 15,
        StructureDamage = 6,
        UnlockDay = 4,
    },
    TankZombie = {
        Name = "Tank Zombie",
        Health = 120,
        Damage = 20,
        AttackSpeed = 0.7,
        WalkSpeed = 10,
        Color = Color3.fromRGB(80, 80, 120),
        Size = Vector3.new(3, 6, 3),
        CoinDrop = 25,
        StructureDamage = 25,
        UnlockDay = 7,
    },
    Crawler = {
        Name = "Crawler",
        Health = 40,
        Damage = 12,
        AttackSpeed = 1.2,
        WalkSpeed = 16,
        Color = Color3.fromRGB(120, 80, 80),
        Size = Vector3.new(2, 2, 2),
        CoinDrop = 15,
        StructureDamage = 10,
        UnlockDay = 10,
    },
    Boss = {
        Name = "Boss Monster",
        Health = 300, -- Scaled per mode and day
        Damage = 30,
        AttackSpeed = 1,
        WalkSpeed = 18,
        Color = Color3.fromRGB(200, 50, 50),
        Size = Vector3.new(4, 8, 4),
        CoinDrop = 150, -- Divided among participants
        StructureDamage = 50,
    }
}

-- State
MonsterManager.Monsters = {} -- Active monsters
MonsterManager.GameManager = nil
MonsterManager.BunkerManager = nil

-- Initialize
function MonsterManager:Initialize(gameManager)
    self.GameManager = gameManager
    print("[MonsterManager] Initialized")

    -- Create monsters folder
    if not workspace:FindFirstChild("Monsters") then
        local monstersFolder = Instance.new("Folder")
        monstersFolder.Name = "Monsters"
        monstersFolder.Parent = workspace
    end
end

-- Spawn monsters for the night
function MonsterManager:SpawnMonsters(day)
    print("[MonsterManager] Spawning monsters for night " .. day)

    -- Calculate total monster count
    local baseCount = 3 + math.floor(day / 3)
    local totalMonsters = baseCount

    -- Check if boss night
    local isBossNight = (day % 7 == 0)
    if isBossNight then
        totalMonsters = baseCount * 3 -- More monsters on boss nights
        self:SpawnBoss(day)
    end

    -- Get available monster types for this day
    local availableTypes = self:GetAvailableMonsterTypes(day)

    -- Get target priority
    local outsidePlayers = self:GetPlayersOutsideBunkers()

    if #outsidePlayers > 0 then
        -- All monsters target outside players
        print("[MonsterManager] Targeting " .. #outsidePlayers .. " players outside bunkers")

        for i = 1, totalMonsters do
            local monsterType = availableTypes[math.random(1, #availableTypes)]
            local target = outsidePlayers[math.random(1, #outsidePlayers)]
            self:SpawnMonster(monsterType, day, target)
        end
    else
        -- Distribute to bunkers
        print("[MonsterManager] All players inside, distributing to bunkers")

        local bunkers = self:GetAllBunkers()
        if #bunkers > 0 then
            local monstersPerBunker = math.ceil(totalMonsters / #bunkers)

            for _, bunker in ipairs(bunkers) do
                for i = 1, monstersPerBunker do
                    local monsterType = availableTypes[math.random(1, #availableTypes)]
                    self:SpawnMonster(monsterType, day, bunker)
                end
            end
        end
    end

    print("[MonsterManager] Spawned " .. totalMonsters .. " monsters" .. (isBossNight and " + 1 BOSS" or ""))
end

-- Get available monster types for day
function MonsterManager:GetAvailableMonsterTypes(day)
    local types = {"BasicZombie"}

    if day >= 4 then
        table.insert(types, "FastZombie")
    end
    if day >= 7 then
        table.insert(types, "TankZombie")
    end
    if day >= 10 then
        table.insert(types, "Crawler")
    end

    return types
end

-- Spawn a single monster
function MonsterManager:SpawnMonster(monsterType, day, target)
    local data = MONSTER_DATA[monsterType]
    if not data then
        warn("[MonsterManager] Unknown monster type:", monsterType)
        return
    end

    -- Apply difficulty scaling
    local scaledHP = data.Health * (1 + day * 0.15)
    local scaledDamage = data.Damage * (1 + day * 0.10)

    -- Create monster model
    local monster = self:CreateMonsterModel(data, scaledHP)

    -- Spawn position (random around map perimeter)
    local spawnPos = self:GetPerimeterSpawnPosition()
    monster:SetPrimaryPartCFrame(CFrame.new(spawnPos))

    -- Add to world
    monster.Parent = workspace.Monsters

    -- Create monster AI controller
    local monsterData = {
        Model = monster,
        Type = monsterType,
        Health = scaledHP,
        MaxHealth = scaledHP,
        Damage = scaledDamage,
        AttackSpeed = data.AttackSpeed,
        StructureDamage = data.StructureDamage,
        CoinDrop = data.CoinDrop,
        Target = target,
        LastAttackTime = 0,
        IsAlive = true,
    }

    table.insert(self.Monsters, monsterData)

    -- Start AI
    self:StartMonsterAI(monsterData)

    return monsterData
end

-- Spawn boss
function MonsterManager:SpawnBoss(day)
    local data = MONSTER_DATA.Boss

    -- Scale boss HP based on player count and day
    local alivePlayers = self.GameManager:GetAlivePlayers()
    local playerCount = #alivePlayers

    local baseHP = 300 + (math.floor(day / 7) - 1) * 200

    -- Scale with player count
    if playerCount == 2 then
        baseHP = baseHP * 1.5
    elseif playerCount >= 3 then
        baseHP = baseHP * 2
    end

    -- Create boss
    local boss = self:CreateMonsterModel(data, baseHP)
    boss.Name = "BOSS"

    -- Spawn in center of map
    local spawnPos = self:GetCenterPosition()
    boss:SetPrimaryPartCFrame(CFrame.new(spawnPos + Vector3.new(0, 10, 0)))

    boss.Parent = workspace.Monsters

    -- Boss AI
    local bossData = {
        Model = boss,
        Type = "Boss",
        Health = baseHP,
        MaxHealth = baseHP,
        Damage = data.Damage * 1.5, -- Boss deals more damage
        AttackSpeed = data.AttackSpeed,
        StructureDamage = data.StructureDamage,
        CoinDrop = data.CoinDrop,
        Target = nil, -- Will target nearest player
        LastAttackTime = 0,
        IsAlive = true,
        IsBoss = true,
    }

    table.insert(self.Monsters, bossData)
    self:StartMonsterAI(bossData)

    print("[MonsterManager] BOSS SPAWNED with " .. baseHP .. " HP!")
end

-- Create monster model
function MonsterManager:CreateMonsterModel(data, health)
    local model = Instance.new("Model")
    model.Name = data.Name

    -- Main body part
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = data.Size
    body.Color = data.Color
    body.Material = Enum.Material.SmoothPlastic
    body.Anchored = false
    body.CanCollide = true
    body.Parent = model

    -- Create humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = health
    humanoid.Health = health
    humanoid.WalkSpeed = data.WalkSpeed
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.Parent = model

    -- Add health bar
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 100, 0, 20)
    billboardGui.StudsOffset = Vector3.new(0, data.Size.Y / 2 + 1, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = body

    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(1, 0, 1, 0)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = billboardGui

    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBg

    -- Set primary part
    model.PrimaryPart = body

    -- Add simple animations (bobbing)
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = body

    return model
end

-- Start monster AI
function MonsterManager:StartMonsterAI(monsterData)
    task.spawn(function()
        while monsterData.IsAlive and monsterData.Model and monsterData.Model.Parent do
            -- Update target (retarget every 2 seconds)
            if tick() % 2 < 0.5 then
                monsterData.Target = self:GetBestTarget(monsterData)
            end

            -- Move towards target
            if monsterData.Target then
                self:MoveToTarget(monsterData)
            end

            -- Check for attack
            self:TryAttack(monsterData)

            task.wait(0.5) -- Update every 0.5 seconds
        end
    end)
end

-- Get best target for monster
function MonsterManager:GetBestTarget(monsterData)
    -- Check for outside players first
    local outsidePlayers = self:GetPlayersOutsideBunkers()

    if #outsidePlayers > 0 then
        -- Target nearest outside player
        return self:GetNearestTarget(monsterData, outsidePlayers)
    else
        -- Target nearest bunker
        local bunkers = self:GetAllBunkers()
        if #bunkers > 0 then
            return self:GetNearestTarget(monsterData, bunkers)
        end
    end

    return nil
end

-- Get nearest target
function MonsterManager:GetNearestTarget(monsterData, targets)
    if #targets == 0 then return nil end

    local monsterPos = monsterData.Model.PrimaryPart.Position
    local nearestTarget = targets[1]
    local nearestDist = math.huge

    for _, target in ipairs(targets) do
        local targetPos
        if target:IsA("Player") and target.Character then
            targetPos = target.Character.PrimaryPart.Position
        elseif target:IsA("Model") then
            targetPos = target.PrimaryPart.Position
        end

        if targetPos then
            local dist = (monsterPos - targetPos).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestTarget = target
            end
        end
    end

    return nearestTarget
end

-- Move monster to target
function MonsterManager:MoveToTarget(monsterData)
    local target = monsterData.Target
    if not target then return end

    local targetPos
    if target:IsA("Player") and target.Character and target.Character.PrimaryPart then
        targetPos = target.Character.PrimaryPart.Position
    elseif target:IsA("Model") and target.PrimaryPart then
        targetPos = target.PrimaryPart.Position
    end

    if not targetPos then return end

    -- Simple movement (just move towards target)
    local humanoid = monsterData.Model:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:MoveTo(targetPos)
    end
end

-- Try to attack
function MonsterManager:TryAttack(monsterData)
    local target = monsterData.Target
    if not target then return end

    -- Check attack cooldown
    local attackInterval = 1 / monsterData.AttackSpeed
    if tick() - monsterData.LastAttackTime < attackInterval then
        return
    end

    -- Check if in range
    local monsterPos = monsterData.Model.PrimaryPart.Position
    local targetPos

    if target:IsA("Player") and target.Character and target.Character.PrimaryPart then
        targetPos = target.Character.PrimaryPart.Position

        -- Attack player
        local dist = (monsterPos - targetPos).Magnitude
        if dist <= 5 then -- Attack range
            local humanoid = target.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid:TakeDamage(monsterData.Damage)
                monsterData.LastAttackTime = tick()
                print("[MonsterManager] Monster attacked player:", target.Name)
            end
        end
    elseif target:IsA("Model") and target.PrimaryPart then
        -- Attack bunker
        targetPos = target.PrimaryPart.Position
        local dist = (monsterPos - targetPos).Magnitude

        if dist <= 8 then -- Bunker attack range
            if self.BunkerManager then
                self.BunkerManager:DamageBunker(target, monsterData.StructureDamage)
                monsterData.LastAttackTime = tick()
                print("[MonsterManager] Monster attacked bunker")
            end
        end
    end
end

-- Monster took damage
function MonsterManager:DamageMonster(monsterData, damage, attacker)
    monsterData.Health = math.max(0, monsterData.Health - damage)

    -- Update health bar
    local healthBar = monsterData.Model.PrimaryPart:FindFirstChild("BillboardGui")
    if healthBar then
        local bar = healthBar:FindFirstChild("Frame"):FindFirstChild("HealthBar")
        if bar then
            local healthPercent = monsterData.Health / monsterData.MaxHealth
            bar.Size = UDim2.new(healthPercent, 0, 1, 0)
        end
    end

    -- Check death
    if monsterData.Health <= 0 then
        self:KillMonster(monsterData, attacker)
    end
end

-- Kill monster
function MonsterManager:KillMonster(monsterData, killer)
    monsterData.IsAlive = false

    -- Award coins to killer
    if killer and killer:IsA("Player") then
        if self.GameManager then
            self.GameManager:AwardCoins(killer, monsterData.CoinDrop, "Monster kill")

            -- Track stats
            local stats = killer:FindFirstChild("PlayerData"):FindFirstChild("Stats")
            if stats then
                local monstersKilled = stats:FindFirstChild("MonstersKilled")
                if monstersKilled then
                    monstersKilled.Value = monstersKilled.Value + 1
                end
            end
        end
    end

    -- Remove model
    if monsterData.Model then
        monsterData.Model:Destroy()
    end

    -- Remove from list
    for i, monster in ipairs(self.Monsters) do
        if monster == monsterData then
            table.remove(self.Monsters, i)
            break
        end
    end

    print("[MonsterManager] Monster killed by:", killer and killer.Name or "Unknown")
end

-- Get players outside bunkers
function MonsterManager:GetPlayersOutsideBunkers()
    local outsidePlayers = {}

    for _, player in ipairs(self.GameManager:GetAlivePlayers()) do
        if player.Character and player.Character.PrimaryPart then
            -- Check if player is inside any bunker
            -- (This will be implemented when bunkers exist)
            -- For now, assume all players are outside
            table.insert(outsidePlayers, player)
        end
    end

    return outsidePlayers
end

-- Get all bunkers
function MonsterManager:GetAllBunkers()
    local bunkers = {}

    -- Get bunkers from BunkerManager when implemented
    if self.BunkerManager then
        bunkers = self.BunkerManager:GetAllBunkers()
    else
        -- Fallback: find bunker models in workspace
        local bunkersFolder = workspace:FindFirstChild("Bunkers")
        if bunkersFolder then
            for _, bunker in ipairs(bunkersFolder:GetChildren()) do
                table.insert(bunkers, bunker)
            end
        end
    end

    return bunkers
end

-- Get random perimeter spawn position
function MonsterManager:GetPerimeterSpawnPosition()
    local spawnRadius = 150
    local angle = math.random() * math.pi * 2

    local x = math.cos(angle) * spawnRadius
    local z = math.sin(angle) * spawnRadius
    local y = 5

    return Vector3.new(x, y, z)
end

-- Get center position
function MonsterManager:GetCenterPosition()
    local mapCenter = workspace:FindFirstChild("MapCenter")
    if mapCenter then
        return mapCenter.Position
    else
        return Vector3.new(0, 5, 0)
    end
end

-- Remove all monsters
function MonsterManager:RemoveAllMonsters()
    for _, monsterData in ipairs(self.Monsters) do
        if monsterData.Model then
            monsterData.Model:Destroy()
        end
    end

    self.Monsters = {}
    print("[MonsterManager] All monsters removed")
end

return MonsterManager
