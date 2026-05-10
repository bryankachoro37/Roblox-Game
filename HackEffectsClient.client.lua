local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local hackProgress = remotes:FindFirstChild("HackProgress")
if not hackProgress then
	hackProgress = Instance.new("RemoteEvent")
	hackProgress.Name = "HackProgress"
	hackProgress.Parent = remotes
end

-- Sons internos do Roblox (sempre funcionam)
local SOUND_TENSION = "rbxasset://sounds/snap.mp3"
local SOUND_HEARTBEAT = "rbxasset://sounds/clickfast.wav"
local SOUND_CAPTURE = "rbxasset://sounds/victory.wav"

local effectsGui = Instance.new("ScreenGui")
effectsGui.Name = "HackEffectsGui"
effectsGui.ResetOnSpawn = false
effectsGui.IgnoreGuiInset = true
effectsGui.DisplayOrder = 999
effectsGui.Parent = playerGui

-- Vinheta vermelha (gradiente)
local borderGlow = Instance.new("Frame")
borderGlow.Size = UDim2.fromScale(1, 1)
borderGlow.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
borderGlow.BackgroundTransparency = 1
borderGlow.BorderSizePixel = 0
borderGlow.Parent = effectsGui

local glowGradient = Instance.new("UIGradient")
glowGradient.Color = ColorSequence.new(Color3.fromRGB(255, 30, 30))
glowGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.4, 1),
	NumberSequenceKeypoint.new(0.6, 1),
	NumberSequenceKeypoint.new(1, 1),
}
glowGradient.Rotation = 0
glowGradient.Parent = borderGlow

-- ColorCorrection
local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "HackEffectCC"
cc.Saturation = 0
cc.Contrast = 0
cc.TintColor = Color3.fromRGB(255, 255, 255)
cc.Enabled = false
cc.Parent = Lighting

-- Blur
local blur = Instance.new("BlurEffect")
blur.Name = "HackEffectBlur"
blur.Size = 0
blur.Enabled = false
blur.Parent = Lighting

local function makeSound(id, volume, looped)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = volume or 0.3
	s.Looped = looped or false
	s.Parent = SoundService
	return s
end

local tensionSound = makeSound(SOUND_TENSION, 0, true)
local heartbeatSound = makeSound(SOUND_HEARTBEAT, 0, true)
local captureSound = makeSound(SOUND_CAPTURE, 0.4, false)

local function fadeSound(sound, target, duration)
	local t = TweenService:Create(sound, TweenInfo.new(duration), {Volume = target})
	t:Play()
	return t
end

local function setIntensity(intensity)
	intensity = math.clamp(intensity, 0, 1)

	if intensity <= 0.05 then
		fadeSound(tensionSound, 0, 0.4)
		fadeSound(heartbeatSound, 0, 0.4)

		borderGlow.BackgroundTransparency = 1
		glowGradient.Transparency = NumberSequence.new(1)
		TweenService:Create(cc, TweenInfo.new(0.4), {
			Saturation = 0, Contrast = 0, TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
		TweenService:Create(blur, TweenInfo.new(0.4), {Size = 0}):Play()

		task.delay(0.5, function()
			if tensionSound.Volume <= 0.01 then tensionSound:Stop() end
			if heartbeatSound.Volume <= 0.01 then heartbeatSound:Stop() end
			cc.Enabled = false
			blur.Enabled = false
		end)
		return
	end

	cc.Enabled = true
	blur.Enabled = true

	if not tensionSound.IsPlaying then tensionSound:Play() end
	if intensity >= 0.5 and not heartbeatSound.IsPlaying then
		heartbeatSound:Play()
	end

	fadeSound(tensionSound, 0.18 * intensity, 0.4)
	if intensity >= 0.5 then
		fadeSound(heartbeatSound, 0.22 * ((intensity - 0.5) / 0.5), 0.4)
	else
		fadeSound(heartbeatSound, 0, 0.4)
	end

	-- Vinheta vermelha aumenta com intensidade
	local glowAlpha = 1 - (intensity * 0.5)
	glowGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, glowAlpha),
		NumberSequenceKeypoint.new(0.4, 1),
		NumberSequenceKeypoint.new(0.6, 1),
		NumberSequenceKeypoint.new(1, glowAlpha),
	}
	borderGlow.BackgroundTransparency = 1 - (0.15 * intensity)
	if intensity >= 0.7 then
		borderGlow.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	else
		borderGlow.BackgroundColor3 = Color3.fromRGB(255, 100, 60)
	end

	TweenService:Create(cc, TweenInfo.new(0.4), {
		Saturation = -0.2 * intensity,
		Contrast = 0.15 * intensity,
		TintColor = Color3.fromRGB(
			255,
			255 - math.floor(60 * intensity),
			255 - math.floor(80 * intensity)
		)
	}):Play()

	TweenService:Create(blur, TweenInfo.new(0.4), {
		Size = 4 * intensity
	}):Play()
end

local function captureFlash()
	captureSound:Play()

	local flash = Instance.new("Frame")
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.fromRGB(255, 230, 150)
	flash.BackgroundTransparency = 0.3
	flash.BorderSizePixel = 0
	flash.ZIndex = 1000
	flash.Parent = effectsGui

	TweenService:Create(flash, TweenInfo.new(0.6), {
		BackgroundTransparency = 1
	}):Play()

	task.delay(0.7, function()
		flash:Destroy()
	end)

	task.delay(0.2, function()
		setIntensity(0)
	end)
end

local function suaveOff()
	setIntensity(0)
end

hackProgress.OnClientEvent:Connect(function(action, value)
	if action == "Intensity" then
		setIntensity(value or 0)
	elseif action == "Capture" then
		captureFlash()
	elseif action == "Stop" then
		suaveOff()
	end
end)

print("🎬 HackEffectsClient v2 carregado!")