--[[
	InstallationChecker.lua
	COMPREHENSIVE setup checker with automated fixes

	Place in ServerScriptService/Server/ as a Script
	Right-click → Run Script
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=" :rep(60))
print("🔧 INSTALLATION CHECKER - Detailed Diagnostics")
print("=" :rep(60))

local errors = {}
local warnings = {}

local function error(msg)
	table.insert(errors, msg)
	warn("❌ ERROR:", msg)
end

local function warning(msg)
	table.insert(warnings, msg)
	warn("⚠️  WARNING:", msg)
end

local function success(msg)
	print("✅", msg)
end

-- Check Server folder structure
print("\n📁 Checking ServerScriptService.Server structure...")

local server = ServerScriptService:FindFirstChild("Server")
if not server then
	error("Server folder missing in ServerScriptService")
	warn("   CREATE: ServerScriptService → Insert Object → Folder → Name it 'Server'")
else
	success("Server folder exists")

	-- Check Core
	local core = server:FindFirstChild("Core")
	if not core then
		error("Core folder missing in Server")
		warn("   CREATE: Server → Insert Object → Folder → Name it 'Core'")
	else
		success("Core folder exists")

		-- Check Core contents
		local coreModules = {"DataManager", "RollingSystem", "StealingSystem"}
		for _, moduleName in ipairs(coreModules) do
			local module = core:FindFirstChild(moduleName)
			if not module then
				error(moduleName .. " missing in Core")
			elseif not module:IsA("ModuleScript") then
				error(moduleName .. " is NOT a ModuleScript (it's a " .. module.ClassName .. ")")
				warn("   FIX: Delete it, Insert Object → ModuleScript, paste code")
			else
				success(moduleName .. " exists and is ModuleScript")
			end
		end
	end

	-- Check Systems
	local systems = server:FindFirstChild("Systems")
	if not systems then
		error("Systems folder missing in Server")
		warn("   CREATE: Server → Insert Object → Folder → Name it 'Systems'")
	else
		success("Systems folder exists")

		local systemModules = {"BaseManager", "RebirthHandler"}
		for _, moduleName in ipairs(systemModules) do
			local module = systems:FindFirstChild(moduleName)
			if not module then
				error(moduleName .. " missing in Systems")
			elseif not module:IsA("ModuleScript") then
				error(moduleName .. " is NOT a ModuleScript")
			else
				success(moduleName .. " exists and is ModuleScript")
			end
		end
	end

	-- Check Leaderboards ⚠️ THIS IS YOUR ISSUE!
	local leaderboards = server:FindFirstChild("Leaderboards")
	if not leaderboards then
		error("Leaderboards folder missing in Server")
		warn("   CREATE: Server → Insert Object → Folder → Name it 'Leaderboards'")
		warn("   THEN: Insert ModuleScript inside Leaderboards, name it 'StatsManager'")
	else
		success("Leaderboards folder exists")

		local statsManager = leaderboards:FindFirstChild("StatsManager")
		if not statsManager then
			error("StatsManager missing in Leaderboards")
		elseif not statsManager:IsA("ModuleScript") then
			error("StatsManager is NOT a ModuleScript")
		else
			success("StatsManager exists and is ModuleScript")
		end
	end

	-- Check MockProfileService
	local mockPS = server:FindFirstChild("MockProfileService")
	if not mockPS then
		warning("MockProfileService missing - needed as fallback")
	elseif not mockPS:IsA("ModuleScript") then
		error("MockProfileService is NOT a ModuleScript")
	else
		success("MockProfileService exists")
	end

	-- Check MainServer
	local mainServer = server:FindFirstChild("MainServer")
	if not mainServer then
		error("MainServer missing in Server")
	elseif not mainServer:IsA("Script") then
		error("MainServer is NOT a Script (it's a " .. mainServer.ClassName .. ")")
		warn("   FIX: It should be a Script (red icon), not ModuleScript")
	else
		success("MainServer exists and is Script")
	end
end

-- Check ProfileService
print("\n💾 Checking ProfileService...")
local profileService = ServerStorage:FindFirstChild("ProfileService")
if not profileService then
	warning("ProfileService not found in ServerStorage")
	print("   → Will use MockProfileService (no data persistence)")
	print("   → This is OK for testing!")
else
	if not profileService:IsA("ModuleScript") then
		error("ProfileService is NOT a ModuleScript (it's a " .. profileService.ClassName .. ")")
	else
		success("ProfileService found in ServerStorage")

		-- Try to require it
		local success, result = pcall(function()
			return require(profileService)
		end)

		if success then
			success("ProfileService loads successfully")
		else
			error("ProfileService has errors when loading:")
			warn("   Error: " .. tostring(result))
			warn("   → Download correct version from: https://github.com/MadStudioRoblox/ProfileService")
			warn("   → Make sure it's the MAIN module, not a subfolder")
		end
	end
end

-- Check ReplicatedStorage
print("\n📦 Checking ReplicatedStorage.Modules...")
local modules = ReplicatedStorage:FindFirstChild("Modules")
if not modules then
	error("Modules folder missing in ReplicatedStorage")
	warn("   CREATE: ReplicatedStorage → Insert Object → Folder → Name it 'Modules'")
else
	success("Modules folder exists")

	local moduleList = {"BrainrotData", "Config"}
	for _, moduleName in ipairs(moduleList) do
		local module = modules:FindFirstChild(moduleName)
		if not module then
			error(moduleName .. " missing in Modules")
		elseif not module:IsA("ModuleScript") then
			error(moduleName .. " is NOT a ModuleScript")
		else
			success(moduleName .. " exists and is ModuleScript")
		end
	end
end

-- Summary
print("\n" .. "=" :rep(60))
print("📊 SUMMARY")
print("=" :rep(60))

if #errors == 0 and #warnings == 0 then
	print("✅ ALL CHECKS PASSED!")
	print("You can now run MainServer")
elseif #errors == 0 then
	print("✅ No critical errors, but " .. #warnings .. " warnings")
	print("Game will run but may have issues")
else
	print("❌ FOUND " .. #errors .. " ERROR(S) and " .. #warnings .. " WARNING(S)")
	print("\nFIX THESE ERRORS:")
	for i, err in ipairs(errors) do
		print(i .. ". " .. err)
	end
end

print("=" :rep(60))
