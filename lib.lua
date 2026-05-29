--[[
  ╔══════════════════════════════════════════════════════════════════╗
  ║              GaySploits UI Library  •  v1.0.0                   ║
  ║              https://gaysploits.xyz                             ║
  ║                                                                  ║
  ║  Pure Roblox Lua · CoreGui · Loadstring-Compatible              ║
  ║  MIT License  © 2025 GaySploits                                 ║
  ╚══════════════════════════════════════════════════════════════════╝

  USAGE:
    local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/.../main/lib.lua"))()
    local Window  = UI:MakeWindow({ Title = "My Hub", Theme = "Dark" })
    local Section = Window:MakeSection("Combat")
    Section:MakeButton("Kill All", function() ... end)
    Section:MakeToggle("God Mode", false, function(v) ... end)
    Section:MakeSlider("Speed", 0, 100, 16, function(v) ... end)
    Section:MakeTextbox("Target", "Enter name...", function(t, enter) ... end)
    Section:MakeDropdown("Team", {"Red","Blue","Green"}, function(v) ... end)
    Section:MakeLabel("Some info text")
]]

-- ─────────────────────────────────────────────────────────────────────────────
--  Services
-- ─────────────────────────────────────────────────────────────────────────────
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local CoreGui            = game:GetService("CoreGui")
local Players            = game:GetService("Players")

