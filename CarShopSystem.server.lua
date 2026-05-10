-- ServerScriptService > CarShopSystem
-- CORRIGIDO:
--   1. remoteEvents apontava para OnServerEvent e depois chamava .OnServerEvent novamente
--      → agora separa corretamente o folder do RemoteEvent
--   2. IDs dos carros alinhados com o que o cliente envia ("car_1", "car_2"...)
--      O cliente envia "car_" .. índice; o servidor agora mapeia por índice também

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

-- CORRIGIDO: pegar o RemoteEvent correto
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local mainRemote         = remoteEventsFolder:WaitForChild("OnServerEvent") -- RemoteEvent

local CAR_CONFIG = {
    { id = "car_1", name = "Taxi",               price = 0, model = "Taxi",                color = Color3.fromRGB(255, 204, 0)   },
    { id = "car_2", name = "Red Hatchback",       price = 0, model = "Red Hatchback",       color = Color3.fromRGB(255, 0, 0)     },
    { id = "car_3", name = "Police Car",          price = 0, model = "Police Car",          color = Color3.fromRGB(0, 0, 128)     },
    { id = "car_4", name = "Green Station Wagon", price = 0, model = "Green Station Wagon", color = Color3.fromRGB(0, 128, 0)     },
    { id = "car_5", name = "Blue Sedan",          price = 0, model = "Blue Sedan",          color = Color3.fromRGB(0, 100, 200)   },
    { id = "car_6", name = "Blue Pickup",         price = 0, model = "Blue Pickup",         color = Color3.fromRGB(0, 50, 150)    },
    { id = "car_7", name = "Blue Box Truck",      price = 0, model = "Blue Box Truck",      color = Color3.fromRGB(70, 130, 180)  },
}

local playerCars = {}

print("🚗 CarShopSystem iniciando... (" .. #CAR_CONFIG .. " carros)")

local function getCarConfig(carId)
    for _, car in ipairs(CAR_CONFIG) do
        if car.id == carId then return car end
    end
    return nil
end

local function playerOwnsCar(player, carId)
    local uid = tostring(player.UserId)
    if not playerCars[uid] then return false end
    for _, id in ipairs(playerCars[uid]) do
        if id == carId then return true end
    end
    return false
end

local function giveCarToPlayer(player, carId)
    local uid = tostring(player.UserId)
    local cfg = getCarConfig(carId)
    if not cfg then
        warn("❌ Carro não encontrado: " .. carId)
        return false
    end

    playerCars[uid] = playerCars[uid] or {}
    table.insert(playerCars[uid], carId)

    mainRemote:FireClient(player, "CarPurchased", {
        carId   = carId,
        carName = cfg.name,
        success = true,
    })

    print("🚗 " .. player.Name .. " recebeu: " .. cfg.name)
    return true
end

local function spawnPlayerCar(player, carId)
    local cfg = getCarConfig(carId)
    if not cfg then return false end
    if not playerOwnsCar(player, carId) then return false end

    local current = Workspace:FindFirstChild(player.Name .. "_Car")
    if current then current:Destroy() end

    local carModel = Workspace:FindFirstChild(cfg.model)
    if not carModel then
        warn("❌ Modelo não encontrado no Workspace: " .. cfg.model)
        return false
    end

    local newCar = carModel:Clone()
    newCar.Name   = player.Name .. "_Car"
    newCar.Parent = Workspace

    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        newCar:PivotTo(CFrame.new(pos + Vector3.new(5, 0, 0)))
    end

    newCar:SetAttribute("Owner", player.UserId)

    mainRemote:FireClient(player, "CarSpawned", {
        carId   = carId,
        carName = cfg.name,
        success = true,
    })

    print("🚗 " .. player.Name .. " spawnou: " .. cfg.name)
    return true
end

-- CORRIGIDO: .OnServerEvent no RemoteEvent correto
mainRemote.OnServerEvent:Connect(function(player, eventName, ...)
    if eventName == "PurchaseCar" then
        local carId = select(1, ...)
        local cfg   = getCarConfig(carId)

        if not cfg then
            mainRemote:FireClient(player, "CarPurchaseResult", { success = false, message = "Carro não encontrado" })
            return
        end

        if playerOwnsCar(player, carId) then
            mainRemote:FireClient(player, "CarPurchaseResult", { success = false, message = "Você já tem esse carro" })
            return
        end

        -- Carros são gratuitos (price = 0); verifica EconomySystem se houver preço
        if cfg.price > 0 and _G.EconomySystem then
            local bal = _G.EconomySystem.getPlayerBalance(player)
            if bal.money < cfg.price then
                mainRemote:FireClient(player, "CarPurchaseResult", { success = false, message = "Coins insuficientes" })
                return
            end
            _G.EconomySystem.removeMoney(player, cfg.price, "Car Purchase: " .. cfg.name)
        end

        giveCarToPlayer(player, carId)
        mainRemote:FireClient(player, "CarPurchaseResult", {
            success = true, carId = carId, carName = cfg.name, message = "Comprado!"
        })

    elseif eventName == "SpawnCar" then
        local carId = select(1, ...)
        spawnPlayerCar(player, carId)

    elseif eventName == "RemoveCar" then
        local current = Workspace:FindFirstChild(player.Name .. "_Car")
        if current then
            current:Destroy()
            mainRemote:FireClient(player, "CarRemoved", { success = true })
        end

    elseif eventName == "GetCarShopData" then
        mainRemote:FireClient(player, "CarShopDataReceived", CAR_CONFIG)

    elseif eventName == "GetPlayerCars" then
        local uid  = tostring(player.UserId)
        mainRemote:FireClient(player, "PlayerCarsReceived", playerCars[uid] or {})
    end
end)

Players.PlayerAdded:Connect(function(player)
    playerCars[tostring(player.UserId)] = {}
end)

Players.PlayerRemoving:Connect(function(player)
    local current = Workspace:FindFirstChild(player.Name .. "_Car")
    if current then current:Destroy() end
    playerCars[tostring(player.UserId)] = nil
end)

_G.CarShopSystem = {
    getCarConfig     = getCarConfig,
    playerOwnsCar    = playerOwnsCar,
    giveCarToPlayer  = giveCarToPlayer,
    spawnPlayerCar   = spawnPlayerCar,
}

print("🏪 CarShopSystem carregado!")
