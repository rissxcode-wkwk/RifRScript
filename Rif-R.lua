-- AutoHarvest v2.1 — LocalScript
-- Features:
--   • Deteksi label "your inventory is full" → auto harvest mati otomatis
--   • Counter harvest akurat (nambah tiap HarvestPart baru berhasil diambil)
--   • UI ultra-modern dengan animasi smooth
--   • [NEW] Klik Header untuk Collapse/Expand UI
--   • [NEW] Label penghitung isi Inventory (Backpack + Character Tools)
--   • [NEW] Layout & Scale yang lebih rapi dan proporsional

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local Player = Players.LocalPlayer

local AutoHarvest    = false
local HarvestDelay   = 0.2
local TotalHarvested = 0
local InventoryFull  = false
local isCollapsed    = false

-- ╔══════════════════════════════════════════════╗
-- ║                  THEME                       ║
-- ╚══════════════════════════════════════════════╝

local C = {
	BG           = Color3.fromRGB(8,  10,  14),
	BG2          = Color3.fromRGB(14, 18,  24),
	PANEL        = Color3.fromRGB(20, 25,  33),
	PANEL2       = Color3.fromRGB(26, 32,  42),
	BORDER       = Color3.fromRGB(40, 50,  65),
	BORDER_GLOW  = Color3.fromRGB(0, 210, 100),

	-- Green (active)
	GREEN        = Color3.fromRGB(0, 220, 100),
	GREEN_DIM    = Color3.fromRGB(0,  70,  35),
	GREEN_MID    = Color3.fromRGB(0, 150,  70),

	-- Red (inactive / warning)
	RED          = Color3.fromRGB(230, 55, 55),
	RED_DIM      = Color3.fromRGB(80,  20, 20),

	-- Amber (inventory full warning / inventory count)
	AMBER        = Color3.fromRGB(255, 185, 30),
	AMBER_DIM    = Color3.fromRGB(80,  55,  5),

	TEXT         = Color3.new(1, 1, 1),
	TEXT_DIM     = Color3.fromRGB(160, 175, 195),
	TEXT_DARK    = Color3.fromRGB(90, 110, 135),
}

-- ╔══════════════════════════════════════════════╗
-- ║               HELPER FUNCTIONS               ║
-- ╚══════════════════════════════════════════════╝

local function Corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
	return c
end

local function Stroke(p, col, th, trans)
	local s = Instance.new("UIStroke")
	s.Color = col or C.BORDER
	s.Thickness = th or 1
	s.Transparency = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function Gradient(p, cs, rot)
	local g = Instance.new("UIGradient")
	g.Color = cs
	g.Rotation = rot or 90
	g.Parent = p
	return g
end

local function Label(parent, t, sz, pos, col, font, align, xalign)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = t or ""
	l.Size = sz or UDim2.new(1,0,1,0)
	l.Position = pos or UDim2.new(0,0,0,0)
	l.TextColor3 = col or C.TEXT
	l.Font = font or Enum.Font.GothamBold
	l.TextSize = xalign or 14
	l.TextScaled = false
	l.TextXAlignment = align or Enum.TextXAlignment.Center
	l.Parent = parent
	return l
end

local function MakeFrame(parent, sz, pos, bg, trans)
	local f = Instance.new("Frame")
	f.Size = sz
	f.Position = pos or UDim2.new(0,0,0,0)
	f.BackgroundColor3 = bg or C.PANEL
	f.BackgroundTransparency = trans or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

-- ╔══════════════════════════════════════════════╗
-- ║                  GUI ROOT                    ║
-- ╚══════════════════════════════════════════════╝

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoHarvestPRO"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = Player:WaitForChild("PlayerGui")

-- ╔══════════════════════════════════════════════╗
-- ║               MAIN FRAME                     ║
-- ╚══════════════════════════════════════════════╝
-- Ukuran diperbesar sedikit untuk menampung 3 stat cards & animasi smooth
local Frame = MakeFrame(Gui, UDim2.new(0, 280, 0, 340), UDim2.new(0.5, -140, 0.5, -170), C.BG)
Frame.Active = true
Frame.ClipsDescendants = true
Corner(Frame, 16)
local FrameStroke = Stroke(Frame, C.BORDER, 1.5)

