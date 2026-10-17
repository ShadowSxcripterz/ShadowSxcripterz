-- ========================================================
-- AUTO TELEPORT TRUCK (DYNAMIC DESTINATION)
-- Dibuat untuk bypass timer 55.5 detik & anti-rusak
-- ========================================================

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer

-- [PENGATURAN]
local SAFE_TIME = 56.5 -- Waktu aman (di atas 55.5 detik)
local OFFSET_Y = 5     -- Ketinggian biar gak nyangkut tanah

-- [FUNGSI NOTIFIKASI]
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5
        })
    end)
end

-- [FUNGSI CARI KOORDINAT TUJUAN]
local function getDestinationPos()
    -- Cek apakah folder utamanya ada
    local destFolder = workspace:FindFirstChild("Etc")
    if not destFolder then return nil end
    destFolder = destFolder:FindFirstChild("Job")
    if not destFolder then return nil end
    destFolder = destFolder:FindFirstChild("Truck")
    if not destFolder then return nil end
    destFolder = destFolder:FindFirstChild("Destination")
    if not destFolder then return nil end

    -- 1. Cek kalau foldernya sendiri adalah Part
    if destFolder:IsA("BasePart") then
        return destFolder.Position
    end

    -- 2. Cek kalau di dalam folder ada Part atau Vector3Value
    local targetPart = destFolder:FindFirstChildWhichIsA("BasePart", true)
    if targetPart then
        return targetPart.Position
    end

    local targetVec = destFolder:FindFirstChildWhichIsA("Vector3Value", true)
    if targetVec then
        return targetVec.Value
    end

    return nil
end

-- [FUNGSI UTAMA]
local function startTeleport()
    local targetPos = getDestinationPos()
    
    if not targetPos then
        notify("❌ Gagal", "Tujuan gak ketemu! Pastikan lo udah ambil misi.")
        return
    end

    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then
        notify("❌ Gagal", "Lo harus duduk di dalam mobil dulu!")
        return
    end

    local truck = hum.SeatPart:FindFirstAncestorOfClass("Model")
    if not truck or not truck.PrimaryPart then
        notify("❌ Gagal", "Mobil gak terdeteksi dengan benar.")
        return
    end

    -- Ambil alih Network Ownership (Biar gak desync/rubberbanding)
    pcall(function()
        truck.PrimaryPart:SetNetworkOwner(LP)
    end)

    -- Hitung jarak
    local distance = (truck.PrimaryPart.Position - targetPos).Magnitude
    print(string.format("🚚 Jarak: %.1f studs | Meluncur dalam %.1f detik...", distance, SAFE_TIME))
    notify("🚚 Perjalanan Dimulai", "Tunggu " .. SAFE_TIME .. " detik ya.")

    -- Bekukan Fisika Mobil (Anchor)
    local parts = {}
    for _, v in pairs(truck:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = true
            table.insert(parts, v)
        end
    end

    -- Bikin Tween (Animasi jalan)
    local targetCFrame = CFrame.new(targetPos + Vector3.new(0, OFFSET_Y, 0))
    local tweenInfo = TweenInfo.new(SAFE_TIME, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(truck.PrimaryPart, tweenInfo, {CFrame = targetCFrame})

    -- Jalanin Tween
    tween:Play()
    tween.Completed:Wait()

    -- Hidupkan Fisika Lagi
    for _, v in pairs(parts) do
        if v and v.Parent then
            v.Anchored = false
        end
    end

    print("✅ Sampai di tujuan dengan aman!")
    notify("✅ Sampai Tujuan", "Misi siap diselesaikan!")
end

-- [JALANKAN]
startTeleport()
