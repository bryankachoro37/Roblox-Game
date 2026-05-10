local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local openInventoryEvent = remotes:WaitForChild("OpenInventory")
local deleteBrainrot = remotes:WaitForChild("DeleteBrainrot")
local inventoryToast = remotes:WaitForChild("InventoryToast")

local brainrotsTemplates = ReplicatedStorage:WaitForChild("Brainrots")

local MAX_INVENTORY = 25
local capturedBrainrots = {}
local currentFilter = "all"

local FILTERS = {
	{key = "all",        label = "📦 Todos",      color = Color3.fromRGB(180, 180, 220)},
	{key = "common",     label = "🟢 Comum",      color = Color3.fromRGB(100, 255, 130)},
	{key = "rare",       label = "🟡 Raro",       color = Color3.fromRGB(255, 220, 100)},
	{key = "epic",       label = "🟠 Épico",      color = Color3.fromRGB(255, 130, 80)},
	{key = "legendary",  label = "🟣 Lendário",  color = Color3.fromRGB(255, 80, 200)},
}

local function getRarityKey(level)
	if level <= 10 then return "common"
	elseif level <= 25 then return "rare"
	elseif level <= 40 then return "epic"
	else return "legendary" end
end

local function getRarityLabel(level)
	if level <= 10 then return "COMUM"
	elseif level <= 25 then return "RARO"
	elseif level <= 40 then return "ÉPICO"
	else return "LENDÁRIO" end
end

local function getLevelColor(level)
	if level <= 10 then return Color3.fromRGB(100, 255, 130)
	elseif level <= 25 then return Color3.fromRGB(255, 220, 100)
	elseif level <= 40 then return Color3.fromRGB(255, 130, 80)
	else return Color3.fromRGB(255, 80, 200) end
end

local function sanitizeName(name)
	return string.gsub(name or "", "%s%[Lv%.%d+%]", "")
end

-- ========== GUI ==========
local inventoryGui = Instance.new("ScreenGui")
inventoryGui.Name = "BrainrotInventory"
inventoryGui.ResetOnSpawn = false
inventoryGui.IgnoreGuiInset = true
inventoryGui.Parent = playerGui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 0.4
backdrop.Visible = false
backdrop.Parent = inventoryGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 920, 0, 620)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 8, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = inventoryGui
local mc = Instance.new("UICorner", mainFrame); mc.CornerRadius = UDim.new(0, 22)
local ms = Instance.new("UIStroke", mainFrame); ms.Color = Color3.fromRGB(100, 200, 255); ms.Thickness = 3

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 60)
title.Position = UDim2.new(0, 20, 0, 12)
title.BackgroundTransparency = 1
title.Text = "🧠 INVENTÁRIO DE BRAINROTS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local capacityLabel = Instance.new("TextLabel")
capacityLabel.Size = UDim2.new(1, -70, 0, 24)
capacityLabel.Position = UDim2.new(0, 20, 0, 72)
capacityLabel.BackgroundTransparency = 1
capacityLabel.Text = "Capacidade: 0 / 25"
capacityLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
capacityLabel.TextScaled = true
capacityLabel.Font = Enum.Font.GothamBold
capacityLabel.TextXAlignment = Enum.TextXAlignment.Left
capacityLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 45, 0, 45)
closeButton.Position = UDim2.new(1, -55, 0, 15)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 90)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 24
closeButton.Font = Enum.Font.GothamBlack
closeButton.Parent = mainFrame
local cbC = Instance.new("UICorner", closeButton); cbC.CornerRadius = UDim.new(1, 0)

-- Tabs de filtro
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, -40, 0, 42)
tabsFrame.Position = UDim2.new(0, 20, 0, 102)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = mainFrame
local tabsLayout = Instance.new("UIListLayout", tabsFrame)
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Padding = UDim.new(0, 8)

local tabButtons = {}

local function refreshTabs()
	for _, t in ipairs(tabButtons) do
		if t.key == currentFilter then
			t.btn.BackgroundColor3 = Color3.fromRGB(80, 50, 150)
			t.stroke.Thickness = 3
			t.stroke.Color = t.color
		else
			t.btn.BackgroundColor3 = Color3.fromRGB(35, 22, 60)
			t.stroke.Thickness = 1
			t.stroke.Color = Color3.fromRGB(80, 60, 110)
		end
	end
end

local function makeTab(filter)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 130, 1, 0)
	btn.Text = filter.label
	btn.TextColor3 = filter.color
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = false
	btn.Parent = tabsFrame
	local bc = Instance.new("UICorner", btn); bc.CornerRadius = UDim.new(0, 10)
	local bs = Instance.new("UIStroke", btn); bs.Color = filter.color
	local p = Instance.new("UIPadding", btn)
	p.PaddingLeft = UDim.new(0, 8); p.PaddingRight = UDim.new(0, 8)

	table.insert(tabButtons, {btn = btn, stroke = bs, color = filter.color, key = filter.key})

	btn.MouseButton1Click:Connect(function()
		currentFilter = filter.key
		refreshTabs()
		updateInventory() -- forward declared abaixo
	end)
