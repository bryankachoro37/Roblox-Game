-- ECONOMY SYSTEM - BRAINROT THEMED (FIXED)
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Data Stores
local moneyDataStore = DataStoreService:GetDataStore("PlayerMoney")
local brainrotDataStore = DataStoreService:GetDataStore("PlayerBrainrot")

-- Remote Events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("OnServerEvent")

-- Configuração inicial
local STARTER_MONEY = 1000
local STARTER_BRAINROT = 100

-- Tabela para armazenar dados dos jogadores
local playerData = {}

print("🧠 Economy System iniciando...")
print("💰 Moeda: Coins | 🧠 Brainrot Points")

-- Função para atualizar rank do jogador
local function updatePlayerRank(player)
    local userId = tostring(player.UserId)
    local data = playerData[userId]
    
    if not data then return end
    
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    
    local rankValue = leaderstats:FindFirstChild("🎭 Sigma Rank")
    if not rankValue then return end
    
    -- Calcular rank baseado em money + brainrot
    local totalScore = data.money + (data.brainrot * 10) -- Brainrot vale 10x mais
    
    local newRank = "🔹 New Sigma"
    
    if totalScore >= 1000000 then
        newRank = "👑 Ultimate Sigma"
    elseif totalScore >= 500000 then
        newRank = "🔥 Mega Sigma"
    elseif totalScore >= 100000 then
        newRank = "⚡ Super Sigma"
    elseif totalScore >= 50000 then
        newRank = "💎 Elite Sigma"
    elseif totalScore >= 10000 then
        newRank = "🌟 Pro Sigma"
    elseif totalScore >= 5000 then
        newRank = "✨ Skilled Sigma"
    elseif totalScore >= 1000 then
        newRank = "🎯 Average Sigma"
    end
    
    rankValue.Value = newRank
end

-- Função para criar leaderstats
local function createLeaderstats(player)
    -- Remover leaderstats existentes
    local existingLeaderstats = player:FindFirstChild("leaderstats")
    if existingLeaderstats then
        existingLeaderstats:Destroy()
    end
    
    -- Criar nova pasta leaderstats
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    -- Criar stat de Coins com tema brainrot
    local coins = Instance.new("IntValue")
    coins.Name = "💰 Coins"
    coins.Value = STARTER_MONEY
    coins.Parent = leaderstats
    
    -- Criar stat de Brainrot Points
    local brainrot = Instance.new("IntValue")
    brainrot.Name = "🧠 Brainrot"
    brainrot.Value = STARTER_BRAINROT
    brainrot.Parent = leaderstats
    
    -- Criar stat de Rank com tema brainrot
    local rank = Instance.new("StringValue")
    rank.Name = "🎭 Sigma Rank"
    rank.Value = "🔹 New Sigma"
    rank.Parent = leaderstats
    
    print("📊 Leaderstats criados para: " .. player.Name)
    
    return leaderstats
end

-- Função para carregar dados do jogador
local function loadPlayerData(player)
    local userId = tostring(player.UserId)
    
    -- Carregar dinheiro (com tratamento de erro para Studio)
    local money = STARTER_MONEY
    local brainrotPoints = STARTER_BRAINROT
    
    -- Só tentar carregar DataStore se não estiver no Studio
    if game:GetService("RunService"):IsStudio() == false then
        local success, result = pcall(function()
            return moneyDataStore:GetAsync(userId)
        end)
        if success and result then
            money = result
        end
        
        local success2, result2 = pcall(function()
            return brainrotDataStore:GetAsync(userId)
        end)
        if success2 and result2 then
            brainrotPoints = result2
        end
    end
    
    -- Inicializar dados do jogador
    playerData[userId] = {
        money = money,
        brainrot = brainrotPoints,
        transactions = {},
        lastSave = os.time()
    }
    
    -- Criar leaderstats
    local leaderstats = createLeaderstats(player)
    
    -- Atualizar valores nos leaderstats
    leaderstats:FindFirstChild("💰 Coins").Value = playerData[userId].money
    leaderstats:FindFirstChild("🧠 Brainrot").Value = playerData[userId].brainrot
    
    -- Atualizar rank baseado nos valores
    updatePlayerRank(player)
    
    print("💾 Dados carregados para: " .. player.Name)
    print("💰 Coins: " .. playerData[userId].money)
    print("🧠 Brainrot: " .. playerData[userId].brainrot)
