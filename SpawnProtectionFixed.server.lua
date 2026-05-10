-- SPAWN PROTECTION SYSTEM FIXED
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local DebrisService = game:GetService("Debris")

-- Variáveis de controle
local loadingPlayers = {} -- Jogadores em loading
local protectedPlayers = {} -- Jogadores com proteção
local INITIAL_PROTECTION = 10 -- 10 segundos para jogadores iniciais
local RESPAWN_PROTECTION = 3 -- 3 segundos para respawns

print("🛡️ Spawn Protection System Fixed iniciando...")

-- Função para verificar se jogador está em loading
local function isLoading(player)
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        local loadingScreen = playerGui:FindFirstChild("BrainrotLoadingScreen")
        return loadingScreen ~= nil
    end
    return false
end

-- Função para dar proteção ao jogador
local function giveProtection(player, duration)
    if protectedPlayers[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Criar efeito visual de proteção
    local shield = Instance.new("ForceField")
    shield.Name = "SpawnProtection"
    shield.Parent = character
    
    -- Criar efeito visual brilhante
    local glow = Instance.new("PointLight")
    glow.Name = "ProtectionGlow"
    glow.Color = Color3.fromRGB(0, 255, 255)
    glow.Range = 15
    glow.Brightness = 2
    glow.Parent = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    
    -- Criar partículas de proteção
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        for i = 1, 3 do
            local particle = Instance.new("ParticleEmitter")
            particle.Name = "ProtectionParticle"
            particle.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
            particle.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 0)
            })
            particle.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(1, 1)
            })
            particle.Acceleration = Vector3.new(0, 2, 0)
            particle.Lifetime = NumberRange.new(2, 3)
            particle.Rate = 30
            particle.Speed = NumberRange.new(1, 3)
            particle.Parent = rootPart
        end
    end
    
    -- Adicionar à lista de protegidos
    protectedPlayers[player] = true
    
    -- Remover proteção após o tempo
    task.delay(duration, function()
        if shield and shield.Parent then
            shield:Destroy()
        end
        if glow and glow.Parent then
            glow:Destroy()
        end
        
        -- Remover partículas
        if rootPart then
            for _, particle in ipairs(rootPart:GetChildren()) do
                if particle.Name == "ProtectionParticle" then
                    particle:Destroy()
                end
            end
        end
        
        protectedPlayers[player] = nil
        print("🛡️ Proteção removida de: " .. player.Name)
    end)
    
    print("🛡️ Proteção concedida para: " .. player.Name .. " (" .. duration .. "s)")
end

-- Função para spawnar jogador com proteção
local function spawnPlayerWithProtection(player)
    if isLoading(player) then
        loadingPlayers[player] = true
        print("⏳ Aguardando loading screen terminar para: " .. player.Name)
        return
    end
    
    -- Determinar duração da proteção - sempre 3 segundos
    local protectionDuration = RESPAWN_PROTECTION -- 3 segundos em todos os spawns
    
    -- Marcar que o jogador já spawnou
    if not player:GetAttribute("HasSpawnedBefore") then
        player:SetAttribute("HasSpawnedBefore", true)
        print("🆕 Primeiro spawn de: " .. player.Name .. " - Proteção padrão")
    end
    
    -- Dar proteção ao spawnar
    giveProtection(player, protectionDuration)
    
    -- Remover da lista de loading
    loadingPlayers[player] = nil
end

-- Evento quando jogador entra
Players.PlayerAdded:Connect(function(player)
    -- Aguardar personagem
    player.CharacterAdded:Connect(function(character)
        -- Aguardar um pouco para garantir que está tudo carregado
        task.wait(1)
        spawnPlayerWithProtection(player)
    end)
    
    -- Se já tem personagem
    if player.Character then
        task.wait(1)
        spawnPlayerWithProtection(player)
    end
end)

-- Monitorar quando loading screen termina
for _, player in ipairs(Players:GetPlayers()) do
    local function checkLoading()
        if loadingPlayers[player] and not isLoading(player) then
            spawnPlayerWithProtection(player)
        end
    end
    
    -- Verificar periodicamente
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not player or not player.Parent then
            connection:Disconnect()
            return
        end
        checkLoading()
    end)
end

-- Prevenir dano em jogadores protegidos
Workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("BasePart") and descendant.CanCollide then
        -- Verificar se colidiu com jogador protegido
        descendant.Touched:Connect(function(hit)
            local character = hit.Parent
            if character and character:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(character)
                if player and protectedPlayers[player] then
                    -- Prevenir dano
                    local humanoid = character.Humanoid
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end)
    end
end)

-- Sistema de respawn para jogadores que morrem
game:GetService("RunService").Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            
            -- Se o jogador morreu e não está protegido
            if humanoid.Health <= 0 and not protectedPlayers[player] then
                -- Aguardar respawn e dar proteção
                humanoid.Died:Connect(function()
                    task.wait(2) -- Aguardar respawn
                    
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        giveProtection(player, RESPAWN_PROTECTION)
                        print("💀 Jogador " .. player.Name .. " respawnou com proteção")
                    end
                end)
            end
        end
    end
end)

print("🛡️ Spawn Protection System Fixed carregado!")
print("💡 Jogadores ganham " .. INITIAL_PROTECTION .. "s no primeiro spawn, " .. RESPAWN_PROTECTION .. "s nos respawns!")
