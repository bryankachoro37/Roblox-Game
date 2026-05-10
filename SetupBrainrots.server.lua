local ReplicatedStorage = game:GetService("ReplicatedStorage")

local brainrotFolder = ReplicatedStorage:WaitForChild("Brainrots")

for _, model in ipairs(brainrotFolder:GetChildren()) do

	if model:IsA("Model") then

		local root =
			model:FindFirstChild("HumanoidRootPart", true)
			or model:FindFirstChild("RootPart", true)
			or model:FindFirstChild("Torso", true)
			or model:FindFirstChild("UpperTorso", true)

		if root and root:IsA("BasePart") then

			model.PrimaryPart = root

			print("PrimaryPart definida para:", model.Name)

		else

			warn("❌ Nenhuma RootPart encontrada:", model.Name)

		end
	end
end