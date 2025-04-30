--// DarlingHub FULL SCRIPT (KRNL Compatible) //--

if game.CoreGui:FindFirstChild("DarlingHub") then
    game.CoreGui:FindFirstChild("DarlingHub"):Destroy()
end

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Main GUI container
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "DarlingHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Welcome Animation Frame
local welcomeFrame = Instance.new("Frame", gui)
welcomeFrame.Size = UDim2.new(1, 0, 1, 0)
welcomeFrame.BackgroundTransparency = 1

local letters = {}
local text = "Welcome Darling"
local centerX = 0.5
local spacing = 30
local startY = 0.4

for i = 1, #text do
	local char = text:sub(i, i)
	local lbl = Instance.new("TextLabel", welcomeFrame)
	lbl.Text = char
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextColor3 = Color3.fromRGB(255, 105, 180)
	lbl.TextStrokeTransparency = 0.5
	lbl.BackgroundTransparency = 1
	lbl.TextSize = 60
	lbl.Position = UDim2.new(centerX, (i - (#text/2 + 0.5)) * spacing, startY, 0)
	lbl.Size = UDim2.new(0, 50, 0, 50)
	lbl.TextTransparency = 1
	lbl.TextScaled = true
	table.insert(letters, lbl)
end

-- Animate Welcome In
task.spawn(function()
	for i, lbl in ipairs(letters) do
		lbl.TextTransparency = 1
		lbl.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			TextTransparency = 0,
			Size = UDim2.new(0, 50, 0, 50)
		}):Play()
		task.wait(0.05)
	end
	task.wait(1)

	-- Animate Welcome Out
	for i = #letters, 1, -1 do
		local lbl = letters[i]
		TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			TextTransparency = 1,
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		task.wait(0.05)
	end
	welcomeFrame:Destroy()
end)

-- Icon Button (Z cute style)
local iconBtn = Instance.new("TextButton", gui)
iconBtn.Size = UDim2.new(0, 60, 0, 60)
iconBtn.Position = UDim2.new(0.9, 0, 0.8, 0)
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
iconBtn.Text = "Z"
iconBtn.Font = Enum.Font.GothamBlack
iconBtn.TextColor3 = Color3.new(1,1,1)
iconBtn.TextScaled = true
iconBtn.AutoButtonColor = false
iconBtn.BackgroundTransparency = 0
iconBtn.BorderSizePixel = 0
iconBtn.ClipsDescendants = true
iconBtn.Name = "ZIcon"
iconBtn.AnchorPoint = Vector2.new(0.5, 0.5)
iconBtn.SizeConstraint = Enum.SizeConstraint.RelativeXY
iconBtn.UICorner = Instance.new("UICorner", iconBtn)
iconBtn.UICorner.CornerRadius = UDim.new(1, 0)

-- Drag handler
local function makeDraggable(obj)
	local dragging, offset
	obj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			offset = input.Position - obj.AbsolutePosition
		end
	end)
	obj.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			obj.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)
end
makeDraggable(iconBtn)

-- Main UI Frame
local mainFrame = Instance.new("Frame", gui)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Size = UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

makeDraggable(mainFrame)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Text = "DarlingHub"
title.Font = Enum.Font.GothamBold
title.TextSize = 30
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 50)

-- Close Button
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 10)

-- Feature toggles
local features = {"AutoFarm", "AutoKill", "ESP"}
for i, name in ipairs(features) do
	local btn = Instance.new("TextButton", mainFrame)
	btn.Size = UDim2.new(0.8, 0, 0, 40)
	btn.Position = UDim2.new(0.1, 0, 0, 60 + (i - 1) * 60)
	btn.Text = name
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 20
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundTransparency = 1

	local outline = Instance.new("Frame", btn)
	outline.Size = UDim2.new(1, 0, 1, 0)
	outline.Position = UDim2.new(0, 0, 0, 0)
	outline.BorderSizePixel = 2
	outline.BackgroundTransparency = 1
	outline.BorderColor3 = Color3.fromRGB(255, 0, 0)
	btn.MouseButton1Click:Connect(function()
		local active = outline.BorderColor3 == Color3.fromRGB(0, 255, 0)
		outline.BorderColor3 = active and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
	end)
end

-- UI Toggle logic
local function showUI()
	mainFrame.Visible = true
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	mainFrame.Position = iconBtn.Position
	TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 350, 0, 400),
		Position = UDim2.new(0.5, -175, 0.5, -200)
	}):Play()
end

local function hideUI()
	for _, v in pairs(mainFrame:GetDescendants()) do
		if v:IsA("TextLabel") or v:IsA("TextButton") then
			TweenService:Create(v, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
		end
	end
	TweenService:Create(mainFrame, TweenInfo.new(0.3), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = iconBtn.Position
	}):Play()
	task.delay(0.3, function()
		mainFrame.Visible = false
	end)
end

iconBtn.MouseButton1Click:Connect(showUI)
closeBtn.MouseButton1Click:Connect(hideUI)