-- Top accent line
local AccentBar = MakeFrame(Frame, UDim2.new(1,0,0,2), UDim2.new(0,0,0,0), C.GREEN)
AccentBar.ZIndex = 6
Gradient(AccentBar, ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,140,60)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,120)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,140,60)),
}), 0)

-- Background subtle tint
local BgTint = MakeFrame(Frame, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.BG2)
BgTint.ZIndex = 0
Gradient(BgTint, ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(8, 10, 14)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(12, 16, 22)),
}), 135)

-- ╔══════════════════════════════════════════════╗
-- ║                  HEADER                      ║
-- ╚══════════════════════════════════════════════╝

local Header = MakeFrame(Frame, UDim2.new(1,0,0,50), UDim2.new(0,0,0,2), C.BG, 1)
Header.ZIndex = 3

-- Logo circle
local LogoCircle = MakeFrame(Header, UDim2.new(0,36,0,36), UDim2.new(0,12,0.5,-18), C.GREEN_DIM)
Corner(LogoCircle, 10)
Stroke(LogoCircle, C.GREEN_MID, 1)
local LogoIcon = Label(LogoCircle, "🌿", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.GREEN, Enum.Font.GothamBold, Enum.TextXAlignment.Center, 18)
LogoIcon.TextScaled = true

-- Title
local TitleLbl = Label(Header, "AUTO HARVEST", UDim2.new(1,-70,0,20), UDim2.new(0,56,0,8), C.TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 15)
local SubLbl   = Label(Header, "PRO FARMING UTILITY", UDim2.new(1,-70,0,14), UDim2.new(0,56,0,28), C.TEXT_DIM, Enum.Font.Gotham, Enum.TextXAlignment.Left, 10)

-- Version badge
local VerBadge = MakeFrame(Header, UDim2.new(0,32,0,16), UDim2.new(1,-44,0.5,-8), Color3.fromRGB(0,60,30))
Corner(VerBadge, 4)
Stroke(VerBadge, C.GREEN_MID, 1)
Label(VerBadge, "v2.1", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.GREEN, Enum.Font.GothamBold, Enum.TextXAlignment.Center, 9)

-- Status dot + ring
local StatusDot = MakeFrame(Header, UDim2.new(0,9,0,9), UDim2.new(1,-18,0,10), C.RED)
Corner(StatusDot, 99)
local StatusRing = MakeFrame(Header, UDim2.new(0,9,0,9), UDim2.new(1,-18,0,10), C.BG, 1)
Corner(StatusRing, 99)
Stroke(StatusRing, C.RED, 1.5)

-- Collapse Toggle Icon
local CollapseIcon = Label(Header, "▼", UDim2.new(0, 24, 0, 24), UDim2.new(1, -32, 0.5, -12), C.TEXT_DIM, Enum.Font.GothamBold, Enum.TextXAlignment.Center, 16)
CollapseIcon.ZIndex = 5

-- ╔══════════════════════════════════════════════╗
-- ║               DIVIDER 1                      ║
-- ╚══════════════════════════════════════════════╝

local Div1 = MakeFrame(Frame, UDim2.new(1,-24,0,1), UDim2.new(0,12,0,50), C.BORDER)
Gradient(Div1, ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(20,25,33)),
	ColorSequenceKeypoint.new(0.3, C.BORDER),
	ColorSequenceKeypoint.new(0.7, C.BORDER),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(20,25,33)),
}), 0)

-- ╔══════════════════════════════════════════════╗
-- ║          INVENTORY FULL WARNING BANNER       ║
-- ╚══════════════════════════════════════════════╝

local WarnBanner = MakeFrame(Frame, UDim2.new(1,-24,0,0), UDim2.new(0,12,0,58), C.AMBER_DIM)
WarnBanner.ClipsDescendants = true
Corner(WarnBanner, 8)
Stroke(WarnBanner, C.AMBER, 1)
local WarnIcon = Label(WarnBanner, "⚠", UDim2.new(0,24,1,0), UDim2.new(0,8,0,0), C.AMBER, Enum.Font.GothamBold, Enum.TextXAlignment.Center, 14)
WarnIcon.TextScaled = true
local WarnText = Label(WarnBanner, "INVENTORY FULL — Harvest stopped", UDim2.new(1,-40,1,0), UDim2.new(0,34,0,0), C.AMBER, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 11)

