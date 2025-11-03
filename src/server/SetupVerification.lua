--[[
	SetupVerification.lua
	Checks if all required game components are properly set up

	Place this as a Script in ServerScriptService and run it first
	to verify your setup before running MainServer
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

print("=====================================")
print("🔍 RNG Brainrot Game - Setup Verification")
print("=====================================")

local allGood = true

local function check(condition, successMsg, errorMsg)
	if condition then
		print("✓", successMsg)
		return true
	else
		warn("✗", errorMsg)
		allGood = false
		return false
	end
end

-- Check ReplicatedStorage modules
print("\n📦 Checking ReplicatedStorage...")
local modules = ReplicatedStorage:FindFirstChild("Modules")
check(modules ~= nil, "Modules folder exists", "Modules folder not found in ReplicatedStorage")

if modules then
	check(modules:FindFirstChild("BrainrotData") ~= nil, "BrainrotData module exists", "BrainrotData not found in Modules")
	check(modules:FindFirstChild("Config") ~= nil, "Config module exists", "Config not found in Modules")
end

-- Check ServerScriptService structure
print("\n🖥️ Checking ServerScriptService...")
local server = ServerScriptService:FindFirstChild("Server")
check(server ~= nil, "Server folder exists", "Server folder not found in ServerScriptService")

if server then
	-- Check Core
	local core = server:FindFirstChild("Core")
	check(core ~= nil, "Core folder exists", "Core folder not found in Server")

	if core then
		check(core:FindFirstChild("DataManager") ~= nil, "DataManager exists", "DataManager not found in Core")
		check(core:FindFirstChild("RollingSystem") ~= nil, "RollingSystem exists", "RollingSystem not found in Core")
		check(core:FindFirstChild("StealingSystem") ~= nil, "StealingSystem exists", "StealingSystem not found in Core")
	end

	-- Check Systems
	local systems = server:FindFirstChild("Systems")
	check(systems ~= nil, "Systems folder exists", "Systems folder not found in Server")

	if systems then
		check(systems:FindFirstChild("BaseManager") ~= nil, "BaseManager exists", "BaseManager not found in Systems")
		check(systems:FindFirstChild("RebirthHandler") ~= nil, "RebirthHandler exists", "RebirthHandler not found in Systems")
	end

	-- Check Leaderboards
	local leaderboards = server:FindFirstChild("Leaderboards")
	check(leaderboards ~= nil, "Leaderboards folder exists", "Leaderboards folder not found in Server")

	if leaderboards then
		check(leaderboards:FindFirstChild("StatsManager") ~= nil, "StatsManager exists", "StatsManager not found in Leaderboards")
	end

	-- Check Tools
	local tools = server:FindFirstChild("Tools")
	check(tools ~= nil, "Tools folder exists", "Tools folder not found in Server")

	if tools then
		check(tools:FindFirstChild("GiveSlapTool") ~= nil, "GiveSlapTool exists", "GiveSlapTool not found in Tools")
	end

	-- Check MainServer
	check(server:FindFirstChild("MainServer") ~= nil, "MainServer exists", "MainServer not found in Server folder")

	-- Check MockProfileService
	check(server:FindFirstChild("MockProfileService") ~= nil, "MockProfileService exists (fallback)", "MockProfileService not found - will cause errors without ProfileService!")
end

-- Check ServerStorage
print("\n💾 Checking ServerStorage...")
local profileService = ServerStorage:FindFirstChild("ProfileService")
if profileService then
	print("✓ ProfileService installed (REAL data persistence)")
else
	warn("⚠️ ProfileService NOT found - will use MOCK (NO DATA PERSISTENCE)")
	warn("   Install from: https://github.com/MadStudioRoblox/ProfileService")
end

local slapTool = ServerStorage:FindFirstChild("SlapTool")
check(slapTool ~= nil, "SlapTool exists", "SlapTool not found in ServerStorage")

if slapTool then
	check(slapTool:FindFirstChild("Handle") ~= nil, "SlapTool has Handle", "SlapTool missing Handle part")
	check(slapTool:FindFirstChild("SlapTool") ~= nil, "SlapTool has Script", "SlapTool missing Script")
end

-- Check ServerStorage.Brainrots
local brainrots = ServerStorage:FindFirstChild("Brainrots")
check(brainrots ~= nil, "Brainrots folder exists", "Brainrots folder not found in ServerStorage")

if brainrots then
	local rarities = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret", "BrainrotGod"}
	for _, rarity in ipairs(rarities) do
		local found = brainrots:FindFirstChild(rarity) ~= nil
		if found then
			print("  ✓", rarity, "folder exists")
		else
			warn("  ✗", rarity, "folder not found")
			allGood = false
		end
	end
end

-- Check StarterGui
print("\n🖼️ Checking StarterGui...")
local newwGui = StarterGui:FindFirstChild("neww")
check(newwGui ~= nil, "neww ScreenGui exists", "neww ScreenGui not found in StarterGui")

if newwGui then
	check(newwGui:FindFirstChild("DiceFrame") ~= nil, "DiceFrame exists", "DiceFrame not found in neww")
	check(newwGui:FindFirstChild("Index") ~= nil, "Index frame exists", "Index frame not found in neww")
	check(newwGui:FindFirstChild("Rebirth") ~= nil, "Rebirth frame exists", "Rebirth frame not found in neww")
	check(newwGui:FindFirstChild("CashStore") ~= nil, "CashStore exists", "CashStore not found in neww")

	-- Check LocalScripts
	local diceFrame = newwGui:FindFirstChild("DiceFrame")
	if diceFrame then
		check(diceFrame:FindFirstChildWhichIsA("LocalScript") ~= nil, "DiceFrame has LocalScript", "DiceFrame missing RollHandler LocalScript")
	end

	local index = newwGui:FindFirstChild("Index")
	if index then
		check(index:FindFirstChildWhichIsA("LocalScript") ~= nil, "Index has LocalScript", "Index missing IndexHandler LocalScript")
	end

	local rebirth = newwGui:FindFirstChild("Rebirth")
	if rebirth then
		check(rebirth:FindFirstChildWhichIsA("LocalScript") ~= nil, "Rebirth has LocalScript", "Rebirth missing RebirthUIHandler LocalScript")
	end

	check(newwGui:FindFirstChild("OpenButtonsHandler") ~= nil, "OpenButtonsHandler exists", "OpenButtonsHandler LocalScript not found in neww")
end

check(StarterGui:FindFirstChild("NotificationHandler") ~= nil, "NotificationHandler exists", "NotificationHandler LocalScript not found in StarterGui")

-- Check Workspace
print("\n🌍 Checking Workspace...")
local bases = Workspace:FindFirstChild("Bases")
if check(bases ~= nil, "Bases folder exists", "Bases folder not found in Workspace - players need bases!") then
	local baseCount = 0
	for _, child in ipairs(bases:GetChildren()) do
		if child.Name:match("^Base%d+$") then
			baseCount = baseCount + 1
		end
	end

	if baseCount > 0 then
		print("  ✓ Found", baseCount, "player base(s)")
	else
		warn("  ⚠️ No player bases found (Base[UserId] format)")
		warn("      Create at least one test base: Bases/Base12345")
	end
end

-- Final result
print("\n=====================================")
if allGood then
	print("✅ SETUP VERIFICATION PASSED!")
	print("You can now run MainServer")
else
	warn("❌ SETUP VERIFICATION FAILED!")
	warn("Fix the issues above before running MainServer")
	warn("See IMPLEMENTATION_GUIDE.md for detailed setup instructions")
end
print("=====================================")
