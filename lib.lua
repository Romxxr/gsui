--[[
  ENEBRIUM LITE
  UI: GaySploits UI Library (lib.lua)
  Features: Aimbot, Triggerbot, Silent Aim, ESP, Ambience/Fog, Skybox
  All non-listed features stripped.
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
    AimbotMethod       = "CFrame",    -- "CFrame" or "Mouse"
    AimbotTargetMode   = "Center",    -- "Center" or "Mouse"
    PredictMovement    = true,
    PredictionMult     = 1.0,
    ShowFOVCircle      = true,
    FOVCircleColor     = Color3.fromRGB(255, 0, 0),
    ShowTargetLine     = false,
    VisibleCheckAimbot = false,
    TeamCheckEnabled   = true,

    -- Triggerbot
    TriggerbotEnabled     = false,
    TriggerbotDelay       = 50,
    TriggerbotFOV         = 50,
    TriggerbotMaxDistance = 500,
    VisibleCheckTrigger   = false,

    -- Silent Aim
    SilentAimEnabled  = false,
    SilentAimMode     = "Target",  -- "Reticle" or "Target"
    SilentAimHitChance = 100,       -- 1–100 %

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
    RemoveHaze        = false,     -- sets Atmosphere.Haze = 0
    CustomBrightness  = false,
    BrightnessValue   = 2,

    -- Skybox
    SkyboxEnabled     = false,
    SkyboxId          = "",        -- asset id base string, e.g. "rbxassetid://12345"
}

local Originals = {
    FogEnd      = Lighting.FogEnd,
    FogStart    = Lighting.FogStart,
    FogColor    = Lighting.FogColor,
    Brightness  = Lighting.Brightness,
    AtmosHaze   = 0,
}

local State = {
    RMBHeld          = false,
    CurrentTarget    = nil,
    SilentAimTarget  = nil,
    Characters       = {},
    ESPObjects       = {},
    DeadPlayers      = {},
    Teammates        = {},
    LastTriggerShot  = 0,
}

-- ═══════════════════════════════════════════════
--  UI LIBRARY LOAD
-- ═══════════════════════════════════════════════
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Romxxr/gsui/refs/heads/main/lib.lua"
))()

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
                    if hum.Health <= 0 then
                        State.DeadPlayers[player] = true
                    else
                        State.DeadPlayers[player] = false
                    end
                else
                    State.Characters[player] = nil
                end
            else
                State.Characters[player] = nil
            end
        end
    end
end

-- Teammate cache (team tag / dot proxy for DZC)
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

-- Player add/remove
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
--  FOV CIRCLE (Drawing)
-- ═══════════════════════════════════════════════
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness   = 2
FOVCircle.NumSides    = 64
FOVCircle.Radius      = Config.AimbotFOV
FOVCircle.Color       = Config.FOVCircleColor
FOVCircle.Visible     = false
FOVCircle.Filled      = false
FOVCircle.Transparency = 1

