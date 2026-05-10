-- RUN SYSTEM BRAINROT - RESTAURADO
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Variáveis de corrida
local isRunning = false
local isShiftPressed = false
local runSpeed = 30 -- Velocidade de corrida
local walkSpeed = 16 -- Velocidade normal
local humanoid = nil
local originalWalkSpeed = 0

-- Animações brainrot temáticas (IDs que funcionam)
local brainrotAnimations = {
    -- Animações de dança brainrot
    507766666, -- Roblox Run Animation
    507766744, -- Roblox Run Animation 2
    507766765, -- Roblox Run Animation 3
    507766766, -- Roblox Run Animation 4
    507766767, -- Roblox Run Animation 5
    -- Animações de emote brainrot
    507770176, -- Emote 1
    507770177, -- Emote 2
    507770178, -- Emote 3
    507770179, -- Emote 4
    507770180, -- Emote 5
}

local currentAnimation = nil
local animationTrack = nil

-- Esperar personagem
local function waitForCharacter()
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    humanoid = character:WaitForChild("Humanoid")
    originalWalkSpeed = humanoid.WalkSpeed
    
    return character
end

-- Criar animação de corrida brainrot
local function createRunAnimation()
    if not humanoid then return end
    
    local randomAnimId = brainrotAnimations[math.random(1, #brainrotAnimations)]
    
    local success, animation = pcall(function()
        return Instance.new("Animation")
    end)
    
    if success and animation then
        animation.AnimationId = "rbxassetid://" .. randomAnimId
        
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        
        animationTrack = animator:LoadAnimation(animation)
        currentAnimation = animation
        
        print("🧠 Animação Brainrot iniciada! ID:", randomAnimId)
    end
end

-- Parar animação de corrida
local function stopRunAnimation()
    if animationTrack then
        animationTrack:Stop()
        animationTrack = nil
    end
    
    if currentAnimation then
        currentAnimation:Destroy()
        currentAnimation = nil
    end
    
    print("🛑 Animação Brainrot parada!")
end

-- REMOVIDO: Efeitos visuais de corrida desativados
local function createRunEffects(character)
    -- Função vazia - sem efeitos visuais
end

-- REMOVIDO: Remoção de efeitos visuais de corrida
local function removeRunEffects(character)
    -- Função vazia - sem efeitos para remover
end

-- Iniciar corrida
local function startRunning()
    if isRunning or not humanoid then return end
    
    isRunning = true
    humanoid.WalkSpeed = runSpeed
    
    createRunAnimation()
    
    print("🛑 Corrida Brainrot ativada!")
end

-- Parar corrida
local function stopRunning()
    if not isRunning then return end
    
    isRunning = false
    humanoid.WalkSpeed = originalWalkSpeed
    
    stopRunAnimation()
    
    print("🛑 Corrida Brainrot desativada!")
end

-- Detectar input do usuário
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.LeftShift then
        isShiftPressed = true
        startRunning()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.LeftShift then
        isShiftPressed = false
        stopRunning()
    end
end)

-- Verificar se o jogador está parado
RunService.Heartbeat:Connect(function()
    if not humanoid then return end
    
    if isRunning and humanoid.MoveDirection.Magnitude == 0 then
        -- Pausar animação se estiver parado
        if animationTrack then
            animationTrack:AdjustSpeed(0)
        end
    elseif isRunning and humanoid.MoveDirection.Magnitude > 0 then
        -- Retomar animação se estiver se movendo
        if animationTrack then
            animationTrack:AdjustSpeed(1)
        end
    end
end)

-- Inicializar sistema
local character = waitForCharacter()

-- Conectar eventos de personagem
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    originalWalkSpeed = humanoid.WalkSpeed
    
    if isShiftPressed then
        startRunning()
    end
end)

print("🧠 Run System Brainrot carregado!")
print("💡 Aperte e segure SHIFT para correr com animações brainrot!")
