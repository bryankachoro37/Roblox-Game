-- 🔗 Inicialização de RemoteEvents
-- Cria estrutura de comunicação cliente-servidor

local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🔗 Inicializando RemoteEvents...")

-- Criar pasta Remotes
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

print("📁 Pasta Remotes criada")

-- Criar RemoteEvents necessários
local events = {
    "OpenInventory"
}

for _, eventName in ipairs(events) do
    local remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = eventName
    remoteEvent.Parent = remotes
end

print("📡 RemoteEvents criados:")
for _, eventName in ipairs(events) do
    print("   - " .. eventName)
end

print("✅ RemoteEvents inicializados com sucesso!")
print("🔗 Comunicação cliente-servidor pronta para uso")
