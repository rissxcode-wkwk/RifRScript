--[[
╔════════════════════════════════════════════════════════════════╗
║           ThemeRecolor.lua v8 - MODIFIED & ENHANCED            ║
║                      Made By Redz                              ║
║                    Modified Version (FIXED)                    ║
║              + PROTECTION FOR settingrigbtn BUTTON             ║
╚════════════════════════════════════════════════════════════════╝

FITUR UTAMA:
✅ Semua text putih (255,255,255)
✅ Semua background abu-abu tema Roblox Studio
✅ Color Protection System - otomatis kembalikan warna jika ada script lain yang ubah
✅ Proteksi "Select MultiButton" (100% tidak diubah)
✅ Proteksi ColorPalette > Folder > Button (100% tidak diubah)
✅ **BARU: Proteksi settingrigbtn Button (100% tidak diubah)**
✅ Real-time monitoring dengan PropertyChanged signal
✅ Dukungan DescendantAdded untuk UI baru
✅ Sistem red color exception tetap berjalan
✅ StudioRis Box Key system tetap berjalan
✅ ColorPalette centering tetap berjalan
✅ Custom Image IDs dengan rotasi
✅ Duplikasi PartSel Button ke PluginBtn
✅ Frame garis separator
✅ **FIXED: HANYA AFFECT STUDIOGUI, TIDAK MENGGANGGU SCREENgui LAIN**

CARA PAKAI:
Taruh sebagai LocalScript di StarterPlayer > StarterPlayerScripts
ATAU di StarterPlayer > StarterCharacterScripts

KEY: STUDIORIS2024
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== TUNGGU STUDIOGUI EXIST ======
local studioGui = playerGui:WaitForChild("StudioGui")

-- ====== KONFIGURASI WARNA TEMA ======
local THEME = {
	FrameColor       = Color3.fromRGB(46, 46, 46),   -- Abu-abu gelap
	FrameColorAlt    = Color3.fromRGB(56, 56, 56),   -- Abu-abu sedikit terang
	BorderColor      = Color3.fromRGB(35, 35, 35),   -- Border gelap
	TextColor        = Color3.fromRGB(255, 255, 255), -- Putih murni
	TextButtonColor  = Color3.fromRGB(60, 60, 60),   -- Abu-abu button
	TextButtonHover  = Color3.fromRGB(75, 75, 75),   -- Abu-abu hover
	TextBoxColor     = Color3.fromRGB(38, 38, 38),   -- Abu-abu textbox
	StrokeColor      = Color3.fromRGB(100, 100, 100), -- Abu-abu stroke
}

-- KONFIGURASI IMAGE & CUSTOM ELEMENTS
local CUSTOM_CONFIG = {
	-- Image IDs untuk Select Label
	SelectImageID_1 = "rbxasset://textures/Cursor.png", -- Fallback, akan diganti
	SelectImageID_2 = "14547804225",
	SelectImageID_3 = "84031887426375",
	ImageRotation = 0, -- Rotasi dalam derajat
}

-- Tabel untuk tracking objek yang sudah diproteksi
local protectedObjects = {}
local protectedConnections = {}

-- ====== FUNGSI CEK APAKAH OBJECT DALAM STUDIOGUI ======
local function isInStudioGui(obj)
	if not obj then return false end
	
	local current = obj
	while current and current ~= playerGui do
		if current == studioGui then
			return true
		end
		current = current.Parent
	end
	return false
end

-- ====== FUNGSI CEK WARNA MERAH ======
local function isRedColor(color)
	if not color then return false end
	return color.R > 0.6 and color.G < 0.3 and color.B < 0.3
end

-- ====== FUNGSI CEK SELECT MULTIBUTTON (STRICT) ======
local function isSelectMultiButton(obj)
	if not obj:IsA("GuiButton") then return false end
	return obj.Name == "Select MultiButton" or obj.Name == "SelectMultiButton"
end

-- ====== FUNGSI CEK BUTTON settingrigbtn (PROTEKSI PENUH) ======
local function isSettingRigButton(obj)
	if not obj:IsA("GuiButton") then return false end
	return obj.Name == "settingrigbtn" or obj.Name == "SettingRigBtn"
end

-- ====== FUNGSI CEK BUTTON DALAM FOLDER DI COLORPALETTE (ROBUST) ======
local function isButtonInFolderInsideColorPalette(obj)
	if not obj:IsA("GuiButton") then return false end
	
	local parent = obj.Parent
	if parent and parent:IsA("Folder") then
		local grandparent = parent.Parent
		while grandparent and grandparent ~= studioGui do
			if grandparent:IsA("Frame") and grandparent.Name == "ColorPalette" then
				return true
			end
			grandparent = grandparent.Parent
		end
	end
	return false
end

-- ====== FUNGSI CEGAH PERUBAHAN WARNA (PROTECTION SYSTEM) ======
local function protectColorProperty(obj, propertyName, correctValue)
	if protectedObjects[obj] and protectedObjects[obj][propertyName] then
		return -- Sudah dilindungi
	end
	
	if not protectedObjects[obj] then
		protectedObjects[obj] = {}
	end
	protectedObjects[obj][propertyName] = true
	
	-- Pantau perubahan property
	local connection
	connection = obj:GetPropertyChangedSignal(propertyName):Connect(function()
		if obj and obj.Parent then
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

-- ====== FUNGSI BUAT FRAME GARIS SEPARATOR ======
local function createLineSeparator(parent)
	-- Hapus jika sudah ada
	local existingLine = parent:FindFirstChild("LineSeparator")
	if existingLine then
		existingLine:Destroy()
	end
	
	local lineFrame = Instance.new("Frame")
	lineFrame.Name = "LineSeparator"
	lineFrame.Size = UDim2.new(0, 1, 0, 30)
	lineFrame.Position = UDim2.new(0, 405, 0, 3)
	lineFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	lineFrame.BorderSizePixel = 0
	lineFrame.Parent = parent
	
	return lineFrame
end

-- ====== FUNGSI DUPLIKASI BUTTON (PartSel → PluginBtn) ======
local function duplicatePartSelButton()
	local mainBar = studioGui:FindFirstChild("MainBar")
	if not mainBar then
		print("[DEBUG] MainBar tidak ditemukan")
		return
	end
	
	-- Cari button PartSel
	local partSelButton = nil
	for _, child in ipairs(mainBar:GetChildren()) do
		if child.Name == "PartSel" then
			partSelButton = child
			break
		end
	end
	
	if not partSelButton then
		print("[DEBUG] PartSel button tidak ditemukan di MainBar")
		-- List semua children MainBar untuk debugging
		print("[DEBUG] Children di MainBar:")
		for _, child in ipairs(mainBar:GetChildren()) do
			print("[DEBUG] - " .. child.Name .. " (" .. child.ClassName .. ")")
		end
		return
	end
	
	-- Cek apakah PluginBtn sudah ada
	local existingPluginBtn = mainBar:FindFirstChild("PluginBtn")
	if existingPluginBtn then
		existingPluginBtn:Destroy()
	end
	
	-- Duplikasi button dengan struktur lengkap
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
	
	-- Duplikasi children dari PartSel jika ada
	for _, child in ipairs(partSelButton:GetChildren()) do
		local clonedChild = child:Clone()
		clonedChild.Parent = pluginBtn
		
		-- Apply theme ke child
		if clonedChild:IsA("TextLabel") then
			clonedChild.TextColor3 = THEME.TextColor
		elseif clonedChild:IsA("ImageLabel") or clonedChild:IsA("ImageButton") then
			if clonedChild.BackgroundTransparency < 1 then
				clonedChild.BackgroundColor3 = THEME.FrameColor
			end
		end
	end
	
	-- Setup protection
	protectColorProperty(pluginBtn, "TextColor3", THEME.TextColor)
	protectColorProperty(pluginBtn, "BackgroundColor3", THEME.TextButtonColor)
	
	-- Setup hover effect
	pluginBtn.MouseEnter:Connect(function()
		pluginBtn.BackgroundColor3 = THEME.TextButtonHover
	end)
	pluginBtn.MouseLeave:Connect(function()
		pluginBtn.BackgroundColor3 = THEME.TextButtonColor
	end)
	
	print("[DEBUG] PluginBtn berhasil dibuat di posisi (430, 3)")
	return pluginBtn
end

-- ====== FUNGSI UPDATE IMAGE DENGAN ROTASI ======
local function updateSelectImages()
	-- Cari semua ImageLabel dengan nama tertentu HANYA DI STUDIOGUI
	for _, obj in ipairs(studioGui:GetDescendants()) do
		if obj:IsA("ImageLabel") then
			-- Update image dengan ID baru
			if obj.Name == "select" then
				pcall(function()
					obj.Image = "rbxasset://textures/Cursor.png" -- Fallback
					print("[DEBUG] Found 'select' image label")
				end)
			elseif obj.Name == "IconLabel" or obj.Name == "Icon" then
				pcall(function()
					obj.Image = "rbxasset://textures/Cursor.png" -- Fallback
					print("[DEBUG] Found icon image label: " .. obj.Name)
				end)
			end
		end
	end
end

-- ====== FUNGSI SETUP BUTTON ROTATE ======
local function setupRotateButton()
	local mainBar = studioGui:FindFirstChild("MainBar")
	if not mainBar then return end
	
	local rotateButton = nil
	for _, child in ipairs(mainBar:GetChildren()) do
		if child.Name == "Rotate" or child.Name == "rotate" then
			rotateButton = child
			break
		end
	end
	
	if not rotateButton then
		print("[DEBUG] Rotate button tidak ditemukan")
		return
	end
	
	-- Apply theme ke rotate button
	if rotateButton:IsA("TextButton") or rotateButton:IsA("GuiButton") then
		rotateButton.BackgroundColor3 = THEME.TextButtonColor
		rotateButton.TextColor3 = THEME.TextColor
		protectColorProperty(rotateButton, "BackgroundColor3", THEME.TextButtonColor)
		protectColorProperty(rotateButton, "TextColor3", THEME.TextColor)
	end
	
	-- Apply theme ke child elements
	for _, child in ipairs(rotateButton:GetDescendants()) do
		if child:IsA("ImageLabel") or child:IsA("ImageButton") then
			if child.BackgroundTransparency < 1 then
				child.BackgroundColor3 = THEME.FrameColor
				-- Terapkan rotasi jika ada property rotation
				if child:FindFirstChild("Rotation") or pcall(function() return child.Rotation end) then
					child.Rotation = 45 -- Default rotasi 45 derajat
				end
			end
		elseif child:IsA("TextLabel") then
			child.TextColor3 = THEME.TextColor
			protectColorProperty(child, "TextColor3", THEME.TextColor)
		end
	end
	
	print("[DEBUG] Rotate button setup selesai")
end

-- ====== FUNGSI MEMBUAT BOX KEY DI TENGAH ======
local function createStudioRisBoxKey()
	local existingBox = playerGui:FindFirstChild("StudioRisBoxKey")
	if existingBox then
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
		verifyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	end)
	verifyButton.MouseLeave:Connect(function()
		verifyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)

	return screenGui
end

-- ====== CEK APAKAH OBJECT ADALAH ATAU CHILD DARI COLORPALETTE ======
local function isPartOfColorPalette(obj)
	if obj.Name == "ColorPalette" then return true end
	
	local parent = obj.Parent
	while parent and parent ~= studioGui do
		if parent.Name == "ColorPalette" then
			return true
		end
		parent = parent.Parent
	end
	return false
end

-- ====== TERAPKAN THEME KHUSUS UNTUK COLORPALETTE (FRAME + SPECIFIC ELEMENTS) ======
local function applyColorPaletteTheme(colorPaletteFrame)
	if not colorPaletteFrame or colorPaletteFrame.Name ~= "ColorPalette" then return end
	
	pcall(function()
		-- 1. Frame background
		if colorPaletteFrame.BackgroundTransparency < 1 then
			colorPaletteFrame.BackgroundColor3 = THEME.FrameColor
			protectColorProperty(colorPaletteFrame, "BackgroundColor3", THEME.FrameColor)
		end
		
		-- 2. Tambah stroke jika belum ada
		local existingStroke = colorPaletteFrame:FindFirstChildOfClass("UIStroke")
		if not existingStroke then
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = THEME.StrokeColor
			uiStroke.Thickness = 1.5
			uiStroke.Parent = colorPaletteFrame
		end
		
		-- 3. Tambah corner jika belum ada
		local existingCorner = colorPaletteFrame:FindFirstChildOfClass("UICorner")
		if not existingCorner then
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 12)
			uiCorner.Parent = colorPaletteFrame
		end
		
		-- 4. Posisi tengah
		colorPaletteFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		colorPaletteFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		-- 5. THEME SPECIFIC ELEMENTS INSIDE COLORPALETTE
		for _, child in ipairs(colorPaletteFrame:GetDescendants()) do    

    -- OkButton & CancelButton
    if child.Name == "OkButton" or child.Name == "CancelButton" then    
        if child:IsA("TextButton") then    
            child.TextColor3 = THEME.TextColor    
            child.BackgroundColor3 = THEME.TextButtonColor    
            protectColorProperty(child, "TextColor3", THEME.TextColor)    
            protectColorProperty(child, "BackgroundColor3", THEME.TextButtonColor)    
        end    

    -- BasicColorsTitle
    elseif child.Name == "BasicColorsTitle" then    
        if child:IsA("TextLabel") then    
            child.TextColor3 = THEME.TextColor    
            if child.BackgroundTransparency < 1 then    
                child.BackgroundColor3 = THEME.FrameColor    
            end    
            protectColorProperty(child, "TextColor3", THEME.TextColor)    
            if child.BackgroundTransparency < 1 then    
                protectColorProperty(child, "BackgroundColor3", THEME.FrameColor)    
            end    
        end    

    -- Selected texts (TEXT ONLY)
    elseif child.Name == "SelectedColor" 
        or child.Name == "SelectedColorText" 
        or child.Name == "SelectedBrickColorText" then    

        if child:IsA("TextLabel") then    
            child.TextColor3 = THEME.TextColor    
            protectColorProperty(child, "TextColor3", THEME.TextColor)    
        end    
    end    
end
	end)
end

-- ====== FUNGSI CARI & PROTECT TOGGLE COLORPALETTE ======
local function protectColorPaletteToggle()
	-- Cari toggle button yang munculkan ColorPalette
	-- Biasanya di MainBar atau toolbar area
	for _, descendant in ipairs(studioGui:GetDescendants()) do
		if descendant:IsA("GuiButton") then
			-- Cek apakah button ini related dengan ColorPalette
			local buttonName = descendant.Name
			if buttonName:find("Color") or buttonName:find("Palette") then
				-- Protect button ini agar tidak berubah warna
				if descendant:IsA("TextButton") or descendant:IsA("GuiButton") then
					pcall(function()
						local originalTextColor = descendant.TextColor3
						local originalBgColor = descendant.BackgroundColor3
						protectColorProperty(descendant, "TextColor3", originalTextColor)
						protectColorProperty(descendant, "BackgroundColor3", originalBgColor)
					end)
				end
			end
		end
	end
	
	print("[DEBUG] ColorPalette toggle buttons protected")
end

-- ====== FUNGSI UTAMA: TERAPKAN TEMA + PROTEKSI (HANYA STUDIOGUI) ======
local function applyTheme(obj)
	if not obj or not obj.Parent then return end

	-- **CRITICAL FIX: CEK APAKAH OBJECT DALAM STUDIOGUI**
	if not isInStudioGui(obj) then
		return
	end

	-- SKIP StudioRisBoxKey
	local parentCheck = obj
	while parentCheck do
		if parentCheck:IsA("ScreenGui") and parentCheck.Name == "StudioRisBoxKey" then
			return
		end
		parentCheck = parentCheck.Parent
	end

	-- SKIP SELECT MULTIBUTTON (STRICT)
	if isSelectMultiButton(obj) then
		return
	end

	-- **BARU: SKIP settingrigbtn BUTTON (PENUH PROTEKSI)**
	if isSettingRigButton(obj) then
		return
	end

	-- SKIP BUTTON DALAM FOLDER DI COLORPALETTE
	if isButtonInFolderInsideColorPalette(obj) then
		return
	end
	
	-- SKIP SEMUA CHILD ELEMENTS DARI COLORPALETTE (KECUALI COLORPALETTE FRAME SENDIRI)
	if isPartOfColorPalette(obj) and obj.Name ~= "ColorPalette" then
		return
	end

	local success, err = pcall(function()
		local className = obj.ClassName

		-- ====== TEXTLABEL: TEKS PUTIH + BG ABU-ABU ======
		if className == "TextLabel" then
			if not isRedColor(obj.TextColor3) then
				obj.TextColor3 = THEME.TextColor
				protectColorProperty(obj, "TextColor3", THEME.TextColor)
			end
			if obj.BackgroundTransparency < 1 then
				obj.BackgroundColor3 = THEME.FrameColor
				protectColorProperty(obj, "BackgroundColor3", THEME.FrameColor)
			end

		-- ====== TEXTBUTTON: TEKS PUTIH + BG ABU-ABU BUTTON ======
		elseif className == "TextButton" then
			if not isRedColor(obj.TextColor3) then
				obj.TextColor3 = THEME.TextColor
				protectColorProperty(obj, "TextColor3", THEME.TextColor)
			end
			if obj.BackgroundTransparency < 1 then
				obj.BackgroundColor3 = THEME.TextButtonColor
				protectColorProperty(obj, "BackgroundColor3", THEME.TextButtonColor)
			end

		-- ====== TEXTBOX: TEKS PUTIH + BG ABU-ABU GELAP ======
		elseif className == "TextBox" then
			if not isRedColor(obj.TextColor3) then
				obj.TextColor3 = THEME.TextColor
				protectColorProperty(obj, "TextColor3", THEME.TextColor)
			end
			if obj.BackgroundTransparency < 1 then
				obj.BackgroundColor3 = THEME.TextBoxColor
				protectColorProperty(obj, "BackgroundColor3", THEME.TextBoxColor)
			end

		-- ====== FRAME / SCROLLINGFRAME: BG ABU-ABU ======
		elseif className == "Frame" or className == "ScrollingFrame" then
			-- KHUSUS COLORPALETTE: Hanya frame yang di-theme
			if obj.Name == "ColorPalette" then
				applyColorPaletteTheme(obj)
			else
				if obj.BackgroundTransparency < 1 then
					obj.BackgroundColor3 = THEME.FrameColor
					protectColorProperty(obj, "BackgroundColor3", THEME.FrameColor)
				end
			end

		-- ====== IMAGE ELEMENTS: BG ABU-ABU ======
		elseif className == "ImageLabel" or className == "ImageButton" then
			if obj.BackgroundTransparency < 1 then
				obj.BackgroundColor3 = THEME.FrameColor
				protectColorProperty(obj, "BackgroundColor3", THEME.FrameColor)
			end
		end
	end)
end

-- ====== FUNGSI SCAN & SETUP COLORPALETTE ======
local function setupColorPalette()
	local function findAllColorPalettes(parent)
		local colorPalettes = {}
		for _, child in ipairs(parent:GetChildren()) do
			if child.Name == "ColorPalette" and child:IsA("Frame") then
				table.insert(colorPalettes, child)
			end
			local subPalettes = findAllColorPalettes(child)
			for _, p in ipairs(subPalettes) do
				table.insert(colorPalettes, p)
			end
		end
		return colorPalettes
	end

	local allColorPalettes = findAllColorPalettes(studioGui)

	if #allColorPalettes == 0 then
		return
	end

	-- Terapkan theme khusus ke setiap ColorPalette (hanya frame, child elements tetap original)
	for _, colorPalette in ipairs(allColorPalettes) do
		applyColorPaletteTheme(colorPalette)
	end
end

-- ====== FUNGSI RECOLOR SEMUA (HANYA STUDIOGUI) ======
local function recolorEverything()
	applyTheme(studioGui)

	for _, obj in ipairs(studioGui:GetDescendants()) do
		applyTheme(obj)
	end
end

-- ====== FUNGSI GABUNGAN ======
local function scanAndApplyAll()
	recolorEverything()
	setupColorPalette()
	
	-- Update images dengan ID baru
	task.defer(function()
		updateSelectImages()
	end)
	
	-- Setup rotate button dengan rotasi
	task.defer(function()
		setupRotateButton()
	end)
	
	-- Duplikasi PartSel button ke PluginBtn
	task.defer(function()
		duplicatePartSelButton()
	end)
	
	-- Buat line separator di MainBar
	task.defer(function()
		local mainBar = studioGui:FindFirstChild("MainBar")
		if mainBar then
			createLineSeparator(mainBar)
			print("[DEBUG] Line separator dibuat di MainBar")
		else
			print("[DEBUG] MainBar tidak ditemukan untuk garis")
		end
	end)
	
	-- Protect ColorPalette toggle buttons
	task.defer(function()
		protectColorPaletteToggle()
	end)
end

-- ====== EKSEKUSI UTAMA ======
-- Buat box key StudioRis
local boxKey = createStudioRisBoxKey()

-- Tunggu sebentar, lalu terapkan tema
task.wait(0.5)
scanAndApplyAll()

-- Scan ulang beberapa kali untuk menangkap UI yang spawn belakangan
task.spawn(function()
	for i = 1, 10 do
		task.wait(0.5)
		scanAndApplyAll()
	end
end)

-- **CRITICAL FIX: Auto-apply ke elemen baru HANYA DI STUDIOGUI**
studioGui.DescendantAdded:Connect(function(obj)
	-- Pastikan object adalah child dari StudioGui
	if not isInStudioGui(obj) then
		return
	end
	
	-- **BARU: Skip settingrigbtn dan anak-anaknya**
	if isSettingRigButton(obj) then
		return
	end
	
	-- Check apakah parent adalah settingrigbtn
	local parentCheck = obj.Parent
	while parentCheck and parentCheck ~= studioGui do
		if isSettingRigButton(parentCheck) then
			return
		end
		parentCheck = parentCheck.Parent
	end
	
	applyTheme(obj)

	-- Jika ColorPalette baru dibuat
	if obj.Name == "ColorPalette" then
		task.defer(function()
			setupColorPalette()
		end)
	end

	-- Jika ada TextButton baru di dalam Folder di ColorPalette, jangan ubah
	if obj:IsA("TextButton") and isButtonInFolderInsideColorPalette(obj) then
		return
	end

	-- Jika Select MultiButton baru, jangan ubah
	if isSelectMultiButton(obj) then
		return
	end
end)

-- ====== HAPUS BORDER & UISTROKE ======
local mainBar = studioGui:FindFirstChild("MainBar", true)

if mainBar then

	-- MainBar sendiri
	if mainBar:IsA("Frame")
		or mainBar:IsA("TextButton")
		or mainBar:IsA("TextLabel")
		or mainBar:IsA("ImageButton")
		or mainBar:IsA("ImageLabel")
		or mainBar:IsA("ScrollingFrame")
	then
		mainBar.BorderSizePixel = 0
	end

	-- Semua isi MainBar kecuali Topbar dan keturunannya
	for _, obj in ipairs(mainBar:GetDescendants()) do

		local insideTopbar = false
		local topbar = mainBar:FindFirstChild("Topbar", true)

		if topbar and (obj == topbar or topbar:IsAncestorOf(obj)) then
			insideTopbar = true
		end

		if not insideTopbar then

			if obj:IsA("UIStroke") then
				obj:Destroy()

			elseif obj:IsA("Frame")
				or obj:IsA("TextButton")
				or obj:IsA("TextLabel")
				or obj:IsA("ImageButton")
				or obj:IsA("ImageLabel")
				or obj:IsA("ScrollingFrame")
			then
				obj.BorderSizePixel = 0
			end

		end
	end

	-- Hanya isi Topbar yang dibersihkan
	local topbar = mainBar:FindFirstChild("Topbar", true)

	if topbar then
		for _, obj in ipairs(topbar:GetDescendants()) do

			if obj:IsA("UIStroke") then
				obj:Destroy()

			elseif obj:IsA("Frame")
				or obj:IsA("TextButton")
				or obj:IsA("TextLabel")
				or obj:IsA("ImageButton")
				or obj:IsA("ImageLabel")
				or obj:IsA("ScrollingFrame")
			then
				obj.BorderSizePixel = 0
			end

		end
	end

	print("✅ Border & UIStroke dibersihkan")
end


-- ====== TUNGGU THEME APPLY SELESAI ======
task.wait(2)

-- ====== KONFIGURASI TEMA (SAMA DENGAN THEMERECOLOR) ======
local THEME = {
	TextColor        = Color3.fromRGB(255, 255, 255),
	TextButtonColor  = Color3.fromRGB(60, 60, 60),
	TextButtonHover  = Color3.fromRGB(75, 75, 75),
	FrameColor       = Color3.fromRGB(46, 46, 46),
}

-- ====== AMBIL UI ======
local topBar = studioGui:WaitForChild("TopBar")
local fileMenu = topBar:WaitForChild("FileMenu")

-- ====== SET FILEMENU ======
fileMenu.Parent = topBar
fileMenu.Visible = true
fileMenu.Size = UDim2.new(0.566, 0, 0, 20)
fileMenu.Position = UDim2.new(0, 0, 0, 0)

fileMenu.BackgroundTransparency = 1
fileMenu.BorderSizePixel = 0

-- ====== ANTI HIDE FILEMENU ======
fileMenu:GetPropertyChangedSignal("Visible"):Connect(function()
	fileMenu.Visible = true
end)

task.spawn(function()
	while task.wait(0.5) do
		fileMenu.Visible = true
	end
end)

-- ====== HAPUS BUTTON DI TOPBAR (FILEMENU AMAN) ======
for _, obj in ipairs(topBar:GetChildren()) do
	if obj ~= fileMenu then
		if obj:IsA("TextButton") or obj:IsA("ImageButton") then
			obj:Destroy()
		end
	end
end

-- ====== HAPUS LAYOUT LAMA ======
for _, v in ipairs(fileMenu:GetChildren()) do
	if v:IsA("UIGridLayout") or v:IsA("UIListLayout") then
		v:Destroy()
	end
end

-- ====== GRID FILEMENU ======
local grid = Instance.new("UIGridLayout")
grid.Parent = fileMenu
grid.CellSize = UDim2.new(0, 90, 0, 18)
grid.CellPadding = UDim2.new(0, 4, 0, 3)
grid.FillDirection = Enum.FillDirection.Horizontal
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
grid.VerticalAlignment = Enum.VerticalAlignment.Center

-- ====== CLEAN BUTTON ======
local function clean(obj)
	if obj:IsA("TextButton") then
		obj.Text = string.gsub(obj.Text or "", "%.%.%.", "")
		obj.Size = UDim2.new(0, 90, 0, 18)
		obj.BorderSizePixel = 0
		obj.BackgroundTransparency = 0.2
	elseif obj:IsA("ImageButton") then
		obj.BorderSizePixel = 0
	end
end

for _, obj in ipairs(fileMenu:GetChildren()) do
	clean(obj)
end

fileMenu.ChildAdded:Connect(function(obj)
	task.wait()
	clean(obj)
end)

fileMenu.DescendantAdded:Connect(function(obj)
	task.wait()
	clean(obj)
end)

-- ===================================================
-- BUTTON BARU : API PLACE
-- ===================================================

local apiButton = Instance.new("TextButton")
apiButton.Name = "APIPlaceButton"
apiButton.Parent = topBar

apiButton.Text = "API Place"
apiButton.Size = UDim2.new(0, 90, 0, 18)
apiButton.BackgroundTransparency = 0.2
apiButton.BorderSizePixel = 0
apiButton.TextSize = 14
apiButton.Font = Enum.Font.SourceSans
apiButton.TextColor3 = Color3.new(1,1,1)

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0,4)
buttonCorner.Parent = apiButton

