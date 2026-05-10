local ReplicatedStorage = game:GetService("ReplicatedStorage")

task.wait(1)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local hackProgress = remotes:FindFirstChild("HackProgress")
if not hackProgress then
	hackProgress = Instance.new("RemoteEvent")
	hackProgress.Name = "HackProgress"
	hackProgress.Parent = remotes
end

hackProgress.OnServerEvent:Connect(function(player, action, value)
	if not player then return end
	-- Apenas devolve para o próprio jogador (efeitos visuais locais)
	hackProgress:FireClient(player, action, value)
end)

print("🎬 HackProgressBridge ativo")