--[[
  ██████╗ ███████╗    ██╗   ██╗██╗
 ██╔════╝ ██╔════╝    ██║   ██║██║
 ██║  ███╗███████╗    ██║   ██║██║
 ██║   ██║╚════██║    ██║   ██║██║
 ╚██████╔╝███████║    ╚██████╔╝██║
  ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝

  GaySploits UI Library  v2.0.0
  Style  : Bunni-Hub Dark Gold
  Toggle : RightShift  (slide + blur)
  Host   : https://raw.githubusercontent.com/Romxxr/gsui/refs/heads/main/lib.lua
  Target : CoreGui  /  LocalScript
  License: MIT
--]]

-- ═══════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════
--  THEME  (Bunni-Hub dark-gold aesthetic)
-- ═══════════════════════════════════════════════
local T = {
    -- backgrounds
    BG0          = Color3.fromRGB( 12,  11,  10),   -- deepest bg
    BG1          = Color3.fromRGB( 18,  17,  15),   -- window
    BG2          = Color3.fromRGB( 24,  23,  20),   -- section
    BG3          = Color3.fromRGB( 30,  28,  24),   -- element row
    BG4          = Color3.fromRGB( 38,  35,  28),   -- hover

    -- gold accent palette
    Gold         = Color3.fromRGB(212, 160,  50),   -- primary gol
    GoldBright   = Color3.fromRGB(240, 190,  70),   -- highlight
    GoldDim      = Color3.fromRGB(140,  98,  22),   -- muted gold
    GoldGlow     = Color3.fromRGB(255, 200,  80),   -- glow / ripple

    -- amber pill buttons (secondary)
    Amber        = Color3.fromRGB(190, 120,  20),
    AmberHover   = Color3.fromRGB(220, 150,  35),

    -- borders
    Border       = Color3.fromRGB( 55,  48,  30),
    BorderGold   = Color3.fromRGB(100,  78,  22),
    BorderHover  = Color3.fromRGB(160, 120,  35),

    -- text
    TextPrimary  = Color3.fromRGB(232, 225, 210),
    TextSecond   = Color3.fromRGB(140, 132, 112),
    TextGold     = Color3.fromRGB(212, 160,  50),
    TextMuted    = Color3.fromRGB( 85,  80,  65),

    -- toggle
    ToggleOn     = Color3.fromRGB(212, 160,  50),
    ToggleOff    = Color3.fromRGB( 45,  42,  34),
    ToggleKnob   = Color3.fromRGB(240, 230, 210),

    -- slider
    SliderFill   = Color3.fromRGB(212, 160,  50),
    SliderTrack  = Color3.fromRGB( 38,  34,  24),
    SliderKnob   = Color3.fromRGB(240, 185,  65),

    -- input
    InputBg      = Color3.fromRGB( 20,  19,  16),
    InputBorder  = Color3.fromRGB( 80,  65,  28),

    -- close / min dots (macOS-style)
    DotClose     = Color3.fromRGB(200,  65,  65),
    DotMin       = Color3.fromRGB(200, 155,  40),
    DotMax       = Color3.fromRGB( 40, 170,  80),

    -- navbar
    NavBg        = Color3.fromRGB( 16,  15,  13),
    NavBorder    = Color3.fromRGB( 48,  42,  25),
    NavActive    = Color3.fromRGB(212, 160,  50),
    NavInactive  = Color3.fromRGB( 95,  88,  65),

    -- notif
    NotifBg      = Color3.fromRGB( 20,  19,  15),
    NotifAccent  = Color3.fromRGB(212, 160,  50),

    -- scrollbar
    ScrollBar    = Color3.fromRGB( 80,  65,  28),
}