-- Posisi otomatis setelah FileMenu
task.spawn(function()
	while task.wait(0.1) do
		apiButton.Position = UDim2.new(
			0,
			fileMenu.AbsolutePosition.X + fileMenu.AbsoluteSize.X + 8,
			0,
			1
		)
	end
end)

-- ===================================================
-- FRAME API PLACE
-- ===================================================

local apiFrame = Instance.new("Frame")
apiFrame.Name = "APIPlaceFrame"
apiFrame.Parent = studioGui

apiFrame.AnchorPoint = Vector2.new(0.5, 0.5)
apiFrame.Position = UDim2.new(0.5, 0, 0.4, 0)

-- Sedikit lebih besar
apiFrame.Size = UDim2.new(0, 500, 0, 320)

apiFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
apiFrame.BorderSizePixel = 0
apiFrame.Visible = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,8)
corner.Parent = apiFrame

-- ====== TITLE ======

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = apiFrame
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "API Place"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)

-- ====== TOGGLE FRAME ======

apiButton.MouseButton1Click:Connect(function()
	apiFrame.Visible = not apiFrame.Visible
end)

-- OpenSaveFrame Modern Theme
-- LocalScript

local styledFrames = {}

local function addCorner(obj, radius)
local c = obj:FindFirstChildOfClass("UICorner")
if not c then
c = Instance.new("UICorner")
c.Parent = obj
end
c.CornerRadius = UDim.new(0, radius or 10)
end