end

for _, f in ipairs(FILTERS) do makeTab(f) end

-- Conteúdo
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -40, 1, -170)
contentFrame.Position = UDim2.new(0, 20, 0, 155)
contentFrame.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 8
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentFrame.Parent = mainFrame
local cfC = Instance.new("UICorner", contentFrame); cfC.CornerRadius = UDim.new(0, 14)

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 200, 0, 280) -- aumentei
gridLayout.CellPadding = UDim2.new(0, 12, 0, 12)
gridLayout.Parent = contentFrame

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 12); pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12); pad.PaddingBottom = UDim.new(0, 12)
pad.Parent = contentFrame

-- Toast do inventário
local toastFrame = Instance.new("Frame")
toastFrame.Size = UDim2.new(0, 380, 0, 60)
toastFrame.Position = UDim2.new(0.5, 0, 0, -80)
toastFrame.AnchorPoint = Vector2.new(0.5, 0)
toastFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
toastFrame.Parent = inventoryGui
local tfC = Instance.new("UICorner", toastFrame); tfC.CornerRadius = UDim.new(0, 12)
local tfS = Instance.new("UIStroke", toastFrame); tfS.Thickness = 2
local toastLabel = Instance.new("TextLabel")
toastLabel.Size = UDim2.new(1, -20, 1, -10)
toastLabel.Position = UDim2.new(0, 10, 0, 5)
toastLabel.BackgroundTransparency = 1
toastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
toastLabel.TextScaled = true
toastLabel.Font = Enum.Font.GothamBold
toastLabel.Parent = toastFrame

local function showToast(text, kind)
	local color = Color3.fromRGB(180, 60, 255)
	if kind == "success" then color = Color3.fromRGB(80, 220, 130)
	elseif kind == "error" then color = Color3.fromRGB(255, 90, 90)
	elseif kind == "info" then color = Color3.fromRGB(120, 180, 255) end
	tfS.Color = color
	toastLabel.Text = text
	TweenService:Create(toastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 30)
	}):Play()
	task.delay(2.5, function()
		TweenService:Create(toastFrame, TweenInfo.new(0.3), {
			Position = UDim2.new(0.5, 0, 0, -80)
		}):Play()
	end)
end

inventoryToast.OnClientEvent:Connect(function(text, kind) showToast(text, kind) end)

-- Viewport com modelo girando
local function createViewport(brainrotName, parent)
	local viewport = Instance.new("ViewportFrame")
	viewport.Size = UDim2.new(1, -10, 0, 165) -- maior
	viewport.Position = UDim2.new(0, 5, 0, 26)
	viewport.BackgroundColor3 = Color3.fromRGB(10, 8, 20)
	viewport.BorderSizePixel = 0
	viewport.Parent = parent
	local vc = Instance.new("UICorner", viewport); vc.CornerRadius = UDim.new(0, 10)

	local cleanName = sanitizeName(brainrotName)
	local template = brainrotsTemplates:FindFirstChild(cleanName)
	if not template then
		local fallback = Instance.new("TextLabel")
		fallback.Size = UDim2.fromScale(1, 1)
		fallback.BackgroundTransparency = 1
		fallback.Text = "🧠"
		fallback.TextScaled = true
		fallback.Parent = viewport
		return
	end

	local clone = template:Clone()
	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true
			obj.CanCollide = false
		elseif obj:IsA("Script") or obj:IsA("LocalScript") then
			obj:Destroy()
		end
	end
	clone.Parent = viewport

	local cam = Instance.new("Camera")
	cam.Parent = viewport
	viewport.CurrentCamera = cam

	local cf, size = clone:GetBoundingBox()
	local center = cf.Position
	local dist = math.max(size.X, size.Y, size.Z) * 1.55

	-- Rotação contínua do modelo
	local angle = 0
	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not viewport.Parent then
			conn:Disconnect()
			return
		end
		angle += dt * 0.7
		local x = math.cos(angle) * dist
		local z = math.sin(angle) * dist
		cam.CFrame = CFrame.new(center + Vector3.new(x, dist * 0.45, z), center)
	end)
end

