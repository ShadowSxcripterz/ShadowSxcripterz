-- Darling Hub UI Script (Updated with centered fade, responsive icon, outlined buttons, draggable icon, and pop animation)

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Main UI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "DarlingHubUI"

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 230)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -115)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Darling Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 26

-- Close button
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0, 5, 0, 5)
closeBtn.Text = "X"
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 20

-- Feature Buttons
local features = {"Fly", "No Clip", "PartName"}
for i, feature in ipairs(features) do
	local btn = Instance.new("TextLabel", mainFrame)
	btn.Size = UDim2.new(0, 200, 0, 30)
	btn.Position = UDim2.new(0.5, -100, 0, 40 + (i * 40))
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	btn.BackgroundTransparency = 0.4
	btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
	btn.BorderSizePixel = 1
	btn.Text = feature
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
end

-- Icon Button
local iconBtn = Instance.new("TextButton", screenGui)
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 20, 1, -70)
iconBtn.Text = "Z"
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Pink
iconBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
iconBtn.Font = Enum.Font.GothamBlack
iconBtn.TextSize = 24
iconBtn.Visible = true
iconBtn.AutoButtonColor = false

-- Draggable Icon
local dragging, dragInput, dragStart, startPos

iconBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = iconBtn.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

iconBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		iconBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Animations
local function animateToIcon(fromFrame, toIcon)
	local iconPos = toIcon.AbsolutePosition
	local framePos = fromFrame.AbsolutePosition
	local offset = UDim2.new(0, iconPos.X - framePos.X, 0, iconPos.Y - framePos.Y)

	local tween = TweenService:Create(fromFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(0, iconPos.X, 0, iconPos.Y)
	})
	tween:Play()
	tween.Completed:Wait()
	fromFrame.Visible = false
end

local function animateFromIcon(toFrame, fromIcon)
	local iconPos = fromIcon.AbsolutePosition
	toFrame.Size = UDim2.new(0, 50, 0, 50)
	toFrame.Position = UDim2.new(0, iconPos.X, 0, iconPos.Y)
	toFrame.Visible = true

	local tween = TweenService:Create(toFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 360, 0, 230),
		Position = UDim2.new(0.5, -180, 0.5, -115)
	})
	tween:Play()
	tween.Completed:Wait()
end

-- Button Logic
closeBtn.MouseButton1Click:Connect(function()
	animateToIcon(mainFrame, iconBtn)
	iconBtn.Visible = true

	-- Pop animation
	local pop = TweenService:Create(iconBtn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 60, 0, 60)
	})
	local back = TweenService:Create(iconBtn, TweenInfo.new(0.15), {
		Size = UDim2.new(0, 50, 0, 50)
	})
	pop:Play()
	pop.Completed:Wait()
	back:Play()
end)

iconBtn.MouseButton1Click:Connect(function()
	iconBtn.Visible = false
	animateFromIcon(mainFrame, iconBtn)

	-- Pop intro
	local bounce = TweenService:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 380, 0, 250)
	})
	local settle = TweenService:Create(mainFrame, TweenInfo.new(0.1), {
		Size = UDim2.new(0, 360, 0, 230)
	})
	bounce:Play()
	bounce.Completed:Wait()
	settle:Play()
end)
