--[[
╔════════════════════════════════════════════════════════════════╗
║           ThemeRecolor.lua v8.2 - STABLE VERSION               ║
║                      Made By Redz                              ║
║                    Error Fixed Edition                         ║
╚════════════════════════════════════════════════════════════════╝

KEY: STUDIORIS2024
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== KONFIGURASI WARNA TEMA ======
local THEME = {
	FrameColor       = Color3.fromRGB(46, 46, 46),
	FrameColorAlt    = Color3.fromRGB(56, 56, 56),
	BorderColor      = Color3.fromRGB(35, 35, 35),
	TextColor        = Color3.fromRGB(255, 255, 255),
	TextButtonColor  = Color3.fromRGB(60, 60, 60),
	TextButtonHover  = Color3.fromRGB(75, 75, 75),
	TextBoxColor     = Color3.fromRGB(38, 38, 38),
	SeparatorBlue    = Color3.fromRGB(0, 120, 215),
}

local protectedObjects = {}
local protectedConnections = {}

-- ====== FUNGSI CEK NIL ======
local function isValid(obj)
	if obj == nil then return false end
	if not pcall(function() return obj.Parent end) then return false end
	return true
end

-- ====== FUNGSI CEK WARNA MERAH ======
local function isRedColor(color)
	if not color then return false end
	return color.R > 0.6 and color.G < 0.3 and color.B < 0.3
end

-- ====== FUNGSI CEK SELECT MULTIBUTTON ======
local function isSelectMultiButton(obj)
	if not isValid(obj) then return false end
	if not obj:IsA("GuiButton") then return false end
	return obj.Name == "Select MultiButton" or obj.Name == "SelectMultiButton"
end

-- ====== FUNGSI CEK BUTTON DALAM FOLDER DI COLORPALETTE ======
local function isButtonInFolderInsideColorPalette(obj)
	if not isValid(obj) then return false end
	if not obj:IsA("GuiButton") then return false end
	
	local parent = obj.Parent
	if parent and parent:IsA("Folder") then
		local grandparent = parent.Parent
		while grandparent and grandparent ~= playerGui do
			if grandparent:IsA("Frame") and grandparent.Name == "ColorPalette" then
				return true
			end
			grandparent = grandparent.Parent
		end
	end
	return false
end

-- ====== FUNGSI PROTEKSI WARNA ======
local function protectColorProperty(obj, propertyName, correctValue)
	if not isValid(obj) then return end
	
	if protectedObjects[obj] and protectedObjects[obj][propertyName] then
		return
	end
	
	if not protectedObjects[obj] then
		protectedObjects[obj] = {}
	end
	protectedObjects[obj][propertyName] = true
	
	local connection
	connection = obj:GetPropertyChangedSignal(propertyName):Connect(function()
		if isValid(obj) then
			pcall(function()
				if propertyName == "TextColor3" then
					if not isRedColor(obj[propertyName]) then
						obj[propertyName] = correctValue
					end
				else
					obj[propertyName] = correctValue
				end
			end)
		else
			if connection then
				connection:Disconnect()
			end
		end
	end)
	
	table.insert(protectedConnections, connection)
end

-- ====== BUAT LINE SEPARATOR (BIRU) ======
local function createLineSeparator(parent)
	if not isValid(parent) then return nil end
	
	pcall(function()
		local existingLine = parent:FindFirstChild("LineSeparator")
		if existingLine then
			existingLine:Destroy()
		end
		
		local lineFrame = Instance.new("Frame")
		lineFrame.Name = "LineSeparator"
		lineFrame.Size = UDim2.new(0, 1, 0, 30)
		lineFrame.Position = UDim2.new(0, 405, 0, 3)
		lineFrame.BackgroundColor3 = THEME.SeparatorBlue
		lineFrame.BorderSizePixel = 0
		lineFrame.Parent = parent
		
		return lineFrame
	end)
	
	return nil
end

-- ====== DUPLIKASI PARTSEL BUTTON ======
local function duplicatePartSelButton()
	local studioGui = playerGui:FindFirstChild("StudioGui")
	if not isValid(studioGui) then return end
	
	local mainBar = studioGui:FindFirstChild("MainBar")
	if not isValid(mainBar) then return end
	
	pcall(function()
		local partSelButton = nil
		for _, child in ipairs(mainBar:GetChildren()) do
			if child.Name == "PartSel" then
				partSelButton = child
				break
			end
		end
		
		if not isValid(partSelButton) then return end
		
		local existingPluginBtn = mainBar:FindFirstChild("PluginBtn")
		if existingPluginBtn then
			existingPluginBtn:Destroy()
		end
		
		local pluginBtn = Instance.new("TextButton")
		pluginBtn.Name = "PluginBtn"
		pluginBtn.Size = partSelButton.Size
		pluginBtn.Position = UDim2.new(0, 430, 0, 3)
		pluginBtn.BackgroundColor3 = THEME.TextButtonColor
		pluginBtn.BorderSizePixel = 0
		pluginBtn.TextColor3 = THEME.TextColor
		pluginBtn.TextSize = 14
		pluginBtn.Font = Enum.Font.GothamMedium
		pluginBtn.Text = "Plugin"
		pluginBtn.Parent = mainBar
		
		for _, child in ipairs(partSelButton:GetChildren()) do
			local clonedChild = child:Clone()
			clonedChild.Parent = pluginBtn
		end
		
		protectColorProperty(pluginBtn, "TextColor3", THEME.TextColor)
		protectColorProperty(pluginBtn, "BackgroundColor3", THEME.TextButtonColor)
		
		pluginBtn.MouseEnter:Connect(function()
			if isValid(pluginBtn) then
				pluginBtn.BackgroundColor3 = THEME.TextButtonHover
			end
		end)
		pluginBtn.MouseLeave:Connect(function()
			if isValid(pluginBtn) then
				pluginBtn.BackgroundColor3 = THEME.TextButtonColor
			end
		end)
	end)
end

-- ====== CEK PART OF COLORPALETTE ======
local function isPartOfColorPalette(obj)
	if not isValid(obj) then return false end
	if obj.Name == "ColorPalette" then return true end
	
	local parent = obj.Parent
	while parent and parent ~= playerGui do
		if parent.Name == "ColorPalette" then
			return true
		end
		parent = parent.Parent
	end
	return false
end

-- ====== APPLY COLORPALETTE THEME ======
local function applyColorPaletteTheme(colorPaletteFrame)
	if not isValid(colorPaletteFrame) then return end
	if colorPaletteFrame.Name ~= "ColorPalette" then return end
	
	pcall(function()
		-- Frame background
		if colorPaletteFrame.BackgroundTransparency < 1 then
			colorPaletteFrame.BackgroundColor3 = THEME.FrameColor
			protectColorProperty(colorPaletteFrame, "BackgroundColor3", THEME.FrameColor)
		end
		
		-- Hapus stroke yang ada
		local existingStroke = colorPaletteFrame:FindFirstChildOfClass("UIStroke")
		if isValid(existingStroke) then
			existingStroke:Destroy()
		end
		
		-- Tambah corner
		local existingCorner = colorPaletteFrame:FindFirstChildOfClass("UICorner")
		if not isValid(existingCorner) then
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 12)
			uiCorner.Parent = colorPaletteFrame
		end
		
		-- Center
		colorPaletteFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		colorPaletteFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		-- Theme specific elements
		for _, child in ipairs(colorPaletteFrame:GetDescendants()) do
			if not isValid(child) then continue end
			
			-- OkButton & CancelButton
			if child.Name == "OkButton" or child.Name == "CancelButton" then
				if child:IsA("TextButton") then
					pcall(function()
						child.TextColor3 = THEME.TextColor
						child.BackgroundColor3 = THEME.TextButtonColor
						protectColorProperty(child, "TextColor3", THEME.TextColor)
						protectColorProperty(child, "BackgroundColor3", THEME.TextButtonColor)
						
						local btnStroke = child:FindFirstChildOfClass("UIStroke")
						if isValid(btnStroke) then
							btnStroke:Destroy()
						end
					end)
				end
			end
			
			-- BasicColorsTitle
			elseif child.Name == "BasicColorsTitle" then
				if child:IsA("TextLabel") then
					pcall(function()
						child.TextColor3 = THEME.TextColor
						if child.BackgroundTransparency < 1 then
							child.BackgroundColor3 = THEME.FrameColor
						end
						protectColorProperty(child, "TextColor3", THEME.TextColor)
						if child.BackgroundTransparency < 1 then
							protectColorProperty(child, "BackgroundColor3", THEME.FrameColor)
						end
						
						local labelStroke = child:FindFirstChildOfClass("UIStroke")
						if isValid(labelStroke) then
							labelStroke:Destroy()
						end
					end)
				end
			end
			
			-- SelectedColor, SelectedColorText, SelectedBrickColorText
			elseif child.Name == "SelectedColor" or child.Name == "SelectedColorText" or child.Name == "SelectedBrickColorText" then
				if child:IsA("TextLabel") then
					pcall(function()
						child.TextColor3 = THEME.TextColor
						protectColorProperty(child, "TextColor3", THEME.TextColor)
						
						local textStroke = child:FindFirstChildOfClass("UIStroke")
						if isValid(textStroke) then
							textStroke:Destroy()
						end
					end)
				end
			end
			
			-- Hapus semua stroke
			if child:IsA("UIStroke") then
				child:Destroy()
			end
		end
	end)
end

-- ====== PROTECT COLORPALETTE TOGGLE ======
local function protectColorPaletteToggle()
	local studioGui = playerGui:FindFirstChild("StudioGui")
	if not isValid(studioGui) then return end
	
	pcall(function()
		for _, descendant in ipairs(studioGui:GetDescendants()) do
			if isValid(descendant) and descendant:IsA("GuiButton") then
				local buttonName = descendant.Name
				if buttonName:find("Color") or buttonName:find("Palette") or buttonName:find("color") or buttonName:find("palette") then
					-- Protected, do nothing
				end
			end
		end
	end)
end

-- ====== APPLY THEME FUNCTION ======
local function applyTheme(obj)
	if not isValid(obj) then return end

	pcall(function()
		-- Skip StudioRisBoxKey
		local parentCheck = obj
		for _ = 1, 10 do
			if not isValid(parentCheck) then break end
			if parentCheck:IsA("ScreenGui") and parentCheck.Name == "StudioRisBoxKey" then
				return
			end
			parentCheck = parentCheck.Parent
		end

		-- Skip protected objects
		if isSelectMultiButton(obj) then return end
		if isButtonInFolderInsideColorPalette(obj) then return end
		
		-- Skip toggle buttons
		if obj:IsA("GuiButton") then
			local buttonName = obj.Name
			if buttonName:find("Color") or buttonName:find("Palette") or buttonName:find("color") or buttonName:find("palette") then
				return
			end
		end
		
		-- Skip ColorPalette children
		if isPartOfColorPalette(obj) and obj.Name ~= "ColorPalette" then
			return
		end

		local className = obj.ClassName

		-- TextLabel
		if className == "TextLabel" then
			if not isRedColor(obj.TextColor3) then
				obj.TextColor3 = THEME.TextColor
				protectColorProperty(obj, "TextColor3", THEME.TextColor)
			end
			if obj.BackgroundTransparency < 1 then
				obj.BackgroundColor3 = THEME.FrameColor
				protectColorProperty(obj, "BackgroundColor3", THEME.FrameColor)
			end

		-- TextButton
		elseif className == "TextButton" then
			if not isRedColor(obj.TextColor3) then
				obj.TextColor3 = THEME.TextColor
				protectColorProperty(obj, "TextColor3", THEME.TextColor)
			end
			if obj.BackgroundTransparency < 1 then
				obj.BackgroundColor3 = THEME.TextButtonColor
				protectColorProperty(obj, "BackgroundColor3", THEME.TextButtonColor)
			end

		-- TextBox
		elseif className == "TextBox" then
			if not isRedColor(obj.TextColor3) then
				obj.TextColor3 = THEME.TextColor
				protectColorProperty(obj, "TextColor3", THEME.TextColor)
			end
			if obj.BackgroundTransparency < 1 then
				obj.BackgroundColor3 = THEME.TextBoxColor
				protectColorProperty(obj, "BackgroundColor3", THEME.TextBoxColor)
			end

		-- Frame / ScrollingFrame
		elseif className == "Frame" or className == "ScrollingFrame" then
			if obj.Name == "ColorPalette" then
				applyColorPaletteTheme(obj)
			else
				if obj.BackgroundTransparency < 1 then
					obj.BackgroundColor3 = THEME.FrameColor
					protectColorProperty(obj, "BackgroundColor3", THEME.FrameColor)
				end
			end

		-- Image elements
		elseif className == "ImageLabel" or className == "ImageButton" then
			if obj.BackgroundTransparency < 1 then
				obj.BackgroundColor3 = THEME.FrameColor
				protectColorProperty(obj, "BackgroundColor3", THEME.FrameColor)
			end
		end
	end)
end

-- ====== SETUP COLORPALETTE ======
local function setupColorPalette()
	local function findAllColorPalettes(parent)
		local colorPalettes = {}
		if not isValid(parent) then return colorPalettes end
		
		pcall(function()
			for _, child in ipairs(parent:GetChildren()) do
				if child.Name == "ColorPalette" and child:IsA("Frame") then
					table.insert(colorPalettes, child)
				end
			end
		end)
		return colorPalettes
	end

	local allColorPalettes = findAllColorPalettes(playerGui)

	for _, colorPalette in ipairs(allColorPalettes) do
		applyColorPaletteTheme(colorPalette)
	end
end

-- ====== RECOLOR EVERYTHING ======
local function recolorEverything()
	applyTheme(playerGui)

	pcall(function()
		for _, obj in ipairs(playerGui:GetDescendants()) do
			applyTheme(obj)
		end
	end)
end

-- ====== REMOVE ALL STROKES ======
local function removeAllStrokes()
	local studioGui = playerGui:FindFirstChild("StudioGui")
	if not isValid(studioGui) then return end
	
	pcall(function()
		for _, obj in ipairs(studioGui:GetDescendants()) do
			if isValid(obj) and obj:IsA("UIStroke") then
				obj:Destroy()
			end
		end
	end)
end

-- ====== MAIN SCAN FUNCTION ======
local function scanAndApplyAll()
	recolorEverything()
	setupColorPalette()
	removeAllStrokes()
	
	task.defer(function()
		protectColorPaletteToggle()
	end)
	
	task.defer(function()
		duplicatePartSelButton()
	end)
	
	task.defer(function()
		local studioGui = playerGui:FindFirstChild("StudioGui")
		if isValid(studioGui) then
			local mainBar = studioGui:FindFirstChild("MainBar")
			if isValid(mainBar) then
				createLineSeparator(mainBar)
			end
		end
	end)
end

-- ====== CREATE KEY BOX ======
local function createStudioRisBoxKey()
	local existingBox = playerGui:FindFirstChild("StudioRisBoxKey")
	if isValid(existingBox) then
		return existingBox
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StudioRisBoxKey"
	screenGui.Parent = playerGui
	screenGui.ResetOnSpawn = false

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 400, 0, 250)
	mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
	mainFrame.BorderSizePixel = 2
	mainFrame.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = mainFrame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(100, 100, 100)
	uiStroke.Thickness = 1.5
	uiStroke.Parent = mainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.Position = UDim2.new(0, 0, 0, 15)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "STUDIORIS"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 28
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.Parent = mainFrame

	local instructionLabel = Instance.new("TextLabel")
	instructionLabel.Name = "InstructionLabel"
	instructionLabel.Size = UDim2.new(1, -40, 0, 30)
	instructionLabel.Position = UDim2.new(0, 20, 0, 70)
	instructionLabel.BackgroundTransparency = 1
	instructionLabel.Text = "Masukkan Key Akses Anda:"
	instructionLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	instructionLabel.TextSize = 16
	instructionLabel.Font = Enum.Font.GothamMedium
	instructionLabel.TextXAlignment = Enum.TextXAlignment.Center
	instructionLabel.Parent = mainFrame

	local keyTextBox = Instance.new("TextBox")
	keyTextBox.Name = "KeyTextBox"
	keyTextBox.Size = UDim2.new(1, -80, 0, 40)
	keyTextBox.Position = UDim2.new(0, 40, 0, 110)
	keyTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	keyTextBox.BorderColor3 = Color3.fromRGB(80, 80, 80)
	keyTextBox.BorderSizePixel = 1
	keyTextBox.Text = ""
	keyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyTextBox.TextSize = 20
	keyTextBox.Font = Enum.Font.GothamMedium
	keyTextBox.PlaceholderText = "Masukkan key..."
	keyTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	keyTextBox.TextXAlignment = Enum.TextXAlignment.Center
	keyTextBox.ClearTextOnFocus = false
	keyTextBox.Parent = mainFrame

	local textBoxCorner = Instance.new("UICorner")
	textBoxCorner.CornerRadius = UDim.new(0, 6)
	textBoxCorner.Parent = keyTextBox

	local verifyButton = Instance.new("TextButton")
	verifyButton.Name = "VerifyButton"
	verifyButton.Size = UDim2.new(0, 150, 0, 40)
	verifyButton.Position = UDim2.new(0.5, -75, 0, 175)
	verifyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	verifyButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
	verifyButton.BorderSizePixel = 1
	verifyButton.Text = "VERIFIKASI"
	verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	verifyButton.TextSize = 16
	verifyButton.Font = Enum.Font.GothamBold
	verifyButton.Parent = mainFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = verifyButton

	verifyButton.MouseButton1Click:Connect(function()
		local enteredKey = keyTextBox.Text
		if enteredKey == "" then
			keyTextBox.PlaceholderText = "Key tidak boleh kosong!"
			keyTextBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
		elseif enteredKey == "STUDIORIS2024" then
			screenGui.Enabled = false
			task.wait(0.5)
			scanAndApplyAll()
		else
			keyTextBox.Text = ""
			keyTextBox.PlaceholderText = "Key salah! Coba lagi."
			keyTextBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
		end
	end)

	verifyButton.MouseEnter:Connect(function()
		if isValid(verifyButton) then
			verifyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		end
	end)
	verifyButton.MouseLeave:Connect(function()
		if isValid(verifyButton) then
			verifyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end
	end)

	return screenGui
end

-- ====== MAIN EXECUTION ======
createStudioRisBoxKey()

task.wait(0.5)
scanAndApplyAll()

-- Scan ulang
task.spawn(function()
	for i = 1, 10 do
		task.wait(0.5)
		scanAndApplyAll()
	end
end)

-- Auto-apply to new elements
playerGui.DescendantAdded:Connect(function(obj)
	if not isValid(obj) then return end
	
	applyTheme(obj)

	if obj.Name == "ColorPalette" and obj:IsA("Frame") then
		task.defer(function()
			setupColorPalette()
		end)
	end

	if obj:IsA("UIStroke") then
		task.defer(function()
			if isValid(obj) then
				obj:Destroy()
			end
		end)
	end
end)

print("[ThemeRecolor v8.2] ✅ Script berjalan! Key: STUDIORIS2024")
print("[ThemeRecolor v8.2] ✅ Semua STROKE dihapus")
print("[ThemeRecolor v8.2] ✅ Garis separator BIRU")
print("[ThemeRecolor v8.2] ✅ Toggle ColorPalette dilindungi")
print("[ThemeRecolor v8.2] ✅ Error handling stabil")
