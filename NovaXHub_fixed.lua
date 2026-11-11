--!nonstrict
-- NovaXHub v5.4 | Nova Island UI (glass white + Full Glass Mode)
-- Update: shared ESP/FOV color, simplified prediction, vehicle-aware wall check,
-- camera + character aim mode, configurable floating quick-toggle dock.
-- v5.4: Aim Close Priority, Wall Lock Grace, Wall Check multi-point, Save/Load Configuration.
-- Target Lock: ESP target yang sedang di-lock aim assist berubah warna (RGB terpisah dari
-- ESP Color) + animasi lock-on (corner bracket menyempit, pulse halus).

local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local RS          = game:GetService("RunService")
local TS          = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PGui   = LP:WaitForChild("PlayerGui")

-- Anti double-execute
if _G.NovaXHub_Running and _G.NovaXHub_Cleanup then
    pcall(_G.NovaXHub_Cleanup)
    warn("[NovaXHub] Script lama di-cleanup otomatis")
end
_G.NovaXHub_Running = true

-- ========== THEME ==========
-- UI = kaca putih + outline hitam (Ink). Amber/Rose/Violet/Dim/Success
-- sengaja dipertahankan karena dipakai ESP & FOV di dunia game, bukan UI.
local T = {
    -- UI glass
    Glass   = Color3.fromRGB(255, 255, 255),
    Frost   = Color3.fromRGB(226, 231, 241),
    Ink     = Color3.fromRGB(14, 14, 18),
    InkDim  = Color3.fromRGB(88, 90, 102),
    Line    = Color3.fromRGB(14, 14, 18),
    Off     = Color3.fromRGB(207, 211, 220),
    Text    = Color3.fromRGB(14, 14, 18),
    Danger  = Color3.fromRGB(214, 48, 64),
    -- warna dunia game (ESP / FOV / prediksi)
    Amber   = Color3.fromRGB(255, 190, 82),
    Rose    = Color3.fromRGB(255, 92, 130),
    Violet  = Color3.fromRGB(139, 108, 255),
    Dim     = Color3.fromRGB(152, 146, 178),
    Success = Color3.fromRGB(80, 220, 150),
}
local WHITE = Color3.new(1, 1, 1)

-- ========== HELPERS ==========
local function tween(o, props, time, style, dir)
    local t = TS:Create(o, TweenInfo.new(
        time or 0.2,
        style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out
    ), props)
    t:Play()
    return t
end

local function new(class, props, parent)
    local o = Instance.new(class)
    if o:IsA("GuiObject") then o.BorderSizePixel = 0 end
    if o:IsA("GuiButton") then o.AutoButtonColor = false end
    if o:IsA("TextLabel") or o:IsA("TextButton") then
        o.Font = Enum.Font.GothamMedium
        o.TextColor3 = T.Text
        o.TextSize = 13
    end
    if props then
        for k, v in pairs(props) do o[k] = v end
    end
    if parent then o.Parent = parent end
    return o
end

local function newLabel(parent, props)
    props.BackgroundTransparency = 1
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    return new("TextLabel", props, parent)
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function gradient(p, seq, rot)
    local g = Instance.new("UIGradient")
    g.Color = seq
    g.Rotation = rot or 0
    g.Parent = p
    return g
end

local function stroke(p, color, thick, transp)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color or T.Line
    s.Thickness = thick or 1
    s.Transparency = transp or 0
    s.Parent = p
    return s
end

local function padding(p, l, t, r, b)
    local u = Instance.new("UIPadding")
    u.PaddingLeft = UDim.new(0, l or 0)
    u.PaddingTop = UDim.new(0, t or 0)
    u.PaddingRight = UDim.new(0, r or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.Parent = p
    return u
end

local function clampRange(v, lo, hi)
    if hi < lo then return lo end
    return math.clamp(v, lo, hi)
end

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local connections = {}
local function track(conn) table.insert(connections, conn); return conn end
local function untrackAll()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    table.clear(connections)
end

-- forward declarations (diisi di bawah)
local unloadHub
local closeAllDropdowns

-- ========== CONFIG ==========
local Config = {
    ESP=false, ESPLine=false, ESPBox=false, ESPChams=false,
    ESPHealth=false, ESPDistance=false, ESPTeamCheck=false, ESPRange=500, ChamsThickness=45,
    AimAssist=false, AimSmoothness=5, AimRange=500, AimFov=150,
    AimPlace="Head", AimTeamCheck=false, AimWallCheck=false, AimVehicleCheck=false,
    AimPredict=false, AimPredictLead=120, AimPredictMaxDist=60,
    AimMode="Camera",
    AimClosePriority=false,
    AimWallMultiPoint=true,
    AimWallGrace=false, AimWallGraceTime=600,
    LockTarget=false,
    InfiniteJump=false, CFrameFly=false, CFrameFlyJoy=false, Fly=false, FlySpeed=50,
    Float=false, FloatHeight=0,
    TpWalk=false, TpWalkSpeed=120,
    Noclip=false, GlassMode=false, QuickDockEnabled=true,
    QuickSlot1="Aim Assist", QuickSlot2="ESP", QuickSlot3="Aim Predict",
    QuickSlot4="Fly", QuickSlot5="Noclip",
    ESPColorR=255, ESPColorG=190, ESPColorB=82,
    -- Target Lock: warna ESP saat target di-lock aim assist (RGB sendiri, tidak dicampur ESPColor)
    LockColor=true, LockAnim=true,
    LockColorR=255, LockColorG=72, LockColorB=104,
    MenuWidth=460, MenuHeight=560,
}

-- ========== DRAWING ==========
local DrawingLib = (function()
    local ok, d = pcall(function()
        local t = Drawing.new("Line"); t:Remove(); return Drawing
    end)
    return ok and d or nil
end)()

-- ========== STATE (dideklarasi di atas supaya UI callback bisa akses) ==========
local espObjects = {}
local bodyGyro, flyBV, flyBG
local bodyRotationActive = false
local quickDock, refreshQuickDock
local flyV = 0

local fovCircle = DrawingLib and DrawingLib.new("Circle")
if fovCircle then
    fovCircle.Thickness = 1.5
    fovCircle.Color = T.Amber
    fovCircle.Filled = false
    fovCircle.Transparency = 0.7
    fovCircle.NumSides = 64
    fovCircle.Visible = false
end

local predictDot = DrawingLib and DrawingLib.new("Circle")
if predictDot then
    predictDot.Thickness = 1.5
    predictDot.Color = T.Amber
    predictDot.Filled = true
    predictDot.Transparency = 0.8
    predictDot.Radius = 5
    predictDot.Visible = false
end

-- ========== UTILITY ==========
local function isTeammate(plr)
    if plr == LP then return true end
    if not plr or not plr.Parent then return false end
    if LP.Neutral or plr.Neutral then return false end
    local lpT, plrT = LP.Team, plr.Team
    if not lpT or not plrT then return false end
    return lpT.TeamColor == plrT.TeamColor
end

local function hasLineOfSight(targetPart, targetPlayer)
    if not targetPart then return false end

    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    if direction.Magnitude <= 0.01 then return true end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    -- Part CanCollide=false (trigger/hitbox tak terlihat, dekorasi) tidak dianggap tembok.
    pcall(function() params.RespectCanCollide = true end)

    local ignore = {}
    if LP.Character then table.insert(ignore, LP.Character) end

    local targetCharacter = targetPlayer and targetPlayer.Character or targetPart:FindFirstAncestorOfClass("Model")
    if targetCharacter then table.insert(ignore, targetCharacter) end

    -- Vehicle Check hanya mengabaikan badan kendaraan saat target sedang duduk.
    -- Tembok/objek di luar kendaraan tetap akan menghentikan raycast.
    if Config.AimVehicleCheck and targetPlayer and targetCharacter then
        local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
        local seatPart = targetHumanoid and targetHumanoid.SeatPart
        if seatPart then
            local vehicleModel = seatPart:FindFirstAncestorOfClass("Model")
            if vehicleModel and vehicleModel ~= targetCharacter then
                table.insert(ignore, vehicleModel)
            else
                table.insert(ignore, seatPart)
            end
        end
    end

    params.FilterDescendantsInstances = ignore
    return workspace:Raycast(origin, direction, params) == nil
end

-- Multi-point: kalau part utama (mis. Head) ketutup ujung atap/tembok tapi badan masih
-- kelihatan, target tetap dianggap terlihat dan aim diarahkan ke part yang kelihatan.
local VISIBLE_FALLBACK = {"UpperTorso", "Torso", "HumanoidRootPart"}
local function resolveVisiblePart(char, plr, primary)
    if hasLineOfSight(primary, plr) then return primary end
    if not Config.AimWallMultiPoint then return nil end
    for _, name in ipairs(VISIBLE_FALLBACK) do
        local p = char:FindFirstChild(name)
        if p and p ~= primary and hasLineOfSight(p, plr) then return p end
    end
    return nil
end

-- ========== DRAG SYSTEM (satu slot global: slider, window, tombol tahan) ==========
local drag = {move = nil, stop = nil}

track(UIS.InputChanged:Connect(function(input)
    if not drag.move then return end
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
        drag.move(input.Position)
    end
end))

track(UIS.InputEnded:Connect(function(input)
    if not drag.stop then return end
    if isPress(input) then
        local s = drag.stop
        drag.move, drag.stop = nil, nil
        pcall(s)
    end
end))

local function beginDrag(move, stop)
    if drag.stop then
        local s = drag.stop
        drag.move, drag.stop = nil, nil
        pcall(s)
    end
    drag.move, drag.stop = move, stop
end

-- ========== SCREEN GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NovaXHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
do
    local parented = false
    local okH, hui = pcall(function() return gethui and gethui() end)
    if okH and hui then
        parented = pcall(function() ScreenGui.Parent = hui end) and ScreenGui.Parent ~= nil
    end
    if not parented then
        parented = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
            and ScreenGui.Parent ~= nil
    end
    if not parented then ScreenGui.Parent = PGui end
end

-- ========== WINDOW (Dynamic Island) ==========
-- Main = satu shell kaca. Tertutup = pill kecil (island), terbuka = menu penuh.
-- Buka/tutup = morph ukuran + radius (melebar dulu, baru turun), isi muncul bertahap.
local ISL_W, ISL_H = 132, 44
local ISL_R, OPEN_R = 22, 28

local menuOpen, menuSettled, closedSettled = false, false, true
local fullW, fullH = Config.MenuWidth, Config.MenuHeight
local fitScale = 1
local menuPos, menuToken = nil, 0
local islandDragging = false
local orbBase = Vector2.new(Camera.ViewportSize.X / 2, 38)

-- ---------- SKIN: mode biasa (putih + outline hitam) <-> Full Glass (liquid glass) ----------
-- Elemen yang berubah tampilan didaftarkan lewat skin()/ustroke(). Posisi, ukuran
-- dan animasi nggak disentuh, cuma warna / transparansi / outline-nya.
local glassMode = false
local skinList, skinGrads, glassHooks = {}, {}, {}
local function sT(n, g) if glassMode then return g end return n end

local function skin(inst, n, g)
    table.insert(skinList, {inst, n, g})
    for k, v in pairs(glassMode and g or n) do inst[k] = v end
    return inst
end

-- highlight speculer: terang di pojok kiri-atas & kanan-bawah, tipis di tengah
local SPEC = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(0.22, 0.6),
    NumberSequenceKeypoint.new(0.5, 0.92),
    NumberSequenceKeypoint.new(0.78, 0.6),
    NumberSequenceKeypoint.new(1, 0),
})

-- outline: hitam tegas (biasa) <-> tepi kaca putih berkilau (glass)
-- opt: gThick = tebal di mode glass, plain = tanpa gradient speculer, gColor = warna di mode glass
local function ustroke(p, thick, nT, gT, opt)
    opt = opt or {}
    local st = stroke(p, T.Ink, thick, nT)
    local n = {Color = T.Ink, Transparency = nT}
    local g = {Color = opt.gColor or T.Glass, Transparency = gT}
    if opt.gThick then n.Thickness = thick; g.Thickness = opt.gThick end
    skin(st, n, g)
    if not opt.plain then
        local gr = Instance.new("UIGradient")
        gr.Color = ColorSequence.new(T.Glass, T.Glass)
        gr.Transparency = SPEC
        gr.Rotation = opt.rot or 45
        gr.Enabled = glassMode
        gr.Parent = st
        table.insert(skinGrads, gr)
    end
    return st
end

local function applyGlass(on)
    glassMode = on and true or false
    for _, gr in ipairs(skinGrads) do gr.Enabled = glassMode end
    for _, e in ipairs(skinList) do
        local inst = e[1]
        if inst and inst.Parent then
            tween(inst, glassMode and e[3] or e[2], 0.5, Enum.EasingStyle.Quad)
        end
    end
    for _, h in ipairs(glassHooks) do pcall(h) end
end

local Main = new("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(orbBase.X, orbBase.Y),
    Size = UDim2.fromOffset(ISL_W, ISL_H),
    BackgroundColor3 = T.Glass,
    BackgroundTransparency = 0.14,
    ClipsDescendants = true,
}, ScreenGui)
local uiScale = Instance.new("UIScale")
uiScale.Parent = Main
local setRadius
do -- dibungkus: batas 200 local di level atas
local mainCorner = corner(Main, ISL_R)
local mainStroke = ustroke(Main, 1.8, 0.05, 0, {gThick = 1.6})
skin(Main, {BackgroundTransparency = 0.14}, {BackgroundTransparency = 0.34})
gradient(Main, ColorSequence.new(T.Glass, T.Frost), 125)

-- kilau kaca di pojok kiri atas
local Sheen = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = T.Glass,
    ZIndex = 1,
}, Main)
local sheenCorner = corner(Sheen, ISL_R)
local sheenGrad = gradient(Sheen, ColorSequence.new(T.Glass, T.Glass), 125)
sheenGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.35),
    NumberSequenceKeypoint.new(0.4, 0.88),
    NumberSequenceKeypoint.new(1, 1),
})

-- lapisan liquid glass (cuma kelihatan saat Full Glass Mode)
local Tint = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = T.Glass,
    ZIndex = 1,
}, Main)
local tintCorner = corner(Tint, ISL_R)
gradient(Tint, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(176, 214, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(236, 226, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 206, 232)),
}), 125)
skin(Tint, {BackgroundTransparency = 1}, {BackgroundTransparency = 0.72})

