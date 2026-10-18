-- ============================================
-- Simple Combat GUI - Full Edition
-- Mobile Ready + Wall Check + ESP Box/Glow + Aim Part + Hit Effect
-- ============================================

-- Cleanup dari run sebelumnya
local CleanupFns = {}
_G.CombatGUICleanup = function()
    for _, fn in ipairs(CleanupFns) do pcall(fn) end
end
if _G.CombatGUICleanup and _G._CombatGUIRan then pcall(_G.CombatGUICleanup) end
_G._CombatGUIRan = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function TrackCleanup(fn) table.insert(CleanupFns, fn) end

-- ========== CONFIG ==========
local Config = {
    AutoAttack = false,
    Hitbox = false,
    AimAssist = false,
    ESP = false,
    ESPBox = true,
    ESPGlow = false,
    ESPTeamCheck = true,
    HitEffect = false,
    WallCheck = true,
    TeamCheck = true,
    AutoAttackSpeed = 0.1,
    HitboxSize = 15,
    AimFOV = 200,
    AimRange = 150,
    AimSmoothness = 0.2,
    AimPart = "Head", -- "Head" | "Chest" | "Body"
}

-- Hapus GUI lama
local oldGui = game.CoreGui:FindFirstChild("SimpleCombatGUI")
if oldGui then oldGui:Destroy() end

-- ========== CEK DRAWING API ==========
local DrawingEnabled = pcall(function()
    local t = Drawing.new("Text"); t:Remove()
end)

-- ========== GUI SETUP ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleCombatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 540)
Main.Position = UDim2.new(0.5, -130, 0.5, -270)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(50, 50, 60)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Simple Combat"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = TitleBar

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -45)
Content.Position = UDim2.new(0, 5, 0, 40)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 5)
Padding.PaddingRight = UDim.new(0, 5)
Padding.PaddingTop = UDim.new(0, 3)
Padding.Parent = Content

-- ========== TOGGLE ==========
local function CreateToggle(text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = btn

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 38, 0, 18)
    switch.Position = UDim2.new(1, -48, 0.5, 0)
    switch.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
    switch.Parent = btn
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switch, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }):Play()
        callback(state)
    end)
end

-- ========== SLIDER ==========
local function CreateSlider(text, min, max, default, callback, decimals)
    decimals = decimals or 2
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. string.format("%."..decimals.."f", default)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 32)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * rel
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = text .. ": " .. string.format("%."..decimals.."f", value)
        callback(value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ========== CYCLE BUTTON (untuk Aim Part) ==========
local function CreateCycle(text, options, default, callback)
    local idx = 1
    for i, v in ipairs(options) do if v == default then idx = i break end end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = btn

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.45, -20, 1, 0)
    valLbl.Position = UDim2.new(0.55, 10, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = options[idx]
    valLbl.TextColor3 = Color3.fromRGB(0, 170, 255)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.Parent = btn

    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        valLbl.Text = options[idx]
        callback(options[idx])
    end)
end

-- Forward declarations
local restoreHitboxes
local GetAimTarget

-- ========== BUILD GUI ==========
CreateToggle("Auto Attack", false, function(v) Config.AutoAttack = v end)
CreateSlider("Attack Delay (s)", 0.02, 1, 0.1, function(v) Config.AutoAttackSpeed = v end)
CreateToggle("Hitbox Expander", false, function(v)
    Config.Hitbox = v
    if not v and restoreHitboxes then restoreHitboxes() end
end)
CreateSlider("Hitbox Size", 5, 40, 15, function(v) Config.HitboxSize = v end, 0)
CreateToggle("Aim Assist", false, function(v) Config.AimAssist = v end)
CreateSlider("Aim FOV (px)", 50, 500, 200, function(v) Config.AimFOV = v end, 0)
CreateSlider("Aim Range (studs)", 10, 500, 150, function(v) Config.AimRange = v end, 0)
CreateSlider("Aim Smoothness", 0.01, 1, 0.2, function(v) Config.AimSmoothness = v end)
CreateCycle("Aim Part", {"Head", "Chest", "Body"}, "Head", function(v) Config.AimPart = v end)
CreateToggle("Wall Check", true, function(v) Config.WallCheck = v end)
CreateToggle("Team Check", true, function(v) Config.TeamCheck = v end)
CreateToggle("ESP", false, function(v) Config.ESP = v end)
CreateToggle("ESP Box (Filled)", true, function(v) Config.ESPBox = v end)
CreateToggle("ESP Glow", false, function(v) Config.ESPGlow = v end)
CreateToggle("ESP Team Check", true, function(v) Config.ESPTeamCheck = v end)
CreateToggle("Hit Effect (Crosshair)", false, function(v)
    Config.HitEffect = v
    if CrosshairParts then
        for _, d in pairs(CrosshairParts) do d.Visible = v end
    end
end)