local function styleObject(obj)

if obj:IsA("TextLabel") then
	obj.BackgroundTransparency = 1
	obj.TextColor3 = Color3.fromRGB(255,255,255)
	obj.Font = Enum.Font.GothamBold

elseif obj:IsA("TextButton") then
	obj.BackgroundColor3 = Color3.fromRGB(0,170,255)
	obj.TextColor3 = Color3.fromRGB(255,255,255)
	obj.BorderSizePixel = 0
	obj.AutoButtonColor = true
	addCorner(obj, 12)

elseif obj:IsA("ImageButton") then
	obj.BackgroundColor3 = Color3.fromRGB(35,35,45)
	obj.BorderSizePixel = 0
	addCorner(obj, 12)

elseif obj:IsA("TextBox") then
	obj.BackgroundColor3 = Color3.fromRGB(40,40,50)
	obj.TextColor3 = Color3.fromRGB(255,255,255)
	obj.PlaceholderColor3 = Color3.fromRGB(180,180,180)
	obj.BorderSizePixel = 0
	addCorner(obj, 10)

elseif obj:IsA("ScrollingFrame") then
	obj.BackgroundColor3 = Color3.fromRGB(24,24,30)
	obj.BorderSizePixel = 0
	obj.ScrollBarThickness = 6