-- starts hidden (height = 0)
WarnBanner.Size = UDim2.new(1,-24,0,0)
WarnBanner.BackgroundTransparency = 1
local warnVisible = false

local function ShowWarning(show)
	if show == warnVisible then return end
	warnVisible = show
	
	-- Auto-expand jika warning muncul saat UI sedang terlipat
	if show and isCollapsed then
		isCollapsed = false
		CollapseIcon.Text = "▼"
	end

	local shift = show and 42 or 0
	local targetH = isCollapsed and 50 or (show and 380 or 340)

	TweenService:Create(WarnBanner, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
		Size = show and UDim2.new(1,-24,0,34) or UDim2.new(1,-24,0,0),
		BackgroundTransparency = show and 0 or 1,
	}):Play()
	
	-- Shift semua elemen di bawahnya
	TweenService:Create(Div2Ref,       TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = UDim2.new(0,12,0,98+shift) }):Play()
	TweenService:Create(ToggleBtnRef,  TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = UDim2.new(0,12,0,106+shift) }):Play()
	TweenService:Create(DelayRowRef,   TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = UDim2.new(0,12,0,158+shift) }):Play()
	TweenService:Create(StatsRowRef,   TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = UDim2.new(0,12,0,204+shift) }):Play()
	TweenService:Create(Div3Ref,       TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = UDim2.new(0,12,0,292+shift) }):Play()
	TweenService:Create(StatusBarRef,  TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = UDim2.new(0,12,0,300+shift) }):Play()
	
	-- Adjust frame height
	TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
		Size = UDim2.new(0, 280, 0, targetH)
	}):Play()
end

-- ╔══════════════════════════════════════════════╗
-- ║              SECOND DIVIDER                  ║
-- ╚══════════════════════════════════════════════╝

local Div2 = MakeFrame(Frame, UDim2.new(1,-24,0,1), UDim2.new(0,12,0,98), C.BORDER)
Gradient(Div2, ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(20,25,33)),
	ColorSequenceKeypoint.new(0.3, C.BORDER),
	ColorSequenceKeypoint.new(0.7, C.BORDER),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(20,25,33)),
}), 0)
local Div2Ref = Div2

-- ╔══════════════════════════════════════════════╗
-- ║              TOGGLE BUTTON                   ║
-- ╚══════════════════════════════════════════════╝

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1,-24,0,44)
ToggleBtn.Position = UDim2.new(0,12,0,106)
ToggleBtn.BackgroundColor3 = C.RED_DIM
ToggleBtn.Text = ""
ToggleBtn.AutoButtonColor = false
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = Frame
Corner(ToggleBtn, 12)
local ToggleStroke = Stroke(ToggleBtn, C.RED, 1.5)
local ToggleBtnRef = ToggleBtn

-- Glow layer inside button
local BtnGlow = MakeFrame(ToggleBtn, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.RED, 0.92)
Corner(BtnGlow, 12)

-- Icon bg circle
local BtnIconBg = MakeFrame(ToggleBtn, UDim2.new(0,30,0,30), UDim2.new(0,8,0.5,-15), C.RED_DIM)
Corner(BtnIconBg, 8)
Stroke(BtnIconBg, C.RED, 1)
local BtnIcon = Label(BtnIconBg, "⏸", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.RED, Enum.Font.GothamBold, Enum.TextXAlignment.Center, 14)
BtnIcon.TextScaled = true

local BtnLabel = Label(ToggleBtn, "START HARVESTING", UDim2.new(1,-56,1,0), UDim2.new(0,46,0,0), C.TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 13)

-- ╔══════════════════════════════════════════════╗
-- ║              DELAY ROW                       ║
-- ╚══════════════════════════════════════════════╝

local DelayRow = MakeFrame(Frame, UDim2.new(1,-24,0,38), UDim2.new(0,12,0,158), C.PANEL)
Corner(DelayRow, 10)
Stroke(DelayRow, C.BORDER, 1)
local DelayRowRef = DelayRow

-- icon
local DelayIcon = MakeFrame(DelayRow, UDim2.new(0,26,0,26), UDim2.new(0,6,0.5,-13), C.BG2)
Corner(DelayIcon, 7)
Label(DelayIcon, "⏱", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), C.TEXT_DIM, Enum.Font.GothamBold, Enum.TextXAlignment.Center, 14)