-- ═══════════════════════════════════════════════
--  AIMBOT
-- ═══════════════════════════════════════════════
local function UpdateAimbot()
    if not Config.AimbotEnabled or not State.RMBHeld then
        State.CurrentTarget = nil
        return
    end
    local maxDist = Config.AimbotFOV
    local target  = nil
    local origin  = Config.AimbotTargetMode == "Mouse"
        and UserInputService:GetMouseLocation()
        or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for player, data in pairs(State.Characters) do
        if player ~= LocalPlayer
        and data.char and data.hum.Health > 0
        and not IsTeammate(player)
        and not State.DeadPlayers[player]
        then
            local aimPart = GetTargetPart(data.char)
            if aimPart then
                local passVis = not Config.VisibleCheckAimbot or IsVisible(data.char, aimPart)
                if passVis then
                    local pos, onScreen = WorldToScreen(aimPart.Position)
                    if onScreen then
                        local dist = (pos - origin).Magnitude
                        if dist < maxDist then
                            maxDist = dist
                            target  = { player = player, part = aimPart }
                        end
                    end
                end
            end
        end
    end

    if target then
        State.CurrentTarget = target.player
        local startPos     = Camera.CFrame.Position
        local predictedPos = target.part.Position

        if Config.PredictMovement then
            local d = State.Characters[target.player]
            if d and d.root then
                local vel = d.root.Velocity
                predictedPos = predictedPos
                    + vel * ((target.part.Position - startPos).Magnitude / 2000)
                    * Config.PredictionMult
            end
        end

        if Config.AimbotMethod == "Mouse" then
            local moveFunc = mousemoverel or mousemove_rel
            if moveFunc then
                local tPos, onScreen = WorldToScreen(predictedPos)
                if onScreen then
                    local delta       = tPos - origin
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
--  TRIGGERBOT
-- ═══════════════════════════════════════════════
local function UpdateTriggerbot()
    if not Config.TriggerbotEnabled then return end
    local now = tick()
    if now - State.LastTriggerShot < (Config.TriggerbotDelay / 1000) then return end

    -- Find closest target within FOV
    local origin   = UserInputService:GetMouseLocation()
    local bestDist = Config.TriggerbotFOV
    local bestData = nil

    for player, data in pairs(State.Characters) do
        if player ~= LocalPlayer
        and data.hum.Health > 0
        and not IsTeammate(player)
        and not State.DeadPlayers[player]
        then
            local dist3D = (data.root.Position - Camera.CFrame.Position).Magnitude
            if dist3D <= Config.TriggerbotMaxDistance then
                local passVis = not Config.VisibleCheckTrigger or IsVisible(data.char, data.root)
                if passVis then
                    local pos, onScreen = WorldToScreen(data.root.Position)
                    if onScreen then
                        local screenDist = (pos - origin).Magnitude
                        if screenDist < bestDist then
                            bestDist = screenDist
                            bestData = data
                        end
                    end
                end
            end
        end
    end

    if bestData then
        State.LastTriggerShot = now
        if mouse1click then
            mouse1click()
        else
            local mp = UserInputService:GetMouseLocation()
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(mp.X, mp.Y, 0, true,  game, 0)
            task.wait(0.01)
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(mp.X, mp.Y, 0, false, game, 0)
        end
    end
end

-- ═══════════════════════════════════════════════
--  SILENT AIM
-- ═══════════════════════════════════════════════
local function UpdateSilentAimTarget()
    if not Config.SilentAimEnabled then State.SilentAimTarget = nil; return end
    local maxDist = Config.AimbotFOV
    local target  = nil
    local origin  = Config.AimbotTargetMode == "Mouse"
        and UserInputService:GetMouseLocation()
        or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for player, data in pairs(State.Characters) do
        if player ~= LocalPlayer
        and data.hum.Health > 0
        and not IsTeammate(player)
        and not State.DeadPlayers[player]
        then
            local aimPart = data.char:FindFirstChild(Config.AimPart) or data.root
            if aimPart then
                local pos, onScreen = WorldToScreen(data.root.Position)
                if onScreen then
                    local dist = (pos - origin).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        target  = player
                    end
                end
            end
        end
    end
    State.SilentAimTarget = target
end

-- Namecall hook for silent aim redirect
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args   = { ... }
    local method = getnamecallmethod()

    if not checkcaller() and method == "FireServer" then
        if (self.Name == "CreateBullet" or self.Name == "NewBullet" or self.Name == "Fire")
        and Config.SilentAimEnabled
        and State.SilentAimTarget
        then
            -- Hit chance gate
            if math.random(1, 100) > Config.SilentAimHitChance then
                return oldNamecall(self, table.unpack(args))
            end

            local d = State.Characters[State.SilentAimTarget]
            if d then
                local aimPart = d.char:FindFirstChild(Config.AimPart)
                    or d.char:FindFirstChild("Head")
                    or d.root
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
--  ESP CLASS
-- ═══════════════════════════════════════════════
local ESP = {}
ESP.__index = ESP

