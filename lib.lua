--[[
  ENEBRIUM LITE
  UI: GaySploits UI Library (lib.lua)
  Features: Aimbot, Triggerbot (mouse-over only), Silent Aim, ESP, Ambience/Fog, Skybox
  Updated: Custom RGB color picker, keybinds (any key, hold/toggle, M1 cancel)
]]

-- ═══════════════════════════════════════════════
--  GUARD
-- ═══════════════════════════════════════════════
if getgenv().EnebriumLiteLoaded then
    warn("[EnebriumLite] Already running.")
    return
end
getgenv().EnebriumLiteLoaded = true

-- ═══════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════
--  REMOTES
-- ═══════════════════════════════════════════════
local RemEvs  = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
local RemFns  = ReplicatedStorage:WaitForChild("RemoteFunctions", 5)
local BindFns = ReplicatedStorage:WaitForChild("BindableFunctions", 5)
local GetModel
if BindFns then
    GetModel = BindFns:FindFirstChild("GetModel")
end

-- ═══════════════════════════════════════════════
--  CONFIG
-- ═══════════════════════════════════════════════
local Config = {
    -- Aimbot
    AimbotEnabled      = false,
    AimbotFOV          = 250,
    AimbotSmoothing    = 0.4,
    AimPart            = "Head",
    AimbotMethod       = "CFrame",
    AimbotTargetMode   = "Center",
    PredictMovement    = true,
    PredictionMult     = 1.0,
    ShowFOVCircle      = true,
    FOVCircleColor     = Color3.fromRGB(255, 0, 0),
    FOVCircleThickness = 2,
    FOVCircleFilled    = false,
    FOVCircleOpacity   = 1.0,
    VisibleCheckAimbot = false,
    TeamCheckEnabled   = true,

    -- Keybinds
    AimbotActivationKey = Enum.KeyCode.RightShift,
    AimbotActivationMode = "Hold",
    CancelAimbotOnM1    = true,

    -- Triggerbot
    TriggerbotEnabled     = false,
    TriggerbotDelay       = 50,
    TriggerbotMaxDistance = 500,
    VisibleCheckTrigger   = false,

    -- Silent Aim
    SilentAimEnabled   = false,
    SilentAimMode      = "Target",
    SilentAimHitChance = 100,

    -- ESP
    ESPEnabled        = false,
    ShowBoxes         = true,
    ShowNames         = true,
    ShowDistance      = true,
    ShowHealthBar     = true,
    MaxDistance       = 5000,
    ESPVisibleColor   = Color3.fromRGB(0, 255, 0),
    ESPInvisibleColor = Color3.fromRGB(255, 0, 0),
    ESPTargetColor    = Color3.fromRGB(255, 255, 0),

    -- Ambience / Fog
    RemoveFogEnabled  = false,
    CustomFog         = false,
    FogEnd            = 100000,
    FogStart          = 0,
    FogColor          = Color3.fromRGB(255, 255, 255),
    RemoveHaze        = false,
    CustomBrightness  = false,
    BrightnessValue   = 2,

    -- Skybox
    SkyboxEnabled     = false,
    SkyboxId          = "",
}

local Originals = {
    FogEnd      = Lighting.FogEnd,
    FogStart    = Lighting.FogStart,
    FogColor    = Lighting.FogColor,
    Brightness  = Lighting.Brightness,
    AtmosHaze   = 0,
}

local State = {
    CurrentTarget    = nil,
    SilentAimTarget  = nil,
    Characters       = {},
    ESPObjects       = {},
    DeadPlayers      = {},
    Teammates        = {},
    LastTriggerShot  = 0,
    AimbotActive     = false,
    AimbotToggled    = false,
    M1Pressed        = false,
    ColorPickerOpen  = false,
}

-- ═══════════════════════════════════════════════
--  UI LIBRARY LOAD
-- ═══════════════════════════════════════════════
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Romxxr/gsui/refs/heads/main/lib.lua"
))()

