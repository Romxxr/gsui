--[[
    gaysploits Ultra Premium UI Library (CS-Cheat Style Layout)
    Two-Column System, Dynamic Section Routing, Real Acrylic Blur
    
    Controls:
    - [RightShift] to Toggle Show/Hide
    - Use the "Unload" button in the bottom-left corner to destroy completely.
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local UI = {}
local currentWindow = nil

local COLORS = {
    Background = Color3.fromRGB(12, 12, 16),
    LeftPanel = Color3.fromRGB(18, 18, 24),
    ContentPanel = Color3.fromRGB(14, 14, 18),
    Border = Color3.fromRGB(40, 40, 48),
    Accents = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 120)),   -- Premium Pink
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(110, 180, 255)), -- Ice Blue
        ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 110, 255)),  -- Purple
    }),
    MainText = Color3.fromRGB(245, 245, 250),
    DimText = Color3.fromRGB(140, 140, 150),
    ComponentBg = Color3.fromRGB(24, 24, 32),
    ComponentHover = Color3.fromRGB(32, 32, 42),
    ActiveTab = Color3.fromRGB(35, 35, 48),
    SliderFill = Color3.fromRGB(110, 180, 255)
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
    if CoreGui:FindFirstChild("gaysploits_Premium_V2") then
        local gui = CoreGui:FindFirstChild("gaysploits_Premium_V2")
        gui:Destroy()
    end
    if Lighting:FindFirstChild("gaysploits_Blur") then
        Lighting:FindFirstChild("gaysploits_Blur"):Destroy()
    end
    currentWindow = nil
end

