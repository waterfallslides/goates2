--[[
	BrainrotImageGenerator.lua
	Generates ViewportFrame images from brainrot models
	SIMPLE, CLEAN, OPTIMIZED

	Place in: ReplicatedStorage/Modules/BrainrotImageGenerator
]]

local BrainrotImageGenerator = {}

-- Cache for viewport frames
local viewportCache = {}

--[[
	Creates a ViewportFrame that displays a brainrot model
	@param brainrotID - The ID of the brainrot (e.g., "SkibidiToilet")
	@param parent - Parent GUI element for the ViewportFrame
	@return ViewportFrame or nil if model not found
]]
function BrainrotImageGenerator.CreateViewportForBrainrot(brainrotID, parent)
	-- Check cache first
	if viewportCache[brainrotID] then
		local cachedViewport = viewportCache[brainrotID]:Clone()
		cachedViewport.Parent = parent
		return cachedViewport
	end

	-- Try to find the model in ReplicatedStorage (copied from ServerStorage by server)
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local brainrotsFolder = replicatedStorage:FindFirstChild("BrainrotModels")

	if not brainrotsFolder then
		warn("BrainrotImageGenerator: BrainrotModels folder not found in ReplicatedStorage")
		warn("  Make sure server has replicated models from ServerStorage!")
		return nil
	end

	-- Search for the model (it might be in a rarity subfolder)
	local modelToClone = nil

	-- First, try direct lookup
	modelToClone = brainrotsFolder:FindFirstChild(brainrotID)

	-- If not found, search in subfolders (Common, Rare, etc.)
	if not modelToClone then
		for _, rarityFolder in ipairs(brainrotsFolder:GetChildren()) do
			if rarityFolder:IsA("Folder") then
				local foundModel = rarityFolder:FindFirstChild(brainrotID)
				if foundModel then
					modelToClone = foundModel
					break
				end
			end
		end
	end

	if not modelToClone then
		warn("BrainrotImageGenerator: Model not found for brainrotID:", brainrotID)
		return nil
	end

	-- Create ViewportFrame
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Size = UDim2.new(1, 0, 1, 0)
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.BorderSizePixel = 0

	-- Clone the model
	local modelClone = modelToClone:Clone()

	-- Make sure it's a Model
	if not modelClone:IsA("Model") then
		-- If it's just a part, wrap it in a model
		local wrapperModel = Instance.new("Model")
		modelClone.Parent = wrapperModel
		modelClone = wrapperModel
	end

	-- Set the model's parent to the viewport
	modelClone.Parent = viewportFrame

	-- Calculate the model's size and center
	local cf, size = modelClone:GetBoundingBox()

	-- Create a camera
	local camera = Instance.new("Camera")
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	-- Position camera to look at model from the front
	-- Calculate distance based on model size
	local maxSize = math.max(size.X, size.Y, size.Z)
	local distance = maxSize * 2.5  -- Adjust multiplier for better framing

	-- Position camera in front of the model
	local cameraPosition = cf.Position + (cf.LookVector * -distance)
	camera.CFrame = CFrame.new(cameraPosition, cf.Position)

	-- Adjust camera field of view for better framing
	camera.FieldOfView = 40

	-- Cache the viewport
	viewportCache[brainrotID] = viewportFrame:Clone()

	-- Set parent
	viewportFrame.Parent = parent

	print("✓ Created viewport for:", brainrotID)
	return viewportFrame
end

--[[
	Updates an existing ImageLabel to use a ViewportFrame instead
	@param imageLabel - The ImageLabel to replace with a viewport
	@param brainrotID - The ID of the brainrot to display
]]
function BrainrotImageGenerator.ReplaceImageWithViewport(imageLabel, brainrotID)
	if not imageLabel then
		warn("BrainrotImageGenerator: imageLabel is nil")
		return nil
	end

	-- Create viewport with same properties as the image label
	local viewport = BrainrotImageGenerator.CreateViewportForBrainrot(brainrotID, imageLabel.Parent)

	if viewport then
		-- Copy properties from image label
		viewport.Position = imageLabel.Position
		viewport.Size = imageLabel.Size
		viewport.AnchorPoint = imageLabel.AnchorPoint
		viewport.ZIndex = imageLabel.ZIndex
		viewport.LayoutOrder = imageLabel.LayoutOrder

		-- Hide the original image label
		imageLabel.Visible = false

		return viewport
	end

	return nil
end

--[[
	Sets up a ViewportFrame to display inside an existing ImageLabel
	(Creates the viewport as a child of the ImageLabel)
	@param imageLabel - The ImageLabel to use as container
	@param brainrotID - The ID of the brainrot to display
]]
function BrainrotImageGenerator.SetupViewportInImage(imageLabel, brainrotID)
	if not imageLabel then
		warn("BrainrotImageGenerator: imageLabel is nil")
		return nil
	end

	-- Clear the image
	imageLabel.Image = ""
	imageLabel.BackgroundTransparency = 1

	-- Remove any existing viewports
	for _, child in ipairs(imageLabel:GetChildren()) do
		if child:IsA("ViewportFrame") then
			child:Destroy()
		end
	end

	-- Create viewport inside the image label
	local viewport = BrainrotImageGenerator.CreateViewportForBrainrot(brainrotID, imageLabel)

	return viewport
end

--[[
	Clears the viewport cache (useful if models change)
]]
function BrainrotImageGenerator.ClearCache()
	viewportCache = {}
	print("✓ ViewportFrame cache cleared")
end

print("✓ BrainrotImageGenerator loaded")

return BrainrotImageGenerator
