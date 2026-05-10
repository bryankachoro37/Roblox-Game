-- HackMentalClient.client.lua
-- StarterPlayerScripts
-- Substitua tudo

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local startHack = remotes:WaitForChild("StartHack")
local hackResult = remotes:WaitForChild("HackResult")
local cooldownNotify = remotes:WaitForChild("HackCooldown")
local hackProgress = remotes:WaitForChild("HackProgress")

print("🧠 HackMentalClient v7 carregado!")

-- ==============================================
-- SONS
-- ==============================================
local SOUNDS = {
	Click       = "rbxasset://sounds/electronicpingshort.wav",
	Wrong       = "rbxasset://sounds/uuhhh.mp3",
	Success     = "rbxasset://sounds/victory.wav",
	Fail        = "rbxasset://sounds/uuhhh.mp3",

	SeqClick    = "rbxasset://sounds/electronicpingshort.wav",
	SeqCorrect  = "rbxasset://sounds/bell.wav",

	MemBlink    = "rbxasset://sounds/clickfast.wav",
	MemCorrect  = "rbxasset://sounds/bell.wav",

	TgtPop      = "rbxasset://sounds/pop_mid_up.wav",
	TgtBomb     = "rbxasset://sounds/impact_explosion.mp3",

	CodeKey     = "rbxasset://sounds/electronicpingshort.wav",
	CodeOk      = "rbxasset://sounds/victory.wav",
	CodeBad     = "rbxasset://sounds/uuhhh.mp3",

	SliderTick  = "rbxasset://sounds/clickfast.wav",
	SliderHit   = "rbxasset://sounds/bell.wav",
	SliderMiss  = "rbxasset://sounds/uuhhh.mp3",
}

local soundCache = {}

local function getSound(id)
	if soundCache[id] then return soundCache[id] end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = 0.25
	s.Parent = SoundService
	soundCache[id] = s
	return s
end

task.spawn(function()
	local toLoad = {}
	for _, id in pairs(SOUNDS) do
		local s = getSound(id)
		table.insert(toLoad, s)
	end
	pcall(function()
		ContentProvider:PreloadAsync(toLoad)
	end)
end)

local function playSound(id, volume, pitch)
	local original = getSound(id)
	local s = original:Clone()
	s.Volume = volume or 0.25
	s.PlaybackSpeed = pitch or 1
	s.Parent = SoundService
	s:Play()
	game:GetService("Debris"):AddItem(s, 4)
end

local timerConnection = nil
local distanceConnection = nil
local resultSent = false
local puzzleActive = false
local currentBrainrot = nil
local totalSteps = 0
local stepsDone = 0

local function reportProgress()
	if totalSteps <= 0 then return end
	local intensity = math.clamp(stepsDone / totalSteps, 0, 1)
	hackProgress:FireServer("Intensity", intensity)
end

local function disconnectAll()
	if timerConnection then
		timerConnection:Disconnect()
		timerConnection = nil
	end
	if distanceConnection then
		distanceConnection:Disconnect()
		distanceConnection = nil
	end
end

-- ==============================================
-- TOAST
-- ==============================================
local toastGui = Instance.new("ScreenGui")
toastGui.Name = "HackToastGui"
toastGui.ResetOnSpawn = false
toastGui.Parent = playerGui

local toastFrame = Instance.new("Frame")
toastFrame.Size = UDim2.new(0, 360, 0, 70)
toastFrame.Position = UDim2.new(0.5, 0, 0.18, 0)
toastFrame.AnchorPoint = Vector2.new(0.5, 0)
toastFrame.BackgroundColor3 = Color3.fromRGB(30, 10, 50)
toastFrame.Visible = false
toastFrame.Parent = toastGui
local tc = Instance.new("UICorner", toastFrame); tc.CornerRadius = UDim.new(0, 14)
local ts = Instance.new("UIStroke", toastFrame); ts.Thickness = 3; ts.Color = Color3.fromRGB(180, 60, 255)
local toastLabel = Instance.new("TextLabel")
toastLabel.Size = UDim2.new(1, -20, 1, -20)
toastLabel.Position = UDim2.new(0, 10, 0, 10)
toastLabel.BackgroundTransparency = 1
toastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
toastLabel.TextScaled = true
toastLabel.Font = Enum.Font.GothamBold
toastLabel.Parent = toastFrame

