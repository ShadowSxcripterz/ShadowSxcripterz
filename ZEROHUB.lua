-- ZERO HUB TOUCHSCREEN FLY (No keyboard)

local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local Min = Instance.new("TextButton")
local Close = Instance.new("TextButton")
local FlyBtn = Instance.new("TextButton")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Name = "ZERO_HUB_TOUCH"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

Main.Name = "Main"
Main.Size = UDim2.new(0, 300, 0, 150)
Main.Position = UDim2.new(0.5, -150, 0.5, -75)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = Main

Title.Text = "ZERO HUB"
Title.Font = Enum.Font.FredokaOne
Title.TextColor3 = Color3.fromRGB(255, 105, 180)
Title.TextSize = 28
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Size = UDim2.new(0, 200, 0, 35)
Title.BackgroundTransparency = 1
Title.Parent = Main

Close.Text = "X"
Close.Font = Enum.Font.FredokaOne
Close.TextColor3 = Color3.fromRGB(255, 105, 180)
Close.TextSize = 28
Close.Position = UDim2.new(1, -40, 0, 5)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.BackgroundTransparency = 1
Close.Parent = Main
Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

Min.Text = "-"
Min.Font = Enum.Font.FredokaOne
Min.TextColor3 = Color3.fromRGB(255, 105, 180)
Min.TextSize = 28
Min.Position = UDim2.new(1, -70, 0, 5)
Min.Size = UDim2.new(0, 30, 0, 30)
Min.BackgroundTransparency = 1
Min.Parent = Main
Min.MouseButton1Click:Connect(function()
	FlyBtn.Visible = not FlyBtn.Visible
end)

-- Fly Button
FlyBtn.Text = "Fly"
FlyBtn.Font = Enum.Font.FredokaOne
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.TextSize = 22
FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FlyBtn.Position = UDim2.new(0.5, -100, 0.5, 10)
FlyBtn.Size = UDim2.new(0, 200, 0, 50)
FlyBtn.AutoButtonColor = false
FlyBtn.Parent = Main

UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 3
UIStroke.Parent = FlyBtn

-- Fly System (Touchscreen)
local flying = false
local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

FlyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	local hrp = char:FindFirstChild("HumanoidRootPart")

	if flying then
		FlyBtn.Text = "Flying..."
		FlyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		UIStroke.Color = Color3.fromRGB(0, 255, 0)

		-- Start flying up
		local bodyVel = Instance.new("BodyVelocity", hrp)
		bodyVel.Velocity = Vector3.new(0, 50, 0)
		bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
		bodyVel.Name = "FlyForce"

	else
		FlyBtn.Text = "Fly"
		UIStroke.Color = Color3.fromRGB(255, 0, 0)

		-- Stop flying
		local bv = hrp:FindFirstChild("FlyForce")
		if bv then bv:Destroy() end
	end
end)
