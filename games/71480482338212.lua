local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
local Notify = Library.newNotify();

--Config
local ConfigManager = Library:ConfigManager({Directory = "SmokerV4/games", Config = "Bedwarz"});
Library:Loader(getcustomasset("SmokerV4/Assets/newlogo.png"), 2.5):yield()

--Library
local SmokerV4 = Library.new({Name="Smoker | Bedwarz",Keybind="RightShift",Logo=getcustomasset("SmokerV4/Assets/icon.png"),Scale=Library.Scale.Window,TextSize=15})

--Notification
Notify.new({Title = "SmokerV4",Content = "Thank you for use this script!", Duration = 10, Icon = getcustomasset("SmokerV4/Assets/icon.png")});

--Watermark
local Watermark = SmokerV4:Watermark();
Watermark:AddText({Icon = "user",Text = game.Players.LocalPlayer.Name});
local Time = Watermark:AddText({Icon = "timer",Text = "TIME"});
Watermark:AddText({Icon = "clock",Text = Library:GetDate()});
Watermark:AddText({Icon = "server",Text = Library.Version});

task.spawn(function()
	while true do task.wait()
		Time:SetText(Library:GetTimeNow());
	end
end)

--Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local rs = game:GetService("ReplicatedStorage")
local InputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--Windows
SmokerV4:DrawCategory({Name = "Smoker"});

local CombatWindow = SmokerV4:DrawTab({Name = "Combat", Icon = "lucide-swords", EnableScrolling = true});
local UtilityWindow = SmokerV4:DrawTab({Name = "Utility", Icon = "lucide-hammer", EnableScrolling = true});
local MovementWindow = SmokerV4:DrawTab({Name = "Movement", Icon = "lucide-layout-dashboard", EnableScrolling = true});
local VisualWindow = SmokerV4:DrawTab({Name = "Visual", Icon = "lucide-eye", EnableScrolling = true});

--Vars
local NameTagsVar = false
local VibeVar = false
local KAVar,HLon,HUDon,UseDN,MoveHUD=false,false,false,false,false
local HighlightVar = false
local ScaffoldVar = false
local ProjectAimVar = false
local ProjectAimRange = 20
local RangeKA = 20
local NukerVar = false
local TeamCheckVar = false
local TeamColorVar = false
local VelocityVar = false
local FOVVar = false
local FOVVal = 70
local AutoToxicVar = false
local DisplayNameVar = false
local CapeVar = false
local SpeedVar = false

--Colors/Texts/Conns
local KAHighlight = Color3.fromRGB(255, 0, 0)
local wm, WatermarkVar = " | smxkev4", false
local KillConns, BedConns, WinConns = {}, {}, {}
local HLc=Color3.fromRGB(66,135,245)
local HUDc=Color3.fromRGB(25,25,25)
local CapeColor = Color3.fromRGB(0, 0, 0)

--Hud
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local hudGui, listFrame, contentFrame, hudconnect
local activeLabels = {}
local HUDStyle = "Drop"
local HUDEnabled = false
local HUDTextColor = Color3.fromRGB(0, 255, 140)
local HUDLabelColor = Color3.fromRGB(0, 255, 140)

local ForHudVars = {
	["Vibe"] = function() return VibeVar end,
    ["NameTags"] = function() return NameTagsVar end,
    ["ProjectAim"] = function() return ProjectAimVar end,
    ["KillAura"] = function() return KAVar end,
    ["Scaffold"] = function() return ScaffoldVar end,
    ["Nuker"] = function() return NukerVar end,
    ["Velocity"] = function() return VelocityVar end,
    ["FOV"] = function() return FOVVar end,
    ["AutoToxic"] = function() return AutoToxicVar end,
	["Cape"] = function() return CapeVar end,
	["Speed"] = function() return SpeedVar end
}

local function DestroyHUD()
	if hudconnect then
		hudconnect:Disconnect()
		hudconnect = nil
	end
	if hudGui then
		hudGui:Destroy()
		hudGui, listFrame, contentFrame = nil, nil, nil
		activeLabels = {}
	end
end