-- ─────────────────────────────────────────────────────────────────────────────
--  Theme Palettes
-- ─────────────────────────────────────────────────────────────────────────────
local Themes = {
    Dark = {
        Background    = Color3.fromRGB(12,  12,  18 ),
        Secondary     = Color3.fromRGB(20,  20,  30 ),
        Tertiary      = Color3.fromRGB(28,  28,  42 ),
        Elevated      = Color3.fromRGB(34,  34,  52 ),
        Border        = Color3.fromRGB(55,  55,  80 ),
        Text          = Color3.fromRGB(235, 235, 255),
        SubText       = Color3.fromRGB(145, 145, 175),
        Accent        = Color3.fromRGB(140, 80,  255),
        AccentAlt     = Color3.fromRGB(80,  180, 255),
        Success       = Color3.fromRGB(80,  220, 120),
        Danger        = Color3.fromRGB(255, 75,  75 ),
    },
    Light = {
        Background    = Color3.fromRGB(242, 242, 252),
        Secondary     = Color3.fromRGB(228, 228, 244),
        Tertiary      = Color3.fromRGB(210, 210, 235),
        Elevated      = Color3.fromRGB(255, 255, 255),
        Border        = Color3.fromRGB(175, 175, 210),
        Text          = Color3.fromRGB(18,  18,  32 ),
        SubText       = Color3.fromRGB(90,  90,  125),
        Accent        = Color3.fromRGB(120, 60,  240),
        AccentAlt     = Color3.fromRGB(60,  160, 240),
        Success       = Color3.fromRGB(40,  185, 85 ),
        Danger        = Color3.fromRGB(220, 45,  45 ),
    },
    Midnight = {
        Background    = Color3.fromRGB(8,   8,   14 ),
        Secondary     = Color3.fromRGB(14,  14,  24 ),
        Tertiary      = Color3.fromRGB(20,  20,  36 ),
        Elevated      = Color3.fromRGB(28,  28,  48 ),
        Border        = Color3.fromRGB(40,  40,  70 ),
        Text          = Color3.fromRGB(220, 220, 255),
        SubText       = Color3.fromRGB(110, 110, 155),
        Accent        = Color3.fromRGB(180, 80,  255),
        AccentAlt     = Color3.fromRGB(100, 200, 255),
        Success       = Color3.fromRGB(80,  220, 120),
        Danger        = Color3.fromRGB(255, 65,  65 ),
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
--  Rainbow Spectrum (mirrors gaysploits.xyz logo gradient)
-- ─────────────────────────────────────────────────────────────────────────────
local RAINBOW = {
    Color3.fromRGB(255, 75,  75 ),   -- red
    Color3.fromRGB(255, 155, 50 ),   -- orange
    Color3.fromRGB(255, 235, 50 ),   -- yellow
    Color3.fromRGB(75,  220, 75 ),   -- green
    Color3.fromRGB(50,  200, 255),   -- cyan
    Color3.fromRGB(75,  100, 255),   -- blue
    Color3.fromRGB(185, 75,  255),   -- purple
}

local function RainbowAt(t)
    -- t ∈ [0,1] → smooth color across RAINBOW
    local s = t * (#RAINBOW - 1)
    local i = math.clamp(math.floor(s) + 1, 1, #RAINBOW)
    local j = math.clamp(i + 1,             1, #RAINBOW)
    local f = s - math.floor(s)
    local c1, c2 = RAINBOW[i], RAINBOW[j]
    return Color3.new(
        c1.R + (c2.R - c1.R) * f,
        c1.G + (c2.G - c1.G) * f,
        c1.B + (c2.B - c1.B) * f
    )
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Utility Helpers
-- ─────────────────────────────────────────────────────────────────────────────
local function Tween(inst, props, dur, style, dir)
    local info = TweenInfo.new(
        dur   or 0.28,
        style or Enum.EasingStyle.Quart,
        dir   or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color       = color or Color3.fromRGB(55, 55, 80)
    s.Thickness   = thick or 1
    s.Transparency= trans or 0
    s.Parent      = parent
    return s
end

local function Padding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 6)
    p.PaddingRight  = UDim.new(0, r or 6)
    p.PaddingBottom = UDim.new(0, b or 6)
    p.PaddingLeft   = UDim.new(0, l or 6)
    p.Parent        = parent
    return p
end

local function ListLayout(parent, pad, sort)
    local l = Instance.new("UIListLayout")
    l.Padding   = UDim.new(0, pad  or 0)
    l.SortOrder = sort or Enum.SortOrder.LayoutOrder
    l.Parent    = parent
    return l
end

-- Soft drop shadow using the standard Roblox shadow asset
local function Shadow(parent, spread)
    spread = spread or 24
    local s = Instance.new("ImageLabel")
    s.Name               = "_Shadow"
    s.BackgroundTransparency = 1
    s.Image              = "rbxassetid://6014261993"
    s.ImageColor3        = Color3.fromRGB(0, 0, 0)
    s.ImageTransparency  = 0.55
    s.ScaleType          = Enum.ScaleType.Slice
    s.SliceCenter        = Rect.new(49, 49, 450, 450)
    s.Size               = UDim2.new(1, spread * 2, 1, spread * 2)
    s.Position           = UDim2.new(0, -spread, 0, -spread)
    s.ZIndex             = parent.ZIndex - 1
    s.Parent             = parent
    return s
end

-- Ghost separator line
local function Divider(parent, order)
    local f = Instance.new("Frame")
    f.Size                  = UDim2.new(1, -16, 0, 1)
    f.Position              = UDim2.new(0, 8, 0, 0)
    f.BackgroundColor3      = Color3.fromRGB(55, 55, 80)
    f.BackgroundTransparency= 0.7
    f.BorderSizePixel       = 0
    f.LayoutOrder           = order or 0
    f.Parent                = parent
    return f
end

-- Ripple effect on click
local function Ripple(btn, theme)
    local rip = Instance.new("Frame")
    rip.AnchorPoint = Vector2.new(0.5, 0.5)
    rip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rip.BackgroundTransparency = 0.8
    rip.BorderSizePixel = 0
    rip.Size = UDim2.new(0, 0, 0, 0)
    rip.ZIndex = btn.ZIndex + 1
    Corner(rip, 99)

    btn.MouseButton1Down:Connect(function(x, y)
        local rel = Vector2.new(x - btn.AbsolutePosition.X, y - btn.AbsolutePosition.Y)
        rip.Position = UDim2.new(0, rel.X, 0, rel.Y)
        rip.Size     = UDim2.new(0, 0, 0, 0)
        rip.Parent   = btn
        Tween(rip, {
            Size = UDim2.new(0, btn.AbsoluteSize.X * 2.5, 0, btn.AbsoluteSize.X * 2.5),
            BackgroundTransparency = 1
        }, 0.55, Enum.EasingStyle.Quad)
        task.delay(0.55, function() rip:Destroy() end)
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Draggable window logic
-- ─────────────────────────────────────────────────────────────────────────────
local function MakeDraggable(handle, target)
    local dragging, start, origin = false, nil, nil

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start    = inp.Position
            origin   = target.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - start
            target.Position = UDim2.new(
                origin.X.Scale, origin.X.Offset + d.X,
                origin.Y.Scale, origin.Y.Offset + d.Y
            )
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
--  ScreenGui bootstrapper
-- ─────────────────────────────────────────────────────────────────────────────
local function BootstrapGui()
    -- Destroy any previous instance so hot-reloading works cleanly
    pcall(function()
        local old = CoreGui:FindFirstChild("GaySploitsUI")
        if old then old:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name            = "GaySploitsUI"
    gui.ResetOnSpawn    = false
    gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder    = 999
    gui.IgnoreGuiInset  = true

    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok then
        -- Fallback: PlayerGui (e.g. in Studio without CoreGui access)
        local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        gui.Parent = player:WaitForChild("PlayerGui")
    end

    return gui
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Library root
-- ─────────────────────────────────────────────────────────────────────────────
local Library = {}
Library.__index = Library

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  UI:MakeWindow(config)                                                   │
-- │    config.Title   (string)  — window title bar text                      │
-- │    config.Theme   (string)  — "Dark" | "Light" | "Midnight"              │
-- │    config.Width   (number)  — pixel width, default 420                   │
-- │    config.Height  (number)  — pixel height, default 520                  │
-- └─────────────────────────────────────────────────────────────────────────┘
function Library:MakeWindow(config)
    config = config or {}
    local TITLE   = config.Title  or "GaySploits Hub"
    local W       = config.Width  or 420
    local H       = config.Height or 520
    local theme   = Themes[config.Theme] or Themes.Dark

    local root    = BootstrapGui()
    local cleanups= {}  -- RunService connections, etc.

    -- ── Outer window frame ─────────────────────────────────────────────────
    local win = Instance.new("Frame")
    win.Name             = "Window"
    win.Size             = UDim2.new(0, W, 0, 0)          -- start collapsed
    win.Position         = UDim2.new(0.5, -W/2, 0.5, 0)   -- center screen
    win.BackgroundColor3 = theme.Background
    win.BorderSizePixel  = 0
    win.ClipsDescendants = true
    win.ZIndex           = 2
    win.Parent           = root
    Corner(win, 14)
    Shadow(win, 36)

    -- Animated rainbow outer ring
    local ringStroke = Stroke(win, RAINBOW[1], 1.8, 0)

    -- ── Title bar ──────────────────────────────────────────────────────────
    local bar = Instance.new("Frame")
    bar.Name             = "TitleBar"
    bar.Size             = UDim2.new(1, 0, 0, 54)
    bar.BackgroundColor3 = theme.Secondary
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 5
    bar.Parent           = win
    Corner(bar, 14)

    -- Square off the bottom corners of the bar (visual patch)
    local barPatch = Instance.new("Frame")
    barPatch.Size            = UDim2.new(1, 0, 0, 14)
    barPatch.Position        = UDim2.new(0, 0, 1, -14)
    barPatch.BackgroundColor3= theme.Secondary
    barPatch.BorderSizePixel = 0
    barPatch.ZIndex          = 5
    barPatch.Parent          = bar

    -- Rainbow accent strip (7 segments, sits right under bar)
    local strip = Instance.new("Frame")
    strip.Size            = UDim2.new(1, 0, 0, 3)
    strip.Position        = UDim2.new(0, 0, 1, 0)
    strip.BackgroundTransparency = 1
    strip.BorderSizePixel = 0
    strip.ZIndex          = 6
    strip.Parent          = bar

    for i = 1, 7 do
        local seg = Instance.new("Frame")
        seg.Size             = UDim2.new(1/7, 1, 1, 0)
        seg.Position         = UDim2.new((i-1)/7, 0, 0, 0)
        seg.BackgroundColor3 = RAINBOW[i]
        seg.BorderSizePixel  = 0
        seg.ZIndex           = 6
        seg.Parent           = strip
    end

    -- Icon dot (rainbow animated circle before title text)
    local iconDot = Instance.new("Frame")
    iconDot.Name             = "IconDot"
    iconDot.Size             = UDim2.new(0, 10, 0, 10)
    iconDot.Position         = UDim2.new(0, 14, 0.5, -5)
    iconDot.BackgroundColor3 = RAINBOW[1]
    iconDot.BorderSizePixel  = 0
    iconDot.ZIndex           = 7
    iconDot.Parent           = bar
    Corner(iconDot, 5)

    -- Title text
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size            = UDim2.new(1, -160, 1, 0)
    titleLbl.Position        = UDim2.new(0, 32, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text            = TITLE
    titleLbl.TextColor3      = theme.Text
    titleLbl.TextSize        = 15
    titleLbl.Font            = Enum.Font.GothamBold
    titleLbl.TextXAlignment  = Enum.TextXAlignment.Left
    titleLbl.ZIndex          = 7
    titleLbl.Parent          = bar

    -- Branding badge
    local brand = Instance.new("TextLabel")
    brand.Size               = UDim2.new(0, 110, 1, 0)
    brand.Position           = UDim2.new(1, -156, 0, 0)
    brand.BackgroundTransparency = 1
    brand.Text               = "gaysploits.xyz"
    brand.TextColor3         = RAINBOW[7]
    brand.TextSize           = 11
    brand.Font               = Enum.Font.GothamBold
    brand.TextXAlignment     = Enum.TextXAlignment.Right
    brand.ZIndex             = 7
    brand.Parent             = bar
    Padding(brand, 0, 4, 0, 0)

    -- ── Control buttons (minimize, close) ──────────────────────────────────
    local function CtrlBtn(xOff, bg, glyph)
        local b = Instance.new("TextButton")
        b.Size            = UDim2.new(0, 28, 0, 28)
        b.Position        = UDim2.new(1, xOff, 0.5, -14)
        b.BackgroundColor3= bg
        b.Text            = glyph
        b.TextColor3      = Color3.fromRGB(255, 255, 255)
        b.TextSize        = 13
        b.Font            = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.ZIndex          = 8
        b.Parent          = bar
        Corner(b, 7)
        return b
    end

    local closeBtn = CtrlBtn(-10,  Color3.fromRGB(255, 65, 65),  "✕")
    local minBtn   = CtrlBtn(-44,  theme.Tertiary,                "–")
    Stroke(minBtn, theme.Border, 1, 0.3)

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 35, 35)}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 65, 65)}, 0.15)
    end)

    -- ── Scroll content area ────────────────────────────────────────────────
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name                  = "Scroll"
    scroll.Size                  = UDim2.new(1, 0, 1, -60)
    scroll.Position              = UDim2.new(0, 0, 0, 60)
    scroll.BackgroundTransparency= 1
    scroll.BorderSizePixel       = 0
    scroll.ScrollBarThickness    = 3
    scroll.ScrollBarImageColor3  = theme.Accent
    scroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    scroll.ScrollingDirection    = Enum.ScrollingDirection.Y
    scroll.ZIndex                = 3
    scroll.Parent                = win
    ListLayout(scroll, 8)
    Padding(scroll, 10, 10, 10, 10)

    -- ── Dragging ───────────────────────────────────────────────────────────
    MakeDraggable(bar, win)

    -- ── Open animation ─────────────────────────────────────────────────────
    local FULL_SIZE = UDim2.new(0, W, 0, H)
    task.defer(function()
        Tween(win, {
            Size     = FULL_SIZE,
            Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
        }, 0.55, Enum.EasingStyle.Back)
    end)

    -- ── Close behavior ─────────────────────────────────────────────────────
    closeBtn.MouseButton1Click:Connect(function()
        Tween(win, {
            Size     = UDim2.new(0, W, 0, 0),
            Position = UDim2.new(0.5, -W/2, 0.5, 0),
            BackgroundTransparency = 1
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.45, function()
            for _, c in ipairs(cleanups) do pcall(function() c:Disconnect() end) end
            root:Destroy()
        end)
    end)

    -- ── Minimize behavior ──────────────────────────────────────────────────
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Tween(win, {
            Size = minimized
                and UDim2.new(0, W, 0, 54)
                or  FULL_SIZE
        }, 0.38, Enum.EasingStyle.Quart)
    end)

    -- ── Animated rainbow border + icon dot + brand label ──────────────────
    local hue = 0
    local heartConn = RunService.Heartbeat:Connect(function(dt)
        hue = (hue + dt * 0.28) % 1
        ringStroke.Color  = RainbowAt(hue)
        iconDot.BackgroundColor3 = RainbowAt(hue)
        brand.TextColor3  = RainbowAt((hue + 0.45) % 1)
    end)
    table.insert(cleanups, heartConn)

    -- ── Window object ──────────────────────────────────────────────────────
    local WindowObj       = {}
    WindowObj._theme      = theme
    WindowObj._scroll     = scroll
    WindowObj._order      = 0
    WindowObj._root       = root

    -- ┌───────────────────────────────────────────────────────────────────┐
    -- │  Window:MakeSection(name)                                         │
    -- └───────────────────────────────────────────────────────────────────┘
    function WindowObj:MakeSection(name)
        local T = self._theme

        local ord = self._order
        self._order += 1

        -- Section card
        local card = Instance.new("Frame")
        card.Name             = "Section_" .. name
        card.Size             = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize    = Enum.AutomaticSize.Y
        card.BackgroundColor3 = T.Secondary
        card.BorderSizePixel  = 0
        card.LayoutOrder      = ord
        card.ClipsDescendants = false
        card.Parent           = self._scroll
        Corner(card, 10)
        Stroke(card, T.Border, 1, 0.5)

        -- Header band
        local header = Instance.new("Frame")
        header.Name             = "Header"
        header.Size             = UDim2.new(1, 0, 0, 36)
        header.BackgroundColor3 = T.Tertiary
        header.BorderSizePixel  = 0
        header.ZIndex           = 4
        header.Parent           = card
        Corner(header, 10)

        -- Square off header bottom
        local hPatch = Instance.new("Frame")
        hPatch.Size             = UDim2.new(1, 0, 0, 10)
        hPatch.Position         = UDim2.new(0, 0, 1, -10)
        hPatch.BackgroundColor3 = T.Tertiary
        hPatch.BorderSizePixel  = 0
        hPatch.ZIndex           = 4
        hPatch.Parent           = header

        -- Accent pill (left edge of header)
        local pill = Instance.new("Frame")
        pill.Name             = "Pill"
        pill.Size             = UDim2.new(0, 3, 0, 18)
        pill.Position         = UDim2.new(0, 10, 0.5, -9)
        pill.BackgroundColor3 = T.Accent
        pill.BorderSizePixel  = 0
        pill.ZIndex           = 5
        pill.Parent           = header
        Corner(pill, 2)

        -- Animate this section's pill with a phase offset so sections differ
        local phase = math.random() * 0.8
        table.insert(cleanups, RunService.Heartbeat:Connect(function(dt)
            hue = hue  -- captured from closure above
            pill.BackgroundColor3 = RainbowAt((hue + phase) % 1)
        end))

        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Size            = UDim2.new(1, -20, 1, 0)
        sectionTitle.Position        = UDim2.new(0, 22, 0, 0)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text            = name
        sectionTitle.TextColor3      = T.Text
        sectionTitle.TextSize        = 13
        sectionTitle.Font            = Enum.Font.GothamSemibold
        sectionTitle.TextXAlignment  = Enum.TextXAlignment.Left
        sectionTitle.ZIndex          = 5
        sectionTitle.Parent          = header

        -- Content area
        local content = Instance.new("Frame")
        content.Name             = "Content"
        content.Size             = UDim2.new(1, 0, 0, 0)
        content.AutomaticSize    = Enum.AutomaticSize.Y
        content.Position         = UDim2.new(0, 0, 0, 36)
        content.BackgroundTransparency = 1
        content.BorderSizePixel  = 0
        content.ZIndex           = 3
        content.Parent           = card
        ListLayout(content, 3)
        Padding(content, 6, 8, 8, 8)

        -- ── Section API ───────────────────────────────────────────────────
        local Section = { _content = content, _theme = T, _order = 0 }

        -- ─── Helper: widget wrapper frame ─────────────────────────────────
        local function WidgetFrame(h, extraProps)
            local f = Instance.new("Frame")
            f.Size             = UDim2.new(1, 0, 0, h)
            f.BackgroundColor3 = T.Elevated
            f.BorderSizePixel  = 0
            f.LayoutOrder      = Section._order
            f.ClipsDescendants = false
            Section._order    += 1
            if extraProps then
                for k, v in pairs(extraProps) do f[k] = v end
            end
            f.Parent = content
            Corner(f, 8)
            Stroke(f, T.Border, 1, 0.55)
            return f
        end

        -- ╔═══════════════╗
        -- ║  MakeLabel    ║
        -- ╚═══════════════╝
        function Section:MakeLabel(text)
            local f = Instance.new("Frame")
            f.Size            = UDim2.new(1, 0, 0, 26)
            f.BackgroundTransparency = 1
            f.LayoutOrder     = self._order
            self._order      += 1
            f.Parent          = content

            local lbl = Instance.new("TextLabel")
            lbl.Size          = UDim2.new(1, -8, 1, 0)
            lbl.Position      = UDim2.new(0, 8, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text          = "  " .. text
            lbl.TextColor3    = T.SubText
            lbl.TextSize      = 12
            lbl.Font          = Enum.Font.Gotham
            lbl.TextXAlignment= Enum.TextXAlignment.Left
            lbl.Parent        = f
        end

        -- ╔════════════════╗
        -- ║  MakeButton    ║
        -- ╚════════════════╝
        function Section:MakeButton(label, callback)
            local f   = WidgetFrame(38)
            f.BackgroundColor3 = T.Tertiary

            local btn = Instance.new("TextButton")
            btn.Size             = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text             = label
            btn.TextColor3       = T.Text
            btn.TextSize         = 13
            btn.Font             = Enum.Font.GothamSemibold
            btn.BorderSizePixel  = 0
            btn.AutoButtonColor  = false
            btn.ZIndex           = f.ZIndex + 1
            btn.Parent           = f

            -- Gradient sheen
            local grad = Instance.new("UIGradient")
            grad.Color    = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(180,180,200)),
            })
            grad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.92),
                NumberSequenceKeypoint.new(1, 1),
            })
            grad.Rotation = 90
            grad.Parent   = f

            Ripple(btn, T)

            btn.MouseEnter:Connect(function()
                Tween(f, {BackgroundColor3 = T.Accent}, 0.2)
                Tween(btn, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
            end)
            btn.MouseLeave:Connect(function()
                Tween(f, {BackgroundColor3 = T.Tertiary}, 0.2)
                Tween(btn, {TextColor3 = T.Text}, 0.2)
            end)
            btn.MouseButton1Down:Connect(function()
                Tween(f, {Size = UDim2.new(0.97, 0, 0, 36)}, 0.08)
            end)
            btn.MouseButton1Up:Connect(function()
                Tween(f, {Size = UDim2.new(1, 0, 0, 38)}, 0.18, Enum.EasingStyle.Back)
                if callback then task.spawn(pcall, callback) end
            end)
        end

        -- ╔════════════════╗
        -- ║  MakeToggle    ║
        -- ╚════════════════╝
        function Section:MakeToggle(label, default, callback)
            local state = default == true
            local f     = WidgetFrame(40)

            local lbl = Instance.new("TextLabel")
            lbl.Size            = UDim2.new(1, -72, 1, 0)
            lbl.Position        = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text            = label
            lbl.TextColor3      = T.Text
            lbl.TextSize        = 13
            lbl.Font            = Enum.Font.Gotham
            lbl.TextXAlignment  = Enum.TextXAlignment.Left
            lbl.ZIndex          = f.ZIndex + 1
            lbl.Parent          = f

            -- Track
            local track = Instance.new("Frame")
            track.Size             = UDim2.new(0, 46, 0, 26)
            track.Position         = UDim2.new(1, -58, 0.5, -13)
            track.BackgroundColor3 = state and T.Accent or T.Border
            track.BorderSizePixel  = 0
            track.ZIndex           = f.ZIndex + 1
            track.Parent           = f
            Corner(track, 13)

            -- Inner shadow on track
            local trackInner = Instance.new("UIGradient")
            trackInner.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
            })
            trackInner.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.85),
                NumberSequenceKeypoint.new(1, 1),
            })
            trackInner.Rotation = 90
            trackInner.Parent   = track

            -- Knob
            local knob = Instance.new("Frame")
            knob.Size             = UDim2.new(0, 20, 0, 20)
            knob.Position         = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel  = 0
            knob.ZIndex           = f.ZIndex + 2
            knob.Parent           = track
            Corner(knob, 10)
            Shadow(knob, 6)

            local function SetState(s, silent)
                state = s
                Tween(track, {BackgroundColor3 = s and T.Accent or T.Border}, 0.22)
                Tween(knob,  {
                    Position = s
                        and UDim2.new(1, -23, 0.5, -10)
                        or  UDim2.new(0, 3,   0.5, -10)
                }, 0.28, Enum.EasingStyle.Back)
                if not silent and callback then task.spawn(pcall, callback, state) end
            end

            local hit = Instance.new("TextButton")
            hit.Size             = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text             = ""
            hit.ZIndex           = f.ZIndex + 3
            hit.Parent           = f
            hit.MouseButton1Click:Connect(function() SetState(not state) end)

            -- Hover tint
            hit.MouseEnter:Connect(function()
                Tween(f, {BackgroundColor3 = T.Tertiary}, 0.15)
            end)
            hit.MouseLeave:Connect(function()
                Tween(f, {BackgroundColor3 = T.Elevated}, 0.15)
            end)

            local ToggleObj = {}
            function ToggleObj:Set(v)   SetState(v, true) end
            function ToggleObj:Get()    return state      end
            return ToggleObj
        end

        -- ╔════════════════╗
        -- ║  MakeSlider    ║
        -- ╚════════════════╝
        function Section:MakeSlider(label, minVal, maxVal, default, callback)
            minVal  = minVal  or 0
            maxVal  = maxVal  or 100
            local value = math.clamp(default or minVal, minVal, maxVal)

            local f = WidgetFrame(58)

            -- Top row: label + value display
            local topRow = Instance.new("Frame")
            topRow.Size             = UDim2.new(1, 0, 0, 28)
            topRow.BackgroundTransparency = 1
            topRow.ZIndex           = f.ZIndex + 1
            topRow.Parent           = f

            local lbl = Instance.new("TextLabel")
            lbl.Size            = UDim2.new(0.65, 0, 1, 0)
            lbl.Position        = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text            = label
            lbl.TextColor3      = T.Text
            lbl.TextSize        = 13
            lbl.Font            = Enum.Font.Gotham
            lbl.TextXAlignment  = Enum.TextXAlignment.Left
            lbl.ZIndex          = f.ZIndex + 1
            lbl.Parent          = topRow

            local valLbl = Instance.new("TextLabel")
            valLbl.Size            = UDim2.new(0.35, -12, 1, 0)
            valLbl.Position        = UDim2.new(0.65, 0, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text            = tostring(math.floor(value))
            valLbl.TextColor3      = T.Accent
            valLbl.TextSize        = 13
            valLbl.Font            = Enum.Font.GothamBold
            valLbl.TextXAlignment  = Enum.TextXAlignment.Right
            valLbl.ZIndex          = f.ZIndex + 1
            valLbl.Parent          = topRow
            Padding(valLbl, 0, 12, 0, 0)

            -- Track background
            local trackBg = Instance.new("Frame")
            trackBg.Size             = UDim2.new(1, -24, 0, 6)
            trackBg.Position         = UDim2.new(0, 12, 0, 38)
            trackBg.BackgroundColor3 = T.Border
            trackBg.BorderSizePixel  = 0
            trackBg.ZIndex           = f.ZIndex + 1
            trackBg.Parent           = f
            Corner(trackBg, 3)

            -- Fill with rainbow gradient
            local rel0  = (value - minVal) / (maxVal - minVal)
            local fill  = Instance.new("Frame")
            fill.Size            = UDim2.new(rel0, 0, 1, 0)
            fill.BackgroundColor3= T.Accent
            fill.BorderSizePixel = 0
            fill.ZIndex          = f.ZIndex + 2
            fill.Parent          = trackBg
            Corner(fill, 3)

            local fillGrad = Instance.new("UIGradient")
            fillGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromRGB(180, 80,  255)),
                ColorSequenceKeypoint.new(0.4,  Color3.fromRGB(80,  180, 255)),
                ColorSequenceKeypoint.new(1,    Color3.fromRGB(80,  220, 120)),
            })
            fillGrad.Parent = fill

            -- Knob
            local knob = Instance.new("Frame")
            knob.Size             = UDim2.new(0, 16, 0, 16)
            knob.Position         = UDim2.new(rel0, -8, 0.5, -8)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel  = 0
            knob.ZIndex           = f.ZIndex + 3
            knob.Parent           = trackBg
            Corner(knob, 8)
            Shadow(knob, 6)

            -- Invisible hit zone for drag
            local hitZone = Instance.new("TextButton")
            hitZone.Size             = UDim2.new(1, 0, 1, 20)
            hitZone.Position         = UDim2.new(0, 0, 0.5, -10)
            hitZone.BackgroundTransparency = 1
            hitZone.Text             = ""
            hitZone.ZIndex           = f.ZIndex + 4
            hitZone.Parent           = trackBg

            local draggingSlider = false

            local function UpdateValue(screenX)
                local abs = trackBg.AbsolutePosition.X
                local sz  = trackBg.AbsoluteSize.X
                local rel = math.clamp((screenX - abs) / sz, 0, 1)
                value = math.floor(minVal + rel * (maxVal - minVal))
                local r = (value - minVal) / (maxVal - minVal)
                fill.Size     = UDim2.new(r, 0, 1, 0)
                knob.Position = UDim2.new(r, -8, 0.5, -8)
                valLbl.Text   = tostring(value)
                if callback then task.spawn(pcall, callback, value) end
            end

            hitZone.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    UpdateValue(inp.Position.X)
                end
            end)

            local uiConn = UserInputService.InputChanged:Connect(function(inp)
                if not draggingSlider then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then
                    UpdateValue(inp.Position.X)
                end
            end)
            local uiEnd = UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)
            table.insert(cleanups, uiConn)
            table.insert(cleanups, uiEnd)

            local SliderObj = {}
            function SliderObj:Set(v)
                value = math.clamp(v, minVal, maxVal)
                local r = (value - minVal) / (maxVal - minVal)
                fill.Size     = UDim2.new(r, 0, 1, 0)
                knob.Position = UDim2.new(r, -8, 0.5, -8)
                valLbl.Text   = tostring(value)
            end
            function SliderObj:Get() return value end
            return SliderObj
        end

        -- ╔════════════════════╗
        -- ║  MakeTextbox       ║
        -- ╚════════════════════╝
        function Section:MakeTextbox(label, placeholder, callback)
            local f = WidgetFrame(58)

            local lbl = Instance.new("TextLabel")
            lbl.Size            = UDim2.new(1, -12, 0, 20)
            lbl.Position        = UDim2.new(0, 12, 0, 5)
            lbl.BackgroundTransparency = 1
            lbl.Text            = label
            lbl.TextColor3      = T.SubText
            lbl.TextSize        = 11
            lbl.Font            = Enum.Font.Gotham
            lbl.TextXAlignment  = Enum.TextXAlignment.Left
            lbl.ZIndex          = f.ZIndex + 1
            lbl.Parent          = f

            local box = Instance.new("TextBox")
            box.Size             = UDim2.new(1, -20, 0, 26)
            box.Position         = UDim2.new(0, 10, 0, 26)
            box.BackgroundColor3 = T.Background
            box.Text             = ""
            box.PlaceholderText  = placeholder or "Enter value..."
            box.PlaceholderColor3= T.SubText
            box.TextColor3       = T.Text
            box.TextSize         = 13
            box.Font             = Enum.Font.Gotham
            box.TextXAlignment   = Enum.TextXAlignment.Left
            box.BorderSizePixel  = 0
            box.ClearTextOnFocus = false
            box.ZIndex           = f.ZIndex + 2
            box.Parent           = f
            Corner(box, 6)
            Padding(box, 0, 0, 0, 8)

            local boxStroke = Stroke(box, T.Border, 1, 0.5)

            box.Focused:Connect(function()
                Tween(boxStroke, {Color = T.Accent, Transparency = 0}, 0.2)
                Tween(f, {BackgroundColor3 = T.Tertiary}, 0.2)
            end)
            box.FocusLost:Connect(function(enter)
                Tween(boxStroke, {Color = T.Border, Transparency = 0.5}, 0.2)
                Tween(f, {BackgroundColor3 = T.Elevated}, 0.2)
                if callback then task.spawn(pcall, callback, box.Text, enter) end
            end)

            local TbObj = {}
            function TbObj:Get()    return box.Text end
            function TbObj:Set(v)   box.Text = v    end
            return TbObj
        end

        -- ╔═══════════════════╗
        -- ║  MakeDropdown     ║
        -- ╚═══════════════════╝
        function Section:MakeDropdown(label, options, callback)
            options = options or {}
            local selected = options[1] or ""
            local isOpen   = false

            local f = WidgetFrame(40)

            local lbl = Instance.new("TextLabel")
            lbl.Size            = UDim2.new(0.55, 0, 1, 0)
            lbl.Position        = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text            = label
            lbl.TextColor3      = T.Text
            lbl.TextSize        = 13
            lbl.Font            = Enum.Font.Gotham
            lbl.TextXAlignment  = Enum.TextXAlignment.Left
            lbl.ZIndex          = f.ZIndex + 1
            lbl.Parent          = f

            local selLbl = Instance.new("TextLabel")
            selLbl.Size          = UDim2.new(0.45, -42, 1, 0)
            selLbl.Position      = UDim2.new(0.55, 0, 0, 0)
            selLbl.BackgroundTransparency = 1
            selLbl.Text          = selected
            selLbl.TextColor3    = T.Accent
            selLbl.TextSize      = 12
            selLbl.Font          = Enum.Font.GothamSemibold
            selLbl.TextXAlignment= Enum.TextXAlignment.Right
            selLbl.ZIndex        = f.ZIndex + 1
            selLbl.Parent        = f

            local arrow = Instance.new("TextLabel")
            arrow.Size           = UDim2.new(0, 32, 1, 0)
            arrow.Position       = UDim2.new(1, -36, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text           = "▾"
            arrow.TextColor3     = T.SubText
            arrow.TextSize       = 15
            arrow.Font           = Enum.Font.Gotham
            arrow.ZIndex         = f.ZIndex + 1
            arrow.Parent         = f

            -- Drop-down list panel (lives outside ClipsDescendants)
            local panel = Instance.new("Frame")
            panel.Name             = "DropPanel"
            panel.Size             = UDim2.new(1, 0, 0, 0)
            panel.Position         = UDim2.new(0, 0, 1, 6)
            panel.BackgroundColor3 = T.Secondary
            panel.BorderSizePixel  = 0
            panel.ClipsDescendants = true
            panel.ZIndex           = 20
            panel.Visible          = false
            panel.Parent           = f
            Corner(panel, 8)
            Stroke(panel, T.Border, 1, 0.3)
            Shadow(panel, 18)

            ListLayout(panel, 0)
            Padding(panel, 4, 4, 4, 4)

            local ITEM_H = 32
            local totalH = #options * ITEM_H + 8

            for i, opt in ipairs(options) do
                local row = Instance.new("TextButton")
                row.Size             = UDim2.new(1, 0, 0, ITEM_H)
                row.BackgroundColor3 = T.Elevated
                row.BackgroundTransparency = opt == selected and 0 or 1
                row.Text             = opt
                row.TextColor3       = opt == selected and T.Accent or T.Text
                row.TextSize         = 13
                row.Font             = Enum.Font.Gotham
                row.BorderSizePixel  = 0
                row.AutoButtonColor  = false
                row.ZIndex           = 21
                row.LayoutOrder      = i
                row.Parent           = panel
                Corner(row, 6)

                row.MouseEnter:Connect(function()
                    if row.Text ~= selected then
                        Tween(row, {BackgroundTransparency = 0, TextColor3 = T.Text}, 0.1)
                    end
                end)
                row.MouseLeave:Connect(function()
                    if row.Text ~= selected then
                        Tween(row, {BackgroundTransparency = 1}, 0.1)
                    end
                end)
                row.MouseButton1Click:Connect(function()
                    -- Reset old selection visuals
                    for _, child in ipairs(panel:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.TextColor3 = T.Text
                            child.BackgroundTransparency = 1
                        end
                    end
                    selected = opt
                    selLbl.Text = opt
                    row.TextColor3 = T.Accent
                    row.BackgroundTransparency = 0

                    -- Close
                    isOpen = false
                    Tween(panel, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Tween(arrow, {Rotation = 0}, 0.2)
                    task.delay(0.21, function() panel.Visible = false end)
                    if callback then task.spawn(pcall, callback, selected) end
                end)
            end

            -- Toggle button over whole widget
            local hit = Instance.new("TextButton")
            hit.Size             = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text             = ""
            hit.ZIndex           = f.ZIndex + 2
            hit.Parent           = f

            hit.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    panel.Visible = true
                    panel.Size    = UDim2.new(1, 0, 0, 0)
                    Tween(panel, {Size = UDim2.new(1, 0, 0, totalH)}, 0.28, Enum.EasingStyle.Back)
                    Tween(arrow, {Rotation = 180}, 0.22)
                else
                    Tween(panel, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Tween(arrow, {Rotation = 0},   0.2)
                    task.delay(0.21, function() panel.Visible = false end)
                end
            end)

            hit.MouseEnter:Connect(function()
                Tween(f, {BackgroundColor3 = T.Tertiary}, 0.15)
            end)
            hit.MouseLeave:Connect(function()
                Tween(f, {BackgroundColor3 = T.Elevated}, 0.15)
            end)

            local DdObj = {}
            function DdObj:Get()  return selected end
            function DdObj:Set(v)
                selected  = v
                selLbl.Text = v
            end
            return DdObj
        end

        return Section
    end  -- MakeSection

    return WindowObj
end  -- MakeWindow

return Library
