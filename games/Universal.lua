local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
local Notify = Library.newNotify();

--Config
local ConfigManager = Library:ConfigManager({Directory = "SmokerV4/games", Config = "Universal"});
Library:Loader(getcustomasset("SmokerV4/Assets/newlogo.png"), 2.5):yield()

-- Window --
local SmokerV4 = Library.new({Name="Smoker | Universal",Keybind="RightShift",Logo=getcustomasset("SmokerV4/Assets/icon.png"),Scale=Library.Scale.Window,TextSize=15})

-- Notification --
Notify.new({Title = "SmokerV4",Content = "Thank you for use this script!", Duration = 10, Icon = getcustomasset("SmokerV4/Assets/icon.png")});

-- Watermark --
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
local WCamera = workspace.CurrentCamera

-- Windows --
SmokerV4:DrawCategory({Name = "Smoker"});

local CombatWindow = SmokerV4:DrawTab({Name = "Combat", Icon = "lucide-swords", EnableScrolling = true});
local UtilityWindow = SmokerV4:DrawTab({Name = "Utility", Icon = "lucide-hammer", EnableScrolling = true});
local MovementWindow = SmokerV4:DrawTab({Name = "Movement", Icon = "lucide-layout-dashboard", EnableScrolling = true});
local VisualWindow = SmokerV4:DrawTab({Name = "Visual", Icon = "lucide-eye", EnableScrolling = true});

--Vars
local NameTagsVar = false
local VibeVar = false
local SpeedVar2 = false
local SpeedVar = 16
local CapeVar = false

--Colors
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
    ["Speed"] = function() return SpeedVar2 end,
    ["Cape"] = function() return CapeVar end
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
		header.Text = "<font size='26'>SMOKER</font> <font size='18'>V3</font>"
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


--NameTags
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local NameTagsSec = VisualWindow:DrawSection({
    Name = "NameTag",
    Position = "left"
})

local connections = {}
local tagColor = Color3.fromRGB(0, 255, 140)

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
        textLabel.TextColor3 = tagColor
        textLabel.Text = ""

        local renderConnection = RunService.RenderStepped:Connect(function()
            if not NameTagsVar or humanoid.Health <= 0 then
                textLabel.Text = ""
                return
            end

            textLabel.TextColor3 = tagColor

            local hp = math.floor(humanoid.Health)
            local maxHp = math.floor(humanoid.MaxHealth)
            local distance = 0

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                distance = math.floor(
                    (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                )
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

local NameTagsToggle = NameTagsSec:AddToggle({
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

NameTagsSec:AddColorPicker({
    Name = "Color",
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

--Speed
local SpeedSec = MovementWindow:DrawSection({Name = "Speed", Position = "left"})

local function setSpeed(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum and SpeedVar2 then
        hum.WalkSpeed = SpeedVar
    end
end)

SpeedSec:AddToggle({
    Name = "Speed",
    Flag = "SpeedToggle",
    Default = false,
    Callback = function(state)
        SpeedVar2 = state
        if state then
            setSpeed(SpeedVar)
        else
            setSpeed(16)
        end
    end
})

SpeedSec:AddSlider({
    Name = "Speed",
    Flag = "Speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Callback = function(value)
        SpeedVar = value
        if SpeedVar2 then
            setSpeed(value)
        end
    end
})

--Cape
local WCamera = workspace.CurrentCamera
local CapeSec = UtilityWindow:DrawSection({Name="Cape", Position="right"})
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