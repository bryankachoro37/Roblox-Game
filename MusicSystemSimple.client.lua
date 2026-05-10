local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local musicPlaylist = {
	{id = "rbxassetid://1848354536", name = "Brainrot Theme 1"},
	{id = "rbxassetid://118037275799021", name = "Brainrot Theme 2"},
	{id = "rbxassetid://129981088770668", name = "Brainrot Theme 3"},
	{id = "rbxassetid://119689936141305", name = "Brainrot Theme 4"},
	{id = "rbxassetid://115316165615671", name = "Brainrot Theme 5"},
	{id = "rbxassetid://94391431805664", name = "Brainrot Theme 6"},
	{id = "rbxassetid://74942910483872", name = "Brainrot Theme 7"},
}

local soundGui, soundMenu, soundButton, currentSound
local isMusicPlaying = false
local isPaused = false
local currentTrackIndex = 1
local isMenuOpen = false
local currentVolume = 0.5
local currentTrackLabel
local playButton, pauseButton, stopButton

local function shufflePlaylist()
	for i = #musicPlaylist, 2, -1 do
		local j = math.random(i)
		musicPlaylist[i], musicPlaylist[j] = musicPlaylist[j], musicPlaylist[i]
	end
end

local function updateCurrentTrackDisplay(text)
	if currentTrackLabel then
		currentTrackLabel.Text = text
	end
end

local function playNextTrack()
	if not isMusicPlaying then return end
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
		currentSound = nil
	end
	if currentTrackIndex > #musicPlaylist then
		currentTrackIndex = 1
		shufflePlaylist()
	end
	local track = musicPlaylist[currentTrackIndex]
	currentTrackIndex += 1

	currentSound = Instance.new("Sound")
	currentSound.Name = "BackgroundMusic"
	currentSound.SoundId = track.id
	currentSound.Volume = currentVolume * 0.4
	currentSound.Looped = false
	currentSound.Parent = SoundService

	currentSound.Ended:Connect(function()
		task.wait(1)
		if isMusicPlaying then playNextTrack() end
	end)

	local ok = pcall(function() currentSound:Play() end)
	if ok then
		updateCurrentTrackDisplay("🎶 " .. track.name)
	else
		task.wait(0.5)
		playNextTrack()
	end
end

local function createSoundButton()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child.Name == "MusicButtonGui" then child:Destroy() end
	end

	local buttonGui = Instance.new("ScreenGui")
	buttonGui.Name = "MusicButtonGui"
	buttonGui.IgnoreGuiInset = true
	buttonGui.Parent = playerGui

	soundButton = Instance.new("TextButton")
	soundButton.Name = "MusicButton"
	soundButton.Size = UDim2.new(0, 56, 0, 56)
	soundButton.Position = UDim2.new(1, -68, 0, 130)
	soundButton.BackgroundColor3 = Color3.fromRGB(50, 0, 70)
	soundButton.BorderSizePixel = 0
	soundButton.Text = "🎵"
	soundButton.TextSize = 28
	soundButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	soundButton.Font = Enum.Font.GothamBold
	soundButton.Parent = buttonGui
	local c = Instance.new("UICorner", soundButton); c.CornerRadius = UDim.new(0, 16)
	local s = Instance.new("UIStroke", soundButton); s.Color = Color3.fromRGB(180, 60, 255); s.Thickness = 2

	soundButton.MouseEnter:Connect(function()
		TweenService:Create(soundButton, TweenInfo.new(0.15), {
			Size = UDim2.new(0, 64, 0, 64),
			BackgroundColor3 = Color3.fromRGB(80, 0, 110)
		}):Play()
	end)
	soundButton.MouseLeave:Connect(function()
		TweenService:Create(soundButton, TweenInfo.new(0.15), {
			Size = UDim2.new(0, 56, 0, 56),
			BackgroundColor3 = Color3.fromRGB(50, 0, 70)
		}):Play()
	end)
	soundButton.MouseButton1Click:Connect(function() openMusicMenu() end)
end

local function refreshButtons()
	if not playButton then return end
	if isMusicPlaying and not isPaused then
		playButton.Text = "▶️"
		playButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		pauseButton.Text = "⏸️ PAUSAR"
		pauseButton.BackgroundColor3 = Color3.fromRGB(220, 160, 50)
	elseif isPaused then
		playButton.Text = "▶️ RETOMAR"
		playButton.BackgroundColor3 = Color3.fromRGB(0, 170, 60)
		pauseButton.Text = "⏸️"
		pauseButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	else
		playButton.Text = "▶️ TOCAR"
		playButton.BackgroundColor3 = Color3.fromRGB(0, 170, 60)
		pauseButton.Text = "⏸️"
		pauseButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end
end

