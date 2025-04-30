-- SERVICES
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- UI HOLDER
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "DarlingHub"

-- WELCOME TEXT
local welcomeHolder = Instance.new("Frame", gui)
welcomeHolder.Size = UDim2.new(1, 0, 1, 0)
welcomeHolder.BackgroundTransparency = 1

local welcomeText = "Welcome Darling"
local letters = {}
for i = 1, #welcomeText do
	local char = welcomeText:sub(i, i)
	local label = Instance.new("TextLabel", welcomeHolder)
	label.Text = char
	label.Size = UDim2.new(0, 40, 0, 60)
	label.Position = UDim2.new(0.5, (i - (#welcomeText / 2)) * 20, 0.5, -30)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 105, 180)
	label.TextTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	table.insert(letters, label)
end

-- ICON
local iconBtn = Instance.new("TextButton", gui)
iconBtn.Text = "Z"
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 100, 0, 300)
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
iconBtn.TextColor3 = Color3.new(1, 1, 1)
iconBtn.Font = Enum.Font.GothamBold
iconBtn.TextSize = 28
iconBtn.Visible = false

-- MAIN UI
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false

-- TITLE
local title = Instance.new("TextLabel", mainFrame)
title.Text = "DarlingHub"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18

-- ENABLE DRAG
local function enableDrag(guiObj)
	local dragging, offset
	guiObj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			offset = input.Position - guiObj.AbsolutePosition
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			guiObj.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)
end

enableDrag(iconBtn)
enableDrag(mainFrame)

-- FEATURES
local features = {"Fly", "Noclip", "PartName"}
for i, text in ipairs(features) do
	local container = Instance.new("Frame", mainFrame)
	container.Size = UDim2.new(0.8, 0, 0, 36)
	container.Position = UDim2.new(0.1, 0, 0, 50 + (i - 1) * 45)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 2
	container.BorderColor3 = Color3.fromRGB(255, 0, 0)

	local toggleBtn = Instance.new("TextButton", container)
	toggleBtn.Size = UDim2.new(1, 0, 1, 0)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = text
	toggleBtn.TextColor3 = Color3.new(1, 1, 1)
	toggleBtn.Font = Enum.Font.Gotham
	toggleBtn.TextSize = 16

	local toggled = false
	toggleBtn.MouseButton1Click:Connect(function()
		toggled = not toggled

		-- Animate outline press
		TweenService:Create(container, TweenInfo.new(0.1), {Size = UDim2.new(0.8, -4, 0, 32)}):Play()
		wait(0.1)
		TweenService:Create(container, TweenInfo.new(0.1), {Size = UDim2.new(0.8, 0, 0, 36)}):Play()

		container.BorderColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	end)
end

-- ANIMATIONS
local function fadeUI(fromPos, toPos, fadeIn)
	if fadeIn then
		mainFrame.Position = fromPos
		mainFrame.Size = UDim2.new(0, 60, 0, 60)
		mainFrame.Visible = true
		local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 320, 0, 260),
			Position = toPos
		})
		tween:Play()

		for _, d in pairs(mainFrame:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextButton") then
				d.TextTransparency = 1
				TweenService:Create(d, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
			elseif d:IsA("Frame") then
				d.BackgroundTransparency = 1
				TweenService:Create(d, TweenInfo.new(0.4), {BackgroundTransparency = 0.25}):Play()
			end
		end
	else
		for _, d in pairs(mainFrame:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextButton") then
				TweenService:Create(d, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
			elseif d:IsA("Frame") then
				TweenService:Create(d, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
			end
		end
		TweenService:Create(mainFrame, TweenInfo.new(0.4), {
			Size = UDim2.new(0, 60, 0, 60),
			Position = iconBtn.Position
		}):Play()
		wait(0.4)
		mainFrame.Visible = false
		iconBtn.Visible = true
	end
end

-- EVENTS
closeBtn.MouseButton1Click:Connect(function()
	fadeUI(nil, nil, false)
end)

iconBtn.MouseButton1Click:Connect(function()
	iconBtn.Visible = false
	fadeUI(iconBtn.Position, UDim2.new(0.5, -160, 0.5, -130), true)
end)

-- WELCOME ANIMATION
coroutine.wrap(function()
	wait(0.5)
	for i, label in ipairs(letters) do
		TweenService:Create(label, TweenInfo.new(0.3), {
			TextTransparency = 0,
			Position = label.Position + UDim2.new(0, 0, 0, -10)
		}):Play()
		wait(0.05)
	end

	wait(1)
	for _, label in ipairs(letters) do
		TweenService:Create(label, TweenInfo.new(0.3), {
			TextTransparency = 1,
			Position = label.Position + UDim2.new(0, 0, 0, -10)
		}):Play()
	end
	wait(0.3)
	welcomeHolder:Destroy()
	iconBtn.Visible = false
	fadeUI(iconBtn.Position, UDim2.new(0.5, -160, 0.5, -130), true)
end)()