end

-- Função para salvar dados do jogador
local function savePlayerData(player)
    local userId = tostring(player.UserId)
    local data = playerData[userId]
    
    if not data then return end
    
    -- Só salvar se não estiver no Studio
    if game:GetService("RunService"):IsStudio() then
        print("💾 Studio detectado - ignorando salvamento em DataStore")
        return
    end
    
    -- Salvar dinheiro
    if game:GetService("RunService"):IsStudio() then
        warn("🔧 Studio detectado - ignorando salvamento no DataStore")
        return
    end
    
    local success, errorMessage = pcall(function()
        moneyDataStore:SetAsync(userId, data.money)
    end)
    
    if not success then
        warn("❌ Erro ao salvar dinheiro de " .. player.Name .. ": " .. errorMessage)
    end
    
    -- Salvar brainrot points
    local success2, errorMessage2 = pcall(function()
        brainrotDataStore:SetAsync(userId, data.brainrot)
    end)
    
    if not success2 then
        warn("❌ Erro ao salvar brainrot de " .. player.Name .. ": " .. errorMessage2)
    end
    
    if success and success2 then
        print("💾 Dados salvos para: " .. player.Name)
    end
end

-- Função para adicionar dinheiro
local function addMoney(player, amount, reason)
    local userId = tostring(player.UserId)
    local data = playerData[userId]
    
    if not data then return false end
    
    data.money = data.money + amount
    
    -- Atualizar leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local coins = leaderstats:FindFirstChild("💰 Coins")
        if coins then
            coins.Value = data.money
        end
    end
    
    -- Registrar transação
    table.insert(data.transactions, {
        type = "money",
        amount = amount,
        reason = reason or "Unknown",
        timestamp = os.time()
    })
    
    -- Atualizar rank
    updatePlayerRank(player)
    
    -- Notificar jogador
    remoteEvents:FireClient(player, "MoneyUpdated", {
        amount = amount,
        newTotal = data.money,
        reason = reason
    })
    
    print("💰 " .. player.Name .. " ganhou $" .. amount .. " (" .. (reason or "Unknown") .. ")")
    return true
end

-- Função para remover dinheiro
local function removeMoney(player, amount, reason)
    local userId = tostring(player.UserId)
    local data = playerData[userId]
    
    if not data then return false end
    
    if data.money < amount then
        return false -- Saldo insuficiente
    end
    
    data.money = data.money - amount
    
    -- Atualizar leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local coins = leaderstats:FindFirstChild("💰 Coins")
        if coins then
            coins.Value = data.money
        end
    end
    
    -- Registrar transação
    table.insert(data.transactions, {
        type = "money",
        amount = -amount,
        reason = reason or "Unknown",
        timestamp = os.time()
    })
    
    -- Atualizar rank
    updatePlayerRank(player)
    
    -- Notificar jogador
    remoteEvents:FireClient(player, "MoneyUpdated", {
        amount = -amount,
        newTotal = data.money,
        reason = reason
    })
    
    print("💸 " .. player.Name .. " perdeu $" .. amount .. " (" .. (reason or "Unknown") .. ")")
    return true
end

-- Função para adicionar brainrot points
local function addBrainrot(player, amount, reason)
    local userId = tostring(player.UserId)
    local data = playerData[userId]
    
    if not data then return false end
    
    data.brainrot = data.brainrot + amount
    
    -- Atualizar leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local brainrot = leaderstats:FindFirstChild("🧠 Brainrot")
        if brainrot then
            brainrot.Value = data.brainrot
        end
    end
    
    -- Registrar transação
    table.insert(data.transactions, {
        type = "brainrot",
        amount = amount,
        reason = reason or "Unknown",
        timestamp = os.time()
    })
    
    -- Atualizar rank
    updatePlayerRank(player)
    
    -- Notificar jogador
    remoteEvents:FireClient(player, "BrainrotUpdated", {
        amount = amount,
        newTotal = data.brainrot,
        reason = reason
    })
    
    print("🧠 " .. player.Name .. " ganhou " .. amount .. " brainrot points (" .. (reason or "Unknown") .. ")")
    return true