-- ========== DRAG TITLE BAR ==========
local dragToggle, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = false
    end
end)

-- ========== MOBILE FLOATING BUTTON ==========
local MobileBtn = Instance.new("TextButton")
MobileBtn.Size = UDim2.new(0, 45, 0, 45)
MobileBtn.Position = UDim2.new(0, 15, 0, 15)
MobileBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
MobileBtn.Text = "CB"
MobileBtn.TextColor3 = Color3.new(1, 1, 1)
MobileBtn.Font = Enum.Font.GothamBold
MobileBtn.TextSize = 14
MobileBtn.AutoButtonColor = false
MobileBtn.Parent = ScreenGui
Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(1, 0)

local btnDrag, btnStart, btnStartPos, btnWasDragged = false, nil, nil, false
MobileBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        btnDrag = true; btnWasDragged = false
        btnStart = input.Position
        btnStartPos = MobileBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDrag and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnStart
        if delta.Magnitude > 5 then btnWasDragged = true end
        MobileBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
                                        btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if btnDrag and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
        btnDrag = false
        if not btnWasDragged then Main.Visible = not Main.Visible end
    end
end)

-- ========== HELPERS ==========
local function IsEnemy(plr)
    if plr == LocalPlayer then return false end
    if not Config.TeamCheck then return true end
    if plr.Team == nil or LocalPlayer.Team == nil then return true end
    return plr.Team ~= LocalPlayer.Team
end

local function WallCheck(targetHRP)
    if not Config.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {Camera}
    if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
    if targetHRP.Parent then table.insert(ignore, targetHRP.Parent) end
    params.FilterDescendantsInstances = ignore
    local origin = Camera.CFrame.Position
    local result = Workspace:Raycast(origin, targetHRP.Position - origin, params)
    return result == nil
end