-- ═══════════════════════════════════════════════
--  CUSTOM COLOR PICKER (RGB sliders)
-- ═══════════════════════════════════════════════
local ColorPickerFrame = nil
local function CreateColorPicker(onColorSelected)
    if ColorPickerFrame then return ColorPickerFrame end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnebriumColorPicker"
    screenGui.Parent = CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 180)
    frame.Position = UDim2.new(0.5, -130, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.05
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(80, 70, 50)

    local title = Instance.new("TextLabel")
    title.Text = "🎨  FOV Circle Color"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(212, 160, 50)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Parent = frame

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 50, 0, 50)
    preview.Position = UDim2.new(0, 15, 0, 40)
    preview.BackgroundColor3 = Config.FOVCircleColor
    preview.BorderSizePixel = 0
    preview.Parent = frame
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", preview).Color = Color3.fromRGB(150, 130, 80)

    local sliders = {
        R = { value = Config.FOVCircleColor.R * 255, label = "Red" },
        G = { value = Config.FOVCircleColor.G * 255, label = "Green" },
        B = { value = Config.FOVCircleColor.B * 255, label = "Blue" }
    }

    local function updateColor()
        local col = Color3.fromRGB(sliders.R.value, sliders.G.value, sliders.B.value)
        preview.BackgroundColor3 = col
        if onColorSelected then onColorSelected(col) end
    end

    local yStart = 40
    for _, channel in ipairs({"R", "G", "B"}) do
        local lbl = Instance.new("TextLabel")
        lbl.Text = channel .. ":"
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(220, 210, 190)
        lbl.Size = UDim2.new(0, 30, 0, 20)
        lbl.Position = UDim2.new(0, 80, 0, yStart)
        lbl.BackgroundTransparency = 1
        lbl.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0, 130, 0, 4)
        slider.Position = UDim2.new(0, 115, 0, yStart + 8)
        slider.BackgroundColor3 = Color3.fromRGB(50, 45, 35)
        slider.BorderSizePixel = 0
        slider.Parent = frame
        Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((sliders[channel].value / 255), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(212, 160, 50)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((sliders[channel].value / 255), -6, 0.5, -6)
        knob.BackgroundColor3 = Color3.fromRGB(240, 200, 80)
        knob.BorderSizePixel = 0
        knob.Parent = slider
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 6)

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Text = tostring(sliders[channel].value)
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextSize = 10
        valueLabel.TextColor3 = Color3.fromRGB(200, 190, 160)
        valueLabel.Size = UDim2.new(0, 30, 0, 16)
        valueLabel.Position = UDim2.new(0, 250, 0, yStart)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Parent = frame

        local dragging = false
        local function updateSlider(inputPos)
            local relX = math.clamp(inputPos.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
            local pct = relX / slider.AbsoluteSize.X
            local newVal = math.floor(pct * 255)
            sliders[channel].value = newVal
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -6, 0.5, -6)
            valueLabel.Text = tostring(newVal)
            updateColor()
        end

        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input.Position)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        yStart = yStart + 28
    end

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "Close"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.fromRGB(220, 200, 160)
    closeBtn.Size = UDim2.new(0, 80, 0, 28)
    closeBtn.Position = UDim2.new(0.5, -40, 1, -38)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 25)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        ColorPickerFrame = nil
        State.ColorPickerOpen = false
    end)

    ColorPickerFrame = screenGui
    return screenGui
end

-- ═══════════════════════════════════════════════
--  UTILITY
-- ═══════════════════════════════════════════════
local function WorldToScreen(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), on, v.Z
end

