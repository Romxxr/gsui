--[[
    gaysploits Ultra Premium v3 (CS:GO / Maxhub Style Layout)
    
    Features:
    - 1:1 Clean Multi-Section Sidebar (Main, Aim, Visuals, Settings)
    - High-End Grid Box Sub-sections (Groupboxes) for clean feature separation
    - True Lighting Acrylic Glass Blur Backend
    - Smooth 0.18s Quad Slide/Fade Animations
    - No ugly close button -> Handled purely via RightShift
    
    Controls:
    - [RightShift] Toggle Show/Hide
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local UI = {}
local currentWindow = nil

local COLORS = {
    Background = Color3.fromRGB(20, 16, 20),
    SidebarBg = Color3.fromRGB(28, 22, 28),
    CardBg = Color3.fromRGB(34, 26, 34),
    ActivePink = Color3.fromRGB(235, 95, 180),
    TextMain = Color3.fromRGB(245, 240, 245),
    TextDim = Color3.fromRGB(155, 145, 155),
    InteractBg = Color3.fromRGB(44, 34, 44),
    Border = Color3.fromRGB(50, 40, 50)
}

local function makeDraggable(topBar, mainFrame)
    local dragging, dragInput, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(mainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

function UI:Unload()
    if CoreGui:FindFirstChild("gaysploits_Premium_V3") then
        CoreGui:FindFirstChild("gaysploits_Premium_V3"):Destroy()
    end
    if Lighting:FindFirstChild("gaysploits_Blur_V3") then
        Lighting:FindFirstChild("gaysploits_Blur_V3"):Destroy()
    end
    currentWindow = nil
end

function UI:MakeWindow(config)
    config = config or {}
    local titleText = config.Title or "Maxhub"
    
    if CoreGui:FindFirstChild("gaysploits_Premium_V3") then CoreGui:FindFirstChild("gaysploits_Premium_V3"):Destroy() end
    if Lighting:FindFirstChild("gaysploits_Blur_V3") then Lighting:FindFirstChild("gaysploits_Blur_V3"):Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "gaysploits_Premium_V3"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Name = "gaysploits_Blur_V3"
    BlurEffect.Size = 16
    BlurEffect.Parent = Lighting

    -- Accurate Premium Size (710x460)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 710, 0, 460)
    MainFrame.Position = UDim2.new(0.5, -355, 0.5, -230)
    MainFrame.BackgroundColor3 = COLORS.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    -- Outer Sleek Border
    local Outline = Instance.new("UIStroke")
    Outline.Color = COLORS.Border
    Outline.Thickness = 1.2
    Outline.Parent = MainFrame

    -- Left Sidebar Panel
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = COLORS.SidebarBg
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SBCorner = Instance.new("UICorner")
    SBCorner.CornerRadius = UDim.new(0, 8)
    SBCorner.Parent = Sidebar

    local SBBoxFix = Instance.new("Frame")
    SBBoxFix.Size = UDim2.new(0, 15, 1, 0)
    SBBoxFix.Position = UDim2.new(1, -15, 0, 0)
    SBBoxFix.BackgroundColor3 = COLORS.SidebarBg
    SBBoxFix.BorderSizePixel = 0
    SBBoxFix.Parent = Sidebar

    -- Hub Brand Label
    local BrandLabel = Instance.new("TextLabel")
    BrandLabel.Size = UDim2.new(1, 0, 0, 50)
    BrandLabel.Position = UDim2.new(0, 20, 0, 10)
    BrandLabel.Text = titleText
    BrandLabel.TextColor3 = COLORS.TextMain
    BrandLabel.Font = Enum.Font.GothamBold
    BrandLabel.TextSize = 18
    BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
    BrandLabel.BackgroundTransparency = 1
    BrandLabel.Parent = Sidebar

    -- Tabs Scroller
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, 0, 1, -110)
    TabScroll.Position = UDim2.new(0, 0, 0, 60)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = Sidebar

    local TabScrollLayout = Instance.new("UIListLayout")
    TabScrollLayout.Padding = UDim.new(0, 2)
    TabScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabScrollLayout.Parent = TabScroll

    -- Main Content View Window
    local ContainerWindow = Instance.new("Frame")
    ContainerWindow.Name = "ContainerWindow"
    ContainerWindow.Size = UDim2.new(1, -200, 1, -20)
    ContainerWindow.Position = UDim2.new(0, 190, 0, 10)
    ContainerWindow.BackgroundTransparency = 1
    ContainerWindow.Parent = MainFrame

    makeDraggable(Sidebar, MainFrame)

    local WindowObj = {}
    currentWindow = WindowObj
    local categories = {}
    local activeTabBtn = nil
    local activePage = nil

    -- Premium Smooth Slide Animation Handler
    local isVisible = true
    local function setUIVisibility(state)
        isVisible = state
        if isVisible then
            MainFrame.Visible = true
            BlurEffect.Size = 16
            TweenService:Create(MainFrame, TweenInfo.new(0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -355, 0.5, -230)
            }):Play()
        else
            BlurEffect.Size = 0
            local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -355, 0.5, -200)
            })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if not isVisible then MainFrame.Visible = false end
            end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            setUIVisibility(not isVisible)
        end
    end)

    function WindowObj:MakeTab(categoryName, tabName)
        -- Route Layout Hierarchy based on category name (e.g., "MAIN", "AIM", "VISUALS")
        local catKey = string.upper(categoryName)
        local categoryWrap = categories[catKey]

        if not categoryWrap then
            categoryWrap = Instance.new("Frame")
            categoryWrap.Name = catKey .. "_Category"
            categoryWrap.Size = UDim2.new(1, -10, 0, 30)
            categoryWrap.BackgroundTransparency = 1
            categoryWrap.Parent = TabScroll

            local CatLabel = Instance.new("TextLabel")
            CatLabel.Size = UDim2.new(1, 0, 1, 0)
            CatLabel.Position = UDim2.new(0, 18, 0, 0)
            CatLabel.Text = catKey
            CatLabel.TextColor3 = COLORS.TextDim
            CatLabel.Font = Enum.Font.GothamBold
            CatLabel.TextSize = 10
            CatLabel.TextXAlignment = Enum.TextXAlignment.Left
            CatLabel.BackgroundTransparency = 1
            CatLabel.Parent = categoryWrap

            categories[catKey] = categoryWrap
        end

        -- Subpage Container Setup
        local PageFrame = Instance.new("ScrollingFrame")
        PageFrame.Name = tabName .. "_Page"
        PageFrame.Size = UDim2.new(1, 0, 1, 0)
        PageFrame.BackgroundTransparency = 1
        PageFrame.BorderSizePixel = 0
        PageFrame.ScrollBarThickness = 4
        PageFrame.ScrollBarImageColor3 = COLORS.Border
        PageFrame.Visible = false
        PageFrame.Parent = ContainerWindow

        local PageGrid = Instance.new("UIGridLayout")
        PageGrid.CellSize = UDim2.new(0, 245, 0, 210) -- Dual Grid columns
        PageGrid.CellPadding = UDim2.new(0, 15, 0, 15)
        PageGrid.SortOrder = Enum.SortOrder.LayoutOrder
        PageGrid.Parent = PageFrame

        PageGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageGrid.AbsoluteContentSize.Y + 10)
        end)

        -- Tab Interaction Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -10, 0, 32)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "     " .. tabName
        TabBtn.TextColor3 = COLORS.TextDim
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabScroll

        local function activateThisTab()
            if activeTabBtn then
                TweenService:Create(activeTabBtn, TweenInfo.new(0.12), {TextColor3 = COLORS.TextDim}):Play()
            end
            if activePage then activePage.Visible = false end

            activeTabBtn = TabBtn
            activePage = PageFrame
            PageFrame.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.12), {TextColor3 = COLORS.ActivePink}):Play()
        end

        TabBtn.MouseButton1Click:Connect(activateThisTab)
        if not activeTabBtn then activateThisTab() end

        local TabObj = {}

        -- Layout Groups inside current View Window Frame (Cards/Groupboxes)
        function TabObj:MakeGroupbox(boxTitle)
            local GroupCard = Instance.new("Frame")
            GroupCard.BackgroundColor3 = COLORS.CardBg
            GroupCard.BorderSizePixel = 0
            GroupCard.Parent = PageFrame

            local GCCorner = Instance.new("UICorner")
            GCCorner.CornerRadius = UDim.new(0, 6)
            GCCorner.Parent = GroupCard

            local GCOutline = Instance.new("UIStroke")
            GCOutline.Color = COLORS.Border
            GCOutline.Thickness = 1
            GCOutline.Parent = GroupCard

            local GroupTitle = Instance.new("TextLabel")
            GroupTitle.Size = UDim2.new(1, -20, 0, 28)
            GroupTitle.Position = UDim2.new(0, 12, 0, 4)
            GroupTitle.Text = boxTitle
            GroupTitle.TextColor3 = COLORS.TextMain
            GroupTitle.Font = Enum.Font.GothamBold
            GroupTitle.TextSize = 12
            GroupTitle.TextXAlignment = Enum.TextXAlignment.Left
            GroupTitle.BackgroundTransparency = 1
            GroupTitle.Parent = GroupCard

            local ElementsList = Instance.new("Frame")
            ElementsList.Size = UDim2.new(1, -24, 1, -36)
            ElementsList.Position = UDim2.new(0, 12, 0, 34)
            ElementsList.BackgroundTransparency = 1
            ElementsList.Parent = GroupCard

            local ElementsLayout = Instance.new("UIListLayout")
            ElementsLayout.Padding = UDim.new(0, 8)
            ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementsLayout.Parent = ElementsList

            local GroupObj = {}

            function GroupObj:MakeToggle(label, default, callback)
                local ToggleRow = Instance.new("Frame")
                ToggleRow.Size = UDim2.new(1, 0, 0, 24)
                ToggleRow.BackgroundTransparency = 1
                ToggleRow.Parent = ElementsList

                local state = default or false

                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -45, 1, 0)
                Lbl.Text = label
                Lbl.TextColor3 = COLORS.TextDim
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = ToggleRow

                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(0, 34, 0, 18)
                Box.Position = UDim2.new(1, -34, 0.5, -9)
                Box.BackgroundColor3 = state and COLORS.ActivePink or COLORS.InteractBg
                Box.BorderSizePixel = 0
                Box.Parent = ToggleRow

                local BC = Instance.new("UICorner")
                BC.CornerRadius = UDim.new(1, 0)
                BC.Parent = Box

                local Dot = Instance.new("Frame")
                Dot.Size = UDim2.new(0, 14, 0, 14)
                Dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Dot.BorderSizePixel = 0
                Dot.Parent = Box
                Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundTransparency = 1
                Btn.Text = ""
                Btn.Parent = ToggleRow

                Btn.MouseButton1Click:Connect(function()
                    state = not state
                    TweenService:Create(Box, TweenInfo.new(0.12), {BackgroundColor3 = state and COLORS.ActivePink or COLORS.InteractBg}):Play()
                    TweenService:Create(Dot, TweenInfo.new(0.12), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                    task.spawn(callback, state)
                end)
            end

            function GroupObj:MakeSlider(label, min, max, default, callback)
                local SliderRow = Instance.new("Frame")
                SliderRow.Size = UDim2.new(1, 0, 0, 32)
                SliderRow.BackgroundTransparency = 1
                SliderRow.Parent = ElementsList

                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -50, 0, 16)
                Lbl.Text = label
                Lbl.TextColor3 = COLORS.TextDim
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = SliderRow

                local ValLbl = Instance.new("TextLabel")
                ValLbl.Size = UDim2.new(0, 45, 0, 16)
                ValLbl.Position = UDim2.new(1, -45, 0, 0)
                ValLbl.Text = tostring(default or min)
                ValLbl.TextColor3 = COLORS.TextMain
                ValLbl.Font = Enum.Font.GothamBold
                ValLbl.TextSize = 11
                ValLbl.TextXAlignment = Enum.TextXAlignment.Right
                ValLbl.BackgroundTransparency = 1
                ValLbl.Parent = SliderRow

                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(1, 0, 0, 4)
                Track.Position = UDim2.new(0, 0, 1, -6)
                Track.BackgroundColor3 = COLORS.InteractBg
                Track.BorderSizePixel = 0
                Track.Parent = SliderRow

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(math.clamp(((default or min) - min) / (max - min), 0, 1), 0, 1, 0)
                Fill.BackgroundColor3 = COLORS.ActivePink
                Fill.BorderSizePixel = 0
                Fill.Parent = Track

                local Trigger = Instance.new("TextButton")
                Trigger.Size = UDim2.new(1, 0, 3, 0)
                Trigger.Position = UDim2.new(0, 0, -1, 0)
                Trigger.BackgroundTransparency = 1
                Trigger.Text = ""
                Trigger.Parent = Track

                local function updateSlider(percentage)
                    local val = math.round(min + (max - min) * percentage)
                    ValLbl.Text = tostring(val)
                    TweenService:Create(Fill, TweenInfo.new(0.06), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                    task.spawn(callback, val)
                end

                local sliding = false
                Trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        updateSlider(math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1))
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1))
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
                end)
            end

            function GroupObj:MakeDropdown(label, options, callback)
                options = options or {}
                local Expanded = false

                local DropdownRow = Instance.new("Frame")
                DropdownRow.Size = UDim2.new(1, 0, 0, 38)
                DropdownRow.BackgroundTransparency = 1
                DropdownRow.Parent = ElementsList
                DropdownRow.ClipsDescendants = false

                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, 0, 0, 16)
                Lbl.Text = label
                Lbl.TextColor3 = COLORS.TextDim
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.TextSize = 11
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = DropdownRow

                local Trigger = Instance.new("TextButton")
                Trigger.Size = UDim2.new(1, 0, 0, 20)
                Trigger.Position = UDim2.new(0, 0, 0, 18)
                Trigger.BackgroundColor3 = COLORS.InteractBg
                Trigger.Text = "  None"
                Trigger.TextColor3 = COLORS.TextMain
                Trigger.Font = Enum.Font.Gotham
                Trigger.TextSize = 11
                Trigger.TextXAlignment = Enum.TextXAlignment.Left
                Trigger.Parent = DropdownRow
                Instance.new("UICorner", Trigger).CornerRadius = UDim.new(0, 4)

                local ListFrame = Instance.new("Frame")
                ListFrame.Size = UDim2.new(1, 0, 0, #options * 22)
                ListFrame.Position = UDim2.new(0, 0, 1, 2)
                ListFrame.BackgroundColor3 = COLORS.CardBg
                ListFrame.Visible = false
                ListFrame.ZIndex = 5
                ListFrame.Parent = Trigger
                Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", ListFrame).Color = COLORS.Border

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = ListFrame

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 22)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = "  " .. tostring(opt)
                    OptBtn.TextColor3 = COLORS.TextDim
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 11
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.ZIndex = 6
                    OptBtn.Parent = ListFrame

                    OptBtn.MouseButton1Click:Connect(function()
                        Trigger.Text = "  " .. tostring(opt)
                        ListFrame.Visible = false
                        Expanded = false
                        task.spawn(callback, opt)
                    end)
                end

                Trigger.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    ListFrame.Visible = Expanded
                end)
            end

            return GroupObj
        end

        return TabObj
    end

    -- Persistent Unload Frame Anchor (Bottom-Left Side)
    local CloseHolder = Instance.new("Frame")
    CloseHolder.Size = UDim2.new(1, 0, 0, 45)
    CloseHolder.Position = UDim2.new(0, 0, 1, -45)
    CloseHolder.BackgroundTransparency = 1
    CloseHolder.Parent = Sidebar

    local UnloadBtn = Instance.new("TextButton")
    UnloadBtn.Size = UDim2.new(1, -24, 0, 28)
    UnloadBtn.Position = UDim2.new(0, 12, 0, 5)
    UnloadBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 30)
    UnloadBtn.Text = "Unload Hub"
    UnloadBtn.TextColor3 = COLORS.ActivePink
    UnloadBtn.Font = Enum.Font.GothamBold
    UnloadBtn.TextSize = 11
    UnloadBtn.Parent = CloseHolder
    Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 4)

    UnloadBtn.MouseButton1Click:Connect(function() UI:Unload() end)

    return WindowObj
end

return UI