local function showToast(text, color)
	toastFrame.Visible = true
	toastFrame.BackgroundTransparency = 0
	toastLabel.TextTransparency = 0
	toastLabel.Text = text
	ts.Color = color or Color3.fromRGB(180, 60, 255)
	task.spawn(function()
		task.wait(2.2)
		TweenService:Create(toastFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
		local t2 = TweenService:Create(toastLabel, TweenInfo.new(0.25), {TextTransparency = 1})
		t2:Play()
		t2.Completed:Wait()
		toastFrame.Visible = false
		toastFrame.BackgroundTransparency = 0
		toastLabel.TextTransparency = 0
	end)
end

-- ==============================================
-- COOLDOWN GUI
-- ==============================================
local cooldownGui = Instance.new("ScreenGui")
cooldownGui.Name = "HackCooldownGui"
cooldownGui.ResetOnSpawn = false
cooldownGui.IgnoreGuiInset = true
cooldownGui.Parent = playerGui

local cdFrame = Instance.new("Frame")
cdFrame.Size = UDim2.new(0, 420, 0, 110)
cdFrame.Position = UDim2.new(0.5, 0, 0, -150)
cdFrame.AnchorPoint = Vector2.new(0.5, 0)
cdFrame.BackgroundColor3 = Color3.fromRGB(40, 10, 25)
cdFrame.BorderSizePixel = 0
cdFrame.Parent = cooldownGui
local cdC = Instance.new("UICorner", cdFrame); cdC.CornerRadius = UDim.new(0, 16)
local cdS = Instance.new("UIStroke", cdFrame); cdS.Thickness = 3; cdS.Color = Color3.fromRGB(255, 90, 110)

local cdGrad = Instance.new("UIGradient", cdFrame)
cdGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 15, 40)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 5, 18)),
}
cdGrad.Rotation = 90

local cdIcon = Instance.new("TextLabel")
cdIcon.Size = UDim2.new(0, 80, 0, 80)
cdIcon.Position = UDim2.new(0, 10, 0.5, 0)
cdIcon.AnchorPoint = Vector2.new(0, 0.5)
cdIcon.BackgroundTransparency = 1
cdIcon.Text = "⏳"
cdIcon.TextScaled = true
cdIcon.Font = Enum.Font.FredokaOne
cdIcon.Parent = cdFrame

local cdTitle = Instance.new("TextLabel")
cdTitle.Size = UDim2.new(1, -110, 0, 30)
cdTitle.Position = UDim2.new(0, 100, 0, 12)
cdTitle.BackgroundTransparency = 1
cdTitle.TextColor3 = Color3.fromRGB(255, 200, 200)
cdTitle.Text = "Sua mente foi bloqueada!"
cdTitle.TextScaled = true
cdTitle.Font = Enum.Font.FredokaOne
cdTitle.TextXAlignment = Enum.TextXAlignment.Left
cdTitle.Parent = cdFrame

local cdSub = Instance.new("TextLabel")
cdSub.Size = UDim2.new(1, -110, 0, 22)
cdSub.Position = UDim2.new(0, 100, 0, 44)
cdSub.BackgroundTransparency = 1
cdSub.TextColor3 = Color3.fromRGB(230, 220, 230)
cdSub.Text = "..."
cdSub.TextScaled = true
cdSub.Font = Enum.Font.GothamBold
cdSub.TextXAlignment = Enum.TextXAlignment.Left
cdSub.Parent = cdFrame

local cdBarBg = Instance.new("Frame")
cdBarBg.Size = UDim2.new(1, -120, 0, 14)
cdBarBg.Position = UDim2.new(0, 100, 1, -28)
cdBarBg.BackgroundColor3 = Color3.fromRGB(20, 10, 20)
cdBarBg.BorderSizePixel = 0
cdBarBg.Parent = cdFrame
local cdBarBgC = Instance.new("UICorner", cdBarBg); cdBarBgC.CornerRadius = UDim.new(0, 8)

local cdBar = Instance.new("Frame")
cdBar.Size = UDim2.new(1, 0, 1, 0)
cdBar.BackgroundColor3 = Color3.fromRGB(255, 90, 110)
cdBar.BorderSizePixel = 0
cdBar.Parent = cdBarBg
local cdBarC = Instance.new("UICorner", cdBar); cdBarC.CornerRadius = UDim.new(0, 8)

local cdActive = false