-- ═══════════════════════════════════════════════
--  UTILITY
-- ═══════════════════════════════════════════════
local function Tween(obj, goals, t, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    local tw = TweenService:Create(obj, TweenInfo.new(t or 0.22, style, dir), goals)
    tw:Play()
    return tw
end

local function New(class, props, parent)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local function Corner(p, r)
    New("UICorner", { CornerRadius = UDim.new(0, r or 8) }, p)
end

local function Stroke(p, color, thick)
    return New("UIStroke", {
        Color           = color or T.Border,
        Thickness       = thick or 1.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, p)
end

local function Ripple(parent)
    local r = New("Frame", {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = T.GoldGlow,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = parent.ZIndex + 8,
    }, parent)
    Corner(r, 999)
    Tween(r, { Size = UDim2.new(2.5,0,2.5,0), BackgroundTransparency = 1 }, 0.55,
        Enum.EasingStyle.Quad)
    task.delay(0.56, function() r:Destroy() end)
end

-- ═══════════════════════════════════════════════
--  DRAG
-- ═══════════════════════════════════════════════
local function MakeDraggable(handle, frame)
    local drag, inp, s0, p0 = false, nil, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; s0 = i.Position; p0 = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then inp = i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == inp and drag then
            local d = i.Position - s0
            frame.Position = UDim2.new(p0.X.Scale, p0.X.Offset+d.X, p0.Y.Scale, p0.Y.Offset+d.Y)
        end
    end)
end

-- ═══════════════════════════════════════════════
--  RESIZE
-- ═══════════════════════════════════════════════
local function MakeResizable(frame, minW, minH)
    minW, minH = minW or 380, minH or 260
    local grip = New("Frame", {
        Size = UDim2.new(0,14,0,14), Position = UDim2.new(1,-14,1,-14),
        BackgroundColor3 = T.GoldDim, BackgroundTransparency = 0.45,
        BorderSizePixel = 0, ZIndex = frame.ZIndex + 10,
    }, frame)
    Corner(grip, 3)
    -- grip lines
    for i = 1, 3 do
        New("Frame", {
            Size = UDim2.new(0, 2+i*2, 0, 1),
            Position = UDim2.new(0, 2, 0, 2+i*3),
            BackgroundColor3 = T.Gold, BackgroundTransparency = 0.3,
            BorderSizePixel = 0, Rotation = -45, ZIndex = grip.ZIndex+1,
        }, grip)
    end
    local res, rs, ss = false, nil, nil
    grip.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            res = true; rs = i.Position
            ss = Vector2.new(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then res = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if res and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - rs
            frame.Size = UDim2.new(0, math.max(minW, ss.X+d.X), 0, math.max(minH, ss.Y+d.Y))
        end
    end)
end

-- ═══════════════════════════════════════════════
--  BLUR  (BlurEffect in Lighting)
-- ═══════════════════════════════════════════════
local BlurFX = Lighting:FindFirstChild("GS_Blur") or New("BlurEffect", {
    Name = "GS_Blur", Size = 0, Enabled = true,
}, Lighting)

local function SetBlur(on)
    Tween(BlurFX, { Size = on and 18 or 0 }, 0.4, Enum.EasingStyle.Quart)
end

-- ═══════════════════════════════════════════════
--  SCREEN GUI  (CoreGui)
-- ═══════════════════════════════════════════════
local ScreenGui
pcall(function()
    if CoreGui:FindFirstChild("GaySploitsUI") then
        CoreGui:FindFirstChild("GaySploitsUI"):Destroy()
    end
    ScreenGui = New("ScreenGui", {
        Name = "GaySploitsUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
    }, CoreGui)
end)
if not ScreenGui then
    ScreenGui = New("ScreenGui", {
        Name = "GaySploitsUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
    }, LocalPlayer:WaitForChild("PlayerGui"))
end

-- ═══════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════
local NotifHolder = New("Frame", {
    Name = "NotifHolder",
    Size = UDim2.new(0,290,1,0),
    Position = UDim2.new(1,-305,0,12),
    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 9999,
}, ScreenGui)
New("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Padding = UDim.new(0,8),
}, NotifHolder)

local function Notify(opts)
    opts = opts or {}
    local card = New("Frame", {
        Size = UDim2.new(1,0,0,70), BackgroundColor3 = T.NotifBg,
        BackgroundTransparency = 0.06, BorderSizePixel = 0,
        ZIndex = 9999, ClipsDescendants = true,
    }, NotifHolder)
    Corner(card, 10)
    Stroke(card, T.BorderGold, 1.2)

    -- gold left bar
    New("Frame", {
        Size = UDim2.new(0,3,1,0), BackgroundColor3 = T.Gold,
        BorderSizePixel = 0, ZIndex = card.ZIndex+1,
    }, card)

    New("TextLabel", {
        Text = opts.Title or "GaySploits",
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = T.TextGold,
        Size = UDim2.new(1,-16,0,20), Position = UDim2.new(0,12,0,8),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = card.ZIndex+1,
    }, card)

    New("TextLabel", {
        Text = opts.Content or "",
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.TextSecond,
        Size = UDim2.new(1,-16,0,30), Position = UDim2.new(0,12,0,30),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, ZIndex = card.ZIndex+1,
    }, card)

    card.Position = UDim2.new(1.1,0,0,0)
    Tween(card, { Position = UDim2.new(0,0,0,0) }, 0.38, Enum.EasingStyle.Back)
    task.delay(opts.Duration or 4, function()
        Tween(card, { Position = UDim2.new(1.15,0,0,0) }, 0.28, Enum.EasingStyle.Quart)
        task.delay(0.3, function() card:Destroy() end)
    end)
