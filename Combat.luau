-- ============================================
-- Simple Combat GUI for Executor
-- Mobile Ready + Wall Check + ESP + Aim Sync
-- Keybind: RightShift (Desktop)
-- ============================================

-- Cleanup dari run sebelumnya
if _G.CombatGUICleanup then pcall(_G.CombatGUICleanup); _G.CombatGUICleanup = nil end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========== CONFIG ==========
local Config = {
    AutoAttack = false,
    Hitbox = false,
    AimAssist = false,
    ESP = false,
    WallCheck = true,
    TeamCheck = true,
    AutoAttackSpeed = 0.1,
    HitboxSize = 15,
    AimFOV = 200,       -- pixel (visual lock area)
    AimRange = 150,     -- studs (3D jarak)
    AimSmoothness = 0.2,
}

-- Tracking cleanup (untuk run ulang)
local CleanupFns = {}
local function TrackCleanup(fn) table.insert(CleanupFns, fn) end
_G.CombatGUICleanup = function() for _, fn in ipairs(CleanupFns) do pcall(fn) end end

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
Main.Size = UDim2.new(0, 260, 0, 470)
Main.Position = UDim2.new(0.5, -130, 0.5, -235)
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

-- ========== TOGGLE (Touch Friendly) ==========
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

-- ========== SLIDER (Touch Friendly) ==========
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
CreateSlider("Hitbox Size", 5, 40, 15, function(v) Config.HitboxSize = v, 0 end)
CreateToggle("Aim Assist", false, function(v)
    Config.AimAssist = v
    if FOVCircle then FOVCircle.Visible = v end
end)
CreateSlider("Aim FOV (px)", 50, 500, 200, function(v) Config.AimFOV = v end, 0)
CreateSlider("Aim Range (studs)", 10, 500, 150, function(v) Config.AimRange = v end, 0)
CreateSlider("Aim Smoothness", 0.01, 1, 0.2, function(v) Config.AimSmoothness = v end)
CreateToggle("Wall Check", true, function(v) Config.WallCheck = v end)
CreateToggle("Team Check", true, function(v) Config.TeamCheck = v end)
CreateToggle("ESP (Line + HP)", false, function(v) Config.ESP = v end)

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

-- ========== MOBILE FLOATING TOGGLE BUTTON ==========
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
        btnDrag = true
        btnWasDragged = false
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
        if not btnWasDragged then
            Main.Visible = not Main.Visible
        end
    end
end)

-- ========== HELPER: TEAM CHECK ==========
local function IsEnemy(plr)
    if plr == LocalPlayer then return false end
    if not Config.TeamCheck then return true end
    if plr.Team == nil or LocalPlayer.Team == nil then return true end
    return plr.Team ~= LocalPlayer.Team
end

-- ========== HELPER: WALL CHECK ==========
local function WallCheck(targetHRP)
    if not Config.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {Camera}
    if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
    if targetHRP.Parent then table.insert(ignore, targetHRP.Parent) end
    params.FilterDescendantsInstances = ignore
    
    local origin = Camera.CFrame.Position
    local dir = targetHRP.Position - origin
    local result = Workspace:Raycast(origin, dir, params)
    return result == nil
end

-- ========== HELPER: DISTANCE CHECK ==========
local function GetLocalHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ========== AIM TARGET SELECTION ==========
GetAimTarget = function()
    local localHRP = GetLocalHRP()
    if not localHRP then return nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, shortest = nil, Config.AimFOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if IsEnemy(plr) then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist3D = (hrp.Position - localHRP.Position).Magnitude
                if dist3D <= Config.AimRange then
                    if WallCheck(hrp) then
                        local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local dist2D = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if dist2D < shortest then
                                shortest = dist2D
                                closest = hrp
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ========== FOV CIRCLE ==========
local FOVCircle
if DrawingEnabled then
    local ok, circle = pcall(function() return Drawing.new("Circle") end)
    if ok and circle then
        FOVCircle = circle
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