local function showCooldownGui(seconds, brainrotName, reason)
	cdActive = true
	if reason == "global" then
		cdTitle.Text = "Captura concluída!"
		cdSub.Text = "Aguarde para capturar outro brainrot"
		cdIcon.Text = "🧠"
		cdS.Color = Color3.fromRGB(120, 220, 255)
		cdBar.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
	elseif reason == "toofar" then
		cdTitle.Text = "Você fugiu do alvo!"
		cdSub.Text = brainrotName .. " escapou"
		cdIcon.Text = "🚫"
		cdS.Color = Color3.fromRGB(255, 180, 80)
		cdBar.BackgroundColor3 = Color3.fromRGB(255, 180, 80)
	elseif reason == "cancel" then
		cdTitle.Text = "Hack cancelado"
		cdSub.Text = "Pequeno cooldown anti-spam"
		cdIcon.Text = "❌"
		cdS.Color = Color3.fromRGB(200, 200, 200)
		cdBar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	else
		cdTitle.Text = "Sua mente foi hackeada!"
		cdSub.Text = brainrotName .. " travou seu cérebro"
		cdIcon.Text = "💀"
		cdS.Color = Color3.fromRGB(255, 90, 110)
		cdBar.BackgroundColor3 = Color3.fromRGB(255, 90, 110)
	end

	cdBar.Size = UDim2.new(1, 0, 1, 0)
	TweenService:Create(cdFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 30)
	}):Play()

	task.spawn(function()
		local startT = os.clock()
		while os.clock() - startT < seconds and cdActive do
			local left = math.max(0, seconds - (os.clock() - startT))
			local pct = left / seconds
			cdSub.Text = string.format("%s • %ds", brainrotName, math.ceil(left))
			cdBar.Size = UDim2.new(pct, 0, 1, 0)
			task.wait(0.1)
		end
		cdActive = false
		TweenService:Create(cdFrame, TweenInfo.new(0.3), {
			Position = UDim2.new(0.5, 0, 0, -150)
		}):Play()
	end)
end

cooldownNotify.OnClientEvent:Connect(function(seconds, brainrotName, reason)
	showCooldownGui(seconds, brainrotName or "Brainrot", reason or "fail")
end)

-- ==============================================
-- GUI DO HACK
-- ==============================================
local hackGui = Instance.new("ScreenGui")
hackGui.Name = "HackMentalGui"
hackGui.ResetOnSpawn = false
hackGui.Enabled = false
hackGui.IgnoreGuiInset = true
hackGui.Parent = playerGui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 0.35
backdrop.Parent = hackGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.78, 0, 0.72, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = hackGui
local mfC = Instance.new("UICorner", mainFrame); mfC.CornerRadius = UDim.new(0, 24)
local mfS = Instance.new("UIStroke", mainFrame); mfS.Thickness = 4; mfS.Color = Color3.fromRGB(50, 200, 255)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -90, 0, 60)
header.Position = UDim2.new(0, 20, 0, 10)
header.BackgroundTransparency = 1
header.Text = "🧠 HACK MENTAL ATIVO 🧠"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.TextScaled = true
header.Font = Enum.Font.FredokaOne
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = mainFrame

local brainrotLabel = Instance.new("TextLabel")
brainrotLabel.Size = UDim2.new(1, -40, 0, 30)
brainrotLabel.Position = UDim2.new(0, 20, 0, 72)
brainrotLabel.BackgroundTransparency = 1
brainrotLabel.Text = "🎯 ???"
brainrotLabel.TextColor3 = Color3.fromRGB(180, 255, 100)
brainrotLabel.TextScaled = true
brainrotLabel.Font = Enum.Font.GothamBold
brainrotLabel.TextXAlignment = Enum.TextXAlignment.Left
brainrotLabel.Parent = mainFrame

local badgesFrame = Instance.new("Frame")
badgesFrame.Size = UDim2.new(1, -40, 0, 40)
badgesFrame.Position = UDim2.new(0, 20, 0, 106)
badgesFrame.BackgroundTransparency = 1
badgesFrame.Parent = mainFrame
local bL = Instance.new("UIListLayout", badgesFrame)
bL.FillDirection = Enum.FillDirection.Horizontal
bL.Padding = UDim.new(0, 8)

local function makeBadge()
	local b = Instance.new("TextLabel")
	b.Size = UDim2.new(0, 140, 1, 0)
	b.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	b.Parent = badgesFrame
	local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0, 10)
	return b
end

local levelBadge = makeBadge()
local chanceBadge = makeBadge()
local typeBadge = makeBadge()

local timerFrame = Instance.new("Frame")
timerFrame.Size = UDim2.new(1, -40, 0, 46)
timerFrame.Position = UDim2.new(0, 20, 0, 156)
timerFrame.BackgroundColor3 = Color3.fromRGB(35, 20, 60)
timerFrame.BorderSizePixel = 0
timerFrame.Parent = mainFrame
local tfC = Instance.new("UICorner", timerFrame); tfC.CornerRadius = UDim.new(0, 14)

local timerBar = Instance.new("Frame")
timerBar.Size = UDim2.new(1, 0, 1, 0)
timerBar.BackgroundColor3 = Color3.fromRGB(255, 220, 100)
timerBar.BorderSizePixel = 0
timerBar.Parent = timerFrame
local tbC = Instance.new("UICorner", timerBar); tbC.CornerRadius = UDim.new(0, 14)

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 1, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "⏱️ 20s"
timerLabel.TextColor3 = Color3.fromRGB(20, 20, 30)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.FredokaOne
timerLabel.Parent = timerFrame

