-- SPAWN BRAINROT SYSTEM
print("🧠 Spawn Brainrot System iniciando...")

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Música será controlada pelo cliente após loading screen
local function createBackgroundMusic()
    -- Não criar música aqui - será gerenciada pelo MusicToggle.client.lua
    print("🎵 Música será iniciada pelo cliente após loading screen")
    return nil
end

-- Função para criar GUI de boas-vindas (removida)
local function createWelcomeGUI(player)
    -- GUI removida - não será criada
    print("🧠 GUI de boas-vindas removida!")
end

-- Conectar eventos
print("🔗 Conectando eventos de jogador...")
Players.PlayerAdded:Connect(function(player)
    print("👤 Jogador entrou: " .. player.Name)
    player.CharacterAdded:Connect(function(char)
        print("🎮 Personagem spawnou para: " .. player.Name)
        task.wait(1) -- Usar task.wait em vez de wait
        -- GUI removida - não será criada
        print("🧠 GUI de boas-vindas não será exibida!")
    end)
end)

-- Música será gerenciada pelo cliente após loading screen
print("🎵 Aguardando loading screen terminar para iniciar música")

print("🧠 Spawn Brainrot System carregado completamente!")