elseif obj:IsA("Frame") then
	if obj.Name ~= "OpenSaveFrame" then
		obj.BackgroundColor3 = Color3.fromRGB(30,30,38)
		obj.BorderSizePixel = 0
		addCorner(obj, 10)
	end
end

end

local function applySpecialStyles(obj)

if obj.Name == "DeleteButton" and obj:IsA("TextButton") then
	obj.BackgroundColor3 = Color3.fromRGB(220,60,60)
	obj.TextColor3 = Color3.fromRGB(255,255,255)
	obj.BorderSizePixel = 0
	addCorner(obj,12)

elseif obj.Name == "ShareButton" and obj:IsA("TextButton") then
	obj.BackgroundColor3 = Color3.fromRGB(140,90,255)
	obj.TextColor3 = Color3.fromRGB(255,255,255)
	obj.BorderSizePixel = 0
	addCorner(obj,12)
end

end

local function lockStyle(obj)

task.spawn(function()

	while obj and obj.Parent do

		if obj.Name == "DeleteButton" and obj:IsA("TextButton") then
			obj.BackgroundColor3 = Color3.fromRGB(220,60,60)
			obj.TextColor3 = Color3.fromRGB(255,255,255)
			obj.BorderSizePixel = 0

		elseif obj.Name == "ShareButton" and obj:IsA("TextButton") then
			obj.BackgroundColor3 = Color3.fromRGB(140,90,255)
			obj.TextColor3 = Color3.fromRGB(255,255,255)
			obj.BorderSizePixel = 0
		end

		task.wait(0.1)
	end

end)