local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(1, -40, 0, 34)
instructions.Position = UDim2.new(0, 20, 0, 208)
instructions.BackgroundTransparency = 1
instructions.Text = "..."
instructions.TextColor3 = Color3.fromRGB(255, 255, 255)
instructions.TextScaled = true
instructions.Font = Enum.Font.GothamBold
instructions.Parent = mainFrame

local puzzleFrame = Instance.new("Frame")
puzzleFrame.Size = UDim2.new(1, -40, 1, -260)
puzzleFrame.Position = UDim2.new(0, 20, 0, 248)
puzzleFrame.BackgroundColor3 = Color3.fromRGB(18, 10, 35)
puzzleFrame.BorderSizePixel = 0
puzzleFrame.ClipsDescendants = true
puzzleFrame.Parent = mainFrame
local pfC = Instance.new("UICorner", puzzleFrame); pfC.CornerRadius = UDim.new(0, 18)

local exitButton = Instance.new("TextButton")
exitButton.Size = UDim2.new(0, 48, 0, 48)
exitButton.Position = UDim2.new(1, -58, 0, 12)
exitButton.BackgroundColor3 = Color3.fromRGB(255, 70, 90)
exitButton.Text = "X"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.TextSize = 24
exitButton.Font = Enum.Font.GothamBlack
exitButton.ZIndex = 20
exitButton.Parent = mainFrame
local exC = Instance.new("UICorner", exitButton); exC.CornerRadius = UDim.new(1, 0)

local function closeHackGui()
	disconnectAll()
	puzzleActive = false
	resultSent = false
	currentBrainrot = nil
	stepsDone = 0
	totalSteps = 0
	puzzleFrame:ClearAllChildren()
	hackGui.Enabled = false
	hackProgress:FireServer("Stop")
end

local function sendResult(result)
	if resultSent then return end
	resultSent = true
	hackResult:FireServer(result)
end

exitButton.MouseButton1Click:Connect(function()
	if puzzleActive then
		sendResult("Cancel")
		showToast("❌ Hack cancelado", Color3.fromRGB(255, 100, 100))
	end
	closeHackGui()
end)

local function startTimer(seconds)
	local startTime = os.clock()
	timerConnection = RunService.Heartbeat:Connect(function()
		if not puzzleActive then return end
		local elapsed = os.clock() - startTime
		local remaining = math.max(0, seconds - elapsed)
		local pct = remaining / seconds
		timerLabel.Text = "⏱️ " .. math.ceil(remaining) .. "s"
		timerBar.Size = UDim2.new(pct, 0, 1, 0)
		if pct < 0.3 then timerBar.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		elseif pct < 0.6 then timerBar.BackgroundColor3 = Color3.fromRGB(255, 180, 80)
		else timerBar.BackgroundColor3 = Color3.fromRGB(255, 220, 100) end

		if remaining <= 0 then
			sendResult("Fail")
			showToast("⏰ Tempo esgotado!", Color3.fromRGB(255, 100, 100))
			closeHackGui()
		end
	end)
end

local function startDistanceWatcher(brainrot)
	local accum = 0
	distanceConnection = RunService.Heartbeat:Connect(function(dt)
		if not puzzleActive then return end
		accum += dt
		if accum < 0.2 then return end
		accum = 0

		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local broot = brainrot and brainrot.Parent
			and (brainrot.PrimaryPart or brainrot:FindFirstChild("HumanoidRootPart"))

		-- ❌ REMOVIDO: showToast "Esse brainrot sumiu!"
		-- A Cooldown GUI já cobre o caso "toofar" enviado pelo servidor
		if not brainrot or not brainrot.Parent or not broot then
			closeHackGui()
			return
		end

		if hrp then
			local dist = (hrp.Position - broot.Position).Magnitude
			if dist > 35 then
				sendResult("TooFar")
				-- ❌ REMOVIDO: showToast "Você foi longe demais!"
				-- A Cooldown GUI (reason = "toofar") já exibe o feedback visual
				closeHackGui()
			end
		end
	end)
end

local function distributePositions(count)
	local positions = {}
	local attempts = 0
	while #positions < count and attempts < 300 do
		local x = math.random(10, 90) / 100
		local y = math.random(15, 85) / 100
		local valid = true
		for _, p in ipairs(positions) do
			if math.abs(p.X - x) < 0.12 and math.abs(p.Y - y) < 0.17 then
				valid = false; break
			end
		end
		if valid then table.insert(positions, Vector2.new(x, y)) end
		attempts += 1
	end
	return positions
end

local function createRoundButton(text, posX, posY, size)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, size or 78, 0, size or 78)
	btn.Position = UDim2.new(posX, 0, posY, 0)
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.BackgroundColor3 = Color3.fromRGB(85, 50, 160)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Font = Enum.Font.FredokaOne
	btn.AutoButtonColor = false
	btn.Parent = puzzleFrame
	local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(1, 0)
	local s = Instance.new("UIStroke", btn); s.Color = Color3.fromRGB(200, 160, 255); s.Thickness = 3
	return btn, s