Label(DelayRow, "DELAY (s)", UDim2.new(0,80,1,0), UDim2.new(0,38,0,0), C.TEXT_DIM, Enum.Font.Gotham, Enum.TextXAlignment.Left, 11)

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(0,72,0,26)
DelayBox.Position = UDim2.new(1,-80,0.5,-13)
DelayBox.BackgroundColor3 = C.BG2
DelayBox.TextColor3 = C.GREEN
DelayBox.PlaceholderText = "0.2"
DelayBox.Text = tostring(HarvestDelay)
DelayBox.TextScaled = false
DelayBox.TextSize = 13
DelayBox.Font = Enum.Font.GothamBold
DelayBox.ClearTextOnFocus = false
DelayBox.TextXAlignment = Enum.TextXAlignment.Center
DelayBox.Parent = DelayRow
Corner(DelayBox, 7)
Stroke(DelayBox, C.BORDER, 1)

-- ╔══════════════════════════════════════════════╗
-- ║              STATS ROW (3 CARDS)             ║
-- ╚══════════════════════════════════════════════╝

local StatsRow = MakeFrame(Frame, UDim2.new(1,-24,0,80), UDim2.new(0,12,0,204), C.BG, 1)
local StatsRowRef = StatsRow

local function StatCard(parent, xpos, icon, labelTxt, defaultVal, accentCol)
	local card = MakeFrame(parent, UDim2.new(0.31, 0, 1, 0), UDim2.new(xpos, 0, 0, 0), C.PANEL)
	Corner(card, 10)
	Stroke(card, C.BORDER, 1)

	-- top color stripe
	local stripe = MakeFrame(card, UDim2.new(1,0,0,2), UDim2.new(0,0,0,0), accentCol)
	Corner(stripe, 2)

	-- icon row
	local iconLbl = Label(card, icon, UDim2.new(1,0,0,16), UDim2.new(0,0,0,8), accentCol, Enum.Font.GothamBold, Enum.TextXAlignment.Center, 12)
	iconLbl.TextScaled = true

	-- label
	local lbl = Label(card, labelTxt, UDim2.new(1,0,0,13), UDim2.new(0,0,0,26), C.TEXT_DARK, Enum.Font.Gotham, Enum.TextXAlignment.Center, 9)

	-- value
	local val = Label(card, defaultVal, UDim2.new(1,-8,0,26), UDim2.new(0,4,0,42), accentCol, Enum.Font.GothamBold, Enum.TextXAlignment.Center, 16)
	val.TextScaled = false

	return val
end

local AvailableVal  = StatCard(StatsRow, 0,      "📦", "AVAILABLE", "0", C.TEXT_DIM)
local InventoryVal  = StatCard(StatsRow, 0.343,  "🎒", "INVENTORY", "0", C.AMBER)
local HarvestedVal  = StatCard(StatsRow, 0.686,  "🌿", "HARVESTED", "0", C.GREEN)

-- ╔══════════════════════════════════════════════╗
-- ║              DIVIDER 3 + STATUS BAR          ║
-- ╚══════════════════════════════════════════════╝

local Div3 = MakeFrame(Frame, UDim2.new(1,-24,0,1), UDim2.new(0,12,0,292), C.BORDER)
Gradient(Div3, ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(20,25,33)),
	ColorSequenceKeypoint.new(0.3, C.BORDER),
	ColorSequenceKeypoint.new(0.7, C.BORDER),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(20,25,33)),
}), 0)
local Div3Ref = Div3

-- Status text at bottom
local StatusBar = Label(Frame, "● IDLE — Waiting to start", UDim2.new(1,-24,0,14), UDim2.new(0,12,0,300), C.TEXT_DARK, Enum.Font.Gotham, Enum.TextXAlignment.Left, 10)
local StatusBarRef = StatusBar

-- ╔══════════════════════════════════════════════╗
-- ║                DRAG & COLLAPSE LOGIC         ║
-- ╚══════════════════════════════════════════════╝

local Dragging = false
local DragInput, DragStart, StartPos, DragStartPos

local function ToggleCollapse()
	isCollapsed = not isCollapsed
	CollapseIcon.Text = isCollapsed and "▲" or "▼"
	
	local targetH = isCollapsed and 50 or (warnVisible and 380 or 340)
	TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
		Size = UDim2.new(0, 280, 0, targetH)
	}):Play()
end

Header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = i.Position
		StartPos = Frame.Position
		DragStartPos = i.Position
	end
