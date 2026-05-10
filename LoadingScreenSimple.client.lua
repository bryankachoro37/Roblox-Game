-- LOADING SCREEN SIMPLE - SEM TRAVAMENTOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variáveis de controle
local loadingGui = nil

-- Criar tela de carregamento simples
local function createLoadingScreen()
    -- Remover GUI existente
    if loadingGui then
        loadingGui:Destroy()
    end
    
    loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "BrainrotLoadingScreen"
    loadingGui.IgnoreGuiInset = true
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingGui.Parent = playerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 0, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = loadingGui
    
    -- Gradiente
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 128)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 0, 130))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- Título
    local gameTitle = Instance.new("TextLabel")
    gameTitle.Size = UDim2.new(0.8, 0, 0.15, 0)
    gameTitle.Position = UDim2.new(0.1, 0, 0.15, 0)
    gameTitle.BackgroundTransparency = 1
    gameTitle.Text = "🧠 BRAINROT ROLEPLAYING CITY 🧠"
    gameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    gameTitle.TextScaled = true
    gameTitle.Font = Enum.Font.GothamBold
    gameTitle.Parent = mainFrame
    
    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0.6, 0, 0.08, 0)
    subtitle.Position = UDim2.new(0.2, 0, 0.35, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "CARREGANDO MUNDO BRAINROT..."
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    -- Barra de progresso
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0.6, 0, 0.02, 0)
    progressBar.Position = UDim2.new(0.2, 0, 0.5, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = mainFrame
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBar
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 10)
    progressCorner.Parent = progressBar
    
    -- Dicas
    local tipLabel = Instance.new("TextLabel")
    tipLabel.Size = UDim2.new(0.7, 0, 0.1, 0)
    tipLabel.Position = UDim2.new(0.15, 0, 0.6, 0)
    tipLabel.BackgroundTransparency = 1
    tipLabel.Text = "💡 DICA: Use SHIFT para correr • B para Sigma Wallet • E para emotes"
    tipLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    tipLabel.TextScaled = true
    tipLabel.Font = Enum.Font.Gotham
    tipLabel.TextWrapped = true
    tipLabel.Parent = mainFrame
    
    -- Animação da barra de progresso
    local progressTween = TweenService:Create(progressFill, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
        Size = UDim2.new(1, 0, 1, 0)
    })
    progressTween:Play()
    
    print("🧠 Loading Screen Simple criada!")
end

-- Função para fechar loading screen
local function closeLoadingScreen()
    if not loadingGui then return end
    
    print("🧠 Iniciando animação de slide-out da Loading Screen...")
    
    local mainFrame = loadingGui:FindFirstChild("Frame")
    
    -- Animação de slide-out rápido para a esquerda
    local slideTween = TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(-1, 0, 0.5, 0),
        BackgroundTransparency = 1
    })
    
    -- Animação do título junto com o slide
    local titleLabel = mainFrame and mainFrame:FindFirstChildOfClass("TextLabel")
    if titleLabel then
        local titleTween = TweenService:Create(titleLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(-1.1, 0, -0.1, 0),
            TextTransparency = 1
        })
        titleTween:Play()
    end
    
    -- Animação da barra de progresso junto com o slide
    local progressBar = mainFrame and mainFrame:FindFirstChild("Frame")
    if progressBar then
        local progressFill = progressBar:FindFirstChildOfClass("Frame")
        if progressFill then
            local progressTween = TweenService:Create(progressFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(-0.5, 0, 0, 0)
            })
            progressTween:Play()
        end
    end
    
    -- Iniciar animação principal de slide
    slideTween:Play()
    
    -- Destruir após animação completar
    spawn(function()
        slideTween.Completed:Wait()
        
        -- Destruir GUI imediatamente
        if loadingGui then
            loadingGui:Destroy()
            loadingGui = nil
        end
        
        -- Limpeza completa de resíduos
        local playerGui = player:WaitForChild("PlayerGui")
        local residualGui = playerGui:FindFirstChild("BrainrotLoadingScreen")
        if residualGui then
            residualGui:Destroy()
            print("🧹 GUI residual removida!")
        end
        
        -- Limpar todos os filhos que possam ter ficado
        for _, child in ipairs(playerGui:GetChildren()) do
            if child:IsA("ScreenGui") and child.Name:find("Loading") then
                child:Destroy()
                print("🧹 GUI de loading residual removida: " .. child.Name)
            end
        end
        
        print("🧠 Loading Screen removida com slide-out!")
    end)
end

-- Permitir fechar manualmente com ESC
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape then
        if loadingGui then
            closeLoadingScreen()
        end
    end
end)

-- Criar loading screen
createLoadingScreen()

-- Fechar automaticamente após 5 segundos
print("🕐 Iniciando contagem de 5 segundos...")
task.wait(5)
closeLoadingScreen()

print("🧠 Loading Screen Simple carregada!")
print("💡 Pressione ESC para pular carregamento")
print("📊 Loading Screen destruída - Jogador pode spawnar agora!")
