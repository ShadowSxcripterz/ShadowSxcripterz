local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "DarlingHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Welcome Animation Frame
local welcomeFrame = Instance.new("Frame", gui)
welcomeFrame.Size = UDim2.new(1, 0, 1, 0)
welcomeFrame.BackgroundTransparency = 1
welcomeFrame.ZIndex = 10

-- Welcome Darling Letters
local welcomeText = "Welcome Darling"
local letterLabels = {}
local centerX = 0.5
local spacing = 24
local centerIndex = math.ceil(#welcomeText / 2)

for i = 1, #welcomeText do
	local char = welcomeText:sub(i, i)
	local lbl = Instance.new("TextLabel", welcomeFrame)
	lbl.Text = char
	lbl.Font = Enum.Font.FredokaOne
	lbl.TextSize = 50
	lbl.TextColor3 = Color3.fromRGB(255, 105, 180)
	lbl.BackgroundTransparency = 1
	lbl.TextTransparency = 1
	lbl.AnchorPoint = Vector2.new(0.5, 0.5)
	lbl.Position = UDim2.new(0.5, (i - centerIndex) * spacing, 0.4, 0)
	lbl.ZIndex = 10
	table.insert(letterLabels, lbl)
end

-- Pink glow around text
local glow = Instance.new("UIStroke")
glow.Color = Color3.fromRGB(255, 105, 180)
glow.Thickness = 2
glow.Transparency = 0.4
for _, lbl in ipairs(letterLabels) do
	glow:Clone().Parent = lbl
end

-- Main UI
local mainUI = Instance.new("Frame", gui)
mainUI.Size = UDim2.new(0, 320, 0, 260)
mainUI.Position = UDim2.new(0.5, -160, 0.5, -130)
mainUI.BackgroundColor3 = Color3.new(0, 0, 0)
mainUI.BackgroundTransparency = 0.25
mainUI.BorderSizePixel = 0
mainUI.Visible = false

-- Drag function (touch & mouse)
local function makeDraggable(frame)
	local dragging, offset
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			offset = input.Position - frame.AbsolutePosition
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			frame.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)
end

makeDraggable(mainUI)

-- Title
local title = Instance.new("TextLabel", mainUI)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "DarlingHub"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24

-- Close Button
local closeBtn = Instance.new("TextButton", mainUI)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 10)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18

-- Icon Button
local iconBtn = Instance.new("TextButton", gui)
iconBtn.Text = "Z"
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 50, 0, 300)
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
iconBtn.TextColor3 = Color3.new(1, 1, 1)
iconBtn.Font = Enum.Font.GothamBold
iconBtn.TextSize = 28
iconBtn.Visible = false

makeDraggable(iconBtn)

-- Feature Buttons
local features = {"Fly", "Noclip", "PartName"}
for i, name in ipairs(features) do
	local container = Instance.new("Frame", mainUI)
	container.Size = UDim2.new(0.8, 0, 0, 36)
	container.Position = UDim2.new(0.1, 0, 0, 50 + (i - 1) * 45)
	container.BackgroundTransparency = 1
	container.BorderColor3 = Color3.fromRGB(255, 0, 0)
	container.BorderSizePixel = 2

	local btn = Instance.new("TextButton", container)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Text = name
	btn.BackgroundTransparency = 1
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
end

-- UI Animation In
local function fadeInUI()
	mainUI.Position = iconBtn.Position
	mainUI.Size = UDim2.new(0, 60, 0, 60)
	mainUI.Visible = true

	TweenService:Create(mainUI, TweenInfo.new(0.4), {
		Position = UDim2.new(0.5, -160, 0.5, -130),
		Size = UDim2.new(0, 320, 0, 260)
	}):Play()

	for _, d in ipairs(mainUI:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			d.TextTransparency = 1
			TweenService:Create(d, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
		end
	end
end

-- UI Animation Out
local function fadeOutUI()
	for _, d in ipairs(mainUI:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			TweenService:Create(d, TweenInfo.new(0.3), {
				TextTransparency = 1
			}):Play()
		end
	end

	TweenService:Create(mainUI, TweenInfo.new(0.4), {
		Position = iconBtn.Position,
		Size = UDim2.new(0, 60, 0, 60)
	}):Play()

	wait(0.4)
	mainUI.Visible = false
	iconBtn.Visible = true
	TweenService:Create(iconBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 60, 0, 60)
	}):Play()
end

-- Fade in Welcome letters
local function animateWelcome()
	for i, lbl in ipairs(letterLabels) do
		lbl.TextTransparency = 1
		lbl.TextSize = 10
	end

	for i = 1, #letterLabels do
		local lbl = letterLabels[i]
		TweenService:Create(lbl, TweenInfo.new(0.25), {
			TextTransparency = 0,
			TextSize = 50
		}):Play()
		wait(0.05)
	end

	wait(1.2)

	for i = #letterLabels, 1, -1 do
		local lbl = letterLabels[i]
		TweenService:Create(lbl, TweenInfo.new(0.25), {
			TextTransparency = 1,
			TextSize = 10
		}):Play()
		wait(0.03)
	end

	wait(0.2)
	welcomeFrame:Destroy()
	iconBtn.Visible = false
	fadeInUI()
end

-- Events
closeBtn.MouseButton1Click:Connect(fadeOutUI)
iconBtn.MouseButton1Click:Connect(function()
	iconBtn.Visible = false
	fadeInUI()
end)

-- Launch
mainUI.Visible = false
iconBtn.Visible = false
coroutine.wrap(animateWelcome)()