local Caustic = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = T.Glass,
    ZIndex = 1,
}, Main)
local causticCorner = corner(Caustic, ISL_R)
local causticGrad = gradient(Caustic, ColorSequence.new(T.Glass, T.Glass), 125)
causticGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.55, 0.96),
    NumberSequenceKeypoint.new(1, 0.5),
})
skin(Caustic, {BackgroundTransparency = 1}, {BackgroundTransparency = 0})

-- rim putih tipis di dalam tepi (efek tebal kaca)
local Rim = new("Frame", {
    Position = UDim2.fromOffset(2, 2),
    Size = UDim2.new(1, -4, 1, -4),
    BackgroundTransparency = 1,
    ZIndex = 2,
}, Main)
local rimCorner = corner(Rim, ISL_R - 2)
skin(stroke(Rim, T.Glass, 1.5, 0.3), {Transparency = 0.3}, {Transparency = 0.1})

-- kilau tipis di tepi atas
local Glint = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 3),
    Size = UDim2.new(1, -30, 0, 1.5),
    BackgroundColor3 = T.Glass,
    ZIndex = 2,
}, Main)
corner(Glint, 1)
gradient(Glint, ColorSequence.new(T.Glass, T.Glass), 0).Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(1, 1),
})
skin(Glint, {BackgroundTransparency = 1}, {BackgroundTransparency = 0.05})

setRadius = function(r, time, style, dir)
    local info = TweenInfo.new(time or 0.5, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    for _, c in ipairs({{mainCorner, 0}, {sheenCorner, 0}, {tintCorner, 0}, {causticCorner, 0}, {rimCorner, -2}}) do
        TS:Create(c[1], info, {CornerRadius = UDim.new(0, r + c[2])}):Play()
    end
end
end

-- ---------- ikon bintang "nova" (digambar pakai Frame, bebas font) ----------
local function makeSparkle(parent, size, color, innerColor)
    local root = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
    }, parent)
    local function ray(w, h, rot, c)
        local f = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(w, h),
            Rotation = rot or 0,
            BackgroundColor3 = c or color,
        }, root)
        corner(f, 99)
        return f
    end
    local t = math.max(2, size * 0.13)
    ray(t, size, 0)
    ray(size, t, 0)
    ray(t * 0.85, size * 0.68, 45)
    ray(t * 0.85, size * 0.68, -45)
    ray(size * 0.32, size * 0.32, 0)
    ray(size * 0.13, size * 0.13, 0, innerColor or T.Glass)
    return root
end

local function animateSparkle(root, spinTime)
    TS:Create(root, TweenInfo.new(spinTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
        {Rotation = 360}):Play()
    local sc = Instance.new("UIScale")
    sc.Parent = root
    TS:Create(sc, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Scale = 1.14}):Play()
end

-- ---------- isi island (saat tertutup) ----------
local Island = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(ISL_W, ISL_H),
    BackgroundTransparency = 1,
    ZIndex = 4,
}, Main)
local islandIcon = makeSparkle(Island, 22, T.Ink)
islandIcon.Position = UDim2.fromOffset(26, ISL_H / 2)
animateSparkle(islandIcon, 14)
newLabel(Island, {
    Position = UDim2.fromOffset(46, 0),
    Size = UDim2.new(1, -54, 1, 0),
    Text = "NovaX",
    TextSize = 15,
    Font = Enum.Font.GothamBlack,
    TextColor3 = T.Ink,
})

local IslandBtn = new("TextButton", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 20,
}, Main)

-- ---------- body menu (fixed size, di-reveal oleh shell yang melebar) ----------
local Body = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(fullW, fullH),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    Visible = false,
    ZIndex = 3,
}, Main)

local function mainHalf()
    local w, h = ISL_W, ISL_H
    local s = 1
    if menuOpen then w, h, s = fullW, fullH, fitScale end
    return Vector2.new(w, h) * s / 2
end

local function clampMainPos(x, y)
    local vp, hf = Camera.ViewportSize, mainHalf()
    return clampRange(x, hf.X, vp.X - hf.X), clampRange(y, hf.Y, vp.Y - hf.Y)
end

local function clampIsland(x, y)
    local vp = Camera.ViewportSize
    return clampRange(x, ISL_W / 2 + 4, vp.X - ISL_W / 2 - 4),
           clampRange(y, ISL_H / 2 + 4, vp.Y - ISL_H / 2 - 4)
end

local function applyLayout(recenter)
    local vp = Camera.ViewportSize
    fitScale = math.clamp((vp.X - 24) / Config.MenuWidth, 0.65, 1)
    fullW = Config.MenuWidth
    fullH = math.max(260, math.min(Config.MenuHeight, math.floor((vp.Y - 24) / fitScale)))
    Body.Size = UDim2.fromOffset(fullW, fullH)
    if menuOpen then
        uiScale.Scale = fitScale
        if menuSettled then Main.Size = UDim2.fromOffset(fullW, fullH) end
    end
    if recenter then
        menuPos = nil
        if menuOpen and menuSettled then Main.Position = UDim2.fromOffset(vp.X / 2, vp.Y / 2) end
    end
    if menuOpen and menuSettled then
        local x, y = clampMainPos(Main.Position.X.Offset, Main.Position.Y.Offset)
        Main.Position = UDim2.fromOffset(x, y)
    end
    local ix, iy = clampIsland(orbBase.X, orbBase.Y)
    orbBase = Vector2.new(ix, iy)
end

local Lighting = game:GetService("Lighting")
local USE_BLUR = true -- set false kalau nggak mau blur layar
local blur
if USE_BLUR then
    pcall(function()
        blur = Instance.new("BlurEffect")
        blur.Name = "NovaXBlur"
        blur.Size = 0
        blur.Parent = Lighting
    end)
end
local function setBlur(sz)
    if blur and blur.Parent then tween(blur, {Size = sz}, 0.5, Enum.EasingStyle.Quad) end
end

table.insert(glassHooks, function()
    if menuOpen then setBlur(glassMode and 22 or 14) end
end)

-- forward: dipakai setMenu untuk animasi pop bead tab (diisi di bagian TABS)
local popBeads = function() end

local function setMenu(open)
    if menuOpen == open then return end
    menuOpen = open
    menuToken += 1
    local token = menuToken

    if open then
        closedSettled = false
        menuSettled = false
        IslandBtn.Visible = false
        local vp = Camera.ViewportSize
        local tx, ty = clampMainPos(menuPos and menuPos.X or vp.X / 2, menuPos and menuPos.Y or vp.Y / 2)

        Body.Visible = true
        Body.GroupTransparency = 1
        Body.Position = UDim2.new(0.5, 0, 0.5, 18)
        setBlur(glassMode and 22 or 14)

        -- fase 1: island melebar ke samping + meluncur ke posisi menu
        tween(Island, {GroupTransparency = 1}, 0.14, Enum.EasingStyle.Quad)
        tween(Main, {Position = UDim2.fromOffset(tx, ty)}, 0.65, Enum.EasingStyle.Quint)
        tween(Main, {Size = UDim2.fromOffset(fullW, ISL_H + 22)}, 0.3, Enum.EasingStyle.Quint)
        tween(uiScale, {Scale = fitScale}, 0.5, Enum.EasingStyle.Quint)
        setRadius(OPEN_R, 0.55, Enum.EasingStyle.Quint)

        -- fase 2: turun jadi panel penuh (agak membal kayak jelly)
        task.delay(0.18, function()
            if menuToken ~= token then return end
            tween(Main, {Size = UDim2.fromOffset(fullW, fullH)}, 0.62, Enum.EasingStyle.Back)
        end)
        -- fase 3: isi muncul
        task.delay(0.3, function()
            if menuToken ~= token then return end
            tween(Body, {GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5)}, 0.45, Enum.EasingStyle.Quint)
            popBeads()
        end)
        task.delay(0.85, function()
            if menuToken == token then menuSettled = true end
        end)
    else
        if closeAllDropdowns then closeAllDropdowns() end
        if menuSettled then
            menuPos = Vector2.new(Main.Position.X.Offset, Main.Position.Y.Offset)
        end
        menuSettled = false
        setBlur(0)

        -- isi memudar, panel mengerut jadi bar tipis, lalu mengecil jadi pill
        tween(Body, {GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 12)}, 0.2, Enum.EasingStyle.Quad)
        tween(Main, {Position = UDim2.fromOffset(orbBase.X, orbBase.Y)}, 0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
        tween(Main, {Size = UDim2.fromOffset(fullW, ISL_H + 22)}, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
        task.delay(0.24, function()
            if menuToken ~= token then return end
            tween(Main, {Size = UDim2.fromOffset(ISL_W, ISL_H)}, 0.55, Enum.EasingStyle.Back)
            tween(uiScale, {Scale = 1}, 0.45, Enum.EasingStyle.Quint)
            setRadius(ISL_R, 0.5, Enum.EasingStyle.Quint)
        end)
        task.delay(0.5, function()
            if menuToken ~= token then return end
            tween(Island, {GroupTransparency = 0}, 0.3, Enum.EasingStyle.Quad)
        end)
        task.delay(0.8, function()
            if menuToken ~= token then return end
            Body.Visible = false
            closedSettled = true
            IslandBtn.Visible = true
        end)
    end
end

local camConn
local function bindCamera()
    Camera = workspace.CurrentCamera or Camera
    if camConn then pcall(function() camConn:Disconnect() end) end
    camConn = track(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        applyLayout(false)
    end))
    applyLayout(false)
end
track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera))

-- ========== TOP BAR ==========
local TopBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundTransparency = 1,
}, Body)

local headIcon = makeSparkle(TopBar, 24, T.Ink)
headIcon.Position = UDim2.fromOffset(32, 29)
animateSparkle(headIcon, 16)

newLabel(TopBar, {
    Position = UDim2.fromOffset(56, 8),
    Size = UDim2.new(1, -150, 0, 26),
    Text = "NovaXHub",
    TextSize = 21,
    Font = Enum.Font.GothamBlack,
    TextColor3 = T.Ink,
})
newLabel(TopBar, {
    Position = UDim2.fromOffset(56, 34),
    Size = UDim2.new(1, -150, 0, 16),
    Text = "Nova Island  v5.3",
    TextSize = 11,
    TextColor3 = T.InkDim,
})

-- area drag window (di luar tombol kontrol)
local DragZone = new("Frame", {
    Size = UDim2.new(1, -90, 1, 0),
    BackgroundTransparency = 1,
}, TopBar)

DragZone.InputBegan:Connect(function(input)
    if not isPress(input) or not menuSettled then return end
    local startPos = input.Position
    local sx, sy = Main.Position.X.Offset, Main.Position.Y.Offset
    beginDrag(function(pos)
        local x, y = clampMainPos(sx + (pos.X - startPos.X), sy + (pos.Y - startPos.Y))
        Main.Position = UDim2.fromOffset(x, y)
    end, function() end)
end)

local function makeCtrlButton(xOff, hoverColor, kind)
    local b = new("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, xOff, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = T.Glass,
        BackgroundTransparency = 0.2,
        Text = "",
        ZIndex = 3,
    }, TopBar)
    corner(b, 15)
    ustroke(b, 1.3, 0.2, 0.1)
    skin(b, {BackgroundTransparency = 0.2}, {BackgroundTransparency = 0.55})
    local bars = {}
    local function bar(w, rot)
        local f = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(w, 2),
            Rotation = rot or 0,
            BackgroundColor3 = T.Ink,
            ZIndex = 4,
        }, b)
        corner(f, 1)
        table.insert(bars, f)
    end
    if kind == "min" then
        bar(11, 0)
    else
        bar(13, 45)
        bar(13, -45)
    end
    b.MouseEnter:Connect(function()
        tween(b, {BackgroundColor3 = hoverColor, BackgroundTransparency = 0}, 0.15)
        for _, f in ipairs(bars) do tween(f, {BackgroundColor3 = T.Glass}, 0.15) end
    end)
    b.MouseLeave:Connect(function()
        tween(b, {BackgroundColor3 = T.Glass, BackgroundTransparency = sT(0.2, 0.55)}, 0.2)
        for _, f in ipairs(bars) do tween(f, {BackgroundColor3 = T.Ink}, 0.2) end
    end)
    return b
end

local CloseBtn = makeCtrlButton(-28, T.Danger, "close")
local MinBtn   = makeCtrlButton(-64, T.Ink, "min")

-- garis tipis dengan ujung memudar
local Divider = new("Frame", {
    Position = UDim2.fromOffset(18, 58),
    Size = UDim2.new(1, -36, 0, 1),
    BackgroundColor3 = T.Ink,
}, Body)
skin(Divider, {BackgroundColor3 = T.Ink}, {BackgroundColor3 = T.Glass})
local divGrad = gradient(Divider, ColorSequence.new(T.Glass, T.Glass), 0)
divGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.7),
    NumberSequenceKeypoint.new(1, 1),
})

-- ========== TABS: konstelasi melayang ==========
-- Tab = bead kaca yang melayang bebas di sisi kiri, posisinya zig-zag
-- (bukan sejajar), disambung garis tipis kayak rasi bintang. Saat pindah tab,
-- ada "komet" yang meluncur dari bead lama ke bead baru.
local TAB_NAMES = {"Visual", "Aim", "Misc", "Settings"}
local TAB_CAPS  = {Visual = "ESP & overlay", Aim = "Targeting", Misc = "Movement & fly", Settings = "Window & info"}
local TabCount = #TAB_NAMES
local RAIL_X = {28, 44, 26, 42}
local RAIL_J = {0, 10, -6, 8}

local function beadCenter(i, t)
    local H = Body.Size.Y.Offset
    local gap = math.max(58, (H - 154) / 3.2)
    return Vector2.new(
        RAIL_X[i] + math.sin(t * 0.9 + i * 1.7) * 3,
        88 + (i - 1) * gap + RAIL_J[i] + math.sin(t * 1.25 + i * 2.1) * 4.5
    )
end

