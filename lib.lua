--[[
    ░██████╗░░█████╗░██╗░░░██╗░██████╗██████╗░██╗░░░░░░█████╗░██╗████████╗░██████╗
    ██╔════╝░██╔══██╗╚██╗░██╔╝██╔════╝██╔══██╗██║░░░░░██╔══██╗██║╚══██╔══╝██╔════╝
    ██║░░██╗░███████║░╚████╔╝░╚█████╗░██████╔╝██║░░░░░██║░░██║██║░░░██║░░░╚█████╗░
    ██║░░╚██╗██╔══██║░░╚██╔╝░░░╚═══██╗██╔═══╝░██║░░░░░██║░░██║██║░░░██║░░░░╚═══██╗
    ╚██████╔╝██║░░██║░░░██║░░░██████╔╝██║░░░░░███████╗╚█████╔╝██║░░░██║░░░██████╔╝
    ░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═════╝░╚═╝░░░░░╚══════╝░╚════╝░╚═╝░░░╚═╝░░░╚═════╝░

    GaySploits UI Library v1.0.0
    Author  : You (MIT Licensed)
    Target  : Roblox LocalScript / CoreGui
    Load    : loadstring(game:HttpGet("https://raw.githubusercontent.com/.../main/lib.lua"))()

    MIT License — do whatever you want, keep the header.
--]]

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
--  THEME TABLE
-- ══════════════════════════════════════════════════════════════
local Themes = {
    Dark = {
        -- Window chrome
        Background      = Color3.fromRGB(13,  13,  18),   -- near-black
        TitleBar        = Color3.fromRGB(20,  20,  28),
        TitleText       = Color3.fromRGB(230, 200, 255),  -- soft lavender
        Border          = Color3.fromRGB(80,  50, 130),

        -- Sections
        SectionBg       = Color3.fromRGB(18,  18,  26),
        SectionTitle    = Color3.fromRGB(160, 120, 220),
        SectionLine     = Color3.fromRGB(60,  40, 100),

        -- Generic element background
        ElementBg       = Color3.fromRGB(25,  25,  36),
        ElementHover    = Color3.fromRGB(35,  30,  55),
        ElementBorder   = Color3.fromRGB(70,  50, 120),

        -- Text
        PrimaryText     = Color3.fromRGB(230, 230, 245),
        SecondaryText   = Color3.fromRGB(140, 130, 165),
        AccentText      = Color3.fromRGB(185, 130, 255),

        -- Accent / highlight
        Accent          = Color3.fromRGB(140,  80, 255),
        AccentDim       = Color3.fromRGB( 90,  45, 180),
        AccentGlow      = Color3.fromRGB(160, 100, 255),

        -- Toggle
        ToggleOn        = Color3.fromRGB(140,  80, 255),
        ToggleOff       = Color3.fromRGB( 50,  45,  70),
        ToggleKnob      = Color3.fromRGB(230, 220, 255),

        -- Slider track
        SliderFill      = Color3.fromRGB(140,  80, 255),
        SliderTrack     = Color3.fromRGB( 40,  35,  60),
        SliderKnob      = Color3.fromRGB(200, 170, 255),

        -- Input / dropdown
        InputBg         = Color3.fromRGB(20,  18,  32),
        InputBorder     = Color3.fromRGB( 90,  60, 160),
        InputText       = Color3.fromRGB(210, 200, 240),
        PlaceholderText = Color3.fromRGB( 90,  80, 120),

        -- Button
        ButtonBg        = Color3.fromRGB( 75,  40, 155),
        ButtonHover     = Color3.fromRGB(110,  65, 200),
        ButtonText      = Color3.fromRGB(240, 230, 255),

        -- Scrollbar
        ScrollBar       = Color3.fromRGB( 80,  50, 140),

        -- Close / minimise buttons
        CloseBtn        = Color3.fromRGB(200,  70,  90),
        MinBtn          = Color3.fromRGB(200, 160,  50),

        -- Notification
        NotifBg         = Color3.fromRGB(20,  18,  30),
        NotifAccent     = Color3.fromRGB(140,  80, 255),
    },
    Light = {
        Background      = Color3.fromRGB(242, 240, 255),
        TitleBar        = Color3.fromRGB(225, 218, 255),
        TitleText       = Color3.fromRGB( 60,  30, 120),
        Border          = Color3.fromRGB(160, 120, 230),

        SectionBg       = Color3.fromRGB(235, 230, 252),
        SectionTitle    = Color3.fromRGB( 90,  50, 180),
        SectionLine     = Color3.fromRGB(190, 170, 230),

        ElementBg       = Color3.fromRGB(248, 245, 255),
        ElementHover    = Color3.fromRGB(235, 225, 255),
        ElementBorder   = Color3.fromRGB(180, 150, 230),

        PrimaryText     = Color3.fromRGB( 30,  20,  60),
        SecondaryText   = Color3.fromRGB(110,  90, 160),
        AccentText      = Color3.fromRGB( 90,  50, 200),

        Accent          = Color3.fromRGB(110,  60, 220),
        AccentDim       = Color3.fromRGB(150, 110, 240),
        AccentGlow      = Color3.fromRGB(130,  80, 240),

        ToggleOn        = Color3.fromRGB(110,  60, 220),
        ToggleOff       = Color3.fromRGB(190, 180, 220),
        ToggleKnob      = Color3.fromRGB(255, 255, 255),

        SliderFill      = Color3.fromRGB(110,  60, 220),
        SliderTrack     = Color3.fromRGB(200, 190, 230),
        SliderKnob      = Color3.fromRGB( 80,  40, 190),

        InputBg         = Color3.fromRGB(252, 250, 255),
        InputBorder     = Color3.fromRGB(160, 130, 220),
        InputText       = Color3.fromRGB( 30,  20,  60),
        PlaceholderText = Color3.fromRGB(160, 150, 190),

        ButtonBg        = Color3.fromRGB(120,  70, 230),
        ButtonHover     = Color3.fromRGB( 90,  45, 200),
        ButtonText      = Color3.fromRGB(255, 255, 255),

        ScrollBar       = Color3.fromRGB(160, 130, 220),

        CloseBtn        = Color3.fromRGB(210,  70,  85),
        MinBtn          = Color3.fromRGB(210, 165,  45),

        NotifBg         = Color3.fromRGB(240, 235, 255),
        NotifAccent     = Color3.fromRGB(110,  60, 220),
    },
}

