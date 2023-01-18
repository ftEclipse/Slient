--[[
 . -.-. .-.. .. .--. ... .
██████  ███████  ██     ██  ██████████    ████████    ███████
██      ██       ██         ██      ██  ██            ██
████    ██       ██     ██  ██████████    ███████     ██████
██      ██       ██     ██  ██                   ██   ██
██████  ███████  █████  ██  ██           █████████    ███████

   Eclipse's Legit Slient
]]

if getgenv().fwSilent then return getgenv().fwSilent end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local GetGuiInset = GuiService.GetGuiInset
local CharacterAdded = LocalPlayer.CharacterAdded
local CharacterAddedWait = CharacterAdded.Wait
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local GetPlayers = Players.GetPlayers
local IsDescendantOf = Instance.new("Part").IsDescendantOf
local FindFirstChildWhichIsA = Instance.new("Part").FindFirstChildWhichIsA
local FindFirstChild = Instance.new("Part").FindFirstChild

getgenv().fwSilent = {
	SilentAimEnabled = true,
	ShowFOV = false,
	FOVSides = 700,
	VisibleCheck = true,
	TeamCheck = false,
	FOV = 25,
	HitChance = 195,
	Selected = LocalPlayer,
	SelectedPart = nil,
	TargetPart = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "RightFoot", "LeftFoot", "RightLeg", "RightLowerLeg", "RightUpperArm", "LeftUpperArm", "LeftUpperLeg", "RightUpperLeg", "LeftLeg", "LeftLowerLeg", "LeftArm", "RightArm", "RightLowerArm","LeftLowerArm", "LeftHand", "RightHand"},
	BlacklistedTeams = {
		{
			Team = LocalPlayer.Team,
			TeamColor = LocalPlayer.TeamColor,
		},
	},
	BlacklistedPlayers = {LocalPlayer},
	WhitelistedPUIDs = {3508651141},
}
local fwSilent = getgenv().fwSilent

local circle = Drawing.new("Circle")
circle.Transparency = 1
circle.Thickness = 2
circle.Color = Color3.fromRGB(255, 255, 255)
circle.Filled = false

function fwSilent.updateCircle()
	if (circle) then
		circle.Visible = fwSilent.ShowFOV
		circle.Radius = (fwSilent.FOV * 3)
		circle.Position = Vector2.new(Mouse.X, Mouse.Y + GetGuiInset(GuiService).Y)
		circle.NumSides = fwSilent.FOVSides
		return circle
	end
end

local calcChance = function(percentage)
	percentage = math.floor(percentage)
	local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
	return chance <= percentage / 100
end

function fwSilent.isPartVisible(Part, PartDescendant)
	local Character = LocalPlayer.Character or CharacterAddedWait(CharacterAdded)
	local Origin = CurrentCamera.CFrame.Position
	local _, OnScreen = WorldToViewportPoint(CurrentCamera, Part.Position)

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

