local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- UI Holder
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "DarlingHub"

-- Welcome Text Setup
local welcomeText = Instance.new("Frame")
welcomeText.Size = UDim2.new(1, 0, 1, 0)
welcomeText.BackgroundTransparency = 1
welcomeText.Parent = screenGui

local letters = {}
local message = "Welcome Darling"
for i = 1, #message do
	local char = message:sub(i, i)
	local label = Instance.new("TextLabel")
	label.Text = char
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = Color3.fromRGB(255, 105, 180)
	label.TextTransparency = 1
	label.Size = UDim2.new(0, 30, 0, 50)
	label.Position = UDim2.new(0.5, (i - #message / 2) * 24, 0.5, -25)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.TextSize = 40
	label.Parent = welcomeText
	table.insert(letters, label)
end

-- Glow ambient
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(0, 300, 0, 300)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://200527618" -- Soft glow image
glow.ImageColor3 = Color3.fromRGB(255, 105, 180)
glow.ImageTransparency = 0.4
glow.ZIndex = 0
glow.Parent = welcomeText

-- Main UI
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Drag Function
local function enableDrag(guiObject)
	local dragging, offset
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			offset = input.Position - guiObject.AbsolutePosition
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			guiObject.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)
end

-- Apply drag
enableDrag(mainFrame)

-- Title
local title = Instance.new("TextLabel")
title.Text = "DarlingHub"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 10)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = mainFrame

-- Icon Button
local iconBtn = Instance.new("TextButton")
iconBtn.Text = "Z"
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0.5, -25, 1, -60)
iconBtn.AnchorPoint = Vector2.new(0.5, 0)
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
iconBtn.TextColor3 = Color3.new(1, 1, 1)
iconBtn.Font = Enum.Font.GothamBold
iconBtn.TextSize = 28
iconBtn.Visible = false
iconBtn.Parent = screenGui

enableDrag(iconBtn)

-- Feature Buttons
local features = {"Fly", "Noclip", "PartName"}
local toggled = {}

for i, name in ipairs(features) do
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0.8, 0, 0, 36)
	container.Position = UDim2.new(0.1, 0, 0, 50 + (i - 1) * 45)
	container.BackgroundTransparency = 1
	container.BorderColor3 = Color3.fromRGB(255, 0, 0)
	container.BorderSizePixel = 2
	container.Parent = mainFrame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Text = name
	btn.BackgroundTransparency = 1
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.Parent = container

	toggled[name] = false

	btn.MouseButton1Click:Connect(function()
		toggled[name] = not toggled[name]
		container.BorderColor3 = toggled[name] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

		-- Press animation
		TweenService:Create(container, TweenInfo.new(0.1), {
			Size = UDim2.new(0.78, 0, 0, 34)
		}):Play()
		wait(0.1)
		TweenService:Create(container, TweenInfo.new(0.1), {
			Size = UDim2.new(0.8, 0, 0, 36)
		}):Play()
	end)
end

-- UI fade in
local function fadeInUI()
	mainFrame.Visible = true
	mainFrame.Size = UDim2.new(0, 60, 0, 60)
	mainFrame.Position = iconBtn.Position

	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 320, 0, 260),
		Position = UDim2.new(0.5, -160, 0.5, -130)
	})
	tween:Play()

	TweenService:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 330, 0, 270)
	}):Play()
	wait(0.1)
	TweenService:Create(mainFrame, TweenInfo.new(0.1), {
		Size = UDim2.new(0, 320, 0, 260)
	}):Play()
end

-- Close UI
local function fadeOutUI()
	TweenService:Create(mainFrame, TweenInfo.new(0.4), {
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

-- Event Hooks
closeBtn.MouseButton1Click:Connect(fadeOutUI)
iconBtn.MouseButton1Click:Connect(function()
	iconBtn.Visible = false
	fadeInUI()
end)

-- Intro anim start
task.spawn(function()
	wait(0.5)
	for i, letter in ipairs(letters) do
		TweenService:Create(letter, TweenInfo.new(0.3), {
			TextTransparency = 0,
			TextSize = 48
		}):Play()
		wait(0.07)
	end
	wait(1)

	for i = #letters, 1, -1 do
		TweenService:Create(letters[i], TweenInfo.new(0.2), {
			TextTransparency = 1
		}):Play()
		wait(0.04)
	end

	welcomeText:Destroy()
	wait(0.2)
	fadeInUI()
end)
