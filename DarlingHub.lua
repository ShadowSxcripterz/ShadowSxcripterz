local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Remove previous GUI if exists
if PlayerGui:FindFirstChild("DarlingHub") then
	PlayerGui.DarlingHub:Destroy()
end

-- Create UI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "DarlingHub"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 350, 0, 300)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.25
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- UICorner for rounded corners
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Text = "DarlingHub"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24

-- Close Button (X)
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20

-- Icon placeholder (Zero Two Icon)
local iconBtn = Instance.new("TextButton", screenGui)
iconBtn.Size = UDim2.new(0, 60, 0, 60)
iconBtn.Position = UDim2.new(0, 20, 1, -80)
iconBtn.AnchorPoint = Vector2.new(0, 1)
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
iconBtn.Text = ""
iconBtn.Visible = false
iconBtn.AutoButtonColor = false
local iconCorner = Instance.new("UICorner", iconBtn)
iconCorner.CornerRadius = UDim.new(1, 0)

-- Feature Button Factory
local function createFeatureButton(text, posY)
	local btnFrame = Instance.new("Frame", mainFrame)
	btnFrame.Size = UDim2.new(1, -40, 0, 40)
	btnFrame.Position = UDim2.new(0, 20, 0, posY)
	btnFrame.BackgroundTransparency = 1

	local outline = Instance.new("Frame", btnFrame)
	outline.Size = UDim2.new(1, 0, 1, 0)
	outline.Position = UDim2.new(0, 0, 0, 0)
	outline.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	outline.BackgroundTransparency = 0.7
	outline.BorderSizePixel = 0

	local outlineCorner = Instance.new("UICorner", outline)
	outlineCorner.CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel", outline)
	label.Text = text
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 18
end

-- Create Feature Buttons
createFeatureButton("Fly", 60)
createFeatureButton("No Clip", 110)
createFeatureButton("PartName", 160)

-- Smooth Fade-Out to Icon
local function hideUI()
	local targetPos = iconBtn.AbsolutePosition
	local screenSize = workspace.CurrentCamera.ViewportSize
	local scalePos = UDim2.new(0, targetPos.X, 0, targetPos.Y)

	local tweenOut = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, targetPos.X, 0, targetPos.Y)
	})
	tweenOut:Play()

	tweenOut.Completed:Connect(function()
		mainFrame.Visible = false
		iconBtn.Visible = true

		-- Hentak Animation
		iconBtn:TweenSize(UDim2.new(0, 70, 0, 70), "Out", "Back", 0.2, true, function()
			iconBtn:TweenSize(UDim2.new(0, 60, 0, 60), "Out", "Quad", 0.2)
		end)
	end)
end

closeBtn.MouseButton1Click:Connect(hideUI)

-- Show UI from Icon
iconBtn.MouseButton1Click:Connect(function()
	iconBtn.Visible = false
	mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame.Visible = true

	local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 350, 0, 300),
		Position = UDim2.new(0.5, -175, 0.5, -150)
	})
	tweenIn:Play()
end)

-- Initial Pop Animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Visible = true
TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0, 350, 0, 300),
	Position = UDim2.new(0.5, -175, 0.5, -150)
}):Play()
