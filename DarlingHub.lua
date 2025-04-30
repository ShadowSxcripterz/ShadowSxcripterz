--// Darling Hub Script | Full Version (Touchscreen, Animasi, Fitur Toggle) //--

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Create Core UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DarlingHubUI"
ScreenGui.ResetOnSpawn = false

-- Welcome Darling Intro
local welcomeFrame = Instance.new("Frame", ScreenGui)
welcomeFrame.BackgroundTransparency = 1
welcomeFrame.Size = UDim2.new(1, 0, 1, 0)

-- Center Welcome Text Container
local textContainer = Instance.new("Frame", welcomeFrame)
textContainer.AnchorPoint = Vector2.new(0.5, 0.5)
textContainer.Position = UDim2.new(0.5, 0, 0.4, 0)
textContainer.BackgroundTransparency = 1
textContainer.Size = UDim2.new(0, 600, 0, 100)

local welcomeText = "Welcome Darling"
local letterLabels = {}

for i = 1, #welcomeText do
	local char = welcomeText:sub(i, i)
	local label = Instance.new("TextLabel", textContainer)
	label.Text = char
	label.Size = UDim2.new(0, 30, 1, 0)
	label.Position = UDim2.new((i - 1) / #welcomeText, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 105, 180)
	label.Font = Enum.Font.GothamSemibold
	label.TextScaled = true
	label.TextTransparency = 1
	label.ZIndex = 2
	table.insert(letterLabels, label)
end

-- Pink Glow Effect
local glow = Instance.new("ImageLabel", welcomeFrame)
glow.BackgroundTransparency = 1
glow.Size = UDim2.new(0.5, 0, 0.2, 0)
glow.Position = UDim2.new(0.5, -200, 0.4, -50)
glow.Image = "rbxassetid://3135407932"
glow.ImageColor3 = Color3.fromRGB(255, 105, 180)
glow.ImageTransparency = 0.5

-- Icon Button (Z)
local iconBtn = Instance.new("TextButton", ScreenGui)
iconBtn.Size = UDim2.new(0, 60, 0, 60)
iconBtn.Position = UDim2.new(0.5, -30, 0.85, 0)
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
iconBtn.Text = "Z"
iconBtn.TextScaled = true
iconBtn.Font = Enum.Font.Fantasy
iconBtn.TextColor3 = Color3.new(1, 1, 1)
iconBtn.Visible = false
iconBtn.AutoButtonColor = false

-- Main UI Frame
local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.Visible = false
mainFrame.ClipsDescendants = true

-- Close Button (X)
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Position = UDim2.new(0, 10, 0, 10)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold

-- Feature Toggle Boxes
local featureNames = {"Aimbot", "ESP", "AutoFarm"}
local toggles = {}

for i, name in ipairs(featureNames) do
	local box = Instance.new("TextButton", mainFrame)
	box.Size = UDim2.new(0.9, 0, 0, 40)
	box.Position = UDim2.new(0.05, 0, 0, 50 + (i - 1) * 50)
	box.Text = name
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextScaled = true
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 2
	box.BorderColor3 = Color3.fromRGB(255, 0, 0)
	box.AutoButtonColor = false
	toggles[box] = false

	box.MouseButton1Click:Connect(function()
		for btn, _ in pairs(toggles) do
			btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
			toggles[btn] = false
		end
		box.BorderColor3 = Color3.fromRGB(0, 255, 0)
		toggles[box] = true
	end)
end

-- Drag Support (Touchscreen Compatible)
local function makeDraggable(frame)
	local dragging, offset
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			offset = Vector2.new(input.Position.X - frame.Position.X.Offset, input.Position.Y - frame.Position.Y.Offset)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			frame.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)
	frame.InputEnded:Connect(function()
		dragging = false
	end)
end

makeDraggable(mainFrame)
makeDraggable(iconBtn)

-- Fade In Welcome Letters
for i, label in ipairs(letterLabels) do
	local tween = TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, (i-1)*0.05), {
		TextTransparency = 0,
		Size = UDim2.new(0, 40, 1, 0)
	})
	tween:Play()
end

-- After Welcome Show UI
task.delay(#letterLabels * 0.05 + 1, function()
	for i, label in ipairs(letterLabels) do
		TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
	end
	TweenService:Create(glow, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
	wait(0.5)
	welcomeFrame:Destroy()

	mainFrame.Visible = true
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 400, 0, 300),
		Position = UDim2.new(0.5, -200, 0.5, -150)
	}):Play()
end)

-- X Button Close UI
closeBtn.MouseButton1Click:Connect(function()
	for i, child in ipairs(mainFrame:GetChildren()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		end
	end

	TweenService:Create(mainFrame, TweenInfo.new(0.4), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = iconBtn.Position
	}):Play()

	wait(0.4)
	mainFrame.Visible = false
	iconBtn.Visible = true
end)

-- Icon Button Reopen UI
iconBtn.MouseButton1Click:Connect(function()
	iconBtn.Visible = false
	mainFrame.Visible = true
	mainFrame.Position = iconBtn.Position
	mainFrame.Size = UDim2.new(0, 0, 0, 0)

	TweenService:Create(mainFrame, TweenInfo.new(0.4), {
		Size = UDim2.new(0, 400, 0, 300),
		Position = UDim2.new(0.5, -200, 0.5, -150)
	}):Play()

	for _, child in ipairs(mainFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child.TextTransparency = 0
		end
	end
end)