function ESP.new(player)
    local self = setmetatable({}, ESP)
    self.Player   = player
    self.Drawings = {}

    self.Drawings.Box = {}
    for i = 1, 4 do
        local l = Drawing.new("Line")
        l.Thickness = 1
        l.Color     = Config.ESPVisibleColor
        l.Visible   = false
        self.Drawings.Box[i] = l
    end

    local tName = Drawing.new("Text")
    tName.Size    = 16; tName.Center = true; tName.Outline = true
    tName.Color   = Color3.fromRGB(255, 255, 255); tName.Visible = false
    self.Drawings.Name = tName

    local tDist = Drawing.new("Text")
    tDist.Size    = 14; tDist.Center = true; tDist.Outline = true
    tDist.Color   = Color3.fromRGB(200, 200, 200); tDist.Visible = false
    self.Drawings.Distance = tDist

    local hBg = Drawing.new("Line")
    hBg.Thickness = 3; hBg.Color = Color3.fromRGB(50, 50, 50); hBg.Visible = false
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
    local boxColor = targeted and Config.ESPTargetColor
        or (visible and Config.ESPVisibleColor or Config.ESPInvisibleColor)

    if Config.ShowBoxes then
        local b = self.Drawings.Box
        b[1].From = box.TopLeft;     b[1].To = box.TopRight;    b[1].Color = boxColor; b[1].Visible = true
        b[2].From = box.TopRight;    b[2].To = box.BottomRight; b[2].Color = boxColor; b[2].Visible = true
        b[3].From = box.BottomRight; b[3].To = box.BottomLeft;  b[3].Color = boxColor; b[3].Visible = true
        b[4].From = box.BottomLeft;  b[4].To = box.TopLeft;     b[4].Color = boxColor; b[4].Visible = true
    else
        for _, l in ipairs(self.Drawings.Box) do l.Visible = false end
    end

    if Config.ShowNames then
        self.Drawings.Name.Text     = self.Player.Name
        self.Drawings.Name.Position = Vector2.new(box.TopLeft.X + box.Width / 2, box.TopLeft.Y - 18)
        self.Drawings.Name.Visible  = true
    else
        self.Drawings.Name.Visible = false
    end

    if Config.ShowDistance then
        self.Drawings.Distance.Text     = math.floor(dist) .. "m"
        self.Drawings.Distance.Position = Vector2.new(box.TopLeft.X + box.Width / 2, box.BottomLeft.Y + 5)
        self.Drawings.Distance.Visible  = true
    else
        self.Drawings.Distance.Visible = false
    end

    if Config.ShowHealthBar then
        local hp = d.hum.Health / math.max(d.hum.MaxHealth, 1)
        self.Drawings.HealthBg.From    = Vector2.new(box.TopLeft.X - 6, box.TopLeft.Y)
        self.Drawings.HealthBg.To      = Vector2.new(box.TopLeft.X - 6, box.BottomLeft.Y)
        self.Drawings.HealthBg.Visible = true
        self.Drawings.HealthFg.From    = Vector2.new(box.TopLeft.X - 6, box.BottomLeft.Y)
        self.Drawings.HealthFg.To      = Vector2.new(box.TopLeft.X - 6, box.BottomLeft.Y - box.Height * hp)
        self.Drawings.HealthFg.Color   = Color3.new(1 - hp, hp, 0)
        self.Drawings.HealthFg.Visible = true
    else
        self.Drawings.HealthBg.Visible = false
        self.Drawings.HealthFg.Visible = false
    end
end

function ESP:Hide()
    for _, g in pairs(self.Drawings) do
        if type(g) == "table" then
            for _, d in ipairs(g) do d.Visible = false end
        else
            g.Visible = false
        end
    end
end

function ESP:Remove()
    for _, g in pairs(self.Drawings) do
        if type(g) == "table" then
            for _, d in ipairs(g) do d:Remove() end
        else
            g:Remove()
        end
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
--  SKYBOX
-- ═══════════════════════════════════════════════
local function ApplySkybox()
    if not Config.SkyboxEnabled or Config.SkyboxId == "" then return end
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky", Lighting)
    end
    local id = Config.SkyboxId
    sky.SkyboxBk = id; sky.SkyboxDn = id
    sky.SkyboxFt = id; sky.SkyboxLf = id
    sky.SkyboxRt = id; sky.SkyboxUp = id
end
local function RemoveSkybox()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky then sky:Destroy() end
end

-- ═══════════════════════════════════════════════
--  ATMOSPHERE UTIL
-- ═══════════════════════════════════════════════
local function GetAtmos()
    return Lighting:FindFirstChildOfClass("Atmosphere")
end

-- ═══════════════════════════════════════════════
--  INPUT
-- ═══════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        State.RMBHeld = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        State.RMBHeld = false
    end