-- judul halaman (ganti dengan animasi geser saat pindah tab)
local TITLE_X, TITLE_Y = 78, 62
local PageTitle = newLabel(Body, {
    Position = UDim2.fromOffset(TITLE_X, TITLE_Y),
    Size = UDim2.new(0.6, 0, 0, 30),
    Text = "",
    TextSize = 21,
    Font = Enum.Font.GothamBlack,
    TextColor3 = T.Ink,
})
local PageCap = newLabel(Body, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -18, 0, TITLE_Y + 8),
    Size = UDim2.new(0.4, 0, 0, 18),
    Text = "",
    TextSize = 11,
    TextColor3 = T.InkDim,
    TextXAlignment = Enum.TextXAlignment.Right,
})

local titleToken = 0
local function setTitle(name, instant)
    titleToken += 1
    local tk = titleToken
    if instant then
        PageTitle.Text = name
        PageCap.Text = TAB_CAPS[name] or ""
        PageTitle.TextTransparency, PageCap.TextTransparency = 0, 0
        PageTitle.Position = UDim2.fromOffset(TITLE_X, TITLE_Y)
        return
    end
    tween(PageTitle, {TextTransparency = 1, Position = UDim2.fromOffset(TITLE_X + 10, TITLE_Y)}, 0.12, Enum.EasingStyle.Quad)
    tween(PageCap, {TextTransparency = 1}, 0.12, Enum.EasingStyle.Quad)
    task.delay(0.13, function()
        if tk ~= titleToken then return end
        PageTitle.Text = name
        PageCap.Text = TAB_CAPS[name] or ""
        PageTitle.Position = UDim2.fromOffset(TITLE_X - 14, TITLE_Y)
        tween(PageTitle, {TextTransparency = 0, Position = UDim2.fromOffset(TITLE_X, TITLE_Y)}, 0.38, Enum.EasingStyle.Quint)
        tween(PageCap, {TextTransparency = 0}, 0.38, Enum.EasingStyle.Quad)
    end)
end

local Content = new("Frame", {
    Position = UDim2.fromOffset(76, 98),
    Size = UDim2.new(1, -88, 1, -136),
    BackgroundColor3 = T.Glass,
    BackgroundTransparency = 0.52,
    ClipsDescendants = true,
}, Body)
corner(Content, 16)
ustroke(Content, 1, 0.82, 0.4)
skin(Content, {BackgroundTransparency = 0.52}, {BackgroundTransparency = 0.78})

-- garis konstelasi
local railLines = {}
for i = 1, TabCount - 1 do
    railLines[i] = skin(new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(10, 1.5),
        BackgroundColor3 = T.Ink,
        BackgroundTransparency = 0.6,
        ZIndex = 2,
    }, Body), {BackgroundColor3 = T.Ink, BackgroundTransparency = 0.6},
        {BackgroundColor3 = T.Glass, BackgroundTransparency = 0.25})
end

-- komet perpindahan tab
local Comet = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = T.Ink,
    Visible = false,
    ZIndex = 9,
}, Body)
corner(Comet, 4)
local cometVal = Instance.new("NumberValue")
cometVal.Parent = ScreenGui
local cometFrom, cometTo, cometOn = 1, 1, false

local Pages, Holders, TabButtons, TabIndex = {}, {}, {}, {}
local TabChips = {}
local orderCount = setmetatable({}, {__mode = "k"})
local function nextOrder(page)
    orderCount[page] = (orderCount[page] or 0) + 1
    return orderCount[page]
end

local currentTab = nil

local function beadBT(on)
    if glassMode then return on and 0.3 or 0.55 end
    return on and 0.04 or 0.2
end

local function selectTab(name, instant)
    if currentTab == name then return end
    local prev = currentTab
    currentTab = name
    if closeAllDropdowns then closeAllDropdowns() end

    local idx = TabIndex[name]
    local dir = (prev and TabIndex[prev] and TabIndex[prev] > idx) and -1 or 1

    for n, c in pairs(TabChips) do
        local on = (n == name)
        tween(c.bead, {
            BackgroundColor3 = on and T.Ink or T.Glass,
            BackgroundTransparency = beadBT(on),
        }, 0.3)
        c.setColor(on and T.Glass or T.Ink, 0.3)
        tween(c.scale, {Scale = on and 1.14 or 1}, 0.45, Enum.EasingStyle.Back)
        if on ~= c.on then
            c.on = on
            if on then
                c.haloStroke.Transparency = 0.35
                c.haloScale.Scale = 1
                c.haloTw:Play()
                c.haloTw2:Play()
            else
                c.haloTw:Cancel()
                c.haloTw2:Cancel()
                c.haloStroke.Transparency = 1
                c.haloScale.Scale = 1
            end
        end
    end

    if prev and not instant then
        cometFrom, cometTo = TabIndex[prev], idx
        cometVal.Value = 0
        cometOn = true
        Comet.Visible = true
        tween(cometVal, {Value = 1}, 0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
    end

    setTitle(name, instant)

    for n, h in pairs(Holders) do
        if n ~= name and n ~= prev then h.Visible = false end
    end
    local newH = Holders[name]
    newH.Visible = true
    if instant then
        newH.GroupTransparency = 0
        newH.Position = UDim2.fromOffset(0, 0)
    else
        newH.GroupTransparency = 1
        newH.Position = UDim2.fromOffset(0, 22 * dir)
        tween(newH, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)}, 0.45, Enum.EasingStyle.Quint)
        if prev and Holders[prev] then
            local oldH = Holders[prev]
            tween(oldH, {GroupTransparency = 1, Position = UDim2.fromOffset(0, -16 * dir)}, 0.16, Enum.EasingStyle.Quad)
            task.delay(0.18, function()
                if currentTab ~= prev then oldH.Visible = false end
            end)
        end
    end
end

-- ikon bead digambar pakai Frame
local function makeIcon(kind, parent)
    local root = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(24, 24),
        BackgroundTransparency = 1,
        ZIndex = 7,
    }, parent)
    local fills, strokes = {}, {}
    local function box(x, y, w, h, r, rot, hollow, th)
        local f = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(w, h),
            Rotation = rot or 0,
            BackgroundColor3 = T.Ink,
            BackgroundTransparency = hollow and 1 or 0,
            ZIndex = 7,
        }, root)
        corner(f, r or 0)
        if hollow then
            table.insert(strokes, stroke(f, T.Ink, th or 2, 0))
        else
            table.insert(fills, f)
        end
    end
    if kind == "Visual" then          -- mata
        box(12, 12, 20, 12, 99, 0, true, 2)
        box(12, 12, 6, 6, 99)
    elseif kind == "Aim" then         -- crosshair
        box(12, 12, 16, 16, 99, 0, true, 2)
        box(12, 12, 3, 3, 99)
        box(12, 1.5, 2, 5, 1)
        box(12, 22.5, 2, 5, 1)
        box(1.5, 12, 5, 2, 1)
        box(22.5, 12, 5, 2, 1)
    elseif kind == "Misc" then        -- 4 kotak, satu miring (sengaja)
        box(6, 6, 8, 8, 2)
        box(18, 6, 8, 8, 2, 45)
        box(6, 18, 8, 8, 2)
        box(18, 18, 8, 8, 2)
    else                              -- slider
        box(12, 7, 20, 2, 1)
        box(12, 17, 20, 2, 1)
        box(16, 7, 7, 7, 99)
        box(8, 17, 7, 7, 99)
    end
    local function setColor(c, time)
        for _, f in ipairs(fills) do tween(f, {BackgroundColor3 = c}, time or 0.2) end
        for _, s in ipairs(strokes) do tween(s, {Color = c}, time or 0.2) end
    end
    return setColor
end

local function makeTab(name, idx)
    TabIndex[name] = idx
    local c0 = beadCenter(idx, 0)
    local bead = new("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(c0.X, c0.Y),
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = T.Glass,
        BackgroundTransparency = 0.2,
        Text = "",
        ZIndex = 6,
    }, Body)
    corner(bead, 22)
    local beadStroke = ustroke(bead, 1.5, 0.12, 0.05, {gThick = 1.6})
    local beadScale = Instance.new("UIScale")
    beadScale.Parent = bead

    -- cincin pulsa untuk tab aktif
    local halo = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 5,
    }, bead)
    corner(halo, 22)
    local haloStroke = stroke(halo, T.Ink, 1.5, 1)
    skin(haloStroke, {Color = T.Ink}, {Color = T.Glass})
    local haloScale = Instance.new("UIScale")
    haloScale.Parent = halo
    local haloInfo = TweenInfo.new(1.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, -1)
    local haloTw = TS:Create(haloScale, haloInfo, {Scale = 1.75})
    local haloTw2 = TS:Create(haloStroke, haloInfo, {Transparency = 1})

    local setColor = makeIcon(name, bead)

    -- label kecil muncul saat hover
    local tagW = 40
    pcall(function()
        tagW = TextService:GetTextSize(name, 12, Enum.Font.GothamBold, Vector2.new(300, 20)).X + 24
    end)
    local Tag = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(tagW, 26),
        BackgroundColor3 = T.Ink,
        BackgroundTransparency = 1,
        ZIndex = 30,
    }, Body)
    corner(Tag, 13)
    local tagScale = Instance.new("UIScale")
    tagScale.Scale = 0.6
    tagScale.Parent = Tag
    local tagLbl = newLabel(Tag, {
        Size = UDim2.fromScale(1, 1),
        Text = name,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = T.Glass,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 31,
    })

    TabButtons[name] = bead
    TabChips[name] = {
        bead = bead, scale = beadScale, idx = idx, on = false,
        setColor = setColor, haloStroke = haloStroke, haloScale = haloScale,
        haloTw = haloTw, haloTw2 = haloTw2, tag = Tag,
    }

    bead.MouseEnter:Connect(function()
        tween(tagScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
        tween(Tag, {BackgroundTransparency = 0.05}, 0.15)
        tween(tagLbl, {TextTransparency = 0}, 0.15)
        if currentTab ~= name then
            tween(beadScale, {Scale = 1.1}, 0.3, Enum.EasingStyle.Back)
            tween(beadStroke, {Transparency = 0}, 0.15)
        end
    end)
    bead.MouseLeave:Connect(function()
        tween(tagScale, {Scale = 0.6}, 0.2, Enum.EasingStyle.Quad)
        tween(Tag, {BackgroundTransparency = 1}, 0.15)
        tween(tagLbl, {TextTransparency = 1}, 0.15)
        if currentTab ~= name then
            tween(beadScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
        end
        tween(beadStroke, {Transparency = sT(0.12, 0.05)}, 0.2)
    end)

    local holder = new("CanvasGroup", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
    }, Content)
    Holders[name] = holder

    local page = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Ink,
        ScrollBarImageTransparency = 0.35,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, holder)
    padding(page, 8, 8, 12, 10)
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 8)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = page

    Pages[name] = page
    bead.Activated:Connect(function() selectTab(name) end)
    return page
end

local VisualPage   = makeTab("Visual", 1)
local AimPage      = makeTab("Aim", 2)
local MiscPage     = makeTab("Misc", 3)
local SettingsPage = makeTab("Settings", 4)

table.insert(glassHooks, function()
    for n, c in pairs(TabChips) do
        tween(c.bead, {BackgroundTransparency = beadBT(n == currentTab)}, 0.5, Enum.EasingStyle.Quad)
    end
end)

-- bead muncul satu-satu (pop) setiap menu dibuka
popBeads = function()
    for name, c in pairs(TabChips) do
        c.scale.Scale = 0.01
        task.delay(0.04 + (c.idx - 1) * 0.07, function()
            if not menuOpen then return end
            tween(c.scale, {Scale = (name == currentTab) and 1.14 or 1}, 0.55, Enum.EasingStyle.Back)
        end)
    end
end

-- animasi per-frame: island idle, bead melayang, garis konstelasi, komet, tag
track(RS.RenderStepped:Connect(function()
    local t = os.clock()

    if closedSettled then
        local dx, dy = 0, 0
        if not islandDragging then
            dx = math.cos(t * 1.1) * 1.2
            dy = math.sin(t * 1.6) * 2.5
        end
        Main.Position = UDim2.fromOffset(orbBase.X + dx, orbBase.Y + dy)
    end

    if not Body.Visible then return end

    local centers = {}
    for i = 1, TabCount do
        local c = beadCenter(i, t)
        centers[i] = c
        local chip = TabChips[TAB_NAMES[i]]
        if chip then
            chip.bead.Position = UDim2.fromOffset(c.X, c.Y)
            chip.tag.Position = UDim2.fromOffset(c.X + 32, c.Y)
        end
    end

    for i = 1, TabCount - 1 do
        local a, b = centers[i], centers[i + 1]
        local d = b - a
        local ln = railLines[i]
        ln.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
        ln.Size = UDim2.fromOffset(math.max(0, d.Magnitude - 50), 1.5)
        ln.Rotation = math.deg(math.atan2(d.Y, d.X))
    end

    if cometOn then
        local a = cometVal.Value
        local p = centers[cometFrom]:Lerp(centers[cometTo], a)
        local bulge = math.sin(math.pi * a)
        Comet.Position = UDim2.fromOffset(p.X + bulge * 16, p.Y)
        local s = 5 + 7 * bulge
        Comet.Size = UDim2.fromOffset(s, s)
        if a >= 0.999 then
            cometOn = false
            Comet.Visible = false
        end
    end
end))

-- ========== FOOTER ==========
local FooterL = newLabel(Body, {
    Position = UDim2.new(0, 20, 1, -28),
    Size = UDim2.new(0.5, 0, 0, 18),
    Text = "-- fps   -- ms",
    TextSize = 11,
    TextColor3 = T.InkDim,
})
newLabel(Body, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -20, 1, -28),
    Size = UDim2.new(0.5, 0, 0, 18),
    Text = "RightShift untuk sembunyikan",
    TextSize = 11,
    TextColor3 = T.InkDim,
    TextXAlignment = Enum.TextXAlignment.Right,
})

do
    local acc, frames = 0, 0
    track(RS.Heartbeat:Connect(function(dt)
        acc += dt
        frames += 1
        if acc >= 0.5 and menuOpen then
            local fps = math.floor(frames / acc + 0.5)
            local ok, ping = pcall(function() return LP:GetNetworkPing() * 1000 end)
            FooterL.Text = string.format("%d fps   %d ms", fps, ok and math.floor(ping) or 0)
            acc, frames = 0, 0
        elseif acc >= 0.5 then
            acc, frames = 0, 0
        end
    end))
