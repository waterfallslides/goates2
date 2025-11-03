--[[
	ProfileService PLACEHOLDER
	This is a TEMPORARY mock for testing without ProfileService installed

	⚠️ IMPORTANT: Replace this with the real ProfileService from:
	https://github.com/MadStudioRoblox/ProfileService

	This mock provides basic functionality but NO DATA PERSISTENCE!
	Use only for testing the game structure.
]]

local ProfileService = {}
local MockProfileStore = {}
MockProfileStore.__index = MockProfileStore

-- Mock Profile
local MockProfile = {}
MockProfile.__index = MockProfile

function MockProfile:AddUserId(userId)
	-- Mock implementation
end

function MockProfile:Reconcile()
	-- Fill in missing data from template
	for key, value in pairs(self._template) do
		if self.Data[key] == nil then
			if type(value) == "table" then
				self.Data[key] = {}
				for k, v in pairs(value) do
					self.Data[key][k] = v
				end
			else
				self.Data[key] = value
			end
		end
	end
end

function MockProfile:ListenToRelease(callback)
	self._releaseCallback = callback
end

function MockProfile:Release()
	if self._releaseCallback then
		self._releaseCallback()
	end
	print("Mock Profile released")
end

-- Mock ProfileStore
function MockProfileStore:LoadProfileAsync(key)
	print("⚠️ MOCK ProfileService - NO DATA PERSISTENCE!")

	-- Create a mock profile
	local profile = setmetatable({
		Data = {},
		_template = self._template,
		_key = key,
		_releaseCallback = nil
	}, MockProfile)

	-- Initialize with template
	for key, value in pairs(self._template) do
		if type(value) == "table" then
			profile.Data[key] = {}
			for k, v in pairs(value) do
				profile.Data[key][k] = v
			end
		else
			profile.Data[key] = value
		end
	end

	return profile
end

-- Get ProfileStore
function ProfileService.GetProfileStore(name, template)
	print("Creating MOCK ProfileStore:", name)
	return setmetatable({
		_name = name,
		_template = template
	}, MockProfileStore)
end

warn([[
⚠️⚠️⚠️ USING MOCK PROFILESERVICE - NO DATA PERSISTENCE! ⚠️⚠️⚠️

This is a temporary placeholder. Install the real ProfileService:
https://github.com/MadStudioRoblox/ProfileService

Place it in ServerStorage as "ProfileService" (ModuleScript)
]])

return ProfileService
