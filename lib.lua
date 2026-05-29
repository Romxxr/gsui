--[[
    gaysploits Premium UI Library (loadstring compatible)
    Inspired by high-end CS cheat interfaces.
    Target: CoreGui, Mobile/PC Friendly, Ultra-Animated
    
    API:
    local UI = loadstring(game:HttpGet("...raw.githubusercontent.com/.../lib.lua"))()
    local Window = UI:MakeWindow({ Title = "My Hub", Theme = "PremiumDark" })
    local Section = Window:MakeSection("Combat")
    Section:MakeSlider(label, min, max, default, callback)
    Section:MakeToggle(label, default, callback)
    Section:MakeButton(label, callback)
    Section:MakeTextbox(label, placeholder, callback)
    Section:MakeDropdown(label, options, callback)
    Section:MakeLabel(text)
    
    Window:Show() -- Displays the UI
    Window:Hide() -- Hides the UI (RightShift to toggle)
    UI:Unload() -- Completely removes the library from memory
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local UI = {}
local currentWindow = nil

-- Premium Color Palette
local COLORS = {
    Background = Color3.fromRGB(15, 15, 20),
    Border = Color3.fromRGB(50, 50, 60),
    Accents = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)), -- Pink
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 255)), -- Blue
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 120, 255)), -- Purple
    }),
    MainText = Color3.fromRGB(240, 240, 245),
    DimText = Color3.fromRGB(160, 160, 170),
    ButtonBackground = Color3.fromRGB(30, 30, 38),
    ButtonHover = Color3.fromRGB(40, 40, 50),
    ToggleBackground = Color3.fromRGB(35, 35, 42),
    ToggleCircle = Color3.fromRGB(255, 255, 255),
    SliderBackground = Color3.fromRGB(50, 50, 60),
    SliderFill = Color3.fromRGB(100, 180, 255),
    TextboxBackground = Color3.fromRGB(20, 20, 25),
    PlaceholderText = Color3.fromRGB(100, 100, 110),
}

-- Utility: Dragging logic
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

-- Completely removes the UI library
function UI:Unload()
    if CoreGui:FindFirstChild("gaysploits_Gui_Premium") then
        local gui = CoreGui:FindFirstChild("gaysploits_Gui_Premium")
        local mainFrame = gui:FindFirstChild("MainFrame")
        if mainFrame then
            -- Optional fade-out before destruction
            local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                gui:Destroy()
            end)
        else
            gui:Destroy()
        end
    end
    currentWindow = nil
    UI = nil -- Nullify global to signal removal
end

