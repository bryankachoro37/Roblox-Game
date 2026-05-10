local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local mainRemote = remoteEventsFolder:WaitForChild("OnServerEvent")

local CARS = {
	{ name = "Taxi",                id = "car_1", emoji = "🚖", color = Color3.fromRGB(255, 200, 0)   },
	{ name = "Red Hatchback",       id = "car_2", emoji = "🚗", color = Color3.fromRGB(220, 50, 50)   },
	{ name = "Police Car",          id = "car_3", emoji = "🚓", color = Color3.fromRGB(60, 90, 200)   },
	{ name = "Green Station Wagon", id = "car_4", emoji = "🚙", color = Color3.fromRGB(80, 180, 80)   },
	{ name = "Blue Sedan",          id = "car_5", emoji = "🚘", color = Color3.fromRGB(80, 140, 220)  },
	{ name = "Blue Pickup",         id = "car_6", emoji = "🛻", color = Color3.fromRGB(50, 100, 200)  },
	{ name = "Blue Box Truck",      id = "car_7", emoji = "🚚", color = Color3.fromRGB(80, 130, 200)  },
}

local function createShopButton()
	for _, child in ipairs(playerGui:GetChildren()) do
		if child.Name == "UltraCarShopGui" then child:Destroy() end
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "UltraCarShopGui"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.1, 0, 0.06, 0)
	button.Position = UDim2.new(0.02, 0, 0.02, 0)
	button.BackgroundColor3 = Color3.fromRGB(255, 30, 200)
	button.BorderSizePixel = 0
	button.Text = "🚗 SHOP"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.FredokaOne
	button.Parent = gui
	local bc = Instance.new("UICorner", button); bc.CornerRadius = UDim.new(0, 10)
	local bs = Instance.new("UIStroke", button); bs.Color = Color3.fromRGB(255, 100, 230); bs.Thickness = 2

	button.MouseButton1Click:Connect(function()
		local existing = playerGui:FindFirstChild("UltraCarShopUI")
		if existing then existing:Destroy(); return end

		local shopGui = Instance.new("ScreenGui")
		shopGui.Name = "UltraCarShopUI"
		shopGui.IgnoreGuiInset = true
		shopGui.Parent = playerGui

		local backdrop = Instance.new("Frame")
		backdrop.Size = UDim2.fromScale(1, 1)
		backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		backdrop.BackgroundTransparency = 0.4
		backdrop.Parent = shopGui

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 720, 0, 560)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = Color3.fromRGB(20, 8, 30)
		frame.BorderSizePixel = 0
		frame.Parent = shopGui
		local fc = Instance.new("UICorner", frame); fc.CornerRadius = UDim.new(0, 20)
		local fs = Instance.new("UIStroke", frame); fs.Color = Color3.fromRGB(255, 60, 200); fs.Thickness = 3
		local fg = Instance.new("UIGradient", frame)
		fg.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 12, 50)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 5, 25)),
		}
		fg.Rotation = 90

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -70, 0, 56)
		title.Position = UDim2.new(0, 20, 0, 10)
		title.BackgroundTransparency = 1
		title.Text = "🚗 LOJA DE CARROS"
		title.TextColor3 = Color3.fromRGB(255, 100, 230)
		title.TextScaled = true
		title.Font = Enum.Font.FredokaOne
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = frame

		local subtitle = Instance.new("TextLabel")
		subtitle.Size = UDim2.new(1, -70, 0, 22)
		subtitle.Position = UDim2.new(0, 20, 0, 64)
		subtitle.BackgroundTransparency = 1
		subtitle.Text = "Todos os carros são gratuitos por enquanto 🎉"
		subtitle.TextColor3 = Color3.fromRGB(220, 200, 255)
		subtitle.TextScaled = true
		subtitle.Font = Enum.Font.Gotham
		subtitle.TextXAlignment = Enum.TextXAlignment.Left
		subtitle.Parent = frame

		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.new(0, 40, 0, 40)
		closeBtn.Position = UDim2.new(1, -50, 0, 14)
		closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
		closeBtn.Text = "X"
		closeBtn.TextColor3 = Color3.new(1, 1, 1)
		closeBtn.TextScaled = true
		closeBtn.Font = Enum.Font.GothamBlack
		closeBtn.Parent = frame
		local cbcC = Instance.new("UICorner", closeBtn); cbcC.CornerRadius = UDim.new(1, 0)
		closeBtn.MouseButton1Click:Connect(function() shopGui:Destroy() end)

		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.new(1, -40, 1, -120)
		scroll.Position = UDim2.new(0, 20, 0, 100)
		scroll.BackgroundColor3 = Color3.fromRGB(15, 8, 30)
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.Parent = frame
		local sC = Instance.new("UICorner", scroll); sC.CornerRadius = UDim.new(0, 12)

		local grid = Instance.new("UIGridLayout")
		grid.CellSize = UDim2.new(0, 200, 0, 130)
		grid.CellPadding = UDim2.new(0, 12, 0, 12)
		grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
		grid.Parent = scroll

		local pad = Instance.new("UIPadding", scroll)
		pad.PaddingTop = UDim.new(0, 12); pad.PaddingLeft = UDim.new(0, 12)
		pad.PaddingRight = UDim.new(0, 12); pad.PaddingBottom = UDim.new(0, 12)

		for _, car in ipairs(CARS) do
			local card = Instance.new("Frame")
			card.BackgroundColor3 = Color3.fromRGB(35, 18, 55)
			card.BorderSizePixel = 0
			card.Parent = scroll
			local cc = Instance.new("UICorner", card); cc.CornerRadius = UDim.new(0, 12)
			local cs = Instance.new("UIStroke", card); cs.Color = car.color; cs.Thickness = 2

			local emoji = Instance.new("TextLabel")
			emoji.Size = UDim2.new(0, 60, 0, 60)
			emoji.Position = UDim2.new(0, 8, 0, 8)
			emoji.BackgroundColor3 = car.color
			emoji.BackgroundTransparency = 0.3
			emoji.Text = car.emoji
			emoji.TextScaled = true
			emoji.Font = Enum.Font.FredokaOne
			emoji.Parent = card
			local eC = Instance.new("UICorner", emoji); eC.CornerRadius = UDim.new(0, 10)

			local nameL = Instance.new("TextLabel")
			nameL.Size = UDim2.new(1, -80, 0, 32)
			nameL.Position = UDim2.new(0, 76, 0, 8)
			nameL.BackgroundTransparency = 1
			nameL.Text = car.name
			nameL.TextColor3 = Color3.new(1, 1, 1)
			nameL.TextScaled = true
			nameL.Font = Enum.Font.FredokaOne
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.Parent = card

			local priceL = Instance.new("TextLabel")
			priceL.Size = UDim2.new(1, -80, 0, 22)
			priceL.Position = UDim2.new(0, 76, 0, 42)
			priceL.BackgroundTransparency = 1
			priceL.Text = "💰 GRÁTIS"
			priceL.TextColor3 = Color3.fromRGB(120, 255, 150)
			priceL.TextScaled = true
			priceL.Font = Enum.Font.GothamBold
			priceL.TextXAlignment = Enum.TextXAlignment.Left
			priceL.Parent = card

			local buyBtn = Instance.new("TextButton")
			buyBtn.Size = UDim2.new(1, -16, 0, 42)
			buyBtn.Position = UDim2.new(0, 8, 1, -50)
			buyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
			buyBtn.Text = "🛒 PEGAR"
			buyBtn.TextColor3 = Color3.new(1, 1, 1)
			buyBtn.TextScaled = true
			buyBtn.Font = Enum.Font.FredokaOne
			buyBtn.Parent = card
			local bC = Instance.new("UICorner", buyBtn); bC.CornerRadius = UDim.new(0, 10)

			buyBtn.MouseButton1Click:Connect(function()
				mainRemote:FireServer("PurchaseCar", car.id)
				buyBtn.Text = "✓ COMPRADO"
				buyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 60)
				task.wait(1.5)
				buyBtn.Text = "🛒 PEGAR"
				buyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
			end)
		end
	end)
end

createShopButton()
print("🚗 UltraCarShop v2 carregado!")