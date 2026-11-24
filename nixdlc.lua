local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local genv = getgenv and getgenv() or _G

local SCRIPT_TITLE = "Nexxwarre"
local STATE_KEY = "Nexxwarre_WindUI_Arceus_v11"
local VALID_KEY = "Test"
local KEY_FILE = "Nexxwarre_key.txt"
local CONFIG_DIR = "Nexxwarre_Configs"
local WIN_SOUND_ID = "rbxassetid://4764109000"

if genv[STATE_KEY] then
	pcall(function()
		genv[STATE_KEY].cleanup()
	end)
	genv[STATE_KEY] = nil
end

local function trimStr(s)
	return tostring(s or ""):match("^%s*(.-)%s*$")
end

local function sanitizeConfigName(raw)
	local clean = trimStr(raw):gsub("[^%w_%-]", "_")
	clean = clean:gsub("_+", "_"):gsub("^_+", ""):gsub("_+$", "")
	if clean == "" then
		return "default"
	end
	return clean:sub(1, 32)
end

local function saveVerifiedKey()
	genv["Nexxwarre_KeyVerified"] = true
	pcall(function()
		if type(writefile) == "function" then
			writefile(KEY_FILE, VALID_KEY)
		end
	end)
end

local function resolveGuiParent()
	local chosen = nil
	pcall(function()
		local cg = game:GetService("CoreGui")
		local testFolder = Instance.new("Folder")
		testFolder.Name = "nx_probe"
		testFolder.Parent = cg
		testFolder:Destroy()
		chosen = cg
	end)
	if not chosen and type(gethui) == "function" then
		pcall(function()
			local h = gethui()
			if h then chosen = h end
		end)
	end
	if not chosen then
		chosen = LocalPlayer:WaitForChild("PlayerGui")
	end
	return chosen
end

-- ================= CUSTOM "N" BRAND ICON BUILDER =================
local function createBrandIconN(parent, sizePx, cornerRadiusPx, colA, colB)
	local sz = sizePx or 26
	local rad = cornerRadiusPx or 7
	local c1 = colA or Color3.fromRGB(58, 225, 145)
	local c2 = colB or Color3.fromRGB(0, 225, 255)

	local iconBox = Instance.new("Frame")
	iconBox.Name = "NexxwarreIconN"
	iconBox.Size = UDim2.fromOffset(sz, sz)
	iconBox.BackgroundColor3 = Color3.fromRGB(16, 21, 32)
	iconBox.BorderSizePixel = 0
	iconBox.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, rad)
	corner.Parent = iconBox

	local bgGrad = Instance.new("UIGradient")
	bgGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1:Lerp(Color3.fromRGB(14, 18, 28), 0.65)),
		ColorSequenceKeypoint.new(1, c2:Lerp(Color3.fromRGB(12, 16, 24), 0.65))
	})
	bgGrad.Rotation = 45
	bgGrad.Parent = iconBox

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 1.3
	stroke.Transparency = 0.2
	stroke.Parent = iconBox

	local strokeGrad = Instance.new("UIGradient")
	strokeGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1),
		ColorSequenceKeypoint.new(1, c2)
	})
	strokeGrad.Rotation = 45
	strokeGrad.Parent = stroke

	local shadowLabel = Instance.new("TextLabel")
	shadowLabel.Size = UDim2.fromScale(1, 1)
	shadowLabel.Position = UDim2.fromOffset(1, 2)
	shadowLabel.BackgroundTransparency = 1
	shadowLabel.Text = "N"
	shadowLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	shadowLabel.TextTransparency = 0.45
	shadowLabel.Font = Enum.Font.GothamBlack
	shadowLabel.TextSize = math.max(11, math.floor(sz * 0.62))
	shadowLabel.Parent = iconBox

	local letterLabel = Instance.new("TextLabel")
	letterLabel.Size = UDim2.fromScale(1, 1)
	letterLabel.BackgroundTransparency = 1
	letterLabel.Text = "N"
	letterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	letterLabel.Font = Enum.Font.GothamBlack
	letterLabel.TextSize = math.max(11, math.floor(sz * 0.62))
	letterLabel.Parent = iconBox

	local letterGrad = Instance.new("UIGradient")
	letterGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1:Lerp(Color3.fromRGB(255, 255, 255), 0.35)),
		ColorSequenceKeypoint.new(1, c2:Lerp(Color3.fromRGB(255, 255, 255), 0.35))
	})
	letterGrad.Rotation = 90
	letterGrad.Parent = letterLabel

	return iconBox
end

local function createIconAndTitleHeader(parent, xPos, yPos, widthOffset, iconSize, titleText, textSize)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, widthOffset or -28, 0, math.max(24, iconSize or 24))
	holder.Position = UDim2.new(0, xPos or 14, 0, yPos or 12)
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = holder

	local iconObj = createBrandIconN(holder, iconSize or 24, 7, Color3.fromRGB(58, 225, 145), Color3.fromRGB(0, 225, 255))

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -(iconSize or 24) - 12, 1, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = titleText or SCRIPT_TITLE
	titleLbl.TextColor3 = Color3.fromRGB(244, 249, 255)
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = textSize or 17
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = holder

	return holder, iconObj, titleLbl
end

-- ================= DISCLAIMER + STYLED KEY SYSTEM GATE =================
local function promptDisclaimerAndKey(onSuccess)
	local parentGui = resolveGuiParent()

	local existingGate = parentGui:FindFirstChild("Nexxwarre_KeyGate")
	if existingGate then
		pcall(function() existingGate:Destroy() end)
	end
	local existingDisc = parentGui:FindFirstChild("Nexxwarre_DisclaimerGate")
	if existingDisc then
		pcall(function() existingDisc:Destroy() end)
	end

	local function openKeyGate()
		local gui = Instance.new("ScreenGui")
		gui.Name = "Nexxwarre_KeyGate"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 999999
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = parentGui

		local backdrop = Instance.new("Frame")
		backdrop.Size = UDim2.fromScale(1, 1)
		backdrop.BackgroundColor3 = Color3.fromRGB(4, 6, 10)
		backdrop.BackgroundTransparency = 0.42
		backdrop.BorderSizePixel = 0
		backdrop.Parent = gui

		local aura = Instance.new("ImageLabel")
		aura.Size = UDim2.fromOffset(420, 290)
		aura.Position = UDim2.new(0.5, -210, 0.5, -145)
		aura.BackgroundTransparency = 1
		aura.Image = "rbxassetid://5028857472"
		aura.ImageColor3 = Color3.fromRGB(48, 226, 152)
		aura.ImageTransparency = 0.68
		aura.Parent = gui

		local card = Instance.new("Frame")
		card.Size = UDim2.fromOffset(344, 248)
		card.Position = UDim2.new(0.5, -172, 0.5, -124)
		card.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
		card.BackgroundTransparency = 0.05
		card.BorderSizePixel = 0
		card.Active = true
		card.Draggable = true
		card.Parent = gui

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 16)
		cardCorner.Parent = card

		local cardGrad = Instance.new("UIGradient")
		cardGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 33, 52)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(12, 15, 23)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 30, 28))
		})
		cardGrad.Rotation = 35
		cardGrad.Parent = card

		local cardStroke = Instance.new("UIStroke")
		cardStroke.Color = Color3.fromRGB(255, 255, 255)
		cardStroke.Thickness = 1.7
		cardStroke.Transparency = 0.12
		cardStroke.Parent = card

		local strokeGrad = Instance.new("UIGradient")
		strokeGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 225, 145)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 225, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(178, 102, 255))
		})
		strokeGrad.Rotation = 0
		strokeGrad.Parent = cardStroke

		local accentBar = Instance.new("Frame")
		accentBar.Size = UDim2.new(1, -28, 0, 2)
		accentBar.Position = UDim2.new(0, 14, 0, 44)
		accentBar.BorderSizePixel = 0
		accentBar.Parent = card

		local accentGrad = Instance.new("UIGradient")
		accentGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 225, 145)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 225, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 225, 145))
		})
		accentGrad.Parent = accentBar

		local badge = Instance.new("Frame")
		badge.Size = UDim2.fromOffset(82, 20)
		badge.Position = UDim2.new(1, -96, 0, 15)
		badge.BackgroundColor3 = Color3.fromRGB(22, 48, 44)
		badge.BorderSizePixel = 0
		badge.Parent = card

		local badgeCorner = Instance.new("UICorner")
		badgeCorner.CornerRadius = UDim.new(0, 6)
		badgeCorner.Parent = badge

		local badgeStroke = Instance.new("UIStroke")
		badgeStroke.Color = Color3.fromRGB(72, 240, 165)
		badgeStroke.Thickness = 0.8
		badgeStroke.Transparency = 0.55
		badgeStroke.Parent = badge

		local badgeText = Instance.new("TextLabel")
		badgeText.Size = UDim2.fromScale(1, 1)
		badgeText.BackgroundTransparency = 1
		badgeText.Text = "KEY SYSTEM"
		badgeText.TextColor3 = Color3.fromRGB(72, 240, 165)
		badgeText.Font = Enum.Font.GothamBold
		badgeText.TextSize = 10
		badgeText.Parent = badge

		createIconAndTitleHeader(card, 14, 12, -116, 24, SCRIPT_TITLE, 17)

		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(1, -110, 0, 18)
		sub.Position = UDim2.new(0, 14, 0, 52)
		sub.BackgroundTransparency = 1
		sub.Text = "Enter license key to unlock hub"
		sub.TextColor3 = Color3.fromRGB(156, 170, 192)
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 12
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.Parent = card

		local fillHintBtn = Instance.new("TextButton")
		fillHintBtn.Size = UDim2.fromOffset(82, 18)
		fillHintBtn.Position = UDim2.new(1, -96, 0, 52)
		fillHintBtn.BackgroundColor3 = Color3.fromRGB(24, 32, 46)
		fillHintBtn.BorderSizePixel = 0
		fillHintBtn.Text = "Use: Test"
		fillHintBtn.TextColor3 = Color3.fromRGB(130, 235, 255)
		fillHintBtn.Font = Enum.Font.GothamBold
		fillHintBtn.TextSize = 11
		fillHintBtn.Parent = card

		local fillHintCorner = Instance.new("UICorner")
		fillHintCorner.CornerRadius = UDim.new(0, 5)
		fillHintCorner.Parent = fillHintBtn

		local boxFrame = Instance.new("Frame")
		boxFrame.Size = UDim2.new(1, -28, 0, 42)
		boxFrame.Position = UDim2.new(0, 14, 0, 77)
		boxFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 36)
		boxFrame.BorderSizePixel = 0
		boxFrame.Parent = card

		local boxCorner = Instance.new("UICorner")
		boxCorner.CornerRadius = UDim.new(0, 10)
		boxCorner.Parent = boxFrame

		local boxStroke = Instance.new("UIStroke")
		boxStroke.Color = Color3.fromRGB(68, 84, 112)
		boxStroke.Thickness = 1.2
		boxStroke.Transparency = 0.3
		boxStroke.Parent = boxFrame

		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, -18, 1, 0)
		box.Position = UDim2.new(0, 9, 0, 0)
		box.BackgroundTransparency = 1
		box.PlaceholderText = "Type key (e.g. Test)..."
		box.PlaceholderColor3 = Color3.fromRGB(110, 124, 148)
		box.Text = ""
		box.TextColor3 = Color3.fromRGB(245, 250, 255)
		box.Font = Enum.Font.GothamMedium
		box.TextSize = 13
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.ClearTextOnFocus = false
		box.Parent = boxFrame

		local status = Instance.new("TextLabel")
		status.Size = UDim2.new(1, -28, 0, 18)
		status.Position = UDim2.new(0, 14, 0, 125)
		status.BackgroundTransparency = 1
		status.Text = "Drag card to move • Key: Test"
		status.TextColor3 = Color3.fromRGB(130, 146, 172)
		status.Font = Enum.Font.GothamMedium
		status.TextSize = 11
		status.TextXAlignment = Enum.TextXAlignment.Left
		status.Parent = card

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -28, 0, 42)
		btn.Position = UDim2.new(0, 14, 0, 152)
		btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		btn.BorderSizePixel = 0
		btn.Text = "Unlock " .. SCRIPT_TITLE
		btn.TextColor3 = Color3.fromRGB(10, 14, 18)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 13
		btn.Parent = card

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 11)
		btnCorner.Parent = btn

		local btnGrad = Instance.new("UIGradient")
		btnGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 225, 145)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 205, 235))
		})
		btnGrad.Parent = btn

		local footerNote = Instance.new("TextLabel")
		footerNote.Size = UDim2.new(1, -28, 0, 16)
		footerNote.Position = UDim2.new(0, 14, 0, 208)
		footerNote.BackgroundTransparency = 1
		footerNote.Text = SCRIPT_TITLE .. " • Arceus X Neo"
		footerNote.TextColor3 = Color3.fromRGB(105, 120, 145)
		footerNote.Font = Enum.Font.Gotham
		footerNote.TextSize = 10
		footerNote.TextXAlignment = Enum.TextXAlignment.Center
		footerNote.Parent = card

		fillHintBtn.MouseButton1Click:Connect(function()
			box.Text = VALID_KEY
			boxStroke.Color = Color3.fromRGB(0, 225, 255)
			status.TextColor3 = Color3.fromRGB(130, 235, 255)
			status.Text = "Inserted key 'Test' — tap Unlock"
		end)

		local animRunning = true
		task.spawn(function()
			local rot = 0
			while animRunning and gui.Parent do
				rot = (rot + 1.5) % 360
				strokeGrad.Rotation = rot
				task.wait(0.03)
			end
		end)

		pcall(function()
			card.Position = UDim2.new(0.5, -172, 0.5, -103)
			TweenService:Create(card, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.5, -172, 0.5, -124)
			}):Play()
		end)

		local unlockedOnce = false
		local function attemptVerify()
			if unlockedOnce then return end
			local entered = trimStr(box.Text)
			if entered == VALID_KEY then
				unlockedOnce = true
				animRunning = false
				boxStroke.Color = Color3.fromRGB(58, 225, 145)
				status.TextColor3 = Color3.fromRGB(58, 225, 145)
				status.Text = "Access granted! Loading " .. SCRIPT_TITLE .. "..."
				saveVerifiedKey()
				pcall(function()
					TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Position = UDim2.new(0.5, -172, 0.5, -144)
					}):Play()
					TweenService:Create(backdrop, TweenInfo.new(0.22), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(aura, TweenInfo.new(0.22), { ImageTransparency = 1 }):Play()
				end)
				task.delay(0.24, function()
					pcall(function() gui:Destroy() end)
					onSuccess()
				end)
			else
				boxStroke.Color = Color3.fromRGB(245, 75, 105)
				status.TextColor3 = Color3.fromRGB(245, 85, 105)
				status.Text = "Invalid key! Use 'Test' to unlock."
			end
		end

		btn.MouseButton1Click:Connect(attemptVerify)
		box.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				attemptVerify()
			end
		end)
	end

	-- ================= DISCLAIMER SCREEN =================
	local discGui = Instance.new("ScreenGui")
	discGui.Name = "Nexxwarre_DisclaimerGate"
	discGui.ResetOnSpawn = false
	discGui.IgnoreGuiInset = true
	discGui.DisplayOrder = 1000000
	discGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	discGui.Parent = parentGui

	local discBackdrop = Instance.new("Frame")
	discBackdrop.Size = UDim2.fromScale(1, 1)
	discBackdrop.BackgroundColor3 = Color3.fromRGB(4, 6, 10)
	discBackdrop.BackgroundTransparency = 0.45
	discBackdrop.BorderSizePixel = 0
	discBackdrop.Parent = discGui

	local discAura = Instance.new("ImageLabel")
	discAura.Size = UDim2.fromOffset(440, 320)
	discAura.Position = UDim2.new(0.5, -220, 0.5, -160)
	discAura.BackgroundTransparency = 1
	discAura.Image = "rbxassetid://5028857472"
	discAura.ImageColor3 = Color3.fromRGB(0, 225, 255)
	discAura.ImageTransparency = 0.72
	discAura.Parent = discGui

	local discCard = Instance.new("Frame")
	discCard.Size = UDim2.fromOffset(356, 268)
	discCard.Position = UDim2.new(0.5, -178, 0.5, -134)
	discCard.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
	discCard.BackgroundTransparency = 0.05
	discCard.BorderSizePixel = 0
	discCard.Active = true
	discCard.Draggable = true
	discCard.Parent = discGui

	local discCorner = Instance.new("UICorner")
	discCorner.CornerRadius = UDim.new(0, 16)
	discCorner.Parent = discCard

	local discGrad = Instance.new("UIGradient")
	discGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 33, 52)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(12, 15, 23)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 30, 28))
	})
	discGrad.Rotation = 35
	discGrad.Parent = discCard

	local discStroke = Instance.new("UIStroke")
	discStroke.Color = Color3.fromRGB(255, 255, 255)
	discStroke.Thickness = 1.7
	discStroke.Transparency = 0.12
	discStroke.Parent = discCard

	local discStrokeGrad = Instance.new("UIGradient")
	discStrokeGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 225, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(58, 225, 145)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(178, 102, 255))
	})
	discStrokeGrad.Rotation = 0
	discStrokeGrad.Parent = discStroke

	local discBadge = Instance.new("Frame")
	discBadge.Size = UDim2.fromOffset(92, 20)
	discBadge.Position = UDim2.new(1, -106, 0, 15)
	discBadge.BackgroundColor3 = Color3.fromRGB(20, 42, 54)
	discBadge.BorderSizePixel = 0
	discBadge.Parent = discCard

	local discBadgeCorner = Instance.new("UICorner")
	discBadgeCorner.CornerRadius = UDim.new(0, 6)
	discBadgeCorner.Parent = discBadge

	local discBadgeStroke = Instance.new("UIStroke")
	discBadgeStroke.Color = Color3.fromRGB(0, 225, 255)
	discBadgeStroke.Thickness = 0.8
	discBadgeStroke.Transparency = 0.5
	discBadgeStroke.Parent = discBadge

	local discBadgeText = Instance.new("TextLabel")
	discBadgeText.Size = UDim2.fromScale(1, 1)
	discBadgeText.BackgroundTransparency = 1
	discBadgeText.Text = "DISCLAIMER"
	discBadgeText.TextColor3 = Color3.fromRGB(130, 235, 255)
	discBadgeText.Font = Enum.Font.GothamBold
	discBadgeText.TextSize = 10
	discBadgeText.Parent = discBadge

	createIconAndTitleHeader(discCard, 14, 12, -124, 24, SCRIPT_TITLE .. " Notice", 17)

	local discLine = Instance.new("Frame")
	discLine.Size = UDim2.new(1, -28, 0, 2)
	discLine.Position = UDim2.new(0, 14, 0, 44)
	discLine.BorderSizePixel = 0
	discLine.Parent = discCard

	local discLineGrad = Instance.new("UIGradient")
	discLineGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 225, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(58, 225, 145)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 225, 255))
	})
	discLineGrad.Parent = discLine

	local discBody = Instance.new("TextLabel")
	discBody.Size = UDim2.new(1, -28, 0, 118)
	discBody.Position = UDim2.new(0, 14, 0, 54)
	discBody.BackgroundTransparency = 1
	discBody.Text = "This script is provided for testing and visual customization purposes only.\n\n• You use all features at your own risk.\n• Visuals, lighting, movement & hitbox options may behave differently across places or executors.\n• By continuing, you accept responsibility for your session."
	discBody.TextColor3 = Color3.fromRGB(185, 198, 218)
	discBody.Font = Enum.Font.Gotham
	discBody.TextSize = 11.5
	discBody.TextWrapped = true
	discBody.TextXAlignment = Enum.TextXAlignment.Left
	discBody.TextYAlignment = Enum.TextYAlignment.Top
	discBody.Parent = discCard

	local declineBtn = Instance.new("TextButton")
	declineBtn.Size = UDim2.new(0.42, -18, 0, 40)
	declineBtn.Position = UDim2.new(0, 14, 1, -66)
	declineBtn.BackgroundColor3 = Color3.fromRGB(28, 22, 30)
	declineBtn.BorderSizePixel = 0
	declineBtn.Text = "Decline"
	declineBtn.TextColor3 = Color3.fromRGB(245, 95, 115)
	declineBtn.Font = Enum.Font.GothamBold
	declineBtn.TextSize = 12.5
	declineBtn.Parent = discCard

	local declineCorner = Instance.new("UICorner")
	declineCorner.CornerRadius = UDim.new(0, 10)
	declineCorner.Parent = declineBtn

	local declineStroke = Instance.new("UIStroke")
	declineStroke.Color = Color3.fromRGB(245, 85, 105)
	declineStroke.Thickness = 1
	declineStroke.Transparency = 0.45
	declineStroke.Parent = declineBtn

	local acceptBtn = Instance.new("TextButton")
	acceptBtn.Size = UDim2.new(0.58, -14, 0, 40)
	acceptBtn.Position = UDim2.new(0.42, 0, 1, -66)
	acceptBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	acceptBtn.BorderSizePixel = 0
	acceptBtn.Text = "I Understand & Continue"
	acceptBtn.TextColor3 = Color3.fromRGB(10, 14, 18)
	acceptBtn.Font = Enum.Font.GothamBold
	acceptBtn.TextSize = 12.5
	acceptBtn.Parent = discCard

	local acceptCorner = Instance.new("UICorner")
	acceptCorner.CornerRadius = UDim.new(0, 10)
	acceptCorner.Parent = acceptBtn

	local acceptGrad = Instance.new("UIGradient")
	acceptGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 225, 145)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 225, 255))
	})
	acceptGrad.Parent = acceptBtn

	local discFooter = Instance.new("TextLabel")
	discFooter.Size = UDim2.new(1, -28, 0, 16)
	discFooter.Position = UDim2.new(0, 14, 1, -22)
	discFooter.BackgroundTransparency = 1
	discFooter.Text = "Drag window to move • Key step follows"
	discFooter.TextColor3 = Color3.fromRGB(105, 120, 145)
	discFooter.Font = Enum.Font.Gotham
	discFooter.TextSize = 10
	discFooter.TextXAlignment = Enum.TextXAlignment.Center
	discFooter.Parent = discCard

	local discAnimRunning = true
	task.spawn(function()
		local rot = 0
		while discAnimRunning and discGui.Parent do
			rot = (rot + 1.5) % 360
			discStrokeGrad.Rotation = rot
			task.wait(0.03)
		end
	end)

	pcall(function()
		discCard.Position = UDim2.new(0.5, -178, 0.5, -112)
		TweenService:Create(discCard, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, -178, 0.5, -134)
		}):Play()
	end)

	declineBtn.MouseButton1Click:Connect(function()
		discAnimRunning = false
		pcall(function() discGui:Destroy() end)
	end)

	local acceptedOnce = false
	acceptBtn.MouseButton1Click:Connect(function()
		if acceptedOnce then return end
		acceptedOnce = true
		discAnimRunning = false
		pcall(function()
			TweenService:Create(discCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, -178, 0.5, -154)
			}):Play()
			TweenService:Create(discBackdrop, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(discAura, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
		end)
		task.delay(0.22, function()
			pcall(function() discGui:Destroy() end)
			openKeyGate()
		end)
	end)
end