local function CreateHUD()
	DestroyHUD()

	hudGui = Instance.new("ScreenGui")
	hudGui.Name = "HUDStatus"
	hudGui.Parent = CoreGui
	hudGui.ResetOnSpawn = false

	listFrame = Instance.new("Frame", hudGui)
	listFrame.Size = UDim2.new(0, 200, 0, 300)
	listFrame.Position = HUDStyle == "Drop"
		and UDim2.new(1, -210, 0, 10)
		or UDim2.new(1, -210, 0.3, 0)

	listFrame.BackgroundTransparency = (HUDStyle == "Drop") and 1 or 0.2
	listFrame.BackgroundColor3 = (HUDStyle == "Drop") and Color3.new(0, 0, 0) or Color3.fromRGB(20, 20, 30)
	listFrame.BorderSizePixel = 0
	Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)

	if HUDStyle == "Box" then
		local stroke = Instance.new("UIStroke", listFrame)
		stroke.Color = HUDLabelColor
		stroke.Thickness = 5

		local title = Instance.new("TextLabel", listFrame)
		title.Name = "BoxTitle"
		title.Size = UDim2.new(1, -10, 0, 30)
		title.Position = UDim2.new(0, 5, 0, 5)
		title.BackgroundTransparency = 1
		title.TextColor3 = HUDTextColor
		title.Font = Enum.Font.GothamBold
		title.TextScaled = true
		title.Text = "Smoker Client"
	else
		local header = Instance.new("TextLabel", listFrame)
		header.Name = "DropHeader"
		header.Size = UDim2.new(1, -20, 0, 28)
		header.Position = UDim2.new(0, 10, 0, 0)
		header.BackgroundTransparency = 1
		header.RichText = true
		header.TextScaled = true
		header.Font = Enum.Font.GothamBold
		header.TextColor3 = HUDTextColor
		header.TextXAlignment = Enum.TextXAlignment.Center
		header.TextYAlignment = Enum.TextYAlignment.Center
		header.Text = "<font size='26'>SMOKER</font> <font size='18'>V4</font>"
	end

	contentFrame = Instance.new("ScrollingFrame", listFrame)
	contentFrame.Size = UDim2.new(1, -10, 1, (HUDStyle == "Drop") and -10 or -40)
	contentFrame.Position = UDim2.new(0, 5, 0, (HUDStyle == "Drop") and 30 or 35)
	contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ScrollBarThickness = 4
	contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentFrame.ClipsDescendants = true

	local layout = Instance.new("UIListLayout", contentFrame)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
end

local function UpdateHUD()
	if not contentFrame then return end

	for name, check in pairs(ForHudVars) do
		local enabled = check()
		local existing = activeLabels[name]

		if enabled and not existing then
			local label = Instance.new("TextLabel")
			label.Name = name
			label.Size = UDim2.new(1, 0, 0, 24)
			label.BackgroundTransparency = 1
			label.TextTransparency = 1
			label.Text = name
			label.Font = Enum.Font.GothamSemibold
			label.TextScaled = true
			label.LayoutOrder = #contentFrame:GetChildren()
			label.TextColor3 = HUDLabelColor
			label.Parent = contentFrame

			if HUDStyle == "Drop" then
				local line = Instance.new("Frame")
				line.Name = "ColorLine"
				line.Parent = label
				line.Size = UDim2.new(0, 4, 1, 0)
				line.Position = UDim2.new(1, -4, 0, 0)
				line.AnchorPoint = Vector2.new(1, 0)
				line.BackgroundColor3 = HUDLabelColor
				line.BorderSizePixel = 0
			end

			TweenService:Create(label, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				TextTransparency = 0
			}):Play()

			activeLabels[name] = label
		elseif not enabled and existing then
			activeLabels[name] = nil
			local hide = TweenService:Create(existing, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				TextTransparency = 1
			})
			hide:Play()
			hide.Completed:Connect(function()
				if existing then existing:Destroy() end
			end)
		end
	end
end

local function ApplyColors()
	if not listFrame then return end

	for _, label in pairs(activeLabels) do
		if label and label:IsDescendantOf(game) then
			label.TextColor3 = HUDLabelColor
			local line = label:FindFirstChild("ColorLine")
			if line then
				line.BackgroundColor3 = HUDLabelColor
			end
		end
	end

	if HUDStyle == "Box" then
		local stroke = listFrame:FindFirstChildOfClass("UIStroke")
		if stroke then stroke.Color = HUDLabelColor end
		local title = listFrame:FindFirstChild("BoxTitle")
		if title then title.TextColor3 = HUDTextColor end
	else
		local header = listFrame:FindFirstChild("DropHeader")
		if header then header.TextColor3 = HUDTextColor end
	end
end

local HudSec = VisualWindow:DrawSection({
	Name = "HUD Style",
	Position = "left"
})

HudSec:AddToggle({
	Name = "HUD",
	Flag = "HUD",
	Default = false,
	Callback = function(enabled)
		HUDEnabled = enabled
		if enabled then
			CreateHUD()
		else
			DestroyHUD()
		end
	end
})

HudSec:AddDropdown({
	Name = "HUD Style",
	Default = "Drop",
	Flag = "HUDStyle",
	Values = {"Box", "Drop"},
	Callback = function(selected)
		HUDStyle = selected
		if HUDEnabled then
			CreateHUD()
		end
	end
})

HudSec:AddColorPicker({ 
    Name = "Watermark Color", 
    Default = HUDTextColor,
    Flag = "HUDWaterColor",
    Callback = function(color)
        HUDTextColor = color
        ApplyColors()
    end
})

HudSec:AddColorPicker({ 
    Name = "Hud Color", 
    Default = HUDLabelColor,
    Flag = "HUDColor",
    Callback = function(color)
        HUDLabelColor = color
        ApplyColors()
    end
})

task.spawn(function()
	while task.wait(0.1) do
		if HUDEnabled then
			UpdateHUD()
			ApplyColors()
		end
	end
end)

--Nametags
local NameTagsSec = VisualWindow:DrawSection({Name = "NameTag", Position = "left"})

local connections = {}
local tagColor = Color3.fromRGB(0, 255, 140)