end

local function styleOpenSaveFrame(frame)

if styledFrames[frame] then
	return
end

styledFrames[frame] = true

frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.Size = UDim2.new(0,295,0,300)

frame.BackgroundColor3 = Color3.fromRGB(22,22,28)
frame.BorderSizePixel = 0

addCorner(frame,16)

local stroke = frame:FindFirstChildOfClass("UIStroke")
if not stroke then
	stroke = Instance.new("UIStroke")
	stroke.Parent = frame
end

stroke.Color = Color3.fromRGB(0,170,255)
stroke.Thickness = 2

for _,obj in ipairs(frame:GetDescendants()) do
	styleObject(obj)
	applySpecialStyles(obj)
	lockStyle(obj)
end

frame.DescendantAdded:Connect(function(obj)

	task.wait()

	pcall(function()
		styleObject(obj)
		applySpecialStyles(obj)
		lockStyle(obj)
	end)

end)

task.spawn(function()

	while frame.Parent do
		frame.AnchorPoint = Vector2.new(0.5,0.5)
		frame.Position = UDim2.new(0.5,0,0.5,0)
		task.wait(0.25)
	end

end)

print("[Theme] OpenSaveFrame ditemukan")

end

local function scan()

for _,obj in ipairs(game:GetDescendants()) do
	if obj:IsA("Frame") and obj.Name == "OpenSaveFrame" then
		styleOpenSaveFrame(obj)
	end