end)

Header.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		DragInput = i
	end
end)

Header.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		Dragging = false
		-- Jika pergerakan mouse sangat kecil (< 5 pixel), anggap sebagai klik (bukan drag)
		if DragStartPos and (i.Position - DragStartPos).Magnitude < 5 then
			ToggleCollapse()
		end
		DragStartPos = nil
	end
end)

UIS.InputChanged:Connect(function(i)
	if i == DragInput and Dragging then
		local d = i.Position - DragStart
		Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + d.X, StartPos.Y.Scale, StartPos.Y.Offset + d.Y)
	end
end)

-- ╔══════════════════════════════════════════════╗
-- ║             PULSE ANIMATION                  ║
-- ╚══════════════════════════════════════════════╝

local pulseActive = false

local function StartPulse()
	if pulseActive then return end
	pulseActive = true
	task.spawn(function()
		while pulseActive do
			TweenService:Create(StatusRing, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-24,0,5), BackgroundTransparency = 0.3
			}):Play()
			task.wait(0.5)
			TweenService:Create(StatusRing, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0,9,0,9), Position = UDim2.new(1,-18,0,10), BackgroundTransparency = 1
			}):Play()
			task.wait(0.7)
		end
	end)
end

local function StopPulse()
	pulseActive = false
	StatusRing.Size = UDim2.new(0,9,0,9)
	StatusRing.Position = UDim2.new(1,-18,0,10)
	StatusRing.BackgroundTransparency = 1
end

-- ╔══════════════════════════════════════════════╗
-- ║            TOGGLE STATE LOGIC                ║
-- ╚══════════════════════════════════════════════╝

local function SetToggleOn(on)
	if on then
		TweenService:Create(ToggleBtn,   TweenInfo.new(0.2), { BackgroundColor3 = C.GREEN_DIM }):Play()
		TweenService:Create(BtnGlow,     TweenInfo.new(0.2), { BackgroundColor3 = C.GREEN_MID, BackgroundTransparency = 0.88 }):Play()
		TweenService:Create(BtnIconBg,   TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(0,50,25) }):Play()
		ToggleStroke.Color = C.GREEN
		BtnIcon.Text = "▶"
		BtnIcon.TextColor3 = C.GREEN
		BtnLabel.Text = "STOP HARVESTING"
		Stroke(BtnIconBg, C.GREEN, 1)
		StatusDot.BackgroundColor3 = C.GREEN
		Stroke(StatusRing, C.GREEN, 1.5)
		StatusBar.Text = "● RUNNING — Auto harvesting active"
		StatusBar.TextColor3 = C.GREEN
		StartPulse()
	else
		TweenService:Create(ToggleBtn,   TweenInfo.new(0.2), { BackgroundColor3 = C.RED_DIM }):Play()
		TweenService:Create(BtnGlow,     TweenInfo.new(0.2), { BackgroundColor3 = C.RED, BackgroundTransparency = 0.92 }):Play()
		TweenService:Create(BtnIconBg,   TweenInfo.new(0.2), { BackgroundColor3 = C.RED_DIM }):Play()
		ToggleStroke.Color = C.RED
		BtnIcon.Text = "⏸"
		BtnIcon.TextColor3 = C.RED
		BtnLabel.Text = "START HARVESTING"
		Stroke(BtnIconBg, C.RED, 1)
		StatusDot.BackgroundColor3 = C.RED
		Stroke(StatusRing, C.RED, 1.5)
		StatusBar.Text = "● IDLE — Waiting to start"
		StatusBar.TextColor3 = C.TEXT_DARK
		StopPulse()
	end
end

-- Hover effects
ToggleBtn.MouseEnter:Connect(function()
	TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {
		BackgroundColor3 = AutoHarvest and Color3.fromRGB(0,90,45) or Color3.fromRGB(100,25,25)
	}):Play()
end)

ToggleBtn.MouseLeave:Connect(function()
	TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {
		BackgroundColor3 = AutoHarvest and C.GREEN_DIM or C.RED_DIM
	}):Play()
end)

ToggleBtn.MouseButton1Click:Connect(function()
	if InventoryFull then return end
	AutoHarvest = not AutoHarvest
	SetToggleOn(AutoHarvest)
end)

-- ╔══════════════════════════════════════════════╗
-- ║              DELAY INPUT                     ║
-- ╚══════════════════════════════════════════════╝

