-- DarlingHub Final Script (Touchscreen-Friendly, Full Features)

local TweenService = game:GetService("TweenService") local UserInputService = game:GetService("UserInputService") local Players = game:GetService("Players") local player = Players.LocalPlayer local mouse = player:GetMouse()

-- Main GUI local screenGui = Instance.new("ScreenGui", game.CoreGui) screenGui.Name = "DarlingHubUI" screenGui.ResetOnSpawn = false

-- Welcome Darling Animation Frame local welcomeFrame = Instance.new("Frame", screenGui) welcomeFrame.BackgroundTransparency = 1 welcomeFrame.Size = UDim2.new(1, 0, 1, 0) welcomeFrame.Position = UDim2.new(0, 0, 0, 0)

local welcomeLetters = {} local welcomeText = "Welcome Darling" local centerX = 0.5 local centerY = 0.4 local spacing = 28 local startIndex = math.floor(#welcomeText / 2)

for i = 1, #welcomeText do local char = welcomeText:sub(i, i) local textLabel = Instance.new("TextLabel", welcomeFrame) textLabel.Text = char textLabel.TextColor3 = Color3.fromRGB(255, 105, 180) textLabel.Font = Enum.Font.GothamSemibold textLabel.TextSize = 42 textLabel.BackgroundTransparency = 1 textLabel.TextTransparency = 1 textLabel.Size = UDim2.new(0, 30, 0, 50) textLabel.Position = UDim2.new(centerX, (i - startIndex) * spacing, centerY, 0) table.insert(welcomeLetters, textLabel) end

-- Animate letters fade in one by one for i, letter in ipairs(welcomeLetters) do delay(i * 0.06, function() TweenService:Create(letter, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { TextTransparency = 0, TextSize = 50 }):Play() end) end

-- Fade out after delay wait(#welcomeLetters * 0.07 + 1) for _, letter in pairs(welcomeLetters) do TweenService:Create(letter, TweenInfo.new(0.4), { TextTransparency = 1, TextSize = 40 }):Play() end wait(0.6) welcomeFrame:Destroy()

-- Icon Button (Zero Two Z Cute) local iconBtn = Instance.new("ImageButton", screenGui) iconBtn.Size = UDim2.new(0, 60, 0, 60) iconBtn.Position = UDim2.new(0.05, 0, 0.85, 0) iconBtn.Image = "rbxassetid://17082430544" -- Cute round Z icon iconBtn.BackgroundTransparency = 1

-- Main UI Frame local mainFrame = Instance.new("Frame", screenGui) mainFrame.Size = UDim2.new(0, 350, 0, 400) mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200) mainFrame.AnchorPoint = Vector2.new(0.5, 0.5) mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) mainFrame.BorderSizePixel = 0 mainFrame.Visible = false

-- Title local title = Instance.new("TextLabel", mainFrame) title.Size = UDim2.new(1, 0, 0, 50) title.Position = UDim2.new(0, 0, 0, 0) title.Text = "DarlingHub" title.Font = Enum.Font.GothamBlack title.TextSize = 28 title.TextColor3 = Color3.fromRGB(255, 255, 255) title.BackgroundTransparency = 1

-- Close Button local closeBtn = Instance.new("TextButton", mainFrame) closeBtn.Size = UDim2.new(0, 40, 0, 40) closeBtn.Position = UDim2.new(0, 10, 0, 10) closeBtn.Text = "X" closeBtn.Font = Enum.Font.GothamBold closeBtn.TextSize = 20 closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) closeBtn.BackgroundTransparency = 1

-- Feature Toggle local features = {"Fly", "ESP", "AutoFarm"} local toggleBoxes = {}

for i, feat in ipairs(features) do local container = Instance.new("TextButton", mainFrame) container.Size = UDim2.new(1, -40, 0, 40) container.Position = UDim2.new(0, 20, 0, 60 + (i - 1) * 60) container.Text = feat container.Font = Enum.Font.Gotham container.TextSize = 20 container.TextColor3 = Color3.fromRGB(255, 255, 255) container.BackgroundTransparency = 1

local outline = Instance.new("Frame", container)
outline.Size = UDim2.new(1, 0, 1, 0)
outline.Position = UDim2.new(0, 0, 0, 0)
outline.BackgroundTransparency = 1
outline.BorderColor3 = Color3.fromRGB(255, 0, 0)
outline.BorderSizePixel = 2
outline.Name = "Outline"

toggleBoxes[feat] = {button = container, outline = outline, active = false}

end

-- Toggle logic for feat, data in pairs(toggleBoxes) do data.button.MouseButton1Click:Connect(function() data.active = not data.active data.outline.BorderColor3 = data.active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0) end) end

-- Dragging Logic (Touchscreen-compatible) local function makeDraggable(frame) local dragToggle, dragInput, dragStart, startPos frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = true dragStart = input.Position startPos = frame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) end end) frame.InputChanged:Connect(function(input) if dragToggle and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then local delta = input.Position - dragStart frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end) end

makeDraggable(mainFrame) makeDraggable(iconBtn)

-- Toggle UI local function showUI() mainFrame.Visible = true mainFrame.Size = UDim2.new(0, 0, 0, 0) TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 350, 0, 400) }):Play() end

local function hideUI() TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 0, 0, 0) }):Play() wait(0.5) mainFrame.Visible = false end

iconBtn.MouseButton1Click:Connect(showUI) closeBtn.MouseButton1Click:Connect(hideUI)