local function GetLocalHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetAimPosition(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    if Config.AimPart == "Head" then
        local head = char:FindFirstChild("Head")
        return head and head.Position or (hrp.Position + Vector3.new(0, 1.5, 0))
    elseif Config.AimPart == "Chest" then
        return hrp.Position + Vector3.new(0, 0.8, 0)
    else
        return hrp.Position
    end
end

-- ========== AIM TARGET ==========
GetAimTarget = function()
    local localHRP = GetLocalHRP()
    if not localHRP then return nil, nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestHRP, bestPos, shortest = nil, nil, Config.AimFOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if IsEnemy(plr) then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if (hrp.Position - localHRP.Position).Magnitude <= Config.AimRange then
                    if WallCheck(hrp) then
                        local ap = GetAimPosition(char)
                        if ap then
                            local sp, onScreen = Camera:WorldToViewportPoint(ap)
                            if onScreen then
                                local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if d2 < shortest then
                                    shortest = d2
                                    bestHRP = hrp
                                    bestPos = ap
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestHRP, bestPos
end

-- ========== FOV CIRCLE ==========
local FOVCircle
if DrawingEnabled then
    local ok, c = pcall(function() return Drawing.new("Circle") end)
    if ok and c then
        FOVCircle = c
        FOVCircle.Thickness = 1
        FOVCircle.NumSides = 60
        FOVCircle.Radius = Config.AimFOV
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(0, 170, 255)
        FOVCircle.Transparency = 0.6
        FOVCircle.Visible = false
        TrackCleanup(function() FOVCircle:Remove() end)
    end
end

-- ========== CROSSHAIR ==========
local CrosshairParts = nil
if DrawingEnabled then
    CrosshairParts = {}
    for _, key in ipairs({"top", "bottom", "left", "right"}) do
        local ln = Drawing.new("Line")
        ln.Thickness = 2
        ln.Color = Color3.fromRGB(255, 255, 255)
        ln.Transparency = 1
        ln.Visible = false
        CrosshairParts[key] = ln
        TrackCleanup(function() ln:Remove() end)
    end
end

-- ========== HIT EFFECT ==========
local ActiveEffects = {}
local function SpawnHitEffect()
    if not DrawingEnabled or not Config.HitEffect then return end
    if #ActiveEffects >= 8 then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local rings = {}
    local colors = {
        Color3.fromRGB(255, 100, 100),
        Color3.fromRGB(255, 220, 100),
        Color3.fromRGB(120, 200, 255),
    }
    for i = 1, 3 do
        local ring = Drawing.new("Circle")
        ring.NumSides = 40
        ring.Filled = false
        ring.Thickness = 2
        ring.Radius = 5
        ring.Color = colors[i]
        ring.Transparency = 0
        ring.Position = center
        ring.Visible = true
        table.insert(rings, { d = ring, delay = (i - 1) * 0.05 })
    end
    table.insert(ActiveEffects, { t = 0, dur = 0.35, rings = rings })
end

-- ========== AIM ASSIST ==========
local CurrentAimTarget, CurrentAimPos = nil, nil
local aimConn = RunService.RenderStepped:Connect(function(dt)
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Config.AimFOV
        FOVCircle.Visible = Config.AimAssist
    end
    if Config.AimAssist then
        local t, ap = GetAimTarget()
        CurrentAimTarget, CurrentAimPos = t, ap
        if t and ap then
            local targetCF = CFrame.new(Camera.CFrame.Position, ap)
            local alpha = math.clamp(dt / math.max(Config.AimSmoothness, 0.001), 0.01, 1)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
        end
    else
        CurrentAimTarget, CurrentAimPos = nil, nil
    end
end)
TrackCleanup(function() aimConn:Disconnect() end)

-- ========== CROSSHAIR + HIT EFFECT RENDER ==========
local fxConn = RunService.RenderStepped:Connect(function(dt)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Crosshair
    if CrosshairParts then
        local show = Config.HitEffect
        local locked = CurrentAimTarget ~= nil
        local color = locked and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 255, 255)
        local len, gap = 7, 4
        if show then
            CrosshairParts.top.From = Vector2.new(center.X, center.Y - gap)
            CrosshairParts.top.To = Vector2.new(center.X, center.Y - gap - len)
            CrosshairParts.bottom.From = Vector2.new(center.X, center.Y + gap)
            CrosshairParts.bottom.To = Vector2.new(center.X, center.Y + gap + len)
            CrosshairParts.left.From = Vector2.new(center.X - gap, center.Y)
            CrosshairParts.left.To = Vector2.new(center.X - gap - len, center.Y)
            CrosshairParts.right.From = Vector2.new(center.X + gap, center.Y)
            CrosshairParts.right.To = Vector2.new(center.X + gap + len, center.Y)
            for _, ln in pairs(CrosshairParts) do
                ln.Color = color
                ln.Visible = true
            end
        else
            for _, ln in pairs(CrosshairParts) do ln.Visible = false end
        end
    end

    -- Hit effects
    for i = #ActiveEffects, 1, -1 do
        local eff = ActiveEffects[i]
        eff.t = eff.t + dt
        for _, r in ipairs(eff.rings) do
            local rt = eff.t - r.delay
            if rt < 0 or rt >= eff.dur then
                r.d.Transparency = 0
            else
                local p = rt / eff.dur
                r.d.Position = center
                r.d.Radius = 8 + p * 55
                r.d.Thickness = math.max(0.5, 2 - p * 1.5)
                r.d.Transparency = 1 - p
            end
        end
        if eff.t >= eff.dur + 0.15 then
            for _, r in ipairs(eff.rings) do pcall(function() r.d:Remove() end) end
            table.remove(ActiveEffects, i)
        end
    end
end)
TrackCleanup(function() fxConn:Disconnect() end)

