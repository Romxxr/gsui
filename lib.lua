--[[
    gaysploits UI Library
    Version: 1.0.0
    License: MIT
    Target: CoreGui, Loadstring-compatible, Mobile & PC Friendly
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local UI = {}

-- Utility: Enable Smooth Dragging for PC & Mobile
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
            TweenService:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

function UI:MakeWindow(config)
    config = config or {}
    local titleText = config.Title or "gaysploits"
    
    -- Destroy old instances to prevent UI stacking on re-run
    if CoreGui:FindFirstChild("gaysploits_Gui") then
        CoreGui:FindFirstChild("gaysploits_Gui"):Destroy()
    end

    -- Base ScreenGui inside protected CoreGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "gaysploits_Gui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -180)
    MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- Super Fancy Rainbow Outline/Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2.5
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = MainFrame
    
    local RainbowGradient = Instance.new("UIGradient")
    RainbowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 90)),    -- Coral Red
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 90)), -- Peach Orange
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 240, 100)),-- Soft Yellow
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(100, 255, 170)),-- Mint Green
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(90, 190, 255)), -- Sky Blue
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 110, 255))   -- Electric Violet
    })
    RainbowGradient.Parent = Stroke

    -- Smooth Rotating Animation for the Rainbow Border
    task.spawn(function()
        local rot = 0
        while MainFrame and MainFrame.Parent do
            rot = (rot + 1.5) % 360
            RainbowGradient.Rotation = rot
            task.wait(0.015)
        end
    end)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = MainFrame

    -- Top Header Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 9)
    TopCorner.Parent = TopBar
    
    -- Cover bottom rounded edges of the top bar
    local FixCover = Instance.new("Frame")
    FixCover.Size = UDim2.new(1, 0, 0, 10)
    FixCover.Position = UDim2.new(0, 0, 1, -10)
    FixCover.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    FixCover.BorderSizePixel = 0
    FixCover.Parent = TopBar

    -- Title text
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 17
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = TopBar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0, 7.5)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
    CloseBtn.TextSize = 15
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = TopBar

    CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 90, 90)}):Play() end)
    CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(140, 140, 150)}):Play() end)
    
    -- Scrolling Component Canvas
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -20, 1, -65)
    ContentContainer.Position = UDim2.new(0, 10, 0, 55)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 4
    ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    ContentContainer.Parent = MainFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentContainer

    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    end)

    makeDraggable(TopBar, MainFrame)

    -- Opening Elastic Tween Animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 550, 0, 360),
        Position = UDim2.new(0.5, -275, 0.5, -180)
    }):Play()

    CloseBtn.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)

    local WindowObj = {}

    function WindowObj:MakeSection(sectionName)
        local SectionObj = {}

        -- Section Header Title
        local SectionHeader = Instance.new("TextLabel")
        SectionHeader.Size = UDim2.new(1, 0, 0, 22)
        SectionHeader.Text = "  " .. string.upper(sectionName)
        SectionHeader.TextColor3 = Color3.fromRGB(130, 130, 150)
        SectionHeader.Font = Enum.Font.GothamBold
        SectionHeader.TextSize = 11
        SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
        SectionHeader.BackgroundTransparency = 1
        SectionHeader.Parent = ContentContainer

        local function createBaseComponent(height)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -6, 0, height)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentContainer
            
            local C = Instance.new("UICorner")
            C.CornerRadius = UDim.new(0, 6)
            C.Parent = Frame
            return Frame
        end

        -- Component: Label
        function SectionObj:MakeLabel(text)
            local LabelFrame = createBaseComponent(32)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(210, 210, 215)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = LabelFrame
            return LabelFrame
        end

        -- Component: Button
        function SectionObj:MakeButton(label, callback)
            local ButtonFrame = createBaseComponent(38)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.Text = "  " .. label
            Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 135
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.BackgroundTransparency = 1
            Btn.Parent = ButtonFrame

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 30, 1, 0)
            Arrow.Position = UDim2.new(1, -35, 0, 0)
            Arrow.Text = "➔"
            Arrow.TextColor3 = Color3.fromRGB(100, 100, 120)
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 13
            Arrow.BackgroundTransparency = 1
            Arrow.Parent = ButtonFrame

            Btn.MouseEnter:Connect(function() TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(36, 36, 44)}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 36)}):Play() end)
            
            Btn.MouseButton1Click:Connect(function()
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                task.delay(0.08, function() ButtonFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 44) end)
                task.spawn(callback)
            end)
        end

        -- Component: Toggle
        function SectionObj:MakeToggle(label, default, callback)
            local ToggleFrame = createBaseComponent(38)
            local state = default or false

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -60, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Text = label
            Title.TextColor3 = Color3.fromRGB(240, 240, 245)
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 38, 0, 18)
            Switch.Position = UDim2.new(1, -48, 0.5, -9)
            Switch.BackgroundColor3 = state and Color3.fromRGB(90, 220, 120) or Color3.fromRGB(55, 55, 65)
            Switch.Parent = ToggleFrame
            
            local SC = Instance.new("UICorner")
            SC.CornerRadius = UDim.new(1, 0)
            SC.Parent = Switch

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 14, 0, 14)
            Circle.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
                local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                local targetColor = state and Color3.fromRGB(90, 220, 120) or Color3.fromRGB(55, 55, 65)
                TweenService:Create(Circle, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
                task.spawn(callback, state)
            end

            Hitbox.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
            end)
        end

        -- Component: Slider
        function SectionObj:MakeSlider(label, min, max, default, callback)
            local SliderFrame = createBaseComponent(46)
            
            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -80, 0, 24)
            Title.Position = UDim2.new(0, 10, 0, 2)
            Title.Text = label
            Title.TextColor3 = Color3.fromRGB(240, 240, 245)
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 60, 0, 24)
            ValueLabel.Position = UDim2.new(1, -70, 0, 2)
            ValueLabel.Text = tostring(default or min)
            ValueLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Parent = SliderFrame

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -20, 0, 5)
            Track.Position = UDim2.new(0, 10, 0, 30)
            Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            Track.BorderSizePixel = 0
            Track.Parent = SliderFrame
            
            local TC = Instance.new("UICorner")
            TC.CornerRadius = UDim.new(1, 0)
            TC.Parent = Track

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(math.clamp(((default or min) - min) / (max - min), 0, 1), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(110, 160, 255)
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
                    relativeX = math.clamp(relativeX, 0, 1)
                    snapValue(relativeX)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
        end

        -- Component: Textbox
        function SectionObj:MakeTextbox(label, placeholder, callback)
            local BoxFrame = createBaseComponent(38)

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(0.4, 0, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Text = label
            Title.TextColor3 = Color3.fromRGB(240, 240, 245)
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = BoxFrame

            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(0.55, 0, 0, 26)
            InputBox.Position = UDim2.new(0.45, -10, 0.5, -13)
            InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            InputBox.Text = ""
            InputBox.PlaceholderText = placeholder or "Type here..."
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

        -- Component: Dropdown
        function SectionObj:MakeDropdown(label, options, callback)
            options = options or {}
            local Expanded = false
            local DropdownFrame = createBaseComponent(38)
            DropdownFrame.ClipsDescendants = true

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -40, 0, 38)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Text = label .. " (Select...)"
            Title.TextColor3 = Color3.fromRGB(240, 240, 245)
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = DropdownFrame

            local Indicator = Instance.new("TextLabel")
            Indicator.Size = UDim2.new(0, 30, 0, 38)
            Indicator.Position = UDim2.new(1, -35, 0, 0)
            Indicator.Text = "▼"
            Indicator.TextColor3 = Color3.fromRGB(120, 120, 130)
            Indicator.Font = Enum.Font.GothamBold
            Indicator.TextSize = 11
            Indicator.BackgroundTransparency = 1
            Indicator.Parent = DropdownFrame

            local ItemHolder = Instance.new("Frame")
            ItemHolder.Size = UDim2.new(1, -20, 0, #options * 30)
            ItemHolder.Position = UDim2.new(0, 10, 0, 38)
            ItemHolder.BackgroundTransparency = 1
            ItemHolder.Parent = DropdownFrame

            local ItemLayout = Instance.new("UIListLayout")
            ItemLayout.Padding = UDim.new(0, 2)
            ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ItemLayout.Parent = ItemHolder

            local Trigger = Instance.new("TextButton")
            Trigger.Size = UDim2.new(1, 0, 0, 38)
            Trigger.BackgroundTransparency = 1
            Trigger.Text = ""
            Trigger.Parent = DropdownFrame

            local function refreshCanvasSize()
                local currentLayout = ContentContainer:FindFirstChildOfClass("UIListLayout")
                if currentLayout then
                    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, currentLayout.AbsoluteContentSize.Y + 10)
                end
            end

            for i, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 28)
                OptBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                OptBtn.Text = "  " .. tostring(opt)
                OptBtn.TextColor3 = Color3.fromRGB(190, 190, 195)
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
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -6, 0, 38)}):Play()
                    Indicator.Text = "▼"
                    task.wait(0.2)
                    refreshCanvasSize()
                    task.spawn(callback, opt)
                end)
            end

            Trigger.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                local targetHeight = Expanded and (38 + (#options * 30)) or 38
                Indicator.Text = Expanded and "▲" or "▼"
                
                local tween = TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -6, 0, targetHeight)})
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

    return WindowObj
end

return UI