end

-- ========== COMPONENTS ==========
local toggleRefs = {}
local uiRefreshers = {}      -- key -> fungsi sinkron UI dengan Config (dipakai Load Configuration)
local sliderRanges = {}      -- key -> {min, max}
local dropdownOptions = {}   -- key -> {opsi}
local dropdownClosers = {}
local espColorRefresh -- diisi oleh kartu ESP Color
local function cardT() return sT(0.38, 0.68) end
local function strokeT() return sT(0.8, 0.3) end

local function setToggle(key, value)
    local ref = toggleRefs[key]
    if ref and ref.setter then ref.setter(value) end
end

closeAllDropdowns = function()
    for _, c in ipairs(dropdownClosers) do c() end
end

local function newCard(page, h)
    local card = new("Frame", {
        Size = UDim2.new(1, 0, 0, h),
        BackgroundColor3 = T.Glass,
        BackgroundTransparency = cardT(),
        LayoutOrder = nextOrder(page),
    }, page)
    corner(card, 13)
    local st = ustroke(card, 1, 0.8, 0.3)
    skin(card, {BackgroundTransparency = 0.38}, {BackgroundTransparency = 0.68})
    return card, st
end

local function hoverable(btn, card, st)
    btn.MouseEnter:Connect(function()
        tween(card, {BackgroundTransparency = cardT() - 0.2}, 0.18)
        tween(st, {Transparency = sT(0.4, 0.08)}, 0.18)
    end)
    btn.MouseLeave:Connect(function()
        tween(card, {BackgroundTransparency = cardT()}, 0.25)
        tween(st, {Transparency = strokeT()}, 0.25)
    end)
end

local function makeSection(page, text)
    local f = new("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(page),
    }, page)
    local w = 60
    pcall(function()
        w = TextService:GetTextSize(text, 12, Enum.Font.GothamBold, Vector2.new(400, 20)).X
    end)
    local dot = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 4, 0.5, 2),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = T.Ink,
    }, f)
    corner(dot, 3)
    newLabel(f, {
        Position = UDim2.fromOffset(17, 4),
        Size = UDim2.fromOffset(w + 4, 22),
        Text = text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = T.Ink,
    })
    skin(new("Frame", {
        Position = UDim2.new(0, w + 28, 0.5, 2),
        Size = UDim2.new(1, -(w + 28), 0, 1),
        BackgroundColor3 = T.Ink,
        BackgroundTransparency = 0.86,
    }, f), {BackgroundColor3 = T.Ink, BackgroundTransparency = 0.86},
        {BackgroundColor3 = T.Glass, BackgroundTransparency = 0.35})
    return f
end