end

-- =================== PUZZLES ===================

local function puzzleSequence(level)
	typeBadge.Text = "🔢 Sequência"
	instructions.Text = "Clique nos números em ordem crescente"

	local count = math.clamp(4 + math.floor(level / 6), 4, 9)
	totalSteps = count; stepsDone = 0; reportProgress()

	local pool = {}
	for i = 1, 30 + level * 2 do table.insert(pool, i) end
	for i = #pool, 2, -1 do
		local j = math.random(1, i); pool[i], pool[j] = pool[j], pool[i]
	end

	local target = {}
	for i = 1, count do table.insert(target, pool[i]) end
	table.sort(target)

	local display = table.clone(target)
	for i = #display, 2, -1 do
		local j = math.random(1, i); display[i], display[j] = display[j], display[i]
	end

	local positions = distributePositions(count)
	local expected = 1
	local allButtons = {}

	for i, num in ipairs(display) do
		local p = positions[i]
		local btn, stroke = createRoundButton(tostring(num), p.X, p.Y, 78)

		btn.MouseButton1Click:Connect(function()
			if not puzzleActive then return end
			playSound(SOUNDS.SeqClick, 0.18)

			if num == target[expected] then
				btn.BackgroundColor3 = Color3.fromRGB(80, 255, 130)
				stroke.Color = Color3.fromRGB(120, 255, 170)
				playSound(SOUNDS.SeqCorrect, 0.22, 1 + (expected * 0.05))
				expected += 1
				stepsDone = expected - 1
				reportProgress()
				if expected > #target then
					sendResult("Success")
					hackProgress:FireServer("Capture")
					closeHackGui()
				end
			else
				btn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
				stroke.Color = Color3.fromRGB(255, 140, 140)
				playSound(SOUNDS.Wrong, 0.22, 0.85)
				expected = 1; stepsDone = 0; reportProgress()
				task.delay(0.35, function()
					for _, e in ipairs(allButtons) do
						if e.btn.Parent then
							e.btn.BackgroundColor3 = Color3.fromRGB(85, 50, 160)
							e.stroke.Color = Color3.fromRGB(200, 160, 255)
						end
					end
				end)
			end
		end)
		table.insert(allButtons, {btn = btn, stroke = stroke})
	end
end

local function puzzleMemory(level)
	typeBadge.Text = "🧠 Memória"
	instructions.Text = "Memorize a ordem e repita"

	local total = math.clamp(4 + math.floor(level / 10), 4, 6)
	local seqLen = math.clamp(3 + math.floor(level / 6), 3, 8)
	totalSteps = seqLen; stepsDone = 0; reportProgress()

	local nodes = {}
	local cols = math.ceil(math.sqrt(total))
	local rows = math.ceil(total / cols)
	local idx = 1
	for r = 1, rows do
		for c = 1, cols do
			if idx > total then break end
			local x = (c - 0.5) / cols
			local y = (r - 0.5) / rows
			local btn, stroke = createRoundButton(tostring(idx), x, y, 74)
			btn:SetAttribute("Index", idx)
			table.insert(nodes, {btn = btn, stroke = stroke})
			idx += 1
		end
	end

	local sequence = {}
	for i = 1, seqLen do table.insert(sequence, math.random(1, total)) end

	task.spawn(function()
		instructions.Text = "👀 Memorize..."
		task.wait(0.8)

		for _, sIdx in ipairs(sequence) do
			local n = nodes[sIdx]
			if n and n.btn.Parent then
				n.btn.BackgroundColor3 = Color3.fromRGB(255, 220, 100)
				playSound(SOUNDS.MemBlink, 0.16, 1 + sIdx * 0.05)
				task.wait(0.45)
				n.btn.BackgroundColor3 = Color3.fromRGB(85, 50, 160)
				task.wait(0.15)
			end
		end
		if not puzzleActive then return end
		instructions.Text = "🎯 Agora repita"

		local expected = 1
		for _, n in ipairs(nodes) do
			n.btn.MouseButton1Click:Connect(function()
				if not puzzleActive then return end
				playSound(SOUNDS.Click, 0.15)

				if n.btn:GetAttribute("Index") == sequence[expected] then
					n.btn.BackgroundColor3 = Color3.fromRGB(80, 255, 130)
					playSound(SOUNDS.MemCorrect, 0.2, 1.1)
					task.delay(0.2, function()
						if n.btn.Parent then
							n.btn.BackgroundColor3 = Color3.fromRGB(85, 50, 160)
						end
					end)
					expected += 1
					stepsDone = expected - 1; reportProgress()
					if expected > #sequence then
						sendResult("Success")
						hackProgress:FireServer("Capture")
						closeHackGui()
					end
				else
					playSound(SOUNDS.Wrong, 0.22, 0.8)
					n.btn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
					task.delay(0.3, function()
						if n.btn.Parent then n.btn.BackgroundColor3 = Color3.fromRGB(85, 50, 160) end
					end)
					expected = 1; stepsDone = 0; reportProgress()
				end
			end)
		end
	end)