-- ========== AIM ASSIST ==========
RunService.RenderStepped:Connect(function(dt)
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Config.AimFOV
        FOVCircle.Visible = Config.AimAssist
    end
    
    if Config.AimAssist then
        local target = GetAimTarget()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            -- Smoothness: nilai kecil = snap instan, besar = smooth/lambat
            local alpha = math.clamp(dt / math.max(Config.AimSmoothness, 0.001), 0.01, 1)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
        end
    end
end)

-- ========== AUTO ATTACK (SYNC DENGAN AIM ASSIST) ==========
task.spawn(function()
    while task.wait(Config.AutoAttackSpeed) do
        if Config.AutoAttack then
            local shouldAttack = true
            -- Jika aim assist ON, harus ada target dulu
            if Config.AimAssist then
                shouldAttack = GetAimTarget() ~= nil
            end
            if shouldAttack then
                local char = LocalPlayer.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                end
            end
        end
    end
end)

-- ========== HITBOX EXPANDER ==========
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

RunService.Heartbeat:Connect(function()
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

-- ========== ESP (LINE + HEALTH) ==========
local ESPLines, ESPHealths = {}, {}

if DrawingEnabled then
    local function SetupESP(plr)
        if plr == LocalPlayer or ESPLines[plr] then return end
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1.5
        line.Color = Color3.fromRGB(255, 60, 60)
        line.Transparency = 1
        line.From = Vector2.zero
        line.To = Vector2.zero
        
        local hp = Drawing.new("Text")
        hp.Visible = false
        hp.Center = true
        hp.Outline = true
        hp.Size = 14
        hp.Color = Color3.fromRGB(255, 255, 255)
        hp.Font = 2 -- Drawing.Fonts.UI
        
        ESPLines[plr] = line
        ESPHealths[plr] = hp
        TrackCleanup(function()
            pcall(function() line:Remove() end)
            pcall(function() hp:Remove() end)
        end)
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do SetupESP(plr) end
    Players.PlayerAdded:Connect(SetupESP)
    Players.PlayerRemoving:Connect(function(plr)
        if ESPLines[plr] then ESPLines[plr]:Remove(); ESPLines[plr] = nil end
        if ESPHealths[plr] then ESPHealths[plr]:Remove(); ESPHealths[plr] = nil end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not Config.ESP then
            for _, line in pairs(ESPLines) do line.Visible = false end
            for _, hp in pairs(ESPHealths) do hp.Visible = false end
            return
        end
        
        -- Titik awal: badan player
        local localHRP = GetLocalHRP()
        local fromPos
        if localHRP then
            local sp = Camera:WorldToViewportPoint(localHRP.Position)
            fromPos = Vector2.new(sp.X, sp.Y)
        else
            fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        end
        
        for _, plr in ipairs(Players:GetPlayers()) do
            local line = ESPLines[plr]
            local hp = ESPHealths[plr]
            if line and hp then
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        line.From = fromPos
                        line.To = Vector2.new(sp.X, sp.Y)
                        line.Color = IsEnemy(plr)
                            and Color3.fromRGB(255, 60, 60)
                            or Color3.fromRGB(60, 255, 100)
                        line.Visible = true
                        
                        -- Health indicator di atas head
                        local head = char:FindFirstChild("Head") or hrp
                        local hsp = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
                        hp.Position = Vector2.new(hsp.X, hsp.Y)
                        hp.Text = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
                        local hpRatio = hum.Health / math.max(hum.MaxHealth, 1)
                        if hpRatio > 0.6 then
                            hp.Color = Color3.fromRGB(80, 255, 120)
                        elseif hpRatio > 0.3 then
                            hp.Color = Color3.fromRGB(255, 200, 60)
                        else
                            hp.Color = Color3.fromRGB(255, 70, 70)
                        end
                        hp.Visible = true
                    else
                        line.Visible = false
                        hp.Visible = false
                    end
                else
                    line.Visible = false
                    hp.Visible = false
                end
            end
        end
    end)
else
    warn("[CombatGUI] Drawing API tidak tersedia, ESP disabled.")
end

-- ========== KEYBIND (DESKTOP) ==========
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

print("[CombatGUI] Loaded! Mobile: tap tombol 'CB' di kiri atas.")