local function makeToggle(page, text, key, callback)
    local card, st = newCard(page, 48)
    newLabel(card, {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -90, 1, 0),
        Text = text,
        TextSize = 14,
    })

    local sw = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(46, 26),
        BackgroundColor3 = T.Off,
    }, card)
    corner(sw, 13)
    ustroke(sw, 1.2, 0.5, 0.15)
    skin(sw, {BackgroundTransparency = 0}, {BackgroundTransparency = 0.35})

    local fill = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = T.Ink,
        BackgroundTransparency = 1,
    }, sw)
    corner(fill, 13)

    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = T.Glass,
    }, sw)
    corner(knob, 10)
    ustroke(knob, 1.2, 0.45, 0.6, {plain = true, gColor = T.Ink})

    local btn = new("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
    }, card)

    local function setState(on, skipCallback)
        Config[key] = on
        if refreshQuickDock then pcall(refreshQuickDock) end
        if espColorRefresh and ((string.sub(key, 1, 3) == "ESP" and key ~= "ESPTeamCheck") or key == "LockColor") then
            espColorRefresh()
        end
        tween(fill, {BackgroundTransparency = on and 0 or 1}, 0.25)
        tween(knob, {
            Position = on and UDim2.new(0, 23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        }, 0.35, Enum.EasingStyle.Back)
        if not skipCallback and callback then callback(on) end
    end

    btn.Activated:Connect(function() setState(not Config[key]) end)
    hoverable(btn, card, st)
    if Config[key] then setState(true, true) end

    toggleRefs[key] = {setter = setState}
    uiRefreshers[key] = function() setState(Config[key] and true or false, true) end
    return card
end

local function makeSlider(page, text, key, min, max, callback, step)
    step = step or (((max - min) >= 20) and 1 or 0.01)
    local card, st = newCard(page, 64)

    newLabel(card, {
        Position = UDim2.fromOffset(16, 9),
        Size = UDim2.new(1, -110, 0, 20),
        Text = text,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local function fmt(v)
        if step >= 1 then return tostring(math.floor(v + 0.5)) end
        return string.format("%.2f", v)
    end

    local val = newLabel(card, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 9),
        Size = UDim2.fromOffset(80, 20),
        Text = fmt(Config[key]),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = T.Ink,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local trackF = new("Frame", {
        Position = UDim2.new(0, 16, 1, -20),
        Size = UDim2.new(1, -32, 0, 6),
        BackgroundColor3 = T.Off,
    }, card)
    corner(trackF, 3)
    ustroke(trackF, 1, 0.65, 0.3)
    skin(trackF, {BackgroundTransparency = 0}, {BackgroundTransparency = 0.3})

    local pct0 = (Config[key] - min) / (max - min)
    local fill = new("Frame", {
        Size = UDim2.fromScale(pct0, 1),
        BackgroundColor3 = T.Ink,
    }, trackF)
    corner(fill, 3)

    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(pct0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = T.Glass,
    }, trackF)
    corner(knob, 7)
    local ks = ustroke(knob, 2, 0, 0.35, {plain = true, gColor = T.Ink})

    -- area sentuh lebih besar dari track-nya
    local hit = new("TextButton", {
        Position = UDim2.new(0, 0, 1, -34),
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
    }, card)

    local function apply(rel)
        rel = math.clamp(rel, 0, 1)
        local v = min + (max - min) * rel
        v = math.floor(v / step + 0.5) * step
        v = math.clamp(tonumber(string.format("%.4f", v)), min, max)
        Config[key] = v
        local r = (v - min) / (max - min)
        val.Text = fmt(v)
        tween(fill, {Size = UDim2.fromScale(r, 1)}, 0.08, Enum.EasingStyle.Quad)
        tween(knob, {Position = UDim2.fromScale(r, 0.5)}, 0.08, Enum.EasingStyle.Quad)
        if callback then callback(v) end
    end

    local function fromX(x)
        apply((x - trackF.AbsolutePosition.X) / math.max(trackF.AbsoluteSize.X, 1))
    end

    hit.InputBegan:Connect(function(input)
        if not isPress(input) then return end
        page.ScrollingEnabled = false
        tween(knob, {Size = UDim2.fromOffset(20, 20)}, 0.2, Enum.EasingStyle.Back)
        tween(ks, {Thickness = 3}, 0.15)
        fromX(input.Position.X)
        beginDrag(function(pos) fromX(pos.X) end, function()
            page.ScrollingEnabled = true
            tween(knob, {Size = UDim2.fromOffset(14, 14)}, 0.2)
            tween(ks, {Thickness = 2}, 0.2)
        end)
    end)

    sliderRanges[key] = {min, max}
    uiRefreshers[key] = function()
        local v = math.clamp(Config[key], min, max)
        Config[key] = v
        local r = (v - min) / (max - min)
        val.Text = fmt(v)
        tween(fill, {Size = UDim2.fromScale(r, 1)}, 0.15, Enum.EasingStyle.Quad)
        tween(knob, {Position = UDim2.fromScale(r, 0.5)}, 0.15, Enum.EasingStyle.Quad)
    end

    hoverable(hit, card, st)
    return card
end

local function makeDropdown(page, text, key, options)
    local HEAD, ITEM, GAP = 50, 30, 4
    local openH = HEAD + #options * (ITEM + GAP) + 8

    local card, st = newCard(page, HEAD)
    card.ClipsDescendants = true

    newLabel(card, {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -176, 0, HEAD),
        Text = text,
        TextSize = 14,
    })

    local chip = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 10),
        Size = UDim2.fromOffset(146, 30),
        BackgroundColor3 = T.Glass,
        BackgroundTransparency = 0.2,
    }, card)
    corner(chip, 10)
    ustroke(chip, 1.2, 0.5, 0.15)
    skin(chip, {BackgroundTransparency = 0.2}, {BackgroundTransparency = 0.5})
    local chipLbl = newLabel(chip, {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -34, 1, 0),
        Text = Config[key],
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local arrow = newLabel(chip, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Text = "▼",
        TextSize = 9,
        TextColor3 = T.Ink,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local head = new("TextButton", {
        Size = UDim2.new(1, 0, 0, HEAD),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
    }, card)

    local list = new("Frame", {
        Position = UDim2.fromOffset(8, HEAD),
        Size = UDim2.new(1, -16, 0, #options * (ITEM + GAP)),
        BackgroundTransparency = 1,
    }, card)
    local ll = Instance.new("UIListLayout")
    ll.Padding = UDim.new(0, GAP)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Parent = list

    local isOpen = false
    local function setOpen(o)
        isOpen = o
        tween(card, {Size = UDim2.new(1, 0, 0, o and openH or HEAD)}, 0.38, Enum.EasingStyle.Quint)
        tween(arrow, {Rotation = o and 180 or 0}, 0.3, Enum.EasingStyle.Quint)
    end

    local items = {}
    local function refresh()
        for opt, it in pairs(items) do
            local sel = (Config[key] == opt)
            tween(it.btn, {
                BackgroundTransparency = sel and 0 or 1,
                TextColor3 = sel and T.Glass or T.Ink,
            }, 0.2)
        end
    end

    for i, opt in ipairs(options) do
        local b = new("TextButton", {
            Size = UDim2.new(1, 0, 0, ITEM),
            BackgroundColor3 = T.Ink,
            BackgroundTransparency = 1,
            Text = opt,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = i,
        }, list)
        corner(b, 9)
        padding(b, 14, 0, 0, 0)
        items[opt] = {btn = b}

        b.MouseEnter:Connect(function()
            if Config[key] ~= opt then tween(b, {BackgroundTransparency = 0.9}, 0.12) end
        end)
        b.MouseLeave:Connect(function()
            if Config[key] ~= opt then tween(b, {BackgroundTransparency = 1}, 0.18) end
        end)
        b.Activated:Connect(function()
            Config[key] = opt
            chipLbl.Text = opt
            refresh()
            if string.sub(key, 1, 9) == "QuickSlot" and refreshQuickDock then
                pcall(refreshQuickDock)
            end
            task.delay(0.12, function() setOpen(false) end)
        end)
    end
    refresh()
    dropdownOptions[key] = options
    uiRefreshers[key] = function()
        chipLbl.Text = tostring(Config[key])
        refresh()
    end

    head.Activated:Connect(function()
        if isOpen then
            setOpen(false)
        else
            closeAllDropdowns()
            setOpen(true)
        end
    end)
    hoverable(head, card, st)
    table.insert(dropdownClosers, function() if isOpen then setOpen(false) end end)
    return card
end

local function makeButton(page, text, danger, cb)
    local card, st = newCard(page, 44)
    local btn = new("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextColor3 = danger and T.Danger or T.Ink,
        ZIndex = 3,
    }, card)
    hoverable(btn, card, st)
    btn.Activated:Connect(function()
        tween(card, {BackgroundTransparency = 0}, 0.08)
        task.delay(0.1, function() tween(card, {BackgroundTransparency = cardT()}, 0.25) end)
        cb()
    end)
    return card
end

-- ========== RGB COLOR CARD (ESP Color & Lock Color) ==========
-- Kartu roll-down generik. Tiap kartu pakai key RGB-nya sendiri (tidak saling campur)
-- dan cuma muncul kalau isActive() true. Mengembalikan card + fungsi update roll-down.
local function makeColorCard(page, title, keys, presets, refreshId, isActive)
    local H = 180
    local card = newCard(page, 0)
    card.ClipsDescendants = true
    card.Visible = false

    local function currentColor()
        return Color3.fromRGB(Config[keys[1]], Config[keys[2]], Config[keys[3]])
    end

    newLabel(card, {
        Position = UDim2.fromOffset(16, 8),
        Size = UDim2.new(1, -110, 0, 22),
        Text = title,
        TextSize = 14,
    })
    local swatch = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 8),
        Size = UDim2.fromOffset(46, 22),
        BackgroundColor3 = currentColor(),
    }, card)
    corner(swatch, 8)
    ustroke(swatch, 1.2, 0.35, 0.3, {plain = true, gColor = T.Ink})

    local letters = {"R", "G", "B"}
    local cols = {Color3.fromRGB(235, 70, 70), Color3.fromRGB(60, 200, 100), Color3.fromRGB(70, 120, 240)}
    local rows = {}

    local function refreshAll()
        tween(swatch, {BackgroundColor3 = currentColor()}, 0.12)
        for _, r in ipairs(rows) do
            local v = Config[r.key]
            local pct = v / 255
            r.val.Text = tostring(v)
            tween(r.fill, {Size = UDim2.fromScale(pct, 1)}, 0.08, Enum.EasingStyle.Quad)
            tween(r.knob, {Position = UDim2.fromScale(pct, 0.5)}, 0.08, Enum.EasingStyle.Quad)
        end
    end

    uiRefreshers[refreshId] = refreshAll

    -- preset warna cepat
    for i, c in ipairs(presets) do
        local dot = new("TextButton", {
            Position = UDim2.fromOffset(16 + (i - 1) * 30, 38),
            Size = UDim2.fromOffset(22, 22),
            BackgroundColor3 = c,
            Text = "",
            ZIndex = 3,
        }, card)
        corner(dot, 11)
        ustroke(dot, 1.2, 0.3, 0.3, {plain = true, gColor = T.Ink})
        dot.Activated:Connect(function()
            Config[keys[1]] = math.floor(c.R * 255 + 0.5)
            Config[keys[2]] = math.floor(c.G * 255 + 0.5)
            Config[keys[3]] = math.floor(c.B * 255 + 0.5)
            refreshAll()
        end)
    end

    for i, key in ipairs(keys) do
        local y = 74 + (i - 1) * 34
        newLabel(card, {
            Position = UDim2.fromOffset(16, y),
            Size = UDim2.fromOffset(16, 24),
            Text = letters[i],
            TextSize = 13,
            Font = Enum.Font.GothamBold,
        })
        local trackF = new("Frame", {
            Position = UDim2.new(0, 38, 0, y + 9),
            Size = UDim2.new(1, -100, 0, 6),
            BackgroundColor3 = T.Off,
        }, card)
        corner(trackF, 3)
        ustroke(trackF, 1, 0.65, 0.3)
        skin(trackF, {BackgroundTransparency = 0}, {BackgroundTransparency = 0.3})

        local pct0 = Config[key] / 255
        local fill = new("Frame", {
            Size = UDim2.fromScale(pct0, 1),
            BackgroundColor3 = cols[i],
        }, trackF)
        corner(fill, 3)
        local knob = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(pct0, 0.5),
            Size = UDim2.fromOffset(14, 14),
            BackgroundColor3 = T.Glass,
        }, trackF)
        corner(knob, 7)
        ustroke(knob, 2, 0, 0.35, {plain = true, gColor = T.Ink})

        local val = newLabel(card, {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -14, 0, y),
            Size = UDim2.fromOffset(36, 24),
            Text = tostring(Config[key]),
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
        local hit = new("TextButton", {
            Position = UDim2.new(0, 30, 0, y - 4),
            Size = UDim2.new(1, -90, 0, 32),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 3,
        }, card)
        rows[i] = {key = key, fill = fill, knob = knob, val = val}

        local function fromX(x)
            local rel = math.clamp((x - trackF.AbsolutePosition.X) / math.max(trackF.AbsoluteSize.X, 1), 0, 1)
            Config[key] = math.floor(rel * 255 + 0.5)
            refreshAll()
        end
        hit.InputBegan:Connect(function(input)
            if not isPress(input) then return end
            page.ScrollingEnabled = false
            tween(knob, {Size = UDim2.fromOffset(19, 19)}, 0.2, Enum.EasingStyle.Back)
            fromX(input.Position.X)
            beginDrag(function(pos) fromX(pos.X) end, function()
                page.ScrollingEnabled = true
                tween(knob, {Size = UDim2.fromOffset(14, 14)}, 0.2)
            end)
        end)
    end

    local shown, tok = false, 0
    local function update()
        local on = isActive() and true or false
        if on == shown then return end
        shown = on
        tok += 1
        local my = tok
        if on then
            card.Visible = true
            tween(card, {Size = UDim2.new(1, 0, 0, H)}, 0.5, Enum.EasingStyle.Quint)
        else
            tween(card, {Size = UDim2.new(1, 0, 0, 0)}, 0.35, Enum.EasingStyle.Quint)
            task.delay(0.37, function()
                if tok == my then card.Visible = false end
            end)
        end
    end
    return card, update
end

local function anyESPOn()
    return Config.ESP or Config.ESPLine or Config.ESPBox
        or Config.ESPChams or Config.ESPHealth or Config.ESPDistance
end

local espColorUpdate, lockColorUpdate

local function makeESPColorCard(page)
    local _, upd = makeColorCard(page, "ESP Color",
        {"ESPColorR", "ESPColorG", "ESPColorB"},
        {
            Color3.fromRGB(255, 190, 82), Color3.fromRGB(255, 70, 70), Color3.fromRGB(70, 230, 120),
            Color3.fromRGB(70, 200, 255), Color3.fromRGB(170, 120, 255), Color3.fromRGB(255, 255, 255),
        },
        "__espcolor", anyESPOn)
    espColorUpdate = upd
end

-- Warna ESP saat target sedang di-lock aim assist. Terpisah total dari ESP Color.
local function makeLockColorCard(page)
    local _, upd = makeColorCard(page, "Lock Color",
        {"LockColorR", "LockColorG", "LockColorB"},
        {
            Color3.fromRGB(255, 72, 104), Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(70, 230, 120), Color3.fromRGB(70, 200, 255), Color3.fromRGB(170, 120, 255),
        },
        "__lockcolor", function() return anyESPOn() and Config.LockColor end)
    lockColorUpdate = upd
end

-- ========== VISUAL TAB ==========
makeSection(VisualPage, "ESP")
makeToggle(VisualPage, "ESP Master", "ESP", function(on)
    setToggle("ESPLine", on)
    setToggle("ESPBox", on)
    setToggle("ESPChams", on)
    setToggle("ESPHealth", on)
    setToggle("ESPDistance", on)
end)
makeToggle(VisualPage, "ESP Line", "ESPLine")
makeToggle(VisualPage, "ESP Box", "ESPBox")
makeToggle(VisualPage, "ESP Chams", "ESPChams")
makeToggle(VisualPage, "ESP Health", "ESPHealth")
makeToggle(VisualPage, "ESP Distance", "ESPDistance")
makeESPColorCard(VisualPage)
makeSlider(VisualPage, "Chams Thickness", "ChamsThickness", 5, 100)
makeSection(VisualPage, "Target Lock")
makeToggle(VisualPage, "Lock Color", "LockColor")
makeLockColorCard(VisualPage)
makeToggle(VisualPage, "Lock Animation", "LockAnim")
espColorRefresh = function()
    if espColorUpdate then espColorUpdate() end
    if lockColorUpdate then lockColorUpdate() end
end
espColorRefresh()
makeSection(VisualPage, "Filter")
makeToggle(VisualPage, "Team Check", "ESPTeamCheck", function(on)
    if on and not LP.Team then
        warn("[NovaXHub] LP.Team = nil. Game tidak pakai Team, Team Check tidak akan hide siapapun.")
    end
end)
makeSlider(VisualPage, "ESP Range", "ESPRange", 50, 2000)

-- ========== AIM TAB ==========
makeSection(AimPage, "Aim Assist")
makeToggle(AimPage, "Aim Assist", "AimAssist")
makeDropdown(AimPage, "Aim Mode", "AimMode", {"Camera", "Camera + Character"})
makeSlider(AimPage, "Aim Smoothness", "AimSmoothness", 1, 30)
makeSlider(AimPage, "Aim Range", "AimRange", 50, 2000)
makeSlider(AimPage, "Aim FOV", "AimFov", 30, 500)
makeToggle(AimPage, "Aim Close Priority", "AimClosePriority")
makeToggle(AimPage, "Lock Target", "LockTarget")
makeDropdown(AimPage, "Aim Place", "AimPlace",
    {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"})
makeSection(AimPage, "Filter")
makeToggle(AimPage, "Team Check", "AimTeamCheck", function(on)
    if on and not LP.Team then
        warn("[NovaXHub] LP.Team = nil. Aim Team Check tidak akan skip siapapun.")
    end
end)
makeToggle(AimPage, "Wall Check", "AimWallCheck")
makeToggle(AimPage, "Wall Check Multi-Point", "AimWallMultiPoint")
makeToggle(AimPage, "Wall Lock Grace", "AimWallGrace")
makeSlider(AimPage, "Wall Grace Time (ms)", "AimWallGraceTime", 50, 3000, nil, 10)
makeToggle(AimPage, "Vehicle Check", "AimVehicleCheck")
makeSection(AimPage, "Prediction")
makeToggle(AimPage, "Aim Predict", "AimPredict", function(on)
    if not on and predictDot then predictDot.Visible = false end
end)
makeSlider(AimPage, "Prediction Lead (ms)", "AimPredictLead", 0, 350)
makeSlider(AimPage, "Max Prediction Offset", "AimPredictMaxDist", 10, 150)

-- ========== MISC TAB ==========
makeSection(MiscPage, "Movement")
makeToggle(MiscPage, "Infinite Jump", "InfiniteJump")
makeToggle(MiscPage, "TpWalk", "TpWalk")
makeSlider(MiscPage, "TpWalk Speed", "TpWalkSpeed", 16, 500)
makeToggle(MiscPage, "Noclip", "Noclip")
makeSection(MiscPage, "Fly")
makeToggle(MiscPage, "Fly (Velocity)", "Fly")
makeSlider(MiscPage, "Fly Speed", "FlySpeed", 10, 300)
makeToggle(MiscPage, "CFrame Fly", "CFrameFly")
makeToggle(MiscPage, "CFrame Fly (Joystick)", "CFrameFlyJoy")

do
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(MiscPage),
    }, MiscPage)

    local function holdButton(txt, posX, dirV)
        local b = new("TextButton", {
            Position = UDim2.new(posX, posX == 0 and 0 or 4, 0, 0),
            Size = UDim2.new(0.5, -4, 1, 0),
            BackgroundColor3 = T.Glass,
            BackgroundTransparency = cardT(),
            Text = txt,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.Ink,
        }, row)
        corner(b, 13)
        ustroke(b, 1, 0.45, 0.15)
        b.InputBegan:Connect(function(input)
            if not isPress(input) then return end
            flyV = dirV
            tween(b, {BackgroundColor3 = T.Ink, BackgroundTransparency = 0, TextColor3 = T.Glass}, 0.1)
            beginDrag(function() end, function()
                if flyV == dirV then flyV = 0 end
                tween(b, {BackgroundColor3 = T.Glass, BackgroundTransparency = cardT(), TextColor3 = T.Ink}, 0.2)
            end)
        end)
    end
    holdButton("▲  Fly Up", 0, 1)
    holdButton("▼  Fly Down", 0.5, -1)
end

makeSection(MiscPage, "Float")
makeToggle(MiscPage, "Float", "Float")
makeSlider(MiscPage, "Float Height", "FloatHeight", -50, 300)

-- ========== SAVE / LOAD CONFIGURATION ==========
-- ========== SETTINGS TAB ==========
makeSection(SettingsPage, "Window")
makeToggle(SettingsPage, "Full Glass Mode", "GlassMode", function(on) applyGlass(on) end)
makeSlider(SettingsPage, "Menu Width", "MenuWidth", 320, 700, function() applyLayout(false) end)
makeSlider(SettingsPage, "Menu Height", "MenuHeight", 380, 850, function() applyLayout(false) end)
makeButton(SettingsPage, "Center Window", false, function()
    if not (menuOpen and menuSettled) then return end
    local vp = Camera.ViewportSize
    tween(Main, {Position = UDim2.fromOffset(vp.X / 2, vp.Y / 2)}, 0.5, Enum.EasingStyle.Quint)
end)
makeSection(SettingsPage, "Configuration")
do
local CONFIG_DIR  = "NovaXHub"
local CONFIG_FILE = CONFIG_DIR .. "/config.json"

local function saveConfig()
    if type(writefile) ~= "function" then
        return false, "Executor tidak support writefile"
    end
    local data = {}
    for k, v in pairs(Config) do
        local t = type(v)
        if t == "boolean" or t == "number" or t == "string" then data[k] = v end
    end
    local ok, err = pcall(function()
        if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(CONFIG_DIR) then
            makefolder(CONFIG_DIR)
        end
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
    if not ok then return false, "Gagal menyimpan: " .. tostring(err) end
    return true, "Config tersimpan (" .. CONFIG_FILE .. ")"
end

local function loadConfig()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then
        return false, "Executor tidak support readfile"
    end
    local okE, exists = pcall(isfile, CONFIG_FILE)
    if not okE or not exists then return false, "Belum ada config tersimpan" end
    local okR, raw = pcall(readfile, CONFIG_FILE)
    if not okR or type(raw) ~= "string" then return false, "Gagal membaca file config" end
    local okD, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not okD or type(data) ~= "table" then return false, "File config rusak" end

    local applied = 0
    for key, default in pairs(Config) do
        local v = data[key]
        if v ~= nil and type(v) == type(default) then
            if type(v) == "number" then
                local r = sliderRanges[key]
                if r then v = math.clamp(v, r[1], r[2]) end
                if key == "ESPColorR" or key == "ESPColorG" or key == "ESPColorB"
                    or key == "LockColorR" or key == "LockColorG" or key == "LockColorB" then
                    v = math.clamp(math.floor(v + 0.5), 0, 255)
                end
            elseif type(v) == "string" and dropdownOptions[key] then
                if not table.find(dropdownOptions[key], v) then continue end
            end
            Config[key] = v
            applied += 1
        end
    end

    -- sinkronkan semua kontrol UI dengan nilai baru
    for _, refresh in pairs(uiRefreshers) do pcall(refresh) end
    pcall(applyGlass, Config.GlassMode)
    pcall(applyLayout, false)
    if espColorRefresh then pcall(espColorRefresh) end
    if refreshQuickDock then pcall(refreshQuickDock) end
    return true, "Config dimuat (" .. applied .. " setting)"
end

    local card = newCard(SettingsPage, 34)
    local status = newLabel(card, {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Text = "Simpan / muat semua pengaturan (Aim, ESP, Misc, Settings).",
        TextSize = 12,
        TextColor3 = T.InkDim,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local function report(ok, msg)
        status.Text = msg
        status.TextColor3 = ok and T.Ink or T.Danger
        if not ok then warn("[NovaXHub] " .. msg) end
    end
    makeButton(SettingsPage, "Save Configuration", false, function() report(saveConfig()) end)
    makeButton(SettingsPage, "Load Configuration", false, function() report(loadConfig()) end)
end
makeSection(SettingsPage, "Floating Quick Toggles")
makeToggle(SettingsPage, "Show Quick Dock", "QuickDockEnabled", function(on)
    if quickDock then quickDock.Visible = on end
end)
do -- dibungkus: batas 200 local di level atas
local quickSlotOptions = {"None", "Aim Assist", "ESP", "Aim Predict", "Fly", "CFrame Fly", "CFrame Fly (Joystick)", "Float", "Noclip", "Infinite Jump", "TpWalk", "Wall Check", "Vehicle Check", "Lock Target"}
makeDropdown(SettingsPage, "Quick Slot 1", "QuickSlot1", quickSlotOptions)
makeDropdown(SettingsPage, "Quick Slot 2", "QuickSlot2", quickSlotOptions)
makeDropdown(SettingsPage, "Quick Slot 3", "QuickSlot3", quickSlotOptions)
makeDropdown(SettingsPage, "Quick Slot 4", "QuickSlot4", quickSlotOptions)
makeDropdown(SettingsPage, "Quick Slot 5", "QuickSlot5", quickSlotOptions)
end
makeSection(SettingsPage, "Info")
do
    local card = newCard(SettingsPage, 64)
    newLabel(card, {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Text = "NovaXHub v5.4\nNova Island UI. RightShift untuk buka/tutup.",
        TextSize = 12,
        TextColor3 = T.InkDim,
        TextWrapped = true,
    })
end
makeSection(SettingsPage, "Danger")
makeButton(SettingsPage, "Unload NovaXHub", true, function()
    setMenu(false)
    task.delay(0.3, function()
        if unloadHub then pcall(unloadHub) end
    end)
end)

-- ========== FLOATING QUICK-TOGGLE DOCK ==========
-- Tombol mengambang yang tetap tersedia saat menu ditutup. Slot bisa dipilih di Settings.
do -- dibungkus: batas 200 local di level atas
local QUICK_FEATURES = {
    ["Aim Assist"] = {key = "AimAssist", short = "AIM"},
    ["ESP"] = {key = "ESP", short = "ESP"},
    ["Aim Predict"] = {key = "AimPredict", short = "PRED"},
    ["Fly"] = {key = "Fly", short = "FLY"},
    ["CFrame Fly"] = {key = "CFrameFly", short = "CFLY"},
    ["CFrame Fly (Joystick)"] = {key = "CFrameFlyJoy", short = "JFLY"},
    ["Float"] = {key = "Float", short = "FLT"},
    ["Noclip"] = {key = "Noclip", short = "NOCL"},
    ["Infinite Jump"] = {key = "InfiniteJump", short = "JUMP"},
    ["TpWalk"] = {key = "TpWalk", short = "TPW"},
    ["Wall Check"] = {key = "AimWallCheck", short = "WALL"},
    ["Vehicle Check"] = {key = "AimVehicleCheck", short = "VEH"},
    ["Lock Target"] = {key = "LockTarget", short = "LOCK"},
}
local QUICK_SLOT_KEYS = {"QuickSlot1", "QuickSlot2", "QuickSlot3", "QuickSlot4", "QuickSlot5"}
local quickRows = {}

local function quickFeatureOn(featureName)
    if featureName == "ESP" then
        return Config.ESP or Config.ESPLine or Config.ESPBox or Config.ESPChams
            or Config.ESPHealth or Config.ESPDistance
    end
    local feature = QUICK_FEATURES[featureName]
    return feature and Config[feature.key] == true or false
end

local function setQuickFeature(featureName, on)
    local feature = QUICK_FEATURES[featureName]
    if not feature then return end
    if featureName == "ESP" then
        setToggle("ESP", on)
        return
    end
    if on and featureName == "Fly" then setToggle("CFrameFly", false); setToggle("CFrameFlyJoy", false) end
    if on and featureName == "CFrame Fly" then setToggle("Fly", false); setToggle("CFrameFlyJoy", false) end
    if on and featureName == "CFrame Fly (Joystick)" then setToggle("Fly", false); setToggle("CFrameFly", false) end
    setToggle(feature.key, on)
end

quickDock = new("Frame", {
    Name = "NovaXHubQuickDock",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.fromOffset(94, 220),
    BackgroundColor3 = T.Glass,
    BackgroundTransparency = 0.22,
    ZIndex = 100,
    Visible = Config.QuickDockEnabled,
}, ScreenGui)
corner(quickDock, 16)
local quickDockStroke = ustroke(quickDock, 1.4, 0.25, 0.12)
skin(quickDock, {BackgroundTransparency = 0.22}, {BackgroundTransparency = 0.48})

local quickGrip = new("TextButton", {
    Name = "DockGrip",
    Position = UDim2.fromOffset(5, 4),
    Size = UDim2.new(1, -10, 0, 23),
    BackgroundTransparency = 1,
    Text = "•••",
    TextSize = 16,
    Font = Enum.Font.GothamBlack,
    TextColor3 = T.Ink,
    ZIndex = 103,
}, quickDock)
skin(quickGrip, {TextColor3 = T.Ink}, {TextColor3 = T.Glass})

for i, slotKey in ipairs(QUICK_SLOT_KEYS) do
    local row = new("TextButton", {
        Name = "QuickSlot" .. i,
        Position = UDim2.fromOffset(6, 31 + (i - 1) * 36),
        Size = UDim2.new(1, -12, 0, 32),
        BackgroundColor3 = T.Glass,
        BackgroundTransparency = 0.72,
        Text = "",
        ZIndex = 101,
        Visible = false,
    }, quickDock)
    corner(row, 10)
    local rowStroke = ustroke(row, 1, 0.72, 0.55)
    skin(row, {BackgroundTransparency = 0.72}, {BackgroundTransparency = 0.82})

    local label = newLabel(row, {
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -38, 1, 0),
        Text = "",
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = T.Ink,
        ZIndex = 102,
    })
    skin(label, {TextColor3 = T.Ink}, {TextColor3 = T.Glass})

    local trackF = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(25, 14),
        BackgroundColor3 = T.Off,
        ZIndex = 102,
    }, row)
    corner(trackF, 7)
    local trackStroke = ustroke(trackF, 0.8, 0.6, 0.35)
    local activeFill = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = T.Ink,
        BackgroundTransparency = 1,
        ZIndex = 103,
    }, trackF)
    corner(activeFill, 7)
    skin(activeFill, {BackgroundColor3 = T.Ink}, {BackgroundColor3 = T.Glass})
    local knob = new("Frame", {
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = T.Glass,
        ZIndex = 104,
    }, trackF)
    corner(knob, 5)
    local knobStroke = ustroke(knob, 0.8, 0.3, 0.55, {plain = true, gColor = T.Ink})
    quickRows[i] = {
        row = row, label = label, track = trackF, activeFill = activeFill,
        knob = knob, stroke = rowStroke, slotKey = slotKey,
    }
    row.Activated:Connect(function()
        local featureName = Config[slotKey]
        if not QUICK_FEATURES[featureName] then return end
        setQuickFeature(featureName, not quickFeatureOn(featureName))
        if refreshQuickDock then refreshQuickDock() end
    end)