-- ========== AUTO ATTACK (SYNC AIM) ==========
task.spawn(function()
    while task.wait(Config.AutoAttackSpeed) do
        if Config.AutoAttack then
            local should = true
            if Config.AimAssist then
                should = CurrentAimTarget ~= nil
            end
            if should then
                local char = LocalPlayer.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                    if Config.HitEffect and Config.AimAssist and CurrentAimTarget then
                        SpawnHitEffect()
                    end
                end
            end
        end
    end
end)

-- ========== HITBOX ==========
local originals = {}
restoreHitboxes = function()
    for char, orig in pairs(originals) do
        if char and char.Parent then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = orig.Size
                hrp.Transparency = orig.Transparency
                hrp.CanCollide = orig.CanCollide
            end
        end
    end
    originals = {}
end

local hbConn = RunService.Heartbeat:Connect(function()
    if not Config.Hitbox then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not originals[plr.Character] then
                    originals[plr.Character] = {
                        Size = hrp.Size, Transparency = hrp.Transparency, CanCollide = hrp.CanCollide,
                    }
                end
                hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                hrp.Transparency = 0.5
                hrp.CanCollide = false
            end
        end
    end
end)
TrackCleanup(function() hbConn:Disconnect() end)

-- ========== ESP ==========
local ESPData = {}

