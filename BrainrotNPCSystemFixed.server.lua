local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local brainrotsFolder = ReplicatedStorage:WaitForChild("Brainrots")

local brainrotLevels = {
	["67"] = 13, ["Admin Lucky Block"] = 45, ["Agarrini la Palini"] = 8,
	["Alessio"] = 10, ["Antonio"] = 8, ["Avocadini Antilopini"] = 15,
	["Avocadini Guffo"] = 18, ["Avocadorilla"] = 20, ["Ballerina Cappuccina"] = 10,
	["Ballerino Lololo"] = 13, ["Bambini Crostini"] = 5, ["Bananita Dolphinita"] = 15,
	["Bandito Axolito"] = 18, ["Bandito Bobritto"] = 20, ["Bisonte Giuppitere"] = 23,
	["Blackhole Goat"] = 38, ["Blueberrinni Octopusini"] = 18, ["Bombardiro Crocodilo"] = 30,
	["Bombombini Gusini"] = 25, ["Boneca Ambalabu"] = 10, ["Brainrot God Lucky Block"] = 50,
	["Brr Brr Patapim"] = 15, ["Brr es Teh Patipum"] = 18, ["Brri Brri Bicus Dicus Bombicus"] = 28,
	["Bulbito Bandito Traktorito"] = 23, ["Burbaloni Loliloli"] = 13, ["Cacasito Satalito"] = 8,
	["Cacto Hipopotamo"] = 15, ["Cappuccino Assassino"] = 20, ["Caramello Filtrello"] = 10,
	["Carloo"] = 8, ["Carrotini Brainini"] = 13, ["Cavallo Virtuoso"] = 18,
	["Celularcini Viciosini"] = 15, ["Chachechi"] = 5, ["Chef Crabracadabra"] = 20,
	["Chicleteira Bicicleteira"] = 13, ["Chihuanini Taconini"] = 15, ["Chimpanzini Bananini"] = 10,
	["Cocofanto Elefanto"] = 23, ["Crabbo Limonetta"] = 13, ["Dragon Cannelloni"] = 25,
	["Dug dug dug"] = 8, ["Dul Dul Dul"] = 10, ["Esok Sekolah"] = 5,
	["Espresso Signora"] = 15, ["Extinct Ballerina"] = 35, ["Extinct Matteo"] = 33,
	["Extinct Tralalero"] = 38, ["Fluriflura"] = 13, ["Fragola La La La"] = 10,
	["Frigo Camelo"] = 18, ["Ganganzelli Trulala"] = 15, ["Gangster Footera"] = 20,
	["Garama and Madundung"] = 13, ["Gattatino Nyanino"] = 10, ["Gattito Tacoto"] = 15,
	["Girafa Celestre"] = 18, ["Glorbo Fruttodrillo"] = 23, ["Gorillo Watermelondrillo"] = 25,
	["Graipuss Medussi"] = 28, ["Guerriro Digitale"] = 20, ["Job Job Job Sahur"] = 13,
	["Karkerkar Kurkur"] = 18, ["Ketchuru and Musturu"] = 15, ["Ketupat Kepat"] = 10,
	["La Cucaracha"] = 13, ["La Extinct Grande"] = 40, ["La Grande Combinasion"] = 30,
	["La Karkerkar Combinasion"] = 33, ["La Sahur Combinasion"] = 28, ["La Vacca Saturno Saturnita"] = 35,
	["Las Capuchinas"] = 15, ["Las Sis"] = 13, ["Las Tralaleritas"] = 18,
	["Las Vaquitas Saturnitas"] = 20, ["Lerulerulerule"] = 10, ["Lionel Cactuseli"] = 23,
	["Lirilì Larilà"] = 25, ["Los Bombinitos"] = 13, ["Los Bros"] = 15,
	["Los Chicleteiras"] = 18, ["Los Combinasionas"] = 28, ["Los Crocodillitos"] = 20,
	["Los Hotspotsitos"] = 23, ["Los Matteos"] = 25, ["Los Noobinis"] = 8,
	["Los Nooo My Hotspotsitos"] = 30, ["Los Orcalitos"] = 20, ["Los Spyderinis"] = 23,
	["Los Tacoritas"] = 18, ["Los Tipi Tacos"] = 15, ["Los Tralaleritos"] = 20,
	["Los Tungtungtungcitos"] = 25, ["Matteo"] = 10, ["Mythic Lucky Block"] = 48,
	["Noobini Pizzanini"] = 8, ["Nuclearo Dinossauro"] = 35, ["Odin Din Din Dun"] = 28,
	["Orangutini Ananassini"] = 18, ["Orcalero Orcala"] = 30, ["Pakrahmatmamat"] = 13,
	["Pandaccini Bananini"] = 15, ["Penguino Cocosino"] = 10, ["Perochello Lemonchello"] = 20,
	["Piccione Macchina"] = 23, ["Pipi Avocado"] = 8, ["Pipi Corni"] = 10,
	["Pipi Kiwi"] = 13, ["Pipi Potato"] = 8, ["Pot Hotspot"] = 25,
	["Quivioli Ameleonni"] = 18, ["Rhino Toasterino"] = 23, ["Salamino Penguino"] = 15,
	["Sammyni Spyderini"] = 20, ["Secret Lucky Block"] = 43, ["Sigma Boy"] = 33,
	["Sigma Girl"] = 30, ["Spaghetti Tualetti"] = 18, ["Spioniro Golubiro"] = 23,
	["Strawberrelli Flamingelli"] = 20, ["Strawberry Elephant"] = 25, ["Svinina Bombardino"] = 28,
	["Ta Ta Ta Ta Sahur"] = 13, ["Taco Lucky Block"] = 40, ["Talpa Di Fero"] = 20,
	["Te Te Te Sahur"] = 15, ["Ti Ti Ti Sahur"] = 18, ["Tigrilini Watermelini"] = 23,
	["Tigroligre Frutonni"] = 25, ["Tim Cheese"] = 10, ["Tipi Topi Taco"] = 15,
	["To to to Sahur"] = 13, ["Torrtuginni Dragonfrutini"] = 28, ["Tracoducotulu Delapeladustuz"] = 33,
	["Tralaledon"] = 25, ["Tralalero Tralala"] = 30, ["Tralalita Tralala"] = 28,
	["Trenostruzzo Turbo 3000"] = 38, ["Tric Trac Baraboom"] = 23, ["Trippi Troppi"] = 18,
	["Trippi Troppi Troppa Trippa"] = 25, ["Trulimero Trulicina"] = 20, ["Tukanno Bananno"] = 23,
	["Tung Tung Tung Sahur"] = 28, ["Unclito Samito"] = 15, ["Urubini Flamenguini"] = 25,
	["Zibra Zubra Zibralini"] = 8,
}

