-- RemoteEvents System (ModuleScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local function createRemote(name)
    local remote = remotesFolder:FindFirstChild(name) or Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = remotesFolder
    return remote
end

createRemote("StartHack")
createRemote("HackInput")
createRemote("HackResult")
createRemote("OpenInventory")
createRemote("BrainrotInteract")

print("✅ RemoteEvents do Hack Mental criados!")

return remotesFolder