end

refreshQuickDock = function()
    if not quickDock or not quickDock.Parent then return end
    local shown = 0
    for _, entry in ipairs(quickRows) do
        local featureName = Config[entry.slotKey]
        local feature = QUICK_FEATURES[featureName]
        local visible = feature ~= nil
        entry.row.Visible = visible
        if visible then
            shown += 1
            entry.row.Position = UDim2.fromOffset(6, 31 + (shown - 1) * 36)
            entry.label.Text = feature.short
            local on = quickFeatureOn(featureName)
            tween(entry.row, {BackgroundTransparency = on and (glassMode and 0.58 or 0.42) or (glassMode and 0.82 or 0.72)}, 0.16)
            tween(entry.activeFill, {BackgroundTransparency = on and 0 or 1}, 0.16)
            tween(entry.knob, {Position = on and UDim2.fromOffset(13, 2) or UDim2.fromOffset(2, 2)}, 0.22, Enum.EasingStyle.Back)
            tween(entry.track, {BackgroundColor3 = on and (glassMode and T.Glass or T.Ink) or T.Off}, 0.16)
            tween(entry.label, {TextColor3 = glassMode and T.Glass or T.Ink}, 0.16)
            tween(entry.stroke, {Transparency = on and 0.24 or 0.72}, 0.16)
        end
    end
    quickDock.Size = UDim2.fromOffset(94, math.max(42, 35 + shown * 36))
    quickDock.Visible = Config.QuickDockEnabled
end

table.insert(glassHooks, function()
    if refreshQuickDock then refreshQuickDock() end
end)

quickGrip.InputBegan:Connect(function(input)
    if not isPress(input) then return end
    local startPos = input.Position
    local abs = quickDock.AbsolutePosition
    local startX = abs.X + quickDock.AbsoluteSize.X
    local startY = abs.Y + quickDock.AbsoluteSize.Y / 2
    beginDrag(function(pos)
        local vp = Camera.ViewportSize
        local halfH = quickDock.AbsoluteSize.Y / 2
        local x = clampRange(startX + pos.X - startPos.X, quickDock.AbsoluteSize.X + 4, vp.X - 4)
        local y = clampRange(startY + pos.Y - startPos.Y, halfH + 4, vp.Y - halfH - 4)
        quickDock.Position = UDim2.fromOffset(x, y)
    end, function() end)
end)
refreshQuickDock()
end

-- ========== ISLAND INTERAKSI ==========
-- Tap = buka menu (morph dari pill). Tahan + geser = pindahkan island.
local islandMoved = false

IslandBtn.MouseEnter:Connect(function()
    if closedSettled and not islandDragging then
        tween(Main, {Size = UDim2.fromOffset(ISL_W + 14, ISL_H + 4)}, 0.35, Enum.EasingStyle.Back)
    end
end)
IslandBtn.MouseLeave:Connect(function()
    if closedSettled then
        tween(Main, {Size = UDim2.fromOffset(ISL_W, ISL_H)}, 0.3, Enum.EasingStyle.Back)
    end
end)

IslandBtn.InputBegan:Connect(function(input)
    if not isPress(input) or not closedSettled then return end
    islandMoved = false
    local startPos = input.Position
    local bx, by = orbBase.X, orbBase.Y
    beginDrag(function(pos)
        local dx, dy = pos.X - startPos.X, pos.Y - startPos.Y
        if not islandMoved and (dx * dx + dy * dy) > 64 then
            islandMoved = true
            islandDragging = true
        end
        if islandMoved then
            local x, y = clampIsland(bx + dx, by + dy)
            orbBase = Vector2.new(x, y)
        end
    end, function()
        islandDragging = false
    end)
end)

IslandBtn.Activated:Connect(function()
    if islandMoved then islandMoved = false return end
    setMenu(true)
end)

MinBtn.Activated:Connect(function() setMenu(false) end)
CloseBtn.Activated:Connect(function()
    setMenu(false)
    task.delay(0.3, function()
        if unloadHub then
            local ok, err = pcall(unloadHub)
            if not ok then warn("[NovaXHub] unload error: " .. tostring(err)) end
        end
    end)
end)

track(UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then setMenu(not menuOpen) end
end))

-- ========== ESP SYSTEM ==========
-- b1..b8 = corner bracket animasi lock-on (4 sudut x 2 garis)
local ESP_FIELDS = {"line", "box", "name", "dist", "hbg", "hbf",
    "b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8"}
local espColor = Color3.fromRGB(Config.ESPColorR, Config.ESPColorG, Config.ESPColorB)
local lockColor = Color3.fromRGB(Config.LockColorR, Config.LockColorG, Config.LockColorB)

-- Player yang sedang di-lock aim assist (nil = tidak ada). Diisi oleh loop aim di bawah,
-- dibaca oleh ESP untuk mengganti warna + memicu animasi lock-on.
local lockedTarget = nil

local LOCK_IN, LOCK_OUT = 14, 8      -- kecepatan fade warna masuk / keluar (exp smoothing)
local LOCK_ACQ_TIME = 0.34           -- durasi bracket menyempit saat target baru ter-lock

local function easeOutCubic(x)
    return 1 - (1 - x) ^ 3
end

local function createESP(plr)
    if plr == LP or espObjects[plr] then return end
    local obj = {lockA = 0, acq = 1, wasLocked = false}
    if DrawingLib then
        obj.line = DrawingLib.new("Line")
        obj.line.Thickness = 1
        obj.line.Color = T.Amber
        obj.line.Transparency = 1
        obj.line.Visible = false

        obj.box = DrawingLib.new("Square")
        obj.box.Thickness = 1
        obj.box.Color = T.Amber
        obj.box.Transparency = 1
        obj.box.Filled = false
        obj.box.Visible = false

        obj.name = DrawingLib.new("Text")
        obj.name.Size = 14; obj.name.Center = true
        obj.name.Outline = true; obj.name.Color = WHITE
        obj.name.Visible = false

        obj.dist = DrawingLib.new("Text")
        obj.dist.Size = 12; obj.dist.Center = true
        obj.dist.Outline = true; obj.dist.Color = T.Amber
        obj.dist.Visible = false

        obj.hbg = DrawingLib.new("Square")
        obj.hbg.Filled = true; obj.hbg.Color = Color3.new(0, 0, 0)
        obj.hbg.Transparency = 1; obj.hbg.Visible = false

        obj.hbf = DrawingLib.new("Square")
        obj.hbf.Filled = true; obj.hbf.Color = Color3.fromRGB(0, 255, 0)
        obj.hbf.Transparency = 1; obj.hbf.Visible = false

        for i = 1, 8 do
            local b = DrawingLib.new("Line")
            b.Thickness = 1.5
            b.Color = T.Amber
            b.Transparency = 1
            b.Visible = false
            obj["b" .. i] = b
        end
    end
    espObjects[plr] = obj
end