local function GetRootPart(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("Head")
        or char:FindFirstChildOfClass("BasePart")
end

local function GetHumanoid(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetTargetPart(char)
    if not char then return nil end
    local part = char:FindFirstChild(Config.AimPart)
    if part then return part end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function IsTeammate(player)
    return State.Teammates[player] or false
end

local function IsVisible(char, visPart)
    if not char or not visPart then return false end
    local camPos = Camera.CFrame.Position
    local tPos   = visPart.Position
    local dir    = (tPos - camPos).Unit
    local dist   = (tPos - camPos).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.RespectCanCollide = false
    local result = Workspace:Raycast(camPos, dir * dist, params)
    if result then
        return result.Instance and result.Instance:IsDescendantOf(char)
    end
    return true
end

-- Mouse over enemy (for triggerbot)
local function IsMouseOverEnemy()
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if result and result.Instance then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        if hitChar and hitChar:FindFirstChildOfClass("Humanoid") then
            for player, data in pairs(State.Characters) do
                if data.char == hitChar then
                    return player, data
                end
            end
        end
    end
    return nil, nil
end

local function GetBoundingBox(char)
    local rp = GetRootPart(char)
    if not rp then return nil end
    local cf = rp.CFrame
    local corners = {
        cf * CFrame.new(-1, 2.5, -1), cf * CFrame.new(1, 2.5, -1),
        cf * CFrame.new(-1, -2.5, -1), cf * CFrame.new(1, -2.5, -1),
        cf * CFrame.new(-1, 2.5, 1),  cf * CFrame.new(1, 2.5, 1),
        cf * CFrame.new(-1, -2.5, 1), cf * CFrame.new(1, -2.5, 1),
    }
    local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
    local any = false
    for _, corner in ipairs(corners) do
        local sp, on = WorldToScreen(corner.Position)
        if on then
            any = true
            if sp.X < minX then minX = sp.X end
            if sp.X > maxX then maxX = sp.X end
            if sp.Y < minY then minY = sp.Y end
            if sp.Y > maxY then maxY = sp.Y end
        end
    end
    if not any then return nil end
    return {
        TopLeft     = Vector2.new(minX, minY),
        TopRight    = Vector2.new(maxX, minY),
        BottomLeft  = Vector2.new(minX, maxY),
        BottomRight = Vector2.new(maxX, maxY),
        Width       = maxX - minX,
        Height      = maxY - minY,
    }
end

-- ═══════════════════════════════════════════════
--  CHARACTER CACHE
-- ═══════════════════════════════════════════════
local function UpdateCharacterCache()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if not char or not char.Parent then
                char = Workspace:FindFirstChild(player.Name)
                if char and not char:IsA("Model") then char = nil end
            end
            if GetModel and (not char or not char.Parent) then
                pcall(function()
                    local model = GetModel:Invoke(player)
                    if model and model:IsA("Model") then char = model end
                end)
            end
            if char and char.Parent then
                local hum  = GetHumanoid(char)
                local root = GetRootPart(char)
                if hum and root then
                    State.Characters[player] = {
                        char = char, hum = hum, root = root,
                        head = char:FindFirstChild("Head"),
                    }
                    State.DeadPlayers[player] = (hum.Health <= 0)
                else
                    State.Characters[player] = nil
                end
            else
                State.Characters[player] = nil
            end
        end
    end
end

local function UpdateTeammateCache()
    if not Config.TeamCheckEnabled then State.Teammates = {}; return end
    local newTeams = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            newTeams[player] = true
        elseif player.Team ~= nil and player.Team == LocalPlayer.Team then
            newTeams[player] = true
        else
            local data = State.Characters[player]
            local char = data and data.char or player.Character
            if char and (char:FindFirstChild("Dot") or char:FindFirstChild("Marker") or char:FindFirstChild("PartyMarker")) then
                newTeams[player] = true
            end
        end
    end
    State.Teammates = newTeams
end

spawn(function() while task.wait(1) do UpdateTeammateCache() end end)

local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(function() task.wait(0.5); UpdateCharacterCache() end)
end
for _, p in ipairs(Players:GetPlayers()) do OnPlayerAdded(p) end
Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    State.Characters[player]  = nil
    State.Teammates[player]   = nil
    State.DeadPlayers[player] = nil
end)

-- ═══════════════════════════════════════════════
--  KEYBIND LOGIC
-- ═══════════════════════════════════════════════
local function UpdateAimbotActive()
    if not Config.AimbotEnabled then
        State.AimbotActive = false
        return
    end
    if Config.CancelAimbotOnM1 and State.M1Pressed then
        State.AimbotActive = false
        return
    end
    local keyPressed = UserInputService:IsKeyDown(Config.AimbotActivationKey)
    if Config.AimbotActivationMode == "Hold" then
        State.AimbotActive = keyPressed
    else -- Toggle
        -- Toggling is handled in heartbeat edge detection
    end
end

local lastKeyState = false
RunService.Heartbeat:Connect(function()
    local current = UserInputService:IsKeyDown(Config.AimbotActivationKey)
    if Config.AimbotActivationMode == "Toggle" and current and not lastKeyState then
        State.AimbotToggled = not State.AimbotToggled
        State.AimbotActive = State.AimbotToggled
    end
    lastKeyState = current
    UpdateAimbotActive()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.M1Pressed = true
        UpdateAimbotActive()
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.M1Pressed = false
        UpdateAimbotActive()
    end
end)

-- ═══════════════════════════════════════════════
--  FOV CIRCLE
-- ═══════════════════════════════════════════════
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness    = Config.FOVCircleThickness
FOVCircle.NumSides     = 64
FOVCircle.Radius       = Config.AimbotFOV
FOVCircle.Color        = Config.FOVCircleColor
FOVCircle.Visible      = false
FOVCircle.Filled       = Config.FOVCircleFilled
FOVCircle.Transparency = 1 - Config.FOVCircleOpacity

-- ═══════════════════════════════════════════════
--  AIMBOT
-- ═══════════════════════════════════════════════
local function UpdateAimbot()
    if not Config.AimbotEnabled or not State.AimbotActive then
        State.CurrentTarget = nil
        return
    end
    local maxDist = Config.AimbotFOV
    local target  = nil
    local origin  = Config.AimbotTargetMode == "Mouse"
        and UserInputService:GetMouseLocation()
        or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for player, data in pairs(State.Characters) do
        if player ~= LocalPlayer and data.char and data.hum.Health > 0
            and not IsTeammate(player) and not State.DeadPlayers[player] then
            local aimPart = GetTargetPart(data.char)
            if aimPart then
                local passVis = not Config.VisibleCheckAimbot or IsVisible(data.char, aimPart)
                if passVis then
                    local pos, onScreen = WorldToScreen(aimPart.Position)
                    if onScreen then
                        local dist = (pos - origin).Magnitude
                        if dist < maxDist then
                            maxDist = dist
                            target = { player = player, part = aimPart }
                        end
                    end
                end
            end
        end
    end

    if target then
        State.CurrentTarget = target.player
        local startPos = Camera.CFrame.Position
        local predictedPos = target.part.Position
        if Config.PredictMovement then
            local d = State.Characters[target.player]
            if d and d.root then
                local vel = d.root.Velocity
                predictedPos = predictedPos + vel * ((target.part.Position - startPos).Magnitude / 2000) * Config.PredictionMult
            end
        end

        if Config.AimbotMethod == "Mouse" then
            local moveFunc = mousemoverel or mousemove_rel
            if moveFunc then
                local tPos, onScreen = WorldToScreen(predictedPos)
                if onScreen then
                    local delta = tPos - origin
                    local sensitivity = math.clamp(1.1 - Config.AimbotSmoothing, 0.05, 1)
                    moveFunc(math.floor(delta.X * sensitivity), math.floor(delta.Y * sensitivity))
                end
            else
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(startPos, predictedPos), Config.AimbotSmoothing)
            end
        else
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(startPos, predictedPos), Config.AimbotSmoothing)
        end
    else
        State.CurrentTarget = nil
    end
