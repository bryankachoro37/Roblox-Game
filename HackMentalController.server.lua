local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

task.wait(2)

local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local hackResult = remotes:WaitForChild("HackResult", 10)
local openInventoryEvent = remotes:WaitForChild("OpenInventory", 10)

local cooldownNotify = remotes:FindFirstChild("HackCooldown")
if not cooldownNotify then
	cooldownNotify = Instance.new("RemoteEvent")
	cooldownNotify.Name = "HackCooldown"
	cooldownNotify.Parent = remotes
end

local deleteBrainrot = remotes:FindFirstChild("DeleteBrainrot")
if not deleteBrainrot then
	deleteBrainrot = Instance.new("RemoteEvent")
	deleteBrainrot.Name = "DeleteBrainrot"
	deleteBrainrot.Parent = remotes
end

local inventoryToast = remotes:FindFirstChild("InventoryToast")
if not inventoryToast then
	inventoryToast = Instance.new("RemoteEvent")
	inventoryToast.Name = "InventoryToast"
	inventoryToast.Parent = remotes
end

print("🧠 HackMentalController v6 iniciando...")

local MAX_INVENTORY = 25
local POST_CAPTURE_COOLDOWN = 6

local ACTIVE_HACKS = {}
local COOLDOWNS = {}
local GLOBAL_COOLDOWN = {}     -- COOLDOWNS gerais por jogador (após captura)
local fallbackInventory = {}

local function getInventory(player)
	fallbackInventory[player] = fallbackInventory[player] or {}
	return fallbackInventory[player]
end

local function getPlayerCooldownTable(player)
	COOLDOWNS[player] = COOLDOWNS[player] or {}
	return COOLDOWNS[player]
end

local function isBrainrotValid(brainrot)
	return brainrot and brainrot.Parent and brainrot:IsA("Model")
end

local function getBrainrotRoot(brainrot)
	if not isBrainrotValid(brainrot) then return nil end
	return brainrot.PrimaryPart or brainrot:FindFirstChild("HumanoidRootPart")
end

local function recalcHackCount(brainrot)
	if not isBrainrotValid(brainrot) then return end
	local active = {}
	local count = 0

	for player, data in pairs(ACTIVE_HACKS) do
		if data.brainrot == brainrot then
			count += 1
			active[player.UserId] = true
		end
	end

	for attrName, _ in pairs(brainrot:GetAttributes()) do
		if string.sub(attrName, 1, 8) == "Hacking_" then
			local userId = tonumber(string.sub(attrName, 9))
			if userId and not active[userId] then
				brainrot:SetAttribute(attrName, nil)
			end
		end
	end

	brainrot:SetAttribute("HackCount", count)
end

local function clearHackState(player)
	local data = ACTIVE_HACKS[player]
	if not data then return end
	local brainrot = data.brainrot
	ACTIVE_HACKS[player] = nil
	if isBrainrotValid(brainrot) then
		brainrot:SetAttribute("Hacking_" .. player.UserId, nil)
		recalcHackCount(brainrot)
	end
end

local function applyCooldown(player, brainrot, seconds, reason)
	local cooldowns = getPlayerCooldownTable(player)
	cooldowns[brainrot] = os.clock() + seconds
	cooldownNotify:FireClient(player, seconds, brainrot.Name, reason or "fail")
end

local function applyGlobalCooldown(player, seconds, brainrotName, reason)
	GLOBAL_COOLDOWN[player] = os.clock() + seconds
	cooldownNotify:FireClient(player, seconds, brainrotName or "Sistema", reason or "global")
end

local function getScaledFailCooldown(level)
	return math.floor(6 + ((level - 1) / 49) * 24)
end

local function syncInventoryToClient(player)
	local inv = getInventory(player)
	openInventoryEvent:FireClient(player, inv, true)
end

local function addBrainrotToInventory(player, brainrot)
	local inv = getInventory(player)
	if #inv >= MAX_INVENTORY then
		inventoryToast:FireClient(player, "❌ Inventário cheio! (" .. MAX_INVENTORY .. " brainrots)", "error")
		return false
	end

	local level = brainrot:GetAttribute("Level") or 1
	table.insert(inv, {
		id = HttpService:GenerateGUID(false),
		name = brainrot.Name,
		level = level,
		capturedDate = os.date("%d/%m/%Y %H:%M:%S"),
	})

	syncInventoryToClient(player)
	inventoryToast:FireClient(player, "🎉 Capturado: " .. brainrot.Name, "success")

	if _G.AddBrainrotToInventory then
		pcall(function() _G.AddBrainrotToInventory(player, brainrot) end)
	end
	return true