end

-- ═══════════════════════════════════════════════
--  LIBRARY
-- ═══════════════════════════════════════════════
local Library = {}
Library.__index = Library

function Library:MakeWindow(opts)
    opts = opts or {}
    local title    = opts.Title   or "GaySploits"
    local subtitle = opts.Subtitle or "Premium hub for your favorite games"

    -- ── master container ──────────────────────────────────
    local Win = New("Frame", {
        Name = "GS_Win",
        Size = UDim2.new(0, 640, 0, 480),
        Position = UDim2.new(0.5,-320, 0.5,-240),
        BackgroundColor3 = T.BG1,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 100,
    }, ScreenGui)
    Corner(Win, 12)
    Stroke(Win, T.Border, 1.5)
    MakeResizable(Win, 420, 300)

    -- drop shadow
    local Shadow = New("Frame", {
        Size = UDim2.new(1,36,1,36), Position = UDim2.new(0,-18,0,-12),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.48, BorderSizePixel = 0,
        ZIndex = Win.ZIndex - 1,
    }, Win)
    Corner(Shadow, 20)

    -- ── nav bar ───────────────────────────────────────────
    local NavBar = New("Frame", {
        Name = "NavBar",
        Size = UDim2.new(1,0,0,44),
        BackgroundColor3 = T.NavBg,
        BorderSizePixel = 0, ZIndex = Win.ZIndex+2,
    }, Win)
    Corner(NavBar, 12)
    -- flatten bottom corners
    New("Frame", {
        Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0,0,0.5,0),
        BackgroundColor3 = T.NavBg, BorderSizePixel = 0, ZIndex = NavBar.ZIndex,
    }, NavBar)
    -- bottom border line
    New("Frame", {
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = T.NavBorder, BorderSizePixel = 0,
        ZIndex = NavBar.ZIndex+1,
    }, NavBar)

    -- logo / icon placeholder
    local LogoHolder = New("Frame", {
        Size = UDim2.new(0,28,0,28), Position = UDim2.new(0,10,0.5,-14),
        BackgroundColor3 = T.GoldDim, BackgroundTransparency = 0.3,
        BorderSizePixel = 0, ZIndex = NavBar.ZIndex+2,
    }, NavBar)
    Corner(LogoHolder, 6)
    New("ImageLabel", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Image = opts.LogoId or "",
        ZIndex = LogoHolder.ZIndex+1,
    }, LogoHolder)
    -- "GS" text fallback
    New("TextLabel", {
        Text = "GS", Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Gold, Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, ZIndex = LogoHolder.ZIndex+2,
    }, LogoHolder)

    -- title
    New("TextLabel", {
        Text = title, Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = T.TextPrimary,
        Size = UDim2.new(0,160,1,0), Position = UDim2.new(0,46,0,0),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = NavBar.ZIndex+2,
    }, NavBar)

    -- nav links container (tabs added dynamically)
    local NavLinks = New("Frame", {
        Name = "NavLinks",
        Size = UDim2.new(0,300,1,0), Position = UDim2.new(0.5,-150,0,0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ZIndex = NavBar.ZIndex+2,
    }, NavBar)
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,4),
    }, NavLinks)

    -- mac dots (close / min)
    local function Dot(color, xOff, tip)
        local d = New("Frame", {
            Size = UDim2.new(0,13,0,13),
            Position = UDim2.new(1,xOff,0.5,-6),
            BackgroundColor3 = color,
            BorderSizePixel = 0, ZIndex = NavBar.ZIndex+3,
        }, NavBar)
        Corner(d, 999)
        local btn = New("TextButton", {
            Text = "", Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, ZIndex = d.ZIndex+1,
        }, d)
        d.MouseEnter:Connect(function() Tween(d,{BackgroundTransparency=0.3},0.1) end)
        d.MouseLeave:Connect(function() Tween(d,{BackgroundTransparency=0},0.1) end)
        return btn
    end
    local CloseBtn = Dot(T.DotClose, -18)
    local MinBtn   = Dot(T.DotMin,   -36)

    MakeDraggable(NavBar, Win)

    -- ── hero band (title + subtitle under navbar) ──────────
    local Hero = New("Frame", {
        Size = UDim2.new(1,0,0,54),
        Position = UDim2.new(0,0,0,44),
        BackgroundColor3 = T.BG0,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0, ZIndex = Win.ZIndex+1,
    }, Win)

    New("TextLabel", {
        Text = title, Font = Enum.Font.GothamBlack, TextSize = 22,
        TextColor3 = T.Gold,
        Size = UDim2.new(1,-24,0,28), Position = UDim2.new(0,16,0,6),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Hero.ZIndex+1,
    }, Hero)
    New("TextLabel", {
        Text = subtitle, Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.TextSecond,
        Size = UDim2.new(1,-24,0,16), Position = UDim2.new(0,16,0,32),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Hero.ZIndex+1,
    }, Hero)

    -- small status dot
    New("Frame", {
        Size = UDim2.new(0,8,0,8), Position = UDim2.new(1,-18,0.5,-4),
        BackgroundColor3 = Color3.fromRGB(60,200,80),
        BorderSizePixel = 0, ZIndex = Hero.ZIndex+2,
    }, Hero):FindFirstChildOfClass("UICorner") or
    New("UICorner",{CornerRadius=UDim.new(1,0)},Hero:FindFirstChild("Frame") or Hero)

    -- hero divider
    New("Frame", {
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = T.BorderGold, BackgroundTransparency = 0.5,
        BorderSizePixel = 0, ZIndex = Hero.ZIndex+1,
    }, Hero)

    -- ── content panel (holds tab pages) ───────────────────
    local ContentY = 44 + 54  -- navbar + hero
    local ContentFrame = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1,0,1,-ContentY),
        Position = UDim2.new(0,0,0,ContentY),
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = Win.ZIndex+1,
        ClipsDescendants = true,
    }, Win)

    -- ── open animation ─────────────────────────────────────
    Win.Size = UDim2.new(0,640,0,0)
    Win.BackgroundTransparency = 1
    Tween(Win,{Size=UDim2.new(0,640,0,480),BackgroundTransparency=0.04},
        0.48,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    -- ── visibility / blur ─────────────────────────────────
    local shown = true
    local function SetVisible(v)
        shown = v
        SetBlur(v)
        if v then
            Win.Visible = true
            Win.Size = UDim2.new(0,640,0,0)
            Win.BackgroundTransparency = 1
            Tween(Win,{Size=UDim2.new(0,640,0,480),BackgroundTransparency=0.04},
                0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        else
            Tween(Win,{Size=UDim2.new(0,640,0,0),BackgroundTransparency=1},
                0.32,Enum.EasingStyle.Quart,Enum.EasingDirection.In)
            task.delay(0.33,function() if not shown then Win.Visible=false end end)
        end
    end

    -- RightShift toggle
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            SetVisible(not shown)
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        SetVisible(false)
        task.delay(0.34,function() Win:Destroy(); BlurFX.Size=0 end)
    end)

    local minimised = false
    MinBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            ContentFrame.Visible = false
            Hero.Visible = false
            Tween(Win,{Size=UDim2.new(0,640,0,44)},0.28,Enum.EasingStyle.Quart)
        else
            ContentFrame.Visible = true
            Hero.Visible = true
            Tween(Win,{Size=UDim2.new(0,640,0,480)},0.35,Enum.EasingStyle.Back)
        end
    end)

    -- hint label bottom-right
    New("TextLabel", {
        Text = "RightShift  ·  toggle",
        Font = Enum.Font.Gotham, TextSize = 9,
        TextColor3 = T.TextMuted, BackgroundTransparency = 1,
        Size = UDim2.new(0,140,0,16),
        Position = UDim2.new(1,-148,1,-20),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = Win.ZIndex+5,
    }, Win)

    -- ═══════════════════════════════════════════
    --  WINDOW OBJECT
    -- ═══════════════════════════════════════════
    local WindowObj  = {}
    WindowObj.__index = WindowObj

    local Tabs         = {}   -- { name, btn, page }
    local ActiveTab    = nil

    local function ActivateTab(tab)
        if ActiveTab == tab then return end
        if ActiveTab then
            Tween(ActiveTab.btn, { TextColor3 = T.NavInactive }, 0.18)
            ActiveTab.underline.BackgroundTransparency = 1
            ActiveTab.page.Visible = false
        end
        ActiveTab = tab
        Tween(tab.btn, { TextColor3 = T.NavActive }, 0.18)
        Tween(tab.underline, { BackgroundTransparency = 0 }, 0.18)
        tab.page.Visible = true
    end

    -- ── MakeTab (creates a nav entry + scrollable page) ────
    function WindowObj:MakeTab(tabName)
        local page = New("ScrollingFrame", {
            Name = "Tab_"..tabName,
            Size = UDim2.new(1,-8,1,-8),
            Position = UDim2.new(0,4,0,4),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = T.ScrollBar,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = ContentFrame.ZIndex+1,
            Visible = false,
        }, ContentFrame)
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7)},page)
        New("UIPadding",{
            PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),
            PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,10),
        },page)

        -- nav button
        local navBtn = New("TextButton", {
            Text = tabName, Font = Enum.Font.GothamSemibold, TextSize = 12,
            TextColor3 = T.NavInactive,
            Size = UDim2.new(0,0,1,-10),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ZIndex = NavLinks.ZIndex+1,
        }, NavLinks)
        New("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},navBtn)

        -- underline
        local uline = New("Frame", {
            Size = UDim2.new(1,0,0,2),
            Position = UDim2.new(0,0,1,-2),
            BackgroundColor3 = T.Gold,
            BackgroundTransparency = 1,
            BorderSizePixel = 0, ZIndex = navBtn.ZIndex+1,
        }, navBtn)

        local tabEntry = { btn = navBtn, page = page, underline = uline, name = tabName }
        table.insert(Tabs, tabEntry)

        navBtn.MouseButton1Click:Connect(function()
            ActivateTab(tabEntry)
        end)

        -- auto-activate first tab
        if #Tabs == 1 then
            ActivateTab(tabEntry)
        end

        -- ═══════════════════════════════════════
        --  TAB / SECTION OBJECT
        -- ═══════════════════════════════════════
        local TabObj = {}
        TabObj.__index = TabObj

        -- ── MakeSection ─────────────────────────────────────
        function TabObj:MakeSection(sectionTitle)
            local Sec = New("Frame", {
                Name = "Sec_"..sectionTitle,
                Size = UDim2.new(1,0,0,36),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.BG2,
                BackgroundTransparency = 0.04,
                BorderSizePixel = 0,
                ZIndex = page.ZIndex+1,
            }, page)
            Corner(Sec, 9)
            Stroke(Sec, T.Border, 1.1)

            -- section header
            local SH = New("Frame", {
                Size = UDim2.new(1,0,0,34),
                BackgroundTransparency = 1, BorderSizePixel = 0,
                ZIndex = Sec.ZIndex+1,
            }, Sec)

            -- left gold accent bar
            New("Frame", {
                Size = UDim2.new(0,3,0,18), Position = UDim2.new(0,8,0.5,-9),
                BackgroundColor3 = T.Gold, BorderSizePixel = 0,
                ZIndex = SH.ZIndex+1,
            }, SH)

            New("TextLabel", {
                Text = sectionTitle, Font = Enum.Font.GothamSemibold, TextSize = 12,
                TextColor3 = T.TextGold,
                Size = UDim2.new(1,-20,1,0), Position = UDim2.new(0,18,0,0),
                BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = SH.ZIndex+2,
            }, SH)

            -- divider
            New("Frame", {
                Size = UDim2.new(1,-16,0,1), Position = UDim2.new(0,8,0,34),
                BackgroundColor3 = T.BorderGold, BackgroundTransparency = 0.45,
                BorderSizePixel = 0, ZIndex = Sec.ZIndex+1,
            }, Sec)

            -- elements list
            local EL = New("Frame", {
                Name = "EL", Size = UDim2.new(1,0,0,0),
                Position = UDim2.new(0,0,0,38),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, BorderSizePixel = 0,
                ZIndex = Sec.ZIndex+1,
            }, Sec)
            New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)},EL)
            New("UIPadding",{
                PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),
                PaddingBottom=UDim.new(0,8),
            },EL)

            -- ── row factory ─────────────────────────────────
            local function Row(h)
                h = h or 34
                local r = New("Frame", {
                    Size = UDim2.new(1,0,0,h),
                    BackgroundColor3 = T.BG3, BackgroundTransparency = 0.1,
                    BorderSizePixel = 0, ZIndex = EL.ZIndex+1,
                }, EL)
                Corner(r, 7)
                Stroke(r, T.Border, 0.9)
                r.MouseEnter:Connect(function() Tween(r,{BackgroundColor3=T.BG4},0.15) end)
                r.MouseLeave:Connect(function() Tween(r,{BackgroundColor3=T.BG3},0.15) end)
                return r
            end

            local function RowTxt(parent, text, x, w)
                return New("TextLabel", {
                    Text = text, Font = Enum.Font.Gotham, TextSize = 12,
                    TextColor3 = T.TextPrimary,
                    Size = UDim2.new(0, w or 170, 1, 0),
                    Position = UDim2.new(0, x or 10, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = parent.ZIndex+1,
                }, parent)
            end

            -- ════════════════════════════════════
            --  SECTION OBJECT
            -- ════════════════════════════════════
            local SectionObj = {}
            SectionObj.__index = SectionObj

            -- ── MakeButton ──────────────────────
            function SectionObj:MakeButton(label, callback)
                local r = New("Frame", {
                    Size = UDim2.new(1,0,0,36),
                    BackgroundColor3 = T.Amber, BackgroundTransparency = 0.12,
                    BorderSizePixel = 0, ZIndex = EL.ZIndex+1, ClipsDescendants = true,
                }, EL)
                Corner(r, 7)
                Stroke(r, T.GoldDim, 1.1)

                New("TextLabel", {
                    Text = label, Font = Enum.Font.GothamSemibold, TextSize = 12,
                    TextColor3 = T.TextPrimary,
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1, ZIndex = r.ZIndex+1,
                }, r)

                local btn = New("TextButton", {
                    Text = "", Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1, ZIndex = r.ZIndex+2,
                }, r)
                btn.MouseEnter:Connect(function() Tween(r,{BackgroundColor3=T.AmberHover},0.15) end)
                btn.MouseLeave:Connect(function() Tween(r,{BackgroundColor3=T.Amber},0.15) end)
                btn.MouseButton1Click:Connect(function() Ripple(r); pcall(callback) end)
                return SectionObj
            end

            -- ── MakeToggle ──────────────────────
            function SectionObj:MakeToggle(label, default, callback)
                local state = default or false
                local r = Row(34)
                RowTxt(r, label)

                local Track = New("Frame", {
                    Size = UDim2.new(0,44,0,22),
                    Position = UDim2.new(1,-54,0.5,-11),
                    BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
                    BorderSizePixel = 0, ZIndex = r.ZIndex+1,
                }, r)
                Corner(Track, 999)

                local Knob = New("Frame", {
                    Size = UDim2.new(0,16,0,16),
                    Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                    BackgroundColor3 = T.ToggleKnob, BorderSizePixel = 0,
                    ZIndex = Track.ZIndex+1,
                }, Track)
                Corner(Knob, 999)

                New("TextButton", {
                    Text = "", Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1, ZIndex = r.ZIndex+5,
                }, r).MouseButton1Click:Connect(function()
                    state = not state
                    Tween(Track,{BackgroundColor3 = state and T.ToggleOn or T.ToggleOff},0.2)
                    Tween(Knob,{Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)},0.2)
                    pcall(callback, state)
                end)
                return SectionObj
            end

            -- ── MakeSlider ──────────────────────
            function SectionObj:MakeSlider(label, min, max, default, callback)
                min = min or 0; max = max or 100; default = default or min
                local r = Row(52); r.Size = UDim2.new(1,0,0,52)

                local topR = New("Frame",{
                    Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,
                    BorderSizePixel=0,ZIndex=r.ZIndex+1,
                },r)
                RowTxt(topR,label)

                -- gold value badge
                local Badge = New("Frame",{
                    Size=UDim2.new(0,46,0,19),Position=UDim2.new(1,-54,0.5,-9),
                    BackgroundColor3=T.GoldDim,BackgroundTransparency=0.35,
                    BorderSizePixel=0,ZIndex=topR.ZIndex+1,
                },topR)
                Corner(Badge,5)
                Stroke(Badge,T.BorderGold,1)
                local ValLbl = New("TextLabel",{
                    Text=tostring(default),Font=Enum.Font.GothamBold,TextSize=11,
                    TextColor3=T.Gold,Size=UDim2.new(1,0,1,0),
                    BackgroundTransparency=1,ZIndex=Badge.ZIndex+1,
                },Badge)

                -- track
                local TrackBg = New("Frame",{
                    Size=UDim2.new(1,-20,0,5),Position=UDim2.new(0,10,0,36),
                    BackgroundColor3=T.SliderTrack,BorderSizePixel=0,
                    ZIndex=r.ZIndex+1,
                },r)
                Corner(TrackBg,999)

                local pct0 = (default-min)/(max-min)
                local Fill = New("Frame",{
                    Size=UDim2.new(pct0,0,1,0),BackgroundColor3=T.SliderFill,
                    BorderSizePixel=0,ZIndex=TrackBg.ZIndex+1,
                },TrackBg)
                Corner(Fill,999)

                -- gold gradient on fill
                New("UIGradient",{
                    Color=ColorSequence.new({
                        ColorSequenceKeypoint.new(0,T.GoldDim),
                        ColorSequenceKeypoint.new(1,T.GoldBright),
                    }),Rotation=0,
                },Fill)

                local Knob = New("Frame",{
                    Size=UDim2.new(0,14,0,14),
                    Position=UDim2.new(pct0,-7,0.5,-7),
                    BackgroundColor3=T.SliderKnob,BorderSizePixel=0,
                    ZIndex=Fill.ZIndex+2,
                },TrackBg)
                Corner(Knob,999)
                Stroke(Knob,T.Gold,1.5)

                local sliding = false
                local function UpdateSlider(ix)
                    local ap = TrackBg.AbsolutePosition.X
                    local as = TrackBg.AbsoluteSize.X
                    local p  = math.clamp((ix-ap)/as,0,1)
                    local v  = math.floor(min+(max-min)*p)
                    Tween(Fill,{Size=UDim2.new(p,0,1,0)},0.06)
                    Tween(Knob,{Position=UDim2.new(p,-7,0.5,-7)},0.06)
                    ValLbl.Text = tostring(v)
                    pcall(callback,v)
                end
                TrackBg.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1
                    or i.UserInputType==Enum.UserInputType.Touch then
                        sliding=true; UpdateSlider(i.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement
                    or i.UserInputType==Enum.UserInputType.Touch) then
                        UpdateSlider(i.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1
                    or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
                end)
                return SectionObj
            end

            -- ── MakeTextbox ─────────────────────
            function SectionObj:MakeTextbox(label, placeholder, callback)
                local r = Row(36)
                RowTxt(r, label, 10, 120)

                local IF = New("Frame",{
                    Size=UDim2.new(0,172,0,24),Position=UDim2.new(1,-180,0.5,-12),
                    BackgroundColor3=T.InputBg,BackgroundTransparency=0.1,
                    BorderSizePixel=0,ZIndex=r.ZIndex+1,
                },r)
                Corner(IF,6)
                local st = Stroke(IF,T.InputBorder,1)

                local Box = New("TextBox",{
                    Text="",PlaceholderText=placeholder or "Enter value...",
                    Font=Enum.Font.Gotham,TextSize=11,
                    TextColor3=T.TextPrimary,PlaceholderColor3=T.TextMuted,
                    Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,6,0,0),
                    BackgroundTransparency=1,ClearTextOnFocus=false,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    ZIndex=IF.ZIndex+1,
                },IF)
                Box.Focused:Connect(function()
                    Tween(IF,{BackgroundColor3=T.BG4},0.15)
                    st.Color = T.Gold
                end)
                Box.FocusLost:Connect(function(enter)
                    Tween(IF,{BackgroundColor3=T.InputBg},0.15)
                    st.Color = T.InputBorder
                    if enter then pcall(callback,Box.Text) end
                end)
                return SectionObj
            end

            -- ── MakeDropdown ─────────────────────
            function SectionObj:MakeDropdown(label, options, callback)
                options = options or {}
                local selected = options[1] or "Select..."
                local open = false

                local Wrap = New("Frame",{
                    Size=UDim2.new(1,0,0,34),
                    AutomaticSize=Enum.AutomaticSize.Y,
                    BackgroundTransparency=1,BorderSizePixel=0,
                    ZIndex=EL.ZIndex+1,ClipsDescendants=false,
                },EL)
                New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},Wrap)

                local HR = New("Frame",{
                    Size=UDim2.new(1,0,0,34),
                    BackgroundColor3=T.BG3,BackgroundTransparency=0.1,
                    BorderSizePixel=0,ZIndex=Wrap.ZIndex+1,ClipsDescendants=true,
                },Wrap)
                Corner(HR,7); Stroke(HR,T.Border,0.9)
                HR.MouseEnter:Connect(function() Tween(HR,{BackgroundColor3=T.BG4},0.15) end)
                HR.MouseLeave:Connect(function() Tween(HR,{BackgroundColor3=T.BG3},0.15) end)

                RowTxt(HR,label,10,130)

                local SelLbl = New("TextLabel",{
                    Text=selected,Font=Enum.Font.GothamSemibold,TextSize=11,
                    TextColor3=T.Gold,
                    Size=UDim2.new(0,110,1,0),Position=UDim2.new(1,-126,0,0),
                    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right,
                    ZIndex=HR.ZIndex+1,
                },HR)

                local Chev = New("TextLabel",{
                    Text="▾",Font=Enum.Font.GothamBold,TextSize=12,
                    TextColor3=T.Gold,
                    Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-20,0,0),
                    BackgroundTransparency=1,ZIndex=HR.ZIndex+1,
                },HR)

                local LF = New("Frame",{
                    Size=UDim2.new(1,0,0,0),
                    BackgroundColor3=T.BG2,BackgroundTransparency=0.04,
                    BorderSizePixel=0,ClipsDescendants=true,
                    ZIndex=Wrap.ZIndex+2,Visible=false,
                },Wrap)
                Corner(LF,7); Stroke(LF,T.GoldDim,1.1)

                New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},LF)
                New("UIPadding",{
                    PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),
                    PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4),
                },LF)

                for _,opt in ipairs(options) do
                    local ob = New("TextButton",{
                        Text=opt,Font=Enum.Font.Gotham,TextSize=11,
                        TextColor3 = opt==selected and T.Gold or T.TextPrimary,
                        Size=UDim2.new(1,0,0,28),
                        BackgroundColor3 = opt==selected and T.GoldDim or T.BG3,
                        BackgroundTransparency = opt==selected and 0.5 or 0.3,
                        BorderSizePixel=0,ZIndex=LF.ZIndex+1,
                    },LF)
                    Corner(ob,5)
                    ob.MouseEnter:Connect(function() Tween(ob,{BackgroundColor3=T.BG4},0.12) end)
                    ob.MouseLeave:Connect(function()
                        Tween(ob,{BackgroundColor3 = opt==selected and T.GoldDim or T.BG3},0.12)
                    end)
                    ob.MouseButton1Click:Connect(function()
                        selected=opt; SelLbl.Text=opt; open=false
                        Tween(LF,{Size=UDim2.new(1,0,0,0)},0.2,Enum.EasingStyle.Quart)
                        Tween(Chev,{Rotation=0},0.2)
                        task.delay(0.21,function() LF.Visible=false end)
                        pcall(callback,opt)
                    end)
                end

                local fullH = #options*30+8
                New("TextButton",{
                    Text="",Size=UDim2.new(1,0,1,0),
                    BackgroundTransparency=1,ZIndex=HR.ZIndex+5,
                },HR).MouseButton1Click:Connect(function()
                    open=not open
                    if open then
                        LF.Visible=true; LF.Size=UDim2.new(1,0,0,0)
                        Tween(LF,{Size=UDim2.new(1,0,0,fullH)},0.26,Enum.EasingStyle.Back)
                        Tween(Chev,{Rotation=180},0.2)
                    else
                        Tween(LF,{Size=UDim2.new(1,0,0,0)},0.2,Enum.EasingStyle.Quart)
                        Tween(Chev,{Rotation=0},0.2)
                        task.delay(0.21,function() LF.Visible=false end)
                    end
                end)
                return SectionObj
            end

            -- ── MakeLabel ───────────────────────
            function SectionObj:MakeLabel(text)
                local r = New("Frame",{
                    Size=UDim2.new(1,0,0,26),
                    BackgroundTransparency=1,BorderSizePixel=0,
                    ZIndex=EL.ZIndex+1,
                },EL)
                New("TextLabel",{
                    Text="  "..text,Font=Enum.Font.Gotham,TextSize=11,
                    TextColor3=T.TextSecond,Size=UDim2.new(1,0,1,0),
                    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
                    TextWrapped=true,ZIndex=r.ZIndex+1,
                },r)
                return SectionObj
            end

            -- ── MakeKeybind (display-only badge) ─
            function SectionObj:MakeKeybind(label, key)
                local r = Row(34)
                RowTxt(r, label)
                local Badge = New("Frame",{
                    Size=UDim2.new(0,52,0,22),Position=UDim2.new(1,-60,0.5,-11),
                    BackgroundColor3=T.GoldDim,BackgroundTransparency=0.4,
                    BorderSizePixel=0,ZIndex=r.ZIndex+1,
                },r)
                Corner(Badge,5); Stroke(Badge,T.BorderGold,1)
                New("TextLabel",{
                    Text=key or "None",Font=Enum.Font.GothamBold,TextSize=11,
                    TextColor3=T.Gold,Size=UDim2.new(1,0,1,0),
                    BackgroundTransparency=1,ZIndex=Badge.ZIndex+1,
                },Badge)
                return SectionObj
            end

            return SectionObj
        end -- MakeSection

        return TabObj
    end -- MakeTab

    -- backwards-compat: MakeSection directly on window → auto first-tab
    function WindowObj:MakeSection(name)
        if #Tabs == 0 then self:MakeTab("Main") end
        local lastTab = Tabs[#Tabs]
        -- rebuild section inside lastTab page using its EL
        -- delegate cleanly
        local tabProxy = { MakeSection = function(_, n) return lastTab end }
        -- actually just call MakeTab's section logic via stored tab obj
        -- (cleaner: store first TabObj)
        return self._firstTab and self._firstTab:MakeSection(name)
            or self:MakeTab("Main"):MakeSection(name)
    end

    -- Notify shortcut
    function WindowObj:Notify(o) Notify(o) end

    return WindowObj
end

function Library:Notify(o) Notify(o) end

-- initial blur off
SetBlur(true)   -- blur on because window opens visible

return Library