end

-- ═══════════════════════════════════════════════
--  TRIGGERBOT (mouse-over only)
-- ═══════════════════════════════════════════════
local function UpdateTriggerbot()
    if not Config.TriggerbotEnabled then return end
    local now = tick()
    if now - State.LastTriggerShot < (Config.TriggerbotDelay / 1000) then return end

    local targetPlayer, targetData = IsMouseOverEnemy()
    if not targetPlayer then return end
    if targetPlayer == LocalPlayer or targetData.hum.Health <= 0 then return end
    if IsTeammate(targetPlayer) or State.DeadPlayers[targetPlayer] then return end

    local dist = (targetData.root.Position - Camera.CFrame.Position).Magnitude
    if dist > Config.TriggerbotMaxDistance then return end
    if Config.VisibleCheckTrigger and not IsVisible(targetData.char, targetData.root) then return end

    State.LastTriggerShot = now
    if mouse1click then
        mouse1click()
    else
        local mp = UserInputService:GetMouseLocation()
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(mp.X, mp.Y, 0, true, game, 0)
        task.wait(0.01)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(mp.X, mp.Y, 0, false, game, 0)
    end
end

-- ═══════════════════════════════════════════════
--  SILENT AIM
-- ═══════════════════════════════════════════════
local function UpdateSilentAimTarget()
    if not Config.SilentAimEnabled then State.SilentAimTarget = nil; return end
    local maxDist = Config.AimbotFOV
    local target = nil
    local origin = Config.AimbotTargetMode == "Mouse"
        and UserInputService:GetMouseLocation()
        or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for player, data in pairs(State.Characters) do
        if player ~= LocalPlayer and data.hum.Health > 0
            and not IsTeammate(player) and not State.DeadPlayers[player] then
            local aimPart = data.char:FindFirstChild(Config.AimPart) or data.root
            if aimPart then
                local pos, onScreen = WorldToScreen(data.root.Position)
                if onScreen then
                    local dist = (pos - origin).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        target = player
                    end
                end
            end
        end
    end
    State.SilentAimTarget = target
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" then
        if (self.Name == "CreateBullet" or self.Name == "NewBullet" or self.Name == "Fire")
            and Config.SilentAimEnabled and State.SilentAimTarget then
            if math.random(1, 100) > Config.SilentAimHitChance then
                return oldNamecall(self, table.unpack(args))
            end
            local d = State.Characters[State.SilentAimTarget]
            if d then
                local aimPart = d.char:FindFirstChild(Config.AimPart) or d.char:FindFirstChild("Head") or d.root
                if aimPart then
                    for i = 1, #args do
                        if typeof(args[i]) == "CFrame" then
                            args[i] = CFrame.new(args[i].Position, aimPart.Position)
                            break
                        end
                    end
                end
            end
            return oldNamecall(self, table.unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ═══════════════════════════════════════════════
--  ESP
-- ═══════════════════════════════════════════════
local ESP = {}
ESP.__index = ESP

function ESP.new(player)
    local self = setmetatable({}, ESP)
    self.Player = player
    self.Drawings = {}
    self.Drawings.Box = {}
    for i = 1, 4 do
        local l = Drawing.new("Line")
        l.Thickness = 1
        l.Color = Config.ESPVisibleColor
        l.Visible = false
        self.Drawings.Box[i] = l
    end
    local tName = Drawing.new("Text")
    tName.Size = 16; tName.Center = true; tName.Outline = true
    tName.Color = Color3.fromRGB(255,255,255); tName.Visible = false
    self.Drawings.Name = tName
    local tDist = Drawing.new("Text")
    tDist.Size = 14; tDist.Center = true; tDist.Outline = true
    tDist.Color = Color3.fromRGB(200,200,200); tDist.Visible = false
    self.Drawings.Distance = tDist
    local hBg = Drawing.new("Line")
    hBg.Thickness = 3; hBg.Color = Color3.fromRGB(50,50,50); hBg.Visible = false
    self.Drawings.HealthBg = hBg
    local hFg = Drawing.new("Line")
    hFg.Thickness = 3; hFg.Visible = false
    self.Drawings.HealthFg = hFg
    return self
end

function ESP:Update()
    if not Config.ESPEnabled then self:Hide(); return end
    if self.Player == LocalPlayer then self:Hide(); return end
    local d = State.Characters[self.Player]
    if not d or not d.char.Parent or not d.root.Parent then self:Hide(); return end
    local dist = (d.root.Position - Camera.CFrame.Position).Magnitude
    if dist > Config.MaxDistance then self:Hide(); return end
    local box = GetBoundingBox(d.char)
    if not box then self:Hide(); return end
    local visible = IsVisible(d.char, d.head or d.root)
    local targeted = (self.Player == State.CurrentTarget or self.Player == State.SilentAimTarget)
    local boxColor = targeted and Config.ESPTargetColor or (visible and Config.ESPVisibleColor or Config.ESPInvisibleColor)
    if Config.ShowBoxes then
        local b = self.Drawings.Box
        b[1].From = box.TopLeft; b[1].To = box.TopRight; b[1].Color = boxColor; b[1].Visible = true
        b[2].From = box.TopRight; b[2].To = box.BottomRight; b[2].Color = boxColor; b[2].Visible = true
        b[3].From = box.BottomRight; b[3].To = box.BottomLeft; b[3].Color = boxColor; b[3].Visible = true
        b[4].From = box.BottomLeft; b[4].To = box.TopLeft; b[4].Color = boxColor; b[4].Visible = true
    else
        for _, l in ipairs(self.Drawings.Box) do l.Visible = false end
    end
    if Config.ShowNames then
        self.Drawings.Name.Text = self.Player.Name
        self.Drawings.Name.Position = Vector2.new(box.TopLeft.X + box.Width/2, box.TopLeft.Y - 18)
        self.Drawings.Name.Visible = true
    else
        self.Drawings.Name.Visible = false
    end
    if Config.ShowDistance then
        self.Drawings.Distance.Text = math.floor(dist) .. "m"
        self.Drawings.Distance.Position = Vector2.new(box.TopLeft.X + box.Width/2, box.BottomLeft.Y + 5)
        self.Drawings.Distance.Visible = true
    else
        self.Drawings.Distance.Visible = false
    end
    if Config.ShowHealthBar then
        local hp = d.hum.Health / math.max(d.hum.MaxHealth, 1)
        self.Drawings.HealthBg.From = Vector2.new(box.TopLeft.X - 6, box.TopLeft.Y)
        self.Drawings.HealthBg.To = Vector2.new(box.TopLeft.X - 6, box.BottomLeft.Y)
        self.Drawings.HealthBg.Visible = true
        self.Drawings.HealthFg.From = Vector2.new(box.TopLeft.X - 6, box.BottomLeft.Y)
        self.Drawings.HealthFg.To = Vector2.new(box.TopLeft.X - 6, box.BottomLeft.Y - box.Height * hp)
        self.Drawings.HealthFg.Color = Color3.new(1 - hp, hp, 0)
        self.Drawings.HealthFg.Visible = true
    else
        self.Drawings.HealthBg.Visible = false
        self.Drawings.HealthFg.Visible = false
    end
end

function ESP:Hide()
    for _, g in pairs(self.Drawings) do
        if type(g) == "table" then for _, d in ipairs(g) do d.Visible = false end
        else g.Visible = false end
    end
end

function ESP:Remove()
    for _, g in pairs(self.Drawings) do
        if type(g) == "table" then for _, d in ipairs(g) do d:Remove() end
        else g:Remove() end
    end
    self.Drawings = {}
end

local function AddESP(player)
    if player == LocalPlayer then return end
    if not State.ESPObjects[player] then
        State.ESPObjects[player] = ESP.new(player)
    end
end
local function RemoveESP(player)
    if State.ESPObjects[player] then
        State.ESPObjects[player]:Remove()
        State.ESPObjects[player] = nil
    end
end
for _, p in ipairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ═══════════════════════════════════════════════
--  SKYBOX & ATMOSPHERE
-- ═══════════════════════════════════════════════
local function ApplySkybox()
    if not Config.SkyboxEnabled or Config.SkyboxId == "" then return end
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then sky = Instance.new("Sky", Lighting) end
    local id = Config.SkyboxId
    sky.SkyboxBk = id; sky.SkyboxDn = id; sky.SkyboxFt = id; sky.SkyboxLf = id; sky.SkyboxRt = id; sky.SkyboxUp = id
end
local function RemoveSkybox()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky then sky:Destroy() end
end
local function GetAtmos() return Lighting:FindFirstChildOfClass("Atmosphere") end

-- ═══════════════════════════════════════════════
--  BUILD UI
-- ═══════════════════════════════════════════════
local Window = Library:MakeWindow({
    Title = "ENEBRIUM LITE",
    Subtitle = "aimbot · triggerbot (mouse-over) · esp · ambience"
})

-- AIMBOT TAB
local AimTab = Window:MakeTab("Aimbot")
local AimSection = AimTab:MakeSection("Aimbot")
AimSection:MakeToggle("Enable Aimbot", Config.AimbotEnabled, function(s)
    Config.AimbotEnabled = s
    FOVCircle.Visible = s and Config.ShowFOVCircle
    if not s then State.AimbotActive = false end
end)
AimSection:MakeToggle("Visible Check", Config.VisibleCheckAimbot, function(s) Config.VisibleCheckAimbot = s end)
AimSection:MakeToggle("Team Check", Config.TeamCheckEnabled, function(s) Config.TeamCheckEnabled = s end)
AimSection:MakeToggle("Predict Movement", Config.PredictMovement, function(s) Config.PredictMovement = s end)
AimSection:MakeSlider("FOV Radius", 10, 800, Config.AimbotFOV, function(v) Config.AimbotFOV = v; FOVCircle.Radius = v end)
AimSection:MakeSlider("Smoothing", 1, 100, math.floor(Config.AimbotSmoothing * 100), function(v) Config.AimbotSmoothing = v / 100 end)
AimSection:MakeDropdown("Aim Part", {"Head","HumanoidRootPart","Torso"}, function(v) Config.AimPart = v end)
AimSection:MakeDropdown("Method", {"CFrame","Mouse"}, function(v) Config.AimbotMethod = v end)
AimSection:MakeDropdown("Target Mode", {"Center","Mouse"}, function(v) Config.AimbotTargetMode = v end)

-- Keybinds
local KeybindSection = AimTab:MakeSection("Aimbot Activation")
local keyOptions = {"RightShift","LeftShift","RightAlt","LeftAlt","RightControl","LeftControl","MouseButton2","MouseButton3","Q","E","R","F","G","X","C","V"}
KeybindSection:MakeDropdown("Activation Key", keyOptions, function(v)
    Config.AimbotActivationKey = Enum.KeyCode[v]
end, "RightShift")
KeybindSection:MakeDropdown("Activation Mode", {"Hold","Toggle"}, function(v)
    Config.AimbotActivationMode = v
    State.AimbotToggled = false
    UpdateAimbotActive()
end, "Hold")
KeybindSection:MakeToggle("Cancel on M1", Config.CancelAimbotOnM1, function(s)
    Config.CancelAimbotOnM1 = s
    UpdateAimbotActive()
end)

-- FOV Circle
local FOVSection = AimTab:MakeSection("FOV Circle")
FOVSection:MakeToggle("Show FOV Circle", Config.ShowFOVCircle, function(s)
    Config.ShowFOVCircle = s
    FOVCircle.Visible = s and Config.AimbotEnabled
end)
FOVSection:MakeToggle("Filled", Config.FOVCircleFilled, function(s) Config.FOVCircleFilled = s; FOVCircle.Filled = s end)
FOVSection:MakeSlider("Thickness", 1, 10, Config.FOVCircleThickness, function(v) Config.FOVCircleThickness = v; FOVCircle.Thickness = v end)
FOVSection:MakeSlider("Opacity (%)", 1, 100, math.floor(Config.FOVCircleOpacity * 100), function(v)
    Config.FOVCircleOpacity = v / 100
    FOVCircle.Transparency = 1 - (v / 100)
end)
FOVSection:MakeButton("Open Color Picker", function()
    if State.ColorPickerOpen then return end
    State.ColorPickerOpen = true
    CreateColorPicker(function(col)
        Config.FOVCircleColor = col
        FOVCircle.Color = col
    end)
end)

-- Triggerbot
local TrigSection = AimTab:MakeSection("Triggerbot")
TrigSection:MakeToggle("Enable Triggerbot", Config.TriggerbotEnabled, function(s) Config.TriggerbotEnabled = s end)
TrigSection:MakeToggle("Visible Check", Config.VisibleCheckTrigger, function(s) Config.VisibleCheckTrigger = s end)
TrigSection:MakeSlider("Delay (ms)", 0, 500, Config.TriggerbotDelay, function(v) Config.TriggerbotDelay = v end)
TrigSection:MakeSlider("Max Distance", 10, 5000, Config.TriggerbotMaxDistance, function(v) Config.TriggerbotMaxDistance = v end)

-- Silent Aim
local SilentSection = AimTab:MakeSection("Silent Aim")
SilentSection:MakeToggle("Enable Silent Aim", Config.SilentAimEnabled, function(s)
    Config.SilentAimEnabled = s
    if not s then State.SilentAimTarget = nil end
end)
SilentSection:MakeDropdown("Mode", {"Target","Reticle"}, function(v) Config.SilentAimMode = v end)
SilentSection:MakeSlider("Hit Chance (%)", 1, 100, Config.SilentAimHitChance, function(v) Config.SilentAimHitChance = v end)

-- ESP TAB
local ESPTab = Window:MakeTab("ESP")
local ESPSection = ESPTab:MakeSection("ESP")
ESPSection:MakeToggle("Enable ESP", Config.ESPEnabled, function(s)
    Config.ESPEnabled = s
    if not s then for _, esp in pairs(State.ESPObjects) do esp:Hide() end end
end)
ESPSection:MakeToggle("Show Boxes", Config.ShowBoxes, function(s) Config.ShowBoxes = s end)
ESPSection:MakeToggle("Show Names", Config.ShowNames, function(s) Config.ShowNames = s end)
ESPSection:MakeToggle("Show Distance", Config.ShowDistance, function(s) Config.ShowDistance = s end)
ESPSection:MakeToggle("Show Health Bar", Config.ShowHealthBar, function(s) Config.ShowHealthBar = s end)
ESPSection:MakeSlider("Max Distance", 100, 10000, Config.MaxDistance, function(v) Config.MaxDistance = v end)

-- AMBIENCE TAB
local AmbTab = Window:MakeTab("Ambience")
local FogSection = AmbTab:MakeSection("Fog & Haze")
FogSection:MakeToggle("Remove Fog", Config.RemoveFogEnabled, function(s)
    Config.RemoveFogEnabled = s
    if not s then
        Lighting.FogEnd, Lighting.FogStart, Lighting.FogColor = Originals.FogEnd, Originals.FogStart, Originals.FogColor
    end
end)
FogSection:MakeToggle("Custom Fog", Config.CustomFog, function(s) Config.CustomFog = s end)
FogSection:MakeSlider("Fog End", 100, 100000, Config.FogEnd, function(v) Config.FogEnd = v end)
FogSection:MakeToggle("Remove Atmosphere Haze", Config.RemoveHaze, function(s)
    Config.RemoveHaze = s
    local atmos = GetAtmos()
    if atmos then
        if s then Originals.AtmosHaze = atmos.Haze; atmos.Haze = 0
        else atmos.Haze = Originals.AtmosHaze end
    end
end)

local LightSection = AmbTab:MakeSection("Lighting")
LightSection:MakeToggle("Custom Brightness", Config.CustomBrightness, function(s)
    Config.CustomBrightness = s
    if not s then Lighting.Brightness = Originals.Brightness end
end)
LightSection:MakeSlider("Brightness (x10)", 0, 100, math.floor(Config.BrightnessValue * 10), function(v) Config.BrightnessValue = v / 10 end)

local SkySection = AmbTab:MakeSection("Skybox")
SkySection:MakeToggle("Enable Custom Skybox", Config.SkyboxEnabled, function(s)
    Config.SkyboxEnabled = s
    if s then ApplySkybox() else RemoveSkybox() end
end)
SkySection:MakeTextbox("Skybox Asset ID", "rbxassetid://...", function(v)
    Config.SkyboxId = v
    if Config.SkyboxEnabled then ApplySkybox() end
end)
SkySection:MakeButton("Apply Skybox", function()
    if Config.SkyboxEnabled then ApplySkybox() else Library:Notify({Title="Skybox", Content="Enable skybox first."}) end
end)
SkySection:MakeButton("Remove Skybox", function()
    RemoveSkybox()
    Config.SkyboxEnabled = false
    Library:Notify({Title="Skybox", Content="Skybox removed."})
end)

-- ═══════════════════════════════════════════════
--  HEARTBEAT & RENDER
-- ═══════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    UpdateCharacterCache()

    if Config.RemoveFogEnabled then
        Lighting.FogEnd, Lighting.FogStart, Lighting.FogColor = 9e9, 0, Color3.new(1,1,1)
    elseif Config.CustomFog then
        Lighting.FogEnd, Lighting.FogStart, Lighting.FogColor = Config.FogEnd, Config.FogStart, Config.FogColor
    end
    if Config.CustomBrightness then Lighting.Brightness = Config.BrightnessValue end

    UpdateSilentAimTarget()
    UpdateTriggerbot()
end)

RunService.RenderStepped:Connect(function()
    local origin = Config.AimbotTargetMode == "Mouse"
        and UserInputService:GetMouseLocation()
        or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    FOVCircle.Position = origin
    FOVCircle.Radius = Config.AimbotFOV
    FOVCircle.Color = Config.FOVCircleColor
    FOVCircle.Thickness = Config.FOVCircleThickness
    FOVCircle.Filled = Config.FOVCircleFilled
    FOVCircle.Transparency = 1 - Config.FOVCircleOpacity
    FOVCircle.Visible = Config.ShowFOVCircle and Config.AimbotEnabled

    UpdateAimbot()

    if Config.ESPEnabled then
        for player, esp in pairs(State.ESPObjects) do
            if player and player.Parent then esp:Update() else RemoveESP(player) end
        end
    end
end)

print("[EnebriumLite] Loaded. Configure keybinds & enjoy!")
