-- Services local TweenService = game:GetService("TweenService") local UserInputService = game:GetService("UserInputService")

-- UI Holder local screenGui = Instance.new("ScreenGui", game.CoreGui) screenGui.Name = "DarlingHub"

-- INTRO: Welcome Darling local introText = Instance.new("TextLabel") introText.Text = "" introText.Size = UDim2.new(1, 0, 0.2, 0) introText.Position = UDim2.new(0, 0, 0.4, 0) introText.BackgroundTransparency = 1 introText.TextColor3 = Color3.fromRGB(255, 105, 180) introText.TextStrokeTransparency = 0.6 introText.Font = Enum.Font.FredokaOne introText.TextSize = 60 introText.ZIndex = 10 introText.Parent = screenGui

local glow = Instance.new("UIStroke") glow.Color = Color3.fromRGB(255, 105, 180) glow.Thickness = 2 glow.Transparency = 0.4 glow.Parent = introText

local textStr = "Welcome Darling" for i = 1, #textStr do introText.Text = string.sub(textStr, 1, i) introText.TextTransparency = 1 TweenService:Create(introText, TweenInfo.new(0.03), {TextTransparency = 0}):Play() wait(0.03) end

introText.TextScaled = true introText.Size = UDim2.new(0.1, 0, 0.1, 0) TweenService:Create(introText, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.new(1, 0, 0.2, 0) }):Play()

wait(1.1)

for i = #textStr, 1, -1 do introText.Text = string.sub(textStr, 1, i) wait(0.02) end

TweenService:Create(introText, TweenInfo.new(0.3), {TextTransparency = 1}):Play() TweenService:Create(glow, TweenInfo.new(0.3), {Transparency = 1}):Play() wait(0.4) introText:Destroy()

-- MAIN UI FRAME local mainFrame = Instance.new("Frame") mainFrame.Name = "MainUI" mainFrame.Size = UDim2.new(0, 60, 0, 60) mainFrame.Position = UDim2.new(0.5, -30, 0.5, -30) mainFrame.AnchorPoint = Vector2.new(0.5, 0.5) mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) mainFrame.BackgroundTransparency = 0.25 mainFrame.BorderSizePixel = 0 mainFrame.Visible = false mainFrame.Parent = screenGui

-- Drag Function local function enableDrag(guiObject) local dragging, offset guiObject.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true offset = input.Position - guiObject.AbsolutePosition end end) UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end) UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then guiObject.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y) end end) end

-- Icon Button local iconBtn = Instance.new("TextButton") iconBtn.Text = "Z" iconBtn.Size = UDim2.new(0, 50, 0, 50) iconBtn.Position = UDim2.new(0, 50, 0, 300) iconBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180) iconBtn.TextColor3 = Color3.new(1, 1, 1) iconBtn.Font = Enum.Font.GothamBold iconBtn.TextSize = 28 iconBtn.Visible = false iconBtn.Parent = screenGui enableDrag(iconBtn)

-- Fade In UI local function fadeInUI() mainFrame.Visible = true mainFrame.Position = iconBtn.Position mainFrame.Size = UDim2.new(0, 60, 0, 60) TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 320, 0, 260), Position = UDim2.new(0.5, -160, 0.5, -130) }):Play() for _, d in pairs(mainFrame:GetDescendants()) do if d:IsA("TextLabel") or d:IsA("TextButton") then d.TextTransparency = 1 TweenService:Create(d, TweenInfo.new(0.4), { TextTransparency = 0 }):Play() elseif d:IsA("Frame") then d.BackgroundTransparency = 1 TweenService:Create(d, TweenInfo.new(0.4), { BackgroundTransparency = 0.25 }):Play() end end TweenService:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Back), { Size = UDim2.new(0, 330, 0, 270) }):Play() wait(0.1) TweenService:Create(mainFrame, TweenInfo.new(0.1), { Size = UDim2.new(0, 320, 0, 260) }):Play() end

-- Fade Out UI local function fadeOutUI() local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut) for _, d in pairs(mainFrame:GetDescendants()) do if d:IsA("TextLabel") or d:IsA("TextButton") then TweenService:Create(d, tweenInfo, { TextTransparency = 1 }):Play() elseif d:IsA("Frame") then TweenService:Create(d, tweenInfo, { BackgroundTransparency = 1 }):Play() end end TweenService:Create(mainFrame, tweenInfo, { Size = UDim2.new(0, 60, 0, 60), Position = iconBtn.Position }):Play() wait(0.4) mainFrame.Visible = false iconBtn.Visible = true TweenService:Create(iconBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Size = UDim2.new(0, 60, 0, 60) }):Play() end

-- Title local title = Instance.new("TextLabel") title.Text = "DarlingHub" title.Size = UDim2.new(1, 0, 0, 40) title.BackgroundTransparency = 1 title.TextColor3 = Color3.new(1, 1, 1) title.Font = Enum.Font.GothamBold title.TextSize = 24 title.Parent = mainFrame

-- Close Button local closeBtn = Instance.new("TextButton") closeBtn.Text = "X" closeBtn.Size = UDim2.new(0, 30, 0, 30) closeBtn.Position = UDim2.new(0, 10, 0, 10) closeBtn.TextColor3 = Color3.new(1, 1, 1) closeBtn.BackgroundTransparency = 1 closeBtn.Font = Enum.Font.GothamBold closeBtn.TextSize = 18 closeBtn.Parent = mainFrame

-- Feature Buttons local features = {"Fly", "Noclip", "PartName"} for i, name in ipairs(features) do local container = Instance.new("Frame") container.Size = UDim2.new(0.8, 0, 0, 36) container.Position = UDim2.new(0.1, 0, 0, 50 + (i - 1) * 45) container.BackgroundColor3 = Color3.new(0, 0, 0) container.BackgroundTransparency = 1 container.BorderColor3 = Color3.fromRGB(255, 0, 0) container.BorderSizePixel = 2 container.Parent = mainFrame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 1, 0)
btn.Text = name
btn.BackgroundTransparency = 1
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.Gotham
btn.TextSize = 16
btn.Parent = container

end

-- Enable drag for main UI enableDrag(mainFrame)

-- Event Hooks closeBtn.MouseButton1Click:Connect(fadeOutUI) iconBtn.MouseButton1Click:Connect(function() iconBtn.Visible = false fadeInUI() end)

-- Auto open UI after intro wait(0.2) fadeInUI()