local spawnedFolder = Workspace:FindFirstChild("SpawnedBrainrots") or Instance.new("Folder", Workspace)
spawnedFolder.Name = "SpawnedBrainrots"

local spawnPoints = {
	Vector3.new(112.122, 34.05, 130.651), Vector3.new(135.478, 34.05, 55.909),
	Vector3.new(-18.59,  34.05, 11.343),  Vector3.new(-42.317, 34.09, 179.605),
	Vector3.new(171.036, 33.93, 157.737), Vector3.new(238.377, 34.05, 62.343),
	Vector3.new(329.322, 35.078, 274.243),Vector3.new(173.171, 33.431, 357.844),
	Vector3.new(177.919, 33.431, 177.243),
}

local occupied = {}

local function getRandomBrainrot()
	local list = brainrotsFolder:GetChildren()
	return #list > 0 and list[math.random(1, #list)] or nil
end

local function setupModel(model)
	local rootPart = model.PrimaryPart or model:FindFirstChild("RootPart") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
	if not rootPart then return nil end
	model.PrimaryPart = rootPart

	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = false
			obj.CanCollide = false
			obj.Massless = true
		end
	end
	rootPart.Anchored = true
	return rootPart
end

local function positionAtSlot(model, slotIndex)
	local rootPart = model.PrimaryPart
	if not rootPart then return end
	local spawnPos = spawnPoints[slotIndex]
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {model}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local rayResult = workspace:Raycast(Vector3.new(spawnPos.X, spawnPos.Y + 50, spawnPos.Z), Vector3.new(0, -100, 0), rayParams)
	local groundY = rayResult and rayResult.Position.Y or spawnPos.Y

	local modelCFrame, modelSize = model:GetBoundingBox()
	local pivotOffset = rootPart.Position.Y - (modelCFrame.Position.Y - (modelSize.Y / 2))
	rootPart.CFrame = CFrame.new(spawnPos.X, groundY + pivotOffset + 0.1, spawnPos.Z)