end

local function puzzleTargets(level)
	typeBadge.Text = "🎯 Reflexo"
	instructions.Text = "Clique nos verdes, evite os vermelhos"

	local hitsNeeded = math.clamp(8 + math.floor(level / 4), 8, 18)
	local hits = 0
	totalSteps = hitsNeeded; stepsDone = 0; reportProgress()

	local counter = Instance.new("TextLabel")
	counter.Size = UDim2.new(0, 180, 0, 36)
	counter.Position = UDim2.new(0.5, 0, 0, 8)
	counter.AnchorPoint = Vector2.new(0.5, 0)
	counter.BackgroundColor3 = Color3.fromRGB(30, 20, 60)
	counter.TextColor3 = Color3.fromRGB(255, 255, 255)
	counter.TextScaled = true
	counter.Font = Enum.Font.GothamBold
	counter.Text = hits .. " / " .. hitsNeeded
	counter.Parent = puzzleFrame
	local cc = Instance.new("UICorner", counter); cc.CornerRadius = UDim.new(0, 10)

	task.spawn(function()
		while puzzleActive do
			local isBomb = math.random() < math.min(0.2 + level * 0.005, 0.4)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 64, 0, 64)
			btn.Position = UDim2.new(math.random(10, 90) / 100, 0, math.random(18, 88) / 100, 0)
			btn.AnchorPoint = Vector2.new(0.5, 0.5)
			btn.BackgroundColor3 = isBomb and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 130)
			btn.Text = isBomb and "💀" or "🎯"
			btn.TextScaled = true
			btn.Font = Enum.Font.FredokaOne
			btn.Parent = puzzleFrame
			local bc = Instance.new("UICorner", btn); bc.CornerRadius = UDim.new(1, 0)

			btn.MouseButton1Click:Connect(function()
				if not puzzleActive then return end
				if isBomb then
					hits = math.max(0, hits - 2)
					playSound(SOUNDS.TgtBomb, 0.22, 1)
				else
					hits += 1
					playSound(SOUNDS.TgtPop, 0.18, 1.1)
				end
				stepsDone = hits; reportProgress()
				counter.Text = hits .. " / " .. hitsNeeded
				btn:Destroy()

				if hits >= hitsNeeded then
					sendResult("Success")
					hackProgress:FireServer("Capture")
					closeHackGui()
				end
			end)

			task.delay(math.max(0.7, 1.5 - level * 0.015), function()
				if btn.Parent then btn:Destroy() end
			end)

			task.wait(math.max(0.28, 0.7 - level * 0.01))
		end
	end)
end