local function SetupESP(plr)
    if plr == LocalPlayer or ESPData[plr] or not DrawingEnabled then return end
    local data = {}
    data.lineGlow = Drawing.new("Line")
    data.line = Drawing.new("Line")
    data.boxFill = Drawing.new("Square")
    data.boxGlow = Drawing.new("Square")
    data.boxOutline = Drawing.new("Square")
    data.hp = Drawing.new("Text")

    data.lineGlow.Thickness = 5
    data.lineGlow.Transparency = 0.35
    data.lineGlow.Visible = false

    data.line.Thickness = 1.5
    data.line.Transparency = 1
    data.line.Visible = false

    data.boxFill.Filled = true
    data.boxFill.Thickness = 1
    data.boxFill.Transparency = 0.25
    data.boxFill.Visible = false

    data.boxGlow.Filled = false
    data.boxGlow.Thickness = 5
    data.boxGlow.Transparency = 0.3
    data.boxGlow.Visible = false

    data.boxOutline.Filled = false
    data.boxOutline.Thickness = 1
    data.boxOutline.Transparency = 1
    data.boxOutline.Visible = false

    data.hp.Center = true
    data.hp.Outline = true
    data.hp.Size = 14
    data.hp.Font = 2
    data.hp.Color = Color3.new(1, 1, 1)
    data.hp.Visible = false

    ESPData[plr] = data
    TrackCleanup(function()
        for _, d in pairs(data) do pcall(function() d:Remove() end) end
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do SetupESP(plr) end
Players.PlayerAdded:Connect(SetupESP)
TrackCleanup(function()
    local c = Players.PlayerRemoving:Connect(function(plr)
        local d = ESPData[plr]
        if d then
            for _, obj in pairs(d) do pcall(function() obj:Remove() end) end
            ESPData[plr] = nil
        end
    end)
    TrackCleanup(function() c:Disconnect() end)
end)

local function GetBoxScreenPositions(char, hrp)
    local head = char:FindFirstChild("Head") or hrp
    local topPos = Vector3.new(hrp.Position.X, head.Position.Y + head.Size.Y/2 + 0.3, hrp.Position.Z)
    local botPos = Vector3.new(hrp.Position.X, hrp.Position.Y - hrp.Size.Y/2 - 2.8, hrp.Position.Z)
    local headSP, headOn = Camera:WorldToViewportPoint(topPos)
    local footSP, footOn = Camera:WorldToViewportPoint(botPos)
    if not (headOn or footOn) then return nil end
    local height = math.abs(footSP.Y - headSP.Y)
    if height < 5 then return nil end
    local width = height * 0.55
    local cx = (headSP.X + footSP.X) / 2
    local topY = math.min(headSP.Y, footSP.Y)
    local botY = math.max(headSP.Y, footSP.Y)
    return Vector2.new(cx - width/2, topY), Vector2.new(cx + width/2, botY)
end

local espConn = RunService.RenderStepped:Connect(function()
    if not DrawingEnabled then return end

    -- Hide all if ESP off
    if not Config.ESP then
        for _, data in pairs(ESPData) do
            for _, d in pairs(data) do d.Visible = false end
        end
        return
    end

    local localHRP = GetLocalHRP()
    if not localHRP then
        for _, data in pairs(ESPData) do
            for _, d in pairs(data) do d.Visible = false end
        end
        return
    end

    local localSP = Camera:WorldToViewportPoint(localHRP.Position)
    local fromPos = Vector2.new(localSP.X, localSP.Y)

    for plr, data in pairs(ESPData) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        local skip = false
        if not (hrp and hum and hum.Health > 0) then skip = true end
        if Config.ESPTeamCheck and not IsEnemy(plr) then skip = true end

        if skip then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end

        local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end

        -- Check "in aim range" (distance + wall check + is enemy)
        local dist = (hrp.Position - localHRP.Position).Magnitude
        local inRange = IsEnemy(plr) and dist <= Config.AimRange and WallCheck(hrp)
        local color = inRange and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 255, 100)

        -- Line
        data.line.From = fromPos
        data.line.To = Vector2.new(sp.X, sp.Y)
        data.line.Color = color
        data.line.Visible = true

        if Config.ESPGlow then
            data.lineGlow.From = fromPos
            data.lineGlow.To = Vector2.new(sp.X, sp.Y)
            data.lineGlow.Color = color
            data.lineGlow.Visible = true
        else
            data.lineGlow.Visible = false
        end

        -- Box
        local tl, br = GetBoxScreenPositions(char, hrp)
        if tl and br and Config.ESPBox then
            data.boxFill.Position = tl
            data.boxFill.Size = br - tl
            data.boxFill.Color = color
            data.boxFill.Visible = true

            data.boxOutline.Position = tl
            data.boxOutline.Size = br - tl
            data.boxOutline.Color = color
            data.boxOutline.Visible = true

            if Config.ESPGlow then
                data.boxGlow.Position = tl
                data.boxGlow.Size = br - tl
                data.boxGlow.Color = color
                data.boxGlow.Visible = true
            else
                data.boxGlow.Visible = false
            end
        else
            data.boxFill.Visible = false
            data.boxOutline.Visible = false
            data.boxGlow.Visible = false
        end

        -- Health indicator di atas box
        local hsp, hOn = Camera:WorldToViewportPoint(
            hrp.Position + Vector3.new(0, (hrp.Size.Y/2) + 3, 0)
        )
        if hOn then
            data.hp.Position = Vector2.new(hsp.X, hsp.Y)
            data.hp.Text = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
            local ratio = hum.Health / math.max(hum.MaxHealth, 1)
            if ratio > 0.6 then
                data.hp.Color = Color3.fromRGB(80, 255, 120)
            elseif ratio > 0.3 then
                data.hp.Color = Color3.fromRGB(255, 200, 60)
            else
                data.hp.Color = Color3.fromRGB(255, 70, 70)
            end
            data.hp.Visible = true
        else
            data.hp.Visible = false
        end
    end
end)
TrackCleanup(function() espConn:Disconnect() end)

-- ========== KEYBIND DESKTOP ==========
local kbConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)
TrackCleanup(function() kbConn:Disconnect() end)

-- Cleanup GUI on re-execute
TrackCleanup(function() if ScreenGui then ScreenGui:Destroy() end end)

print("[CombatGUI] Loaded! Tap 'CB' di kiri atas (mobile) atau RightShift (desktop).")