end)

-- ═══════════════════════════════════════════════
--  BUILD UI
-- ═══════════════════════════════════════════════
local Window = Library:MakeWindow({
    Title    = "ENEBRIUM LITE",
    Subtitle = "aimbot · esp · ambience",
})

-- ── AIMBOT TAB ──────────────────────────────────
local AimTab = Window:MakeTab("Aimbot")

local AimSection = AimTab:MakeSection("Aimbot")
AimSection
    :MakeToggle("Enable Aimbot", Config.AimbotEnabled, function(s)
        Config.AimbotEnabled = s
        FOVCircle.Visible = s and Config.ShowFOVCircle
    end)
    :MakeToggle("Visible Check", Config.VisibleCheckAimbot, function(s)
        Config.VisibleCheckAimbot = s
    end)
    :MakeToggle("Team Check", Config.TeamCheckEnabled, function(s)
        Config.TeamCheckEnabled = s
    end)
    :MakeToggle("Show FOV Circle", Config.ShowFOVCircle, function(s)
        Config.ShowFOVCircle = s
        FOVCircle.Visible = s and Config.AimbotEnabled
    end)
    :MakeToggle("Predict Movement", Config.PredictMovement, function(s)
        Config.PredictMovement = s
    end)
    :MakeSlider("FOV Radius", 50, 600, Config.AimbotFOV, function(v)
        Config.AimbotFOV = v
        FOVCircle.Radius = v
    end)
    :MakeSlider("Smoothing (x10)", 1, 10, math.floor(Config.AimbotSmoothing * 10), function(v)
        Config.AimbotSmoothing = v / 10
    end)
    :MakeDropdown("Aim Part", { "Head", "HumanoidRootPart", "Torso" }, function(v)
        Config.AimPart = v
    end)
    :MakeDropdown("Method", { "CFrame", "Mouse" }, function(v)
        Config.AimbotMethod = v
    end)
    :MakeDropdown("Target Mode", { "Center", "Mouse" }, function(v)
        Config.AimbotTargetMode = v
    end)

-- Triggerbot sub-section
local TrigSection = AimTab:MakeSection("Triggerbot")
TrigSection
    :MakeToggle("Enable Triggerbot", Config.TriggerbotEnabled, function(s)
        Config.TriggerbotEnabled = s
    end)
    :MakeToggle("Visible Check", Config.VisibleCheckTrigger, function(s)
        Config.VisibleCheckTrigger = s
    end)
    :MakeSlider("Delay (ms)", 0, 500, Config.TriggerbotDelay, function(v)
        Config.TriggerbotDelay = v
    end)
    :MakeSlider("Trigger FOV", 1, 500, Config.TriggerbotFOV, function(v)
        Config.TriggerbotFOV = v
    end)
    :MakeSlider("Max Distance", 10, 5000, Config.TriggerbotMaxDistance, function(v)
        Config.TriggerbotMaxDistance = v
    end)

-- Silent Aim sub-section
local SilentSection = AimTab:MakeSection("Silent Aim")
SilentSection
    :MakeToggle("Enable Silent Aim", Config.SilentAimEnabled, function(s)
        Config.SilentAimEnabled = s
        if not s then State.SilentAimTarget = nil end
    end)
    :MakeDropdown("Mode", { "Target", "Reticle" }, function(v)
        Config.SilentAimMode = v
    end)
    :MakeSlider("Hit Chance (%)", 1, 100, Config.SilentAimHitChance, function(v)
        Config.SilentAimHitChance = v
    end)

-- ── ESP TAB ─────────────────────────────────────
local ESPTab = Window:MakeTab("ESP")

local ESPSection = ESPTab:MakeSection("ESP")
ESPSection
    :MakeToggle("Enable ESP", Config.ESPEnabled, function(s)
        Config.ESPEnabled = s
        if not s then
            for _, esp in pairs(State.ESPObjects) do esp:Hide() end
        end
    end)
    :MakeToggle("Show Boxes", Config.ShowBoxes, function(s)
        Config.ShowBoxes = s
    end)
    :MakeToggle("Show Names", Config.ShowNames, function(s)
        Config.ShowNames = s
    end)
    :MakeToggle("Show Distance", Config.ShowDistance, function(s)
        Config.ShowDistance = s
    end)
    :MakeToggle("Show Health Bar", Config.ShowHealthBar, function(s)
        Config.ShowHealthBar = s
    end)
    :MakeSlider("Max Distance", 100, 10000, Config.MaxDistance, function(v)
        Config.MaxDistance = v
    end)