-- ===== Chams: deteksi "keliatan di kita" =====
-- Chams tetap tembus tembok (Highlight AlwaysOnTop). Warnanya berubah MERAH hanya kalau
-- minimal satu bagian badan musuh terlihat dari kamera kita (raycast), selain itu pakai
-- warna ESP. TIDAK terhubung ke Target Lock / aim assist.
-- Raycast "pintar": part transparan (kaca, hitbox) dan benda yang menempel di kamera (<2 stud)
-- tidak dianggap tembok; karakter semua player juga diabaikan.
local chamsCanSee
do
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    pcall(function() rayParams.RespectCanCollide = true end)

    local baseFilter = {}
    local lastFilter = 0
    local function refreshFilter(now)
        if now - lastFilter < 0.25 then return end
        lastFilter = now
        table.clear(baseFilter)
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character then baseFilter[#baseFilter + 1] = pl.Character end
        end
        rayParams.FilterDescendantsInstances = baseFilter
    end

    local function pointVisible(origin, point)
        local extra
        local result = false
        for _ = 1, 3 do
            local hit = workspace:Raycast(origin, point - origin, rayParams)
            if not hit then result = true; break end
            local inst = hit.Instance
            if inst:IsA("Terrain") then break end
            if inst.Transparency >= 0.6 or (hit.Position - origin).Magnitude < 2 then
                if not extra then extra = table.clone(baseFilter) end
                extra[#extra + 1] = inst
                rayParams.FilterDescendantsInstances = extra
            else
                break
            end
        end
        if extra then rayParams.FilterDescendantsInstances = baseFilter end
        return result
    end

    chamsCanSee = function(char)
        refreshFilter(os.clock())
        local origin = Camera.CFrame.Position
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 0.95 then
                if pointVisible(origin, part.Position) then return true end
                local top = (part.CFrame * CFrame.new(0, part.Size.Y * 0.4, 0)).Position
                if pointVisible(origin, top) then return true end
            end
        end
        return false
    end
end

local function clearHighlight(obj)
    if obj.highlight then
        pcall(function() obj.highlight:Destroy() end)
        obj.highlight = nil
    end
    obj.seen, obj.visA, obj.visT = nil, nil, nil
end

local function removeESP(plr)
    local obj = espObjects[plr]
    if not obj then return end
    for _, field in ipairs(ESP_FIELDS) do
        if obj[field] then pcall(function() obj[field]:Remove() end) end
    end
    clearHighlight(obj)
    espObjects[plr] = nil
end

local function hideAll(obj)
    for _, field in ipairs(ESP_FIELDS) do
        if obj[field] then obj[field].Visible = false end
    end
    -- reset state lock supaya animasi mulai bersih saat player muncul lagi
    obj.lockA, obj.acq, obj.wasLocked = 0, 1, false
end

local BOX_HALF = Vector3.new(2, 3, 2)
local function getBoundingBox(hrp)
    local cf = hrp.CFrame
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local anyVisible = false
    for xi = -1, 1, 2 do
        for yi = -1, 1, 2 do
            for zi = -1, 1, 2 do
                local wp = cf:PointToWorldSpace(Vector3.new(xi * BOX_HALF.X, yi * BOX_HALF.Y, zi * BOX_HALF.Z))
                local sp = Camera:WorldToViewportPoint(wp)
                if sp.Z > 0 then
                    anyVisible = true
                    minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
                    maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
                end
            end
        end
    end
    if not anyVisible then return nil end
    return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

-- Corner bracket lock-on: 4 sudut, tiap sudut 2 garis (horizontal + vertikal).
local BRACKET_CORNERS = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}}

local function drawLockBrackets(obj, tl, br, boxSize, acq, vis, col)
    -- Mulai agak di luar box, menyempit (ease-out) ke posisi akhir. Panjang sudut ikut tumbuh.
    local e = easeOutCubic(acq)
    local pad = 3 + (1 - e) * 12
    local len = math.clamp(math.min(boxSize.X, boxSize.Y) * 0.22, 6, 16) * (0.65 + 0.35 * e)
    local x1, y1 = tl.X - pad, tl.Y - pad
    local x2, y2 = br.X + pad, br.Y + pad

    for i, c in ipairs(BRACKET_CORNERS) do
        local sx, sy = c[1], c[2]
        local cx = sx < 0 and x1 or x2
        local cy = sy < 0 and y1 or y2
        local h, v = obj["b" .. (i * 2 - 1)], obj["b" .. (i * 2)]
        if h then
            h.From = Vector2.new(cx, cy)
            h.To = Vector2.new(cx - sx * len, cy)
            h.Color = col
            h.Transparency = vis
            h.Visible = true
        end
        if v then
            v.From = Vector2.new(cx, cy)
            v.To = Vector2.new(cx, cy - sy * len)
            v.Color = col
            v.Transparency = vis
            v.Visible = true
        end
    end
end

local function updateESPObject(plr, obj, dt)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not (hum and hrp) or hum.Health <= 0
        or (Config.ESPTeamCheck and isTeammate(plr)) then
        hideAll(obj); clearHighlight(obj)
        return
    end

    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if dist > Config.ESPRange then
        hideAll(obj); clearHighlight(obj)
        return
    end

    -- ===== Target Lock: state animasi per-player =====
    -- lockA   : 0..1, fade halus saat target masuk / keluar lock
    -- acq     : 0..1, progres bracket menyempit (di-reset tiap target BARU ter-lock)
    local locked = lockedTarget == plr and (Config.LockColor or Config.LockAnim)
    local goal = locked and 1 or 0
    local lockA = obj.lockA
    lockA += (goal - lockA) * (1 - math.exp(-(goal > lockA and LOCK_IN or LOCK_OUT) * dt))
    if math.abs(goal - lockA) < 0.003 then lockA = goal end
    obj.lockA = lockA
    if locked then
        if not obj.wasLocked then obj.acq = 0 end
        obj.acq = math.min(obj.acq + dt / LOCK_ACQ_TIME, 1)
    end
    obj.wasLocked = locked and true or false

    local colorA = Config.LockColor and lockA or 0           -- seberapa kuat warna berubah
    local animA = Config.LockAnim and lockA or 0             -- seberapa kuat animasi
    local pulse = 0.5 + 0.5 * math.sin(os.clock() * 3.4)     -- napas pelan 0..1
    local col = espColor:Lerp(lockColor, colorA)

    if Config.ESPChams then
        if not obj.highlight or obj.highlight.Parent ~= char then
            clearHighlight(obj)
            local h = Instance.new("Highlight")
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = espColor
            h.OutlineColor = espColor
            h.FillTransparency = 0.55
            h.OutlineTransparency = 0
            h.Adornee = char
            h.Parent = char
            obj.highlight = h
            obj.visA = 0
        end
        -- warna ikut "keliatan di kita atau tidak" (bukan ikut aim assist), transisi halus
        local now = os.clock()
        if now - (obj.visT or 0) >= 0.066 then
            obj.visT = now
            obj.seen = chamsCanSee(char)
        end
        local seeGoal = obj.seen and 1 or 0
        local va = obj.visA or 0
        va += (seeGoal - va) * (1 - math.exp(-14 * math.clamp(dt, 0, 0.1)))
        obj.visA = va
        local cc = espColor:Lerp(lockColor, va)   -- warna "keliatan" = RGB dari kartu Lock Color
        obj.highlight.FillColor = cc
        obj.highlight.OutlineColor = cc
        -- slider "Chams Thickness": makin besar = fill makin tebal/solid
        obj.highlight.FillTransparency = 1 - math.clamp(Config.ChamsThickness, 0, 100) / 100
    else
        clearHighlight(obj)
    end

    local tl, br = getBoundingBox(hrp)
    if not tl then hideAll(obj) return end
    local boxSize = br - tl
    local lineW = 1 + 0.6 * animA
    if obj.line then obj.line.Color = col; obj.line.Thickness = lineW end
    if obj.box then obj.box.Color = col; obj.box.Thickness = lineW end
    if obj.dist then obj.dist.Color = col end
    if obj.name then obj.name.Color = WHITE:Lerp(lockColor, colorA * 0.8) end

    if obj.line then
        local show = false
        if Config.ESPLine then
            local head = char:FindFirstChild("Head") or hrp
            local hp = Camera:WorldToViewportPoint(head.Position)
            if hp.Z > 0 then
                local vp = Camera.ViewportSize
                obj.line.From = Vector2.new(vp.X / 2, vp.Y)
                obj.line.To = Vector2.new(hp.X, hp.Y)
                show = true
            end
        end
        obj.line.Visible = show
    end
    if obj.box then
        obj.box.Visible = Config.ESPBox
        if Config.ESPBox then
            obj.box.Position = tl
            obj.box.Size = boxSize
        end
    end
    if obj.name then
        obj.name.Visible = Config.ESPBox
        if Config.ESPBox then
            obj.name.Text = plr.Name
            obj.name.Position = Vector2.new(tl.X + boxSize.X / 2, tl.Y - 16)
        end
    end

    -- bracket lock-on (muncul hanya selama / sesaat setelah target ter-lock)
    if obj.b1 then
        if animA > 0.01 then
            drawLockBrackets(obj, tl, br, boxSize, obj.acq, animA * (0.78 + 0.22 * pulse), col)
        else
            for i = 1, 8 do
                local b = obj["b" .. i]
                if b then b.Visible = false end
            end
        end
    end
    if obj.dist then
        obj.dist.Visible = Config.ESPDistance
        if Config.ESPDistance then
            obj.dist.Text = math.floor(dist) .. "m"
            obj.dist.Position = Vector2.new(tl.X + boxSize.X / 2, br.Y + 2)
        end
    end
    if obj.hbg and obj.hbf then
        obj.hbg.Visible = Config.ESPHealth
        obj.hbf.Visible = Config.ESPHealth
        if Config.ESPHealth then
            local p = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            obj.hbg.Position = Vector2.new(tl.X - 6, tl.Y)
            obj.hbg.Size = Vector2.new(3, boxSize.Y)
            obj.hbf.Position = Vector2.new(tl.X - 6, tl.Y + boxSize.Y * (1 - p))
            obj.hbf.Size = Vector2.new(3, boxSize.Y * p)
            obj.hbf.Color = Color3.fromRGB(255 * (1 - p), 255 * p, 0)
        end
    end
end

local espWasActive = false
track(RS.RenderStepped:Connect(function(dt)
    local any = Config.ESPLine or Config.ESPBox or Config.ESPChams
        or Config.ESPHealth or Config.ESPDistance
    if not any then
        if espWasActive then
            for _, obj in pairs(espObjects) do hideAll(obj); clearHighlight(obj) end
            espWasActive = false
        end
        return
    end
    espWasActive = true
    espColor = Color3.fromRGB(Config.ESPColorR, Config.ESPColorG, Config.ESPColorB)
    lockColor = Color3.fromRGB(Config.LockColorR, Config.LockColorG, Config.LockColorB)
    dt = math.clamp(dt, 0, 0.1)
    if not DrawingLib and not Config.ESPChams then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not espObjects[plr] then createESP(plr) end
    end
    for plr, obj in pairs(espObjects) do
        if not plr.Parent then
            removeESP(plr)
        else
            updateESPObject(plr, obj, dt)
        end
    end
end))

track(Players.PlayerRemoving:Connect(removeESP))