-- ================= CORE HUB LOGIC =================
local function startNexxwarreHub()
	local OriginalLighting = {
		FogColor = Lighting.FogColor,
		FogStart = Lighting.FogStart,
		FogEnd = Lighting.FogEnd,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ColorShift_Top = Lighting.ColorShift_Top,
		ColorShift_Bottom = Lighting.ColorShift_Bottom,
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime
	}
	local OriginalGravity = workspace.Gravity

	local OriginalAtmosphere = nil
	do
		local existingAtm = Lighting:FindFirstChildOfClass("Atmosphere")
		if existingAtm then
			OriginalAtmosphere = {
				Instance = existingAtm,
				Density = existingAtm.Density,
				Offset = existingAtm.Offset,
				Color = existingAtm.Color,
				Decay = existingAtm.Decay,
				Glare = existingAtm.Glare,
				Haze = existingAtm.Haze
			}
		end
	end

	local DefaultFov = Camera and Camera.FieldOfView or 70

	local ColorMap = {
		Emerald = Color3.fromRGB(58, 225, 145),
		Arctic = Color3.fromRGB(135, 220, 255),
		Cyber = Color3.fromRGB(0, 235, 255),
		Crimson = Color3.fromRGB(245, 72, 98),
		Amethyst = Color3.fromRGB(178, 102, 255),
		Sunset = Color3.fromRGB(255, 158, 82),
		White = Color3.fromRGB(240, 245, 252)
	}

	local ColorNames = { "Emerald", "Arctic", "Cyber", "Crimson", "Amethyst", "Sunset", "White" }
	local WindUiThemes = { "Dark", "Midnight", "Amethyst", "Rose", "Emerald", "Light", "Cyberpunk", "Crimson", "Obsidian" }
	local ParticleStyles = { "Motes", "Snow", "Sparks", "Dust", "Combo" }

	local SkyMoodPresets = {
		Original = { ClockTime = OriginalLighting.ClockTime, Brightness = OriginalLighting.Brightness, Tint = Color3.fromRGB(255, 255, 255) },
		Midnight = { ClockTime = 1.2, Brightness = 1.15, Tint = Color3.fromRGB(175, 215, 255) },
		CyberDusk = { ClockTime = 18.4, Brightness = 1.35, Tint = Color3.fromRGB(215, 185, 255) },
		GoldenHour = { ClockTime = 17.3, Brightness = 1.55, Tint = Color3.fromRGB(255, 212, 168) }
	}

	local Config = {
		TopicTheme = "Dark",

		-- Ball
		HitboxEnabled = false,
		BallRadius = 12,
		BallHitbox3DEnabled = false,
		BallHitbox3DColorName = "Cyber",
		BallHitbox3DTransp = 55,
		BallHitboxChamsEnabled = false,
		BallHitboxChamsThroughWalls = false,
		BallHitboxChamsFillColorName = "Cyber",
		BallHitboxChamsOutlineColorName = "Emerald",
		BallHitboxChamsFillTransp = 55,
		BallHitboxChamsOutlineTransp = 10,
		BallHitboxChamsPulseSpeed = 0,
		BallVisualScale = 100,
		Ball2DBoxEnabled = false,
		Ball2DBoxColorName = "Emerald",
		Ball2DBoxThickness = 2,
		RingEnabled = false,
		RingColorName = "Emerald",
		RingThickness = 2,
		BallLineEnabled = false,
		BallLineColorName = "Arctic",
		BallLineThickness = 2,
		BallCrosshairEnabled = false,
		BallSpeedTagEnabled = false,
		BallVelArrowEnabled = false,
		BallVelArrowColorName = "Sunset",
		BallVelArrowScale = 100,
		TracerEnabled = false,
		TracerColorName = "Cyber",
		TracerThickness = 2,
		TrajectoryArcEnabled = false,
		PulseWaveEnabled = false,
		BallTrailEnabled = false,
		BallTrailColorName = "Cyber",
		BallTrailLength = 10,
		BallTrailThickness = 2,

		-- ESP людей + GRADIENT GLOW OFFSCREEN ESP
		EspEnabled = false,
		EspOffscreenEnabled = false,
		EspOffscreenRadius = 120,
		EspOffscreenColorName = "Crimson",
		EspOffscreenAccentName = "Cyber",
		Esp2DBoxEnabled = false,
		EspCornerBoxEnabled = false,
		Esp3DBoxEnabled = false,
		EspSkeletonEnabled = false,
		EspHeadDotEnabled = false,
		EspInfoTagEnabled = false,
		EspHealthBarEnabled = false,
		EspColorName = "Emerald",
		EspThickness = 2,

		-- Chams
		ChamsEnabled = false,
		ChamsThroughWalls = false,
		ChamsSelfEnabled = false,
		ChamsFillColorName = "Emerald",
		ChamsOutlineColorName = "Cyber",
		ChamsFillTransp = 45,
		ChamsOutlineTransp = 10,
		ChamsPulseSpeed = 0,

		-- World + Different Particles
		SkyMoodName = "Original",
		CustomSkyEnabled = false,
		CustomSkyColorName = "Cyber",
		CustomSkyCelestial = true,
		WorldParticlesEnabled = false,
		WorldParticleMode = "Motes",
		WorldParticlesColorName = "Emerald",
		WorldParticlesRate = 85,
		WorldParticlesSize = 35,
		WorldMotesEnabled = false,
		WorldMotesRate = 65,
		WorldSnowEnabled = false,
		WorldSnowRate = 140,
		WorldSnowSize = 35,
		FogEnabled = false,
		FogStart = 20,
		FogEnd = 220,
		FogColorName = "Arctic",
		AtmosphereEnabled = false,
		AtmosphereColorName = "Emerald",
		AtmosphereIntensity = 65,
		BloomEnabled = false,
		BloomIntensity = 45,
		SunRaysEnabled = false,
		SunRaysIntensity = 35,

		-- Visuals
		WinEdgeEffectEnabled = false,
		WinEdgeColorName = "Emerald",
		WinEdgeDuration = 120,
		WinSoundEnabled = false,
		HitFlashEnabled = false,
		HitFlashColorName = "Emerald",
		HitFlashDuration = 55,
		ScreenFrameEnabled = false,
		GroundRingEnabled = false,
		CircleFovEnabled = false,
		CircleFovRadius = 135,
		ScreenFovEnabled = false,
		ScreenFovValue = math.clamp(DefaultFov, 55, 115),
		StretchEnabled = false,
		StretchRatio = 75,
		CrosshairEnabled = false,
		CrosshairSize = 8,
		RadarEnabled = false,
		RadarRange = 140,
		CompassBarEnabled = false,
		CompassBarColorName = "Arctic",
		SnapLineEnabled = false,
		SnapLineColorName = "Crimson",
		AimRingEnabled = false,
		AimRingRadius = 64,
		AimRingColorName = "Cyber",
		CameraTiltEnabled = false,
		CameraTiltAngle = 4,
		WatermarkHudEnabled = false,
		WatermarkColorName = "Emerald",

		-- Crosshair (1000 presets + Dynamic Spread)
		CrosshairTabEnabled = false,
		CrosshairPresetId = 1,
		CrosshairPresetColorName = "Emerald",
		CrosshairPresetScale = 100,
		CrosshairPresetThickness = 2,
		CrosshairPresetSpin = 0,
		CrosshairDynamicEnabled = false,
		CrosshairDynamicSpread = 100,

		-- Movement
		LegitSpeedEnabled = false,
		LegitSpeed = 22,
		JumpBoostEnabled = false,
		JumpPowerValue = 58,
		SpinEnabled = false,
		SpinSpeed = 18,

		-- Local Tab
		LocalNoClipEnabled = false,
		LocalAntiAfkEnabled = false,
		LocalInfJumpEnabled = false,
		LocalSwimAssistEnabled = false,
		LocalLowGravityEnabled = false,
		LocalGravityValue = 75,
		LocalFullBrightEnabled = false,
		LocalFreezeEnabled = false,
		LocalDashDistance = 18
	}

	local Connections = {}
	local Balls = {}
	local EspEntries = {}
	local OffscreenArrows = {}
	local ChamsHighlights = {}
	local RadarDots = {}
	local AmbientCCRef = nil
	local SkyMoodCCRef = nil
	local CustomSkyRef = nil
	local BloomRef = nil
	local SunRaysRef = nil
	local WorldSnowPart = nil
	local WorldSnowEmitter = nil
	local WorldMotesPart = nil
	local WorldMotesEmitter = nil
	local WorldMultiPart = nil
	local WorldMultiPrimary = nil
	local WorldMultiSecondary = nil
	local elapsedClock = 0
	local smoothSpreadPx = 0
	local fpsSmoothed = 60

	local lastThrowTime = 0
	local lastThrownBallPos = nil
	local lastBallCrossedFarZone = false
	local winEffectTimer = 0
	local lastWinTriggerTime = 0
	local hitFlashTimer = 0
	local lastHitFlashTime = 0
	local watchedValues = {}
	local lastGuiTextMap = {}

	local SavedConfigsMap = {}
	local SelectedConfigName = nil
	local ConfigNameInput = "preset_1"
	local RefreshConfigBarFn = nil
	local SyncUiFromConfigFn = nil

	local function safeDrawing(className, props)
		local ok, obj = pcall(function()
			if type(Drawing) ~= "table" or type(Drawing.new) ~= "function" then
				return nil
			end
			local d = Drawing.new(className)
			for k, v in pairs(props or {}) do
				d[k] = v
			end
			return d
		end)
		return ok and obj or nil
	end

	local function safeRemoveDrawing(obj)
		if not obj then return end
		pcall(function()
			obj.Visible = false
			obj:Remove()
		end)
	end

	local function getNamedColor(nameStr)
		return ColorMap[tostring(nameStr or "")] or Color3.fromRGB(58, 225, 145)
	end

	local function getSkyMood(nameStr)
		return SkyMoodPresets[tostring(nameStr or "")] or SkyMoodPresets.Original
	end

	-- ================= HIT / ACTION FLASH =================
	local hitFlashTop = safeDrawing("Line", { Thickness = 7, Transparency = 0, Visible = false })
	local hitFlashBot = safeDrawing("Line", { Thickness = 7, Transparency = 0, Visible = false })
	local hitFlashLeft = safeDrawing("Line", { Thickness = 7, Transparency = 0, Visible = false })
	local hitFlashRight = safeDrawing("Line", { Thickness = 7, Transparency = 0, Visible = false })

	local function hideHitFlashLines()
		if hitFlashTop then hitFlashTop.Visible = false end
		if hitFlashBot then hitFlashBot.Visible = false end
		if hitFlashLeft then hitFlashLeft.Visible = false end
		if hitFlashRight then hitFlashRight.Visible = false end
	end

	local function triggerHitFlash(forceBypassCooldown)
		if not Config.HitFlashEnabled and not forceBypassCooldown then return end
		local now = os.clock()
		if not forceBypassCooldown and (now - lastHitFlashTime < 0.22) then
			return
		end
		lastHitFlashTime = now
		local durSec = math.clamp((Config.HitFlashDuration or 55) / 100, 0.18, 1.4)
		hitFlashTimer = durSec
	end

	local function updateHitFlash(dt)
		Camera = workspace.CurrentCamera
		if not Camera or not Config.HitFlashEnabled or hitFlashTimer <= 0 then
			hitFlashTimer = 0
			hideHitFlashLines()
			return
		end

		hitFlashTimer = math.max(0, hitFlashTimer - dt)
		local durSec = math.max(0.12, math.clamp((Config.HitFlashDuration or 55) / 100, 0.18, 1.4))
		local t = 1 - (hitFlashTimer / durSec)
		local alpha = math.clamp((1 - t) * 0.85, 0, 0.85)
		if alpha <= 0.02 then
			hideHitFlashLines()
			return
		end

		local vp = Camera.ViewportSize
		local col = getNamedColor(Config.HitFlashColorName)
		local pad = 3
		local w, h = vp.X, vp.Y

		if hitFlashTop then hitFlashTop.Color = col; hitFlashTop.Transparency = alpha; hitFlashTop.From = Vector2.new(pad, pad); hitFlashTop.To = Vector2.new(w - pad, pad); hitFlashTop.Visible = true end
		if hitFlashBot then hitFlashBot.Color = col; hitFlashBot.Transparency = alpha; hitFlashBot.From = Vector2.new(pad, h - pad); hitFlashBot.To = Vector2.new(w - pad, h - pad); hitFlashBot.Visible = true end
		if hitFlashLeft then hitFlashLeft.Color = col; hitFlashLeft.Transparency = alpha; hitFlashLeft.From = Vector2.new(pad, pad); hitFlashLeft.To = Vector2.new(pad, h - pad); hitFlashLeft.Visible = true end
		if hitFlashRight then hitFlashRight.Color = col; hitFlashRight.Transparency = alpha; hitFlashRight.From = Vector2.new(w - pad, pad); hitFlashRight.To = Vector2.new(w - pad, h - pad); hitFlashRight.Visible = true end
	end

	-- ================= 1000 CROSSHAIRS GENERATOR + DYNAMIC SPREAD =================
	local CROSSHAIR_ARCHETYPES = {
		"Classic Cross",
		"Precision Dot",
		"Halo Ring",
		"Dual Ring",
		"Diagonal X",
		"Diamond Frame",
		"Tactical Brackets",
		"Starburst",
		"Sniper Ticks",
		"Orbit Pulse"
	}

	local function buildCrosshairSpec(id)
		local n = math.clamp(math.floor(tonumber(id) or 1), 1, 1000)
		local seed = (n * 2654435761) % 4294967296
		local function nextRand()
			seed = (seed * 1664525 + 1013904223) % 4294967296
			return seed / 4294967296
		end

		local archIndex = ((n - 1) % #CROSSHAIR_ARCHETYPES) + 1
		local archName = CROSSHAIR_ARCHETYPES[archIndex]

		local r1 = nextRand()
		local r2 = nextRand()
		local r3 = nextRand()
		local r4 = nextRand()
		local r5 = nextRand()
		local r6 = nextRand()

		local rayCount = 4
		if archName == "Starburst" then
			rayCount = 6 + math.floor(r1 * 7)
		elseif archName == "Orbit Pulse" then
			rayCount = 4 + math.floor(r1 * 5)
		end

		return {
			id = n,
			archetype = archName,
			rayCount = rayCount,
			gap = 3 + math.floor(r2 * 14),
			length = 4 + math.floor(r3 * 16),
			baseAngle = math.rad(math.floor(r4 * 360)),
			hasCenterDot = (archName == "Precision Dot") or (r5 > 0.35),
			centerRadius = (archName == "Precision Dot") and (2.5 + r6 * 3.5) or (1.5 + r6 * 2.2),
			hasOuterRing = (archName == "Halo Ring") or (archName == "Dual Ring") or (r2 > 0.65),
			outerRadius = 11 + math.floor(r3 * 18),
			hasInnerRing = (archName == "Dual Ring") or (archName == "Orbit Pulse") or (r4 > 0.78),
			innerRadius = 5 + math.floor(r5 * 8),
			hasTicks = (archName == "Sniper Ticks") or (archName == "Tactical Brackets") or (r6 > 0.72),
			pulseAmp = (archName == "Orbit Pulse" or r1 > 0.68) and (0.14 + r2 * 0.22) or 0
		}
	end

	local MAX_XHAIR_LINES = 24
	local MAX_XHAIR_DOTS = 10
	local xhairLines = {}
	local xhairDots = {}
	local xhairOuterCircle = safeDrawing("Circle", { Filled = false, NumSides = 72, Visible = false })
	local xhairInnerCircle = safeDrawing("Circle", { Filled = false, NumSides = 64, Visible = false })

	for i = 1, MAX_XHAIR_LINES do
		xhairLines[i] = safeDrawing("Line", { Visible = false })
	end
	for i = 1, MAX_XHAIR_DOTS do
		xhairDots[i] = safeDrawing("Circle", { Filled = true, NumSides = 20, Visible = false })
	end

	local function hideCustomCrosshair()
		if xhairOuterCircle then xhairOuterCircle.Visible = false end
		if xhairInnerCircle then xhairInnerCircle.Visible = false end
		for i = 1, MAX_XHAIR_LINES do
			if xhairLines[i] then xhairLines[i].Visible = false end
		end
		for i = 1, MAX_XHAIR_DOTS do
			if xhairDots[i] then xhairDots[i].Visible = false end
		end
	end

	local function updateCustomCrosshair(dt)
		Camera = workspace.CurrentCamera
		if not Config.CrosshairTabEnabled or not Camera then
			smoothSpreadPx = 0
			hideCustomCrosshair()
			return
		end

		local targetSpreadPx = 0
		if Config.CrosshairDynamicEnabled then
			local mult = math.clamp((Config.CrosshairDynamicSpread or 100) / 100, 0.2, 2.5)
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			local moveFactor = 0
			if hrp then
				local horizSpeed = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z).Magnitude
				moveFactor = math.clamp(horizSpeed / 24, 0, 1.35) * 9.5
			end

			local airFactor = 0
			if hum and hum.FloorMaterial == Enum.Material.Air then
				airFactor = 5.5
			end

			local hitPulseFactor = 0
			if hitFlashTimer > 0 then
				hitPulseFactor = math.clamp(hitFlashTimer * 18, 0, 10)
			end

			targetSpreadPx = (moveFactor + airFactor + hitPulseFactor) * mult
		end

		smoothSpreadPx = smoothSpreadPx + (targetSpreadPx - smoothSpreadPx) * math.clamp((dt or 0.016) * 14, 0, 1)

		local spec = buildCrosshairSpec(Config.CrosshairPresetId)
		local vp = Camera.ViewportSize
		local cx, cy = vp.X * 0.5, vp.Y * 0.5
		local col = getNamedColor(Config.CrosshairPresetColorName)
		local scale = math.clamp((Config.CrosshairPresetScale or 100) / 100, 0.35, 2.5)
		local thick = math.clamp(Config.CrosshairPresetThickness or 2, 1, 5)
		local spinRad = math.rad((Config.CrosshairPresetSpin or 0) * 36) * elapsedClock
		local pulseMult = 1 + (spec.pulseAmp > 0 and (math.sin(elapsedClock * 5) * spec.pulseAmp) or 0)

		local gap = spec.gap * scale * pulseMult + smoothSpreadPx
		local len = spec.length * scale * pulseMult
		local rot = spec.baseAngle + spinRad
		if spec.archetype == "Diagonal X" then
			rot = rot + math.rad(45)
		end

		local lineIdx = 0
		local dotIdx = 0

		local function pushLine(pFrom, pTo, lineThick, alpha)
			lineIdx += 1
			local ln = xhairLines[lineIdx]
			if ln then
				ln.From = pFrom
				ln.To = pTo
				ln.Color = col
				ln.Thickness = math.max(1, lineThick or thick)
				ln.Transparency = math.clamp(alpha or 0.92, 0.1, 1)
				ln.Visible = true
			end
		end

		local function pushDot(pos2D, radPx, alpha)
			dotIdx += 1
			local dtDot = xhairDots[dotIdx]
			if dtDot then
				dtDot.Position = pos2D
				dtDot.Radius = math.max(1.2, radPx)
				dtDot.Color = col
				dtDot.Transparency = math.clamp(alpha or 0.95, 0.1, 1)
				dtDot.Visible = true
			end
		end

		if spec.hasCenterDot then
			pushDot(Vector2.new(cx, cy), spec.centerRadius * scale, 0.96)
		end

		if xhairOuterCircle then
			if spec.hasOuterRing then
				xhairOuterCircle.Position = Vector2.new(cx, cy)
				xhairOuterCircle.Radius = math.max(4, spec.outerRadius * scale * pulseMult + smoothSpreadPx * 0.75)
				xhairOuterCircle.Color = col
				xhairOuterCircle.Thickness = math.max(1, thick * 0.85)
				xhairOuterCircle.Transparency = 0.85
				xhairOuterCircle.Visible = true
			else
				xhairOuterCircle.Visible = false
			end
		end

		if xhairInnerCircle then
			if spec.hasInnerRing then
				xhairInnerCircle.Position = Vector2.new(cx, cy)
				xhairInnerCircle.Radius = math.max(3, spec.innerRadius * scale + smoothSpreadPx * 0.35)
				xhairInnerCircle.Color = col:Lerp(Color3.fromRGB(255, 255, 255), 0.25)
				xhairInnerCircle.Thickness = math.max(1, thick * 0.75)
				xhairInnerCircle.Transparency = 0.8
				xhairInnerCircle.Visible = true
			else
				xhairInnerCircle.Visible = false
			end
		end

		if spec.archetype == "Diamond Frame" then
			local pts = {}
			for i = 0, 3 do
				local a = rot + (i * math.pi * 0.5)
				local r = (gap + len * 0.75)
				pts[i + 1] = Vector2.new(cx + math.cos(a) * r, cy + math.sin(a) * r)
			end
			for i = 1, 4 do
				local nxt = (i % 4) + 1
				pushLine(pts[i], pts[nxt], thick, 0.92)
			end
		elseif spec.archetype == "Tactical Brackets" then
			for i = 0, 3 do
				local a = rot + (i * math.pi * 0.5)
				local rOuter = gap + len
				local midPt = Vector2.new(cx + math.cos(a) * rOuter, cy + math.sin(a) * rOuter)
				local perpX = -math.sin(a) * (len * 0.55)
				local perpY = math.cos(a) * (len * 0.55)
				pushLine(Vector2.new(midPt.X - perpX, midPt.Y - perpY), Vector2.new(midPt.X + perpX, midPt.Y + perpY), thick, 0.92)
				pushLine(Vector2.new(cx + math.cos(a) * gap, cy + math.sin(a) * gap), midPt, math.max(1, thick * 0.75), 0.7)
			end
		elseif spec.archetype == "Orbit Pulse" then
			local count = math.min(spec.rayCount, MAX_XHAIR_DOTS - dotIdx)
			local orbitR = gap + len * 0.65
			for i = 0, count - 1 do
				local a = rot + (i * (math.pi * 2 / math.max(1, count)))
				pushDot(Vector2.new(cx + math.cos(a) * orbitR, cy + math.sin(a) * orbitR), math.max(2, thick * 1.4), 0.92)
			end
		elseif spec.archetype ~= "Precision Dot" and spec.archetype ~= "Halo Ring" and spec.archetype ~= "Dual Ring" then
			local count = math.min(spec.rayCount, MAX_XHAIR_LINES)
			for i = 0, count - 1 do
				local a = rot + (i * (math.pi * 2 / math.max(1, count)))
				local dx, dy = math.cos(a), math.sin(a)
				local pStart = Vector2.new(cx + dx * gap, cy + dy * gap)
				local pEnd = Vector2.new(cx + dx * (gap + len), cy + dy * (gap + len))
				pushLine(pStart, pEnd, thick, 0.94)

				if spec.hasTicks and lineIdx < MAX_XHAIR_LINES then
					local tickR = gap + len * 0.72
					local tx, ty = cx + dx * tickR, cy + dy * tickR
					local px, py = -dy * (len * 0.35), dx * (len * 0.35)
					pushLine(Vector2.new(tx - px, ty - py), Vector2.new(tx + px, ty + py), math.max(1, thick * 0.75), 0.75)
				end
			end
		end

		for i = lineIdx + 1, MAX_XHAIR_LINES do
			if xhairLines[i] then xhairLines[i].Visible = false end
		end
		for i = dotIdx + 1, MAX_XHAIR_DOTS do
			if xhairDots[i] then xhairDots[i].Visible = false end
		end
	end

	-- ================= CONFIG SAVE / LOAD HELPERS =================
	local function serializeConfig()
		local snap = {}
		for k, v in pairs(Config) do
			if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
				snap[k] = v
			end
		end
		return snap
	end

	local function ensureConfigFolder()
		pcall(function()
			if type(makefolder) == "function" then
				if type(isfolder) == "function" then
					if not isfolder(CONFIG_DIR) then
						makefolder(CONFIG_DIR)
					end
				else
					makefolder(CONFIG_DIR)
				end
			end
		end)
	end

	local function loadAllSavedConfigsFromDisk()
		ensureConfigFolder()
		local memStore = genv["Nexxwarre_MemoryConfigs"]
		if type(memStore) == "table" then
			for k, v in pairs(memStore) do
				if type(v) == "table" then
					SavedConfigsMap[k] = v
				end
			end
		end

		pcall(function()
			if type(listfiles) == "function" and type(readfile) == "function" then
				local files = listfiles(CONFIG_DIR)
				for _, path in ipairs(files or {}) do
					local fileName = tostring(path):match("([^/\\]+)$") or tostring(path)
					if fileName:sub(-5) == ".json" then
						local cfgName = sanitizeConfigName(fileName:sub(1, -6))
						local okDec, decoded = pcall(function()
							return HttpService:JSONDecode(readfile(path))
						end)
						if okDec and type(decoded) == "table" then
							SavedConfigsMap[cfgName] = decoded
						end
					end
				end
			end
		end)
	end

	local function saveConfigByName(rawName)
		local name = sanitizeConfigName(rawName)
		local snapshot = serializeConfig()
		SavedConfigsMap[name] = snapshot
		SelectedConfigName = name

		genv["Nexxwarre_MemoryConfigs"] = genv["Nexxwarre_MemoryConfigs"] or {}
		genv["Nexxwarre_MemoryConfigs"][name] = snapshot

		ensureConfigFolder()
		pcall(function()
			if type(writefile) == "function" then
				local fullPath = CONFIG_DIR .. "/" .. name .. ".json"
				writefile(fullPath, HttpService:JSONEncode(snapshot))
			end
		end)

		if RefreshConfigBarFn then
			RefreshConfigBarFn()
		end
		return name
	end

	local function applyConfigSnapshot(tbl)
		if type(tbl) ~= "table" then return false end
		for k, v in pairs(tbl) do
			if Config[k] ~= nil and type(v) == type(Config[k]) then
				Config[k] = v
			end
		end
		return true
	end

	loadAllSavedConfigsFromDisk()

	-- ================= ROUND WIN SOUND & EDGE EFFECT =================
	local function playRoundWinSound()
		if not Config.WinSoundEnabled then return end
		pcall(function()
			local parentTarget = (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")) or SoundService
			local snd = Instance.new("Sound")
			snd.Name = "NexxwarreWinSound_" .. tostring(math.random(1000, 9999))
			snd.SoundId = WIN_SOUND_ID
			snd.Volume = 1
			snd.Looped = false
			snd.Parent = parentTarget

			if not snd.IsLoaded then
				pcall(function()
					snd.Loaded:Wait()
				end)
			end

			snd:Play()
			pcall(function()
				SoundService:PlayLocalSound(snd)
			end)

			task.delay(5, function()
				pcall(function()
					snd:Stop()
					snd:Destroy()
				end)
			end)
		end)
	end

	local function triggerRoundWinFeedback(forceBypassCooldown)
		local now = os.clock()
		if not forceBypassCooldown and (now - lastWinTriggerTime < 0.85) then
			return
		end
		lastWinTriggerTime = now

		if Config.WinEdgeEffectEnabled then
			local durSec = math.clamp(Config.WinEdgeDuration / 100, 0.5, 2.5)
			winEffectTimer = durSec
		end

		triggerHitFlash(false)
		playRoundWinSound()
	end

	local winEdgeTop = safeDrawing("Line", { Thickness = 8, Transparency = 0, Visible = false })
	local winEdgeBot = safeDrawing("Line", { Thickness = 8, Transparency = 0, Visible = false })
	local winEdgeLeft = safeDrawing("Line", { Thickness = 8, Transparency = 0, Visible = false })
	local winEdgeRight = safeDrawing("Line", { Thickness = 8, Transparency = 0, Visible = false })
	local winEdgeInnerTop = safeDrawing("Line", { Thickness = 3.5, Transparency = 0, Visible = false })
	local winEdgeInnerBot = safeDrawing("Line", { Thickness = 3.5, Transparency = 0, Visible = false })
	local winEdgeInnerLeft = safeDrawing("Line", { Thickness = 3.5, Transparency = 0, Visible = false })
	local winEdgeInnerRight = safeDrawing("Line", { Thickness = 3.5, Transparency = 0, Visible = false })

	local function hideWinEdgeLines()
		if winEdgeTop then winEdgeTop.Visible = false end
		if winEdgeBot then winEdgeBot.Visible = false end
		if winEdgeLeft then winEdgeLeft.Visible = false end
		if winEdgeRight then winEdgeRight.Visible = false end
		if winEdgeInnerTop then winEdgeInnerTop.Visible = false end
		if winEdgeInnerBot then winEdgeInnerBot.Visible = false end
		if winEdgeInnerLeft then winEdgeInnerLeft.Visible = false end
		if winEdgeInnerRight then winEdgeInnerRight.Visible = false end
	end

	local function updateWinEdgeEffect(dt)
		Camera = workspace.CurrentCamera
		if not Camera or not Config.WinEdgeEffectEnabled or winEffectTimer <= 0 then
			winEffectTimer = 0
			hideWinEdgeLines()
			return
		end

		winEffectTimer = math.max(0, winEffectTimer - dt)
		local durSec = math.max(0.25, math.clamp(Config.WinEdgeDuration / 100, 0.5, 2.5))
		local progress = 1 - (winEffectTimer / durSec)

		local envelope
		if progress < 0.22 then
			envelope = progress / 0.22
		else
			envelope = 1 - ((progress - 0.22) / 0.78)
		end
		envelope = math.clamp(envelope, 0, 1)

		if envelope <= 0.02 then
			hideWinEdgeLines()
			return
		end

		local vp = Camera.ViewportSize
		local edgeColor = getNamedColor(Config.WinEdgeColorName)
		local innerColor = edgeColor:Lerp(Color3.fromRGB(255, 255, 255), 0.35)
		local outerPad, innerPad = 4, 13
		local w, h = vp.X, vp.Y
		local outerAlpha = math.clamp(envelope * 0.94, 0, 0.94)
		local innerAlpha = math.clamp(envelope * 0.62, 0, 0.62)

		if winEdgeTop then winEdgeTop.Color = edgeColor; winEdgeTop.Transparency = outerAlpha; winEdgeTop.From = Vector2.new(outerPad, outerPad); winEdgeTop.To = Vector2.new(w - outerPad, outerPad); winEdgeTop.Visible = true end
		if winEdgeBot then winEdgeBot.Color = edgeColor; winEdgeBot.Transparency = outerAlpha; winEdgeBot.From = Vector2.new(outerPad, h - outerPad); winEdgeBot.To = Vector2.new(w - outerPad, h - outerPad); winEdgeBot.Visible = true end
		if winEdgeLeft then winEdgeLeft.Color = edgeColor; winEdgeLeft.Transparency = outerAlpha; winEdgeLeft.From = Vector2.new(outerPad, outerPad); winEdgeLeft.To = Vector2.new(outerPad, h - outerPad); winEdgeLeft.Visible = true end
		if winEdgeRight then winEdgeRight.Color = edgeColor; winEdgeRight.Transparency = outerAlpha; winEdgeRight.From = Vector2.new(w - outerPad, outerPad); winEdgeRight.To = Vector2.new(w - outerPad, h - outerPad); winEdgeRight.Visible = true end

		if winEdgeInnerTop then winEdgeInnerTop.Color = innerColor; winEdgeInnerTop.Transparency = innerAlpha; winEdgeInnerTop.From = Vector2.new(innerPad, innerPad); winEdgeInnerTop.To = Vector2.new(w - innerPad, innerPad); winEdgeInnerTop.Visible = true end
		if winEdgeInnerBot then winEdgeInnerBot.Color = innerColor; winEdgeInnerBot.Transparency = innerAlpha; winEdgeInnerBot.From = Vector2.new(innerPad, h - innerPad); winEdgeInnerBot.To = Vector2.new(w - innerPad, h - innerPad); winEdgeInnerBot.Visible = true end
		if winEdgeInnerLeft then winEdgeInnerLeft.Color = innerColor; winEdgeInnerLeft.Transparency = innerAlpha; winEdgeInnerLeft.From = Vector2.new(innerPad, innerPad); winEdgeInnerLeft.To = Vector2.new(innerPad, h - innerPad); winEdgeInnerLeft.Visible = true end
		if winEdgeInnerRight then winEdgeInnerRight.Color = innerColor; winEdgeInnerRight.Transparency = innerAlpha; winEdgeInnerRight.From = Vector2.new(w - innerPad, innerPad); winEdgeInnerRight.To = Vector2.new(w - innerPad, h - innerPad); winEdgeInnerRight.Visible = true end
	end

	local function isScoreOrWinName(nameStr)
		local s = tostring(nameStr or ""):lower()
		return s:find("win") or s:find("point") or s:find("score") or s:find("goal")
			or s:find("round") or s:find("won") or s:find("team") or s:find("побед")
			or s:find("очк") or s:find("счет") or s:find("счёт")
	end

	local function hookValueInstance(obj)
		if not obj or watchedValues[obj] then return end
		if not (obj:IsA("IntValue") or obj:IsA("NumberValue")) then return end
		if not isScoreOrWinName(obj.Name) then return end

		watchedValues[obj] = tonumber(obj.Value) or 0
		local conn = obj:GetPropertyChangedSignal("Value"):Connect(function()
			local cur = tonumber(obj.Value)
			local prev = watchedValues[obj]
			watchedValues[obj] = cur
			if cur ~= nil and prev ~= nil and cur > prev then
				if (os.clock() - lastThrowTime) <= 15.0 then
					lastThrowTime = 0
					lastThrownBallPos = nil
					lastBallCrossedFarZone = false
					triggerRoundWinFeedback(false)
				end
			end
		end)
		table.insert(Connections, conn)
	end

	local function scanAndHookContainer(container)
		if not container then return end
		pcall(function()
			for _, obj in ipairs(container:GetDescendants()) do
				hookValueInstance(obj)
			end
			local addedConn = container.DescendantAdded:Connect(function(desc)
				hookValueInstance(desc)
			end)
			table.insert(Connections, addedConn)
		end)
	end

	scanAndHookContainer(LocalPlayer)
	scanAndHookContainer(workspace)
	scanAndHookContainer(ReplicatedStorage)
	scanAndHookContainer(Teams)

	local function registerPlayerBallContactOrThrow(ballPos, ballVel)
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local dist = (ballPos - hrp.Position).Magnitude
		local spd = ballVel.Magnitude

		if dist <= 26 and spd >= 4 then
			lastThrowTime = os.clock()
			lastThrownBallPos = ballPos
			lastBallCrossedFarZone = false
			triggerHitFlash(false)
		end

		if lastThrownBallPos and (os.clock() - lastThrowTime <= 15.0) then
			local movedFromThrow = (ballPos - lastThrownBallPos).Magnitude
			local movedFromPlayer = (ballPos - hrp.Position).Magnitude
			if movedFromThrow >= 10 and movedFromPlayer >= 10 then
				lastBallCrossedFarZone = true
			end
		end
	end

	local function checkGuiScoreChangeAfterThrow()
		if (os.clock() - lastThrowTime) > 15.0 then return end
		local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
		if not pg then return end

		for _, desc in ipairs(pg:GetDescendants()) do
			if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Visible then
				local txt = tostring(desc.Text or "")
				local prev = lastGuiTextMap[desc]
				lastGuiTextMap[desc] = txt

				if prev ~= nil and prev ~= txt then
					local low = txt:lower()
					if low:find("won") or low:find("point") or low:find("score") or low:find("round")
						or low:find("выигр") or low:find("побед") or low:find("очк") or low:find("раунд") then
						lastThrowTime = 0
						lastThrownBallPos = nil
						lastBallCrossedFarZone = false
						triggerRoundWinFeedback(false)
						return
					end
				end
			end
		end
	end

	-- ================= WORLD VISUALS + CUSTOM SKY + MULTI PARTICLES =================
	local function removeCustomSky()
		pcall(function()
			if CustomSkyRef then
				CustomSkyRef:Destroy()
				CustomSkyRef = nil
			end
		end)
	end

	local function updateCustomSky()
		if not Config.CustomSkyEnabled then
			removeCustomSky()
			return
		end
		if not CustomSkyRef or not CustomSkyRef.Parent then
			local sky = Instance.new("Sky")
			sky.Name = "NexxwarreCustomSky"
			sky.Parent = Lighting
			CustomSkyRef = sky
		end
		local tint = getNamedColor(Config.CustomSkyColorName)
		pcall(function()
			CustomSkyRef.CelestialBodiesShown = not not Config.CustomSkyCelestial
			CustomSkyRef.StarCount = Config.CustomSkyCelestial and 3000 or 0
			CustomSkyRef.SunAngularSize = Config.CustomSkyCelestial and 14 or 0
			CustomSkyRef.MoonAngularSize = Config.CustomSkyCelestial and 12 or 0
			CustomSkyRef.SkyColor = tint
			CustomSkyRef.SunColor = tint:Lerp(Color3.fromRGB(255, 255, 255), 0.45)
			CustomSkyRef.MoonColor = tint:Lerp(Color3.fromRGB(220, 235, 255), 0.35)
		end)
	end

	local function ensureWorldMultiParticles()
		if not WorldMultiPart or not WorldMultiPart.Parent then
			local part = Instance.new("Part")
			part.Name = "NexxwarreMultiParticles"
			part.Size = Vector3.new(44, 16, 44)
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.CastShadow = false
			part.Transparency = 1
			part.Parent = workspace
			WorldMultiPart = part

			local p1 = Instance.new("ParticleEmitter")
			p1.Name = "PrimaryEmitter"
			p1.Texture = "rbxassetid://241685484"
			p1.Enabled = false
			p1.Parent = part
			WorldMultiPrimary = p1

			local p2 = Instance.new("ParticleEmitter")
			p2.Name = "SecondaryEmitter"
			p2.Texture = "rbxassetid://241685484"
			p2.Enabled = false
			p2.Parent = part
			WorldMultiSecondary = p2
		end
	end

	local function configureEmitterByStyle(emitter, styleName, col, rateVal, sizeVal, isSecondary)
		if not emitter then return end
		local sz = math.clamp((tonumber(sizeVal) or 35) / 100, 0.08, 0.95)
		local rt = math.clamp(tonumber(rateVal) or 85, 5, 320)
		if isSecondary then
			rt = math.max(6, math.floor(rt * 0.6))
			sz = sz * 0.72
		end

		emitter.Color = ColorSequence.new(col, col:Lerp(Color3.fromRGB(255, 255, 255), 0.35))
		emitter.Rate = rt

		if styleName == "Sparks" then
			emitter.LightEmission = 0.95
			emitter.LightInfluence = 0.05
			emitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, sz * 0.55),
				NumberSequenceKeypoint.new(0.5, sz * 0.85),
				NumberSequenceKeypoint.new(1, 0.02)
			})
			emitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.05),
				NumberSequenceKeypoint.new(0.75, 0.45),
				NumberSequenceKeypoint.new(1, 1)
			})
			emitter.Lifetime = NumberRange.new(0.8, 1.8)
			emitter.Speed = NumberRange.new(7, 17)
			emitter.SpreadAngle = Vector2.new(180, 180)
			emitter.Acceleration = Vector3.new(0, -6.5, 0)
			emitter.RotSpeed = NumberRange.new(-160, 160)
		elseif styleName == "Snow" then
			emitter.LightEmission = 0.25
			emitter.LightInfluence = 0.75
			emitter.Size = NumberSequence.new(sz * 0.95)
			emitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.85, 0.15),
				NumberSequenceKeypoint.new(1, 1)
			})
			emitter.Lifetime = NumberRange.new(4.0, 6.5)
			emitter.Speed = NumberRange.new(5, 11)
			emitter.SpreadAngle = Vector2.new(25, 25)
			emitter.Acceleration = Vector3.new(1.8, -5.0, 1.4)
			emitter.RotSpeed = NumberRange.new(-55, 55)
		elseif styleName == "Dust" then
			emitter.LightEmission = 0.15
			emitter.LightInfluence = 0.85
			emitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, sz * 0.4),
				NumberSequenceKeypoint.new(0.5, sz * 0.75),
				NumberSequenceKeypoint.new(1, sz * 0.2)
			})
			emitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.85),
				NumberSequenceKeypoint.new(0.4, 0.42),
				NumberSequenceKeypoint.new(1, 1)
			})
			emitter.Lifetime = NumberRange.new(3.5, 6.0)
			emitter.Speed = NumberRange.new(0.6, 2.2)
			emitter.SpreadAngle = Vector2.new(180, 180)
			emitter.Acceleration = Vector3.new(0.4, 0.35, -0.4)
			emitter.RotSpeed = NumberRange.new(-20, 20)
		else
			emitter.LightEmission = 0.85
			emitter.LightInfluence = 0.15
			emitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, sz * 0.35),
				NumberSequenceKeypoint.new(0.5, sz * 0.8),
				NumberSequenceKeypoint.new(1, 0.05)
			})
			emitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(0.45, 0.18),
				NumberSequenceKeypoint.new(1, 1)
			})
			emitter.Lifetime = NumberRange.new(2.0, 4.0)
			emitter.Speed = NumberRange.new(1.5, 4.2)
			emitter.SpreadAngle = Vector2.new(180, 180)
			emitter.Acceleration = Vector3.new(0, 1.1, 0)
			emitter.RotSpeed = NumberRange.new(-45, 45)
		end
	end

	local function updateWorldMultiParticles()
		if not Config.WorldParticlesEnabled then
			if WorldMultiPrimary then WorldMultiPrimary.Enabled = false end
			if WorldMultiSecondary then WorldMultiSecondary.Enabled = false end
			return
		end
		ensureWorldMultiParticles()
		Camera = workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local anchor = (hrp and hrp.Position) or (Camera and Camera.CFrame.Position)
		if anchor and WorldMultiPart then
			WorldMultiPart.CFrame = CFrame.new(anchor.X, anchor.Y + 2, anchor.Z)
		end

		local mode = tostring(Config.WorldParticleMode or "Motes")
		local col = getNamedColor(Config.WorldParticlesColorName)

		if mode == "Combo" then
			configureEmitterByStyle(WorldMultiPrimary, "Sparks", col, Config.WorldParticlesRate, Config.WorldParticlesSize, false)
			configureEmitterByStyle(WorldMultiSecondary, "Motes", col:Lerp(Color3.fromRGB(255, 255, 255), 0.3), Config.WorldParticlesRate, Config.WorldParticlesSize, true)
			if WorldMultiPrimary then WorldMultiPrimary.Enabled = true end
			if WorldMultiSecondary then WorldMultiSecondary.Enabled = true end
		else
			configureEmitterByStyle(WorldMultiPrimary, mode, col, Config.WorldParticlesRate, Config.WorldParticlesSize, false)
			if WorldMultiPrimary then WorldMultiPrimary.Enabled = true end
			if WorldMultiSecondary then WorldMultiSecondary.Enabled = false end
		end
	end

	local function ensureWorldSnow()
		if not WorldSnowPart or not WorldSnowPart.Parent then
			local part = Instance.new("Part")
			part.Name = "NexxwarreSnowEmitter"
			part.Size = Vector3.new(170, 2, 170)
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.CastShadow = false
			part.Transparency = 1
			part.Parent = workspace
			WorldSnowPart = part

			local emitter = Instance.new("ParticleEmitter")
			emitter.Name = "SnowFlakes3D"
			emitter.Texture = "rbxassetid://241685484"
			emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			emitter.LightEmission = 0.35
			emitter.LightInfluence = 0.65
			emitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.25),
				NumberSequenceKeypoint.new(0.8, 0.15),
				NumberSequenceKeypoint.new(1, 1)
			})
			emitter.Size = NumberSequence.new(0.35)
			emitter.Lifetime = NumberRange.new(5.5, 8.5)
			emitter.Rate = Config.WorldSnowRate
			emitter.Speed = NumberRange.new(10, 18)
			emitter.SpreadAngle = Vector2.new(18, 18)
			emitter.Acceleration = Vector3.new(2.2, -3.5, 1.8)
			emitter.Rotation = NumberRange.new(0, 360)
			emitter.RotSpeed = NumberRange.new(-45, 45)
			emitter.EmissionDirection = Enum.NormalId.Bottom
			emitter.Enabled = Config.WorldSnowEnabled
			emitter.Parent = part
			WorldSnowEmitter = emitter
		end
	end

	local function updateWorldSnow()
		if not Config.WorldSnowEnabled then
			if WorldSnowEmitter then WorldSnowEmitter.Enabled = false end
			return
		end
		ensureWorldSnow()
		if WorldSnowEmitter then
			WorldSnowEmitter.Enabled = true
			WorldSnowEmitter.Rate = Config.WorldSnowRate
			WorldSnowEmitter.Size = NumberSequence.new(math.clamp(Config.WorldSnowSize / 100, 0.12, 0.9))
		end
		Camera = workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local anchorPos = (hrp and hrp.Position) or (Camera and Camera.CFrame.Position)
		if anchorPos and WorldSnowPart then
			WorldSnowPart.CFrame = CFrame.new(anchorPos.X, anchorPos.Y + 46, anchorPos.Z)
		end
	end

	local function ensureWorldMotes()
		if not WorldMotesPart or not WorldMotesPart.Parent then
			local part = Instance.new("Part")
			part.Name = "NexxwarreMotesEmitter"
			part.Size = Vector3.new(36, 12, 36)
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.CastShadow = false
			part.Transparency = 1
			part.Parent = workspace
			WorldMotesPart = part

			local emitter = Instance.new("ParticleEmitter")
			emitter.Name = "AmbientMotes3D"
			emitter.Texture = "rbxassetid://241685484"
			emitter.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 250, 190)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 225, 255))
			})
			emitter.LightEmission = 0.85
			emitter.LightInfluence = 0.15
			emitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.85),
				NumberSequenceKeypoint.new(0.45, 0.2),
				NumberSequenceKeypoint.new(1, 1)
			})
			emitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.08),
				NumberSequenceKeypoint.new(0.5, 0.22),
				NumberSequenceKeypoint.new(1, 0.04)
			})
			emitter.Lifetime = NumberRange.new(2.2, 4.2)
			emitter.Rate = Config.WorldMotesRate
			emitter.Speed = NumberRange.new(1.2, 3.4)
			emitter.SpreadAngle = Vector2.new(180, 180)
			emitter.Acceleration = Vector3.new(0, 0.75, 0)
			emitter.Enabled = Config.WorldMotesEnabled
			emitter.Parent = part
			WorldMotesEmitter = emitter
		end
	end

	local function updateWorldMotes()
		if not Config.WorldMotesEnabled then
			if WorldMotesEmitter then WorldMotesEmitter.Enabled = false end
			return
		end
		ensureWorldMotes()
		if WorldMotesEmitter then
			WorldMotesEmitter.Enabled = true
			WorldMotesEmitter.Rate = Config.WorldMotesRate
		end
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and WorldMotesPart then
			WorldMotesPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 2, hrp.Position.Z)
		end
	end

	local function restoreSkyMood()
		pcall(function()
			Lighting.ClockTime = OriginalLighting.ClockTime
			Lighting.Brightness = Config.LocalFullBrightEnabled and 2.5 or OriginalLighting.Brightness
			if SkyMoodCCRef then
				SkyMoodCCRef.Enabled = false
				SkyMoodCCRef.TintColor = Color3.fromRGB(255, 255, 255)
			end
		end)
	end

	local function updateSkyMood()
		if Config.SkyMoodName == "Original" then
			restoreSkyMood()
			return
		end
		local mood = getSkyMood(Config.SkyMoodName)
		if not SkyMoodCCRef or not SkyMoodCCRef.Parent then
			local cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "NexxwarreSkyMoodCC"
			cc.Parent = Lighting
			SkyMoodCCRef = cc
		end
		pcall(function()
			Lighting.ClockTime = mood.ClockTime
			Lighting.Brightness = Config.LocalFullBrightEnabled and math.max(mood.Brightness, 2.5) or mood.Brightness
			SkyMoodCCRef.Enabled = true
			SkyMoodCCRef.TintColor = mood.Tint
			SkyMoodCCRef.Saturation = 0.14
		end)
	end

	local function restoreFog()
		pcall(function()
			Lighting.FogColor = OriginalLighting.FogColor
			Lighting.FogStart = OriginalLighting.FogStart
			Lighting.FogEnd = OriginalLighting.FogEnd
			if OriginalAtmosphere and OriginalAtmosphere.Instance and OriginalAtmosphere.Instance.Parent then
				local atm = OriginalAtmosphere.Instance
				atm.Density = OriginalAtmosphere.Density
				atm.Offset = OriginalAtmosphere.Offset
				atm.Color = OriginalAtmosphere.Color
				atm.Decay = OriginalAtmosphere.Decay
				atm.Glare = OriginalAtmosphere.Glare
				atm.Haze = OriginalAtmosphere.Haze
			end
		end)
	end

	local function updateCustomFog()
		if not Config.FogEnabled then
			restoreFog()
			return
		end
		local fogCol = getNamedColor(Config.FogColorName)
		local fStart = math.clamp(Config.FogStart, 0, 500)
		local fEnd = math.max(fStart + 15, math.clamp(Config.FogEnd, 20, 1200))
		Lighting.FogColor = fogCol
		Lighting.FogStart = fStart
		Lighting.FogEnd = fEnd
		local atm = Lighting:FindFirstChildOfClass("Atmosphere")
		if atm then
			local density = math.clamp(1 - (fEnd / 1250), 0.18, 0.85)
			atm.Density = density
			atm.Color = fogCol
			atm.Decay = fogCol
			atm.Haze = math.clamp(density * 2.4, 0.4, 2.5)
		end
	end

	local function restoreAtmosphere()
		pcall(function()
			Lighting.Ambient = Config.LocalFullBrightEnabled and Color3.fromRGB(220, 220, 220) or OriginalLighting.Ambient
			Lighting.OutdoorAmbient = Config.LocalFullBrightEnabled and Color3.fromRGB(220, 220, 220) or OriginalLighting.OutdoorAmbient
			Lighting.ColorShift_Top = OriginalLighting.ColorShift_Top
			Lighting.ColorShift_Bottom = OriginalLighting.ColorShift_Bottom
			if AmbientCCRef then
				AmbientCCRef.TintColor = Color3.fromRGB(255, 255, 255)
				AmbientCCRef.Saturation = 0
				AmbientCCRef.Contrast = 0
			end
		end)
	end

	local function updateMapAtmosphere()
		if not Config.AtmosphereEnabled then
			restoreAtmosphere()
			return
		end
		if not AmbientCCRef or not AmbientCCRef.Parent then
			local cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "NexxwarreAtmCC"
			cc.Parent = Lighting
			AmbientCCRef = cc
		end
		local col = getNamedColor(Config.AtmosphereColorName)
		local alpha = math.clamp(Config.AtmosphereIntensity, 10, 100) / 100
		Lighting.Ambient = OriginalLighting.Ambient:Lerp(col, alpha * 0.65)
		Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient:Lerp(col, alpha * 0.75)
		Lighting.ColorShift_Top = col
		Lighting.ColorShift_Bottom = col:Lerp(Color3.fromRGB(15, 18, 26), 0.5)
		AmbientCCRef.TintColor = Color3.fromRGB(255, 255, 255):Lerp(col, alpha * 0.35)
		AmbientCCRef.Saturation = alpha * 0.22
		AmbientCCRef.Contrast = alpha * 0.1
	end

	local function updateBloom()
		if not Config.BloomEnabled then
			if BloomRef then BloomRef.Enabled = false end
			return
		end
		if not BloomRef or not BloomRef.Parent then
			local bl = Instance.new("BloomEffect")
			bl.Name = "NexxwarreBloom"
			bl.Threshold = 1.15
			bl.Size = 24
			bl.Parent = Lighting
			BloomRef = bl
		end
		BloomRef.Enabled = true
		BloomRef.Intensity = math.clamp(Config.BloomIntensity / 100, 0.05, 1.2)
	end

	local function updateSunRays()
		if not Config.SunRaysEnabled then
			if SunRaysRef then SunRaysRef.Enabled = false end
			return
		end
		if not SunRaysRef or not SunRaysRef.Parent then
			local sr = Instance.new("SunRaysEffect")
			sr.Name = "NexxwarreSunRays"
			sr.Spread = 0.45
			sr.Parent = Lighting
			SunRaysRef = sr
		end
		SunRaysRef.Enabled = true
		SunRaysRef.Intensity = math.clamp(Config.SunRaysIntensity / 100, 0.05, 0.85)
	end

	local function applyFullBrightState()
		pcall(function()
			if Config.LocalFullBrightEnabled then
				Lighting.Brightness = math.max(Lighting.Brightness, 2.5)
				Lighting.Ambient = Color3.fromRGB(220, 220, 220)
				Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
			else
				if not Config.AtmosphereEnabled then
					Lighting.Ambient = OriginalLighting.Ambient
					Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
				end
				if Config.SkyMoodName == "Original" then
					Lighting.Brightness = OriginalLighting.Brightness
				end
			end
		end)
	end

	local function applyGravityState()
		pcall(function()
			if Config.LocalLowGravityEnabled then
				workspace.Gravity = math.clamp(tonumber(Config.LocalGravityValue) or 75, 15, 196.2)
			else
				workspace.Gravity = OriginalGravity
			end
		end)
	end

	local function dashForward()
		pcall(function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local dist = math.clamp(tonumber(Config.LocalDashDistance) or 18, 6, 45)
				local look = hrp.CFrame.LookVector
				local flatDir = Vector3.new(look.X, 0, look.Z)
				if flatDir.Magnitude > 0.01 then
					hrp.CFrame = hrp.CFrame + flatDir.Unit * dist
				end
			end
		end)
	end

	-- ================= STRETCHED RESOLUTION & CAMERA TILT =================
	pcall(function()
		RunService:UnbindFromRenderStep("NexxwarreStretchBind")
	end)

	RunService:BindToRenderStep("NexxwarreStretchBind", Enum.RenderPriority.Camera.Value + 1, function()
		local cam = workspace.CurrentCamera
		if not cam then return end

		if Config.StretchEnabled then
			local verticalScale = math.clamp(Config.StretchRatio / 100, 0.52, 1.0)
			if verticalScale < 0.995 then
				cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, verticalScale, 0, 0, 0, 1)
			end
		end

		if Config.CameraTiltEnabled then
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local maxRoll = math.clamp(Config.CameraTiltAngle or 4, 1, 15)
			local rollDeg = 0
			if hrp then
				local rightVel = hrp.CFrame.RightVector:Dot(hrp.AssemblyLinearVelocity)
				rollDeg = math.clamp(-rightVel / 18, -1, 1) * maxRoll
			end
			if math.abs(rollDeg) > 0.05 then
				cam.CFrame = cam.CFrame * CFrame.Angles(0, 0, math.rad(rollDeg))
			end
		end
	end)

	-- ================= BALL SYSTEM =================
	local ARC_SEGMENTS = 10
	local MAX_TRAIL_SEGMENTS = 18

	local function getVisualParent()
		local target
		pcall(function()
			target = gethui and gethui() or game:GetService("CoreGui")
			local test = Instance.new("Folder")
			test.Parent = target
			test:Destroy()
		end)
		if not target then
			target = LocalPlayer:WaitForChild("PlayerGui")
		end
		return target
	end

	local function createDoubleSidedSphere(namePrefix, parentTarget)
		local outer = Instance.new("Part")
		outer.Name = namePrefix .. "_Outer"
		outer.Shape = Enum.PartType.Ball
		outer.Material = Enum.Material.ForceField
		outer.Anchored = true
		outer.CanCollide = false
		outer.CanTouch = false
		outer.CanQuery = false
		outer.CastShadow = false
		outer.Transparency = 0.55
		outer.Parent = parentTarget

		local inner = Instance.new("Part")
		inner.Name = namePrefix .. "_Inner"
		inner.Shape = Enum.PartType.Ball
		inner.Material = Enum.Material.Neon
		inner.Anchored = true
		inner.CanCollide = false
		inner.CanTouch = false
		inner.CanQuery = false
		inner.CastShadow = false
		inner.Transparency = 0.84
		inner.Parent = parentTarget

		local hl = Instance.new("Highlight")
		hl.Name = namePrefix .. "_HL"
		hl.Adornee = outer
		hl.DepthMode = Enum.HighlightDepthMode.Occluded
		hl.FillTransparency = 0.65
		hl.OutlineTransparency = 0.05
		hl.Parent = parentTarget

		return outer, inner, hl
	end

	local function destroyDoubleSidedSphere(outer, inner, hl)
		pcall(function() if hl then hl:Destroy() end end)
		pcall(function() if inner then inner:Destroy() end end)
		pcall(function() if outer then outer:Destroy() end end)
	end

	local function createBallHitboxChams(namePrefix)
		local part = Instance.new("Part")
		part.Name = namePrefix .. "_ChamsPart"
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Transparency = 1
		part.Parent = workspace

		local hl = Instance.new("Highlight")
		hl.Name = namePrefix .. "_ChamsHL"
		hl.Adornee = part
		hl.DepthMode = Enum.HighlightDepthMode.Occluded
		hl.FillTransparency = 0.55
		hl.OutlineTransparency = 0.1
		hl.Enabled = false
		hl.Parent = getVisualParent()

		return part, hl
	end

	local function destroyBallHitboxChams(part, hl)
		pcall(function() if hl then hl:Destroy() end end)
		pcall(function() if part then part:Destroy() end end)
	end

	local function getActualBallRadius(ball, root)
		local r = 2.0
		pcall(function()
			if ball and ball:IsA("Model") then
				local ext = ball:GetExtentsSize()
				local maxAxis = math.max(ext.X, ext.Y, ext.Z)
				if maxAxis > 0.1 then
					r = maxAxis * 0.5
					return
				end
			end
			if root and root:IsA("BasePart") then
				local s = root.Size
				local maxAxis = math.max(s.X, s.Y, s.Z)
				if maxAxis > 0.1 then
					r = maxAxis * 0.5
				end
			end
		end)
		return math.clamp(r, 0.5, 40)
	end

	local function computeExactBallScreenBounds(cam, centerWorld, actualRadius, visScale)
		local rad = actualRadius * visScale
		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge
		local anyValid = false

		for sx = -1, 1, 2 do
			for sy = -1, 1, 2 do
				for sz = -1, 1, 2 do
					local cornerWorld = centerWorld + Vector3.new(sx * rad, sy * rad, sz * rad)
					local pt, on = cam:WorldToViewportPoint(cornerWorld)
					if on and pt.Z > 0 then
						anyValid = true
						if pt.X < minX then minX = pt.X end
						if pt.Y < minY then minY = pt.Y end
						if pt.X > maxX then maxX = pt.X end
						if pt.Y > maxY then maxY = pt.Y end
					end
				end
			end
		end

		local centerPt, centerOn = cam:WorldToViewportPoint(centerWorld)
		local ringPx = 0
		if centerOn and centerPt.Z > 0 then
			local edgePt = cam:WorldToViewportPoint(centerWorld + cam.CFrame.RightVector * rad)
			ringPx = math.abs(edgePt.X - centerPt.X)
		end

		if anyValid then
			return true, Vector2.new(minX, minY), Vector2.new(maxX, maxY), ringPx
		end

		if centerOn and centerPt.Z > 0 and ringPx > 0 then
			return true, Vector2.new(centerPt.X - ringPx, centerPt.Y - ringPx), Vector2.new(centerPt.X + ringPx, centerPt.Y + ringPx), ringPx
		end

		return false, nil, nil, 0
	end

	local function createArcLines()
		local segs = {}
		for i = 1, ARC_SEGMENTS do
			segs[i] = safeDrawing("Line", { Color = Color3.fromRGB(120, 245, 210), Thickness = 1.6, Transparency = 0.75, Visible = false })
		end
		return segs
	end

	local function createTrailLines()
		local segs = {}
		for i = 1, MAX_TRAIL_SEGMENTS do
			segs[i] = safeDrawing("Line", { Thickness = 2, Transparency = 0.7, Visible = false })
		end
		return segs
	end

	local function createBall2DBoxLines()
		local lines = {}
		for i = 1, 4 do
			lines[i] = safeDrawing("Line", { Transparency = 0.92, Visible = false })
		end
		return lines
	end

	local function updateBallBoxSize(box, radius)
		if box and box.Parent then
			local diam = radius * 2
			box.Size = Vector3.new(diam, diam, diam)
		end
	end

	local function update3DHexSphereForBall(d, centerPos)
		if not d or not d.sphereOuter or not d.sphereInner then return end
		local show = Config.BallHitbox3DEnabled and (centerPos ~= nil)
		if not show then
			d.sphereOuter.CFrame = CFrame.new(0, -5000, 0)
			d.sphereInner.CFrame = CFrame.new(0, -5000, 0)
			if d.sphereHL then d.sphereHL.Enabled = false end
			return
		end

		local diam = math.max(1, Config.BallRadius * 2)
		local col = getNamedColor(Config.BallHitbox3DColorName)
		local baseTransp = math.clamp(Config.BallHitbox3DTransp / 100, 0.1, 0.92)
		local spinAngle = elapsedClock * 1.1

		d.sphereOuter.Size = Vector3.new(diam, diam, diam)
		d.sphereOuter.Color = col
		d.sphereOuter.Transparency = baseTransp
		d.sphereOuter.CFrame = CFrame.new(centerPos) * CFrame.Angles(0, spinAngle, 0)

		d.sphereInner.Size = Vector3.new(diam * 0.96, diam * 0.96, diam * 0.96)
		d.sphereInner.Color = col:Lerp(Color3.fromRGB(255, 255, 255), 0.25)
		d.sphereInner.Transparency = math.clamp(baseTransp + 0.24, 0.25, 0.96)
		d.sphereInner.CFrame = CFrame.new(centerPos) * CFrame.Angles(spinAngle * 0.6, -spinAngle, 0)

		if d.sphereHL then
			d.sphereHL.Enabled = true
			d.sphereHL.FillColor = col
			d.sphereHL.OutlineColor = col:Lerp(Color3.fromRGB(255, 255, 255), 0.35)
			d.sphereHL.FillTransparency = math.clamp(baseTransp + 0.15, 0.2, 0.95)
			d.sphereHL.OutlineTransparency = 0.08
		end
	end

	local function updateHitboxChamsForBall(d, centerPos)
		if not d or not d.chamsPart or not d.chamsHL then return end
		local show = Config.BallHitboxChamsEnabled and (centerPos ~= nil)
		if not show then
			d.chamsPart.CFrame = CFrame.new(0, -5000, 0)
			d.chamsHL.Enabled = false
			return
		end

		local diam = math.max(1, Config.BallRadius * 2)
		local fillCol = getNamedColor(Config.BallHitboxChamsFillColorName)
		local outCol = getNamedColor(Config.BallHitboxChamsOutlineColorName)
		local baseFillTransp = math.clamp(Config.BallHitboxChamsFillTransp / 100, 0.05, 0.95)
		local outTransp = math.clamp(Config.BallHitboxChamsOutlineTransp / 100, 0, 0.95)
		local depthMode = Config.BallHitboxChamsThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded

		local pulseOffset = 0
		if Config.BallHitboxChamsPulseSpeed > 0 then
			pulseOffset = math.sin(elapsedClock * (Config.BallHitboxChamsPulseSpeed * 0.25)) * 0.16
		end

		if not d.chamsPart.Parent then d.chamsPart.Parent = workspace end
		if not d.chamsHL.Parent then d.chamsHL.Parent = getVisualParent() end

		d.chamsPart.Size = Vector3.new(diam, diam, diam)
		d.chamsPart.CFrame = CFrame.new(centerPos)

		d.chamsHL.Enabled = true
		d.chamsHL.Adornee = d.chamsPart
		d.chamsHL.DepthMode = depthMode
		d.chamsHL.FillColor = fillCol
		d.chamsHL.OutlineColor = outCol
		d.chamsHL.FillTransparency = math.clamp(baseFillTransp + pulseOffset, 0.05, 0.95)
		d.chamsHL.OutlineTransparency = outTransp
	end

	local function refreshAllBallBoxes()
		for ball, d in pairs(Balls) do
			if d.box then
				updateBallBoxSize(d.box, Config.BallRadius)
			end
			if ball and ball.Parent then
				local root = ball.PrimaryPart or ball:FindFirstChildWhichIsA("BasePart", true)
				if root then
					if Config.BallHitbox3DEnabled then
						update3DHexSphereForBall(d, root.Position)
					end
					if Config.BallHitboxChamsEnabled then
						updateHitboxChamsForBall(d, root.Position)
					end
				end
			end
		end
	end

	local function hideBallDrawings(d)
		if not d then return end
		if d.box2D then
			for _, ln in ipairs(d.box2D) do if ln then ln.Visible = false end end
		end
		if d.ringOuter then d.ringOuter.Visible = false end
		if d.ringInner then d.ringInner.Visible = false end
		if d.pulseRing then d.pulseRing.Visible = false end
		if d.ballLine then d.ballLine.Visible = false end
		if d.bCrossH then d.bCrossH.Visible = false end
		if d.bCrossV then d.bCrossV.Visible = false end
		if d.speedText then d.speedText.Visible = false end
		if d.velShaft then d.velShaft.Visible = false end
		if d.velHeadLeft then d.velHeadLeft.Visible = false end
		if d.velHeadRight then d.velHeadRight.Visible = false end
		if d.tracerGlow then d.tracerGlow.Visible = false end
		if d.tracerCore then d.tracerCore.Visible = false end
		if d.targetDot then d.targetDot.Visible = false end
		if d.arcLines then
			for _, ln in ipairs(d.arcLines) do if ln then ln.Visible = false end end
		end
		if d.trailLines then
			for _, ln in ipairs(d.trailLines) do if ln then ln.Visible = false end end
		end
	end

	local function addBall(ball)
		if not ball or not ball:IsA("Model") or not ball:IsDescendantOf(workspace) then return end
		if Balls[ball] then return end
		local root = ball.PrimaryPart or ball:FindFirstChildWhichIsA("BasePart", true)
		if not root then return end

		local box = Instance.new("Part")
		box.Name = "Nexxwarre_BallHitbox"
		box.Shape = Enum.PartType.Ball
		box.Size = Vector3.new(Config.BallRadius * 2, Config.BallRadius * 2, Config.BallRadius * 2)
		box.CFrame = root.CFrame
		box.Transparency = 1
		box.CanCollide = false
		box.CanTouch = false
		box.CanQuery = true
		box.Anchored = true
		box.CastShadow = false
		box.Massless = true
		box.Parent = ball

		local sOuter, sInner, sHL = createDoubleSidedSphere("Nexxwarre_3DHitboxSphere", getVisualParent())
		local cPart, cHL = createBallHitboxChams("Nexxwarre_BallHitbox")

		Balls[ball] = {
			box = box,
			sphereOuter = sOuter,
			sphereInner = sInner,
			sphereHL = sHL,
			chamsPart = cPart,
			chamsHL = cHL,
			box2D = createBall2DBoxLines(),
			ringOuter = safeDrawing("Circle", { Filled = false, NumSides = 128, Transparency = 0.18, Visible = false }),
			ringInner = safeDrawing("Circle", { Color = Color3.fromRGB(195, 252, 236), Filled = false, NumSides = 128, Transparency = 0.85, Visible = false }),
			pulseRing = safeDrawing("Circle", { Color = Color3.fromRGB(115, 250, 215), Filled = false, NumSides = 96, Thickness = 1.4, Transparency = 0.45, Visible = false }),
			ballLine = safeDrawing("Line", { Transparency = 0.9, Visible = false }),
			bCrossH = safeDrawing("Line", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1.2, Transparency = 0.85, Visible = false }),
			bCrossV = safeDrawing("Line", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1.2, Transparency = 0.85, Visible = false }),
			speedText = safeDrawing("Text", { Text = "", Color = Color3.fromRGB(220, 252, 240), Outline = true, OutlineColor = Color3.fromRGB(8, 12, 18), Center = true, Size = 12, Visible = false }),
			velShaft = safeDrawing("Line", { Thickness = 2.6, Transparency = 0.92, Visible = false }),
			velHeadLeft = safeDrawing("Line", { Thickness = 2.4, Transparency = 0.92, Visible = false }),
			velHeadRight = safeDrawing("Line", { Thickness = 2.4, Transparency = 0.92, Visible = false }),
			tracerGlow = safeDrawing("Line", { Transparency = 0.16, Visible = false }),
			tracerCore = safeDrawing("Line", { Color = Color3.fromRGB(205, 252, 238), Transparency = 0.88, Visible = false }),
			targetDot = safeDrawing("Circle", { Filled = true, NumSides = 32, Radius = 4.0, Transparency = 0.88, Visible = false }),
			arcLines = createArcLines(),
			trailLines = createTrailLines(),
			trailHistory = {}
		}
	end

	local function killBall(ball)
		local d = Balls[ball]
		if not d then return end
		pcall(function() if d.box then d.box:Destroy() end end)
		destroyDoubleSidedSphere(d.sphereOuter, d.sphereInner, d.sphereHL)
		destroyBallHitboxChams(d.chamsPart, d.chamsHL)
		if d.box2D then for _, ln in ipairs(d.box2D) do safeRemoveDrawing(ln) end end
		safeRemoveDrawing(d.ringOuter)
		safeRemoveDrawing(d.ringInner)
		safeRemoveDrawing(d.pulseRing)
		safeRemoveDrawing(d.ballLine)
		safeRemoveDrawing(d.bCrossH)
		safeRemoveDrawing(d.bCrossV)
		safeRemoveDrawing(d.speedText)
		safeRemoveDrawing(d.velShaft)
		safeRemoveDrawing(d.velHeadLeft)
		safeRemoveDrawing(d.velHeadRight)
		safeRemoveDrawing(d.tracerGlow)
		safeRemoveDrawing(d.tracerCore)
		safeRemoveDrawing(d.targetDot)
		if d.arcLines then for _, ln in ipairs(d.arcLines) do safeRemoveDrawing(ln) end end
		if d.trailLines then for _, ln in ipairs(d.trailLines) do safeRemoveDrawing(ln) end end
		Balls[ball] = nil
	end

	table.insert(Connections, CollectionService:GetInstanceAddedSignal("Ball"):Connect(addBall))
	table.insert(Connections, CollectionService:GetInstanceRemovedSignal("Ball"):Connect(killBall))
	for _, ball in ipairs(CollectionService:GetTagged("Ball")) do addBall(ball) end

	-- ================= GRADIENT GLOW OFFSCREEN ESP =================
	local function getOrCreateOffscreenArrow(plr)
		if OffscreenArrows[plr] then return OffscreenArrows[plr] end
		local arrow = {
			glowHalo = safeDrawing("Circle", { Filled = true, NumSides = 28, Radius = 14, Transparency = 0.16, Visible = false }),
			glowRing = safeDrawing("Circle", { Filled = false, NumSides = 28, Thickness = 2.0, Radius = 11, Transparency = 0.42, Visible = false }),
			tipGlow = safeDrawing("Line", { Thickness = 6.0, Transparency = 0.24, Visible = false }),
			leftGlow = safeDrawing("Line", { Thickness = 5.5, Transparency = 0.22, Visible = false }),
			rightGlow = safeDrawing("Line", { Thickness = 5.5, Transparency = 0.22, Visible = false }),
			tip = safeDrawing("Line", { Thickness = 2.6, Transparency = 0.96, Visible = false }),
			leftWing = safeDrawing("Line", { Thickness = 2.3, Transparency = 0.94, Visible = false }),
			rightWing = safeDrawing("Line", { Thickness = 2.3, Transparency = 0.94, Visible = false }),
			coreDot = safeDrawing("Circle", { Filled = true, NumSides = 18, Radius = 3.8, Transparency = 0.96, Visible = false })
		}
		OffscreenArrows[plr] = arrow
		return arrow
	end

	local function hideOffscreenArrow(a)
		if not a then return end
		if a.glowHalo then a.glowHalo.Visible = false end
		if a.glowRing then a.glowRing.Visible = false end
		if a.tipGlow then a.tipGlow.Visible = false end
		if a.leftGlow then a.leftGlow.Visible = false end
		if a.rightGlow then a.rightGlow.Visible = false end
		if a.tip then a.tip.Visible = false end
		if a.leftWing then a.leftWing.Visible = false end
		if a.rightWing then a.rightWing.Visible = false end
		if a.coreDot then a.coreDot.Visible = false end
	end

	local function removeOffscreenArrow(plr)
		local a = OffscreenArrows[plr]
		if not a then return end
		safeRemoveDrawing(a.glowHalo)
		safeRemoveDrawing(a.glowRing)
		safeRemoveDrawing(a.tipGlow)
		safeRemoveDrawing(a.leftGlow)
		safeRemoveDrawing(a.rightGlow)
		safeRemoveDrawing(a.tip)
		safeRemoveDrawing(a.leftWing)
		safeRemoveDrawing(a.rightWing)
		safeRemoveDrawing(a.coreDot)
		OffscreenArrows[plr] = nil
	end

	local function updateOffscreenEsp()
		if not Config.EspOffscreenEnabled then
			for _, a in pairs(OffscreenArrows) do hideOffscreenArrow(a) end
			return
		end
		Camera = workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not Camera or not hrp then
			for _, a in pairs(OffscreenArrows) do hideOffscreenArrow(a) end
			return
		end

		local vp = Camera.ViewportSize
		local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
		local baseRadius = math.clamp(Config.EspOffscreenRadius, 50, math.min(vp.X, vp.Y) * 0.45)
		local primaryCol = getNamedColor(Config.EspOffscreenColorName)
		local accentCol = getNamedColor(Config.EspOffscreenAccentName)
		local pulse = 0.5 + 0.5 * math.sin(elapsedClock * 4.5)
		local activePlrs = {}

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local pHrp = plr.Character:FindFirstChild("HumanoidRootPart")
				local pHum = plr.Character:FindFirstChildOfClass("Humanoid")
				if pHrp and pHum and pHum.Health > 0 then
					activePlrs[plr] = true
					local a = getOrCreateOffscreenArrow(plr)
					local screenPt, onScreen = Camera:WorldToViewportPoint(pHrp.Position)
					local insideViewport = onScreen and screenPt.Z > 0
						and screenPt.X >= 14 and screenPt.X <= (vp.X - 14)
						and screenPt.Y >= 14 and screenPt.Y <= (vp.Y - 14)

					if insideViewport then
						hideOffscreenArrow(a)
					else
						local dir2D
						if screenPt.Z > 0 then
							dir2D = Vector2.new(screenPt.X - center.X, screenPt.Y - center.Y)
						else
							dir2D = Vector2.new(center.X - screenPt.X, center.Y - screenPt.Y)
						end
						if dir2D.Magnitude < 0.001 then
							dir2D = Vector2.new(0, -1)
						else
							dir2D = dir2D.Unit
						end

						local anglePhase = (math.atan2(dir2D.Y, dir2D.X) + elapsedClock * 1.4) % (math.pi * 2)
						local gradMix = 0.5 + 0.5 * math.sin(anglePhase)
						local gradPrimary = primaryCol:Lerp(accentCol, gradMix)
						local gradTip = accentCol:Lerp(Color3.fromRGB(255, 255, 255), 0.35 + pulse * 0.25)

						local orbitR = baseRadius + math.sin(elapsedClock * 3.2 + anglePhase) * 2.5
						local tipPos = center + dir2D * orbitR
						local backPos = tipPos - dir2D * 15
						local perp = Vector2.new(-dir2D.Y, dir2D.X) * 7.5
						local leftPt = backPos + perp
						local rightPt = backPos - perp

						if a.glowHalo then
							a.glowHalo.Position = tipPos - dir2D * 4
							a.glowHalo.Radius = 13 + pulse * 3.5
							a.glowHalo.Color = gradPrimary
							a.glowHalo.Transparency = 0.14 + pulse * 0.08
							a.glowHalo.Visible = true
						end
						if a.glowRing then
							a.glowRing.Position = tipPos - dir2D * 4
							a.glowRing.Radius = 10 + pulse * 2.5
							a.glowRing.Color = accentCol:Lerp(primaryCol, 0.5)
							a.glowRing.Transparency = 0.32 + pulse * 0.18
							a.glowRing.Visible = true
						end

						if a.tipGlow then a.tipGlow.From = backPos; a.tipGlow.To = tipPos; a.tipGlow.Color = gradPrimary; a.tipGlow.Visible = true end
						if a.leftGlow then a.leftGlow.From = tipPos; a.leftGlow.To = leftPt; a.leftGlow.Color = gradPrimary; a.leftGlow.Visible = true end
						if a.rightGlow then a.rightGlow.From = tipPos; a.rightGlow.To = rightPt; a.rightGlow.Color = accentCol; a.rightGlow.Visible = true end

						if a.tip then a.tip.From = backPos; a.tip.To = tipPos; a.tip.Color = gradTip; a.tip.Visible = true end
						if a.leftWing then a.leftWing.From = tipPos; a.leftWing.To = leftPt; a.leftWing.Color = gradPrimary; a.leftWing.Visible = true end
						if a.rightWing then a.rightWing.From = tipPos; a.rightWing.To = rightPt; a.rightWing.Color = accentCol; a.rightWing.Visible = true end

						if a.coreDot then
							a.coreDot.Position = tipPos
							a.coreDot.Radius = 3.4 + pulse * 1.0
							a.coreDot.Color = Color3.fromRGB(255, 255, 255):Lerp(accentCol, 0.35)
							a.coreDot.Visible = true
						end
					end
				end
			end
		end

		for plr, a in pairs(OffscreenArrows) do
			if not activePlrs[plr] then hideOffscreenArrow(a) end
		end
	end

	-- ================= ESP ЛЮДЕЙ =================
	local function createBox2DLines()
		local lines = {}
		for i = 1, 4 do lines[i] = safeDrawing("Line", { Transparency = 0.9, Visible = false }) end
		return lines
	end

	local function createCornerBoxLines()
		local lines = {}
		for i = 1, 8 do lines[i] = safeDrawing("Line", { Transparency = 0.94, Visible = false }) end
		return lines
	end

	local function createBox3DLines()
		local lines = {}
		for i = 1, 12 do lines[i] = safeDrawing("Line", { Transparency = 0.88, Visible = false }) end
		return lines
	end

	local function getOrCreateEsp(char)
		if EspEntries[char] then return EspEntries[char] end
		local entry = {
			box2D = createBox2DLines(),
			corners = createCornerBoxLines(),
			box3D = createBox3DLines(),
			spineUpper = safeDrawing("Line", { Transparency = 0.92, Visible = false }),
			spineLower = safeDrawing("Line", { Transparency = 0.92, Visible = false }),
			hipLine = safeDrawing("Line", { Transparency = 0.88, Visible = false }),
			shoulderLine = safeDrawing("Line", { Transparency = 0.88, Visible = false }),
			headDot = safeDrawing("Circle", { Filled = true, NumSides = 24, Transparency = 0.94, Visible = false }),
			headRing = safeDrawing("Circle", { Filled = false, NumSides = 24, Thickness = 1.4, Transparency = 0.72, Visible = false }),
			hpBg = safeDrawing("Line", { Color = Color3.fromRGB(10, 14, 18), Thickness = 4.5, Transparency = 0.72, Visible = false }),
			hpBar = safeDrawing("Line", { Color = Color3.fromRGB(82, 236, 138), Thickness = 2.6, Transparency = 0.95, Visible = false }),
			infoText = safeDrawing("Text", { Text = "", Color = Color3.fromRGB(238, 250, 244), Outline = true, OutlineColor = Color3.fromRGB(8, 12, 18), Center = true, Size = 13, Visible = false })
		}
		EspEntries[char] = entry
		return entry
	end

	local function hideEspEntry(e)
		if not e then return end
		if e.box2D then for _, ln in ipairs(e.box2D) do if ln then ln.Visible = false end end end
		if e.corners then for _, ln in ipairs(e.corners) do if ln then ln.Visible = false end end end
		if e.box3D then for _, ln in ipairs(e.box3D) do if ln then ln.Visible = false end end end
		if e.spineUpper then e.spineUpper.Visible = false end
		if e.spineLower then e.spineLower.Visible = false end
		if e.hipLine then e.hipLine.Visible = false end
		if e.shoulderLine then e.shoulderLine.Visible = false end
		if e.headDot then e.headDot.Visible = false end
		if e.headRing then e.headRing.Visible = false end
		if e.hpBg then e.hpBg.Visible = false end
		if e.hpBar then e.hpBar.Visible = false end
		if e.infoText then e.infoText.Visible = false end
	end

	local function updateEsp()
		if not Config.EspEnabled then
			for _, e in pairs(EspEntries) do hideEspEntry(e) end
			return
		end
		Camera = workspace.CurrentCamera
		if not Camera then return end

		local espCol = getNamedColor(Config.EspColorName)
		local thick = math.clamp(Config.EspThickness, 1, 5)
		local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local activeChars = {}

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local char = plr.Character
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChildOfClass("Humanoid")
				local head = char:FindFirstChild("Head")

				if hrp and hum and hum.Health > 0 then
					activeChars[char] = true
					local e = getOrCreateEsp(char)
					local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

					if onScreen and rootPos.Z > 0 then
						local headWorld = head and head.Position or (hrp.Position + Vector3.new(0, 2.2, 0))
						local torsoWorld = hrp.Position + Vector3.new(0, 0.55, 0)
						local pelvisWorld = hrp.Position - Vector3.new(0, 0.9, 0)
						local topScreen = Camera:WorldToViewportPoint(headWorld + Vector3.new(0, 0.65, 0))
						local botScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.1, 0))

						local boxH = math.clamp(math.abs(botScreen.Y - topScreen.Y), 16, 540)
						local boxW = boxH * 0.55
						local cx = rootPos.X
						local cy = (topScreen.Y + botScreen.Y) * 0.5
						local tl = Vector2.new(cx - boxW * 0.5, cy - boxH * 0.5)
						local tr = Vector2.new(cx + boxW * 0.5, cy - boxH * 0.5)
						local br = Vector2.new(cx + boxW * 0.5, cy + boxH * 0.5)
						local bl = Vector2.new(cx - boxW * 0.5, cy + boxH * 0.5)

						if Config.Esp2DBoxEnabled and e.box2D then
							e.box2D[1].From = tl; e.box2D[1].To = tr
							e.box2D[2].From = tr; e.box2D[2].To = br
							e.box2D[3].From = br; e.box2D[3].To = bl
							e.box2D[4].From = bl; e.box2D[4].To = tl
							for i = 1, 4 do
								local ln = e.box2D[i]
								if ln then ln.Color = espCol; ln.Thickness = thick; ln.Visible = true end
							end
						elseif e.box2D then
							for _, ln in ipairs(e.box2D) do if ln then ln.Visible = false end end
						end

						if Config.EspCornerBoxEnabled and e.corners then
							local seg = math.clamp(math.min(boxW, boxH) * 0.25, 5, 22)
							e.corners[1].From = tl; e.corners[1].To = Vector2.new(tl.X + seg, tl.Y)
							e.corners[2].From = tl; e.corners[2].To = Vector2.new(tl.X, tl.Y + seg)
							e.corners[3].From = tr; e.corners[3].To = Vector2.new(tr.X - seg, tr.Y)
							e.corners[4].From = tr; e.corners[4].To = Vector2.new(tr.X, tr.Y + seg)
							e.corners[5].From = br; e.corners[5].To = Vector2.new(br.X - seg, br.Y)
							e.corners[6].From = br; e.corners[6].To = Vector2.new(br.X, br.Y - seg)
							e.corners[7].From = bl; e.corners[7].To = Vector2.new(bl.X + seg, bl.Y)
							e.corners[8].From = bl; e.corners[8].To = Vector2.new(bl.X, bl.Y - seg)
							for i = 1, 8 do
								local ln = e.corners[i]
								if ln then ln.Color = espCol; ln.Thickness = thick; ln.Visible = true end
							end
						elseif e.corners then
							for _, ln in ipairs(e.corners) do if ln then ln.Visible = false end end
						end

						if Config.Esp3DBoxEnabled and e.box3D then
							local sx, sy, sz = 1.9, 2.85, 1.5
							local baseCFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 0.15, hrp.Position.Z)
							local corners3D = {
								baseCFrame * Vector3.new(-sx, sy, -sz),
								baseCFrame * Vector3.new(sx, sy, -sz),
								baseCFrame * Vector3.new(sx, sy, sz),
								baseCFrame * Vector3.new(-sx, sy, sz),
								baseCFrame * Vector3.new(-sx, -sy, -sz),
								baseCFrame * Vector3.new(sx, -sy, -sz),
								baseCFrame * Vector3.new(sx, -sy, sz),
								baseCFrame * Vector3.new(-sx, -sy, sz)
							}
							local pts2D = {}
							local allOk = true
							for idx = 1, 8 do
								local p3, pOn = Camera:WorldToViewportPoint(corners3D[idx])
								if not pOn or p3.Z <= 0 then
									allOk = false
									break
								end
								pts2D[idx] = Vector2.new(p3.X, p3.Y)
							end
							if allOk then
								local edges = {
									{1,2}, {2,3}, {3,4}, {4,1},
									{5,6}, {6,7}, {7,8}, {8,5},
									{1,5}, {2,6}, {3,7}, {4,8}
								}
								for idx, ed in ipairs(edges) do
									local ln = e.box3D[idx]
									if ln then
										ln.From = pts2D[ed[1]]
										ln.To = pts2D[ed[2]]
										ln.Color = espCol
										ln.Thickness = math.max(1, thick * 0.85)
										ln.Visible = true
									end
								end
							else
								for _, ln in ipairs(e.box3D) do if ln then ln.Visible = false end end
							end
						elseif e.box3D then
							for _, ln in ipairs(e.box3D) do if ln then ln.Visible = false end end
						end

						local hScreen, hOn = Camera:WorldToViewportPoint(headWorld)
						local tScreen, tOn = Camera:WorldToViewportPoint(torsoWorld)
						local pScreen, pOn = Camera:WorldToViewportPoint(pelvisWorld)
						local rightVec = Camera.CFrame.RightVector
						local shLScreen, shLOn = Camera:WorldToViewportPoint(torsoWorld - rightVec * 1.15)
						local shRScreen, shROn = Camera:WorldToViewportPoint(torsoWorld + rightVec * 1.15)
						local hipLScreen, hipLOn = Camera:WorldToViewportPoint(pelvisWorld - rightVec * 0.85)
						local hipRScreen, hipROn = Camera:WorldToViewportPoint(pelvisWorld + rightVec * 0.85)

						if Config.EspSkeletonEnabled then
							if e.spineUpper then
								if hOn and tOn and hScreen.Z > 0 and tScreen.Z > 0 then
									e.spineUpper.From = Vector2.new(hScreen.X, hScreen.Y); e.spineUpper.To = Vector2.new(tScreen.X, tScreen.Y)
									e.spineUpper.Color = espCol; e.spineUpper.Thickness = thick; e.spineUpper.Visible = true
								else e.spineUpper.Visible = false end
							end
							if e.spineLower then
								if tOn and pOn and tScreen.Z > 0 and pScreen.Z > 0 then
									e.spineLower.From = Vector2.new(tScreen.X, tScreen.Y); e.spineLower.To = Vector2.new(pScreen.X, pScreen.Y)
									e.spineLower.Color = espCol; e.spineLower.Thickness = thick; e.spineLower.Visible = true
								else e.spineLower.Visible = false end
							end
							if e.shoulderLine then
								if shLOn and shROn and shLScreen.Z > 0 and shRScreen.Z > 0 then
									e.shoulderLine.From = Vector2.new(shLScreen.X, shLScreen.Y); e.shoulderLine.To = Vector2.new(shRScreen.X, shRScreen.Y)
									e.shoulderLine.Color = espCol:Lerp(Color3.fromRGB(255, 255, 255), 0.25); e.shoulderLine.Thickness = math.max(1, thick * 0.85); e.shoulderLine.Visible = true
								else e.shoulderLine.Visible = false end
							end
							if e.hipLine then
								if hipLOn and hipROn and hipLScreen.Z > 0 and hipRScreen.Z > 0 then
									e.hipLine.From = Vector2.new(hipLScreen.X, hipLScreen.Y); e.hipLine.To = Vector2.new(hipRScreen.X, hipRScreen.Y)
									e.hipLine.Color = espCol:Lerp(Color3.fromRGB(255, 255, 255), 0.25); e.hipLine.Thickness = math.max(1, thick * 0.85); e.hipLine.Visible = true
								else e.hipLine.Visible = false end
							end
						else
							if e.spineUpper then e.spineUpper.Visible = false end
							if e.spineLower then e.spineLower.Visible = false end
							if e.shoulderLine then e.shoulderLine.Visible = false end
							if e.hipLine then e.hipLine.Visible = false end
						end

						if Config.EspHeadDotEnabled and hOn and hScreen.Z > 0 then
							local rad = math.clamp(120 / math.max(hScreen.Z, 4), 3, 9)
							local hPt = Vector2.new(hScreen.X, hScreen.Y)
							if e.headDot then e.headDot.Position = hPt; e.headDot.Radius = rad * 0.55; e.headDot.Color = espCol; e.headDot.Visible = true end
							if e.headRing then e.headRing.Position = hPt; e.headRing.Radius = rad * 1.15; e.headRing.Color = espCol:Lerp(Color3.fromRGB(255, 255, 255), 0.4); e.headRing.Visible = true end
						else
							if e.headDot then e.headDot.Visible = false end
							if e.headRing then e.headRing.Visible = false end
						end

						if e.hpBg and e.hpBar then
							if Config.EspHealthBarEnabled then
								local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
								local barX = tl.X - 6
								local botPt = Vector2.new(barX, bl.Y)
								local topPt = Vector2.new(barX, tl.Y)
								local hpTopPt = Vector2.new(barX, bl.Y - (bl.Y - tl.Y) * ratio)
								e.hpBg.From = topPt; e.hpBg.To = botPt; e.hpBg.Visible = true
								e.hpBar.From = botPt; e.hpBar.To = hpTopPt
								e.hpBar.Color = Color3.fromRGB(255 - math.floor(ratio * 175), 95 + math.floor(ratio * 140), 120)
								e.hpBar.Visible = true
							else
								e.hpBg.Visible = false; e.hpBar.Visible = false
							end
						end

						if e.infoText then
							if Config.EspInfoTagEnabled then
								local distStuds = localHrp and math.floor((hrp.Position - localHrp.Position).Magnitude + 0.5) or math.floor(rootPos.Z + 0.5)
								e.infoText.Text = string.format("%s [%dm]", plr.DisplayName, distStuds)
								e.infoText.Color = espCol:Lerp(Color3.fromRGB(255, 255, 255), 0.3)
								e.infoText.Position = Vector2.new(cx, tl.Y - 18)
								e.infoText.Visible = true
							else
								e.infoText.Visible = false
							end
						end
					else
						hideEspEntry(e)
					end
				end
			end
		end

		for char, e in pairs(EspEntries) do
			if not activeChars[char] then hideEspEntry(e) end
		end
	end

	-- ================= CHAMS SYSTEM =================
	local function removeChamsForKey(key)
		local hl = ChamsHighlights[key]
		if hl then
			pcall(function() hl:Destroy() end)
			ChamsHighlights[key] = nil
		end
	end

	local function getOrCreateChamsHighlight(key, adorneeChar)
		local hl = ChamsHighlights[key]
		if not hl or not hl.Parent then
			hl = Instance.new("Highlight")
			hl.Name = "NexxwarreChams_" .. tostring(key)
			hl.Parent = getVisualParent()
			ChamsHighlights[key] = hl
		end
		if hl.Adornee ~= adorneeChar then
			hl.Adornee = adorneeChar
		end
		return hl
	end

	local function updateChams()
		if not Config.ChamsEnabled then
			for key in pairs(ChamsHighlights) do removeChamsForKey(key) end
			return
		end

		local fillCol = getNamedColor(Config.ChamsFillColorName)
		local outCol = getNamedColor(Config.ChamsOutlineColorName)
		local baseFillTransp = math.clamp(Config.ChamsFillTransp / 100, 0, 1)
		local outTransp = math.clamp(Config.ChamsOutlineTransp / 100, 0, 1)
		local depthMode = Config.ChamsThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded

		local pulseOffset = 0
		if Config.ChamsPulseSpeed > 0 then
			pulseOffset = math.sin(elapsedClock * (Config.ChamsPulseSpeed * 0.25)) * 0.16
		end
		local finalFillTransp = math.clamp(baseFillTransp + pulseOffset, 0.05, 0.95)
		local activeKeys = {}

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					activeKeys[plr] = true
					local hl = getOrCreateChamsHighlight(plr, plr.Character)
					hl.Enabled = true; hl.DepthMode = depthMode
					hl.FillColor = fillCol; hl.OutlineColor = outCol
					hl.FillTransparency = finalFillTransp; hl.OutlineTransparency = outTransp
				end
			end
		end

		if Config.ChamsSelfEnabled and LocalPlayer.Character then
			local selfHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if selfHum and selfHum.Health > 0 then
				activeKeys["__SELF__"] = true
				local hl = getOrCreateChamsHighlight("__SELF__", LocalPlayer.Character)
				hl.Enabled = true; hl.DepthMode = depthMode
				hl.FillColor = fillCol; hl.OutlineColor = outCol
				hl.FillTransparency = finalFillTransp; hl.OutlineTransparency = outTransp
			end
		end

		for key in pairs(ChamsHighlights) do
			if not activeKeys[key] then removeChamsForKey(key) end
		end
	end

	-- ================= VISUALS =================
	local frameTop = safeDrawing("Line", { Color = Color3.fromRGB(76, 232, 134), Thickness = 1.5, Transparency = 0.35, Visible = false })
	local frameBot = safeDrawing("Line", { Color = Color3.fromRGB(76, 232, 134), Thickness = 1.5, Transparency = 0.35, Visible = false })
	local frameLeft = safeDrawing("Line", { Color = Color3.fromRGB(76, 232, 134), Thickness = 1.5, Transparency = 0.35, Visible = false })
	local frameRight = safeDrawing("Line", { Color = Color3.fromRGB(76, 232, 134), Thickness = 1.5, Transparency = 0.35, Visible = false })

	local function updateScreenFrame()
		Camera = workspace.CurrentCamera
		if not Config.ScreenFrameEnabled or not Camera then
			if frameTop then frameTop.Visible = false end; if frameBot then frameBot.Visible = false end
			if frameLeft then frameLeft.Visible = false end; if frameRight then frameRight.Visible = false end
			return
		end
		local vp = Camera.ViewportSize
		local pad, w, h = 6, vp.X - 6, vp.Y - 6
		if frameTop then frameTop.From = Vector2.new(pad, pad); frameTop.To = Vector2.new(w, pad); frameTop.Visible = true end
		if frameBot then frameBot.From = Vector2.new(pad, h); frameBot.To = Vector2.new(w, h); frameBot.Visible = true end
		if frameLeft then frameLeft.From = Vector2.new(pad, pad); frameLeft.To = Vector2.new(pad, h); frameLeft.Visible = true end
		if frameRight then frameRight.From = Vector2.new(w, pad); frameRight.To = Vector2.new(w, h); frameRight.Visible = true end
	end

	local groundRingOuter = safeDrawing("Circle", { Color = Color3.fromRGB(82, 242, 142), Filled = false, NumSides = 64, Thickness = 1.6, Transparency = 0.45, Visible = false })
	local groundRingInner = safeDrawing("Circle", { Color = Color3.fromRGB(165, 252, 210), Filled = false, NumSides = 64, Thickness = 1.1, Transparency = 0.22, Visible = false })

	local function updateGroundRing()
		Camera = workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not Config.GroundRingEnabled or not Camera or not hrp then
			if groundRingOuter then groundRingOuter.Visible = false end
			if groundRingInner then groundRingInner.Visible = false end
			return
		end
		local footPos = hrp.Position - Vector3.new(0, 2.85, 0)
		local pScreen, on = Camera:WorldToViewportPoint(footPos)
		if not on or pScreen.Z <= 0 then
			if groundRingOuter then groundRingOuter.Visible = false end
			if groundRingInner then groundRingInner.Visible = false end
			return
		end
		local edgePt = Camera:WorldToViewportPoint(footPos + Camera.CFrame.RightVector * 3.1)
		local radiusPx = math.clamp(math.abs(edgePt.X - pScreen.X), 8, 140)
		local center = Vector2.new(pScreen.X, pScreen.Y)
		if groundRingOuter then groundRingOuter.Position = center; groundRingOuter.Radius = radiusPx * (1 + math.sin(elapsedClock * 3.2) * 0.06); groundRingOuter.Visible = true end
		if groundRingInner then groundRingInner.Position = center; groundRingInner.Radius = math.max(5, radiusPx * 0.65); groundRingInner.Visible = true end
	end

	local fovOuter = safeDrawing("Circle", { Color = Color3.fromRGB(130, 240, 200), Filled = false, NumSides = 120, Thickness = 3.6, Transparency = 0.14, Radius = Config.CircleFovRadius, Visible = false })
	local fovMain = safeDrawing("Circle", { Color = Color3.fromRGB(130, 240, 200), Filled = false, NumSides = 120, Thickness = 1.6, Transparency = 0.82, Radius = Config.CircleFovRadius, Visible = false })

	local function updateCircleFov()
		Camera = workspace.CurrentCamera
		if not Config.CircleFovEnabled or not Camera then
			if fovOuter then fovOuter.Visible = false end
			if fovMain then fovMain.Visible = false end
			return
		end
		local vp = Camera.ViewportSize
		local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
		local r = Config.CircleFovRadius * (1 + math.sin(elapsedClock * 2.4) * 0.012)
		if fovOuter then fovOuter.Position = center; fovOuter.Radius = r; fovOuter.Visible = true end
		if fovMain then fovMain.Position = center; fovMain.Radius = r; fovMain.Visible = true end
	end

	local function updateScreenFov(dt)
		Camera = workspace.CurrentCamera
		if not Camera then return end
		if Config.ScreenFovEnabled then
			local targetFov = math.clamp(Config.ScreenFovValue, 55, 115)
			Camera.FieldOfView = Camera.FieldOfView + (targetFov - Camera.FieldOfView) * math.clamp(dt * 12, 0, 1)
		end
	end

	local function restoreScreenFov()
		pcall(function()
			local cam = workspace.CurrentCamera
			if cam then cam.FieldOfView = DefaultFov end
		end)
	end

	local chTop = safeDrawing("Line", { Color = Color3.fromRGB(224, 248, 238), Thickness = 1.5, Transparency = 0.78, Visible = false })
	local chBot = safeDrawing("Line", { Color = Color3.fromRGB(224, 248, 238), Thickness = 1.5, Transparency = 0.78, Visible = false })
	local chLeft = safeDrawing("Line", { Color = Color3.fromRGB(224, 248, 238), Thickness = 1.5, Transparency = 0.78, Visible = false })
	local chRight = safeDrawing("Line", { Color = Color3.fromRGB(224, 248, 238), Thickness = 1.5, Transparency = 0.78, Visible = false })
	local chCenter = safeDrawing("Circle", { Color = Color3.fromRGB(76, 232, 134), Filled = true, NumSides = 18, Radius = 2.0, Transparency = 0.88, Visible = false })

	local function updateCrosshair()
		Camera = workspace.CurrentCamera
		if not Config.CrosshairEnabled or not Camera then
			if chTop then chTop.Visible = false end; if chBot then chBot.Visible = false end
			if chLeft then chLeft.Visible = false end; if chRight then chRight.Visible = false end
			if chCenter then chCenter.Visible = false end
			return
		end
		local vp = Camera.ViewportSize
		local cx, cy, gap, len = vp.X * 0.5, vp.Y * 0.5, 4, Config.CrosshairSize
		if chTop then chTop.From = Vector2.new(cx, cy - gap - len); chTop.To = Vector2.new(cx, cy - gap); chTop.Visible = true end
		if chBot then chBot.From = Vector2.new(cx, cy + gap); chBot.To = Vector2.new(cx, cy + gap + len); chBot.Visible = true end
		if chLeft then chLeft.From = Vector2.new(cx - gap - len, cy); chLeft.To = Vector2.new(cx - gap, cy); chLeft.Visible = true end
		if chRight then chRight.From = Vector2.new(cx + gap, cy); chRight.To = Vector2.new(cx + gap + len, cy); chRight.Visible = true end
		if chCenter then chCenter.Position = Vector2.new(cx, cy); chCenter.Visible = true end
	end

	local radarCircle = safeDrawing("Circle", { Color = Color3.fromRGB(82, 242, 142), Filled = true, NumSides = 64, Radius = 56, Transparency = 0.22, Visible = false })
	local radarBorder = safeDrawing("Circle", { Color = Color3.fromRGB(82, 242, 142), Filled = false, NumSides = 64, Thickness = 1.5, Transparency = 0.78, Visible = false })
	local radarSelfDot = safeDrawing("Circle", { Color = Color3.fromRGB(255, 255, 255), Filled = true, NumSides = 16, Radius = 3.0, Transparency = 0.95, Visible = false })

	local function hideRadarDots()
		for _, dot in pairs(RadarDots) do if dot then dot.Visible = false end end
	end

	local function updateRadar()
		Camera = workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not Config.RadarEnabled or not Camera or not hrp then
			if radarCircle then radarCircle.Visible = false end
			if radarBorder then radarBorder.Visible = false end
			if radarSelfDot then radarSelfDot.Visible = false end
			hideRadarDots()
			return
		end

		local vp = Camera.ViewportSize
		local radiusPx = 56
		local center = Vector2.new(vp.X - radiusPx - 18, vp.Y - radiusPx - 18)
		if radarCircle then radarCircle.Position = center; radarCircle.Radius = radiusPx; radarCircle.Visible = true end
		if radarBorder then radarBorder.Position = center; radarBorder.Radius = radiusPx; radarBorder.Visible = true end
		if radarSelfDot then radarSelfDot.Position = center; radarSelfDot.Visible = true end

		local look = Camera.CFrame.LookVector
		local yaw = math.atan2(-look.X, -look.Z)
		local cosY, sinY = math.cos(yaw), math.sin(yaw)
		local maxDist = math.max(20, Config.RadarRange)
		local active = {}

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local pHrp = plr.Character:FindFirstChild("HumanoidRootPart")
				local pHum = plr.Character:FindFirstChildOfClass("Humanoid")
				if pHrp and pHum and pHum.Health > 0 then
					active[plr] = true
					local dot = RadarDots[plr]
					if not dot then
						dot = safeDrawing("Circle", { Color = Color3.fromRGB(76, 232, 134), Filled = true, NumSides = 14, Radius = 3.6, Transparency = 0.92, Visible = false })
						RadarDots[plr] = dot
					end
					local rel = pHrp.Position - hrp.Position
					local rx = rel.X * cosY - rel.Z * sinY
					local rz = rel.X * sinY + rel.Z * cosY
					local nx = math.clamp(rx / maxDist, -1, 1)
					local nz = math.clamp(rz / maxDist, -1, 1)
					dot.Position = Vector2.new(center.X + nx * (radiusPx - 6), center.Y - nz * (radiusPx - 6))
					dot.Visible = true
				end
			end
		end
		for plr, dot in pairs(RadarDots) do
			if not active[plr] and dot then dot.Visible = false end
		end
	end

	local compassLine = safeDrawing("Line", { Thickness = 1.6, Transparency = 0.72, Visible = false })
	local compassTick = safeDrawing("Line", { Thickness = 2.0, Transparency = 0.92, Visible = false })
	local compassText = safeDrawing("Text", { Text = "", Outline = true, OutlineColor = Color3.fromRGB(8, 12, 18), Center = true, Size = 12, Visible = false })

	local function updateCompassBar()
		Camera = workspace.CurrentCamera
		if not Config.CompassBarEnabled or not Camera then
			if compassLine then compassLine.Visible = false end
			if compassTick then compassTick.Visible = false end
			if compassText then compassText.Visible = false end
			return
		end
		local vp = Camera.ViewportSize
		local cx = vp.X * 0.5
		local yPos = 18
		local halfW = 90
		local col = getNamedColor(Config.CompassBarColorName)

		local look = Camera.CFrame.LookVector
		local deg = math.floor((math.deg(math.atan2(-look.X, -look.Z)) % 360) + 0.5)
		local dirLabel = "N"
		if deg >= 23 and deg < 68 then dirLabel = "NE"
		elseif deg >= 68 and deg < 113 then dirLabel = "E"
		elseif deg >= 113 and deg < 158 then dirLabel = "SE"
		elseif deg >= 158 and deg < 203 then dirLabel = "S"
		elseif deg >= 203 and deg < 248 then dirLabel = "SW"
		elseif deg >= 248 and deg < 293 then dirLabel = "W"
		elseif deg >= 293 and deg < 338 then dirLabel = "NW"
		end

		if compassLine then compassLine.From = Vector2.new(cx - halfW, yPos + 14); compassLine.To = Vector2.new(cx + halfW, yPos + 14); compassLine.Color = col; compassLine.Visible = true end
		if compassTick then compassTick.From = Vector2.new(cx, yPos + 10); compassTick.To = Vector2.new(cx, yPos + 18); compassTick.Color = Color3.fromRGB(255, 255, 255); compassTick.Visible = true end
		if compassText then compassText.Text = string.format("%s  %d°", dirLabel, deg); compassText.Position = Vector2.new(cx, yPos - 4); compassText.Color = col; compassText.Visible = true end
	end

	local snapLine = safeDrawing("Line", { Thickness = 1.6, Transparency = 0.85, Visible = false })
	local snapDot = safeDrawing("Circle", { Filled = true, NumSides = 16, Radius = 3.5, Transparency = 0.9, Visible = false })

	local function updateSnapLine()
		Camera = workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not Config.SnapLineEnabled or not Camera or not hrp then
			if snapLine then snapLine.Visible = false end
			if snapDot then snapDot.Visible = false end
			return
		end

		local bestPos = nil
		local bestDist = math.huge
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local pHrp = plr.Character:FindFirstChild("HumanoidRootPart")
				local pHum = plr.Character:FindFirstChildOfClass("Humanoid")
				if pHrp and pHum and pHum.Health > 0 then
					local d = (pHrp.Position - hrp.Position).Magnitude
					if d < bestDist then
						bestDist = d
						bestPos = pHrp.Position
					end
				end
			end
		end

		if bestPos then
			local sp, on = Camera:WorldToViewportPoint(bestPos)
			if on and sp.Z > 0 then
				local vp = Camera.ViewportSize
				local col = getNamedColor(Config.SnapLineColorName)
				local target2D = Vector2.new(sp.X, sp.Y)
				if snapLine then snapLine.From = Vector2.new(vp.X * 0.5, vp.Y * 0.5); snapLine.To = target2D; snapLine.Color = col; snapLine.Visible = true end
				if snapDot then snapDot.Position = target2D; snapDot.Color = col; snapDot.Visible = true end
				return
			end
		end
		if snapLine then snapLine.Visible = false end
		if snapDot then snapDot.Visible = false end
	end

	local aimRingCircle = safeDrawing("Circle", { Filled = false, NumSides = 72, Thickness = 1.4, Transparency = 0.75, Visible = false })

	local function updateAimRing()
		Camera = workspace.CurrentCamera
		if not Config.AimRingEnabled or not Camera then
			if aimRingCircle then aimRingCircle.Visible = false end
			return
		end
		local vp = Camera.ViewportSize
		aimRingCircle.Position = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
		aimRingCircle.Radius = math.clamp(Config.AimRingRadius or 64, 20, 220)
		aimRingCircle.Color = getNamedColor(Config.AimRingColorName)
		aimRingCircle.Visible = true
	end

	local watermarkText = safeDrawing("Text", { Text = "", Outline = true, OutlineColor = Color3.fromRGB(8, 12, 18), Center = false, Size = 13, Visible = false })

	local function updateWatermarkHud(dt)
		if not Config.WatermarkHudEnabled then
			if watermarkText then watermarkText.Visible = false end
			return
		end
		local instFps = (dt and dt > 0) and (1 / dt) or 60
		fpsSmoothed = fpsSmoothed + (instFps - fpsSmoothed) * math.clamp((dt or 0.016) * 8, 0, 1)
		local pingMs = 0
		pcall(function()
			local netItem = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
			if netItem then
				pingMs = math.floor((tonumber(netItem:GetValue()) or 0) + 0.5)
			end
		end)
		if watermarkText then
			watermarkText.Text = string.format("[N] %s  |  %d FPS  |  %d ms", SCRIPT_TITLE, math.floor(fpsSmoothed + 0.5), pingMs)
			watermarkText.Position = Vector2.new(14, 14)
			watermarkText.Color = getNamedColor(Config.WatermarkColorName)
			watermarkText.Visible = true
		end
	end

	-- ================= MOVEMENT & LOCAL HELPERS =================
	local lastAntiAfkPulse = 0
	local function updateMovement(dt)
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")

		if Config.LocalNoClipEnabled then
			pcall(function()
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end)
		end

		if Config.LocalSwimAssistEnabled and hum then
			pcall(function()
				if hum:GetState() == Enum.HumanoidStateType.Swimming and hum.MoveDirection.Magnitude > 0.05 then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end

		if Config.LocalAntiAfkEnabled and (os.clock() - lastAntiAfkPulse > 45) then
			lastAntiAfkPulse = os.clock()
			pcall(function()
				local vu = game:GetService("VirtualUser")
				if vu then
					vu:CaptureController()
					vu:ClickButton2(Vector2.new())
				end
			end)
		end

		if hrp then
			pcall(function()
				hrp.Anchored = not not Config.LocalFreezeEnabled
			end)
		end

		if hum and hum.Health > 0 then
			if Config.LegitSpeedEnabled then
				local targetSpeed = Config.LegitSpeed
				hum.WalkSpeed = hum.WalkSpeed + (targetSpeed - hum.WalkSpeed) * math.clamp(dt * 10, 0, 1)
				if hrp and hum.MoveDirection.Magnitude > 0.05 and hum.FloorMaterial ~= Enum.Material.Air then
					local horizVel = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
					local desiredVel = hum.MoveDirection.Unit * math.min(targetSpeed, 28)
					local blended = horizVel:Lerp(desiredVel, math.clamp(dt * 6, 0, 0.35))
					hrp.AssemblyLinearVelocity = Vector3.new(blended.X, hrp.AssemblyLinearVelocity.Y, blended.Z)
				end
			end
			if Config.JumpBoostEnabled then
				hum.UseJumpPower = true
				hum.JumpPower = math.clamp(Config.JumpPowerValue, 45, 95)
			end
			if Config.SpinEnabled and hrp then
				hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed * 24) * dt, 0)
			end
		end
	end

	table.insert(Connections, UserInputService.JumpRequest:Connect(function()
		if not Config.LocalInfJumpEnabled then return end
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			pcall(function()
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end)
		end
	end))

	-- ================= RENDER LOOP =================
	table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
		elapsedClock += dt
		Camera = workspace.CurrentCamera
		if not Camera then return end

		local vp = Camera.ViewportSize
		local tracerOrigin = Vector2.new(vp.X * 0.5, vp.Y * 0.93)
		local grav = workspace.Gravity
		local visScale = math.clamp(Config.BallVisualScale / 100, 0.4, 2.5)

		for ball, d in pairs(Balls) do
			local root = ball.PrimaryPart or ball:FindFirstChildWhichIsA("BasePart", true)
			if not root or not ball.Parent then
				if lastBallCrossedFarZone and (os.clock() - lastThrowTime <= 15.0) then
					lastThrowTime = 0; lastThrownBallPos = nil; lastBallCrossedFarZone = false
					triggerRoundWinFeedback(false)
				end
				killBall(ball)
			else
				registerPlayerBallContactOrThrow(root.Position, root.AssemblyLinearVelocity)
				if Config.HitboxEnabled and d.box then
					d.box.CFrame = root.CFrame
					updateBallBoxSize(d.box, Config.BallRadius)
				elseif d.box then
					d.box.CFrame = CFrame.new(0, -5000, 0)
				end

				update3DHexSphereForBall(d, root.Position)
				updateHitboxChamsForBall(d, root.Position)

				if Config.BallTrailEnabled then
					local hist = d.trailHistory
					local lastPt = hist[#hist]
					if not lastPt or (lastPt - root.Position).Magnitude >= 0.45 then
						table.insert(hist, root.Position)
						local maxKeep = math.clamp(tonumber(Config.BallTrailLength) or 10, 3, MAX_TRAIL_SEGMENTS) + 1
						while #hist > maxKeep do
							table.remove(hist, 1)
						end
					end
				elseif d.trailHistory and #d.trailHistory > 0 then
					table.clear(d.trailHistory)
				end

				local pos, on = Camera:WorldToViewportPoint(root.Position)
				local onScreen = on and pos.Z > 0
				local targetPt = Vector2.new(pos.X, pos.Y)

				if d.trailLines then
					if Config.BallTrailEnabled and d.trailHistory and #d.trailHistory >= 2 then
						local trailCol = getNamedColor(Config.BallTrailColorName)
						local trailThick = math.clamp(Config.BallTrailThickness or 2, 1, 5)
						local hist = d.trailHistory
						local segCount = math.min(#hist - 1, MAX_TRAIL_SEGMENTS)
						local used = 0

						for idx = #hist, 2, -1 do
							if used >= segCount then break end
							local pA3 = hist[idx]
							local pB3 = hist[idx - 1]
							local sA, onA = Camera:WorldToViewportPoint(pA3)
							local sB, onB = Camera:WorldToViewportPoint(pB3)
							used += 1
							local ln = d.trailLines[used]
							if ln then
								if onA and onB and sA.Z > 0 and sB.Z > 0 then
									local fade = 1 - ((used - 1) / math.max(1, segCount))
									ln.From = Vector2.new(sA.X, sA.Y)
									ln.To = Vector2.new(sB.X, sB.Y)
									ln.Color = trailCol
									ln.Thickness = math.max(1, trailThick * (0.45 + fade * 0.55))
									ln.Transparency = math.clamp(fade * 0.85, 0.08, 0.85)
									ln.Visible = true
								else
									ln.Visible = false
								end
							end
						end
						for i = used + 1, MAX_TRAIL_SEGMENTS do
							if d.trailLines[i] then d.trailLines[i].Visible = false end
						end
					else
						for _, ln in ipairs(d.trailLines) do if ln then ln.Visible = false end end
					end
				end

				if onScreen then
					local actualR = getActualBallRadius(ball, root)
					local hasBounds, minPt, maxPt, ringPx = computeExactBallScreenBounds(Camera, root.Position, actualR, visScale)

					if Config.BallVelArrowEnabled and d.velShaft and d.velHeadLeft and d.velHeadRight then
						local vel = root.AssemblyLinearVelocity
						local spd = vel.Magnitude
						if spd > 1.5 then
							local tipWorld = root.Position + vel.Unit * math.clamp(spd * 0.28, 3.5, 18)
							local tipScreen, tipOn = Camera:WorldToViewportPoint(tipWorld)
							if tipOn and tipScreen.Z > 0 then
								local dir2D = Vector2.new(tipScreen.X - targetPt.X, tipScreen.Y - targetPt.Y)
								local arrowScale = math.clamp((Config.BallVelArrowScale or 100) / 100, 0.5, 2.2)
								local lenPx = math.clamp(dir2D.Magnitude * arrowScale, 16, 130)
								if dir2D.Magnitude > 0.01 then
									dir2D = dir2D.Unit
								else
									dir2D = Vector2.new(0, -1)
								end
								local endPt = targetPt + dir2D * lenPx
								local perp = Vector2.new(-dir2D.Y, dir2D.X) * 6.5
								local headBase = endPt - dir2D * 10
								local vCol = getNamedColor(Config.BallVelArrowColorName)

								d.velShaft.From = targetPt; d.velShaft.To = endPt; d.velShaft.Color = vCol; d.velShaft.Visible = true
								d.velHeadLeft.From = endPt; d.velHeadLeft.To = headBase + perp; d.velHeadLeft.Color = vCol; d.velHeadLeft.Visible = true
								d.velHeadRight.From = endPt; d.velHeadRight.To = headBase - perp; d.velHeadRight.Color = vCol; d.velHeadRight.Visible = true
							else
								d.velShaft.Visible = false; d.velHeadLeft.Visible = false; d.velHeadRight.Visible = false
							end
						else
							d.velShaft.Visible = false; d.velHeadLeft.Visible = false; d.velHeadRight.Visible = false
						end
					elseif d.velShaft then
						d.velShaft.Visible = false; d.velHeadLeft.Visible = false; d.velHeadRight.Visible = false
					end

					if Config.Ball2DBoxEnabled and hasBounds and d.box2D then
						local boxCol = getNamedColor(Config.Ball2DBoxColorName)
						local boxThick = math.clamp(Config.Ball2DBoxThickness, 1, 5)
						local tl = Vector2.new(minPt.X, minPt.Y)
						local tr = Vector2.new(maxPt.X, minPt.Y)
						local br = Vector2.new(maxPt.X, maxPt.Y)
						local bl = Vector2.new(minPt.X, maxPt.Y)

						d.box2D[1].From = tl; d.box2D[1].To = tr
						d.box2D[2].From = tr; d.box2D[2].To = br
						d.box2D[3].From = br; d.box2D[3].To = bl
						d.box2D[4].From = bl; d.box2D[4].To = tl

						for i = 1, 4 do
							local ln = d.box2D[i]
							if ln then ln.Color = boxCol; ln.Thickness = boxThick; ln.Visible = true end
						end
					elseif d.box2D then
						for _, ln in ipairs(d.box2D) do if ln then ln.Visible = false end end
					end

					if Config.RingEnabled and ringPx > 0 then
						local ringCol = getNamedColor(Config.RingColorName)
						local ringThick = math.clamp(Config.RingThickness, 1, 5)
						if d.ringOuter then d.ringOuter.Position = targetPt; d.ringOuter.Radius = ringPx; d.ringOuter.Color = ringCol; d.ringOuter.Thickness = ringThick + 1.4; d.ringOuter.Visible = true end
						if d.ringInner then d.ringInner.Position = targetPt; d.ringInner.Radius = math.max(2, ringPx * 0.92); d.ringInner.Thickness = math.max(1.0, ringThick * 0.6); d.ringInner.Visible = true end
						if d.pulseRing then
							if Config.PulseWaveEnabled then
								local wavePhase = (elapsedClock * 1.4) % 1
								d.pulseRing.Position = targetPt
								d.pulseRing.Radius = math.max(3, ringPx * (0.65 + wavePhase * 0.65))
								d.pulseRing.Transparency = math.clamp((1 - wavePhase) * 0.55, 0.05, 0.55)
								d.pulseRing.Visible = true
							else
								d.pulseRing.Visible = false
							end
						end
					else
						if d.ringOuter then d.ringOuter.Visible = false end
						if d.ringInner then d.ringInner.Visible = false end
						if d.pulseRing then d.pulseRing.Visible = false end
					end

					if Config.BallLineEnabled and d.ballLine then
						d.ballLine.From = tracerOrigin
						d.ballLine.To = targetPt
						d.ballLine.Color = getNamedColor(Config.BallLineColorName)
						d.ballLine.Thickness = math.clamp(Config.BallLineThickness, 1, 5)
						d.ballLine.Visible = true
					elseif d.ballLine then
						d.ballLine.Visible = false
					end

					if Config.BallCrosshairEnabled and d.bCrossH and d.bCrossV then
						local arm = math.clamp(ringPx * 0.55, 5, 16)
						d.bCrossH.From = Vector2.new(targetPt.X - arm, targetPt.Y); d.bCrossH.To = Vector2.new(targetPt.X + arm, targetPt.Y); d.bCrossH.Visible = true
						d.bCrossV.From = Vector2.new(targetPt.X, targetPt.Y - arm); d.bCrossV.To = Vector2.new(targetPt.X, targetPt.Y + arm); d.bCrossV.Visible = true
					else
						if d.bCrossH then d.bCrossH.Visible = false end
						if d.bCrossV then d.bCrossV.Visible = false end
					end

					if Config.BallSpeedTagEnabled and d.speedText then
						local spd = math.floor(root.AssemblyLinearVelocity.Magnitude + 0.5)
						d.speedText.Text = tostring(spd) .. " u/s"
						d.speedText.Position = Vector2.new(targetPt.X, (hasBounds and maxPt.Y or targetPt.Y) + 4)
						d.speedText.Visible = true
					elseif d.speedText then
						d.speedText.Visible = false
					end

					if Config.TracerEnabled then
						local trCol = getNamedColor(Config.TracerColorName)
						local trThick = math.clamp(Config.TracerThickness, 1, 5)
						if d.tracerGlow then d.tracerGlow.From = tracerOrigin; d.tracerGlow.To = targetPt; d.tracerGlow.Color = trCol; d.tracerGlow.Thickness = trThick + 2.2; d.tracerGlow.Visible = true end
						if d.tracerCore then d.tracerCore.From = tracerOrigin; d.tracerCore.To = targetPt; d.tracerCore.Thickness = trThick; d.tracerCore.Visible = true end
						if d.targetDot then d.targetDot.Position = targetPt; d.targetDot.Color = trCol; d.targetDot.Visible = true end
					else
						if d.tracerGlow then d.tracerGlow.Visible = false end
						if d.tracerCore then d.tracerCore.Visible = false end
						if d.targetDot then d.targetDot.Visible = false end
					end

					if d.arcLines then
						if Config.TrajectoryArcEnabled then
							local vel = root.AssemblyLinearVelocity
							local prev2D = targetPt
							local prevVisible = true
							local stepDt = 0.055
							for idx = 1, ARC_SEGMENTS do
								local t = idx * stepDt
								local predPos = root.Position + vel * t + Vector3.new(0, -0.5 * grav * t * t, 0)
								local pScreen, pOn = Camera:WorldToViewportPoint(predPos)
								local ln = d.arcLines[idx]
								if ln then
									if pOn and pScreen.Z > 0 and prevVisible then
										local curr2D = Vector2.new(pScreen.X, pScreen.Y)
										ln.From = prev2D; ln.To = curr2D
										ln.Transparency = math.clamp(0.78 - (idx / ARC_SEGMENTS) * 0.52, 0.15, 0.78)
										ln.Visible = true; prev2D = curr2D
									else
										ln.Visible = false; prevVisible = pOn and pScreen.Z > 0
										if prevVisible then prev2D = Vector2.new(pScreen.X, pScreen.Y) end
									end
								end
							end
						else
							for _, ln in ipairs(d.arcLines) do if ln then ln.Visible = false end end
						end
					end
				else
					hideBallDrawings(d)
				end
			end
		end

		checkGuiScoreChangeAfterThrow()
		updateWinEdgeEffect(dt)
		updateHitFlash(dt)
		updateEsp()
		updateOffscreenEsp()
		updateChams()
		updateGroundRing()
		updateCircleFov()
		updateScreenFov(dt)
		updateWorldMultiParticles()
		updateWorldSnow()
		updateWorldMotes()
		updateSkyMood()
		updateCustomSky()
		updateCustomFog()
		updateMapAtmosphere()
		updateBloom()
		updateSunRays()
		applyFullBrightState()
		applyGravityState()
		updateCrosshair()
		updateCustomCrosshair(dt)
		updateScreenFrame()
		updateRadar()
		updateCompassBar()
		updateSnapLine()
		updateAimRing()
		updateWatermarkHud(dt)
		updateMovement(dt)
	end))

	-- ================= WINDUI LOADER (ARCEUS X NEO) =================
	local function loadWindUI()
		local sources = {
			"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
			"https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
		}
		for _, url in ipairs(sources) do
			local ok, lib = pcall(function()
				local src = game:HttpGet(url, true)
				return loadstring(src)()
			end)
			if ok and type(lib) == "table" and type(lib.CreateWindow) == "function" then
				return lib
			end
		end
		return nil
	end

	local ThemeFallbackMap = {
		Cyberpunk = "Midnight",
		Crimson = "Rose",
		Obsidian = "Dark"
	}

	local function applyWindUiTheme(lib, themeName)
		if not lib then return end
		local targetTheme = ThemeFallbackMap[tostring(themeName)] or tostring(themeName)
		pcall(function()
			if type(lib.SetTheme) == "function" then
				lib:SetTheme(targetTheme)
			end
		end)
	end

	local function decorateWindUiWithBrandN(parentGui)
		pcall(function()
			if not parentGui then return end
			for _, desc in ipairs(parentGui:GetDescendants()) do
				if desc:IsA("TextLabel") and tostring(desc.Text) == SCRIPT_TITLE then
					local hdr = desc.Parent
					if hdr and not hdr:FindFirstChild("NexxwarreTitleBadgeN") then
						local badge = createBrandIconN(hdr, 20, 6, Color3.fromRGB(58, 225, 145), Color3.fromRGB(0, 225, 255))
						badge.Name = "NexxwarreTitleBadgeN"
						badge.LayoutOrder = -10
					end
				end
			end
		end)
	end

	local WindUI = loadWindUI()
	local WindowRef = nil

	if WindUI then
		local okWin, win = pcall(function()
			local initTheme = ThemeFallbackMap[Config.TopicTheme] or Config.TopicTheme
			return WindUI:CreateWindow({
				Title = SCRIPT_TITLE,
				Icon = "sparkles",
				Author = "Arceus X Neo",
				Folder = "Nexxwarre_WindUI",
				Size = UDim2.fromOffset(560, 360),
				Transparent = true,
				Theme = initTheme,
				Resizable = true,
				SideBarWidth = 146,
				HideSearchBar = true
			})
		end)

		if okWin and win then
			WindowRef = win
			decorateWindUiWithBrandN(resolveGuiParent())

			local TopicTab = win:Tab({ Title = "Topic", Icon = "palette" })
			local BallTab = win:Tab({ Title = "Ball", Icon = "target" })
			local EspTab = win:Tab({ Title = "ESP", Icon = "eye" })
			local ChamsTab = win:Tab({ Title = "Chams", Icon = "layers" })
			local WorldTab = win:Tab({ Title = "World", Icon = "sun" })
			local VisualsTab = win:Tab({ Title = "Visuals", Icon = "monitor" })
			local CrosshairTab = win:Tab({ Title = "Crosshair", Icon = "crosshair" })
			local MovementTab = win:Tab({ Title = "Movement", Icon = "zap" })
			local LocalTab = win:Tab({ Title = "Local", Icon = "user" })
			local ConfigTab = win:Tab({ Title = "Config", Icon = "folder" })

			local uiElements = {}
			local function trackEl(key, el)
				if el then uiElements[key] = el end
				return el
			end

			local function safeSetElementValue(el, val)
				if not el then return end
				pcall(function()
					if type(el.Set) == "function" then
						el:Set(val)
					elseif type(el.SetValue) == "function" then
						el:SetValue(val)
					elseif type(el.Select) == "function" then
						el:Select(val)
					end
				end)
			end

			local xhairInfoParagraph = nil
			local function updateCrosshairInfoText()
				if not xhairInfoParagraph or not xhairInfoParagraph.SetDesc then return end
				local spec = buildCrosshairSpec(Config.CrosshairPresetId)
				local desc = string.format(
					"Preset #%d / 1000  |  Style: %s  |  Rays: %d  |  Gap: %d  |  Len: %d",
					spec.id, spec.archetype, spec.rayCount, spec.gap, spec.length
				)
				pcall(function()
					xhairInfoParagraph:SetDesc(desc)
				end)
			end

			SyncUiFromConfigFn = function()
				applyWindUiTheme(WindUI, Config.TopicTheme)
				updateSkyMood()
				updateCustomSky()
				updateWorldMultiParticles()
				updateCustomFog()
				updateMapAtmosphere()
				updateBloom()
				updateSunRays()
				applyFullBrightState()
				applyGravityState()
				refreshAllBallBoxes()
				if not Config.ScreenFovEnabled then restoreScreenFov() end

				safeSetElementValue(uiElements.TopicTheme, Config.TopicTheme)
				safeSetElementValue(uiElements.HitboxEnabled, Config.HitboxEnabled)
				safeSetElementValue(uiElements.BallRadius, Config.BallRadius)
				safeSetElementValue(uiElements.BallHitbox3DEnabled, Config.BallHitbox3DEnabled)
				safeSetElementValue(uiElements.BallHitbox3DColorName, Config.BallHitbox3DColorName)
				safeSetElementValue(uiElements.BallHitbox3DTransp, Config.BallHitbox3DTransp)
				safeSetElementValue(uiElements.BallHitboxChamsEnabled, Config.BallHitboxChamsEnabled)
				safeSetElementValue(uiElements.BallHitboxChamsThroughWalls, Config.BallHitboxChamsThroughWalls)
				safeSetElementValue(uiElements.BallHitboxChamsFillColorName, Config.BallHitboxChamsFillColorName)
				safeSetElementValue(uiElements.BallHitboxChamsOutlineColorName, Config.BallHitboxChamsOutlineColorName)
				safeSetElementValue(uiElements.BallHitboxChamsFillTransp, Config.BallHitboxChamsFillTransp)
				safeSetElementValue(uiElements.BallHitboxChamsOutlineTransp, Config.BallHitboxChamsOutlineTransp)
				safeSetElementValue(uiElements.BallHitboxChamsPulseSpeed, Config.BallHitboxChamsPulseSpeed)
				safeSetElementValue(uiElements.BallVisualScale, Config.BallVisualScale)
				safeSetElementValue(uiElements.Ball2DBoxEnabled, Config.Ball2DBoxEnabled)
				safeSetElementValue(uiElements.Ball2DBoxColorName, Config.Ball2DBoxColorName)
				safeSetElementValue(uiElements.Ball2DBoxThickness, Config.Ball2DBoxThickness)
				safeSetElementValue(uiElements.RingEnabled, Config.RingEnabled)
				safeSetElementValue(uiElements.RingColorName, Config.RingColorName)
				safeSetElementValue(uiElements.RingThickness, Config.RingThickness)
				safeSetElementValue(uiElements.BallLineEnabled, Config.BallLineEnabled)
				safeSetElementValue(uiElements.BallLineColorName, Config.BallLineColorName)
				safeSetElementValue(uiElements.BallLineThickness, Config.BallLineThickness)
				safeSetElementValue(uiElements.BallCrosshairEnabled, Config.BallCrosshairEnabled)
				safeSetElementValue(uiElements.BallSpeedTagEnabled, Config.BallSpeedTagEnabled)
				safeSetElementValue(uiElements.BallVelArrowEnabled, Config.BallVelArrowEnabled)
				safeSetElementValue(uiElements.BallVelArrowColorName, Config.BallVelArrowColorName)
				safeSetElementValue(uiElements.BallVelArrowScale, Config.BallVelArrowScale)
				safeSetElementValue(uiElements.PulseWaveEnabled, Config.PulseWaveEnabled)
				safeSetElementValue(uiElements.TracerEnabled, Config.TracerEnabled)
				safeSetElementValue(uiElements.TracerColorName, Config.TracerColorName)
				safeSetElementValue(uiElements.TracerThickness, Config.TracerThickness)
				safeSetElementValue(uiElements.TrajectoryArcEnabled, Config.TrajectoryArcEnabled)
				safeSetElementValue(uiElements.BallTrailEnabled, Config.BallTrailEnabled)
				safeSetElementValue(uiElements.BallTrailColorName, Config.BallTrailColorName)
				safeSetElementValue(uiElements.BallTrailLength, Config.BallTrailLength)
				safeSetElementValue(uiElements.BallTrailThickness, Config.BallTrailThickness)

				safeSetElementValue(uiElements.EspEnabled, Config.EspEnabled)
				safeSetElementValue(uiElements.EspColorName, Config.EspColorName)
				safeSetElementValue(uiElements.EspOffscreenEnabled, Config.EspOffscreenEnabled)
				safeSetElementValue(uiElements.EspOffscreenColorName, Config.EspOffscreenColorName)
				safeSetElementValue(uiElements.EspOffscreenAccentName, Config.EspOffscreenAccentName)
				safeSetElementValue(uiElements.EspOffscreenRadius, Config.EspOffscreenRadius)
				safeSetElementValue(uiElements.Esp2DBoxEnabled, Config.Esp2DBoxEnabled)
				safeSetElementValue(uiElements.EspCornerBoxEnabled, Config.EspCornerBoxEnabled)
				safeSetElementValue(uiElements.Esp3DBoxEnabled, Config.Esp3DBoxEnabled)
				safeSetElementValue(uiElements.EspSkeletonEnabled, Config.EspSkeletonEnabled)
				safeSetElementValue(uiElements.EspHeadDotEnabled, Config.EspHeadDotEnabled)
				safeSetElementValue(uiElements.EspInfoTagEnabled, Config.EspInfoTagEnabled)
				safeSetElementValue(uiElements.EspHealthBarEnabled, Config.EspHealthBarEnabled)
				safeSetElementValue(uiElements.EspThickness, Config.EspThickness)

				safeSetElementValue(uiElements.ChamsEnabled, Config.ChamsEnabled)
				safeSetElementValue(uiElements.ChamsThroughWalls, Config.ChamsThroughWalls)
				safeSetElementValue(uiElements.ChamsSelfEnabled, Config.ChamsSelfEnabled)
				safeSetElementValue(uiElements.ChamsFillColorName, Config.ChamsFillColorName)
				safeSetElementValue(uiElements.ChamsOutlineColorName, Config.ChamsOutlineColorName)
				safeSetElementValue(uiElements.ChamsFillTransp, Config.ChamsFillTransp)
				safeSetElementValue(uiElements.ChamsOutlineTransp, Config.ChamsOutlineTransp)
				safeSetElementValue(uiElements.ChamsPulseSpeed, Config.ChamsPulseSpeed)

				safeSetElementValue(uiElements.SkyMoodName, Config.SkyMoodName)
				safeSetElementValue(uiElements.CustomSkyEnabled, Config.CustomSkyEnabled)
				safeSetElementValue(uiElements.CustomSkyColorName, Config.CustomSkyColorName)
				safeSetElementValue(uiElements.CustomSkyCelestial, Config.CustomSkyCelestial)
				safeSetElementValue(uiElements.WorldParticlesEnabled, Config.WorldParticlesEnabled)
				safeSetElementValue(uiElements.WorldParticleMode, Config.WorldParticleMode)
				safeSetElementValue(uiElements.WorldParticlesColorName, Config.WorldParticlesColorName)
				safeSetElementValue(uiElements.WorldParticlesRate, Config.WorldParticlesRate)
				safeSetElementValue(uiElements.WorldParticlesSize, Config.WorldParticlesSize)
				safeSetElementValue(uiElements.WorldMotesEnabled, Config.WorldMotesEnabled)
				safeSetElementValue(uiElements.WorldMotesRate, Config.WorldMotesRate)
				safeSetElementValue(uiElements.WorldSnowEnabled, Config.WorldSnowEnabled)
				safeSetElementValue(uiElements.WorldSnowRate, Config.WorldSnowRate)
				safeSetElementValue(uiElements.WorldSnowSize, Config.WorldSnowSize)
				safeSetElementValue(uiElements.FogEnabled, Config.FogEnabled)
				safeSetElementValue(uiElements.FogColorName, Config.FogColorName)
				safeSetElementValue(uiElements.FogStart, Config.FogStart)
				safeSetElementValue(uiElements.FogEnd, Config.FogEnd)
				safeSetElementValue(uiElements.AtmosphereEnabled, Config.AtmosphereEnabled)
				safeSetElementValue(uiElements.AtmosphereColorName, Config.AtmosphereColorName)
				safeSetElementValue(uiElements.AtmosphereIntensity, Config.AtmosphereIntensity)
				safeSetElementValue(uiElements.BloomEnabled, Config.BloomEnabled)
				safeSetElementValue(uiElements.BloomIntensity, Config.BloomIntensity)
				safeSetElementValue(uiElements.SunRaysEnabled, Config.SunRaysEnabled)
				safeSetElementValue(uiElements.SunRaysIntensity, Config.SunRaysIntensity)

				safeSetElementValue(uiElements.WinEdgeEffectEnabled, Config.WinEdgeEffectEnabled)
				safeSetElementValue(uiElements.WinEdgeColorName, Config.WinEdgeColorName)
				safeSetElementValue(uiElements.WinEdgeDuration, Config.WinEdgeDuration)
				safeSetElementValue(uiElements.WinSoundEnabled, Config.WinSoundEnabled)
				safeSetElementValue(uiElements.HitFlashEnabled, Config.HitFlashEnabled)
				safeSetElementValue(uiElements.HitFlashColorName, Config.HitFlashColorName)
				safeSetElementValue(uiElements.HitFlashDuration, Config.HitFlashDuration)
				safeSetElementValue(uiElements.ScreenFrameEnabled, Config.ScreenFrameEnabled)
				safeSetElementValue(uiElements.GroundRingEnabled, Config.GroundRingEnabled)
				safeSetElementValue(uiElements.CircleFovEnabled, Config.CircleFovEnabled)
				safeSetElementValue(uiElements.CircleFovRadius, Config.CircleFovRadius)
				safeSetElementValue(uiElements.ScreenFovEnabled, Config.ScreenFovEnabled)
				safeSetElementValue(uiElements.ScreenFovValue, Config.ScreenFovValue)
				safeSetElementValue(uiElements.StretchEnabled, Config.StretchEnabled)
				safeSetElementValue(uiElements.StretchRatio, Config.StretchRatio)
				safeSetElementValue(uiElements.CrosshairEnabled, Config.CrosshairEnabled)
				safeSetElementValue(uiElements.CrosshairSize, Config.CrosshairSize)
				safeSetElementValue(uiElements.RadarEnabled, Config.RadarEnabled)
				safeSetElementValue(uiElements.RadarRange, Config.RadarRange)

				safeSetElementValue(uiElements.CompassBarEnabled, Config.CompassBarEnabled)
				safeSetElementValue(uiElements.CompassBarColorName, Config.CompassBarColorName)
				safeSetElementValue(uiElements.SnapLineEnabled, Config.SnapLineEnabled)
				safeSetElementValue(uiElements.SnapLineColorName, Config.SnapLineColorName)
				safeSetElementValue(uiElements.AimRingEnabled, Config.AimRingEnabled)
				safeSetElementValue(uiElements.AimRingRadius, Config.AimRingRadius)
				safeSetElementValue(uiElements.AimRingColorName, Config.AimRingColorName)
				safeSetElementValue(uiElements.CameraTiltEnabled, Config.CameraTiltEnabled)
				safeSetElementValue(uiElements.CameraTiltAngle, Config.CameraTiltAngle)
				safeSetElementValue(uiElements.WatermarkHudEnabled, Config.WatermarkHudEnabled)
				safeSetElementValue(uiElements.WatermarkColorName, Config.WatermarkColorName)

				safeSetElementValue(uiElements.CrosshairTabEnabled, Config.CrosshairTabEnabled)
				safeSetElementValue(uiElements.CrosshairPresetId, Config.CrosshairPresetId)
				safeSetElementValue(uiElements.CrosshairPresetColorName, Config.CrosshairPresetColorName)
				safeSetElementValue(uiElements.CrosshairPresetScale, Config.CrosshairPresetScale)
				safeSetElementValue(uiElements.CrosshairPresetThickness, Config.CrosshairPresetThickness)
				safeSetElementValue(uiElements.CrosshairPresetSpin, Config.CrosshairPresetSpin)
				safeSetElementValue(uiElements.CrosshairDynamicEnabled, Config.CrosshairDynamicEnabled)
				safeSetElementValue(uiElements.CrosshairDynamicSpread, Config.CrosshairDynamicSpread)
				updateCrosshairInfoText()

				safeSetElementValue(uiElements.LegitSpeedEnabled, Config.LegitSpeedEnabled)
				safeSetElementValue(uiElements.LegitSpeed, Config.LegitSpeed)
				safeSetElementValue(uiElements.JumpBoostEnabled, Config.JumpBoostEnabled)
				safeSetElementValue(uiElements.JumpPowerValue, Config.JumpPowerValue)
				safeSetElementValue(uiElements.SpinEnabled, Config.SpinEnabled)
				safeSetElementValue(uiElements.SpinSpeed, Config.SpinSpeed)

				safeSetElementValue(uiElements.LocalNoClipEnabled, Config.LocalNoClipEnabled)
				safeSetElementValue(uiElements.LocalAntiAfkEnabled, Config.LocalAntiAfkEnabled)
				safeSetElementValue(uiElements.LocalInfJumpEnabled, Config.LocalInfJumpEnabled)
				safeSetElementValue(uiElements.LocalSwimAssistEnabled, Config.LocalSwimAssistEnabled)
				safeSetElementValue(uiElements.LocalLowGravityEnabled, Config.LocalLowGravityEnabled)
				safeSetElementValue(uiElements.LocalGravityValue, Config.LocalGravityValue)
				safeSetElementValue(uiElements.LocalFullBrightEnabled, Config.LocalFullBrightEnabled)
				safeSetElementValue(uiElements.LocalFreezeEnabled, Config.LocalFreezeEnabled)
				safeSetElementValue(uiElements.LocalDashDistance, Config.LocalDashDistance)
			end

			-- TOPIC
			trackEl("TopicTheme", TopicTab:Dropdown({
				Title = "WindUI Theme",
				Desc = "Switch WindUI color theme live",
				Values = WindUiThemes,
				Value = Config.TopicTheme,
				Callback = function(val)
					Config.TopicTheme = tostring(val)
					applyWindUiTheme(WindUI, Config.TopicTheme)
				end
			}))

			-- BALL
			trackEl("HitboxEnabled", BallTab:Toggle({ Title = "Ball Hitbox", Desc = "Expand ball hitbox radius", Default = false, Callback = function(v) Config.HitboxEnabled = not not v end }))
			trackEl("BallRadius", BallTab:Slider({ Title = "Hitbox Radius", Step = 1, Value = { Min = 4, Max = 30, Default = Config.BallRadius }, Callback = function(val) Config.BallRadius = tonumber(val) or 12; refreshAllBallBoxes() end }))
			trackEl("BallHitbox3DEnabled", BallTab:Toggle({ Title = "3D Hitbox Sphere", Desc = "Double-sided 3D sphere matching Hitbox Radius", Default = false, Callback = function(v) Config.BallHitbox3DEnabled = not not v; refreshAllBallBoxes() end }))
			trackEl("BallHitbox3DColorName", BallTab:Dropdown({ Title = "3D Sphere Color", Values = ColorNames, Value = Config.BallHitbox3DColorName, Callback = function(val) Config.BallHitbox3DColorName = tostring(val); refreshAllBallBoxes() end }))
			trackEl("BallHitbox3DTransp", BallTab:Slider({ Title = "3D Sphere Transparency %", Step = 5, Value = { Min = 15, Max = 90, Default = Config.BallHitbox3DTransp }, Callback = function(val) Config.BallHitbox3DTransp = tonumber(val) or 55; refreshAllBallBoxes() end }))
			trackEl("BallHitboxChamsEnabled", BallTab:Toggle({ Title = "Hitbox Chams", Desc = "Highlight chams matching ball hitbox radius", Default = false, Callback = function(v) Config.BallHitboxChamsEnabled = not not v; refreshAllBallBoxes() end }))
			trackEl("BallHitboxChamsThroughWalls", BallTab:Toggle({ Title = "Hitbox Chams Through Walls", Desc = "AlwaysOnTop visibility for hitbox chams", Default = false, Callback = function(v) Config.BallHitboxChamsThroughWalls = not not v; refreshAllBallBoxes() end }))
			trackEl("BallHitboxChamsFillColorName", BallTab:Dropdown({ Title = "Hitbox Chams Fill Color", Values = ColorNames, Value = Config.BallHitboxChamsFillColorName, Callback = function(val) Config.BallHitboxChamsFillColorName = tostring(val); refreshAllBallBoxes() end }))
			trackEl("BallHitboxChamsOutlineColorName", BallTab:Dropdown({ Title = "Hitbox Chams Outline Color", Values = ColorNames, Value = Config.BallHitboxChamsOutlineColorName, Callback = function(val) Config.BallHitboxChamsOutlineColorName = tostring(val); refreshAllBallBoxes() end }))
			trackEl("BallHitboxChamsFillTransp", BallTab:Slider({ Title = "Hitbox Chams Fill Transp %", Step = 5, Value = { Min = 5, Max = 95, Default = Config.BallHitboxChamsFillTransp }, Callback = function(val) Config.BallHitboxChamsFillTransp = tonumber(val) or 55; refreshAllBallBoxes() end }))
			trackEl("BallHitboxChamsOutlineTransp", BallTab:Slider({ Title = "Hitbox Chams Outline Transp %", Step = 5, Value = { Min = 0, Max = 95, Default = Config.BallHitboxChamsOutlineTransp }, Callback = function(val) Config.BallHitboxChamsOutlineTransp = tonumber(val) or 10; refreshAllBallBoxes() end }))
			trackEl("BallHitboxChamsPulseSpeed", BallTab:Slider({ Title = "Hitbox Chams Pulse Speed", Step = 1, Value = { Min = 0, Max = 50, Default = Config.BallHitboxChamsPulseSpeed }, Callback = function(val) Config.BallHitboxChamsPulseSpeed = tonumber(val) or 0; refreshAllBallBoxes() end }))
			trackEl("BallVisualScale", BallTab:Slider({ Title = "Ball Visual Scale %", Step = 5, Value = { Min = 50, Max = 200, Default = Config.BallVisualScale }, Callback = function(val) Config.BallVisualScale = tonumber(val) or 100 end }))
			trackEl("Ball2DBoxEnabled", BallTab:Toggle({ Title = "Ball 2D Box", Desc = "2D box matching exact ball size", Default = false, Callback = function(v) Config.Ball2DBoxEnabled = not not v end }))
			trackEl("Ball2DBoxColorName", BallTab:Dropdown({ Title = "Ball 2D Box Color", Values = ColorNames, Value = Config.Ball2DBoxColorName, Callback = function(val) Config.Ball2DBoxColorName = tostring(val) end }))
			trackEl("Ball2DBoxThickness", BallTab:Slider({ Title = "Ball 2D Box Thickness", Step = 1, Value = { Min = 1, Max = 5, Default = Config.Ball2DBoxThickness }, Callback = function(val) Config.Ball2DBoxThickness = tonumber(val) or 2 end }))
			trackEl("RingEnabled", BallTab:Toggle({ Title = "Ball Ring", Desc = "Ring matching exact ball size", Default = false, Callback = function(v) Config.RingEnabled = not not v end }))
			trackEl("RingColorName", BallTab:Dropdown({ Title = "Ball Ring Color", Values = ColorNames, Value = Config.RingColorName, Callback = function(val) Config.RingColorName = tostring(val) end }))
			trackEl("RingThickness", BallTab:Slider({ Title = "Ball Ring Thickness", Step = 1, Value = { Min = 1, Max = 5, Default = Config.RingThickness }, Callback = function(val) Config.RingThickness = tonumber(val) or 2 end }))
			trackEl("BallLineEnabled", BallTab:Toggle({ Title = "Ball Line", Desc = "Line from bottom screen to ball", Default = false, Callback = function(v) Config.BallLineEnabled = not not v end }))
			trackEl("BallLineColorName", BallTab:Dropdown({ Title = "Ball Line Color", Values = ColorNames, Value = Config.BallLineColorName, Callback = function(val) Config.BallLineColorName = tostring(val) end }))
			trackEl("BallLineThickness", BallTab:Slider({ Title = "Ball Line Thickness", Step = 1, Value = { Min = 1, Max = 5, Default = Config.BallLineThickness }, Callback = function(val) Config.BallLineThickness = tonumber(val) or 2 end }))
			trackEl("BallCrosshairEnabled", BallTab:Toggle({ Title = "Ball Crosshair", Desc = "Center aim cross on the ball", Default = false, Callback = function(v) Config.BallCrosshairEnabled = not not v end }))
			trackEl("BallSpeedTagEnabled", BallTab:Toggle({ Title = "Ball Speed Tag", Desc = "Shows ball speed in studs/s", Default = false, Callback = function(v) Config.BallSpeedTagEnabled = not not v end }))
			trackEl("BallVelArrowEnabled", BallTab:Toggle({ Title = "Velocity Arrow", Desc = "Directional arrow along ball velocity", Default = false, Callback = function(v) Config.BallVelArrowEnabled = not not v end }))
			trackEl("BallVelArrowColorName", BallTab:Dropdown({ Title = "Velocity Arrow Color", Values = ColorNames, Value = Config.BallVelArrowColorName, Callback = function(val) Config.BallVelArrowColorName = tostring(val) end }))
			trackEl("BallVelArrowScale", BallTab:Slider({ Title = "Velocity Arrow Scale %", Step = 10, Value = { Min = 50, Max = 220, Default = Config.BallVelArrowScale }, Callback = function(val) Config.BallVelArrowScale = tonumber(val) or 100 end }))
			trackEl("PulseWaveEnabled", BallTab:Toggle({ Title = "Pulse Wave", Desc = "Expanding pulse ring", Default = false, Callback = function(v) Config.PulseWaveEnabled = not not v end }))
			trackEl("TracerEnabled", BallTab:Toggle({ Title = "Ball Tracer", Desc = "Tracer line to ball", Default = false, Callback = function(v) Config.TracerEnabled = not not v end }))
			trackEl("TracerColorName", BallTab:Dropdown({ Title = "Ball Tracer Color", Values = ColorNames, Value = Config.TracerColorName, Callback = function(val) Config.TracerColorName = tostring(val) end }))
			trackEl("TracerThickness", BallTab:Slider({ Title = "Ball Tracer Thickness", Step = 1, Value = { Min = 1, Max = 5, Default = Config.TracerThickness }, Callback = function(val) Config.TracerThickness = tonumber(val) or 2 end }))
			trackEl("TrajectoryArcEnabled", BallTab:Toggle({ Title = "Trajectory Arc", Desc = "Predicted ball trajectory arc", Default = false, Callback = function(v) Config.TrajectoryArcEnabled = not not v end }))
			trackEl("BallTrailEnabled", BallTab:Toggle({ Title = "Ball Trail", Desc = "Fading motion trail behind ball", Default = false, Callback = function(v) Config.BallTrailEnabled = not not v end }))
			trackEl("BallTrailColorName", BallTab:Dropdown({ Title = "Ball Trail Color", Values = ColorNames, Value = Config.BallTrailColorName, Callback = function(val) Config.BallTrailColorName = tostring(val) end }))
			trackEl("BallTrailLength", BallTab:Slider({ Title = "Ball Trail Length", Step = 1, Value = { Min = 4, Max = 18, Default = Config.BallTrailLength }, Callback = function(val) Config.BallTrailLength = tonumber(val) or 10 end }))
			trackEl("BallTrailThickness", BallTab:Slider({ Title = "Ball Trail Thickness", Step = 1, Value = { Min = 1, Max = 5, Default = Config.BallTrailThickness }, Callback = function(val) Config.BallTrailThickness = tonumber(val) or 2 end }))

			-- ESP
			trackEl("EspEnabled", EspTab:Toggle({ Title = "Enable ESP", Desc = "Master toggle for player ESP", Default = false, Callback = function(v) Config.EspEnabled = not not v end }))
			trackEl("EspColorName", EspTab:Dropdown({ Title = "ESP Color", Values = ColorNames, Value = Config.EspColorName, Callback = function(val) Config.EspColorName = tostring(val) end }))
			trackEl("EspOffscreenEnabled", EspTab:Toggle({ Title = "Offscreen Gradient Glow", Desc = "Glowing gradient arrows for offscreen players", Default = false, Callback = function(v) Config.EspOffscreenEnabled = not not v end }))
			trackEl("EspOffscreenColorName", EspTab:Dropdown({ Title = "Offscreen Primary Color", Values = ColorNames, Value = Config.EspOffscreenColorName, Callback = function(val) Config.EspOffscreenColorName = tostring(val) end }))
			trackEl("EspOffscreenAccentName", EspTab:Dropdown({ Title = "Offscreen Gradient Accent", Values = ColorNames, Value = Config.EspOffscreenAccentName, Callback = function(val) Config.EspOffscreenAccentName = tostring(val) end }))
			trackEl("EspOffscreenRadius", EspTab:Slider({ Title = "Offscreen Orbit Radius", Step = 5, Value = { Min = 50, Max = 260, Default = Config.EspOffscreenRadius }, Callback = function(val) Config.EspOffscreenRadius = tonumber(val) or 120 end }))
			trackEl("Esp2DBoxEnabled", EspTab:Toggle({ Title = "2D Box", Desc = "2D bounding box around players", Default = false, Callback = function(v) Config.Esp2DBoxEnabled = not not v end }))
			trackEl("EspCornerBoxEnabled", EspTab:Toggle({ Title = "Corner Box", Desc = "Corner brackets around players", Default = false, Callback = function(v) Config.EspCornerBoxEnabled = not not v end }))
			trackEl("Esp3DBoxEnabled", EspTab:Toggle({ Title = "3D Box", Desc = "3D wireframe cube around players", Default = false, Callback = function(v) Config.Esp3DBoxEnabled = not not v end }))
			trackEl("EspSkeletonEnabled", EspTab:Toggle({ Title = "Skeleton Rig", Desc = "Spine, shoulders & hips lines", Default = false, Callback = function(v) Config.EspSkeletonEnabled = not not v end }))
			trackEl("EspHeadDotEnabled", EspTab:Toggle({ Title = "Head Dot & Ring", Desc = "Head marker & halo ring", Default = false, Callback = function(v) Config.EspHeadDotEnabled = not not v end }))
			trackEl("EspInfoTagEnabled", EspTab:Toggle({ Title = "Name & Distance", Desc = "Player name + studs distance", Default = false, Callback = function(v) Config.EspInfoTagEnabled = not not v end }))
			trackEl("EspHealthBarEnabled", EspTab:Toggle({ Title = "Health Bar", Desc = "Vertical HP bar beside player", Default = false, Callback = function(v) Config.EspHealthBarEnabled = not not v end }))
			trackEl("EspThickness", EspTab:Slider({ Title = "ESP Line Thickness", Step = 1, Value = { Min = 1, Max = 5, Default = Config.EspThickness }, Callback = function(val) Config.EspThickness = tonumber(val) or 2 end }))

			-- CHAMS
			trackEl("ChamsEnabled", ChamsTab:Toggle({ Title = "Enable Chams", Desc = "3D character highlight chams", Default = false, Callback = function(v) Config.ChamsEnabled = not not v end }))
			trackEl("ChamsThroughWalls", ChamsTab:Toggle({ Title = "Through Walls", Desc = "AlwaysOnTop visibility mode", Default = false, Callback = function(v) Config.ChamsThroughWalls = not not v end }))
			trackEl("ChamsSelfEnabled", ChamsTab:Toggle({ Title = "Self Chams", Desc = "Apply chams to your character", Default = false, Callback = function(v) Config.ChamsSelfEnabled = not not v end }))
			trackEl("ChamsFillColorName", ChamsTab:Dropdown({ Title = "Fill Color", Values = ColorNames, Value = Config.ChamsFillColorName, Callback = function(val) Config.ChamsFillColorName = tostring(val) end }))
			trackEl("ChamsOutlineColorName", ChamsTab:Dropdown({ Title = "Outline Color", Values = ColorNames, Value = Config.ChamsOutlineColorName, Callback = function(val) Config.ChamsOutlineColorName = tostring(val) end }))
			trackEl("ChamsFillTransp", ChamsTab:Slider({ Title = "Fill Transparency", Step = 1, Value = { Min = 0, Max = 95, Default = Config.ChamsFillTransp }, Callback = function(val) Config.ChamsFillTransp = tonumber(val) or 45 end }))
			trackEl("ChamsOutlineTransp", ChamsTab:Slider({ Title = "Outline Transparency", Step = 1, Value = { Min = 0, Max = 95, Default = Config.ChamsOutlineTransp }, Callback = function(val) Config.ChamsOutlineTransp = tonumber(val) or 10 end }))
			trackEl("ChamsPulseSpeed", ChamsTab:Slider({ Title = "Pulse Speed", Step = 1, Value = { Min = 0, Max = 50, Default = Config.ChamsPulseSpeed }, Callback = function(val) Config.ChamsPulseSpeed = tonumber(val) or 0 end }))

			-- WORLD
			trackEl("SkyMoodName", WorldTab:Dropdown({ Title = "Sky Mood", Values = { "Original", "Midnight", "CyberDusk", "GoldenHour" }, Value = Config.SkyMoodName, Callback = function(val) Config.SkyMoodName = tostring(val); updateSkyMood() end }))
			trackEl("CustomSkyEnabled", WorldTab:Toggle({ Title = "Custom Sky", Desc = "Tinted skybox & starfield", Default = false, Callback = function(v) Config.CustomSkyEnabled = not not v; updateCustomSky() end }))
			trackEl("CustomSkyColorName", WorldTab:Dropdown({ Title = "Custom Sky Tint", Values = ColorNames, Value = Config.CustomSkyColorName, Callback = function(val) Config.CustomSkyColorName = tostring(val); updateCustomSky() end }))
			trackEl("CustomSkyCelestial", WorldTab:Toggle({ Title = "Celestial Bodies", Desc = "Show sun, moon & stars", Default = true, Callback = function(v) Config.CustomSkyCelestial = not not v; updateCustomSky() end }))
			trackEl("WorldParticlesEnabled", WorldTab:Toggle({ Title = "World Particles", Desc = "Enable multi-style world particles", Default = false, Callback = function(v) Config.WorldParticlesEnabled = not not v; updateWorldMultiParticles() end }))
			trackEl("WorldParticleMode", WorldTab:Dropdown({ Title = "Particle Style", Values = ParticleStyles, Value = Config.WorldParticleMode, Callback = function(val) Config.WorldParticleMode = tostring(val); updateWorldMultiParticles() end }))
			trackEl("WorldParticlesColorName", WorldTab:Dropdown({ Title = "Particle Color", Values = ColorNames, Value = Config.WorldParticlesColorName, Callback = function(val) Config.WorldParticlesColorName = tostring(val); updateWorldMultiParticles() end }))
			trackEl("WorldParticlesRate", WorldTab:Slider({ Title = "Particle Rate", Step = 5, Value = { Min = 15, Max = 260, Default = Config.WorldParticlesRate }, Callback = function(val) Config.WorldParticlesRate = tonumber(val) or 85 end }))
			trackEl("WorldParticlesSize", WorldTab:Slider({ Title = "Particle Size", Step = 5, Value = { Min = 10, Max = 90, Default = Config.WorldParticlesSize }, Callback = function(val) Config.WorldParticlesSize = tonumber(val) or 35 end }))
			trackEl("WorldMotesEnabled", WorldTab:Toggle({ Title = "Ambient Motes", Desc = "Floating world particles", Default = false, Callback = function(v) Config.WorldMotesEnabled = not not v end }))
			trackEl("WorldMotesRate", WorldTab:Slider({ Title = "Motes Rate", Step = 5, Value = { Min = 10, Max = 180, Default = Config.WorldMotesRate }, Callback = function(val) Config.WorldMotesRate = tonumber(val) or 65 end }))
			trackEl("WorldSnowEnabled", WorldTab:Toggle({ Title = "3D Snowflakes", Desc = "Falling snow around player", Default = false, Callback = function(v) Config.WorldSnowEnabled = not not v end }))
			trackEl("WorldSnowRate", WorldTab:Slider({ Title = "Snow Rate", Step = 10, Value = { Min = 20, Max = 350, Default = Config.WorldSnowRate }, Callback = function(val) Config.WorldSnowRate = tonumber(val) or 140 end }))
			trackEl("WorldSnowSize", WorldTab:Slider({ Title = "Snowflake Size", Step = 5, Value = { Min = 15, Max = 85, Default = Config.WorldSnowSize }, Callback = function(val) Config.WorldSnowSize = tonumber(val) or 35 end }))
			trackEl("FogEnabled", WorldTab:Toggle({ Title = "Custom Fog", Desc = "Override fog settings", Default = false, Callback = function(v) Config.FogEnabled = not not v; if not v then restoreFog() end end }))
			trackEl("FogColorName", WorldTab:Dropdown({ Title = "Fog Color", Values = ColorNames, Value = Config.FogColorName, Callback = function(val) Config.FogColorName = tostring(val) end }))
			trackEl("FogStart", WorldTab:Slider({ Title = "Fog Start", Step = 10, Value = { Min = 0, Max = 400, Default = Config.FogStart }, Callback = function(val) Config.FogStart = tonumber(val) or 20 end }))
			trackEl("FogEnd", WorldTab:Slider({ Title = "Fog End", Step = 20, Value = { Min = 30, Max = 1200, Default = Config.FogEnd }, Callback = function(val) Config.FogEnd = tonumber(val) or 220 end }))
			trackEl("AtmosphereEnabled", WorldTab:Toggle({ Title = "Atmosphere Tint", Desc = "Ambient & color tint", Default = false, Callback = function(v) Config.AtmosphereEnabled = not not v; if not v then restoreAtmosphere() end end }))
			trackEl("AtmosphereColorName", WorldTab:Dropdown({ Title = "Atmosphere Color", Values = ColorNames, Value = Config.AtmosphereColorName, Callback = function(val) Config.AtmosphereColorName = tostring(val) end }))
			trackEl("AtmosphereIntensity", WorldTab:Slider({ Title = "Atmosphere Intensity", Step = 5, Value = { Min = 10, Max = 100, Default = Config.AtmosphereIntensity }, Callback = function(val) Config.AtmosphereIntensity = tonumber(val) or 65 end }))
			trackEl("BloomEnabled", WorldTab:Toggle({ Title = "Bloom", Desc = "Bloom glow post-effect", Default = false, Callback = function(v) Config.BloomEnabled = not not v; updateBloom() end }))
			trackEl("BloomIntensity", WorldTab:Slider({ Title = "Bloom Intensity", Step = 5, Value = { Min = 5, Max = 100, Default = Config.BloomIntensity }, Callback = function(val) Config.BloomIntensity = tonumber(val) or 45 end }))
			trackEl("SunRaysEnabled", WorldTab:Toggle({ Title = "Sun Rays", Desc = "Sun rays post-effect", Default = false, Callback = function(v) Config.SunRaysEnabled = not not v; updateSunRays() end }))
			trackEl("SunRaysIntensity", WorldTab:Slider({ Title = "Sun Rays Intensity", Step = 5, Value = { Min = 5, Max = 85, Default = Config.SunRaysIntensity }, Callback = function(val) Config.SunRaysIntensity = tonumber(val) or 35 end }))

			-- VISUALS
			trackEl("WinEdgeEffectEnabled", VisualsTab:Toggle({ Title = "Win Edge Glow", Desc = "Screen border flash on win", Default = false, Callback = function(v) Config.WinEdgeEffectEnabled = not not v end }))
			trackEl("WinEdgeColorName", VisualsTab:Dropdown({ Title = "Win Edge Color", Values = ColorNames, Value = Config.WinEdgeColorName, Callback = function(val) Config.WinEdgeColorName = tostring(val) end }))
			trackEl("WinEdgeDuration", VisualsTab:Slider({ Title = "Win Edge Duration", Step = 10, Value = { Min = 50, Max = 250, Default = Config.WinEdgeDuration }, Callback = function(val) Config.WinEdgeDuration = tonumber(val) or 120 end }))
			trackEl("WinSoundEnabled", VisualsTab:Toggle({ Title = "Round Win Sound", Desc = "Play win sound effect", Default = false, Callback = function(v) Config.WinSoundEnabled = not not v end }))
			VisualsTab:Button({ Title = "Test Win FX", Desc = "Preview glow & sound", Callback = function() triggerRoundWinFeedback(true) end })
			trackEl("HitFlashEnabled", VisualsTab:Toggle({ Title = "Hit / Action Flash", Desc = "Edge flash on ball hit / throw / action", Default = false, Callback = function(v) Config.HitFlashEnabled = not not v end }))
			trackEl("HitFlashColorName", VisualsTab:Dropdown({ Title = "Hit Flash Color", Values = ColorNames, Value = Config.HitFlashColorName, Callback = function(val) Config.HitFlashColorName = tostring(val) end }))
			trackEl("HitFlashDuration", VisualsTab:Slider({ Title = "Hit Flash Duration", Step = 5, Value = { Min = 25, Max = 140, Default = Config.HitFlashDuration }, Callback = function(val) Config.HitFlashDuration = tonumber(val) or 55 end }))
			VisualsTab:Button({ Title = "Test Hit Flash", Desc = "Preview hit / action flash", Callback = function() triggerHitFlash(true) end })
			trackEl("ScreenFrameEnabled", VisualsTab:Toggle({ Title = "Screen Frame", Desc = "Clean border frame on screen", Default = false, Callback = function(v) Config.ScreenFrameEnabled = not not v end }))
			trackEl("GroundRingEnabled", VisualsTab:Toggle({ Title = "Ground Ring", Desc = "Ring under your character", Default = false, Callback = function(v) Config.GroundRingEnabled = not not v end }))
			trackEl("CircleFovEnabled", VisualsTab:Toggle({ Title = "Circle FOV", Desc = "Center FOV circle", Default = false, Callback = function(v) Config.CircleFovEnabled = not not v end }))
			trackEl("CircleFovRadius", VisualsTab:Slider({ Title = "Circle FOV Radius", Step = 5, Value = { Min = 30, Max = 360, Default = Config.CircleFovRadius }, Callback = function(val) Config.CircleFovRadius = tonumber(val) or 135 end }))
			trackEl("ScreenFovEnabled", VisualsTab:Toggle({ Title = "Camera FOV", Desc = "Custom camera FieldOfView", Default = false, Callback = function(v) Config.ScreenFovEnabled = not not v; if not v then restoreScreenFov() end end }))
			trackEl("ScreenFovValue", VisualsTab:Slider({ Title = "Camera FOV Value", Step = 1, Value = { Min = 55, Max = 115, Default = Config.ScreenFovValue }, Callback = function(val) Config.ScreenFovValue = tonumber(val) or 70 end }))
			trackEl("StretchEnabled", VisualsTab:Toggle({ Title = "Stretched Res", Desc = "Vertical camera scale", Default = false, Callback = function(v) Config.StretchEnabled = not not v end }))
			trackEl("StretchRatio", VisualsTab:Slider({ Title = "Vertical Scale", Step = 1, Value = { Min = 55, Max = 100, Default = Config.StretchRatio }, Callback = function(val) Config.StretchRatio = tonumber(val) or 75 end }))
			trackEl("CrosshairEnabled", VisualsTab:Toggle({ Title = "Crosshair", Desc = "Center screen crosshair", Default = false, Callback = function(v) Config.CrosshairEnabled = not not v end }))
			trackEl("CrosshairSize", VisualsTab:Slider({ Title = "Crosshair Size", Step = 1, Value = { Min = 4, Max = 20, Default = Config.CrosshairSize }, Callback = function(val) Config.CrosshairSize = tonumber(val) or 8 end }))
			trackEl("RadarEnabled", VisualsTab:Toggle({ Title = "Radar", Desc = "Bottom-right radar", Default = false, Callback = function(v) Config.RadarEnabled = not not v end }))
			trackEl("RadarRange", VisualsTab:Slider({ Title = "Radar Range", Step = 10, Value = { Min = 40, Max = 320, Default = Config.RadarRange }, Callback = function(val) Config.RadarRange = tonumber(val) or 140 end }))
			trackEl("CompassBarEnabled", VisualsTab:Toggle({ Title = "Top Compass Bar", Desc = "Cardinal direction & angle at top", Default = false, Callback = function(v) Config.CompassBarEnabled = not not v end }))
			trackEl("CompassBarColorName", VisualsTab:Dropdown({ Title = "Compass Color", Values = ColorNames, Value = Config.CompassBarColorName, Callback = function(val) Config.CompassBarColorName = tostring(val) end }))
			trackEl("SnapLineEnabled", VisualsTab:Toggle({ Title = "Nearest Snap Line", Desc = "Line from center to nearest player", Default = false, Callback = function(v) Config.SnapLineEnabled = not not v end }))
			trackEl("SnapLineColorName", VisualsTab:Dropdown({ Title = "Snap Line Color", Values = ColorNames, Value = Config.SnapLineColorName, Callback = function(val) Config.SnapLineColorName = tostring(val) end }))
			trackEl("AimRingEnabled", VisualsTab:Toggle({ Title = "Inner Aim Ring", Desc = "Inner reference circle around center", Default = false, Callback = function(v) Config.AimRingEnabled = not not v end }))
			trackEl("AimRingRadius", VisualsTab:Slider({ Title = "Aim Ring Radius", Step = 4, Value = { Min = 20, Max = 220, Default = Config.AimRingRadius }, Callback = function(val) Config.AimRingRadius = tonumber(val) or 64 end }))
			trackEl("AimRingColorName", VisualsTab:Dropdown({ Title = "Aim Ring Color", Values = ColorNames, Value = Config.AimRingColorName, Callback = function(val) Config.AimRingColorName = tostring(val) end }))
			trackEl("CameraTiltEnabled", VisualsTab:Toggle({ Title = "Strafe Camera Tilt", Desc = "Subtle roll tilt when strafing", Default = false, Callback = function(v) Config.CameraTiltEnabled = not not v end }))
			trackEl("CameraTiltAngle", VisualsTab:Slider({ Title = "Tilt Max Angle", Step = 1, Value = { Min = 1, Max = 15, Default = Config.CameraTiltAngle }, Callback = function(val) Config.CameraTiltAngle = tonumber(val) or 4 end }))
			trackEl("WatermarkHudEnabled", VisualsTab:Toggle({ Title = "Watermark HUD", Desc = "Top-left FPS & ping overlay", Default = false, Callback = function(v) Config.WatermarkHudEnabled = not not v end }))
			trackEl("WatermarkColorName", VisualsTab:Dropdown({ Title = "Watermark Color", Values = ColorNames, Value = Config.WatermarkColorName, Callback = function(val) Config.WatermarkColorName = tostring(val) end }))

			-- CROSSHAIR TAB
			trackEl("CrosshairTabEnabled", CrosshairTab:Toggle({
				Title = "Enable Crosshair",
				Desc = "Show selected crosshair preset on screen",
				Default = false,
				Callback = function(v)
					Config.CrosshairTabEnabled = not not v
				end
			}))

			xhairInfoParagraph = CrosshairTab:Paragraph({
				Title = "Active Crosshair Preset",
				Desc = "Preset #1 / 1000  |  Style: Classic Cross"
			})
			updateCrosshairInfoText()

			trackEl("CrosshairPresetId", CrosshairTab:Slider({
				Title = "Crosshair # (1-1000)",
				Step = 1,
				Value = { Min = 1, Max = 1000, Default = Config.CrosshairPresetId },
				Callback = function(val)
					Config.CrosshairPresetId = math.clamp(math.floor(tonumber(val) or 1), 1, 1000)
					updateCrosshairInfoText()
				end
			}))

			CrosshairTab:Button({
				Title = "Random Crosshair (1-1000)",
				Desc = "Pick a random crosshair from 1000 presets",
				Callback = function()
					local rndId = math.random(1, 1000)
					Config.CrosshairPresetId = rndId
					safeSetElementValue(uiElements.CrosshairPresetId, rndId)
					updateCrosshairInfoText()
				end
			})

			trackEl("CrosshairDynamicEnabled", CrosshairTab:Toggle({
				Title = "Dynamic Spread",
				Desc = "Expand crosshair smoothly when moving, jumping & on hit flash",
				Default = false,
				Callback = function(v)
					Config.CrosshairDynamicEnabled = not not v
				end
			}))

			trackEl("CrosshairDynamicSpread", CrosshairTab:Slider({
				Title = "Spread Multiplier %",
				Step = 5,
				Value = { Min = 20, Max = 200, Default = Config.CrosshairDynamicSpread },
				Callback = function(val)
					Config.CrosshairDynamicSpread = tonumber(val) or 100
				end
			}))

			trackEl("CrosshairPresetColorName", CrosshairTab:Dropdown({
				Title = "Crosshair Color",
				Values = ColorNames,
				Value = Config.CrosshairPresetColorName,
				Callback = function(val)
					Config.CrosshairPresetColorName = tostring(val)
				end
			}))

			trackEl("CrosshairPresetScale", CrosshairTab:Slider({
				Title = "Crosshair Scale %",
				Step = 5,
				Value = { Min = 40, Max = 220, Default = Config.CrosshairPresetScale },
				Callback = function(val)
					Config.CrosshairPresetScale = tonumber(val) or 100
				end
			}))

			trackEl("CrosshairPresetThickness", CrosshairTab:Slider({
				Title = "Line Thickness",
				Step = 1,
				Value = { Min = 1, Max = 5, Default = Config.CrosshairPresetThickness },
				Callback = function(val)
					Config.CrosshairPresetThickness = tonumber(val) or 2
				end
			}))

			trackEl("CrosshairPresetSpin", CrosshairTab:Slider({
				Title = "Spin Speed",
				Step = 1,
				Value = { Min = 0, Max = 50, Default = Config.CrosshairPresetSpin },
				Callback = function(val)
					Config.CrosshairPresetSpin = tonumber(val) or 0
				end
			}))

			-- MOVEMENT
			trackEl("LegitSpeedEnabled", MovementTab:Toggle({ Title = "Legit Speed", Desc = "Smooth WalkSpeed boost", Default = false, Callback = function(v)
				Config.LegitSpeedEnabled = not not v
				if not v then
					local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.WalkSpeed = 16 end
				end
			end }))
			trackEl("LegitSpeed", MovementTab:Slider({ Title = "Speed Value", Step = 1, Value = { Min = 16, Max = 32, Default = Config.LegitSpeed }, Callback = function(val) Config.LegitSpeed = tonumber(val) or 22 end }))
			trackEl("JumpBoostEnabled", MovementTab:Toggle({ Title = "Jump Boost", Desc = "Higher jump power", Default = false, Callback = function(v)
				Config.JumpBoostEnabled = not not v
				if not v then
					local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.JumpPower = 50 end
				end
			end }))
			trackEl("JumpPowerValue", MovementTab:Slider({ Title = "Jump Power", Step = 1, Value = { Min = 45, Max = 95, Default = Config.JumpPowerValue }, Callback = function(val) Config.JumpPowerValue = tonumber(val) or 58 end }))
			trackEl("SpinEnabled", MovementTab:Toggle({ Title = "Character Spin", Desc = "Smooth Y-axis spin", Default = false, Callback = function(v) Config.SpinEnabled = not not v end }))
			trackEl("SpinSpeed", MovementTab:Slider({ Title = "Spin Speed", Step = 1, Value = { Min = 1, Max = 50, Default = Config.SpinSpeed }, Callback = function(val) Config.SpinSpeed = tonumber(val) or 18 end }))

			-- LOCAL TAB
			trackEl("LocalNoClipEnabled", LocalTab:Toggle({ Title = "NoClip", Desc = "Disable character part collisions", Default = false, Callback = function(v) Config.LocalNoClipEnabled = not not v end }))
			trackEl("LocalInfJumpEnabled", LocalTab:Toggle({ Title = "Infinite Jump", Desc = "Jump again in mid-air", Default = false, Callback = function(v) Config.LocalInfJumpEnabled = not not v end }))
			trackEl("LocalSwimAssistEnabled", LocalTab:Toggle({ Title = "Swim Assist", Desc = "Auto jump pulse while swimming", Default = false, Callback = function(v) Config.LocalSwimAssistEnabled = not not v end }))
			trackEl("LocalLowGravityEnabled", LocalTab:Toggle({ Title = "Custom Gravity", Desc = "Override workspace gravity", Default = false, Callback = function(v) Config.LocalLowGravityEnabled = not not v; applyGravityState() end }))
			trackEl("LocalGravityValue", LocalTab:Slider({ Title = "Gravity Value", Step = 5, Value = { Min = 15, Max = 196, Default = Config.LocalGravityValue }, Callback = function(val) Config.LocalGravityValue = tonumber(val) or 75; applyGravityState() end }))
			trackEl("LocalFullBrightEnabled", LocalTab:Toggle({ Title = "FullBright", Desc = "Brighter ambient & lighting", Default = false, Callback = function(v) Config.LocalFullBrightEnabled = not not v; applyFullBrightState() end }))
			trackEl("LocalFreezeEnabled", LocalTab:Toggle({ Title = "Freeze Character", Desc = "Anchor HumanoidRootPart in place", Default = false, Callback = function(v)
				Config.LocalFreezeEnabled = not not v
				if not v then
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp then pcall(function() hrp.Anchored = false end) end
				end
			end }))
			trackEl("LocalAntiAfkEnabled", LocalTab:Toggle({ Title = "Anti-AFK", Desc = "Prevent idle kick", Default = false, Callback = function(v) Config.LocalAntiAfkEnabled = not not v end }))
			trackEl("LocalDashDistance", LocalTab:Slider({ Title = "Dash Distance", Step = 2, Value = { Min = 6, Max = 45, Default = Config.LocalDashDistance }, Callback = function(val) Config.LocalDashDistance = tonumber(val) or 18 end }))
			LocalTab:Button({ Title = "Forward Dash", Desc = "Teleport forward along look direction", Callback = dashForward })
			LocalTab:Button({
				Title = "Reset Character",
				Desc = "Respawn your character",
				Callback = function()
					pcall(function()
						local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
						if hum then hum.Health = 0 end
					end)
				end
			})

			-- CONFIG TAB
			ConfigTab:Input({
				Title = "Config Name",
				Desc = "Type a name for your config",
				Value = ConfigNameInput,
				Placeholder = "preset_1",
				Callback = function(txt)
					ConfigNameInput = tostring(txt or "")
				end
			})

			local configStatusEl = ConfigTab:Paragraph({
				Title = "Selected Config",
				Desc = SelectedConfigName and ("Selected: " .. SelectedConfigName .. "  |  Tap a config below and press Load") or "No config selected yet. Save one or tap below."
			})

			local configBarDropdown = ConfigTab:Dropdown({
				Title = "Saved Configs Bar",
				Desc = "Tap to choose a saved config, then press Load",
				Values = { "(empty)" },
				Value = "(empty)",
				Callback = function(val)
					local chosen = tostring(val or "")
					if chosen ~= "" and chosen ~= "(empty)" and SavedConfigsMap[chosen] then
						SelectedConfigName = chosen
						ConfigNameInput = chosen
						pcall(function()
							if configStatusEl and configStatusEl.SetDesc then
								configStatusEl:SetDesc("Selected: " .. chosen .. "  |  Press Load to apply")
							end
						end)
					end
				end
			})

			local configChipsParagraph = ConfigTab:Paragraph({
				Title = "Configs List",
				Desc = "Saved configs will appear here"
			})

			RefreshConfigBarFn = function()
				local names = {}
				for cfgName in pairs(SavedConfigsMap) do
					table.insert(names, cfgName)
				end
				table.sort(names)

				if #names == 0 then
					pcall(function()
						if configBarDropdown and configBarDropdown.Refresh then
							configBarDropdown:Refresh({ "(empty)" }, "(empty)")
						end
						if configChipsParagraph and configChipsParagraph.SetDesc then
							configChipsParagraph:SetDesc("No configs saved yet")
						end
					end)
					return
				end

				if not SelectedConfigName or not SavedConfigsMap[SelectedConfigName] then
					SelectedConfigName = names[1]
				end

				local chipLines = {}
				for _, n in ipairs(names) do
					local prefix = (n == SelectedConfigName) and "[SELECTED] " or "• "
					table.insert(chipLines, prefix .. n)
				end

				pcall(function()
					if configBarDropdown and configBarDropdown.Refresh then
						configBarDropdown:Refresh(names, SelectedConfigName)
					end
					if configChipsParagraph and configChipsParagraph.SetDesc then
						configChipsParagraph:SetDesc(table.concat(chipLines, "   |   "))
					end
					if configStatusEl and configStatusEl.SetDesc then
						configStatusEl:SetDesc("Selected: " .. tostring(SelectedConfigName) .. "  |  Ready to Load")
					end
				end)
			end

			ConfigTab:Button({
				Title = "Save Config",
				Desc = "Save current settings under typed name",
				Callback = function()
					local savedName = saveConfigByName(ConfigNameInput)
					pcall(function()
						if configStatusEl and configStatusEl.SetDesc then
							configStatusEl:SetDesc("Saved & Selected: " .. savedName .. "  |  Tap Load anytime")
						end
					end)
				end
			})

			ConfigTab:Button({
				Title = "Load Config",
				Desc = "Apply selected config from bar below",
				Callback = function()
					local targetName = SelectedConfigName or sanitizeConfigName(ConfigNameInput)
					local data = SavedConfigsMap[targetName]
					if data then
						SelectedConfigName = targetName
						applyConfigSnapshot(data)
						if SyncUiFromConfigFn then
							SyncUiFromConfigFn()
						end
						pcall(function()
							if configStatusEl and configStatusEl.SetDesc then
								configStatusEl:SetDesc("Loaded config: " .. targetName)
							end
						end)
					else
						pcall(function()
							if configStatusEl and configStatusEl.SetDesc then
								configStatusEl:SetDesc("Config not found: " .. tostring(targetName))
							end
						end)
					end
				end
			})

			RefreshConfigBarFn()
		end
	else
		warn("[" .. SCRIPT_TITLE .. "] Failed to load WindUI library.")
	end

	-- ================= CLEANUP =================
	local function cleanup()
		pcall(function() RunService:UnbindFromRenderStep("NexxwarreStretchBind") end)
		pcall(function() workspace.Gravity = OriginalGravity end)
		pcall(function()
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.Anchored = false end
		end)
		pcall(function()
			local g = resolveGuiParent()
			for _, desc in ipairs(g:GetDescendants()) do
				if desc.Name == "NexxwarreTitleBadgeN" then
					desc:Destroy()
				end
			end
		end)
		for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
		table.clear(Connections)

		for ball in pairs(Balls) do killBall(ball) end
		for char, e in pairs(EspEntries) do
			if e.box2D then for _, ln in ipairs(e.box2D) do safeRemoveDrawing(ln) end end
			if e.corners then for _, ln in ipairs(e.corners) do safeRemoveDrawing(ln) end end
			if e.box3D then for _, ln in ipairs(e.box3D) do safeRemoveDrawing(ln) end end
			safeRemoveDrawing(e.spineUpper); safeRemoveDrawing(e.spineLower)
			safeRemoveDrawing(e.hipLine); safeRemoveDrawing(e.shoulderLine)
			safeRemoveDrawing(e.headDot); safeRemoveDrawing(e.headRing)
			safeRemoveDrawing(e.hpBg); safeRemoveDrawing(e.hpBar); safeRemoveDrawing(e.infoText)
			EspEntries[char] = nil
		end
		for plr in pairs(OffscreenArrows) do removeOffscreenArrow(plr) end
		for key in pairs(ChamsHighlights) do removeChamsForKey(key) end
		for plr, dot in pairs(RadarDots) do safeRemoveDrawing(dot); RadarDots[plr] = nil end

		safeRemoveDrawing(xhairOuterCircle); safeRemoveDrawing(xhairInnerCircle)
		for i = 1, MAX_XHAIR_LINES do safeRemoveDrawing(xhairLines[i]) end
		for i = 1, MAX_XHAIR_DOTS do safeRemoveDrawing(xhairDots[i]) end

		safeRemoveDrawing(hitFlashTop); safeRemoveDrawing(hitFlashBot); safeRemoveDrawing(hitFlashLeft); safeRemoveDrawing(hitFlashRight)
		safeRemoveDrawing(fovOuter); safeRemoveDrawing(fovMain)
		safeRemoveDrawing(chTop); safeRemoveDrawing(chBot); safeRemoveDrawing(chLeft); safeRemoveDrawing(chRight); safeRemoveDrawing(chCenter)
		safeRemoveDrawing(frameTop); safeRemoveDrawing(frameBot); safeRemoveDrawing(frameLeft); safeRemoveDrawing(frameRight)
		safeRemoveDrawing(radarCircle); safeRemoveDrawing(radarBorder); safeRemoveDrawing(radarSelfDot)
		safeRemoveDrawing(groundRingOuter); safeRemoveDrawing(groundRingInner)
		safeRemoveDrawing(winEdgeTop); safeRemoveDrawing(winEdgeBot); safeRemoveDrawing(winEdgeLeft); safeRemoveDrawing(winEdgeRight)
		safeRemoveDrawing(winEdgeInnerTop); safeRemoveDrawing(winEdgeInnerBot); safeRemoveDrawing(winEdgeInnerLeft); safeRemoveDrawing(winEdgeInnerRight)
		safeRemoveDrawing(compassLine); safeRemoveDrawing(compassTick); safeRemoveDrawing(compassText)
		safeRemoveDrawing(snapLine); safeRemoveDrawing(snapDot)
		safeRemoveDrawing(aimRingCircle)
		safeRemoveDrawing(watermarkText)

		pcall(function()
			if WorldMultiPart then WorldMultiPart:Destroy() end
			if WorldSnowPart then WorldSnowPart:Destroy() end
			if WorldMotesPart then WorldMotesPart:Destroy() end
			if AmbientCCRef then AmbientCCRef:Destroy() end
			if SkyMoodCCRef then SkyMoodCCRef:Destroy() end
			if CustomSkyRef then CustomSkyRef:Destroy() end
			if BloomRef then BloomRef:Destroy() end
			if SunRaysRef then SunRaysRef:Destroy() end
			if WindowRef and WindowRef.Destroy then WindowRef:Destroy() end
		end)

		restoreFog(); restoreAtmosphere(); restoreSkyMood(); restoreScreenFov()
	end

	genv[STATE_KEY] = {
		cleanup = cleanup,
		config = Config
	}
end

promptDisclaimerAndKey(startNexxwarreHub)