-- ══════════════════════════════════════════════════════════════
--  UTILITY HELPERS
-- ══════════════════════════════════════════════════════════════
local function Tween(obj, goals, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.25, style, direction)
    local t    = TweenService:Create(obj, info, goals)
    t:Play()
    return t
end

local function MakeInstance(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

-- Corner + stroke combo used everywhere
local function ApplyCornerStroke(parent, radius, color, thickness)
    MakeInstance("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
    local stroke = MakeInstance("UIStroke", {
        Color     = color     or Color3.fromRGB(80, 50, 130),
        Thickness = thickness or 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
    return stroke
end

-- Shimmer gradient overlay (purely cosmetic, runs once)
local function AddShimmer(parent, theme)
    local frame = MakeInstance("Frame", {
        Size            = UDim2.new(1, 0, 0, 2),
        Position        = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Accent,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex          = parent.ZIndex + 1,
    }, parent)
    MakeInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.5, theme.Accent),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,255,255)),
        }),
        Rotation = 90,
    }, frame)
    return frame
end

-- Ripple effect on click
local function Ripple(parent, theme)
    local rip = MakeInstance("Frame", {
        Size             = UDim2.new(0, 0, 0, 0),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.AccentGlow,
        BackgroundTransparency = 0.6,
        BorderSizePixel  = 0,
        ZIndex           = parent.ZIndex + 5,
        ClipsDescendants = false,
    }, parent)
    MakeInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, rip)
    Tween(rip, { Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1 }, 0.5,
        Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    task.delay(0.5, function() rip:Destroy() end)
end

-- ══════════════════════════════════════════════════════════════
--  DRAG LOGIC (works on both PC and mobile)
-- ══════════════════════════════════════════════════════════════
local function MakeDraggable(handle, frame)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  RESIZE LOGIC
-- ══════════════════════════════════════════════════════════════
local function MakeResizable(frame, minW, minH)
    minW = minW or 280
    minH = minH or 200

    -- bottom-right corner grip
    local grip = MakeInstance("Frame", {
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = UDim2.new(1, -14, 1, -14),
        BackgroundColor3 = Color3.fromRGB(120, 80, 200),
        BackgroundTransparency = 0.5,
        BorderSizePixel  = 0,
        ZIndex           = frame.ZIndex + 10,
    }, frame)
    MakeInstance("UICorner", { CornerRadius = UDim.new(0, 3) }, grip)

    -- draw two tiny diagonal lines inside grip for visual cue
    for i = 1, 2 do
        MakeInstance("Frame", {
            Size             = UDim2.new(0, 8 - i*2, 0, 1),
            Position         = UDim2.new(0, i*2, 0, 4 + i*3),
            BackgroundColor3 = Color3.fromRGB(200, 170, 255),
            BackgroundTransparency = 0.2,
            BorderSizePixel  = 0,
            Rotation         = -45,
            ZIndex           = grip.ZIndex + 1,
        }, grip)
    end

    local resizing, resizeStart, startSize = false, nil, nil

    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing    = true
            resizeStart = input.Position
            startSize   = Vector2.new(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - resizeStart
            local newW  = math.max(minW, startSize.X + delta.X)
            local newH  = math.max(minH, startSize.Y + delta.Y)
            frame.Size  = UDim2.new(0, newW, 0, newH)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  ROOT SCREENGU
-- ══════════════════════════════════════════════════════════════
-- Safely parent to CoreGui (works in exploits; falls back to PlayerGui)
local ScreenGui
pcall(function()
    ScreenGui = MakeInstance("ScreenGui", {
        Name            = "GaySploitsUI",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
    }, CoreGui)
end)
if not ScreenGui then
    ScreenGui = MakeInstance("ScreenGui", {
        Name           = "GaySploitsUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 999,
    }, LocalPlayer:WaitForChild("PlayerGui"))
end

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM  (standalone, appears top-right)
-- ══════════════════════════════════════════════════════════════
local NotifHolder = MakeInstance("Frame", {
    Name            = "NotifHolder",
    Size            = UDim2.new(0, 280, 1, 0),
    Position        = UDim2.new(1, -295, 0, 10),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex          = 9999,
}, ScreenGui)
MakeInstance("UIListLayout", {
    SortOrder        = Enum.SortOrder.LayoutOrder,
    VerticalAlignment= Enum.VerticalAlignment.Top,
    Padding          = UDim.new(0, 8),
    FillDirection    = Enum.FillDirection.Vertical,
}, NotifHolder)

local function Notify(opts)
    opts = opts or {}
    local theme = Themes[opts.Theme or "Dark"]

    local card = MakeInstance("Frame", {
        Name             = "Notif",
        Size             = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = theme.NotifBg,
        BackgroundTransparency = 0.08,
        BorderSizePixel  = 0,
        ZIndex           = 9999,
        ClipsDescendants = true,
    }, NotifHolder)
    ApplyCornerStroke(card, 10, theme.NotifAccent, 1.5)

    -- left accent bar
    MakeInstance("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = theme.NotifAccent,
        BorderSizePixel  = 0,
        ZIndex           = card.ZIndex + 1,
    }, card)

    MakeInstance("TextLabel", {
        Text             = opts.Title or "GaySploits",
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextColor3       = theme.AccentText,
        Size             = UDim2.new(1, -16, 0, 20),
        Position         = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = card.ZIndex + 1,
    }, card)

    MakeInstance("TextLabel", {
        Text             = opts.Content or "",
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextColor3       = theme.SecondaryText,
        Size             = UDim2.new(1, -16, 0, 32),
        Position         = UDim2.new(0, 12, 0, 30),
        BackgroundTransparency = 1,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = card.ZIndex + 1,
    }, card)

    -- slide-in
    card.Position = UDim2.new(1.1, 0, 0, 0)
    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back)

    task.delay(opts.Duration or 4, function()
        Tween(card, { Position = UDim2.new(1.1, 0, 0, 0) }, 0.3, Enum.EasingStyle.Quad)
        task.delay(0.31, function() card:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════════════════════
--  LIBRARY TABLE
-- ══════════════════════════════════════════════════════════════
local Library = {}
Library.__index = Library

-- ── MakeWindow ────────────────────────────────────────────────
function Library:MakeWindow(opts)
    opts = opts or {}
    local theme = Themes[opts.Theme or "Dark"]
    local title = opts.Title or "GaySploits"

    -- ── outer container (centers on screen) ──────────────────
    local Container = MakeInstance("Frame", {
        Name             = "GS_Window_" .. title,
        Size             = UDim2.new(0, 480, 0, 540),
        Position         = UDim2.new(0.5, -240, 0.5, -270),
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 0.04,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        ZIndex           = 100,
    }, ScreenGui)
    ApplyCornerStroke(Container, 12, theme.Border, 1.8)
    MakeResizable(Container, 360, 300)

    -- subtle drop shadow
    local Shadow = MakeInstance("Frame", {
        Name             = "Shadow",
        Size             = UDim2.new(1, 28, 1, 28),
        Position         = UDim2.new(0, -14, 0, -10),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel  = 0,
        ZIndex           = Container.ZIndex - 1,
    }, Container)
    MakeInstance("UICorner", { CornerRadius = UDim.new(0, 18) }, Shadow)

    -- ── title bar ─────────────────────────────────────────────
    local TitleBar = MakeInstance("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = theme.TitleBar,
        BorderSizePixel  = 0,
        ZIndex           = Container.ZIndex + 1,
    }, Container)
    MakeInstance("UICorner", { CornerRadius = UDim.new(0, 12) }, TitleBar)
    -- square off the bottom corners of the title bar
    MakeInstance("Frame", {
        Size             = UDim2.new(1, 0, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.TitleBar,
        BorderSizePixel  = 0,
        ZIndex           = TitleBar.ZIndex,
    }, TitleBar)

    AddShimmer(TitleBar, theme)

    -- logo placeholder (replace ImageId with your own asset)
    local LogoImg = MakeInstance("ImageLabel", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(0, 10, 0.5, -14),
        BackgroundTransparency = 1,
        Image            = opts.LogoId or "rbxassetid://0",  -- <── drop your asset ID here
        ZIndex           = TitleBar.ZIndex + 2,
    }, TitleBar)
    MakeInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, LogoImg)

    local TitleLabel = MakeInstance("TextLabel", {
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 15,
        TextColor3       = theme.TitleText,
        Size             = UDim2.new(1, -120, 1, 0),
        Position         = UDim2.new(0, 46, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = TitleBar.ZIndex + 2,
    }, TitleBar)

    -- ── window chrome buttons ─────────────────────────────────
    local function ChromeBtn(color, xOffset, icon)
        local btn = MakeInstance("Frame", {
            Size             = UDim2.new(0, 13, 0, 13),
            Position         = UDim2.new(1, xOffset, 0.5, -6),
            BackgroundColor3 = color,
            BorderSizePixel  = 0,
            ZIndex           = TitleBar.ZIndex + 3,
        }, TitleBar)
        MakeInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, btn)
        MakeInstance("TextLabel", {
            Text             = icon,
            Font             = Enum.Font.GothamBold,
            TextSize         = 9,
            TextColor3       = Color3.fromRGB(0, 0, 0),
            TextTransparency = 0.4,
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex           = btn.ZIndex + 1,
        }, btn)
        return btn
    end

    local CloseBtn = ChromeBtn(theme.CloseBtn, -18, "×")
    local MinBtn   = ChromeBtn(theme.MinBtn,   -36, "–")

    MakeDraggable(TitleBar, Container)

    -- ── content area ──────────────────────────────────────────
    local ContentOuter = MakeInstance("Frame", {
        Name             = "ContentOuter",
        Size             = UDim2.new(1, -8, 1, -52),
        Position         = UDim2.new(0, 4, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = Container.ZIndex + 1,
    }, Container)

    local ScrollFrame = MakeInstance("ScrollingFrame", {
        Name             = "Scroll",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness  = 4,
        ScrollBarImageColor3= theme.ScrollBar,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex           = ContentOuter.ZIndex,
    }, ContentOuter)

    local ListLayout = MakeInstance("UIListLayout", {
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Padding          = UDim.new(0, 6),
    }, ScrollFrame)

    MakeInstance("UIPadding", {
        PaddingLeft   = UDim.new(0, 6),
        PaddingRight  = UDim.new(0, 6),
        PaddingTop    = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 8),
    }, ScrollFrame)

    -- ── open / close animation ────────────────────────────────
    Container.Size = UDim2.new(0, 480, 0, 0)
    Container.BackgroundTransparency = 1
    Tween(Container, {
        Size = UDim2.new(0, 480, 0, 540),
        BackgroundTransparency = 0.04,
    }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local visible = true
    MinBtn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if visible then
            Tween(Container, { Size = UDim2.new(0, 480, 0, 44) }, 0.3, Enum.EasingStyle.Quart)
            ContentOuter.Visible = false
        else
            ContentOuter.Visible = true
            Tween(Container, { Size = UDim2.new(0, 480, 0, 540) }, 0.35, Enum.EasingStyle.Back)
        end
        visible = not visible
    end)

    CloseBtn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        Tween(Container, { Size = UDim2.new(0, 480, 0, 0), BackgroundTransparency = 1 }, 0.3,
            Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.31, function() Container:Destroy() end)
    end)

    -- ════════════════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ════════════════════════════════════════════════════════
    local Window = {}
    Window.__index = Window

    -- ── MakeSection ──────────────────────────────────────────
    function Window:MakeSection(sectionTitle)
        local SectionFrame = MakeInstance("Frame", {
            Name             = "Section_" .. sectionTitle,
            Size             = UDim2.new(1, 0, 0, 36),  -- grows with AutoSize
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.SectionBg,
            BackgroundTransparency = 0.05,
            BorderSizePixel  = 0,
            ZIndex           = ScrollFrame.ZIndex + 1,
        }, ScrollFrame)
        ApplyCornerStroke(SectionFrame, 9, theme.SectionLine, 1.2)

        -- header row
        local Header = MakeInstance("Frame", {
            Size             = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = SectionFrame.ZIndex + 1,
        }, SectionFrame)

        MakeInstance("TextLabel", {
            Text             = sectionTitle,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 12,
            TextColor3       = theme.SectionTitle,
            Size             = UDim2.new(1, -12, 1, 0),
            Position         = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = Header.ZIndex + 1,
        }, Header)

        -- thin accent line below header
        local Divider = MakeInstance("Frame", {
            Size             = UDim2.new(1, -16, 0, 1),
            Position         = UDim2.new(0, 8, 0, 32),
            BackgroundColor3 = theme.SectionLine,
            BackgroundTransparency = 0.3,
            BorderSizePixel  = 0,
            ZIndex           = SectionFrame.ZIndex + 1,
        }, SectionFrame)

        -- element container (auto-grows)
        local ElemList = MakeInstance("Frame", {
            Name          = "Elements",
            Size          = UDim2.new(1, 0, 0, 0),
            Position      = UDim2.new(0, 0, 0, 36),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex        = SectionFrame.ZIndex + 1,
        }, SectionFrame)
        MakeInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 4),
        }, ElemList)
        MakeInstance("UIPadding", {
            PaddingLeft   = UDim.new(0, 8),
            PaddingRight  = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
        }, ElemList)

        -- ── helper: create a base element row ─────────────────
        local function BaseRow(h)
            h = h or 34
            local row = MakeInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, h),
                BackgroundColor3 = theme.ElementBg,
                BackgroundTransparency = 0.1,
                BorderSizePixel  = 0,
                ZIndex           = ElemList.ZIndex + 1,
            }, ElemList)
            ApplyCornerStroke(row, 7, theme.ElementBorder, 1)

            -- hover tween
            row.MouseEnter:Connect(function()
                Tween(row, { BackgroundColor3 = theme.ElementHover }, 0.18)
            end)
            row.MouseLeave:Connect(function()
                Tween(row, { BackgroundColor3 = theme.ElementBg }, 0.18)
            end)
            return row
        end

        local function RowLabel(parent, text, xOff, w)
            return MakeInstance("TextLabel", {
                Text             = text,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = theme.PrimaryText,
                Size             = UDim2.new(0, w or 160, 1, 0),
                Position         = UDim2.new(0, xOff or 10, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = parent.ZIndex + 1,
            }, parent)
        end

        -- ════════════════════════════════════════════════════
        --  SECTION OBJECT
        -- ════════════════════════════════════════════════════
        local Section = {}
        Section.__index = Section

        -- ── MakeButton ────────────────────────────────────────
        function Section:MakeButton(label, callback)
            local row = MakeInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = theme.ButtonBg,
                BackgroundTransparency = 0.08,
                BorderSizePixel  = 0,
                ZIndex           = ElemList.ZIndex + 1,
                ClipsDescendants = true,
            }, ElemList)
            ApplyCornerStroke(row, 7, theme.Accent, 1.2)

            MakeInstance("TextLabel", {
                Text             = label,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 12,
                TextColor3       = theme.ButtonText,
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex           = row.ZIndex + 1,
            }, row)

            local btn = MakeInstance("TextButton", {
                Text             = "",
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex           = row.ZIndex + 2,
            }, row)

            btn.MouseEnter:Connect(function()
                Tween(row, { BackgroundColor3 = theme.ButtonHover }, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(row, { BackgroundColor3 = theme.ButtonBg }, 0.15)
            end)
            btn.MouseButton1Click:Connect(function()
                Ripple(row, theme)
                pcall(callback)
            end)
            return Section
        end

        -- ── MakeToggle ────────────────────────────────────────
        function Section:MakeToggle(label, default, callback)
            local state = default or false
            local row   = BaseRow(34)

            RowLabel(row, label)

            -- track
            local Track = MakeInstance("Frame", {
                Size             = UDim2.new(0, 42, 0, 22),
                Position         = UDim2.new(1, -52, 0.5, -11),
                BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff,
                BorderSizePixel  = 0,
                ZIndex           = row.ZIndex + 1,
            }, row)
            MakeInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, Track)

            -- knob
            local Knob = MakeInstance("Frame", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = theme.ToggleKnob,
                BorderSizePixel  = 0,
                ZIndex           = Track.ZIndex + 1,
            }, Track)
            MakeInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, Knob)

            local Btn = MakeInstance("TextButton", {
                Text             = "",
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex           = row.ZIndex + 5,
            }, row)

            Btn.MouseButton1Click:Connect(function()
                state = not state
                Tween(Track, { BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff }, 0.2)
                Tween(Knob,  { Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }, 0.2)
                pcall(callback, state)
            end)
            return Section
        end

        -- ── MakeSlider ────────────────────────────────────────
        function Section:MakeSlider(label, min, max, default, callback)
            min     = min     or 0
            max     = max     or 100
            default = default or min

            local row = BaseRow(52)
            row.Size  = UDim2.new(1, 0, 0, 52)

            -- top row: label + value badge
            local topRow = MakeInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                ZIndex           = row.ZIndex + 1,
            }, row)
            RowLabel(topRow, label)

            local ValBadge = MakeInstance("Frame", {
                Size             = UDim2.new(0, 44, 0, 18),
                Position         = UDim2.new(1, -52, 0.5, -9),
                BackgroundColor3 = theme.Accent,
                BackgroundTransparency = 0.5,
                BorderSizePixel  = 0,
                ZIndex           = topRow.ZIndex + 1,
            }, topRow)
            MakeInstance("UICorner", { CornerRadius = UDim.new(0, 5) }, ValBadge)

            local ValLabel = MakeInstance("TextLabel", {
                Text             = tostring(default),
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = theme.AccentText,
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex           = ValBadge.ZIndex + 1,
            }, ValBadge)

            -- track bar
            local TrackBg = MakeInstance("Frame", {
                Size             = UDim2.new(1, -20, 0, 6),
                Position         = UDim2.new(0, 10, 0, 34),
                BackgroundColor3 = theme.SliderTrack,
                BorderSizePixel  = 0,
                ZIndex           = row.ZIndex + 1,
            }, row)
            MakeInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, TrackBg)

            local fillPct = (default - min) / (max - min)
            local Fill = MakeInstance("Frame", {
                Size             = UDim2.new(fillPct, 0, 1, 0),
                BackgroundColor3 = theme.SliderFill,
                BorderSizePixel  = 0,
                ZIndex           = TrackBg.ZIndex + 1,
            }, TrackBg)
            MakeInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, Fill)

            -- draggable knob
            local Knob = MakeInstance("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = UDim2.new(fillPct, -7, 0.5, -7),
                BackgroundColor3 = theme.SliderKnob,
                BorderSizePixel  = 0,
                ZIndex           = Fill.ZIndex + 2,
            }, TrackBg)
            MakeInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, Knob)
            ApplyCornerStroke(Knob, 99, theme.Accent, 1.5)

            local sliding = false
            local function UpdateSlider(inputX)
                local absPos  = TrackBg.AbsolutePosition.X
                local absSize = TrackBg.AbsoluteSize.X
                local pct     = math.clamp((inputX - absPos) / absSize, 0, 1)
                local value   = math.floor(min + (max - min) * pct)

                Tween(Fill,  { Size = UDim2.new(pct, 0, 1, 0) }, 0.06)
                Tween(Knob,  { Position = UDim2.new(pct, -7, 0.5, -7) }, 0.06)
                ValLabel.Text = tostring(value)
                pcall(callback, value)
            end

            TrackBg.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    UpdateSlider(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (
                    i.UserInputType == Enum.UserInputType.MouseMovement or
                    i.UserInputType == Enum.UserInputType.Touch
                ) then
                    UpdateSlider(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            return Section
        end

        -- ── MakeTextbox ───────────────────────────────────────
        function Section:MakeTextbox(label, placeholder, callback)
            local row = BaseRow(36)

            RowLabel(row, label, 10, 120)

            local InputFrame = MakeInstance("Frame", {
                Size             = UDim2.new(0, 170, 0, 24),
                Position         = UDim2.new(1, -178, 0.5, -12),
                BackgroundColor3 = theme.InputBg,
                BackgroundTransparency = 0.1,
                BorderSizePixel  = 0,
                ZIndex           = row.ZIndex + 1,
            }, row)
            ApplyCornerStroke(InputFrame, 6, theme.InputBorder, 1)

            local Box = MakeInstance("TextBox", {
                Text             = "",
                PlaceholderText  = placeholder or "Enter value...",
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextColor3       = theme.InputText,
                PlaceholderColor3= theme.PlaceholderText,
                Size             = UDim2.new(1, -10, 1, 0),
                Position         = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                ClearTextOnFocus = false,
                ZIndex           = InputFrame.ZIndex + 1,
                TextXAlignment   = Enum.TextXAlignment.Left,
            }, InputFrame)

            Box.Focused:Connect(function()
                Tween(InputFrame, { BackgroundColor3 = theme.ElementHover }, 0.15)
            end)
            Box.FocusLost:Connect(function(enter)
                Tween(InputFrame, { BackgroundColor3 = theme.InputBg }, 0.15)
                if enter then pcall(callback, Box.Text) end
            end)
            return Section
        end

        -- ── MakeDropdown ──────────────────────────────────────
        function Section:MakeDropdown(label, options, callback)
            options = options or {}
            local selected = options[1] or "Select..."
            local open     = false

            -- outer wrapper grows when open
            local Wrapper = MakeInstance("Frame", {
                Size          = UDim2.new(1, 0, 0, 34),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex        = ElemList.ZIndex + 1,
                ClipsDescendants = false,
            }, ElemList)
            MakeInstance("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, Wrapper)

            local HeaderRow = MakeInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = theme.ElementBg,
                BackgroundTransparency = 0.1,
                BorderSizePixel  = 0,
                ZIndex           = Wrapper.ZIndex + 1,
                ClipsDescendants = true,
            }, Wrapper)
            ApplyCornerStroke(HeaderRow, 7, theme.ElementBorder, 1)

            RowLabel(HeaderRow, label, 10, 130)

            local SelLabel = MakeInstance("TextLabel", {
                Text             = selected,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 11,
                TextColor3       = theme.AccentText,
                Size             = UDim2.new(0, 110, 1, 0),
                Position         = UDim2.new(1, -124, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment   = Enum.TextXAlignment.Right,
                ZIndex           = HeaderRow.ZIndex + 1,
            }, HeaderRow)

            -- chevron
            local Chevron = MakeInstance("TextLabel", {
                Text             = "▾",
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextColor3       = theme.Accent,
                Size             = UDim2.new(0, 18, 1, 0),
                Position         = UDim2.new(1, -18, 0, 0),
                BackgroundTransparency = 1,
                ZIndex           = HeaderRow.ZIndex + 1,
            }, HeaderRow)

            -- dropdown list (hidden until open)
            local ListFrame = MakeInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = theme.InputBg,
                BackgroundTransparency = 0.05,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                ZIndex           = Wrapper.ZIndex + 2,
                Visible          = false,
            }, Wrapper)
            ApplyCornerStroke(ListFrame, 7, theme.Accent, 1.2)

            local ListLayout = MakeInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 2),
            }, ListFrame)
            MakeInstance("UIPadding", {
                PaddingTop    = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft   = UDim.new(0, 4),
                PaddingRight  = UDim.new(0, 4),
            }, ListFrame)

            for _, opt in ipairs(options) do
                local optBtn = MakeInstance("TextButton", {
                    Text             = opt,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    TextColor3       = opt == selected and theme.AccentText or theme.PrimaryText,
                    Size             = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = opt == selected and theme.Accent or theme.ElementBg,
                    BackgroundTransparency = opt == selected and 0.5 or 0.3,
                    BorderSizePixel  = 0,
                    ZIndex           = ListFrame.ZIndex + 1,
                }, ListFrame)
                MakeInstance("UICorner", { CornerRadius = UDim.new(0, 5) }, optBtn)

                optBtn.MouseButton1Click:Connect(function()
                    selected       = opt
                    SelLabel.Text  = opt
                    open           = false
                    Tween(ListFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.22, Enum.EasingStyle.Quart)
                    Tween(Chevron, { Rotation = 0 }, 0.2)
                    task.delay(0.23, function() ListFrame.Visible = false end)
                    pcall(callback, opt)
                end)
            end

            -- compute full height
            local fullH = #options * 30 + 8
            local toggleBtn = MakeInstance("TextButton", {
                Text = "", Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex = HeaderRow.ZIndex + 5,
            }, HeaderRow)

            toggleBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    ListFrame.Visible = true
                    ListFrame.Size    = UDim2.new(1, 0, 0, 0)
                    Tween(ListFrame, { Size = UDim2.new(1, 0, 0, fullH) }, 0.25, Enum.EasingStyle.Back)
                    Tween(Chevron, { Rotation = 180 }, 0.2)
                else
                    Tween(ListFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart)
                    Tween(Chevron, { Rotation = 0 }, 0.2)
                    task.delay(0.21, function() ListFrame.Visible = false end)
                end
            end)
            return Section
        end

        -- ── MakeLabel ─────────────────────────────────────────
        function Section:MakeLabel(text)
            local row = MakeInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                ZIndex           = ElemList.ZIndex + 1,
            }, ElemList)
            MakeInstance("TextLabel", {
                Text             = "  " .. text,
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextColor3       = theme.SecondaryText,
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = row.ZIndex + 1,
                TextWrapped      = true,
            }, row)
            return Section
        end

        return Section
    end -- MakeSection

    -- ── Notify shortcut on window ─────────────────────────────
    function Window:Notify(opts)
        opts       = opts or {}
        opts.Theme = opts.Theme or (opts.Theme or "Dark")
        Notify(opts)
    end

    return Window
end -- MakeWindow

-- ── top-level Notify on library ────────────────────────────────
function Library:Notify(opts)
    Notify(opts)
end

return Library