end

-- Função para remover brainrot points
local function removeBrainrot(player, amount, reason)
    local userId = tostring(player.UserId)
    local data = playerData[userId]
    
    if not data then return false end
    
    if data.brainrot < amount then
        return false -- Saldo insuficiente
    end
    
    data.brainrot = data.brainrot - amount
    
    -- Atualizar leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local brainrot = leaderstats:FindFirstChild("🧠 Brainrot")
        if brainrot then
            brainrot.Value = data.brainrot
        end
    end
    
    -- Registrar transação
    table.insert(data.transactions, {
        type = "brainrot",
        amount = -amount,
        reason = reason or "Unknown",
        timestamp = os.time()
    })
    
    -- Atualizar rank
    updatePlayerRank(player)
    
    -- Notificar jogador
    remoteEvents:FireClient(player, "BrainrotUpdated", {
        amount = -amount,
        newTotal = data.brainrot,
        reason = reason
    })
    
    print("🧠 " .. player.Name .. " perdeu " .. amount .. " brainrot points (" .. (reason or "Unknown") .. ")")
    return true
end

-- Função para obter saldo do jogador
local function getPlayerBalance(player)
    local userId = tostring(player.UserId)
    local data = playerData[userId]
    
    if not data then
        return {
            money = 0,
            brainrot = 0
        }
    end
    
    return {
        money = data.money,
        brainrot = data.brainrot
    }
end

-- Eventos de jogador
Players.PlayerAdded:Connect(function(player)
    print("👤 Jogador entrou: " .. player.Name)
    loadPlayerData(player)
end)

Players.PlayerRemoving:Connect(function(player)
    print("👋 Jogador saindo: " .. player.Name)
    savePlayerData(player)
    
    -- Limpar dados da memória
    local userId = tostring(player.UserId)
    playerData[userId] = nil
end)

-- Auto-salvar periódico
coroutine.wrap(function()
    while true do
        wait(60) -- Salvar a cada 1 minuto
        
        for _, player in ipairs(Players:GetPlayers()) do
            savePlayerData(player)
        end
        
        print("💾 Auto-salvo concluído para todos os jogadores online")
    end
end)()

-- Event handlers para remote events
remoteEvents.OnServerEvent:Connect(function(player, eventName, ...)
    if eventName == "GetBalance" then
        local balance = getPlayerBalance(player)
        remoteEvents:FireClient(player, "BalanceReceived", balance)
        
    elseif eventName == "PurchaseItem" then
        local itemCost = select(1, ...)
        local itemType = select(2, ...) or "money"
        
        if itemType == "money" then
            local success = removeMoney(player, itemCost, "Purchase")
            remoteEvents:FireClient(player, "PurchaseResult", success)
        elseif itemType == "brainrot" then
            local success = removeBrainrot(player, itemCost, "Purchase")
            remoteEvents:FireClient(player, "PurchaseResult", success)
        end
        
    elseif eventName == "AddMoney" then
        -- Para administradores/testes
        local amount = select(1, ...)
        local reason = select(2, ...) or "Admin"
        addMoney(player, amount, reason)
        
    elseif eventName == "AddBrainrot" then
        -- Para administradores/testes
        local amount = select(1, ...)
        local reason = select(2, ...) or "Admin"
        addBrainrot(player, amount, reason)
    end
end)

-- Sistema de recompensas automáticas (tempo online)
coroutine.wrap(function()
    while true do
        wait(300) -- A cada 5 minutos
        
        for _, player in ipairs(Players:GetPlayers()) do
            -- Recompensa por tempo online
            addMoney(player, 50, "Online Time Bonus")
            addBrainrot(player, 10, "Online Time Bonus")
        end
    end
end)()

-- Exportar funções para outros sistemas
_G.EconomySystem = {
    addMoney = addMoney,
    removeMoney = removeMoney,
    addBrainrot = addBrainrot,
    removeBrainrot = removeBrainrot,
    getPlayerBalance = getPlayerBalance,
    updatePlayerRank = updatePlayerRank
}

print("💰 Economy System carregado completamente!")
print("🎮 Jogadores agora podem usar Coins e Brainrot Points!")
