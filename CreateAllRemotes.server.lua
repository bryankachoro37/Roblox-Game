-- ServerScriptService > CreateAllRemotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Espera um pouco para evitar conflito com outros scripts
task.wait(1)

local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function create(name)
    local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
    r.Name = name
    r.Parent = remotes
    return r
end

create("StartHack")
create("HackResult")
create("HackInput")
create("OpenInventory")
create("BrainrotInteract")

print("✅ [CreateAllRemotes] Todos os RemoteEvents criados com sucesso!")