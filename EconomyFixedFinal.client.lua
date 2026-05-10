-- ECONOMY FIXED FINAL - FUNCIONAL
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("OnServerEvent")

-- Variável para controlar UI
local economyUI = nil

-- Função para criar UI
local function createEconomyUI()
    -- Remover UI existente
    if economyUI then
        economyUI:Destroy()
    end
    
    -- Criar ScreenGui
    economyUI = Instance.new("ScreenGui")
    economyUI.Name = "EconomyFixedUI"
    economyUI.Parent = playerGui
    
    -- Frame principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.3, 0, 0.4, 0)
    frame.Position = UDim2.new(0.02, 0, 0.58, 0) -- Posição (canto superior esquerdo)
    frame.BackgroundColor3 = Color3.fromRGB(45, 0, 45)
    frame.BorderSizePixel = 0
    frame.Parent = economyUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🧠 SIGMA WALLET 🧠"
    title.TextColor3 = Color3.fromRGB(255, 0, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Saldo
    local balanceLabel = Instance.new("TextLabel")
    balanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
    balanceLabel.Position = UDim2.new(0, 0, 0.2, 0)
    balanceLabel.BackgroundTransparency = 1
    balanceLabel.Text = "💰 Coins: 1000\n🧠 Brainrot: 100"
    balanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    balanceLabel.TextScaled = true
    balanceLabel.Font = Enum.Font.GothamBold
    balanceLabel.Parent = frame
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.9, 0, 0.85, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "❌"
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = frame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        if economyUI then
            economyUI:Destroy()
            economyUI = nil
        end
    end)
    
    print("💰 Sigma Wallet aberta!")
end

-- Atalho de teclado (tecla B) - Toggle com verificação de UIs abertas
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
        -- Verificar se há outras UIs abertas
        local hasOpenUI = false
        
        -- Verificar Car Shop
        for _, child in ipairs(playerGui:GetChildren()) do
            if child.Name == "UltraCarShopUI" and child.Enabled then
                hasOpenUI = true
                break
            end
        end
        
        -- Verificar Menu de Som
        local soundMenu = playerGui:FindFirstChild("SoundMenuGui")
        if soundMenu then
            local soundMenuFrame = soundMenu:FindFirstChild("SoundMenu")
            if soundMenuFrame and soundMenuFrame.Visible then
                hasOpenUI = true
            end
        end
        
        if economyUI and economyUI.Parent then
            -- Fechar
            economyUI:Destroy()
            economyUI = nil
            print("💰 Sigma Wallet fechada!")
        elseif not hasOpenUI then
            -- Abrir Sigma Wallet
            createEconomyUI()
        else
            print("🚫 Outra UI já está aberta!")
        end
    end
end)

print("💰 Economy Fixed Final carregado!")
