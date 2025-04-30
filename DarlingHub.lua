-- DarlingHub - Full Version Script [KRNL-Compatible]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Create screen GUI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.ResetOnSpawn = false
screenGui.Name = "DarlingHubUI"

-- Pink color for Zero Two
local pinkColor = Color3.fromRGB(255, 102, 204)

-- Create Welcome Darling animation
local welcomeFrame = Instance.new("Frame", screenGui)
welcomeFrame.Size = UDim2.new(1, 0, 1, 0)
welcomeFrame.BackgroundTransparency = 1
welcomeFrame.ZIndex = 10

-- Container for welcome letters
local letterContainer = Instance.new("Frame", welcomeFrame)
letterContainer.BackgroundTransparency = 1
letterContainer.Size = UDim2.new(0, 600, 0, 100)
letterContainer.Position = UDim2.new(0.5, -300, 0.4, 0)

local welcomeText = "Welcome Darling"
local letters = {}

for i = 1, #welcomeText do
	local char = welcomeText:sub(i, i)
	local label = Instance.new("TextLabel", letterContainer)
	label.Text = char
	label.TextColor3 = pinkColor
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0, 40, 1, 0)
	label.Position = UDim2.new(0, (i - 1) * 40, 0, 0)
	label.TextTransparency = 1
	label.TextSize = 40
	table.insert(letters, label)
end

-- Pink ambient glow
local glow = Instance.new("ImageLabel", letterContainer)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://6980520016" -- soft glow
glow.Size = UDim2.new(1, 60, 2, 60)
glow.Position = UDim2.new(0, -30, 0, -30)
glow.ImageColor3 = pinkColor
glow.ImageTransparency = 0.5
glow.ZIndex = 0

-- Main UI frame
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 450, 0, 400)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.BorderSizePixel = 0

-- UI Corner
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 16)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "DarlingHub"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

-- Close button
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(0, 10, 0, 10)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundTransparency = 1

-- Zero Two icon
local iconBtn = Instance.new("ImageButton", screenGui)
iconBtn.Size = UDim2.new(0, 80, 0, 80)
iconBtn.Position = UDim2.new(0.9, 0, 0.8, 0)
iconBtn.Image = "rbxassetid://17215674367" -- cute Z icon
iconBtn.BackgroundTransparency = 1
iconBtn.Visible = false

-- Drag function
local function makeDraggable(obj)
	local dragging, offset
	obj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			offset = input.Position - obj.AbsolutePosition
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local pos = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
			obj.Position = pos
		end
	end)
end
makeDraggable(mainFrame)
makeDraggable(iconBtn)

-- Feature buttons (sample)
local features = {"ESP", "Aimbot", "Fly", "Speed"}
for i, name in ipairs(features) do
	local button = Instance.new("TextButton", mainFrame)
	button.Size = UDim2.new(0.8, 0, 0, 40)
	button.Position = UDim2.new(0.1, 0, 0, 60 + (i - 1) * 50)
	button.Text = name
	button.Font = Enum.Font.Gotham
	button.TextColor3 = Color3.new(1, 1, 1)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0

	local outline = Instance.new("Frame", button)
	outline.Size = UDim2.new(1, 0, 1, 0)
	outline.BackgroundTransparency = 1
	outline.BorderColor3 = Color3.fromRGB(255, 0, 0)
	outline.BorderSizePixel = 2
	outline.Name = "Outline"

	local active = false
	button.MouseButton1Click:Connect(function()
		active = not active
		outline.BorderColor3 = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	end)
end

-- Animations
local function playWelcome(callback)
	for i, label in ipairs(letters) do
		TweenService:Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0,
			TextSize = 40
		}):Play()
		wait(0.05)
	end
	wait(1)
	for i = #letters, 1, -1 do
		TweenService:Create(letters[i], TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			TextTransparency = 1,
			TextSize = 10
		}):Play()
		wait(0.04)
	end
	wait(0.3)
	welcomeFrame:Destroy()
	callback()
end

local function showUI()
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame.Visible = true
	TweenService:Create(mainFrame, TweenInfo.new(0.5), {
		Size = UDim2.new(0, 450, 0, 400)
	}):Play()
end

local function hideUI()
	for _, obj in ipairs(mainFrame:GetChildren()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			TweenService:Create(obj, TweenInfo.new(0.25), {
				TextTransparency = 1
			}):Play()
		end
	end
	TweenService:Create(mainFrame, TweenInfo.new(0.5), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = iconBtn.Position
	}):Play()
	wait(0.5)
	mainFrame.Visible = false
	iconBtn.Visible = true
end

closeBtn.MouseButton1Click:Connect(hideUI)
iconBtn.MouseButton1Click:Connect(function()
	iconBtn.Visible = false
	mainFrame.Position = iconBtn.Position
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame.Visible = true
	TweenService:Create(mainFrame, TweenInfo.new(0.5), {
		Size = UDim2.new(0, 450, 0, 400),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()
end)

-- Launch
playWelcome(showUI)
