-- INIT REMOTE EVENTS
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🔗 Inicializando RemoteEvents...")

-- Criar pasta para RemoteEvents
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
    remoteEventsFolder = Instance.new("Folder")
    remoteEventsFolder.Name = "RemoteEvents"
    remoteEventsFolder.Parent = ReplicatedStorage
    print("📁 Pasta RemoteEvents criada")
end

-- Criar RemoteEvent principal
local mainRemoteEvent = remoteEventsFolder:FindFirstChild("OnServerEvent")
if not mainRemoteEvent then
    mainRemoteEvent = Instance.new("RemoteEvent")
    mainRemoteEvent.Name = "OnServerEvent"
    mainRemoteEvent.Parent = remoteEventsFolder
    print("📡 RemoteEvent OnServerEvent criado")
end

print("✅ RemoteEvents inicializados com sucesso!")
print("🔗 Comunicação cliente-servidor pronta para uso")