function UI:MakeWindow(config)
    config = config or {}
    local titleText = config.Title or "gaysploits Premium"
    
    -- Protect against duplicate instances
    if CoreGui:FindFirstChild("gaysploits_Gui_Premium") then
        CoreGui:FindFirstChild("gaysploits_Gui_Premium"):Destroy()
    end

    -- Base ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "gaysploits_Gui_Premium"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    -- Main Frame (Clean dark with border)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 580, 0, 390)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -195)
    MainFrame.BackgroundColor3 = COLORS.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    -- Rainbow Border Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = MainFrame
    
    local RainbowGradient = Instance.new("UIGradient")
    RainbowGradient.Color = COLORS.Accents
    RainbowGradient.Parent = Stroke

    -- Animate the rainbow border (faster and smoother)
    task.spawn(function()
        local rot = 0
        while MainFrame and MainFrame.Parent do
            rot = (rot + 3) % 360
            RainbowGradient.Rotation = rot
            task.wait(0.01)
        end
    end)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame

    -- Top Bar / Header
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15) -- Slightly darker
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar
    
    local FixCover = Instance.new("Frame")
    FixCover.Size = UDim2.new(1, 0, 0, 15)
    FixCover.Position = UDim2.new(0, 0, 1, -15)
    FixCover.BackgroundColor3 = TopBar.BackgroundColor3
    FixCover.BorderSizePixel = 0
    FixCover.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Text = titleText
    Title.TextColor3 = COLORS.MainText
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 19
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = TopBar

    -- Close Button (Premium style with hover color change)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -45, 0, 9)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = COLORS.DimText
    CloseBtn.TextSize = 17
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = TopBar

    CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 70, 70)}):Play() end)
    CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = COLORS.DimText}):Play() end)
    
    -- Content Container
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -30, 1, -75)
    ContentContainer.Position = UDim2.new(0, 15, 0, 60)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 5
    ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    ContentContainer.Parent = MainFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentContainer

    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 15)
    end)

    makeDraggable(TopBar, MainFrame)

    -- RightShift to Toggle handling
    local isVisible = true
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift and UI ~= nil and currentWindow == WindowObj then
            isVisible = not isVisible
            if isVisible then
                MainFrame.Visible = true
                TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 580, 0, 390),
                    Position = UDim2.new(0.5, -290, 0.5, -195)
                }):Play()
            else
                local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                })
                closeTween:Play()
                closeTween.Completed:Connect(function()
                    if not isVisible then MainFrame.Visible = false end
                end)
            end
        end
    end)

    -- Initial animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 580, 0, 390),
        Position = UDim2.new(0.5, -290, 0.5, -195)
    }):Play()

    CloseBtn.MouseButton1Click:Connect(function()
        -- Close just this window, don't unload completely yet.
        isVisible = false
        local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            if not isVisible then MainFrame.Visible = false end
        end)
    end)

    local WindowObj = {}
    currentWindow = WindowObj

    function WindowObj:MakeSection(sectionName)
        local SectionObj = {}

        -- Section Label
        local SectionHeader = Instance.new("TextLabel")
        SectionHeader.Size = UDim2.new(1, 0, 0, 28)
        SectionHeader.Text = "  " .. string.upper(sectionName)
        SectionHeader.TextColor3 = COLORS.DimText
        SectionHeader.Font = Enum.Font.GothamBold
        SectionHeader.TextSize = 13
        SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
        SectionHeader.BackgroundTransparency = 1
        SectionHeader.Parent = ContentContainer

        local function createBaseComponent(height)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -6, 0, height)
            Frame.BackgroundColor3 = COLORS.ButtonBackground
            Frame.BorderSizePixel = 0
            Frame.Parent = ContentContainer
            
            local C = Instance.new("UICorner")
            C.CornerRadius = UDim.new(0, 8)
            C.Parent = Frame
            
            return Frame
        end

        function SectionObj:MakeLabel(text)
            local LabelFrame = createBaseComponent(36)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -24, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(220, 220, 225)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 15
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = LabelFrame
            return LabelFrame
        end

        function SectionObj:MakeButton(label, callback)
            local ButtonFrame = createBaseComponent(42)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.Text = "  " .. label
            Btn.TextColor3 = COLORS.MainText
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 15
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.BackgroundTransparency = 1
            Btn.Parent = ButtonFrame

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 30, 1, 0)
            Arrow.Position = UDim2.new(1, -38, 0, 0)
            Arrow.Text = "➔"
            Arrow.TextColor3 = COLORS.DimText
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 15
            Arrow.BackgroundTransparency = 1
            Arrow.Parent = ButtonFrame

            Btn.MouseEnter:Connect(function() TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.ButtonHover}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.ButtonBackground}):Play() end)
            
            Btn.MouseButton1Click:Connect(function()
                -- Premium flash effect
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                task.delay(0.08, function() ButtonFrame.BackgroundColor3 = COLORS.ButtonHover end)
                task.spawn(callback)
            end)
        end

        function SectionObj:MakeToggle(label, default, callback)
            local ToggleFrame = createBaseComponent(42)
            local state = default or false

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -70, 1, 0)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.Text = label
            Title.TextColor3 = COLORS.MainText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 15
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 44, 0, 22)
            Switch.Position = UDim2.new(1, -56, 0.5, -11)
            Switch.BackgroundColor3 = state and COLORS.SliderFill or COLORS.ToggleBackground
            Switch.Parent = ToggleFrame
            
            local SC = Instance.new("UICorner")
            SC.CornerRadius = UDim.new(1, 0)
            SC.Parent = Switch

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 18, 0, 18)
            Circle.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            Circle.BackgroundColor3 = COLORS.ToggleCircle
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
                local targetPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                local targetColor = state and COLORS.SliderFill or COLORS.ToggleBackground
                TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
                task.spawn(callback, state)
            end

            Hitbox.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
            end)
        end

        function SectionObj:MakeSlider(label, min, max, default, callback)
            local SliderFrame = createBaseComponent(52)
            
            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -90, 0, 28)
            Title.Position = UDim2.new(0, 12, 0, 4)
            Title.Text = label
            Title.TextColor3 = COLORS.MainText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 15
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 70, 0, 28)
            ValueLabel.Position = UDim2.new(1, -82, 0, 4)
            ValueLabel.Text = tostring(default or min)
            ValueLabel.TextColor3 = COLORS.DimText
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 14
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Parent = SliderFrame

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -24, 0, 8)
            Track.Position = UDim2.new(0, 12, 0, 36)
            Track.BackgroundColor3 = COLORS.SliderBackground
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
                local val = min + (max - min) * percentage
                val = math.round(val) -- Change for decimals if needed
                ValueLabel.Text = tostring(val)
                TweenService:Create(Fill, TweenInfo.new(0.08), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
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
            local BoxFrame = createBaseComponent(42)

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(0.4, 0, 1, 0)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.Text = label
            Title.TextColor3 = COLORS.MainText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 15
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = BoxFrame

            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(0.55, 0, 0, 28)
            InputBox.Position = UDim2.new(0.45, -12, 0.5, -14)
            InputBox.BackgroundColor3 = COLORS.TextboxBackground
            InputBox.Text = ""
            InputBox.PlaceholderText = placeholder or "Type here..."
            InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            InputBox.PlaceholderColor3 = COLORS.PlaceholderText
            InputBox.Font = Enum.Font.Gotham
            InputBox.TextSize = 14
            InputBox.ClipsDescendants = true
            InputBox.Parent = BoxFrame

            local BC = Instance.new("UICorner")
            BC.CornerRadius = UDim.new(0, 6)
            BC.Parent = InputBox

            InputBox.FocusLost:Connect(function(enterPressed)
                task.spawn(callback, InputBox.Text, enterPressed)
            end)
        end

        function SectionObj:MakeDropdown(label, options, callback)
            options = options or {}
            local Expanded = false
            local DropdownFrame = createBaseComponent(42)
            
            -- Set up dynamic height animation
            DropdownFrame.ClipsDescendants = true

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -40, 0, 42)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.Text = label .. " (Select...)"
            Title.TextColor3 = COLORS.MainText
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 15
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = DropdownFrame

            local Indicator = Instance.new("TextLabel")
            Indicator.Size = UDim2.new(0, 30, 0, 42)
            Indicator.Position = UDim2.new(1, -38, 0, 0)
            Indicator.Text = "▼"
            Indicator.TextColor3 = COLORS.DimText
            Indicator.Font = Enum.Font.GothamBold
            Indicator.TextSize = 13
            Indicator.BackgroundTransparency = 1
            Indicator.Parent = DropdownFrame

            local ItemHolder = Instance.new("Frame")
            ItemHolder.Size = UDim2.new(1, -24, 0, #options * 32) -- Adjust base size
            ItemHolder.Position = UDim2.new(0, 12, 0, 42)
            ItemHolder.BackgroundTransparency = 1
            ItemHolder.Parent = DropdownFrame

            local ItemLayout = Instance.new("UIListLayout")
            ItemLayout.Padding = UDim.new(0, 2)
            ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ItemLayout.Parent = ItemHolder

            local Trigger = Instance.new("TextButton")
            Trigger.Size = UDim2.new(1, 0, 0, 42)
            Trigger.BackgroundTransparency = 1
            Trigger.Text = ""
            Trigger.Parent = DropdownFrame

            local function refreshCanvasSize()
                local currentLayout = ContentContainer:FindFirstChildOfClass("UIListLayout")
                if currentLayout then
                    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, currentLayout.AbsoluteContentSize.Y + 15)
                end
            end

            for i, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 30)
                OptBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                OptBtn.Text = "  " .. tostring(opt)
                OptBtn.TextColor3 = COLORS.DimText
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 14
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.Parent = ItemHolder
                
                local OC = Instance.new("UICorner")
                OC.CornerRadius = UDim.new(0, 5)
                OC.Parent = OptBtn

                OptBtn.MouseButton1Click:Connect(function()
                    Title.Text = label .. " (" .. tostring(opt) .. ")"
                    Expanded = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -6, 0, 42)}):Play()
                    Indicator.Text = "▼"
                    task.wait(0.2)
                    refreshCanvasSize()
                    task.spawn(callback, opt)
                end)
            end

            Trigger.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                local targetHeight = Expanded and (42 + (#options * 32)) or 42
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

    -- Add Unload Button at bottom of MainFrame (protected)
    local UnloadBtnHolder = Instance.new("Frame")
    UnloadBtnHolder.Name = "UnloadBtnHolder"
    UnloadBtnHolder.Size = UDim2.new(1, 0, 0, 40)
    UnloadBtnHolder.Position = UDim2.new(0, 0, 1, -40)
    UnloadBtnHolder.BackgroundColor3 = COLORS.Background
    UnloadBtnHolder.BorderSizePixel = 0
    UnloadBtnHolder.Parent = MainFrame

    local UnloadCornerFix = Instance.new("UICorner")
    UnloadCornerFix.CornerRadius = UDim.new(0, 12)
    UnloadCornerFix.Parent = UnloadBtnHolder

    local UnloadCover = Instance.new("Frame")
    UnloadCover.Size = UDim2.new(1, 0, 0, 10)
    UnloadCover.Position = UDim2.new(0, 0, 0, 0)
    UnloadCover.BackgroundColor3 = COLORS.Background
    UnloadCover.BorderSizePixel = 0
    UnloadCover.Parent = UnloadBtnHolder

    local UnloadBtn = Instance.new("TextButton")
    UnloadBtn.Size = UDim2.new(0, 100, 0, 30)
    UnloadBtn.Position = UDim2.new(1, -115, 0.5, -15)
    UnloadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    UnloadBtn.Text = "Unload Hub"
    UnloadBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    UnloadBtn.Font = Enum.Font.GothamMedium
    UnloadBtn.TextSize = 13
    UnloadBtn.Parent = UnloadBtnHolder

    local UC = Instance.new("UICorner")
    UC.CornerRadius = UDim.new(0, 6)
    UC.Parent = UnloadBtn

    UnloadBtn.MouseEnter:Connect(function() TweenService:Create(UnloadBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 30, 30)}):Play() end)
    UnloadBtn.MouseLeave:Connect(function() TweenService:Create(UnloadBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play() end)

    UnloadBtn.MouseButton1Click:Connect(function()
        UI:Unload()
    end)

    return WindowObj
end

return UI
