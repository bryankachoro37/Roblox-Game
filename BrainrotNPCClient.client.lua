-- StarterPlayerScripts > NPCClient
-- CORRIGIDO:
--   1. Removidas todas as chamadas a attackNPC (função removida mas ainda referenciada)
--   2. weaponGui removida do CharacterRemoving (variável nunca declarada → crash nil)
--   3. onMouseClick limpa: sem referência a função inexistente

local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local npcIndicators = {}

-- Função para obter posição do NPC
local function getNPCPosition(npc)
    if npc.PrimaryPart then
        return npc.PrimaryPart.Position
    elseif npc:FindFirstChild("HumanoidRootPart") then
        return npc.HumanoidRootPart.Position
    elseif npc:FindFirstChild("Body") then
        return npc.Body.Position
    else
        for _, part in ipairs(npc:GetChildren()) do
            if part:IsA("BasePart") then
                return part.Position
            end
        end
        return npc:GetPivot().Position
    end
end

-- Criar indicador de NPC (BillboardGui)
local function createNPCIndicator(npc)
    local indicator = Instance.new("BillboardGui")
    indicator.Name         = "BrainrotIndicator"
    indicator.Size         = UDim2.new(0, 100, 0, 50)
    indicator.StudsOffset  = Vector3.new(0, 3, 0)
    indicator.AlwaysOnTop  = true

    local frame = Instance.new("Frame")
    frame.Size                 = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3     = Color3.new(0.2, 0.2, 0.2)
    frame.BorderSizePixel      = 0
    frame.Parent               = indicator

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size               = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text               = "Brainrot Lvl ?"
    nameLabel.TextColor3         = Color3.new(1, 1, 1)
    nameLabel.TextScaled         = true
    nameLabel.Font               = Enum.Font.SourceSansBold
    nameLabel.Parent             = frame

    local healthBar = Instance.new("Frame")
    healthBar.Size             = UDim2.new(0.8, 0, 0.3, 0)
    healthBar.Position         = UDim2.new(0.1, 0, 0.6, 0)
    healthBar.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    healthBar.BorderSizePixel  = 0
    healthBar.Parent           = frame

    local healthFill = Instance.new("Frame")
    healthFill.Size             = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    healthFill.BorderSizePixel  = 0
    healthFill.Parent           = healthBar

    local humanoid = npc:FindFirstChild("Humanoid")
    if humanoid then
        indicator.Parent = humanoid

        -- Tentar obter nível pelo nome do NPC
        local npcName = npc.Name
        local level = string.match(npcName, "_(%d+)$")
        if level then
            level = tonumber(level)
            nameLabel.Text = "Brainrot Lvl " .. level

            local colors = {
                [1] = Color3.new(0.5, 0.5, 1),
                [2] = Color3.new(0.2, 0.8, 0.2),
                [3] = Color3.new(0.8, 0.2, 0.8),
                [4] = Color3.new(1, 0.5, 0),
                [5] = Color3.new(1, 0.2, 0.2),
            }
            frame.BackgroundColor3 = colors[level] or Color3.new(0.2, 0.2, 0.2)
        end

        -- Atualizar barra de vida
        humanoid.HealthChanged:Connect(function()
            local pct = humanoid.Health / humanoid.MaxHealth
            healthFill.Size = UDim2.new(pct, 0, 1, 0)

            if pct < 0.3 then
                healthFill.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
            elseif pct < 0.6 then
                healthFill.BackgroundColor3 = Color3.new(0.8, 0.8, 0.2)
            else
                healthFill.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
            end
        end)
    end

    return indicator
end

-- Atualizar todos os indicadores
local function updateNPCIndicators()
    for _, indicator in pairs(npcIndicators) do
        if indicator then indicator:Destroy() end
    end
    npcIndicators = {}

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name:match("BrainrotNPC_") and obj:FindFirstChild("Humanoid") then
            npcIndicators[obj] = createNPCIndicator(obj)
        end
    end
end

-- Inicializar sistema
local function initialize()
    task.spawn(function()
        while true do
            updateNPCIndicators()
            task.wait(1)
        end
    end)

    print("🧠 NPCClient iniciado!")
end

player.CharacterAdded:Wait()
initialize()

-- CORRIGIDO: removida referência a weaponGui (nunca existiu)
player.CharacterRemoving:Connect(function()
    for _, indicator in pairs(npcIndicators) do
        if indicator then indicator:Destroy() end
    end
    npcIndicators = {}
end)
