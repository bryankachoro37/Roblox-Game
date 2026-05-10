local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

task.wait(2)

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
local startHack = remotesFolder:WaitForChild("StartHack", 10)

if not startHack then
	error("❌ StartHack RemoteEvent não encontrado!")
end

local brainrotFolder = Workspace:WaitForChild("SpawnedBrainrots", 15)

local function addPrompt(brainrot)
	if not brainrot or not brainrot.Parent then return end
	if brainrot:GetAttribute("Captured") then return end

	local root = brainrot:FindFirstChild("HumanoidRootPart") or brainrot.PrimaryPart
	if not root then return end

	local old = root:FindFirstChild("HackPrompt")
	if old then old:Destroy() end

	local level = brainrot:GetAttribute("Level") or 1
	local captureChance = brainrot:GetAttribute("CaptureChance") or 100

	local actionText
	if level <= 10 then
		actionText = "🧠 Capturar"
	elseif level <= 25 then
		actionText = "⚡ Invadir"
	elseif level <= 40 then
		actionText = "💀 Dominar"
	else
		actionText = "👑 Hackear"
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "HackPrompt"
	prompt.ActionText = actionText
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = 25
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0
	-- Default = aparece a UI padrão visual do Roblox
	prompt.Style = Enum.ProximityPromptStyle.Default
	prompt.Enabled = true
	prompt.Parent = root

	task.spawn(function()
		while prompt.Parent and brainrot.Parent do
			if brainrot:GetAttribute("Captured") then break end

			local despawnTimer = brainrot:GetAttribute("DespawnTimer") or 0
			local hackCount = brainrot:GetAttribute("HackCount") or 0

			if hackCount > 0 then
				prompt.ObjectText = string.format("⚠️ %d hacker(s)\n%s | ⏳ %ds",
					hackCount, brainrot.Name, despawnTimer)
			else
				prompt.ObjectText = string.format("%s\n⭐ Lv.%d | ⏳ %ds",
					brainrot.Name, level, despawnTimer)
			end

			task.wait(0.5)
		end
	end)

	prompt.Triggered:Connect(function(player)
		if not player or not player.Parent then return end
		if not brainrot or not brainrot.Parent then return end
		if brainrot:GetAttribute("Captured") then return end

		local registered = false
		if _G.RegisterHack then
			registered = _G.RegisterHack(player, brainrot, level, captureChance)
		end

		if not registered then
			return
		end

		startHack:FireClient(player, {
			brainrot = brainrot,
			level = level,
			captureChance = captureChance,
		})

		print("[" .. player.Name .. "] Iniciou hack → " .. brainrot.Name)
	end)
end

local function onCaptured(brainrot)
	local root = brainrot:FindFirstChild("HumanoidRootPart") or brainrot.PrimaryPart
	if root then
		local prompt = root:FindFirstChild("HackPrompt")
		if prompt then prompt:Destroy() end
	end
end

local function monitorBrainrot(brainrot)
	brainrot:GetAttributeChangedSignal("Captured"):Connect(function()
		if brainrot:GetAttribute("Captured") then
			onCaptured(brainrot)
		end
	end)
end

for _, b in ipairs(brainrotFolder:GetChildren()) do
	if b:IsA("Model") then
		task.delay(0.5, function()
			addPrompt(b)
			monitorBrainrot(b)
		end)
	end
end

brainrotFolder.ChildAdded:Connect(function(b)
	if b:IsA("Model") then
		task.delay(1, function()
			addPrompt(b)
			monitorBrainrot(b)
		end)
	end
end)

print("🚀 BrainrotInteraction com prompt padrão!")