-- ========== AIM PREDICT ==========
-- Prediksi v2:
--  * Kecepatan DIUKUR dari riwayat posisi (jendela ~0.15 dtk), bukan AssemblyLinearVelocity
--    yang sering noisy/0 di player lain. Jendela waktu juga menghindari efek "0 / lompat"
--    karena posisi player lain cuma diupdate ~20-60x/dtk sementara render jalan lebih cepat.
--  * Kecepatan dihaluskan (EMA) + deadzone, jadi titik bidik tidak bergetar saat target diam.
--  * Horizontal: posisi + v * lead. Vertikal: hanya dipakai saat target di udara dan memakai
--    parabola gravitasi (v*t - 1/2*g*t^2), bukan lurus, jadi lompatan tidak bikin aim "loncat".
--  * Kendaraan: diukur dari kursi/root kendaraan.
--  * Reset otomatis kalau ganti target / teleport / lama tidak diupdate.
-- (dibungkus do-block: Lua membatasi 200 variabel local di level atas file)
local getPredictedPosition
do
    local PRED_WINDOW = 0.15       -- detik riwayat posisi yang dipakai
    local PRED_SMOOTH = 16         -- makin besar = makin responsif, makin kecil = makin halus
    local PRED_DEADZONE = 1.5      -- stud/dtk; di bawah ini dianggap diam
    local PRED_TELEPORT = 40       -- lompatan posisi antar-sample (stud) yang dianggap teleport

    local predState = {root = nil, samples = {}, vel = Vector3.zero}

    local function resetPredState(root)
        predState.root = root
        predState.samples = {}
        predState.vel = Vector3.zero
    end

    getPredictedPosition = function(part, dt)
        if not Config.AimPredict or not part then return part and part.Position end

        local character = part:FindFirstAncestorOfClass("Model")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local seat = humanoid and humanoid.SeatPart
        local root = seat or (character and character:FindFirstChild("HumanoidRootPart")) or part

        if predState.root ~= root then resetPredState(root) end

        local now = os.clock()
        local samples = predState.samples
        local pos = root.Position

        -- buang sample yang terlalu lama; kalau semuanya basi, mulai dari nol
        while #samples > 0 and now - samples[1].t > PRED_WINDOW do
            table.remove(samples, 1)
        end
        if #samples == 0 then predState.vel = Vector3.zero end

        -- teleport / respawn: jangan hitung sebagai kecepatan
        local last = samples[#samples]
        if last and (pos - last.p).Magnitude > PRED_TELEPORT then
            samples = {}
            predState.samples = samples
            predState.vel = Vector3.zero
        end
        samples[#samples + 1] = {t = now, p = pos}

        local oldest = samples[1]
        local span = now - oldest.t
        if span >= 0.03 then
            local raw = (pos - oldest.p) / span
            local k = 1 - math.exp(-math.clamp(dt or 0.016, 0, 0.1) * PRED_SMOOTH)
            predState.vel = predState.vel:Lerp(raw, k)
        end

        local vel = predState.vel
        local lead = math.clamp(Config.AimPredictLead / 1000, 0, 0.35)

        -- horizontal
        local hvel = Vector3.new(vel.X, 0, vel.Z)
        if hvel.Magnitude < PRED_DEADZONE then hvel = Vector3.zero end
        local offset = hvel * lead

        -- vertikal
        if seat then
            offset += Vector3.new(0, vel.Y * lead, 0)
        elseif humanoid and humanoid.FloorMaterial == Enum.Material.Air then
            offset += Vector3.new(0, vel.Y * lead - 0.5 * workspace.Gravity * lead * lead, 0)
        end

        local maxOffset = math.max(Config.AimPredictMaxDist, 0)
        if maxOffset == 0 then
            offset = Vector3.zero
        elseif offset.Magnitude > maxOffset then
            offset = offset.Unit * maxOffset
        end
        return part.Position + offset
    end
end

-- ========== AIM ASSIST ==========
-- Mengembalikan: part yang diaim, jarak layar, jarak dunia, visible (lolos wall check)
-- nil kalau target tidak valid (mati, teammate, di luar range / FOV / layar).
local AIM_BIND = "NovaXHub_Aim"
do -- dibungkus: batas 200 local di level atas
local function getCandidate(plr, camPos, center)
    if plr == LP then return nil end
    if Config.AimTeamCheck and isTeammate(plr) then return nil end
    local char = plr.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    local part = char:FindFirstChild(Config.AimPlace)
    if not part then return nil end
    -- Range = jarak 3D dari kamera (semua arah, termasuk ke atas/bawah)
    local dist = (camPos - part.Position).Magnitude
    if dist > Config.AimRange then return nil end
    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return nil end
    local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
    if sd > Config.AimFov then return nil end

    local visible = true
    if Config.AimWallCheck then
        local seen = resolveVisiblePart(char, plr, part)
        visible = seen ~= nil
        if seen then part = seen end
    end
    return part, sd, dist, visible
end

local function getClosestTarget()
    local bestPart, bestPlr, bestScore = nil, nil, math.huge
    local center = Camera.ViewportSize / 2
    local camPos = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        local part, sd, dist, visible = getCandidate(plr, camPos, center)
        if not part or not visible then continue end
        -- Close Priority: yang paling dekat (jarak dunia) menang, bukan yang paling dekat crosshair.
        local score = Config.AimClosePriority and dist or sd
        if score < bestScore then
            bestPart, bestPlr, bestScore = part, plr, score
        end
    end
    return bestPart, bestPlr
end

-- Wall Lock Grace: target terakhir yang di-aim tetap dipegang beberapa saat setelah
-- tertutup tembok, dan selama itu aim TIDAK pindah ke target lain.
local lockPlayer, lockLastSeen = nil, 0

-- Lock Target: saat toggle dinyalakan, target yang sedang di-aim dikunci dan PRIORITAS
-- di atas semua fitur lain (Wall Check, Grace, FOV, Range, Close Priority). Tidak pindah
-- ke target lain sampai target mati / keluar, atau toggle dimatikan.
local hardLockPlayer = nil

local function getHardLockPart(plr)
    if not plr or plr.Parent ~= Players then return nil end
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    return char:FindFirstChild(Config.AimPlace) or char:FindFirstChild("HumanoidRootPart")
end

local function pickTarget()
    local now = os.clock()
    if Config.LockTarget then
        -- ambil target yang sedang di-aim saat toggle baru dinyalakan
        if not hardLockPlayer and lockPlayer and getHardLockPart(lockPlayer) then
            hardLockPlayer = lockPlayer
        end
        if hardLockPlayer then
            local part = getHardLockPart(hardLockPlayer)
            if part then
                lockPlayer = hardLockPlayer
                lockLastSeen = now
                return part
            end
            hardLockPlayer = nil   -- target mati / keluar: lepas, lock ke target berikutnya
        end
    else
        hardLockPlayer = nil
    end
    if lockPlayer and Config.AimWallGrace and Config.AimWallCheck then
        local part, _, _, visible = getCandidate(lockPlayer, Camera.CFrame.Position, Camera.ViewportSize / 2)
        if part then
            if visible then
                lockLastSeen = now
            elseif now - lockLastSeen <= Config.AimWallGraceTime / 1000 then
                return part   -- masih dalam masa grace: tetap ikuti target yang bersembunyi
            end
        end
    end
    local part, plr = getClosestTarget()
    lockPlayer = plr
    if plr then
        lockLastSeen = now
        if Config.LockTarget then hardLockPlayer = plr end
    end
    return part
end

local function cleanupBodyRotation()
    if bodyGyro then pcall(function() bodyGyro:Destroy() end); bodyGyro = nil end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
    bodyRotationActive = false
end

pcall(function() RS:UnbindFromRenderStep(AIM_BIND) end)
RS:BindToRenderStep(AIM_BIND, Enum.RenderPriority.Camera.Value + 1, function(dt)
    local espSharedColor = Color3.fromRGB(Config.ESPColorR, Config.ESPColorG, Config.ESPColorB)
    if fovCircle then
        fovCircle.Visible = Config.AimAssist
        fovCircle.Position = Camera.ViewportSize / 2
        fovCircle.Radius = Config.AimFov
        fovCircle.Color = espSharedColor
    end

    if predictDot then
        predictDot.Color = espSharedColor
        if not Config.AimPredict or not Config.AimAssist then
            predictDot.Visible = false
        end
    end

    if not Config.AimAssist then
        lockPlayer = nil
        hardLockPlayer = nil
        lockedTarget = nil
        if bodyRotationActive or bodyGyro then cleanupBodyRotation() end
        return
    end

    if Config.AimMode ~= "Camera + Character" and (bodyRotationActive or bodyGyro) then
        cleanupBodyRotation()
    end

    local target = pickTarget()
    lockedTarget = target and lockPlayer or nil   -- dibaca ESP untuk warna + animasi lock-on
    if not target then
        if predictDot then predictDot.Visible = false end
        if bodyRotationActive or bodyGyro then cleanupBodyRotation() end
        return
    end

    local aimPos = Config.AimPredict and getPredictedPosition(target, dt) or target.Position
    if predictDot then
        if Config.AimPredict then
            local sp, onScreen = Camera:WorldToViewportPoint(aimPos)
            predictDot.Visible = onScreen
            if onScreen then predictDot.Position = Vector2.new(sp.X, sp.Y) end
        else
            predictDot.Visible = false
        end
    end

    -- Smoothing berbasis waktu supaya tetap konsisten pada FPS yang berbeda.
    local base = math.clamp(1 / math.max(Config.AimSmoothness, 1), 0.01, 1)
    local alpha = 1 - (1 - base) ^ (math.clamp(dt, 0, 0.1) * 60)
    local cameraTarget = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(cameraTarget, alpha)

    -- Mode kedua mengubah yaw karakter secara langsung, bukan hanya mengarahkan kamera.
    if Config.AimMode == "Camera + Character" then
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            hum.AutoRotate = false
            bodyRotationActive = true
            local flatTarget = Vector3.new(aimPos.X, hrp.Position.Y, aimPos.Z)
            if (flatTarget - hrp.Position).Magnitude > 0.01 then
                local desired = CFrame.lookAt(hrp.Position, flatTarget)
                local _, targetYaw = desired:ToOrientation()
                local _, currentYaw = hrp.CFrame:ToOrientation()
                local yawDelta = math.atan2(math.sin(targetYaw - currentYaw), math.cos(targetYaw - currentYaw))
                local nextYaw = currentYaw + yawDelta * alpha
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, nextYaw, 0)
            end
        elseif bodyRotationActive then
            cleanupBodyRotation()
        end
    elseif bodyRotationActive then
        cleanupBodyRotation()
    end
end)
end

-- ========== INFINITE JUMP ==========
track(UIS.JumpRequest:Connect(function()
    if not Config.InfiniteJump then return end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

-- ========== FLY (Velocity) ==========
track(RS.RenderStepped:Connect(function()
    if not Config.Fly or Config.CFrameFly or Config.CFrameFlyJoy then
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        return
    end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    if not flyBV or flyBV.Parent ~= hrp then
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.P = 10000; flyBG.D = 100
        flyBG.Parent = hrp
    end

    local vel = hum.MoveDirection * Config.FlySpeed
    if flyV ~= 0 then vel += Vector3.new(0, flyV * Config.FlySpeed, 0) end
    if not UIS:GetFocusedTextBox() then
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            vel += Vector3.new(0, Config.FlySpeed, 0)
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            vel -= Vector3.new(0, Config.FlySpeed, 0)
        end
    end
    flyBV.Velocity = vel
    flyBG.CFrame = Camera.CFrame
end))

-- ========== CFrame Fly ==========
track(RS.RenderStepped:Connect(function(dt)
    if not Config.CFrameFly or Config.CFrameFlyJoy then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    hrp.AssemblyLinearVelocity = Vector3.zero

    local newPos = hrp.Position + hum.MoveDirection * Config.FlySpeed * dt
    if flyV ~= 0 then
        newPos += Vector3.new(0, flyV * Config.FlySpeed * dt, 0)
    end
    if not UIS:GetFocusedTextBox() then
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            newPos += Vector3.new(0, Config.FlySpeed * dt, 0)
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            newPos -= Vector3.new(0, Config.FlySpeed * dt, 0)
        end
    end
    hrp.CFrame = CFrame.new(newPos) * (hrp.CFrame - hrp.Position)
end))

-- ========== CFrame Fly (Joystick) ==========
-- Terbang 3D bebas mengikuti arah kamera: joystick/WASD maju = ke arah pandangan kamera
-- (termasuk naik/turun sesuai kemiringan kamera), kiri/kanan = strafe. Speed pakai slider Fly Speed.
track(RS.RenderStepped:Connect(function(dt)
    if not Config.CFrameFlyJoy then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    hrp.AssemblyLinearVelocity = Vector3.zero

    local cam = Camera.CFrame
    local md = hum.MoveDirection
    local move = Vector3.zero
    local flatLook = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)
    local flatRight = Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z)
    if md.Magnitude > 0.01 and flatLook.Magnitude > 0.001 and flatRight.Magnitude > 0.001 then
        local f = md:Dot(flatLook.Unit)
        local r = md:Dot(flatRight.Unit)
        move = cam.LookVector * f + cam.RightVector * r
    end

    local newPos = hrp.Position + move * Config.FlySpeed * dt
    -- tombol naik/turun tetap bisa dipakai sebagai tambahan
    if flyV ~= 0 then newPos += Vector3.new(0, flyV * Config.FlySpeed * dt, 0) end
    if not UIS:GetFocusedTextBox() then
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            newPos += Vector3.new(0, Config.FlySpeed * dt, 0)
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            newPos -= Vector3.new(0, Config.FlySpeed * dt, 0)
        end
    end
    hrp.CFrame = CFrame.new(newPos) * (hrp.CFrame - hrp.Position)
end))

-- ========== FLOAT ==========
-- Melayang di satu ketinggian: ada pijakan tak terlihat di bawah kaki + ketinggian dikunci,
-- jadi tidak jatuh dan tidak "naik pelan-pelan" walau game mencoba mengangkat karakter.
-- Ketinggian diatur slider "Float Height" (relatif terhadap tinggi saat Float dinyalakan).
-- Jalan tetap normal; lompat dibebaskan ~1 detik lalu kembali ke ketinggian float.
do
    local part, wasOn, lastHrp = nil, false, nil
    local baseY, curY, lastJump = 0, 0, 0

    local function destroyPart()
        if part then pcall(function() part:Destroy() end); part = nil end
    end
    track({Disconnect = destroyPart})   -- ikut dibersihkan saat hub di-unload

    track(UIS.JumpRequest:Connect(function() lastJump = os.clock() end))

    track(RS.RenderStepped:Connect(function(dt)
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not Config.Float or not (hrp and hum) or hum.Health <= 0
            or Config.Fly or Config.CFrameFly or Config.CFrameFlyJoy then
            if wasOn then destroyPart(); wasOn = false end
            return
        end

        if not wasOn or lastHrp ~= hrp then
            wasOn, lastHrp = true, hrp
            baseY = hrp.Position.Y - Config.FloatHeight
            curY = hrp.Position.Y
        end

        -- gerak mulus ke ketinggian target saat slider diubah (maks 80 stud/dtk)
        local target = baseY + Config.FloatHeight
        local maxStep = 80 * math.clamp(dt, 0, 0.1)
        curY += math.clamp(target - curY, -maxStep, maxStep)

        local footOff = hum.RigType == Enum.HumanoidRigType.R6 and 3 or (hum.HipHeight + hrp.Size.Y / 2)
        local pos = hrp.Position

        if not part or not part.Parent then
            part = Instance.new("Part")
            part.Name = "NXFloatPad"
            part.Size = Vector3.new(7, 0.5, 7)
            part.Anchored = true
            part.CanCollide = true
            part.CanTouch = false
            part.CanQuery = false
            part.CastShadow = false
            part.Transparency = 1
            part.Parent = workspace
        end
        part.CFrame = CFrame.new(pos.X, curY - footOff - 0.25, pos.Z)

        if os.clock() - lastJump > 1.1 then
            hrp.CFrame = CFrame.new(pos.X, curY, pos.Z) * (hrp.CFrame - hrp.Position)
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
        end
    end))
end

-- ========== TPWALK ==========
track(RS.RenderStepped:Connect(function(dt)
    if not Config.TpWalk then return end
    if Config.Fly or Config.CFrameFly or Config.CFrameFlyJoy then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    if hum.Health <= 0 then return end

    local move = hum.MoveDirection
    if move.Magnitude < 0.01 then return end

    local newPos = hrp.Position + move.Unit * Config.TpWalkSpeed * dt
    hrp.CFrame = CFrame.new(newPos) * (hrp.CFrame - hrp.Position)
    -- jaga kecepatan vertikal supaya lompat & gravitasi tetap jalan
    local v = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
end))

-- ========== NOCLIP ==========
-- Matikan CanCollide semua part karakter tiap Stepped. Part yang tadinya
-- collide dicatat, jadi saat Noclip dimatikan dikembalikan seperti semula.
do -- dibungkus: batas 200 local di level atas
local noclipOrig = setmetatable({}, {__mode = "k"})
local noclipWas = false

local function noclipRestore()
    for part in pairs(noclipOrig) do
        if part and part.Parent then pcall(function() part.CanCollide = true end) end
    end
    table.clear(noclipOrig)
end

track(RS.Stepped:Connect(function()
    if not Config.Noclip then
        if noclipWas then
            noclipWas = false
            noclipRestore()
        end
        return
    end
    noclipWas = true
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            noclipOrig[part] = true
            part.CanCollide = false
        end
    end
end))
track({Disconnect = noclipRestore})   -- kembalikan CanCollide saat hub di-unload
end

-- ========== UNLOAD ==========
unloadHub = function()
    for k, v in pairs(Config) do
        if type(v) == "boolean" then Config[k] = false end
    end
    drag.move, drag.stop = nil, nil
    flyV = 0

    pcall(function() RS:UnbindFromRenderStep(AIM_BIND) end)

    for plr in pairs(espObjects) do removeESP(plr) end
    table.clear(espObjects)
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    if predictDot then pcall(function() predictDot:Remove() end) end

    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end

    if bodyGyro then pcall(function() bodyGyro:Destroy() end); bodyGyro = nil end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end

    if blur then pcall(function() blur:Destroy() end); blur = nil end
    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end

    untrackAll()
    _G.NovaXHub_Running = nil
    _G.NovaXHub_Cleanup = nil
end

_G.NovaXHub_Cleanup = unloadHub

-- ========== INIT ==========
bindCamera()
applyLayout(true)
selectTab("Visual", true)
setMenu(true)