DelayBox.FocusLost:Connect(function()
	local n = tonumber(DelayBox.Text)
	if n and n > 0 then
		HarvestDelay = math.clamp(n, 0.05, 60)
		DelayBox.Text = string.format("%.2f", HarvestDelay)
	else
		DelayBox.Text = tostring(HarvestDelay)
	end
end)

-- ╔══════════════════════════════════════════════╗
-- ║         INVENTORY FULL DETECTION             ║
-- ╚══════════════════════════════════════════════╝

local function CheckInventoryFull()
	local gui = Player:FindFirstChild("PlayerGui")
	if not gui then return false end

	for _, obj in ipairs(gui:GetDescendants()) do
		if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("Frame")) then
			local txt = ""
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				txt = obj.Text or ""
			end
			if txt:lower():find("inventory is full") or txt:lower():find("inventori penuh") then
				return true
			end
		end
	end
	return false
end

-- ╔══════════════════════════════════════════════╗
-- ║            INVENTORY COUNT TRACKER           ║
-- ╚══════════════════════════════════════════════╝
-- Menghitung jumlah Tool di Backpack dan Karakter secara real-time

local function UpdateInventoryCount()
	local count = #Player.Backpack:GetChildren()
	if Player.Character then
		for _, child in ipairs(Player.Character:GetChildren()) do
			if child:IsA("Tool") then
				count += 1
			end
		end
	end
	InventoryVal.Text = tostring(count)
end

Player.Backpack.ChildAdded:Connect(UpdateInventoryCount)
Player.Backpack.ChildRemoved:Connect(UpdateInventoryCount)
Player.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(UpdateInventoryCount)
	char.ChildRemoved:Connect(UpdateInventoryCount)
	UpdateInventoryCount()
end)
UpdateInventoryCount() -- Initial call

-- ╔══════════════════════════════════════════════╗
-- ║             COUNT AVAILABLE                  ║
-- ╚══════════════════════════════════════════════╝

local function CountAvailable()
	local n = 0
	for _, v in ipairs(workspace:GetDescendants()) do
		if v.Name == "HarvestPart" then n += 1 end
	end
	return n
end

-- ╔══════════════════════════════════════════════╗
-- ║              HARVEST FUNCTION                ║
-- ╚══════════════════════════════════════════════╝

local function Harvest()
	local beforeCount = CountAvailable()

	for _, v in ipairs(workspace:GetDescendants()) do
		if v.Name == "HarvestPart" and v:IsA("BasePart") then
			local Prompt = v:FindFirstChild("HarvestPrompt")
			if not Prompt then
				for _, x in ipairs(v:GetDescendants()) do
					if x:IsA("ProximityPrompt") and x.Name == "HarvestPrompt" then
						Prompt = x
						break
					end
				end
			end
			if Prompt and Prompt:IsA("ProximityPrompt") then
				pcall(function()
					fireproximityprompt(Prompt)
				end)
			end
		end
	end

	task.wait(0.05)

	local afterCount = CountAvailable()
	local gained     = math.max(0, beforeCount - afterCount)

	if gained > 0 then
		TotalHarvested = TotalHarvested + gained
		HarvestedVal.Text = tostring(TotalHarvested)
	end
end

-- ╔══════════════════════════════════════════════╗
-- ║                MAIN LOOP                     ║
-- ╚══════════════════════════════════════════════╝

task.spawn(function()
	while true do
		local avail = CountAvailable()
		AvailableVal.Text = tostring(avail)

		local isFull = CheckInventoryFull()

		if isFull and not InventoryFull then    
			InventoryFull = true    
			if AutoHarvest then    
				AutoHarvest = false    
				SetToggleOn(false)    
			end    
			ShowWarning(true)    
			StatusBar.Text = "⚠ STOPPED — Inventory is full!"    
			StatusBar.TextColor3 = C.AMBER    
		elseif not isFull and InventoryFull then    
			InventoryFull = false    
			ShowWarning(false)    
			if not AutoHarvest then    
				StatusBar.Text = "● IDLE — Inventory cleared"    
				StatusBar.TextColor3 = C.TEXT_DARK    
			end    
		end    

		if AutoHarvest and not InventoryFull then    
			Harvest()    
		end    

		task.wait(HarvestDelay)
	end
end)
