--[[
	DiagnosticScript.lua
	This will tell us EXACTLY what's in your GUI so we can connect it properly

	Place in: StarterGui/neww/ as LocalScript
	Run it, check Output, then DELETE it after we see the structure
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = script.Parent -- neww

print("=" :rep(60))
print("🔍 DIAGNOSTIC - Checking YOUR GUI Structure")
print("=" :rep(60))

-- Check DiceFrame
print("\n📦 Looking for DiceFrame...")
local diceFrame = gui:FindFirstChild("DiceFrame")
if diceFrame then
	print("✓ DiceFrame found!")
	print("\n  Contents of DiceFrame:")
	for _, child in ipairs(diceFrame:GetChildren()) do
		print("    -", child.Name, "(" .. child.ClassName .. ")")
	end
else
	warn("✗ DiceFrame NOT FOUND!")
	print("  Available children in neww:")
	for _, child in ipairs(gui:GetChildren()) do
		print("    -", child.Name, "(" .. child.ClassName .. ")")
	end
end

-- Check RollingFrame
print("\n📦 Looking for RollingFrame...")
local rollingFrame = gui:FindFirstChild("RollingFrame")
if rollingFrame then
	print("✓ RollingFrame found!")
	print("\n  Contents of RollingFrame:")
	for _, child in ipairs(rollingFrame:GetChildren()) do
		print("    -", child.Name, "(" .. child.ClassName .. ")")
	end
else
	warn("✗ RollingFrame NOT FOUND!")
	print("  Available children in neww:")
	for _, child in ipairs(gui:GetChildren()) do
		print("    -", child.Name, "(" .. child.ClassName .. ")")
	end
end

-- Check what we're looking for specifically
print("\n🔍 Checking for specific elements...")

if diceFrame then
	print("\nIn DiceFrame, looking for:")
	print("  Roll button:", diceFrame:FindFirstChild("Roll") and "✓ FOUND" or "✗ NOT FOUND")
	print("  AutoRoll button:", diceFrame:FindFirstChild("AutoRoll") and "✓ FOUND" or "✗ NOT FOUND")
	print("  FastRoll button:", diceFrame:FindFirstChild("FastRoll") and "✓ FOUND" or "✗ NOT FOUND")
end

if rollingFrame then
	print("\nIn RollingFrame, looking for:")
	print("  BrainrotImage:", rollingFrame:FindFirstChild("BrainrotImage") and "✓ FOUND" or "✗ NOT FOUND")
	print("  Keep button:", rollingFrame:FindFirstChild("Keep") and "✓ FOUND" or "✗ NOT FOUND")
	print("  Rarity label:", rollingFrame:FindFirstChild("Rarity") and "✓ FOUND" or "✗ NOT FOUND")
	print("  Rolling label:", rollingFrame:FindFirstChild("Rolling") and "✓ FOUND" or "✗ NOT FOUND")
	print("  Name label:", rollingFrame:FindFirstChild("Name") and "✓ FOUND" or "✗ NOT FOUND")
end

-- Check ReplicatedStorage Events
print("\n📡 Checking ReplicatedStorage...")
local events = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
if events then
	print("✓ Events folder found!")
	print("  Contents:")
	for _, child in ipairs(events:GetChildren()) do
		print("    -", child.Name, "(" .. child.ClassName .. ")")
	end
else
	warn("✗ Events folder NOT FOUND in ReplicatedStorage!")
end

print("\n" .. "=" :rep(60))
print("🎯 COPY THE OUTPUT ABOVE AND SHOW ME!")
print("=" :rep(60))
