-- DarlingHub UI dengan toggle interaktif & animasi tekan
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

-- UI Cleanup
if playerGui:FindFirstChild("DarlingHubUI") then
    playerGui:FindFirstChild("DarlingHubUI"):Destroy()
end

-- Buat UI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "DarlingHubUI"
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Active = true
mainFrame.Draggable = true

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Text = "DarlingHub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)

-- Table fitur
local fiturList = {
    "Fly",
    "No Clip",
    "PartName"
}

local toggleStatus = {}

for i, nama in ipairs(fiturList) do
    local frame = Instance.new("Frame", mainFrame)
    frame.Size = UDim2.new(0.8, 0, 0, 30)
    frame.Position = UDim2.new(0.1, 0, 0, 40 + (i - 1) * 40)
    frame.BackgroundTransparency = 1
    frame.Name = nama .. "_Frame"

    local outline = Instance.new("Frame", frame)
    outline.Size = UDim2.new(1, 0, 1, 0)
    outline.Position = UDim2.new(0, 0, 0, 0)
    outline.BackgroundTransparency = 1
    outline.BorderSizePixel = 2
    outline.BorderColor3 = Color3.fromRGB(255, 0, 0)

    local label = Instance.new("TextLabel", frame)
    label.Text = nama
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 18
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 5

    toggleStatus[nama] = false

    button.MouseButton1Click:Connect(function()
        -- Animasi tekan
        local shrink = TweenService:Create(outline, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0.95, 0), Position = UDim2.new(0.025, 0, 0.025, 0)})
        local expand = TweenService:Create(outline, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)})

        shrink:Play()
        shrink.Completed:Connect(function()
            expand:Play()
        end)

        -- Toggle warna outline
        toggleStatus[nama] = not toggleStatus[nama]
        if toggleStatus[nama] then
            outline.BorderColor3 = Color3.fromRGB(0, 255, 0) -- Hijau
        else
            outline.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Merah
        end
    end)
end
