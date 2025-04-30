local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "DarlingHub"
screenGui.ResetOnSpawn = false

-- Welcome Text
local welcomeText = Instance.new("TextLabel")
welcomeText.Size = UDim2.new(1, 0, 1, 0)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = "Welcome Darling"
welcomeText.TextColor3 = Color3.fromRGB(255, 105, 180)
welcomeText.Font = Enum.Font.FredokaOne
welcomeText.TextSize = 60
welcomeText.TextTransparency = 1
welcomeText.Position = UDim2.new(0.5, 0, 0.5, 0)
welcomeText.AnchorPoint = Vector2.new(0.5, 0.5)
welcomeText.Parent = screenGui

-- Pink ambient glow
local uiCorner = Instance.new("UICorner", welcomeText)
uiCorner.CornerRadius = UDim.new(1, 0)

-- Fade-in animation for welcome text
TweenService:Create(welcomeText, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	TextTransparency = 0,
	Size = UDim2.new(0, 450, 0, 80)
}):Play()

wait(2)

-- Fade-out welcome text
TweenService:Create(welcomeText, TweenInfo.new(0.5), {
	TextTransparency = 1,
	Size = UDim2.new(0, 20, 0, 20)
}):Play()

wait(0.6)
welcomeText:Destroy()

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Enable drag
local function enableDrag(gui)
	local dragging, offset
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			offset = input.Position - gui.AbsolutePosition
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			gui.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

enableDrag(mainFrame)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "DarlingHub"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 24

-- Close Button
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 10)
closeBtn.Text = "X"
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18

-- Icon Button
local iconBtn = Instance.new("TextButton", screenGui)
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 100, 0, 300)
iconBtn.Text = "Z"
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
iconBtn.TextColor3 = Color3.new(1, 1, 1)
iconBtn.Font = Enum.Font.GothamBold
iconBtn.TextSize = 28
iconBtn.Visible = false

enableDrag(iconBtn)

-- Feature Buttons
local features = {"Fly", "Noclip", "PartName"}
local featureToggles = {}

for i, name in ipairs(features) do
	local container = Instance.new("Frame", mainFrame)
	container.Size = UDim2.new(0.8, 0, 0, 36)
	container.Position = UDim2.new(0.1, 0, 0, 50 + (i - 1) * 45)
	container.BackgroundTransparency = 1
	container.BorderColor3 = Color3.fromRGB(255, 0, 0)
	container.BorderSizePixel = 2

	local button = Instance.new("TextButton", container)
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Text = name
	button.BackgroundTransparency = 1
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.Gotham
	button.TextSize = 16

	local toggled = false
	button.MouseButton1Click:Connect(function()
		toggled = not toggled
		local color = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
		TweenService:Create(container, TweenInfo.new(0.2), { BorderColor3 = color }):Play()
		TweenService:Create(container, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0.78, 0, 0, 34)
		}):Play()
		wait(0.1)
		TweenService:Create(container, TweenInfo.new(0.1), {
			Size = UDim2.new(0.8, 0, 0, 36)
		}):Play()
	end)
end

-- Fade in
local function fadeInUI()
	mainFrame.Visible = true
	mainFrame.Position = iconBtn.Position
	mainFrame.Size = UDim2.new(0, 60, 0, 60)

	TweenService:Create(mainFrame, TweenInfo.new(0.4), {
		Position = UDim2.new(0.5, -160, 0.5, -130),
		Size = UDim2.new(0, 320, 0, 260)
	}):Play()

	for _, d in pairs(mainFrame:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			d.TextTransparency = 1
			TweenService:Create(d, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
		end
	end

	TweenService:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 330, 0, 270)
	}):Play()
	wait(0.1)
	TweenService:Create(mainFrame, TweenInfo.new(0.1), {
		Size = UDim2.new(0, 320, 0, 260)
	}):Play()
end

-- Fade out
local function fadeOutUI()
	for _, d in pairs(mainFrame:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			TweenService:Create(d, TweenInfo.new(0.25), {
				TextTransparency = 1
			}):Play()
		end
	end

	TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 60, 0, 60),
		Position = iconBtn.Position
	}):Play()

	wait(0.4)
	mainFrame.Visible = false
	iconBtn.Visible = true

	TweenService:Create(iconBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 60, 0, 60)
	}):Play()
end

-- Buttons
closeBtn.MouseButton1Click:Connect(fadeOutUI)
iconBtn.MouseButton1Click:Connect(function()
	iconBtn.Visible = false
	fadeInUI()
end)

-- Auto play
wait(0.1)
fadeInUI()