local function createMusicMenu()
	if soundGui then soundGui:Destroy() end

	soundGui = Instance.new("ScreenGui")
	soundGui.Name = "MusicMenuGui"
	soundGui.IgnoreGuiInset = true
	soundGui.Parent = playerGui

	soundMenu = Instance.new("Frame")
	soundMenu.Size = UDim2.new(0, 380, 0, 460)
	soundMenu.Position = UDim2.new(0.5, -190, 0.5, -230)
	soundMenu.BackgroundColor3 = Color3.fromRGB(25, 8, 45)
	soundMenu.BorderSizePixel = 0
	soundMenu.Visible = false
	soundMenu.Parent = soundGui
	local c = Instance.new("UICorner", soundMenu); c.CornerRadius = UDim.new(0, 18)
	local s = Instance.new("UIStroke", soundMenu); s.Color = Color3.fromRGB(180, 60, 255); s.Thickness = 3
	local g = Instance.new("UIGradient", soundMenu)
	g.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 12, 70)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 5, 30)),
	}
	g.Rotation = 90

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 0, 50)
	title.Position = UDim2.new(0, 20, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "🎵 PLAYER BRAINROT"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextScaled = true
	title.Font = Enum.Font.FredokaOne
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = soundMenu

	local closeX = Instance.new("TextButton")
	closeX.Size = UDim2.new(0, 36, 0, 36)
	closeX.Position = UDim2.new(1, -46, 0, 12)
	closeX.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
	closeX.Text = "X"
	closeX.TextColor3 = Color3.new(1, 1, 1)
	closeX.Font = Enum.Font.GothamBlack
	closeX.TextScaled = true
	closeX.Parent = soundMenu
	local cxC = Instance.new("UICorner", closeX); cxC.CornerRadius = UDim.new(1, 0)
	closeX.MouseButton1Click:Connect(function() closeMusicMenu() end)

	-- Card da música atual
	local trackCard = Instance.new("Frame")
	trackCard.Size = UDim2.new(1, -40, 0, 80)
	trackCard.Position = UDim2.new(0, 20, 0, 70)
	trackCard.BackgroundColor3 = Color3.fromRGB(40, 18, 70)
	trackCard.Parent = soundMenu
	local tcC = Instance.new("UICorner", trackCard); tcC.CornerRadius = UDim.new(0, 12)

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 60, 1, 0)
	icon.BackgroundTransparency = 1
	icon.Text = "🎶"
	icon.TextScaled = true
	icon.Font = Enum.Font.FredokaOne
	icon.Parent = trackCard

	currentTrackLabel = Instance.new("TextLabel")
	currentTrackLabel.Size = UDim2.new(1, -70, 1, -10)
	currentTrackLabel.Position = UDim2.new(0, 65, 0, 5)
	currentTrackLabel.BackgroundTransparency = 1
	currentTrackLabel.Text = "Nenhuma música tocando"
	currentTrackLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
	currentTrackLabel.TextScaled = true
	currentTrackLabel.Font = Enum.Font.GothamBold
	currentTrackLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentTrackLabel.Parent = trackCard

	-- Volume
	local volumeLabel = Instance.new("TextLabel")
	volumeLabel.Size = UDim2.new(1, -40, 0, 22)
	volumeLabel.Position = UDim2.new(0, 20, 0, 165)
	volumeLabel.BackgroundTransparency = 1
	volumeLabel.Text = "🔊 Volume: 50%"
	volumeLabel.TextColor3 = Color3.fromRGB(230, 230, 255)
	volumeLabel.TextScaled = true
	volumeLabel.Font = Enum.Font.GothamBold
	volumeLabel.TextXAlignment = Enum.TextXAlignment.Left
	volumeLabel.Parent = soundMenu

	local volumeSlider = Instance.new("Frame")
	volumeSlider.Size = UDim2.new(1, -40, 0, 20)
	volumeSlider.Position = UDim2.new(0, 20, 0, 195)
	volumeSlider.BackgroundColor3 = Color3.fromRGB(35, 15, 60)
	volumeSlider.BorderSizePixel = 0
	volumeSlider.Parent = soundMenu
	local vsC = Instance.new("UICorner", volumeSlider); vsC.CornerRadius = UDim.new(0, 10)

	local volumeFill = Instance.new("Frame")
	volumeFill.Size = UDim2.new(0.5, 0, 1, 0)
	volumeFill.BackgroundColor3 = Color3.fromRGB(180, 60, 255)
	volumeFill.BorderSizePixel = 0
	volumeFill.Parent = volumeSlider
	local vfC = Instance.new("UICorner", volumeFill); vfC.CornerRadius = UDim.new(0, 10)

	-- Botões de controle
	playButton = Instance.new("TextButton")
	playButton.Size = UDim2.new(0, 150, 0, 50)
	playButton.Position = UDim2.new(0, 20, 0, 235)
	playButton.BackgroundColor3 = Color3.fromRGB(0, 170, 60)
	playButton.Text = "▶️ TOCAR"
	playButton.TextColor3 = Color3.new(1, 1, 1)
	playButton.TextScaled = true
	playButton.Font = Enum.Font.FredokaOne
	playButton.Parent = soundMenu
	local pbC = Instance.new("UICorner", playButton); pbC.CornerRadius = UDim.new(0, 10)

	pauseButton = Instance.new("TextButton")
	pauseButton.Size = UDim2.new(0, 150, 0, 50)
	pauseButton.Position = UDim2.new(1, -170, 0, 235)
	pauseButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	pauseButton.Text = "⏸️"
	pauseButton.TextColor3 = Color3.new(1, 1, 1)
	pauseButton.TextScaled = true
	pauseButton.Font = Enum.Font.FredokaOne
	pauseButton.Parent = soundMenu
	local pa = Instance.new("UICorner", pauseButton); pa.CornerRadius = UDim.new(0, 10)

	local nextButton = Instance.new("TextButton")
	nextButton.Size = UDim2.new(0, 150, 0, 50)
	nextButton.Position = UDim2.new(0, 20, 0, 295)
	nextButton.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
	nextButton.Text = "⏭️ PRÓXIMA"
	nextButton.TextColor3 = Color3.new(1, 1, 1)
	nextButton.TextScaled = true
	nextButton.Font = Enum.Font.FredokaOne
	nextButton.Parent = soundMenu
	local nbC = Instance.new("UICorner", nextButton); nbC.CornerRadius = UDim.new(0, 10)

	stopButton = Instance.new("TextButton")
	stopButton.Size = UDim2.new(0, 150, 0, 50)
	stopButton.Position = UDim2.new(1, -170, 0, 295)
	stopButton.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
	stopButton.Text = "⏹️ PARAR"
	stopButton.TextColor3 = Color3.new(1, 1, 1)
	stopButton.TextScaled = true
	stopButton.Font = Enum.Font.FredokaOne
	stopButton.Parent = soundMenu
	local sbC = Instance.new("UICorner", stopButton); sbC.CornerRadius = UDim.new(0, 10)

	-- Hint
	local hint = Instance.new("TextLabel")
	hint.Size = UDim2.new(1, -40, 0, 60)
	hint.Position = UDim2.new(0, 20, 1, -75)
	hint.BackgroundTransparency = 1
	hint.Text = #musicPlaylist .. " músicas na playlist 🎧"
	hint.TextColor3 = Color3.fromRGB(180, 180, 220)
	hint.TextScaled = true
	hint.Font = Enum.Font.Gotham
	hint.Parent = soundMenu

	-- Eventos
	playButton.MouseButton1Click:Connect(function()
		if isPaused and currentSound then
			currentSound:Resume()
			isPaused = false
		elseif not isMusicPlaying then
			isMusicPlaying = true
			currentTrackIndex = 1
			shufflePlaylist()
			playNextTrack()
		end
		refreshButtons()
	end)

	pauseButton.MouseButton1Click:Connect(function()
		if isMusicPlaying and not isPaused and currentSound then
			currentSound:Pause()
			isPaused = true
			refreshButtons()
		end
	end)

	nextButton.MouseButton1Click:Connect(function()
		if isMusicPlaying then
			isPaused = false
			playNextTrack()
			refreshButtons()
		end
	end)

	stopButton.MouseButton1Click:Connect(function()
		isMusicPlaying = false
		isPaused = false
		if currentSound then
			currentSound:Stop()
			currentSound:Destroy()
			currentSound = nil
		end
		updateCurrentTrackDisplay("Nenhuma música tocando")
		refreshButtons()
	end)

	-- Volume drag
	local isDragging = false
	volumeSlider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end
	end)
	volumeSlider.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local rel = (input.Position.X - volumeSlider.AbsolutePosition.X) / volumeSlider.AbsoluteSize.X
			rel = math.clamp(rel, 0, 1)
			volumeFill.Size = UDim2.new(rel, 0, 1, 0)
			currentVolume = rel
			volumeLabel.Text = "🔊 Volume: " .. math.floor(rel * 100) .. "%"
			if currentSound then currentSound.Volume = rel * 0.4 end
		end
	end)

	refreshButtons()
end

function openMusicMenu()
	if not soundGui then createMusicMenu() end
	soundMenu.Visible = true
	isMenuOpen = true
	soundMenu.Size = UDim2.new(0, 0, 0, 460)
	soundMenu.Position = UDim2.new(0.5, 0, 0.5, -230)
	TweenService:Create(soundMenu, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 380, 0, 460),
		Position = UDim2.new(0.5, -190, 0.5, -230)
	}):Play()
end

function closeMusicMenu()
	if not soundMenu or not isMenuOpen then return end
	local t = TweenService:Create(soundMenu, TweenInfo.new(0.2), {
		Size = UDim2.new(0, 0, 0, 460),
		Position = UDim2.new(0.5, 0, 0.5, -230)
	})
	t.Completed:Connect(function()
		soundMenu.Visible = false
		isMenuOpen = false
	end)
	t:Play()
end

if #musicPlaylist == 0 then
	warn("⚠️ Nenhuma música na playlist!")
	return
end

createSoundButton()
createMusicMenu()

player.CharacterRemoving:Connect(function()
	if currentSound then currentSound:Stop(); currentSound:Destroy() end
end)

print("🎵 Music System v2 carregado com " .. #musicPlaylist .. " músicas!")