function fwSilent.BlacklistPlayer(Player)
	local BlacklistedPlayers = fwSilent.BlacklistedPlayers

	for i = 1, #BlacklistedPlayers do
		local BlacklistedPlayer = BlacklistedPlayers[i]

		if (BlacklistedPlayer == Player) then
			return false
		end
	end

	BlacklistedPlayers[#BlacklistedPlayers + 1] = Player
	return true
end

function fwSilent.UnblacklistPlayer(Player)
	local BlacklistedPlayers = fwSilent.BlacklistedPlayers

	for i = 1, #BlacklistedPlayers do
		local BlacklistedPlayer = BlacklistedPlayers[i]

		if (BlacklistedPlayer == Player) then
			table.remove(BlacklistedPlayer, i)
			return true
		end
	end
	return false
end

function fwSilent.WhitelistPlayer(PlayerId)
	local WhitelistedPUIDs = fwSilent.WhitelistedPUIDs

	for i = 1, #WhitelistedPUIDs do
		local WhitelistedPUID = WhitelistedPUIDs[i]

		if (WhitelistedPUID == PlayerId) then
			return false
		end
	end

	WhitelistedPUIDs[#WhitelistedPUIDs + 1] = PlayerId
	return true
end

function fwSilent.UnwhitelistPlayer(PlayerId)
	local WhitelistedPUIDs = fwSilent.WhitelistedPUIDs

	for i = 1, #WhitelistedPUIDs do
		local WhitelistedPUID = WhitelistedPUIDs[i]

		if (WhitelistedPUID == PlayerId) then
			table.remove(WhitelistedPUID, i)
			return true
		end
	end
	return false
end

function fwSilent.findDirectionNormalMaterial(Origin, Destination, UnitMultiplier)
	if (typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3") then
		
		if (not UnitMultiplier) then UnitMultiplier = 1 end

		local Direction = (Destination - Origin).Unit * UnitMultiplier
		local RaycastResult = Workspace.Raycast(Workspace, Origin, Direction)

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
	local Humanoid = FindFirstChildWhichIsA(Character, "Humanoid")

	local Health = (Humanoid and Humanoid.Health or 0)
	return Health > 0
end

function fwSilent.checkSilentAim()
	return (fwSilent.SilentAimEnabled == true and fwSilent.Selected ~= LocalPlayer and fwSilent.SelectedPart ~= nil)
end

function fwSilent.getClosestTargetPartToCursor(Character)
	local TargetParts = fwSilent.TargetPart

	local ClosestPart = nil
	local ClosestPartPosition = nil
	local ClosestPartOnScreen = false
	local ClosestPartMagnitudeFromMouse = nil
	local ShortestDistance = 1/0

	local function checkTargetPart(TargetPartName)
		local TargetPart = FindFirstChild(Character, TargetPartName)

		if (TargetPart) then
			local PartPos, onScreen = WorldToViewportPoint(CurrentCamera, TargetPart.Position)
			local Magnitude = (Vector2.new(PartPos.X, PartPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

			if (Magnitude < ShortestDistance) then
				ClosestPart = TargetPart
				ClosestPartPosition = PartPos
				ClosestPartOnScreen = onScreen
				ClosestPartMagnitudeFromMouse = Magnitude
				ShortestDistance = Magnitude
			end
		end
	end

	
	if (typeof(TargetParts) == "string") then
		checkTargetPart(TargetParts)
	end

	if (typeof(TargetParts) == "table") then
		for i = 1, #TargetParts do
			local TargetPartName = TargetParts[i]
			checkTargetPart(TargetPartName)
		end
	end
	return ClosestPart, ClosestPartPosition, ClosestPartOnScreen, ClosestPartMagnitudeFromMouse
end


function fwSilent.getClosestPlayerToCursor()
	local TargetPart = nil
	local ClosestPlayer = nil
	local Chance = calcChance(fwSilent.HitChance)
	local ShortestDistance = 1/0

	if (not Chance) then
		fwSilent.Selected = LocalPlayer
		fwSilent.SelectedPart = nil

		return LocalPlayer
	end

	local AllPlayers = GetPlayers(Players)
	for i = 1, #AllPlayers do
		local Player = AllPlayers[i]
		local Character = fwSilent.getCharacter(Player)

		if (not fwSilent.checkWhitelisted(Player) and fwSilent.checkPlayer(Player) and Character) then
			local TargetPartTemp, PartPos, onScreen, Magnitude = fwSilent.getClosestTargetPartToCursor(Character)

			if (TargetPartTemp and fwSilent.checkHealth(Player)) then
				
				if (fwSilent.TeamCheck and not fwSilent.checkTeam(Player, LocalPlayer)) then
					continue
				end
				
				if (circle.Radius > Magnitude and Magnitude < ShortestDistance) then
					
					if (fwSilent.VisibleCheck and not fwSilent.isPartVisible(TargetPartTemp, Character)) then 
						continue
					end
					ClosestPlayer = Player
					ShortestDistance = Magnitude
					TargetPart = TargetPartTemp
				end
			end
		end
	end
	fwSilent.Selected = ClosestPlayer
	fwSilent.SelectedPart = TargetPart
end

Heartbeat:Connect(function()
	fwSilent.updateCircle()
	fwSilent.getClosestPlayerToCursor()
end)

return fwSilent