local function getTagColor(player)
    if TeamColorVar and player.Team then
        return player.Team.TeamColor.Color
    else
        return tagColor
    end
end

local function createNameTag(player)
    if player == LocalPlayer then return end
    if connections[player] then
        for _, c in pairs(connections[player]) do
            c:Disconnect()
        end
        connections[player] = nil
    end

    local function setupCharacter(character)
        local head = character:WaitForChild("Head", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not head or not humanoid then return end

        local oldTag = head:FindFirstChild("CustomNametag")
        if oldTag then oldTag:Destroy() end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CustomNametag"
        billboard.Parent = head
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 250, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextStrokeColor3 = Color3.new()
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextColor3 = getTagColor(player)
        textLabel.Text = ""

        local renderConnection = RunService.RenderStepped:Connect(function()
            if not NameTagsVar or humanoid.Health <= 0 then
                textLabel.Text = ""
                return
            end

            local localTeam = LocalPlayer.Team
            local targetTeam = player.Team
            if TeamCheckVar and localTeam and localTeam.Name ~= "Spectators" then
                if localTeam == targetTeam then
                    textLabel.Text = ""
                    return
                end
            end

            textLabel.TextColor3 = getTagColor(player)

            local hp = math.floor(humanoid.Health)
            local maxHp = math.floor(humanoid.MaxHealth)
            local distance = 0

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
            end

            textLabel.Text = string.format("[%d/%d] %s [%dm]", hp, maxHp, player.Name, distance)
        end)

        connections[player] = connections[player] or {}
        table.insert(connections[player], renderConnection)
    end

    local charConn = player.CharacterAdded:Connect(setupCharacter)
    connections[player] = connections[player] or {}
    table.insert(connections[player], charConn)

    if player.Character then
        setupCharacter(player.Character)
    end
end

local function clearAllTags()
    for player, conns in pairs(connections) do
        for _, c in pairs(conns) do
            c:Disconnect()
        end
        connections[player] = nil
        if player.Character and player.Character:FindFirstChild("Head") then
            local tag = player.Character.Head:FindFirstChild("CustomNametag")
            if tag then tag:Destroy() end
        end
    end
end

NameTagsSec:AddToggle({
    Name = "NameTags",
    Flag = "NameTags",
    Default = false,
    Callback = function(enabled)
        NameTagsVar = enabled
        if enabled then
            for _, player in pairs(Players:GetPlayers()) do
                createNameTag(player)
            end
        else
            clearAllTags()
        end
    end
})

NameTagsSec:AddToggle({
    Name = "TeamCheck",
    Flag = "NameTagsTeamCheck",
    Default = false,
    Callback = function(state)
        TeamCheckVar = state
    end
})

NameTagsSec:AddToggle({
    Name = "TeamColor",
    Flag = "NameTagsTeamColor",
    Default = false,
    Callback = function(state)
        TeamColorVar = state
    end
})

NameTagsSec:AddColorPicker({
    Name = "Custom Color",
    Default = Color3.fromRGB(0, 255, 140),
    Flag = "NameTagsColor",
    Callback = function(newColor)
        tagColor = newColor
    end
})

Players.PlayerAdded:Connect(function(player)
    if NameTagsVar then
        createNameTag(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if connections[player] then
        for _, c in pairs(connections[player]) do
            c:Disconnect()
        end
        connections[player] = nil
    end
end)

--Vibe
local VibeSec = VisualWindow:DrawSection({Name = "Vibe",Position = "right"})
local vibeColor = Color3.fromRGB(0, 85, 255)
local function setVibe(state)
    if state then
        Lighting.TimeOfDay = "00:00:00"
        Lighting.Ambient = vibeColor
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        Lighting.Technology = Enum.Technology.Future
    else
        Lighting.TimeOfDay = "14:00:00"
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.Technology = Enum.Technology.Compatibility
    end
end

VibeSec:AddToggle({
    Name = "Vibe",
    Flag = "Vibe",
    Default = false,
    Callback = function(state)
        VibeVar = state
        setVibe(state)
    end
})

VibeSec:AddColorPicker({
    Name = "Color",
    Default = Color3.fromRGB(0, 85, 255),
    Flag = "VibeColor",
    Callback = function(color)
        vibeColor = color
        if VibeVar then
            Lighting.Ambient = color
        end
    end
})

--KillAura
local KAsec = CombatWindow:DrawSection({Name="KillAura",Position="left"})

local curHL,HUD
local r = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("SwordHit")
local sw = {"Wooden Sword","Stone Sword","Iron Sword","Diamond Sword","Emerald Sword"}
local range = 18

local function sword()
	for _, n in ipairs(sw) do
		if LocalPlayer.Backpack:FindFirstChild(n) then return n end
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(n) then return n end
	end
end

local function nearest()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	local root = LocalPlayer.Character.HumanoidRootPart
	local t, dist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
			local lt, tt = LocalPlayer.Team, p.Team
			if lt == nil or lt.Name == "Spectators" or lt ~= tt then
				local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
				if d < dist and d <= range then
					dist, t = d, p
				end
			end
		end
	end
	return t
end

local function hl(t)
	if not HLon or not KAVar then 
		if curHL then curHL:Destroy() curHL = nil end 
		return 
	end
	if not t or not t.Character then 
		if curHL then curHL:Destroy() curHL = nil end 
		return 
	end
	if curHL and curHL.Adornee ~= t.Character then 
		curHL:Destroy() curHL = nil 
	end
	if not curHL then
		local h = Instance.new("Highlight")
		h.Adornee = t.Character
		h.FillColor = HLc
		h.OutlineColor = Color3.new(0,0,0)
		h.Parent = t.Character
		curHL = h
	else
		curHL.FillColor = HLc
	end
end

local function makeHUD()
	local g = Instance.new("ScreenGui", game.CoreGui)
	local f = Instance.new("Frame", g)
	f.Size = UDim2.new(0,180,0,55)
	f.Position = UDim2.new(0.5,-90,0.8,0)
	f.BackgroundColor3 = HUDc
	f.BackgroundTransparency = .2
	f.BorderSizePixel = 0
	Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

	local i = Instance.new("ImageLabel", f)
	i.Size = UDim2.new(0,28,0,28)
	i.Position = UDim2.new(0,6,0,6)
	i.BackgroundTransparency = 1
	i.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=48&h=48"
	i.ScaleType = Enum.ScaleType.Fit

	local n = Instance.new("TextLabel", f)
	n.Size = UDim2.new(1,-45,0,25)
	n.Position = UDim2.new(0,40,0,5)
	n.BackgroundTransparency = 1
	n.TextColor3 = Color3.new(1,1,1)
	n.Font = Enum.Font.GothamBold
	n.TextSize = 16
	n.TextXAlignment = Enum.TextXAlignment.Left
	n.Text = "No target"

	local bg = Instance.new("Frame", f)
	bg.Size = UDim2.new(1,-10,0,8)
	bg.Position = UDim2.new(0,5,0,38)
	bg.BackgroundColor3 = Color3.fromRGB(40,40,40)
	bg.BorderSizePixel = 0
	Instance.new("UICorner", bg)

	local hp = Instance.new("Frame", bg)
	hp.Size = UDim2.new(1,0,1,0)
	hp.BackgroundColor3 = Color3.fromRGB(0,255,0)
	hp.BorderSizePixel = 0
	Instance.new("UICorner", hp)

	local drag, stPos, stFrame
	f.InputBegan:Connect(function(iu)
		if not MoveHUD then return end
		if iu.UserInputType == Enum.UserInputType.MouseButton1 then 
			drag = true 
			stPos = iu.Position 
			stFrame = f.Position 
		end
	end)
	game.UserInputService.InputEnded:Connect(function(iu) 
		if iu.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end 
	end)
	game.UserInputService.InputChanged:Connect(function(iu)
		if drag and MoveHUD and iu.UserInputType == Enum.UserInputType.MouseMovement then
			local d = iu.Position - stPos
			f.Position = UDim2.new(stFrame.X.Scale, stFrame.X.Offset + d.X, stFrame.Y.Scale, stFrame.Y.Offset + d.Y)
		end
	end)

	f.Visible = false
	HUD = {F=f, N=n, HP=hp, I=i}
end

local function delHUD()
	if HUD and HUD.F then
		HUD.F:Destroy()
		HUD = nil
	end
end

local function updHUD(t)
	if not HUD then return end
	if not t or not t.Character or not t.Character:FindFirstChild("Humanoid") or not KAVar then 
		HUD.F.Visible = false 
		return 
	end
	local h = t.Character.Humanoid
	local name = UseDN and t.DisplayName or t.Name
	local hp = math.clamp(h.Health / h.MaxHealth, 0, 1)
	HUD.F.Visible = true
	HUD.N.Text = name
	HUD.I.Image = "rbxthumb://type=AvatarHeadShot&id=" .. t.UserId .. "&w=48&h=48"
	HUD.F.BackgroundColor3 = HUDc
	HUD.HP:TweenSize(UDim2.new(hp,0,1,0), "Out", "Quad", .1, true)
	if hp > .5 then
		HUD.HP.BackgroundColor3 = Color3.fromRGB(0,255,0)
	elseif hp > .25 then
		HUD.HP.BackgroundColor3 = Color3.fromRGB(255,200,0)
	else
		HUD.HP.BackgroundColor3 = Color3.fromRGB(255,0,0)
	end
end

KAsec:AddToggle({
	Name = "KillAura",
	Flag = "KA",
	Default = false,
	Callback = function(s)
		KAVar = s
		if s then
			task.spawn(function()
				while KAVar do
					local w = sword()
					local t = nearest()
					if w and t and t.Character then
						r:FireServer(t.Character, w)
						hl(t)
						if HUDon then updHUD(t) end
					else
						hl(nil)
						if HUDon then updHUD(nil) end
					end
					task.wait(.1)
				end
				hl(nil)
				if HUDon then updHUD(nil) end
			end)
		else
			hl(nil)
			if HUDon then updHUD(nil) end
		end
	end
})

KAsec:AddToggle({Name="Highlight",Flag="KAhl",Default=false,Callback=function(s) HLon=s if not s then hl(nil) end end})
KAsec:AddColorPicker({Name="Highlight Color",Default=HLc,Flag="KAhlC",Callback=function(c) HLc=c if curHL then curHL.FillColor=c end end})
KAsec:AddToggle({Name="Target HUD",Flag="KAhud",Default=false,Callback=function(s) HUDon=s if s then makeHUD() else delHUD() end end})
KAsec:AddToggle({Name="Use DisplayName",Flag="KAdn",Default=false,Callback=function(s) UseDN=s end})
KAsec:AddToggle({Name="Move HUD",Flag="KAmove",Default=false,Callback=function(s) MoveHUD=s end})
KAsec:AddColorPicker({Name="HUD Color",Default=HUDc,Flag="KAhudC",Callback=function(c) HUDc=c if HUD and HUD.F then HUD.F.BackgroundColor3=c end end})

--Scaffold
local ScaffoldSec = UtilityWindow:DrawSection({Name = "Scaffold", Position = "left"})

local PlaceRemote = rs:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("PlaceBlock")
local ScaffoldTask

local function GetBlockName()
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Backpack then return nil end
    if Backpack:FindFirstChild("Fake Block") then return "Fake Block" end
    local Team = LocalPlayer.Team
    if Team and Team.Name and Team.Name ~= "Spectator" then
        local WoolName = Team.Name .. " Wool"
        if Backpack:FindFirstChild(WoolName) then
            return WoolName
        end
    end
    return nil
end

local function PlaceBlock(Position)
    local Block = GetBlockName()
    if not Block then return end
    pcall(function()
        PlaceRemote:FireServer(Block, 1, Position)
    end)
end

local function RoundVector(Vector)
    return Vector3.new(
        math.floor(Vector.X + 0.5),
        math.floor(Vector.Y + 0.5),
        math.floor(Vector.Z + 0.5)
    )
end

local function PerformScaffold()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local MoveDirection = Character:FindFirstChildOfClass("Humanoid").MoveDirection
    local SpeedFactor = math.max(MoveDirection.Magnitude * 3, 2)
    local BasePosition = RoundVector(Root.Position - Vector3.new(0, 3.5, 0))

    PlaceBlock(BasePosition)
    for i = 1, math.ceil(SpeedFactor) do
        local Offset = RoundVector(BasePosition + Root.CFrame.LookVector * i)
        PlaceBlock(Offset)
    end
end

local function StartScaffold()
    if ScaffoldTask then return end
    ScaffoldTask = task.spawn(function()
        while ScaffoldEnabled do
            PerformScaffold()
            task.wait(0.03)
        end
        ScaffoldTask = nil
    end)
end

ScaffoldSec:AddToggle({
    Name = "Scaffold",
    Flag = "Scaffold",
    Default = false,
    Callback = function(State)
        ScaffoldEnabled = State
        if State then
            StartScaffold()
        end
    end
})

--ProjectAim
local ProjectAimSec = CombatWindow:DrawSection({Name = "ProjectAim", Position = "right"})

ProjectAimSec:AddToggle({
    Name = "ProjectAim",
    Flag = "ProjectAim",
    Default = false,
    Callback = function(state)
        ProjectAimVar = state
        local remote = rs.Remotes.ItemsRemotes.ShootProjectile
        local gravity = workspace.Gravity or 196.2

        local function getClosest()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            local root = LocalPlayer.Character.HumanoidRootPart
            local nearest, dist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    if d < dist and d <= (ProjectAimRange or 20) then
                        dist, nearest = d, p
                    end
                end
            end
            return nearest
        end

        local function predictPosition(target, speed)
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
            local tRoot = target.Character.HumanoidRootPart
            local vel = tRoot.Velocity
            local pos = tRoot.Position
            local dist = (pos - root.Position).Magnitude
            local travelTime = dist / speed
            local predicted = pos + vel * travelTime + Vector3.new(0, 0.5 * gravity * (travelTime ^ 2) / speed, 0)
            return predicted
        end

        task.spawn(function()
            while ProjectAimVar do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local target = getClosest()
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local weapon, projId, speed
                        if char:FindFirstChild("Bow") or LocalPlayer.Backpack:FindFirstChild("Bow") then
                            weapon, projId, speed = "Bow", 110, 500
                        elseif char:FindFirstChild("Crossbow") or LocalPlayer.Backpack:FindFirstChild("Crossbow") then
                            weapon, projId, speed = "Crossbow", 115, 700
                        end
                        if weapon then
                            local predicted = predictPosition(target, speed)
                            if predicted then
                                local dir = (predicted - root.Position).Unit
                                remote:FireServer(projId, weapon, root.Position, speed, dir, predicted)
                            end
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
    end
})

ProjectAimSec:AddSlider({
    Name = "ProjectAim Range",
    Flag = "ProjectAimRange",
    Default = 50,
    Min = 10,
    Max = 200,
    Callback = function(value)
        ProjectAimRange = value
    end
})

--LongJump
local LongJumpSection = MovementWindow:DrawSection({ Name = "LongJump", Position = "right" })

local keybindKey = Enum.KeyCode.Q
local cooldown = false
local cooldownTime = 2

local function parseKey(key)
	if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
		return key
	end
	if type(key) == "string" then
		local name = key:gsub("Enum.KeyCode.", ""):gsub("KeyCode.", ""):gsub("%s", "")
		if Enum.KeyCode[name] then
			return Enum.KeyCode[name]
		end
		name = name:upper()
		if Enum.KeyCode[name] then
			return Enum.KeyCode[name]
		end
	end
	return nil
end

local function performLongJump()
	if cooldown then
		Notify.new({
			Title = "LongJump",
			Content = "LongJump is on cooldown for " .. cooldownTime .. " seconds",
			Duration = 2,
			Icon = "lucide-mail-warning"
		})
		return
	end

	local playerContainer = workspace:FindFirstChild("PlayersContainer")
	if not playerContainer then
		return
	end

	local character = playerContainer:FindFirstChild(LocalPlayer.Name)
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then
		return
	end

	cooldown = true

	local originalSpeed = humanoid.WalkSpeed
	local originalJumpPower = humanoid.JumpPower
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	local destination = root.Position + (root.CFrame.LookVector * 50)
	local tween = TweenService:Create(root, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = CFrame.new(destination) })
	tween:Play()

	task.delay(1.5, function()
		humanoid.WalkSpeed = originalSpeed
		humanoid.JumpPower = originalJumpPower
	end)

	task.delay(cooldownTime, function()
		cooldown = false
	end)
end

LongJumpSection:AddKeybind({
	Name = "LongJump",
	Default = Enum.KeyCode.Q,
	Flag = "LongJumpKey",
	Callback = function(newKey)
		local parsed = parseKey(newKey)
		if parsed then
			keybindKey = parsed
		end
	end
})

InputService.InputBegan:Connect(function(input, processed)
	if not processed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keybindKey then
		performLongJump()
	end
end)

--Nuker
local NukerSec = UtilityWindow:DrawSection({Name = "Nuker", Position = "left"})

local MineBlock = rs.Remotes.ItemsRemotes.MineBlock

local function getBed(r)
    local c = workspace:FindFirstChild("BedsContainer")
    if not c then return nil end

    local nearest, dist
    for _, v in ipairs(c:GetChildren()) do
        local h = v:FindFirstChild("BedHitbox")
        if h and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local d = (LocalPlayer.Character.PrimaryPart.Position - h.Position).Magnitude
            if d <= r and (not dist or d < dist) then
                nearest, dist = h, d
            end
        end
    end
    return nearest
end

local function getPick()
    if not LocalPlayer then return nil end
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v.Name:lower():find("pickaxe") then
            return v
        end
    end
    if LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
            if v.Name:lower():find("pickaxe") then
                return v
            end
        end
    end
    return nil
end

NukerSec:AddToggle({
    Name = "Nuker",
    Flag = "Nuker",
    Default = false,
    Callback = function(state)
        NukerVar = state
        if state then
            task.spawn(function()
                while NukerVar do
                    task.wait(0.2)
                    local bed = getBed(30)
                    local pick = getPick()
                    if bed and pick then
                        local pos = bed.Position
                        local origin = pos + Vector3.new(0, 3, 0)
                        local dir = (pos - origin).Unit
                        MineBlock:FireServer(pick.Name, bed.Parent, pos, origin, dir)
                    end
                end
            end)
        end
    end
})

--Velocity
local VeloSec = MovementWindow:DrawSection({Name = "VelocityPatch", Position = "left"})
local VeloConn
local SavedVelo = {}
local VelocityModules = rs.Modules.VelocityUtils

VeloSec:AddToggle({
    Name = "Velocity",
    Flag = "Velocity",
    Default = false,
    Callback = function(state)
        VelocityVar = state
        if state then
            for _,v in ipairs(VelocityModules:GetChildren()) do
                table.insert(SavedVelo, v)
                v.Parent = nil
            end
            VeloConn = VelocityModules.ChildAdded:Connect(function(c)
                c:Destroy()
            end)
        else
            if VeloConn then
                VeloConn:Disconnect()
                VeloConn = nil
            end
            for _,v in ipairs(SavedVelo) do
                if v then
                    v.Parent = VelocityModules
                end
            end
            table.clear(SavedVelo)
        end
    end
})

--AutoToxic
local AutoToxicSec = UtilityWindow:DrawSection({Name = "AutoToxic", Position = "right"})

local Kills = {"L {name}", "Your pvp is terrible {name}", "Go back to sleep {name}", "{name} got cooked"}
local Beds  = {"Bed is gone?", "{name} are homeless now", "no more respawn 4 you"}
local Wins  = {"too easy", "ez ggs", "free win"}

local function say(msg)
	if WatermarkVar then msg = msg .. wm end
	local tcs = game:GetService("TextChatService")
	if tcs and tcs.ChatInputBarConfiguration and tcs.ChatInputBarConfiguration.TargetTextChannel then
		tcs.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
	else
		local e = rs:FindFirstChild("DefaultChatSystemChatEvents")
		if e and e:FindFirstChild("SayMessageRequest") then
			e.SayMessageRequest:FireServer(msg, "All")
		end
	end
end

local function rnd(tbl, name)
	return tbl[math.random(#tbl)]:gsub("{name}", name or "player")
end

local function getName(victim)
	local plr = game.Players:FindFirstChild(victim)
	if not plr then return victim end
	return DisplayNameVar and plr.DisplayName or plr.Name
end

local function onKillLog(killer, victim)
	if killer ~= LocalPlayer.Name then return end
	if not victim then return end
	say(rnd(Kills, getName(victim)))
end

AutoToxicSec:AddToggle({
	Name = "AutoToxic Kills",
	Flag = "AutoToxic Kills",
	Callback = function(v)
		if v then
			table.insert(KillConns, rs.Remotes.KillLog.OnClientEvent:Connect(onKillLog))
		else
			for _, c in ipairs(KillConns) do c:Disconnect() end
			table.clear(KillConns)
		end
	end
})

AutoToxicSec:AddToggle({
	Name = "AutoToxic Beds",
	Flag = "AutoToxic Beds",
	Callback = function(v)
		if v then
			table.insert(BedConns, LocalPlayer.Stats['Total Beds Broken']:GetPropertyChangedSignal('Value'):Connect(function()
				say(rnd(Beds, "their"))
			end))
		else
			for _, c in ipairs(BedConns) do c:Disconnect() end
			table.clear(BedConns)
		end
	end
})

AutoToxicSec:AddToggle({
	Name = "AutoToxic Win",
	Flag = "AutoToxic Win",
	Callback = function(v)
		if v then
			table.insert(WinConns, LocalPlayer.Stats.Wins.Changed:Connect(function()
				say(rnd(Wins))
			end))
		else
			for _, c in ipairs(WinConns) do c:Disconnect() end
			table.clear(WinConns)
		end
	end
})

AutoToxicSec:AddToggle({
	Name = "ATWatermark",
	Flag = "ATWatermark",
	Callback = function(v)
		WatermarkVar = v
	end
})

AutoToxicSec:AddToggle({
	Name = "Display Name",
	Flag = "Display Name",
	Callback = function(v)
		DisplayNameVar = v
	end
})

--Speed
local SpeedSec = MovementWindow:DrawSection({Name="Speed", Position="right"})
local conns, method, bounce = {}, "Classic", false

local sbounce = function() bounce = false end

local stop = function()
	sbounce()
	for _, c in ipairs(conns) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end
	table.clear(conns)
	local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if h then h.WalkSpeed = 16 end
end

local start = function()
	local hum = function() local c=LocalPlayer.Character return c and c:FindFirstChildOfClass("Humanoid") end
	if method=="Classic" then
		local keepRunning = true
		table.insert(conns, RunService.Heartbeat:Connect(function()
			if not SpeedVar or method ~= "Classic" then return end
			local h = hum()
			if h and h.WalkSpeed ~= 35 then
				h.WalkSpeed = 35
			end
		end))
	elseif method=="Velocity" then
		table.insert(conns, RunService.Heartbeat:Connect(function()
			local c = LocalPlayer.Character
			if not c or not c.PrimaryPart then return end
			local h = hum()
			if not h then return end
			local d = h.MoveDirection
			local v = c.PrimaryPart.AssemblyLinearVelocity
			c.PrimaryPart.AssemblyLinearVelocity = Vector3.new(d.X*42.5, v.Y, d.Z*42.5)
		end))
	elseif method=="Bounce" then
		bounce = true
		task.spawn(function()
			while bounce do
				local h = hum()
				if not h then break end
				h.WalkSpeed = 40 task.wait(0.3)
				if not bounce then break end
				h.WalkSpeed = 16 task.wait(0.5)
				if not bounce then break end
				h.WalkSpeed = 70 task.wait(0.1)
			end
		end)
	end
end

SpeedSec:AddToggle({
	Name="Speed",
	Flag="Speed",
	Callback=function(v)
		SpeedVar = v
		if v then start() else stop() end
	end
})

SpeedSec:AddDropdown({
	Name="Speed Method",
	Default="Classic",
	Flag="Speed_Method",
	Values={"Classic","Velocity","Bounce"},
	Callback=function(v)
		if method=="Bounce" then sbounce() end
		method = v
		if SpeedVar then stop() start() end
	end
})

--FOV
local FOVSec = VisualWindow:DrawSection({Name = "FOV", Position = "right"})

FOVSec:AddToggle({
    Name = "FOV",
    Flag = "FOV",
    Default = false,
    Callback = function(state)
        FOVVar = state
        if state then
            rs:WaitForChild("Remotes"):WaitForChild("ApplySettings"):FireServer("FOV", FOVVal)
        else
            rs:WaitForChild("Remotes"):WaitForChild("ApplySettings"):FireServer("FOV", 70)
        end
    end
})

FOVSec:AddSlider({
    Name = "FOV Value",
    Flag = "FOVvalue",
    Default = 70,
    Min = 70,
    Max = 100,
    Callback = function(value)
        FOVVal = value
        if FOVVar then
            rs:WaitForChild("Remotes"):WaitForChild("ApplySettings"):FireServer("FOV", value)
        end
    end
})

--Cape
local WCamera = workspace.CurrentCamera
local CapeSec = VisualWindow:DrawSection({Name="Cape", Position="right"})
local DefaultCape = "SmokerV4/Assets/Capes/Default.png"
local tex, part, mot = DefaultCape, nil, nil

local function link(a)
	if mot then mot:Destroy() end
	local b = a:FindFirstChild("UpperTorso") or a:FindFirstChild("Torso") or a:FindFirstChild("HumanoidRootPart")
	if not (b and part) then return end
	part.Parent = WCamera
	local w = Instance.new("Motor6D")
	w.MaxVelocity = .08
	w.Part0 = part
	w.Part1 = b
	w.C0 = CFrame.new(0,2,0)*CFrame.Angles(0,math.rad(-90),0)
	w.C1 = CFrame.new(0,b.Size.Y/2,0.45)*CFrame.Angles(0,math.rad(90),0)
	w.Parent = part
	mot = w
end

local function build(a)
	if part then part:Destroy() end
	local p = Instance.new("Part")
	p.Size = Vector3.new(2,4,0.1)
	p.Color = CapeColor
	p.CanCollide, p.CanQuery, p.Massless = false,false,true
	p.Material = Enum.Material.SmoothPlastic
	p.CastShadow = false
	p.Parent = WCamera

	local g = Instance.new("SurfaceGui")
	g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.Adornee, g.Parent = p,p

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromScale(1,1)
	img.BackgroundTransparency = 1
	img.Image = tex:find("rbxasset") and tex or getcustomasset(tex)
	img.Parent = g

	part = p
	link(a)

	task.spawn(function()
		while CapeVar and mot and part do
			local c = LocalPlayer.Character
			if c and c:FindFirstChild("HumanoidRootPart") then
				local v = math.min(c.HumanoidRootPart.Velocity.Magnitude,90)
				mot.DesiredAngle = math.rad(6)+math.rad(v)+(v>1 and math.abs(math.cos(tick()*5))/3 or 0)
			end
			if not WCamera or not WCamera.CFrame then WCamera = workspace.CurrentCamera task.wait() continue end
			if WCamera and WCamera.Focus then
				local dist = (WCamera.CFrame.Position - WCamera.Focus.Position).Magnitude
				g.Enabled = dist>0.6
				p.Transparency = dist>0.6 and 0 or 1
			end
			task.wait()
		end
	end)
end

local function clear()
	if part then part:Destroy() end
	part,mot = nil,nil
end

CapeSec:AddToggle({
	Name="Cape",
	Flag="Cape",
	Callback=function(v)
		CapeVar=v
		if v then
			if LocalPlayer.Character then build(LocalPlayer.Character) end
			LocalPlayer.CharacterAdded:Connect(function(c)
				if CapeVar then task.wait(1) build(c) end
			end)
		else
			clear()
		end
	end
})

CapeSec:AddDropdown({
	Name="Capes",
	Default="Default",
	Flag="CapeType",
	Values={"Default","Cat","Waifu","Watermark","Yap", "Private"},
	Callback=function(v)
		local path="SmokerV4/Assets/Capes/"..v..".png"
		if isfile(path) then
			tex=path
			if part then
				clear()
				build(LocalPlayer.Character)
			end
		end
	end
})

CapeSec:AddTextBox({
	Name="Texture",
	Flag="CapeTexture",
	Placeholder="RobloxID / Path",
	Callback=function(v)
		task.delay(0.5,function()
			if v=="" then v=DefaultCape end
			if not isfile(v) and not v:find("rbxasset") then return end
			tex=v
			if part then
				clear()
				build(LocalPlayer.Character)
			end
		end)
	end
})

CapeSec:AddColorPicker({
	Name="Color",
	Flag="CapeColor",
	Default=CapeColor,
	Callback=function(v)
		CapeColor=v
		if part then part.Color=v end
	end
})

-- Settings
local SettingsWindow = SmokerV4:DrawTab({
    Icon = "settings-3",
    Name = "Settings",
    Type = "Single",
    EnableScrolling = true
})

local Settings = SettingsWindow:DrawSection({
    Name = "UI Settings"
})

Settings:AddToggle({
    Name = "Always Show Sidebar",
    Default = false,
    Callback = function(v)
        SmokerV4.AlwayShowTab = v
    end
})

SettingsWindow:DrawSection({
    Name = "UI Themes"
}):AddDropdown({
    Name = "Select Theme",
    Default = "Default",
    Values = {
        "Default",
        "Dark Green",
        "Dark Blue",
        "Purple Rose",
        "Skeet",
        "Nova"
    },
    Callback = function(v)
        if v == "Nova" then
            Library.Colors.Highlight = Color3.fromRGB(255, 100, 150)
            Library.Colors.Toggle = Color3.fromRGB(100, 200, 255)
            Library.Colors.Background = Color3.fromRGB(25, 25, 25)
            Library.Colors.StrokeColor = Color3.fromRGB(255, 255, 255)
            Library.Colors.LineColor = Color3.fromRGB(180, 180, 180)
            Library:RefreshCurrentColor()
        else
            Library:SetTheme(v)
        end
    end
})

local ConfigsWindow = SmokerV4:DrawConfig({
    Name = "Config",
    Icon = "folder",
    Config = ConfigManager
})

ConfigsWindow:Init()