local function puzzleCode(level)
	typeBadge.Text = "🔐 Código"
	instructions.Text = "Digite o código exibido"

	local codeLength = math.clamp(3 + math.floor(level / 9), 3, 6)
	totalSteps = codeLength; stepsDone = 0; reportProgress()

	local code = ""
	for _ = 1, codeLength do code ..= tostring(math.random(0, 9)) end

	local codeBox = Instance.new("TextLabel")
	codeBox.Size = UDim2.new(0.54, 0, 0, 58)
	codeBox.Position = UDim2.new(0.5, 0, 0, 12)
	codeBox.AnchorPoint = Vector2.new(0.5, 0)
	codeBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	codeBox.Text = code
	codeBox.TextColor3 = Color3.fromRGB(80, 255, 120)
	codeBox.TextScaled = true
	codeBox.Font = Enum.Font.Code
	codeBox.Parent = puzzleFrame
	local cb1 = Instance.new("UICorner", codeBox); cb1.CornerRadius = UDim.new(0, 10)

	local typedBox = Instance.new("TextLabel")
	typedBox.Size = UDim2.new(0.54, 0, 0, 46)
	typedBox.Position = UDim2.new(0.5, 0, 0, 82)
	typedBox.AnchorPoint = Vector2.new(0.5, 0)
	typedBox.BackgroundColor3 = Color3.fromRGB(35, 25, 60)
	typedBox.Text = string.rep("_ ", codeLength)
	typedBox.TextColor3 = Color3.fromRGB(255, 220, 100)
	typedBox.TextScaled = true
	typedBox.Font = Enum.Font.FredokaOne
	typedBox.Parent = puzzleFrame
	local tb1 = Instance.new("UICorner", typedBox); tb1.CornerRadius = UDim.new(0, 10)

	task.delay(math.max(1.7, 4 - level * 0.05), function()
		if codeBox.Parent then
			codeBox.Text = string.rep("?", codeLength)
			codeBox.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
	end)

	local keypad = Instance.new("Frame")
	keypad.Size = UDim2.new(0, 240, 0, 240)
	keypad.Position = UDim2.new(0.5, 0, 1, -18)
	keypad.AnchorPoint = Vector2.new(0.5, 1)
	keypad.BackgroundTransparency = 1
	keypad.Parent = puzzleFrame

	local typed = ""
	local function refresh()
		local out = ""
		for i = 1, codeLength do
			local ch = string.sub(typed, i, i)
			if ch == "" then ch = "_" end
			out ..= ch .. " "
		end
		typedBox.Text = out
	end

	local function check()
		if #typed == codeLength then
			if typed == code then
				stepsDone = codeLength; reportProgress()
				playSound(SOUNDS.CodeOk, 0.3, 1.1)
				sendResult("Success")
				hackProgress:FireServer("Capture")
				closeHackGui()
			else
				typed = ""
				typedBox.Text = "❌ ERRADO!"
				stepsDone = 0; reportProgress()
				playSound(SOUNDS.CodeBad, 0.25, 0.8)
				task.delay(0.5, function() if typedBox.Parent then refresh() end end)
			end
		else
			stepsDone = #typed; reportProgress()
		end
	end

	local function makeKey(d, pos)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 70, 0, 50)
		btn.Position = pos
		btn.BackgroundColor3 = Color3.fromRGB(85, 50, 160)
		btn.Text = tostring(d)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextScaled = true
		btn.Font = Enum.Font.FredokaOne
		btn.Parent = keypad
		local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 10)
		btn.MouseButton1Click:Connect(function()
			if not puzzleActive or #typed >= codeLength then return end
			playSound(SOUNDS.CodeKey, 0.18)
			typed ..= tostring(d)
			refresh(); check()
		end)
	end

	for d = 1, 9 do
		local row = math.floor((d - 1) / 3)
		local col = (d - 1) % 3
		makeKey(d, UDim2.new(0, col * 80, 0, row * 60))
	end
	makeKey(0, UDim2.new(0, 80, 0, 180))
end

local function puzzleSlider(level)
	typeBadge.Text = "🎚️ Precisão"
	instructions.Text = "Pare na zona verde"

	local rounds = math.clamp(2 + math.floor(level / 18), 2, 4)
	totalSteps = rounds; stepsDone = 0; reportProgress()

	local currentRound = 0

	local function runRound()
		currentRound += 1
		if currentRound > rounds then
			sendResult("Success")
			hackProgress:FireServer("Capture")
			closeHackGui()
			return
		end
		stepsDone = currentRound - 1; reportProgress()

		puzzleFrame:ClearAllChildren()
		instructions.Text = string.format("🎚️ Rodada %d/%d", currentRound, rounds)

		local track = Instance.new("Frame")
		track.Size = UDim2.new(0.82, 0, 0, 50)
		track.Position = UDim2.new(0.5, 0, 0.42, 0)
		track.AnchorPoint = Vector2.new(0.5, 0.5)
		track.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
		track.Parent = puzzleFrame
		local trC = Instance.new("UICorner", track); trC.CornerRadius = UDim.new(0, 14)

		local zoneSize = math.max(0.11, 0.22 - ((level - 1) / 49) * 0.11)
		local zoneX = math.random(15, 85) / 100

		local zone = Instance.new("Frame")
		zone.Size = UDim2.new(zoneSize, 0, 1, 0)
		zone.Position = UDim2.new(zoneX - zoneSize / 2, 0, 0, 0)
		zone.BackgroundColor3 = Color3.fromRGB(80, 255, 130)
		zone.Parent = track
		local zoC = Instance.new("UICorner", zone); zoC.CornerRadius = UDim.new(0, 14)

		local pointer = Instance.new("Frame")
		pointer.Size = UDim2.new(0, 10, 1.25, 0)
		pointer.Position = UDim2.new(0, 0, 0.5, 0)
		pointer.AnchorPoint = Vector2.new(0.5, 0.5)
		pointer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		pointer.Parent = track

		local stopBtn = Instance.new("TextButton")
		stopBtn.Size = UDim2.new(0, 180, 0, 56)
		stopBtn.Position = UDim2.new(0.5, 0, 0.78, 0)
		stopBtn.AnchorPoint = Vector2.new(0.5, 0.5)
		stopBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 60)
		stopBtn.Text = "🛑 PARAR"
		stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		stopBtn.TextScaled = true
		stopBtn.Font = Enum.Font.FredokaOne
		stopBtn.Parent = puzzleFrame
		local sbC = Instance.new("UICorner", stopBtn); sbC.CornerRadius = UDim.new(0, 12)

		local moving = true
		local pos = 0
		local dir = 1
		local speed = 0.35 + ((level - 1) / 49) * 1.15
		local lastTick = 0

		local conn
		conn = RunService.Heartbeat:Connect(function(dt)
			if not puzzleActive or not moving then if conn then conn:Disconnect() end; return end
			pos += dir * speed * dt
			if pos >= 1 then pos = 1; dir = -1
			elseif pos <= 0 then pos = 0; dir = 1 end
			pointer.Position = UDim2.new(pos, 0, 0.5, 0)

			lastTick += dt
			if lastTick >= 0.18 then
				lastTick = 0
				playSound(SOUNDS.SliderTick, 0.07, 1.4)
			end
		end)

		stopBtn.MouseButton1Click:Connect(function()
			if not moving then return end
			moving = false
			if conn then conn:Disconnect() end

			local minHit = zoneX - zoneSize / 2
			local maxHit = zoneX + zoneSize / 2
			if pos >= minHit and pos <= maxHit then
				playSound(SOUNDS.SliderHit, 0.25, 1.1)
				task.delay(0.5, runRound)
			else
				playSound(SOUNDS.SliderMiss, 0.22, 0.8)
				sendResult("Fail")
				closeHackGui()
			end
		end)
	end
	runRound()
