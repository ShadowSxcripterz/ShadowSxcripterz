
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ScreenGui
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "DarlingHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Main UI Frame (container)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainContainer"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Parent = gui

-- UICorner
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 8)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Text = "DarlingHub"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24

-- Exit Button
local exitBtn = Instance.new("TextButton", mainFrame)
exitBtn.Text = "X"
exitBtn.Size = UDim2.new(0, 30, 0, 30)
exitBtn.Position = UDim2.new(0, 5, 0, 5)
exitBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
exitBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
exitBtn.Font = Enum.Font.GothamBold
exitBtn.TextSize = 18

local exitCorner = Instance.new("UICorner", exitBtn)
exitCorner.CornerRadius = UDim.new(1, 0)

-- Feature Buttons
local features = {"Fly", "No Clip", "PartName"}
for i, name in pairs(features) do
    local holder = Instance.new("Frame", mainFrame)
    holder.Size = UDim2.new(0, 120, 0, 35)
    holder.Position = UDim2.new(0, 20, 0, 60 + (i - 1) * 50)
    holder.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", holder)
    btn.Text = name
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 18

    local outline = Instance.new("UIStroke", holder)
    outline.Color = Color3.fromRGB(255, 0, 0)
    outline.Thickness = 1.5
end

-- Zero Two Icon
local iconBtn = Instance.new("TextButton", gui)
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0.5, -25, 0.85, 0)
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
iconBtn.Text = "02"
iconBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
iconBtn.TextSize = 18
iconBtn.Visible = false

local iconCorner = Instance.new("UICorner", iconBtn)
iconCorner.CornerRadius = UDim.new(1, 0)

-- Fade Out + Bounce
exitBtn.MouseButton1Click:Connect(function()
    local iconPos = iconBtn.AbsolutePosition + iconBtn.AbsoluteSize / 2
    local mainPos = mainFrame.AbsolutePosition + mainFrame.AbsoluteSize / 2

    local direction = (iconPos - mainPos)
    local endPos = mainFrame.Position + UDim2.new(0, direction.X * 0.005, 0, direction.Y * 0.005)

    local tweenOut = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = endPos, Size = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1})

    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        mainFrame.Visible = false
        iconBtn.Visible = true

        -- Hentak animasi
        local bounce = TweenService:Create(iconBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 60, 0, 60)})
        local bounceBack = TweenService:Create(iconBtn, TweenInfo.new(0.1),
            {Size = UDim2.new(0, 50, 0, 50)})
        bounce:Play()
        bounce.Completed:Connect(function()
            bounceBack:Play()
        end)
    end)
end)

-- Show Main UI
iconBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.BackgroundTransparency = 0.3
    iconBtn.Visible = false
end)

-- Dragging (touch friendly)
local function enableDrag(guiElement)
    local dragging, offset
    guiElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            offset = input.Position - guiElement.AbsolutePosition
        end
    end)
    guiElement.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            guiElement.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
        end
    end)
end

enableDrag(mainFrame)
enableDrag(iconBtn)