-- ── AMBIENCE TAB ────────────────────────────────
local AmbTab = Window:MakeTab("Ambience")

local FogSection = AmbTab:MakeSection("Fog & Haze")
FogSection
    :MakeToggle("Remove Fog", Config.RemoveFogEnabled, function(s)
        Config.RemoveFogEnabled = s
        if not s then
            Lighting.FogEnd   = Originals.FogEnd
            Lighting.FogStart = Originals.FogStart
            Lighting.FogColor = Originals.FogColor
        end
    end)
    :MakeToggle("Custom Fog", Config.CustomFog, function(s)
        Config.CustomFog = s
    end)
    :MakeSlider("Fog End", 100, 100000, Config.FogEnd, function(v)
        Config.FogEnd = v
    end)
    :MakeToggle("Remove Atmosphere Haze", Config.RemoveHaze, function(s)
        Config.RemoveHaze = s
        local atmos = GetAtmos()
        if atmos then
            if s then
                Originals.AtmosHaze = atmos.Haze
                atmos.Haze = 0
            else
                atmos.Haze = Originals.AtmosHaze
            end
        end
    end)

local LightSection = AmbTab:MakeSection("Lighting")
LightSection
    :MakeToggle("Custom Brightness", Config.CustomBrightness, function(s)
        Config.CustomBrightness = s
        if not s then Lighting.Brightness = Originals.Brightness end
    end)
    :MakeSlider("Brightness (x10)", 0, 100, math.floor(Config.BrightnessValue * 10), function(v)
        Config.BrightnessValue = v / 10
    end)

local SkySection = AmbTab:MakeSection("Skybox")
SkySection
    :MakeToggle("Enable Custom Skybox", Config.SkyboxEnabled, function(s)
        Config.SkyboxEnabled = s
        if s then ApplySkybox() else RemoveSkybox() end
    end)
    :MakeTextbox("Skybox Asset ID", "rbxassetid://...", function(v)
        Config.SkyboxId = v
        if Config.SkyboxEnabled then ApplySkybox() end
    end)
    :MakeButton("Apply Skybox", function()
        if Config.SkyboxEnabled then ApplySkybox()
        else Library:Notify({ Title = "Skybox", Content = "Enable skybox first." }) end
    end)
    :MakeButton("Remove Skybox", function()
        RemoveSkybox()
        Config.SkyboxEnabled = false
        Library:Notify({ Title = "Skybox", Content = "Skybox removed." })
    end)

-- ═══════════════════════════════════════════════
--  HEARTBEAT
-- ═══════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    UpdateCharacterCache()

    if Config.RemoveFogEnabled then
        Lighting.FogEnd   = 9e9
        Lighting.FogStart = 0
        Lighting.FogColor = Color3.new(1, 1, 1)
    elseif Config.CustomFog then
        Lighting.FogEnd   = Config.FogEnd
        Lighting.FogStart = Config.FogStart
        Lighting.FogColor = Config.FogColor
    end

    if Config.CustomBrightness then
        Lighting.Brightness = Config.BrightnessValue
    end

    UpdateSilentAimTarget()
    UpdateTriggerbot()
end)

-- ═══════════════════════════════════════════════
--  RENDER STEPPED
-- ═══════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    local origin = Config.AimbotTargetMode == "Mouse"
        and UserInputService:GetMouseLocation()
        or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    FOVCircle.Position = origin
    FOVCircle.Radius   = Config.AimbotFOV
    FOVCircle.Color    = Config.FOVCircleColor
    FOVCircle.Visible  = Config.ShowFOVCircle and Config.AimbotEnabled

    UpdateAimbot()

    if Config.ESPEnabled then
        for player, esp in pairs(State.ESPObjects) do
            if player and player.Parent then
                esp:Update()
            else
                RemoveESP(player)
            end
        end
    end
end)

print("[EnebriumLite] Loaded. Toggle: RightShift")
