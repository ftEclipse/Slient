if getgenv().FwSilent then
	return getgenv().FwSilent 
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local CharacterAdded = LocalPlayer.CharacterAdded
local CharacterAddedWait = CharacterAdded.Wait

local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local FindFirstChildWhichIsA = Instance.new("Part").FindFirstChildWhichIsA
local IsDescendantOf = Instance.new("Part").IsDescendantOf
local FindFirstChild = Instance.new("Part").FindFirstChild

getgenv().FwSilent = {
	SilentAimEnabled = true,

	ShowFOV = false,
	FOV = 17,
	FOVSides = 700,
	FOVColour = Color3.fromRGB(255, 255, 255),

	VisibleCheck = true,

	HitChance = 125,

	Selected = nil,
	SelectedPart = nil,

	TargetPart = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "RightFoot", "LeftFoot", "RightLeg", "RightLowerLeg", "RightUpperArm", "LeftUpperArm", "LeftUpperLeg", "RightUpperLeg", "LeftLeg", "LeftLowerLeg", "LeftArm", "RightArm", "RightLowerArm","LeftLowerArm", "LeftHand", "RightHand"},

	Ignored = {
		Teams = {
			{
				Team = LocalPlayer.Team,
				TeamColor = LocalPlayer.TeamColor,
			},
		},
		Players = {
			LocalPlayer,
			3508651141
		}
	}
}
local FwSilent = getgenv().FwSilent

local circle = Drawing.new("Circle")
circle.Transparency = 0.4
circle.Thickness = 0.8
circle.Color = FwSilent.FOVColour
circle.Filled = false
FwSilent.FOVCircle = circle

function FwSilent.UpdateFOV()
	if not (circle) then
		return
	end

	circle.Visible = FwSilent.ShowFOV
	circle.Radius = (FwSilent.FOV * 3)
	circle.Position = Vector2.new(Mouse.X, Mouse.Y + GuiService.GetGuiInset(GuiService).Y)
	circle.NumSides = FwSilent.FOVSides
	circle.Color = FwSilent.FOVColour

	return circle
end

local CalcChance = function(percentage)
	percentage = math.floor(percentage)

	local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100

	return chance <= percentage / 100
end

function FwSilent.IsPartVisible(Part, PartDescendant)
	local Character = LocalPlayer.Character or CharacterAddedWait(CharacterAdded)
	local Origin = CurrentCamera.CFrame.Position
	local _, OnScreen = CurrentCamera.WorldToViewportPoint(CurrentCamera, Part.Position)

	if (OnScreen) then
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = EnumRaycastFilterTypeBlacklist
		raycastParams.FilterDescendantsInstances = {Character, CurrentCamera}

		local Result = Workspace.Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)

		if (Result) then
			local PartHit = Result.Instance
			local Visible = (not PartHit or IsDescendantOf(PartHit, PartDescendant))

			return Visible
		end
	end
	return false
end

function FwSilent.IgnorePlayer(Player)
	local Ignored = FwSilent.Ignored
	local IgnoredPlayers = Ignored.Players

	for _, IgnoredPlayer in ipairs(IgnoredPlayers) do
		if (IgnoredPlayer == Player) then
			return false
		end
	end

	table.insert(IgnoredPlayers, Player)
	return true
end

function FwSilent.UnIgnorePlayer(Player)
	local Ignored = FwSilent.Ignored
	local IgnoredPlayers = Ignored.Players

	for i, IgnoredPlayer in ipairs(IgnoredPlayers) do
		if (IgnoredPlayer == Player) then
			table.remove(IgnoredPlayers, i)
			return true
		end
	end

	return false
end

function FwSilent.IgnoreTeam(Team, TeamColor)
	local Ignored = FwSilent.Ignored
	local IgnoredTeams = Ignored.Teams

	for _, IgnoredTeam in ipairs(IgnoredTeams) do
		if (IgnoredTeam.Team == Team and IgnoredTeam.TeamColor == TeamColor) then
			return false
		end
	end

	table.insert(IgnoredTeams, {Team, TeamColor})
	return true
end

function FwSilent.UnIgnoreTeam(Team, TeamColor)
	local Ignored = FwSilent.Ignored
	local IgnoredTeams = Ignored.Teams

	for i, IgnoredTeam in ipairs(IgnoredTeams) do
		if (IgnoredTeam.Team == Team and IgnoredTeam.TeamColor == TeamColor) then
			table.remove(IgnoredTeams, i)
			return true
		end
	end

	return false
end

function FwSilent.TeamCheck(Toggle)
	if (Toggle) then
		return FwSilent.IgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
	end

	return FwSilent.UnIgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
end

