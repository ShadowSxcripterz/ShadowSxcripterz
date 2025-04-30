--[[ 
DarlingHub Final Script (Touchscreen, KRNL Compatible)
By: ShadowSxcripterz
--]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Main UI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "DarlingHub"

-- Welcome Animation
local welcomeFrame = Instance.new("Frame", screenGui)
welcomeFrame.Size = UDim2.new(1, 0, 1, 0)
welcomeFrame.BackgroundTransparency = 1

local letters = {}
local text = "Welcome Darling"
local center = #text / 2
for i = 1, #text do
	local char = text:sub(i, i)
	local lbl = Instance.new("TextLabel", welcomeFrame)
	lbl.Text = char
	lbl.Size = UDim2.new(0, 32, 0, 50)
	lbl.Position = UDim2.new(0.5, (i - center - 0.5) * 35, 0.5, -25)
	lbl.BackgroundTransparency = 1
	lbl.TextTransparency = 1
	lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextColor3 = Color3.fromRGB(255, 105, 180)
	table.insert(letters, lbl)

	local glow = Instance.new("UIStroke", lbl)
	glow.Color = Color3.fromRGB(255, 105, 180)
	glow.Thickness = 1.2
	glow.Transparency = 0.5
end

task.spawn(function()
	for i, lbl in ipairs(letters) do
		lbl.TextTransparency = 1
		lbl.Size = UDim2.new(0, 0, 0, 0)
		local t1 = TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0,
			Size = UDim2.new(0, 32, 0, 50)
		})
		t1:Play()
		wait(0.05)
	end
	wait(1)
	for i = #letters, 1, -1 do
		local lbl = letters[i]
		local t2 = TweenService:Create(lbl, TweenInfo.new(0.3), {
			TextTransparency = 1,
			Size = UDim2.new(0, 0, 0, 0)
		})
		t2:Play()
		wait(0.04)
	end
	wait(0.4)
	welcomeFrame:Destroy()
	showMainUI()
end)

-- Main Frame
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.25
mainFrame.Visible = false
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Text = "DarlingHub"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24

-- Close Button
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18

-- Icon Button
local iconBtn = Instance.new("TextButton", screenGui)
iconBtn.Text = "Z"
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(0, 60, 0, 300)
iconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
iconBtn.TextColor3 = Color3.new(1, 1, 1)
iconBtn.Font = Enum.Font.GothamBold
iconBtn.TextSize = 28
iconBtn.Visible = false

-- Drag System
local function enableDrag(obj)
	local dragging = false
	local offset = Vector2.zero
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
			obj.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)
end

enableDrag(mainFrame)
enableDrag(iconBtn)

-- Feature Buttons
local features = {"Fly", "Noclip", "PartName"}
for i, name in ipairs(features) do
	local box = Instance.new("Frame", mainFrame)
	box.Size = UDim2.new(0.8, 0, 0, 36)
	box.Position = UDim2.new(0.1, 0, 0, 50 + (i - 1) * 45)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 2
	box.BorderColor3 = Color3.fromRGB(255, 0, 0)

	local btn = Instance.new("TextButton", box)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16

	local active = false
	btn.MouseButton1Click:Connect(function()
		active = not active
		local color = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
		TweenService:Create(box, TweenInfo.new(0.2), {BorderColor3 = color}):Play()
		TweenService:Create(box, TweenInfo.new(0.05), {Size = UDim2.new(0.78, 0, 0, 34)}):Play()
		wait(0.05)
		TweenService:Create(box, TweenInfo.new(0.05), {Size = UDim2.new(0.8, 0, 0, 36)}):Play()
	end)
end

-- UI Show / Hide Logic
function showMainUI()
	mainFrame.Position = iconBtn.Position
	mainFrame.Size = UDim2.new(0, 60, 0, 60)
	mainFrame.Visible = true
	local tIn = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(mainFrame, tIn, {
		Size = UDim2.new(0, 320, 0, 260),
		Position = UDim2.new(0.5, -160, 0.5, -130)
	}):Play()
	iconBtn.Visible = false
	for _, d in ipairs(mainFrame:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			d.TextTransparency = 1
			TweenService:Create(d, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
		end
	end
end

function hideMainUI()
	local tOut = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	for _, d in ipairs(mainFrame:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			TweenService:Create(d, tOut, {TextTransparency = 1}):Play()
		end
	end
	TweenService:Create(mainFrame, tOut, {
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

closeBtn.MouseButton1Click:Connect(hideMainUI)
iconBtn.MouseButton1Click:Connect(showMainUI)