-- Modal de confirmação
local function showConfirmDelete(brainrot, onConfirm)
	local modal = Instance.new("Frame")
	modal.Size = UDim2.fromScale(1, 1)
	modal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	modal.BackgroundTransparency = 0.4
	modal.ZIndex = 100
	modal.Parent = inventoryGui

	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 360, 0, 200)
	box.Position = UDim2.new(0.5, 0, 0.5, 0)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
	box.ZIndex = 101
	box.Parent = modal
	local bc = Instance.new("UICorner", box); bc.CornerRadius = UDim.new(0, 14)
	local bs = Instance.new("UIStroke", box); bs.Color = Color3.fromRGB(255, 80, 100); bs.Thickness = 3

	local titleL = Instance.new("TextLabel")
	titleL.Size = UDim2.new(1, -20, 0, 40)
	titleL.Position = UDim2.new(0, 10, 0, 10)
	titleL.BackgroundTransparency = 1
	titleL.Text = "🗑️ Deletar?"
	titleL.TextColor3 = Color3.fromRGB(255, 100, 120)
	titleL.TextScaled = true
	titleL.Font = Enum.Font.FredokaOne
	titleL.ZIndex = 102
	titleL.Parent = box

	local descL = Instance.new("TextLabel")
	descL.Size = UDim2.new(1, -20, 0, 60)
	descL.Position = UDim2.new(0, 10, 0, 55)
	descL.BackgroundTransparency = 1
	descL.Text = "Tem certeza que quer deletar\n" .. sanitizeName(brainrot.name) .. " (Lv." .. brainrot.level .. ")?"
	descL.TextColor3 = Color3.fromRGB(230, 230, 240)
	descL.TextScaled = true
	descL.Font = Enum.Font.GothamBold
	descL.ZIndex = 102
	descL.Parent = box

	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0, 140, 0, 44)
	cancelBtn.Position = UDim2.new(0, 20, 1, -60)
	cancelBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
	cancelBtn.Text = "Cancelar"
	cancelBtn.TextColor3 = Color3.new(1, 1, 1)
	cancelBtn.TextScaled = true
	cancelBtn.Font = Enum.Font.GothamBold
	cancelBtn.ZIndex = 102
	cancelBtn.Parent = box
	local cbc = Instance.new("UICorner", cancelBtn); cbc.CornerRadius = UDim.new(0, 10)

	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(0, 140, 0, 44)
	confirmBtn.Position = UDim2.new(1, -160, 1, -60)
	confirmBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 80)
	confirmBtn.Text = "Deletar"
	confirmBtn.TextColor3 = Color3.new(1, 1, 1)
	confirmBtn.TextScaled = true
	confirmBtn.Font = Enum.Font.FredokaOne
	confirmBtn.ZIndex = 102
	confirmBtn.Parent = box
	local cfc = Instance.new("UICorner", confirmBtn); cfc.CornerRadius = UDim.new(0, 10)

	cancelBtn.MouseButton1Click:Connect(function() modal:Destroy() end)
	confirmBtn.MouseButton1Click:Connect(function()
		modal:Destroy()
		onConfirm()
	end)
end