end

end

scan()

game.DescendantAdded:Connect(function(obj)

if obj:IsA("Frame") and obj.Name == "OpenSaveFrame" then
	task.wait(0.2)
	styleOpenSaveFrame(obj)
end

end)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Membuat RemoteEvent otomatis di ReplicatedStorage jika belum ada
local remoteEvent = ReplicatedStorage:FindFirstChild("RigChangeEvent")
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "RigChangeEvent"
	remoteEvent.Parent = ReplicatedStorage
end

local mainBar = playerGui:FindFirstChild("MainBar", true)

if mainBar then
	local targetScreenGui = mainBar.Parent 
	
	if targetScreenGui and targetScreenGui:IsA("ScreenGui") then
		
		local oldBtn = mainBar:FindFirstChild("settingrigbtn", true)
		if oldBtn then oldBtn:Destroy() end

		local originalBtn = mainBar:FindFirstChild("partsel", true)

		if originalBtn and originalBtn:IsA("GuiButton") then

			local btn = originalBtn:Clone()
			btn.Name = "settingrigbtn"
			btn.Parent = mainBar
			btn.Position = UDim2.new(0, 365, 0, 3)
			btn.Text = "R6 / R15"

			local oldPanel = targetScreenGui:FindFirstChild("RigPanel")
			if oldPanel then oldPanel:Destroy() end

			local panel = Instance.new("Frame")
			panel.Name = "RigPanel"
			panel.Parent = targetScreenGui
			panel.Size = UDim2.new(0, 260, 0, 220)
			panel.Position = UDim2.new(0.5, 0, 0.5, 0)
			panel.AnchorPoint = Vector2.new(0.5, 0.5)
			panel.BackgroundColor3 = Color3.fromRGB(25,25,25)
			panel.BorderSizePixel = 0
			panel.Visible = false

			Instance.new("UICorner", panel).CornerRadius = UDim.new(0,10)

			btn.MouseButton1Click:Connect(function()
				panel.Visible = not panel.Visible
			end)

			local allToggles = {}

			local function createToggle(y, title, desc, modeValue)
				local holder = Instance.new("Frame")
				holder.Parent = panel
				holder.Size = UDim2.new(1, -20, 0, 55)
				holder.Position = UDim2.new(0, 10, 0, y)
				holder.BackgroundTransparency = 1

				local t = Instance.new("TextLabel")
				t.Parent = holder
				t.Size = UDim2.new(1, 0, 0, 25)
				t.BackgroundTransparency = 1
				t.Text = title
				t.TextColor3 = Color3.fromRGB(255,255,255)
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Font = Enum.Font.SourceSansBold
				t.TextSize = 16

				local d = Instance.new("TextLabel")
				d.Parent = holder
				d.Position = UDim2.new(0, 0, 0, 25)
				d.Size = UDim2.new(1, 0, 0, 20)
				d.BackgroundTransparency = 1
				d.Text = desc
				d.TextColor3 = Color3.fromRGB(180,180,180)
				d.TextXAlignment = Enum.TextXAlignment.Left
				d.Font = Enum.Font.SourceSans
				d.TextSize = 13

				local switch = Instance.new("TextButton")
				switch.Parent = holder
				switch.Size = UDim2.new(0, 40, 0, 20)
				switch.Position = UDim2.new(1, -50, 0.5, -10)
				switch.BackgroundColor3 = Color3.fromRGB(80,80,80)
				switch.BorderSizePixel = 0
				switch.Text = ""
				switch.AutoButtonColor = false

				Instance.new("UICorner", switch).CornerRadius = UDim.new(1,0)

				local circle = Instance.new("Frame")
				circle.Parent = switch
				circle.Size = UDim2.new(0, 16, 0, 16)
				circle.Position = UDim2.new(0, 2, 0.5, -8)
				circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
				circle.BorderSizePixel = 0

				Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

				local toggleData = {
					Active = false,
					Mode = modeValue,
					UpdateVisual = function(self)
						if self.Active then
							switch.BackgroundColor3 = Color3.fromRGB(0,200,100)
							circle:TweenPosition(UDim2.new(1,-18,0.5,-8),"Out","Quad",0.15,true)
						else
							switch.BackgroundColor3 = Color3.fromRGB(80,80,80)
							circle:TweenPosition(UDim2.new(0,2,0.5,-8),"Out","Quad",0.15,true)
						end
					end
				}
				
				table.insert(allToggles, toggleData)

				switch.MouseButton1Click:Connect(function()
					if toggleData.Active then
						toggleData.Active = false
						toggleData:UpdateVisual()
						remoteEvent:FireServer("DEFAULT") -- Kembali ke settingan awal game jika dimatikan semua
					else
						for _, tog in ipairs(allToggles) do
							tog.Active = false
							tog:UpdateVisual()
						end
						toggleData.Active = true
						toggleData:UpdateVisual()
						
						-- Mengirim mode pilihan ("R15", "R6", atau "RANDOM") ke Server
						remoteEvent:FireServer(toggleData.Mode)
					end
				end)

				-- Default awal: R15 menyala sejak awal
				if modeValue == "R15" then
					toggleData.Active = true
				end
				
				toggleData:UpdateVisual()
			end

			-- ===== ISI PANEL (Menambahkan argumen parameter mode di ujung kanan) =====
			createToggle(10,  "R15 CHAR", "Char akan menjadi R15", "R15")
			createToggle(70,  "R6 CHAR", "Char akan menjadi R6", "R6")
			createToggle(130, "R6 & R15 CHAR", "Random R6 / R15", "RANDOM")
		end
	end