end

local function chooseMinigame(level)
	local pool = {"sequence", "targets"}
	if level >= 8 then table.insert(pool, "code") end
	if level >= 15 then
		table.insert(pool, "memory")
		table.insert(pool, "slider")
	end
	if level >= 30 then
		table.insert(pool, "memory")
		table.insert(pool, "slider")
		table.insert(pool, "code")
	end
	if level >= 45 then
		table.insert(pool, "memory")
		table.insert(pool, "slider")
		table.insert(pool, "slider")
	end
	return pool[math.random(1, #pool)]
end

local function startPuzzle(level)
	puzzleFrame:ClearAllChildren()
	puzzleActive = true; resultSent = false; stepsDone = 0; totalSteps = 0

	local timeLimit = math.max(11, math.floor(28 - level * 0.28))
	startTimer(timeLimit)

	local chosen = chooseMinigame(level)
	if chosen == "sequence" then puzzleSequence(level)
	elseif chosen == "memory" then puzzleMemory(level)
	elseif chosen == "targets" then puzzleTargets(level)
	elseif chosen == "code" then puzzleCode(level)
	elseif chosen == "slider" then puzzleSlider(level)
	end
end

startHack.OnClientEvent:Connect(function(data)
	if not data or not data.brainrot then return end
	local brainrot = data.brainrot
	local level = data.level or 1
	local captureChance = data.captureChance or 100

	disconnectAll()
	puzzleFrame:ClearAllChildren()
	resultSent = false
	puzzleActive = true
	currentBrainrot = brainrot

	brainrotLabel.Text = "🎯 " .. brainrot.Name
	levelBadge.Text = "⭐ Lv." .. level
	chanceBadge.Text = "🎯 " .. math.floor(captureChance) .. "%"
	typeBadge.Text = "..."

	if level <= 10 then levelBadge.TextColor3 = Color3.fromRGB(100, 255, 130)
	elseif level <= 25 then levelBadge.TextColor3 = Color3.fromRGB(255, 220, 100)
	elseif level <= 40 then levelBadge.TextColor3 = Color3.fromRGB(255, 130, 80)
	else levelBadge.TextColor3 = Color3.fromRGB(255, 80, 200) end

	hackGui.Enabled = true
	startDistanceWatcher(brainrot)
	startPuzzle(level)
end)

hackResult.OnClientEvent:Connect(function(result)
	disconnectAll()
	puzzleActive = false

	if result == "Success" then
		playSound(SOUNDS.Success, 0.3, 1.1)
		showToast("🎉 Brainrot capturado!", Color3.fromRGB(100, 255, 130))
	elseif result == "Stolen" then
		showToast("💀 Outro jogador capturou primeiro!", Color3.fromRGB(255, 180, 80))
		hackProgress:FireServer("Stop")
	elseif result == "TooFar" then
		-- ❌ REMOVIDO: showToast "Você foi longe demais!"
		-- ✅ O servidor dispara HackCooldown com reason="toofar"
		-- que exibe a Cooldown GUI — único feedback necessário
		hackProgress:FireServer("Stop")
	elseif result == "Cancel" then
		showToast("❌ Hack cancelado", Color3.fromRGB(255, 140, 140))
		hackProgress:FireServer("Stop")
	else
		playSound(SOUNDS.Fail, 0.25, 0.8)
		hackProgress:FireServer("Stop")
	end

	closeHackGui()
end)

print("🧠 HackMentalClient v7 pronto!")