local function clearContent()
	for _, child in ipairs(contentFrame:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

function updateInventory()
	clearContent()

	capacityLabel.Text = string.format("Capacidade: %d / %d", #capturedBrainrots, MAX_INVENTORY)
	capacityLabel.TextColor3 = (#capturedBrainrots >= MAX_INVENTORY)
		and Color3.fromRGB(255, 100, 100)
		or Color3.fromRGB(255, 220, 100)

	-- filtra
	local filtered = {}
	for _, b in ipairs(capturedBrainrots) do
		local key = getRarityKey(b.level or 1)
		if currentFilter == "all" or currentFilter == key then
			table.insert(filtered, b)
		end
	end

	if #filtered == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Size = UDim2.new(1, 0, 0, 100)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.Text = (#capturedBrainrots == 0)
			and "Nenhum brainrot capturado ainda!"
			or "Nenhum brainrot nesta categoria"
		emptyLabel.TextColor3 = Color3.fromRGB(170, 170, 200)
		emptyLabel.TextScaled = true
		emptyLabel.Font = Enum.Font.GothamBold
		emptyLabel.Parent = contentFrame
		return
	end

	table.sort(filtered, function(a, b) return (a.level or 1) > (b.level or 1) end)

	for _, brainrot in ipairs(filtered) do
		local color = getLevelColor(brainrot.level or 1)
		local slot = Instance.new("Frame")
		slot.BackgroundColor3 = Color3.fromRGB(35, 20, 60)
		slot.BorderSizePixel = 0
		slot.Parent = contentFrame
		local sc = Instance.new("UICorner", slot); sc.CornerRadius = UDim.new(0, 12)
		local ss = Instance.new("UIStroke", slot); ss.Color = color; ss.Thickness = 2

		local rarity = Instance.new("TextLabel")
		rarity.Size = UDim2.new(1, -10, 0, 20)
		rarity.Position = UDim2.new(0, 5, 0, 4)
		rarity.BackgroundColor3 = color
		rarity.BackgroundTransparency = 0.2
		rarity.Text = getRarityLabel(brainrot.level or 1)
		rarity.TextColor3 = Color3.fromRGB(0, 0, 0)
		rarity.TextScaled = true
		rarity.Font = Enum.Font.FredokaOne
		rarity.Parent = slot
		local rc = Instance.new("UICorner", rarity); rc.CornerRadius = UDim.new(0, 6)

		createViewport(brainrot.name, slot)

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -10, 0, 24)
		nameLabel.Position = UDim2.new(0, 5, 0, 195)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = sanitizeName(brainrot.name)
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Parent = slot

		local levelLabel = Instance.new("TextLabel")
		levelLabel.Size = UDim2.new(1, -10, 0, 22)
		levelLabel.Position = UDim2.new(0, 5, 0, 220)
		levelLabel.BackgroundTransparency = 1
		levelLabel.Text = "⭐ Lv." .. tostring(brainrot.level or 1)
		levelLabel.TextColor3 = color
		levelLabel.TextScaled = true
		levelLabel.Font = Enum.Font.FredokaOne
		levelLabel.Parent = slot

		local deleteBtn = Instance.new("TextButton")
		deleteBtn.Size = UDim2.new(1, -10, 0, 28)
		deleteBtn.Position = UDim2.new(0, 5, 1, -34)
		deleteBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 80)
		deleteBtn.Text = "🗑️ Deletar"
		deleteBtn.TextColor3 = Color3.new(1, 1, 1)
		deleteBtn.TextScaled = true
		deleteBtn.Font = Enum.Font.GothamBold
		deleteBtn.Parent = slot
		local dbc = Instance.new("UICorner", deleteBtn); dbc.CornerRadius = UDim.new(0, 8)

		deleteBtn.MouseButton1Click:Connect(function()
			showConfirmDelete(brainrot, function()
				deleteBrainrot:FireServer(brainrot.id)
			end)
		end)
	end
end

local function openInventory()
	backdrop.Visible = true
	mainFrame.Visible = true
	updateInventory()
end

local function closeInventory()
	mainFrame.Visible = false
	backdrop.Visible = false
end

closeButton.MouseButton1Click:Connect(closeInventory)
backdrop.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		closeInventory()
	end
end)

-- BOTÃO ABAIXO DO SHOP (no canto superior esquerdo)
local buttonGui = Instance.new("ScreenGui")
buttonGui.Name = "BrainrotInventoryButtonGui"
buttonGui.ResetOnSpawn = false
buttonGui.IgnoreGuiInset = true
buttonGui.Parent = playerGui

local inventoryButton = Instance.new("TextButton")
inventoryButton.Size = UDim2.new(0.1, 0, 0.06, 0)
inventoryButton.Position = UDim2.new(0.02, 0, 0.10, 0) -- logo abaixo do SHOP
inventoryButton.BackgroundColor3 = Color3.fromRGB(50, 25, 90)
inventoryButton.Text = "🧠 BRAINROTS"
inventoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
inventoryButton.TextScaled = true
inventoryButton.Font = Enum.Font.FredokaOne
inventoryButton.Parent = buttonGui
local ibC = Instance.new("UICorner", inventoryButton); ibC.CornerRadius = UDim.new(0, 8)
local ibS = Instance.new("UIStroke", inventoryButton); ibS.Color = Color3.fromRGB(100, 200, 255); ibS.Thickness = 2

local countBubble = Instance.new("TextLabel")
countBubble.Size = UDim2.new(0, 46, 0, 26)
countBubble.Position = UDim2.new(1, -10, 0, -8)
countBubble.AnchorPoint = Vector2.new(0, 0)
countBubble.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
countBubble.Text = "0/25"
countBubble.TextColor3 = Color3.new(1, 1, 1)
countBubble.TextScaled = true
countBubble.Font = Enum.Font.FredokaOne
countBubble.Parent = inventoryButton
local cbC2 = Instance.new("UICorner", countBubble); cbC2.CornerRadius = UDim.new(0, 8)

inventoryButton.MouseButton1Click:Connect(function()
	if mainFrame.Visible then closeInventory() else openInventory() end
end)

openInventoryEvent.OnClientEvent:Connect(function(brainrots, replace)
	if replace then
		capturedBrainrots = brainrots or {}
	else
		for _, b in ipairs(brainrots or {}) do
			table.insert(capturedBrainrots, b)
		end
	end

	countBubble.Text = string.format("%d/%d", #capturedBrainrots, MAX_INVENTORY)
	countBubble.BackgroundColor3 = (#capturedBrainrots >= MAX_INVENTORY)
		and Color3.fromRGB(255, 50, 50)
		or Color3.fromRGB(255, 80, 80)

	if mainFrame.Visible then updateInventory() end
end)

refreshTabs()
print("🧠 Brainrot Inventory v6 carregado!")