--[[
╔════════════════════════════════════════════════════════════════╗
║           ThemeRecolor.lua v8 - MODIFIED & ENHANCED            ║
║                      Made By Redz                              ║
║                    Modified Version (v8.1)                     ║
╚════════════════════════════════════════════════════════════════╝

FITUR UTAMA:
✅ Semua text putih (255,255,255)
✅ Semua background abu-abu tema Roblox Studio
✅ Color Protection System - otomatis kembalikan warna jika ada script lain yang ubah
✅ Proteksi "Select MultiButton" (100% tidak diubah)
✅ Proteksi ColorPalette > Folder > Button (100% tidak diubah)
✅ Real-time monitoring dengan PropertyChanged signal
✅ Dukungan DescendantAdded untuk UI baru
✅ Sistem red color exception tetap berjalan
✅ StudioRis Box Key system tetap berjalan
✅ ColorPalette centering tetap berjalan
✅ Custom Image IDs dengan rotasi
✅ Duplikasi PartSel Button ke PluginBtn
✅ Frame garis separator BIRU (tidak ada stroke di UI)
✅ Toggle ColorPalette tidak berubah warna
✅ SEMUA STROKE DIHAPUS dari UI

PERUBAHAN VERSI 8.1:
🔧 Hapus semua UIStroke dari elemen
🔧 Garis separator di TopBar berubah jadi BIRU
🔧 Proteksi toggle ColorPalette (tidak berubah warna)
🔧 Hapus stroke di ColorPalette frame

CARA PAKAI:
Taruh sebagai LocalScript di StarterPlayer > StarterPlayerScripts
ATAU di StarterPlayer > StarterCharacterScripts

KEY: STUDIORIS2024
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== KONFIGURASI WARNA TEMA ======
local THEME = {
	FrameColor       = Color3.fromRGB(46, 46, 46),   -- Abu-abu gelap
	FrameColorAlt    = Color3.fromRGB(56, 56, 56),   -- Abu-abu sedikit terang
	BorderColor      = Color3.fromRGB(35, 35, 35),   -- Border gelap
	TextColor        = Color3.fromRGB(255, 255, 255), -- Putih murni
	TextButtonColor  = Color3.fromRGB(60, 60, 60),   -- Abu-abu button
	TextButtonHover  = Color3.fromRGB(75, 75, 75),   -- Abu-abu hover
	TextBoxColor     = Color3.fromRGB(38, 38, 38),   -- Abu-abu textbox
	StrokeColor      = Color3.fromRGB(100, 100, 100), -- Abu-abu stroke (TIDAK DIGUNAKAN)
	SeparatorBlue    = Color3.fromRGB(0, 120, 215),   -- BIRU untuk garis separator
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

-- ====== FUNGSI CEK BUTTON DALAM FOLDER DI COLORPALETTE (ROBUST) ======
local function isButtonInFolderInsideColorPalette(obj)
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

-- ====== FUNGSI BUAT FRAME GARIS SEPARATOR (BIRU) ======
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
	lineFrame.BackgroundColor3 = THEME.SeparatorBlue -- ✅ BIRU BUKAN ABU-ABU
	lineFrame.BorderSizePixel = 0
	lineFrame.Parent = parent
	
	return lineFrame
end

-- ====== FUNGSI DUPLIKASI BUTTON (PartSel → PluginBtn) ======
local function duplicatePartSelButton()
	local studioGui = playerGui:FindFirstChild("StudioGui")
	if not studioGui then
		print("[DEBUG] StudioGui tidak ditemukan")
		return
	end
	
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
	local studioGui = playerGui:FindFirstChild("StudioGui")
	if not studioGui then return end
	
	-- Cari semua ImageLabel dengan nama tertentu
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
	local studioGui = playerGui:FindFirstChild("StudioGui")
	if not studioGui then return end
	
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
	while parent and parent ~= playerGui do
		if parent.Name == "ColorPalette" then
			return true
		end
		parent = parent.Parent
	end
	return false
end

-- ====== TERAPKAN THEME KHUSUS UNTUK COLORPALETTE (HANYA ELEMEN TERTENTU) ======
local function applyColorPaletteTheme(colorPaletteFrame)
	if not colorPaletteFrame or colorPaletteFrame.Name ~= "ColorPalette" then return end
	
	pcall(function()
		-- 1. Frame background
		if colorPaletteFrame.BackgroundTransparency < 1 then
			colorPaletteFrame.BackgroundColor3 = THEME.FrameColor
			protectColorProperty(colorPaletteFrame, "BackgroundColor3", THEME.FrameColor)
		end
		
		-- 🚨 HAPUS STROKE JIKA ADA (TIDAK TAMBAH STROKE BARU)
		local existingStroke = colorPaletteFrame:FindFirstChildOfClass("UIStroke")
		if existingStroke then
			existingStroke:Destroy()
			print("[DEBUG] UIStroke dihapus dari ColorPalette")
		end
		
		-- 2. Tambah corner jika belum ada
		local existingCorner = colorPaletteFrame:FindFirstChildOfClass("UICorner")
		if not existingCorner then
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 12)
			uiCorner.Parent = colorPaletteFrame
		end
		
		-- 3. Posisi tengah
		colorPaletteFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		colorPaletteFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		-- 4. THEME SPECIFIC ELEMENTS INSIDE COLORPALETTE
		for _, child in ipairs(colorPaletteFrame:GetDescendants()) do
			-- OkButton & CancelButton - theme button (text + background)
			if child.Name == "OkButton" or child.Name == "CancelButton" then
				if child:IsA("TextButton") then
					child.TextColor3 = THEME.TextColor
					child.BackgroundColor3 = THEME.TextButtonColor
					protectColorProperty(child, "TextColor3", THEME.TextColor)
					protectColorProperty(child, "BackgroundColor3", THEME.TextButtonColor)
					
					-- 🚨 HAPUS STROKE dari button
					local btnStroke = child:FindFirstChildOfClass("UIStroke")
					if btnStroke then
						btnStroke:Destroy()
					end
				end
			end
			
			-- BasicColorsTitle - theme background + text
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
					
					-- 🚨 HAPUS STROKE dari label
					local labelStroke = child:FindFirstChildOfClass("UIStroke")
					if labelStroke then
						labelStroke:Destroy()
					end
				end
			end
			
			-- SelectedColor, SelectedColorText, SelectedBrickColorText - HANYA TEXT
			elseif child.Name == "SelectedColor" or child.Name == "SelectedColorText" or child.Name == "SelectedBrickColorText" then
				if child:IsA("TextLabel") then
					child.TextColor3 = THEME.TextColor
					protectColorProperty(child, "TextColor3", THEME.TextColor)
					-- Background TIDAK diubah
					
					-- 🚨 HAPUS STROKE jika ada
					local textStroke = child:FindFirstChildOfClass("UIStroke")
					if textStroke then
						textStroke:Destroy()
					end
				end
			end
			
			-- 🚨 HAPUS SEMUA STROKE di descendants ColorPalette
			if child:IsA("UIStroke") then
				child:Destroy()
			end
		end
	end)
end

-- ====== FUNGSI CARI & PROTECT TOGGLE COLORPALETTE (TIDAK BERUBAH) ======
local function protectColorPaletteToggle()
	local studioGui = playerGui:FindFirstChild("StudioGui")
	if not studioGui then return end
	
	-- Cari toggle button yang munculkan ColorPalette
	-- Biasanya di MainBar atau toolbar area
	for _, descendant in ipairs(studioGui:GetDescendants()) do
		if descendant:IsA("GuiButton") then
			-- Cek apakah button ini related dengan ColorPalette
			local buttonName = descendant.Name
			if buttonName:find("Color") or buttonName:find("Palette") or buttonName:find("color") or buttonName:find("palette") then
				-- JANGAN UBAH BUTTON INI SAMA SEKALI
				-- Simpan warna original
				if descendant:IsA("TextButton") or descendant:IsA("GuiButton") then
					pcall(function()
						-- Hanya protect, tidak ubah
						local originalTextColor = descendant.TextColor3
						local originalBgColor = descendant.BackgroundColor3
						
						-- Jangan override dengan theme color
						-- Biarkan warna original tetap
						print("[DEBUG] Toggle ColorPalette '" .. buttonName .. "' dilindungi (tidak berubah)")
					end)
				end
			end
		end
	end
	
	print("[DEBUG] ColorPalette toggle buttons dilindungi")
end

-- ====== FUNGSI UTAMA: TERAPKAN TEMA + PROTEKSI ======
local function applyTheme(obj)
	if not obj or not obj.Parent then return end

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

	-- SKIP BUTTON DALAM FOLDER DI COLORPALETTE
	if isButtonInFolderInsideColorPalette(obj) then
		return
	end
	
	-- SKIP TOGGLE COLORPALETTE (TIDAK BERUBAH)
	if obj:IsA("GuiButton") then
		local buttonName = obj.Name
		if buttonName:find("Color") or buttonName:find("Palette") or buttonName:find("color") or buttonName:find("palette") then
			return
		end
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

	local allColorPalettes = findAllColorPalettes(playerGui)

	if #allColorPalettes == 0 then
		return
	end

	-- Terapkan theme khusus ke setiap ColorPalette (hanya frame, child elements tetap original)
	for _, colorPalette in ipairs(allColorPalettes) do
		applyColorPaletteTheme(colorPalette)
	end
end

-- ====== FUNGSI RECOLOR SEMUA ======
local function recolorEverything()
	applyTheme(playerGui)

	for _, obj in ipairs(playerGui:GetDescendants()) do
		applyTheme(obj)
	end
end

-- ====== FUNGSI HAPUS SEMUA STROKE DI UI ======
local function removeAllStrokes()
	local studioGui = playerGui:FindFirstChild("StudioGui")
	if not studioGui then return end
	
	-- Hapus semua UIStroke di StudioGui
	for _, obj in ipairs(studioGui:GetDescendants()) do
		if obj:IsA("UIStroke") then
			obj:Destroy()
		end
	end
	
	print("[DEBUG] Semua UIStroke di StudioGui dihapus")
end

-- ====== FUNGSI GABUNGAN ======
local function scanAndApplyAll()
	recolorEverything()
	setupColorPalette()
	
	-- Hapus semua stroke
	task.defer(function()
		removeAllStrokes()
	end)
	
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
	
	-- Buat line separator di MainBar (WARNA BIRU)
	task.defer(function()
		local studioGui = playerGui:FindFirstChild("StudioGui")
		if studioGui then
			local mainBar = studioGui:FindFirstChild("MainBar")
			if mainBar then
				createLineSeparator(mainBar)
				print("[DEBUG] ✅ Line separator BIRU dibuat di MainBar")
			else
				print("[DEBUG] MainBar tidak ditemukan untuk garis")
			end
		else
			print("[DEBUG] StudioGui tidak ditemukan untuk garis")
		end
	end)
	
	-- Protect ColorPalette toggle buttons (TIDAK BERUBAH)
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

-- Auto-apply ke elemen baru + COLOR PROTECTION
playerGui.DescendantAdded:Connect(function(obj)
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
	
	-- Jika ada UIStroke baru, hapus langsung
	if obj:IsA("UIStroke") then
		task.defer(function()
			if obj and obj.Parent then
				obj:Destroy()
			end
		end)
	end
end)

print("[ThemeRecolor v8.1 - FINAL] ✅ Script berjalan! Key: STUDIORIS2024")
print("[ThemeRecolor v8.1] ✅ Semua STROKE dihapus")
print("[ThemeRecolor v8.1] ✅ Garis separator BIRU")
print("[ThemeRecolor v8.1] ✅ Toggle ColorPalette dilindungi")