function FwSilent.IsIgnoredTeam(Player)
	local Ignored = FwSilent.Ignored
	local IgnoredTeams = Ignored.Teams

	for _, IgnoredTeam in ipairs(IgnoredTeams) do
		if (Player.Team == IgnoredTeam.Team and Player.TeamColor == IgnoredTeam.TeamColor) then
			return true
		end
	end
	return false
end

function FwSilent.IsIgnored(Player)
	local Ignored = FwSilent.Ignored
	local IgnoredPlayers = Ignored.Players

	for _, IgnoredPlayer in ipairs(IgnoredPlayers) do
		if (typeof(IgnoredPlayer) == "number" and Player.UserId == IgnoredPlayer) then
			return true
		end

		if (IgnoredPlayer == Player) then
			return true
		end
	end
	return FwSilent.IsIgnoredTeam(Player)
end

function FwSilent.Raycast(Origin, Destination, UnitMultiplier)
	if (typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3") then
		if (not UnitMultiplier) then
			UnitMultiplier = 1 
		end
		
		local Direction = (Destination - Origin).Unit * UnitMultiplier
		local Result = Workspace.Raycast(Workspace, Origin, Direction)

		if (Result) then
			local Normal = Result.Normal
			local Material = Result.Material

			return Direction, Normal, Material
		end
	end
	return nil
end

function FwSilent.Character(Player)
	return Player.Character
end

function FwSilent.CheckHealth(Player)
	local Character = FwSilent.Character(Player)
	local Humanoid = FindFirstChildWhichIsA(Character, "Humanoid")

	local Health = (Humanoid and Humanoid.Health or 0)

	return Health > 0
end

function FwSilent.Check()
	return (FwSilent.Enabled == true and FwSilent.Selected ~= LocalPlayer and FwSilent.SelectedPart ~= nil)
end

FwSilent.checkSilentAim = FwSilent.Check

function FwSilent.GetClosestTargetPartToCursor(Character)
	local TargetParts = FwSilent.TargetPart
	
	local ClosestPart = nil
	local ClosestPartPosition = nil
	local ClosestPartOnScreen = false
	local ClosestPartMagnitudeFromMouse = nil
	local ShortestDistance = 1/0

	local function CheckTargetPart(TargetPart)
		if (typeof(TargetPart) == "string") then
			TargetPart = FindFirstChild(Character, TargetPart)
		end

		if not (TargetPart) then
			return
		end

		local PartPos, onScreen = CurrentCamera.WorldToViewportPoint(CurrentCamera, TargetPart.Position)
		local GuiInset = GuiService.GetGuiInset(GuiService)
		local Magnitude = (Vector2.new(PartPos.X, PartPos.Y - GuiInset.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

		if (Magnitude < ShortestDistance) then
			ClosestPart = TargetPart
			ClosestPartPosition = PartPos
			ClosestPartOnScreen = onScreen
			ClosestPartMagnitudeFromMouse = Magnitude
			ShortestDistance = Magnitude
		end
	end

	if (typeof(TargetParts) == "string") then
		if (TargetParts == "All") then
			for _, v in ipairs(Character:GetChildren()) do
				if not (v:IsA("BasePart")) then
					continue
				end

				CheckTargetPart(v)
			end
		else
			CheckTargetPart(TargetParts)
		end
	end

	if (typeof(TargetParts) == "table") then
		for _, TargetPartName in ipairs(TargetParts) do
			CheckTargetPart(TargetPartName)
		end
	end
	return ClosestPart, ClosestPartPosition, ClosestPartOnScreen, ClosestPartMagnitudeFromMouse
end

function FwSilent.GetClosestPlayerToCursor()
	local TargetPart = nil
	local ClosestPlayer = nil
	local Chance = CalcChance(FwSilent.HitChance)
	local ShortestDistance = 1/0

	if (not Chance) then
		FwSilent.Selected = LocalPlayer
		FwSilent.SelectedPart = nil

		return LocalPlayer
	end

	for _, Player in ipairs(Players.GetPlayers(Players)) do
		local Character = FwSilent.Character(Player)
		
		if (FwSilent.IsIgnored(Player) == false and Character) then
			local TargetPartTemp, _, _, Magnitude = FwSilent.GetClosestTargetPartToCursor(Character)
			
			if (TargetPartTemp and FwSilent.CheckHealth(Player)) then
				
				if (circle.Radius > Magnitude and Magnitude < ShortestDistance) then

					if (FwSilent.VisibleCheck and not FwSilent.IsPartVisible(TargetPartTemp, Character)) then
						continue 
					end

					ClosestPlayer = Player
					ShortestDistance = Magnitude
					TargetPart = TargetPartTemp
				end
			end
		end
	end
	FwSilent.Selected = ClosestPlayer
	FwSilent.SelectedPart = TargetPart
end

RunService.Heartbeat:Connect(function()
	FwSilent.UpdateFOV()
	FwSilent.GetClosestPlayerToCursor()
end)

return FwSilent