end

local function spawnBrainrotAtSlot(slotIndex)
	local template = getRandomBrainrot()
	if not template or not template:IsA("Model") then return end

	local clone = template:Clone()
	local level = brainrotLevels[template.Name] or 1
	local captureChance = math.max(100 - ((level - 1) * 1.94), 5)

	-- ════════════════════════════════════════════════════════
	-- CÁLCULO DE TEMPO DE VIDA (Lv.1 = 180s | Lv.50 = 30s)
	-- ════════════════════════════════════════════════════════
	local maxLifespan, minLifespan = 180, 30
	local lifespan = math.floor(maxLifespan - ((level - 1) / 49) * (maxLifespan - minLifespan))

	clone:SetAttribute("Level", level)
	clone:SetAttribute("CaptureChance", captureChance)
	clone:SetAttribute("Captured", false)
	clone:SetAttribute("Hacking", false)
	clone:SetAttribute("DespawnTimer", lifespan) -- NOVO ATRIBUTO

	clone.Name = template.Name .. " [Lv." .. level .. "]"
	clone.Parent = spawnedFolder

	local rootPart = setupModel(clone)
	if not rootPart then clone:Destroy(); return end

	if clone.PrimaryPart then clone:ScaleTo(1.0 + ((level - 1) * 0.0816)) end
	positionAtSlot(clone, slotIndex)

	occupied[slotIndex] = clone
	print(string.format("✅ %s spawnado no slot %d | Chance: %d%% | Despawn em: %ds", clone.Name, slotIndex, captureChance, lifespan))

	-- ════════════════════════════════════════════════════════
	-- LOOP DE CONTAGEM REGRESSIVA DO DESPAWN
	-- ════════════════════════════════════════════════════════
	task.spawn(function()
		while clone.Parent do
			task.wait(1)

			if clone:GetAttribute("Captured") then
				break
			end

			local hackCount = clone:GetAttribute("HackCount") or 0
			if hackCount > 0 then
				continue
			end

			local timeLeft = (clone:GetAttribute("DespawnTimer") or 0) - 1
			clone:SetAttribute("DespawnTimer", timeLeft)

			if timeLeft <= 0 then
				print("💨 Despawn por tempo esgotado:", clone.Name)
				if occupied[slotIndex] == clone then
					occupied[slotIndex] = nil
				end
				clone:Destroy()
				break
			end
		end
	end)

	clone.AncestryChanged:Connect(function(_, parent)
		if not parent and occupied[slotIndex] == clone then occupied[slotIndex] = nil end
	end)
end

local function fillSpawns()
	while true do
		for i = 1, #spawnPoints do
			if not occupied[i] then
				spawnBrainrotAtSlot(i)
				task.wait(0.2)
			end
		end
		task.wait(1)
	end
end

task.wait(2)
fillSpawns()