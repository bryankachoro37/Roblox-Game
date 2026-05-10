local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local mainMenuGui = script.Parent

local function setupLobbyCamera()
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(
		Vector3.new(0, 50, 0),
		Vector3.new(0, 0, 0)
	)
end

local function restoreCamera(character)
	local humanoid = character:WaitForChild("Humanoid")

	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = humanoid
end

local function playButtonAction()
	mainMenuGui.Enabled = false

	local character = player.Character
	if character then
		restoreCamera(character)
	end
end

player.CharacterAdded:Connect(restoreCamera)

setupLobbyCamera()