end

_G.RegisterHack = function(player, brainrot, level, captureChance)
	if not player or not isBrainrotValid(brainrot) then return false end

	-- 1) cooldown global pós-captura
	local globalAt = GLOBAL_COOLDOWN[player]
	if globalAt and globalAt > os.clock() then
		local remaining = math.ceil(globalAt - os.clock())
		cooldownNotify:FireClient(player, remaining, "Cooldown pós-captura", "global")
		return false
	end

	-- 2) inventário cheio
	local inv = getInventory(player)
	if #inv >= MAX_INVENTORY then
		inventoryToast:FireClient(player, "❌ Inventário cheio! Delete brainrots para capturar mais.", "error")
		return false
	end

	-- 3) cooldown específico daquele brainrot (falha anterior)
	local cooldowns = getPlayerCooldownTable(player)
	local expireAt = cooldowns[brainrot]
	if expireAt and expireAt > os.clock() then
		local remaining = math.ceil(expireAt - os.clock())
		cooldownNotify:FireClient(player, remaining, brainrot.Name, "fail")
		return false
	end

	if ACTIVE_HACKS[player] then
		clearHackState(player)
	end

	ACTIVE_HACKS[player] = {
		brainrot = brainrot,
		level = level or 1,
		captureChance = captureChance or 100,
		startTime = os.clock(),
	}

	brainrot:SetAttribute("Hacking_" .. player.UserId, true)
	recalcHackCount(brainrot)
	return true
end

Players.PlayerRemoving:Connect(function(player)
	clearHackState(player)
	COOLDOWNS[player] = nil
	GLOBAL_COOLDOWN[player] = nil
	fallbackInventory[player] = nil
end)

deleteBrainrot.OnServerEvent:Connect(function(player, brainrotId)
	if not player or not brainrotId then return end
	local inv = getInventory(player)
	for i, b in ipairs(inv) do
		if b.id == brainrotId then
			local removed = table.remove(inv, i)
			syncInventoryToClient(player)
			inventoryToast:FireClient(player, "🗑️ " .. removed.name .. " deletado!", "info")
			return
		end
	end
end)

hackResult.OnServerEvent:Connect(function(player, result)
	local data = ACTIVE_HACKS[player]
	if not data then return end

	local brainrot = data.brainrot
	local level = data.level or 1

	clearHackState(player)

	if not isBrainrotValid(brainrot) then
		hackResult:FireClient(player, "Stolen")
		return
	end

	if brainrot:GetAttribute("Captured") then
		hackResult:FireClient(player, "Stolen")
		return
	end

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local broot = getBrainrotRoot(brainrot)

	if result == "Cancel" then
		applyCooldown(player, brainrot, 5, "cancel")
		hackResult:FireClient(player, "Cancel")
		return
	end

	if result == "TooFar" then
		applyCooldown(player, brainrot, 5, "toofar")
		hackResult:FireClient(player, "TooFar")
		return
	end

	if hrp and broot then
		local dist = (hrp.Position - broot.Position).Magnitude
		if dist > 35 then
			applyCooldown(player, brainrot, 5, "toofar")
			hackResult:FireClient(player, "TooFar")
			return
		end
	end

	if result == "Success" then
		brainrot:SetAttribute("Captured", true)
		brainrot:SetAttribute("HackCount", 0)

		local toRemove = {}
		for otherPlayer, otherData in pairs(ACTIVE_HACKS) do
			if otherData.brainrot == brainrot then
				table.insert(toRemove, otherPlayer)
			end
		end
		for _, otherPlayer in ipairs(toRemove) do
			clearHackState(otherPlayer)
			hackResult:FireClient(otherPlayer, "Stolen")
		end

		local added = addBrainrotToInventory(player, brainrot)

		if added then
			-- Cooldown global pós-captura
			applyGlobalCooldown(player, POST_CAPTURE_COOLDOWN, brainrot.Name, "global")

			if _G.AddCoins then
				pcall(function() _G.AddCoins(player, level * 10, "Captura: " .. brainrot.Name) end)
			end
			if _G.AddBrainrotPoints then
				pcall(function() _G.AddBrainrotPoints(player, level, "Captura: " .. brainrot.Name) end)
			end
		end

		hackResult:FireClient(player, "Success")

		task.delay(0.8, function()
			if isBrainrotValid(brainrot) then brainrot:Destroy() end
		end)
	else
		local failCooldown = getScaledFailCooldown(level)
		applyCooldown(player, brainrot, failCooldown, "fail")
		hackResult:FireClient(player, "Fail")
	end
end)

print("✅ HackMentalController v6 carregado!")