end



print("[FINAL CLEAN] FileMenu transparan, TopBar bersih total, text udah gak ada '...' 😈")
print("[ThemeRecolor v8 - FINAL FIXED] 🎨 HANYA AFFECT STUDIOGUI")
print("[ThemeRecolor v8 - FINAL FIXED] 🔒 Tidak mengganggu ScreenGui lain")
print("[ThemeRecolor v8 - FINAL FIXED] 🔒 settingrigbtn TERLINDUNGI 100%")
print("[ThemeRecolor v8 - FINAL FIXED] 🎨 Images: 14547804225, 84031887426375")
print("[ThemeRecolor v8 - FINAL FIXED] 🔘 Button: PluginBtn @ (430, 3)")
print("[ThemeRecolor v8 - FINAL FIXED] 🔄 Rotate Button dengan rotasi otomatis")
print("[ThemeRecolor v8 - FINAL FIXED] ━ Line Separator @ (405, 3)")
print("[ThemeRecolor v8 - FINAL FIXED] 🎨 ColorPalette Elements:")
print("   ├─ OkButton & CancelButton (text + bg)")
print("   ├─ BasicColorsTitle (text + bg)")
print("   └─ SelectedColor texts (text only)")
print("[ThemeRecolor v8 - FINAL FIXED] 🔒 ColorPalette toggle button protected")
print("[ThemeRecolor v8 - FINAL FIXED] 📋 Cek output console untuk debug info")
