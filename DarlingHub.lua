-- CLEAR UI SEBELUMNYA
pcall(function() game.CoreGui:FindFirstChild("DarlingHubUI"):Destroy() end)

-- SERVICES
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- UI UTAMA
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DarlingHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- FUNGSI DRAG
local function MakeDraggable(frame)
	local dragging, dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

-- WELCOME DARLING ANIMASI
local WelcomeContainer = Instance.new("Frame", ScreenGui)
WelcomeContainer.Size = UDim2.new(1, 0, 1, 0)
WelcomeContainer.BackgroundTransparency = 1
WelcomeContainer.ZIndex = 5

local WelcomeText = "Welcome Darling"
local letters = {}
local centerX = 0.5
local startX = centerX - (#WelcomeText * 0.5 * 0.04)

for i = 1, #WelcomeText do
	local char = WelcomeText:sub(i, i)
	local label = Instance.new("TextLabel", WelcomeContainer)
	label.Text = char
	label.Size = UDim2.new(0, 30, 0, 50)
	label.Position = UDim2.new(startX + (i - 1) * 0.04, 0, 0.45, 0)
	label.BackgroundTransparency = 1
	label.TextTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(255, 105, 180)
	label.ZIndex = 5
	letters[i] = label
end

-- AMBIENT LIGHT
local Ambient = Instance.new("UIGradient", WelcomeContainer)
Ambient.Rotation = 45
Ambient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 105, 180)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 255))
}

-- ANIMASI FADE IN TEXT
task.wait(0.5)
for i, label in ipairs(letters) do
	label.TextTransparency = 1
	label.TextStrokeTransparency = 1
	label.Size = UDim2.new(0, 0, 0, 0)
	local tween = TweenService:Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0, Size = UDim2.new(0, 30, 0, 50)})
	tween:Play()
	task.wait(0.05)
end

-- TUNGGU SEBELUM FADE OUT
task.wait(1.5)

-- ANIMASI FADE OUT REVERSE
for i = #letters, 1, -1 do
	local tween = TweenService:Create(letters[i], TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{TextTransparency = 1, Size = UDim2.new(0, 0, 0, 0)})
	tween:Play()
	task.wait(0.05)
end
task.wait(0.3)
WelcomeContainer:Destroy()

-- UI MENU UTAMA
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Visible = false

MakeDraggable(MainFrame)

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 16)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "DarlingHub"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1

-- Close Button
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0, 5, 0, 5)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true

-- FEATURE TOGGLE EXAMPLE
local function CreateFeatureToggle(text, yPos)
	local Button = Instance.new("TextButton", MainFrame)
	Button.Size = UDim2.new(0.9, 0, 0, 40)
	Button.Position = UDim2.new(0.05, 0, 0, yPos)
	Button.Text = text
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.BackgroundTransparency = 1
	Button.TextScaled = true
	Button.Font = Enum.Font.Gotham

	local Outline = Instance.new("Frame", Button)
	Outline.Size = UDim2.new(1, 0, 1, 0)
	Outline.Position = UDim2.new(0, 0, 0, 0)
	Outline.BackgroundTransparency = 1

	local UIStroke = Instance.new("UIStroke", Outline)
	UIStroke.Color = Color3.fromRGB(255, 0, 0)
	UIStroke.Thickness = 2

	local toggled = false
	Button.MouseButton1Click:Connect(function()
		toggled = not toggled
		UIStroke.Color = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	end)
end

CreateFeatureToggle("Aimbot", 60)
CreateFeatureToggle("ESP", 110)
CreateFeatureToggle("Fly", 160)

-- ICON ZERO TWO (Z)
local IconBtn = Instance.new("TextButton", ScreenGui)
IconBtn.Size = UDim2.new(0, 50, 0, 50)
IconBtn.Position = UDim2.new(0, 20, 0.5, -25)
IconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
IconBtn.Text = "Z"
IconBtn.TextColor3 = Color3.new(1, 1, 1)
IconBtn.TextScaled = true
IconBtn.Font = Enum.Font.GothamBold

MakeDraggable(IconBtn)

-- BUKA UI DARI ICON
IconBtn.MouseButton1Click:Connect(function()
	MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
	MainFrame.Size = UDim2.new(0, 0, 0, 0)
	MainFrame.Visible = true

	local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 300, 0, 400)
	})
	tween:Play()
end)

-- CLOSE UI
CloseBtn.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 0, 0, 0)
	})
	tween:Play()
	tween.Completed:Wait()
	MainFrame.Visible = false
end)