function UI:MakeWindow(config)
    config = config or {}
    local titleText = config.Title or "gaysploits premium"
    
    if CoreGui:FindFirstChild("gaysploits_Premium_V2") then
        CoreGui:FindFirstChild("gaysploits_Premium_V2"):Destroy()
    end
    if Lighting:FindFirstChild("gaysploits_Blur") then
        Lighting:FindFirstChild("gaysploits_Blur"):Destroy()
    end

    -- Base ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "gaysploits_Premium_V2"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    -- Premium Real Back Blur Effect
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Name = "gaysploits_Blur"
    BlurEffect.Size = 14
    BlurEffect.Parent = Lighting

    -- Bigger Main Panel Frame (CS-Cheat Inspired Size 680x440)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 680, 0, 440)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -220)
    MainFrame.BackgroundColor3 = COLORS.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame

    -- Outer Premium Razor Rainbow Stroke Grid
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.8
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = MainFrame
    
    local RainbowGradient = Instance.new("UIGradient")
    RainbowGradient.Color = COLORS.Accents
    RainbowGradient.Parent = Stroke

    task.spawn(function()
        local rot = 0
        while MainFrame and MainFrame.Parent do
            rot = (rot + 1.5) % 360
            RainbowGradient.Rotation = rot
            task.wait(0.01)
        end
    end)

    -- Left Navigation Column
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Name = "LeftPanel"
    LeftPanel.Size = UDim2.new(0, 170, 1, 0)
    LeftPanel.BackgroundColor3 = COLORS.LeftPanel
    LeftPanel.BorderSizePixel = 0
    LeftPanel.Parent = MainFrame

    local LPCorner = Instance.new("UICorner")
    LPCorner.CornerRadius = UDim.new(0, 10)
    LPCorner.Parent = LeftPanel

    -- Clean corner-cutting helper for side layout alignment
    local LPBoxFix = Instance.new("Frame")
    LPBoxFix.Size = UDim2.new(0, 15, 1, 0)
    LPBoxFix.Position = UDim2.new(1, -15, 0, 0)
    LPBoxFix.BackgroundColor3 = COLORS.LeftPanel
    LPBoxFix.BorderSizePixel = 0
    LPBoxFix.Parent = LeftPanel

    -- Top Header Panel inside Left Control Column
    local HeaderText = Instance.new("TextLabel")
    HeaderText.Size = UDim2.new(1, 0, 0, 55)
    HeaderText.Text = titleText:lower()
    HeaderText.TextColor3 = COLORS.MainText
    HeaderText.Font = Enum.Font.GothamBold
    HeaderText.TextSize = 18
    HeaderText.Position = UDim2.new(0, 15, 0, 0)
    HeaderText.TextXAlignment = Enum.TextXAlignment.Left
    HeaderText.BackgroundTransparency = 1
    HeaderText.Parent = LeftPanel

    -- Tab Selection Scrolling Buttons list layout
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -10, 1, -115)
    TabScroll.Position = UDim2.new(0, 5, 0, 60)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = LeftPanel

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabScroll

    -- Content Windows Matrix right side wrapper frame
    local DisplayArea = Instance.new("Frame")
    DisplayArea.Name = "DisplayArea"
    DisplayArea.Size = UDim2.new(1, -180, 1, -20)
    DisplayArea.Position = UDim2.new(0, 175, 0, 10)
    DisplayArea.BackgroundTransparency = 1
    DisplayArea.Parent = MainFrame

    makeDraggable(LeftPanel, MainFrame)

    local WindowObj = {}
    currentWindow = WindowObj
    local activeTabButton = nil
    local activeContainer = nil

    -- Clean premium transparency/slide reveal animation
    local function playPremiumOpenAnim()
        MainFrame.Visible = true
        MainFrame.GroupColor3 = Color3.fromRGB(255, 255, 255)
        BlurEffect.Size = 14
        
        local targetPos = UDim2.new(0.5, -340, 0.5, -220)
        MainFrame.Position = UDim2.new(0.5, -340, 0.5, -190) -- starts slightly lower
        
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Position = targetPos
        }):Play()
    end

    local function playPremiumCloseAnim()
        BlurEffect.Size = 0
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -340, 0.5, -190)
        })
        tween:Play()
        tween.Completed:Connect(function()
            if MainFrame then MainFrame.Visible = false end
        end)
    end

    -- Toggle handler (RightShift)
    local isVisible = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift and currentWindow == WindowObj then
            isVisible = not isVisible
            if isVisible then
                playPremiumOpenAnim()
            else
                playPremiumCloseAnim()
            end
        end
    end)

    -- Trigger init anim immediately
    playPremiumOpenAnim()

    function WindowObj:MakeSection(sectionName)
        local ContainerFrame = Instance.new("ScrollingFrame")
        ContainerFrame.Name = sectionName .. "_Container"
        ContainerFrame.Size = UDim2.new(1, 0, 1, 0)
        ContainerFrame.BackgroundTransparency = 1
        ContainerFrame.BorderSizePixel = 0
        ContainerFrame.ScrollBarThickness = 4
        ContainerFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
        ContainerFrame.Visible = false
        ContainerFrame.Parent = DisplayArea

        local ContainerLayout = Instance.new("UIListLayout")
        ContainerLayout.Padding = UDim.new(0, 8)
        ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContainerLayout.Parent = ContainerFrame

        ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 10)
        end)

        -- Tab Selection Trigger Bar
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -5, 0, 36)
        TabBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "   " .. sectionName
        TabBtn.TextColor3 = COLORS.DimText
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabScroll

        local TBCorner = Instance.new("UICorner")
        TBCorner.CornerRadius = UDim.new(0, 6)
        TBCorner.Parent = TabBtn

        -- Accent left indicator block
        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(0, 3, 0, 16)
        TabIndicator.Position = UDim2.new(0, 0, 0.5, -8)
        TabIndicator.BackgroundColor3 = Color3.fromRGB(255, 90, 120)
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Visible = false
        TabIndicator.Parent = TabBtn

        local function selectThisTab()
            if activeTabButton then
                TweenService:Create(activeTabButton, TweenInfo.new(0.15), {TextColor3 = COLORS.DimText, BackgroundTransparency = 1}):Play()
                activeTabButton.TabIndicator.Visible = false
            end
            if activeContainer then
                activeContainer.Visible = false
            end
            
            activeTabButton = TabBtn
            activeContainer = ContainerFrame
            
            TabBtn.TabIndicator.Visible = true
            ContainerFrame.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {TextColor3 = COLORS.MainText, BackgroundTransparency = 0.85, BackgroundColor3 = COLORS.ActiveTab}):Play()
        end

        TabBtn.MouseButton1Click:Connect(selectThisTab)
        if activeTabButton == nil then
            selectThisTab() -- Auto-focus on first created section
        end

        local SectionObj = {}

        local function createBaseComponent(height)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, height)
            Frame.BackgroundColor3 = COLORS.ComponentBg
            Frame.BorderSizePixel = 0
            Frame.Parent = ContainerFrame
            
            local C = Instance.new("UICorner")
            C.CornerRadius = UDim.new(0, 6)
            C.Parent = Frame
            return Frame
        end

        function SectionObj:MakeLabel(text)
            local LabelFrame = createBaseComponent(34)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.Text = text
            Label.TextColor3 = COLORS.DimText
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = LabelFrame
            return LabelFrame
        end

        function SectionObj:MakeButton(label, callback)
            local ButtonFrame = createBaseComponent(40)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.Text = "  " .. label
            Btn.TextColor3 = COLORS.MainText
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.BackgroundTransparency = 1
            Btn.Parent = ButtonFrame

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 30, 1, 0)
            Arrow.Position = UDim2.new(1, -35, 0, 0)
            Arrow.Text = "➔"
            Arrow.TextColor3 = COLORS.DimText
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 13
            Arrow.BackgroundTransparency = 1
            Arrow.Parent = ButtonFrame

            Btn.MouseEnter:Connect(function() TweenService:Create(ButtonFrame, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.ComponentHover}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(ButtonFrame, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.ComponentBg}):Play() end)
            
            Btn.MouseButton1Click:Connect(function()
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
                task.delay(0.06, function() ButtonFrame.BackgroundColor3 = COLORS.ComponentHover end)
                task.spawn(callback)
            end)
        end

        function SectionObj:MakeToggle(label, default, callback)
            local ToggleFrame = createBaseComponent(40)
            local state = default or false

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -70, 1, 0)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.Text = label
            Title.TextColor3 = COLORS.MainText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 40, 0, 20)
            Switch.Position = UDim2.new(1, -52, 0.5, -10)
            Switch.BackgroundColor3 = state and COLORS.SliderFill or Color3.fromRGB(45, 45, 52)
            Switch.Parent = ToggleFrame
            
            local SC = Instance.new("UICorner")
            SC.CornerRadius = UDim.new(1, 0)
            SC.Parent = Switch

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Circle.Parent = Switch
            
            local CC = Instance.new("UICorner")
            CC.CornerRadius = UDim.new(1, 0)
            CC.Parent = Circle

            local Hitbox = Instance.new("TextButton")
            Hitbox.Size = UDim2.new(1, 0, 1, 0)
            Hitbox.BackgroundTransparency = 1
            Hitbox.Text = ""
            Hitbox.Parent = ToggleFrame

            local function updateToggle()
                local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local targetColor = state and COLORS.SliderFill or Color3.fromRGB(45, 45, 52)
                TweenService:Create(Circle, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
                task.spawn(callback, state)
            end

            Hitbox.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
            end)
        end

        function SectionObj:MakeSlider(label, min, max, default, callback)
            local SliderFrame = createBaseComponent(50)
            
            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -90, 0, 26)
            Title.Position = UDim2.new(0, 12, 0, 2)
            Title.Text = label
            Title.TextColor3 = COLORS.MainText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 70, 0, 26)
            ValueLabel.Position = UDim2.new(1, -82, 0, 2)
            ValueLabel.Text = tostring(default or min)
            ValueLabel.TextColor3 = COLORS.DimText
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Parent = SliderFrame

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -24, 0, 6)
            Track.Position = UDim2.new(0, 12, 0, 34)
            Track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            Track.BorderSizePixel = 0
            Track.Parent = SliderFrame
            
            local TC = Instance.new("UICorner")
            TC.CornerRadius = UDim.new(1, 0)
            TC.Parent = Track

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(math.clamp(((default or min) - min) / (max - min), 0, 1), 0, 1, 0)
            Fill.BackgroundColor3 = COLORS.SliderFill
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            
            local FC = Instance.new("UICorner")
            FC.CornerRadius = UDim.new(1, 0)
            FC.Parent = Fill

            local Trigger = Instance.new("TextButton")
            Trigger.Size = UDim2.new(1, 0, 1, 0)
            Trigger.BackgroundTransparency = 1
            Trigger.Text = ""
            Trigger.Parent = Track

            local function snapValue(percentage)
                local val = math.round(min + (max - min) * percentage)
                ValueLabel.Text = tostring(val)
                TweenService:Create(Fill, TweenInfo.new(0.06), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                task.spawn(callback, val)
            end

            local sliding = false
            Trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    local relativeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    snapValue(relativeX)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relativeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    snapValue(relativeX)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
        end

        function SectionObj:MakeTextbox(label, placeholder, callback)
            local BoxFrame = createBaseComponent(40)

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(0.4, 0, 1, 0)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.Text = label
            Title.TextColor3 = COLORS.MainText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = BoxFrame

            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(0.55, 0, 0, 26)
            InputBox.Position = UDim2.new(0.45, -12, 0.5, -13)
            InputBox.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
            InputBox.Text = ""
            InputBox.PlaceholderText = placeholder or "Input config..."
            InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            InputBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 100)
            InputBox.Font = Enum.Font.Gotham
            InputBox.TextSize = 12
            InputBox.ClipsDescendants = true
            InputBox.Parent = BoxFrame

            local BC = Instance.new("UICorner")
            BC.CornerRadius = UDim.new(0, 5)
            BC.Parent = InputBox

            InputBox.FocusLost:Connect(function(enterPressed)
                task.spawn(callback, InputBox.Text, enterPressed)
            end)
        end

        function SectionObj:MakeDropdown(label, options, callback)
            options = options or {}
            local Expanded = false
            local DropdownFrame = createBaseComponent(40)
            DropdownFrame.ClipsDescendants = true

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -40, 0, 40)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.Text = label .. " (Select...)"
            Title.TextColor3 = COLORS.MainText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = DropdownFrame

            local Indicator = Instance.new("TextLabel")
            Indicator.Size = UDim2.new(0, 30, 0, 40)
            Indicator.Position = UDim2.new(1, -38, 0, 0)
            Indicator.Text = "▼"
            Indicator.TextColor3 = COLORS.DimText
            Indicator.Font = Enum.Font.GothamBold
            Indicator.TextSize = 11
            Indicator.BackgroundTransparency = 1
            Indicator.Parent = DropdownFrame

            local ItemHolder = Instance.new("Frame")
            ItemHolder.Size = UDim2.new(1, -24, 0, #options * 30)
            ItemHolder.Position = UDim2.new(0, 12, 0, 40)
            ItemHolder.BackgroundTransparency = 1
            ItemHolder.Parent = DropdownFrame

            local ItemLayout = Instance.new("UIListLayout")
            ItemLayout.Padding = UDim.new(0, 2)
            ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ItemLayout.Parent = ItemHolder

            local Trigger = Instance.new("TextButton")
            Trigger.Size = UDim2.new(1, 0, 0, 40)
            Trigger.BackgroundTransparency = 1
            Trigger.Text = ""
            Trigger.Parent = DropdownFrame

            local function refreshCanvasSize()
                local currentLayout = ContainerFrame:FindFirstChildOfClass("UIListLayout")
                if currentLayout then
                    ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, currentLayout.AbsoluteContentSize.Y + 15)
                end
            end

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 28)
                OptBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
                OptBtn.Text = "  " .. tostring(opt)
                OptBtn.TextColor3 = COLORS.DimText
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 12
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.Parent = ItemHolder
                
                local OC = Instance.new("UICorner")
                OC.CornerRadius = UDim.new(0, 4)
                OC.Parent = OptBtn

                OptBtn.MouseButton1Click:Connect(function()
                    Title.Text = label .. " (" .. tostring(opt) .. ")"
                    Expanded = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -10, 0, 40)}):Play()
                    Indicator.Text = "▼"
                    task.wait(0.18)
                    refreshCanvasSize()
                    task.spawn(callback, opt)
                end)
            end

            Trigger.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                local targetHeight = Expanded and (40 + (#options * 30)) or 40
                Indicator.Text = Expanded and "▲" or "▼"
                
                local tween = TweenService:Create(DropdownFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -10, 0, targetHeight)})
                tween:Play()
                if Expanded then
                    refreshCanvasSize()
                else
                    tween.Completed:Connect(function() refreshCanvasSize() end)
                end
            end)
        end

        return SectionObj
    end

    -- Bottom-Left Anchor Unload Clean Dashboard System 
    local UnloadBtn = Instance.new("TextButton")
    UnloadBtn.Size = UDim2.new(1, -20, 0, 32)
    UnloadBtn.Position = UDim2.new(0, 10, 1, -42)
    UnloadBtn.BackgroundColor3 = Color3.fromRGB(28, 20, 24)
    UnloadBtn.Text = "Unload Script"
    UnloadBtn.TextColor3 = Color3.fromRGB(255, 90, 100)
    UnloadBtn.Font = Enum.Font.GothamBold
    UnloadBtn.TextSize = 12
    UnloadBtn.Parent = LeftPanel

    local UC = Instance.new("UICorner")
    UC.CornerRadius = UDim.new(0, 6)
    UC.Parent = UnloadBtn

    local UnloadStroke = Instance.new("UIStroke")
    UnloadStroke.Thickness = 1
    UnloadStroke.Color = Color3.fromRGB(70, 35, 40)
    UnloadStroke.Parent = UnloadBtn

    UnloadBtn.MouseEnter:Connect(function() TweenService:Create(UnloadBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 20, 25)}):Play() end)
    UnloadBtn.MouseLeave:Connect(function() TweenService:Create(UnloadBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 20, 24)}):Play() end)
    UnloadBtn.MouseButton1Click:Connect(function() UI:Unload() end)

    return WindowObj
end

return UI
