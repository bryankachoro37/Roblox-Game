local RunService = game:GetService("RunService")
local folder = workspace:WaitForChild("SpawnedBrainrots")

local movePositions = {
	Vector3.new(112.122, 34.05, 130.651),
	Vector3.new(135.478, 34.05, 55.909),
	Vector3.new(-18.59, 34.05, 11.343),
	Vector3.new(-42.317, 34.09, 179.605),
	Vector3.new(171.036, 33.93, 157.737),
	Vector3.new(238.377, 34.05, 62.343),
	Vector3.new(329.32, 33.431, 274.243),
	Vector3.new(173.171, 33.431, 357.844),
	Vector3.new(177.919, 33.431, 177.243),
}

local activeBrainrots = {}

local function getRandomPosition(currentPosition)
	if #movePositions == 0 then return nil end

	local target = movePositions[math.random(1, #movePositions)]

	if currentPosition and #movePositions > 1 then
		local tries = 0
		while (target - currentPosition).Magnitude < 5 and tries < 10 do
			target = movePositions[math.random(1, #movePositions)]
			tries += 1
		end
	end

	return target
end

local function getGroundY(x, z, ignoreModel)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {ignoreModel}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(
		Vector3.new(x, 200, z),
		Vector3.new(0, -500, 0),
		rayParams
	)

	return result and result.Position.Y or nil
end

local function moveBrainrot(brainrot)
	if not brainrot:IsA("Model") then return end
	if activeBrainrots[brainrot] then return end
	activeBrainrots[brainrot] = true

	task.spawn(function()
		task.wait(0.5)

		local rootPart = brainrot.PrimaryPart
		if not rootPart then
			activeBrainrots[brainrot] = nil
			return
		end

		local homePositionXZ = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
		local level = brainrot:GetAttribute("Level") or 1

		-- mais rápido
		local npcSpeed = 14 + ((level - 1) * 0.5)

		local boxCf, boxSize = brainrot:GetBoundingBox()
		local pivotOffset = rootPart.Position.Y - (boxCf.Position.Y - boxSize.Y / 2)

		local wanderSteps = 0
		local maxStepsBeforeHome = math.random(5, 8)

		while brainrot.Parent and rootPart.Parent do
			-- espera enquanto alguém está hackeando
			local waited = 0
			while (brainrot:GetAttribute("HackCount") or 0) > 0 and brainrot.Parent do
				task.wait(0.4)
				waited += 0.4

				-- fail-safe
				if waited > 60 then
					brainrot:SetAttribute("HackCount", 0)
					break
				end
			end

			if brainrot:GetAttribute("Captured") then
				break
			end

			if not brainrot.Parent or not rootPart.Parent then
				break
			end

			local targetXZ
			local returningHome = false

			if wanderSteps >= maxStepsBeforeHome then
				targetXZ = homePositionXZ
				returningHome = true
				wanderSteps = 0
				maxStepsBeforeHome = math.random(5, 8)
			else
				local randTarget = getRandomPosition(rootPart.Position)
				if randTarget then
					targetXZ = Vector3.new(randTarget.X, 0, randTarget.Z)
					wanderSteps += 1
				else
					targetXZ = homePositionXZ
					returningHome = true
				end
			end

			local groundY = getGroundY(targetXZ.X, targetXZ.Z, brainrot)
			local finalTarget = groundY
				and Vector3.new(targetXZ.X, groundY + pivotOffset + 0.1, targetXZ.Z)
				or Vector3.new(targetXZ.X, rootPart.Position.Y, targetXZ.Z)

			local startPos = rootPart.Position
			local distance = (finalTarget - startPos).Magnitude

			if distance > 1 then
				local duration = distance / npcSpeed
				local elapsed = 0
				local lookCFrame = CFrame.lookAt(startPos, Vector3.new(finalTarget.X, startPos.Y, finalTarget.Z))

				while elapsed < duration and brainrot.Parent and rootPart.Parent do
					if brainrot:GetAttribute("Captured") then break end
					if (brainrot:GetAttribute("HackCount") or 0) > 0 then break end

					local dt = RunService.Heartbeat:Wait()
					elapsed += dt
					local alpha = math.min(elapsed / duration, 1)

					local currentPos = startPos:Lerp(finalTarget, alpha)
					rootPart.CFrame = CFrame.new(currentPos) * (lookCFrame - lookCFrame.Position)
				end
			end

			if returningHome then
				task.wait(math.random(3, 5))
			else
				task.wait(math.random(1, 2))
			end
		end

		activeBrainrots[brainrot] = nil
	end)
end

for _, brainrot in ipairs(folder:GetChildren()) do
	moveBrainrot(brainrot)
end

folder.ChildAdded:Connect(function(brainrot)
	moveBrainrot(brainrot)
end)

folder.ChildRemoved:Connect(function(brainrot)
	activeBrainrots[brainrot] = nil
end)

print("✅ Movement system ativo")