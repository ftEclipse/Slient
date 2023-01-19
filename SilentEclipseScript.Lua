if getgenv().fwSilent then
	return getgenv().fwSilent
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

getgenv().fwSilent = {
	SilentAimEnabled = true,
	ShowFOV = true,
	VisibleCheck = true,
	TeamCheck = false,
	FOV = 25,
	FOVSides = 700,
	HitChance = 195,
	FOVColour = Color3.fromRGB(255, 255, 255),
	Selected = LocalPlayer,
	TargetPart = "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "RightFoot", "LeftFoot", "RightLeg", "RightLowerLeg", "RightUpperArm", "LeftUpperArm", "LeftUpperLeg", "RightUpperLeg", "LeftLeg", "LeftLowerLeg", "LeftArm", "RightArm", "RightLowerArm","LeftLowerArm", "LeftHand", "RightHand",
	BlacklistedTeams = {
		{
			Team = LocalPlayer.Team,
			TeamColor = LocalPlayer.TeamColor,
		},
	},
	BlacklistedPlayers = {LocalPlayer},
	WhitelistedPUIDs = {},
}

local circle = Drawing.new("Circle")
circle.Transparency = 1
circle.Thickness = 1.7
circle.Color = fwSilent.FOVColour
circle.Filled = false

function fwSilent.updateCircle()
	if not (circle) then
		return
	end
	
	circle.Visible = fwSilent.ShowFOV
	circle.Radius = (fwSilent.FOV * 3)
	circle.Position = Vector2.new(Mouse.X, Mouse.Y + GuiService:GetGuiInset().Y)
	circle.NumSides = fwSilent.FOVSides
	circle.Color = fwSilent.FOVColour
	
	return circle
end

calcChance = function(percentage)
	percentage = math.floor(percentage)
	local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
	return chance <= percentage/100
end

function fwSilent.isPartVisible(Part, PartDescendant)
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Origin = CurrentCamera.CFrame.Position
	local _, OnScreen = CurrentCamera:WorldToViewportPoint(Part.Position)

	if (OnScreen) then
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {Character, CurrentCamera}

		local Result = Workspace:Raycast(Origin, Part.Position - Origin, raycastParams)
		local PartHit = Result.Instance
		local Visible = (not PartHit or PartHit:IsDescendantOf(PartDescendant))
		
		return Visible
	end
	return false
end

function fwSilent.checkTeam(targetPlayerA, targetPlayerB)
	if (targetPlayerA.Team ~= targetPlayerB.Team) then
		
		for i = 1, #fwSilent.BlacklistedTeams do
			local v = fwSilent.BlacklistedTeams

			if (targetPlayerA.Team ~= v.Team and targetPlayerA.TeamColor ~= v.TeamColor) then
				return true
			end
		end
	end
	return false
end

function fwSilent.checkPlayer(targetPlayer)
	for i = 1, #fwSilent.BlacklistedPlayers do
		local v = fwSilent.BlacklistedPlayers[i]

		if (v ~= targetPlayer) then
			return true
		end
	end
	return false
end

function fwSilent.checkWhitelisted(targetPlayer)
	for i = 1, #fwSilent.WhitelistedPUIDs do
		local v = fwSilent.WhitelistedPUIDs[i]

		if (targetPlayer.UserId == v) then
			return true
		end
	end
	return false
end

function fwSilent.findDirectionNormalMaterial(Origin, Destination, UnitMultiplier)
	if (typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3") then
		if (not UnitMultiplier) then 
			UnitMultiplier = 1
		end
		local Direction = (Destination - Origin).Unit * UnitMultiplier
		local RaycastResult = Workspace:Raycast(Origin, Direction)

		if (RaycastResult ~= nil) then
			local Normal = RaycastResult.Normal
			local Material = RaycastResult.Material
			return Direction, Normal, Material
		end
	end
	return nil
end

function fwSilent.getCharacter(Player)
	return Player.Character
end

function fwSilent.checkHealth(Player)
	local Character = fwSilent.getCharacter(Player)
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")

	local Health = (Humanoid and Humanoid.Health or 0)
	return Health > 0
end

function fwSilent.checkSilentAim()
	return (fwSilent.SilentAimEnabled == true and fwSilent.Selected ~= LocalPlayer)
end

function fwSilent.getClosestPlayerToCursor()
	local ClosestPlayer = nil
	local Chance = calcChance(fwSilent.HitChance)
	local ShortestDistance = 1/0

	if (not Chance) then
		fwSilent.Selected = (Chance and LocalPlayer or LocalPlayer)
		return (Chance and LocalPlayer or LocalPlayer)
	end
	
	local AllPlayers = Players:GetPlayers()
	for i = 1, #AllPlayers do
		local Player = AllPlayers[i]
		local Character = fwSilent.getCharacter(Player)

		if (not fwSilent.checkWhitelisted(Player) and fwSilent.checkPlayer(Player) and Character and Character:FindFirstChild(fwSilent.TargetPart) and fwSilent.checkHealth(Player)) then
			if (fwSilent.TeamCheck and not fwSilent.checkTeam(Player, LocalPlayer)) then 
				continue
			end

			local TargetPart = Character[fwSilent.TargetPart]
			local PartPos, _ = CurrentCamera:WorldToViewportPoint(TargetPart.Position)
			local Magnitude = (Vector2.new(PartPos.X, PartPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

			if (circle.Radius > Magnitude and Magnitude < ShortestDistance) then
				if (fwSilent.VisibleCheck and not fwSilent.isPartVisible(TargetPart, Character)) then
					continue
				end
				ClosestPlayer = Player
				ShortestDistance = Magnitude
			end
		end
	end
	fwSilent.Selected = (Chance and ClosestPlayer or LocalPlayer)
end

Heartbeat:Connect(function()
	fwSilent.updateCircle()
	fwSilent.getClosestPlayerToCursor()
end)

return fwSilent
