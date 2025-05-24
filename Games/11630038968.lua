local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7Smoker/Smoker/refs/heads/main/UILibrary/Library", true))()
Library.DefaultColor = Color3.fromRGB(3, 73, 252)
local Flags = Library.Flags

-- Windows
local CreditsWindow = Library:Window({Text = "Credits"})
local CombatWindow = Library:Window({Text = "Combat"})
local UtilityWindow = Library:Window({Text = "Utility"})
local MovementWindow = Library:Window({Text = "Movement"})
local VisualWindow = Library:Window({Text = "Visual"})
local SettingsWindow = Library:Window({Text = "Settings"})

--Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local KillFeed = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Notifications"):WaitForChild("Notifications")

--States
local InfJumpsVar, KAVar, AutoGGVar, AutoLVar, NormalToxicVar, TargetHeadHudVar, TargetBackHudVar, TargetSafeHudVar = false, false, false, false, false, false, false, false
local TargetVar, AntiKBConnect, RunKAConnect, CharAddedConnect, CharDiedConnect
local PreCameraCFrame, CurrentTarget, LastSwing = nil, nil, 0
local HumanoidRootPart, character = hrp, Character, hudGui, listFrame, contentFrame, hudconnect
local activeLabels = {}
local LibrarySyncColors = {}
local LibrarySyncBackgrounds = {}

local HUDStyle = "Off"

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local rotationAngle = 0
local rotationSpeed = math.rad(360)

local SwordItems = {"WoodenSword", "TemplateSword", "DiamondSword", "GoldSword", "Sword"}
local nametagConnections = {}
local connections = {}
local Messages = {
    "L %s",
    "gg %s",
    "%s cant fight %s"
}

--Functions
function SyncColor(obj)
	if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
		table.insert(LibrarySyncColors, obj)
	elseif obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
		table.insert(LibrarySyncBackgrounds, obj)
	end
end

UserInputService.JumpRequest:Connect(function()
    if InfJumpsVar then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

local function isInCityArea(pos)
    local cityModel = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("City")
    if not (cityModel and cityModel:IsA("Model")) then return false end

    local cityRegion = cityModel:GetExtentsSize()
    local cityCFrame = cityModel:GetModelCFrame()
    local cityMin = cityCFrame.Position - (cityRegion / 2)
    local cityMax = cityCFrame.Position + (cityRegion / 2)

    return pos.X >= cityMin.X and pos.X <= cityMax.X and
           pos.Y >= cityMin.Y and pos.Y <= cityMax.Y and
           pos.Z >= cityMin.Z and pos.Z <= cityMax.Z
end

local function getHumanoidRootPart()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function ClosestPlayer(maxDistance)
    local closest, shortest = nil, maxDistance
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                closest = player
                shortest = dist
            end
        end
    end
    return closest
end

local NameTagsVar = false
local function NameTagCreate(player)
    if player == LocalPlayer then return end

    if nametagConnections[player] then
        for _, conn in pairs(nametagConnections[player]) do
            conn:Disconnect()
        end
        nametagConnections[player] = nil
    end

    local function onCharacterAdded(character)
        local head = character:WaitForChild("Head", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not head or not humanoid then return end

        if head:FindFirstChild("CustomNametag") then
            head.CustomNametag:Destroy()
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CustomNametag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 250, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        task.spawn(function()
        while textLabel and textLabel.Parent do
            textLabel.TextColor3 = Library.DefaultColor
                task.wait(0.03)
            end
        end)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Text = ""
        billboard.Parent = head

        local updateConn
        updateConn = RunService.RenderStepped:Connect(function()
            if not NameTagsVar then
                textLabel.Text = ""
                return
            end
            if humanoid.Health <= 0 then
                textLabel.Text = ""
                return
            end

            local health = math.floor(humanoid.Health)
            local maxHealth = math.floor(humanoid.MaxHealth)
            local name = player.Name

            local distance = 0
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
            end

            textLabel.Text = string.format("[%d/%d] %s [%dm]", health, maxHealth, name, distance)
        end)

        nametagConnections[player] = nametagConnections[player] or {}
        table.insert(nametagConnections[player], updateConn)
    end

    local charConn = player.CharacterAdded:Connect(onCharacterAdded)
    nametagConnections[player] = nametagConnections[player] or {}
    table.insert(nametagConnections[player], charConn)

    if player.Character then
        onCharacterAdded(player.Character)
    end
end

local function clearNametags()
    for player, conns in pairs(nametagConnections) do
        for _, conn in pairs(conns) do
            conn:Disconnect()
        end
        nametagConnections[player] = nil
        if player.Character and player.Character:FindFirstChild("Head") then
            local tag = player.Character.Head:FindFirstChild("CustomNametag")
            if tag then tag:Destroy() end
        end
    end
end

local function ResetCam()
    if camera and camera.CameraType == Enum.CameraType.Scriptable then
        camera.CameraType = Enum.CameraType.Custom
        if PreCameraCFrame then
            camera.CFrame = PreCameraCFrame
            PreCameraCFrame = nil
        end
    end
end

local function KALoopDisconnect()
    if RunKAConnect then
        RunKAConnect:Disconnect()
        RunKAConnect = nil
    end
    if CharDiedConnect then
        CharDiedConnect:Disconnect()
        CharDiedConnect = nil
    end
    ResetCam()
end

local function ClosestPlayer()
    local character = player.Character
    if not character then return nil end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end

    local closestPlayer = nil
    local shortestDistance = 23 + 1
    local myPos = humanoidRootPart.Position

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local otherHead = otherPlayer.Character:FindFirstChild("Head")
            if otherHRP and otherHead then
                local direction = (otherHead.Position - myPos)
                local distance = direction.Magnitude

                if distance < shortestDistance then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {character}
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    rayParams.IgnoreWater = true

                    local rayResult = workspace:Raycast(myPos, direction, rayParams)

                    if not rayResult or (rayResult.Instance and otherPlayer.Character:IsAncestorOf(rayResult.Instance)) then
                        shortestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
    end

    return closestPlayer, shortestDistance
end

local function getSword(character)
    for _, swordName in ipairs(SwordItems) do
        local sword = character:FindFirstChild(swordName)
        if sword then
            return sword
        end
    end
    return nil
end

local function KillAuraFunc()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    KALoopDisconnect()

    local clickToggle = false

    RunKAConnect = RunService.RenderStepped:Connect(function()
        if not KAVar then
                KALoopDisconnect()
            return
        end

        if not character.Parent then
                KALoopDisconnect()
            return
        end

        local localSword = getSword(character)
        if not localSword then
                ResetCam()
            return
        end

        local cityModel = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("City")
        local isInCity = false

        if cityModel and cityModel:IsA("Model") then
            local cityRegion = cityModel:GetExtentsSize()
            local cityCFrame = cityModel:GetModelCFrame()
            local cityMin = cityCFrame.Position - (cityRegion / 2)
            local cityMax = cityCFrame.Position + (cityRegion / 2)

            local pos = humanoidRootPart.Position
            if pos.X >= cityMin.X and pos.X <= cityMax.X and
               pos.Y >= cityMin.Y and pos.Y <= cityMax.Y and
               pos.Z >= cityMin.Z and pos.Z <= cityMax.Z then
                isInCity = true
            end
        end

        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Humanoid") then
            local targetHumanoid = CurrentTarget.Character.Humanoid
            local targetHRP = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
            if targetHumanoid.Health <= 0 or not targetHRP then
                CurrentTarget = nil
            elseif (targetHRP.Position - humanoidRootPart.Position).Magnitude > 23 then
                CurrentTarget = nil
            end
        end

        if not CurrentTarget then
            local closestPlayer, distance = ClosestPlayer()
            if closestPlayer and distance <= 23 then
                CurrentTarget = closestPlayer
            end
        end

        if not isInCity and CurrentTarget and CurrentTarget.Character then
            local targetHead = CurrentTarget.Character:FindFirstChild("Head")
            if targetHead then
                if not PreCameraCFrame and camera.CameraType ~= Enum.CameraType.Scriptable then
                    PreCameraCFrame = camera.CFrame
                end

                camera.CameraType = Enum.CameraType.Scriptable
                camera.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 2, 0), targetHead.Position)

                if tick() - LastSwing >= 0.05 then
                    LastSwing = tick()
                    if localSword.Parent == character then
                        localSword:Activate()

                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        if clickToggle == false then
                            clickToggle = true
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
                        else
                            clickToggle = false
                            VirtualInputManager:SendMouseButtonEvent(0, 1, 1, true, game, 0)
                            VirtualInputManager:SendMouseButtonEvent(0, 1, 1, false, game, 0)
                        end

                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            local state = humanoid:GetState()
                            if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end
                end

                return
            end
        end

        if camera.CameraType == Enum.CameraType.Scriptable then
            camera.CameraType = Enum.CameraType.Custom
            if PreCameraCFrame then
                camera.CFrame = PreCameraCFrame
                PreCameraCFrame = nil
            end
        end
    end)

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        CharDiedConnect = humanoid.Died:Connect(function()
            KALoopDisconnect()
            CurrentTarget = nil
        end)
    end
end

local function onCharacterAdded(character)
    character:WaitForChild("HumanoidRootPart", 5)
    character:WaitForChild("Humanoid", 5)

    task.wait(0.5)

    if KAVar then
        KillAuraFunc()
    else
        ResetCam()
    end
end

local function isInCity()
    local cityModel = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("City")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not cityModel or not hrp then return false end

    if cityModel:IsA("Model") then
        local cityRegion = cityModel:GetExtentsSize()
        local cityCFrame = cityModel:GetModelCFrame()
        local cityMin = cityCFrame.Position - (cityRegion / 2)
        local cityMax = cityCFrame.Position + (cityRegion / 2)

        local pos = hrp.Position
        return pos.X >= cityMin.X and pos.X <= cityMax.X and
        pos.Y >= cityMin.Y and pos.Y <= cityMax.Y and
        pos.Z >= cityMin.Z and pos.Z <= cityMax.Z
    end

    return false
end

local function IsAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

if not CharAddedConnect then
    CharAddedConnect = player.CharacterAdded:Connect(onCharacterAdded)
end

local function PlayerLowHP(range)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart

    local lowestHealthPlayer = nil
    local lowestHealth = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                local distance = (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if distance <= range and humanoid.Health < lowestHealth then
                    lowestHealth = humanoid.Health
                    lowestHealthPlayer = player
                end
            end
        end
    end

    return lowestHealthPlayer
end

--Features
local RGBVar = false
SettingsWindow:Dropdown({
    Text = "Theme",
    List = {"Dark", "Light", "Aqua", "Nova", "RGB"},
    Callback = function(theme)
        RGBVar = false

        if theme == "Dark" then
            Library.DefaultColor = Color3.fromRGB(0, 0, 0)
        elseif theme == "Light" then
            Library.DefaultColor = Color3.fromRGB(255, 255, 255)
        elseif theme == "Aqua" then
            Library.DefaultColor = Color3.fromRGB(66, 245, 194)
        elseif theme == "Nova" then
            Library.DefaultColor = Color3.fromRGB(255, 0, 234)
        elseif theme == "RGB" then
            RGBVar = true
            task.spawn(function()
                while RGBVar do
                    for hue = 0, 1, 0.01 do
                        if not RGBVar then break end
                        Library.DefaultColor = Color3.fromHSV(hue, 1, 1)
                        task.wait(0.03)
                    end
                end
            end)
        end

        Library:Notification({Text = "Changed Theme to: " .. theme, Duration = 15})
    end
})

CombatWindow:Toggle({
    Text = "KillAura",
    Flag = "KillAura",
    Default = Library.Flags["KillAura"] or false,
    Callback = function(state)
        Library.Flags["KillAura"] = state
        Library:SaveFlags()
        KAVar = state
        if KAVar then
            if player.Character then
                KillAuraFunc()
            end
        else
            KALoopDisconnect()
        end
    end
})

MovementWindow:Toggle({
    Text = "InfJumps",
    Flag = "InfJumps",
    Default = Library.Flags["InfJumps"] or false,
    Callback = function(state)
        Library.Flags["InfJumps"] = state
        Library:SaveFlags()
        InfJumpsVar = state
    end
})

local KillFeedConnect = nil
local LocalPlrDisplay = LocalPlayer.DisplayName
local LocalPlrName = LocalPlayer.Name
UtilityWindow:Dropdown({
    Text = "AutoToxic Mode",
    List = {"Off", "AutoGG", "AutoL", "AutoToxic"},
    Callback = function(selected)
        if KillFeedConnect then
            KillFeedConnect:Disconnect()
            KillFeedConnect = nil
        end
        AutoGGVar = false
        AutoLVar = false
        NormalToxicVar = false

        if selected == "Off" then
            return
        end

        if selected == "AutoGG" then
            AutoGGVar = true
        elseif selected == "AutoL" then
            AutoLVar = true
        elseif selected == "AutoToxic" then
            NormalToxicVar = true
        end

        KillFeedConnect = KillFeed.ChildAdded:Connect(function(child)
            if child:IsA("TextLabel") then
                task.wait(0.1)
                local rawText = child.Text

                local names = {}
                for name in rawText:gmatch("<font color='#ffffff'>(.-)</font>") do
                    table.insert(names, name)
                end

                if #names >= 2 then
                    local killedName = names[1]
                    local killerName = names[2]

                    if killerName == LocalPlrDisplay or killerName == LocalPlrName then
                        local deadPlayer = nil
                        for _, plr in pairs(Players:GetPlayers()) do
                            if plr.DisplayName == killedName or plr.Name == killedName then
                                deadPlayer = plr
                                break
                            end
                        end
                        if not deadPlayer then return end

                        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                        if not channel then return end

                        local message = ""
                        if selected == "AutoGG" then
                            message = "gg " .. deadPlayer.DisplayName .. " | <S<M<O<K<E<R<> Client on top"
                        elseif selected == "AutoL" then
                            message = "L " .. deadPlayer.DisplayName .. " | <S<M<O<K<E<R<> Client on top"
                        elseif selected == "AutoToxic" then
                            local fmt = Messages[math.random(1, #Messages)]
                            message = string.format(fmt, deadPlayer.DisplayName, LocalPlrDisplay) .. " | <S<M<O<K<E<R<> Client on top"
                        end

                        channel:SendAsync(message)
                    end
                end
            end
        end)
    end
})

local AntiKBVar = false
MovementWindow:Toggle({
    Text = "AntiKnockback Beta",
    Flag = "AntiKnockbackBeta",
    Default = Library.Flags["AntiKnockbackBeta"] or false,
    Callback = function(state)
        Library.Flags["AntiKnockbackBeta"] = state
        Library:SaveFlags()
        AntiKBVar = state
        if AntiKBVar then
            AntiKBConnect = RunService.Heartbeat:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end)
        else
            if AntiKBConnect then
                AntiKBConnect:Disconnect()
                AntiKBConnect = nil
            end
        end
    end
})

local VibeVar = false
VisualWindow:Toggle({
    Text = "Vibe",
    Flag = "Vibe",
    Default = Library.Flags["Vibe"] or false,
    Callback = function(state)
        Library.Flags["Vibe"] = state
        Library:SaveFlags()
        VibeVar = state
        if VibeVar then
            task.spawn(function()
                while VibeVar and task.wait() do
                    Lighting.TimeOfDay = "00:00:00"
                    Lighting.Ambient = Library.DefaultColor
                    Lighting.OutdoorAmbient = Library.DefaultColor
                    Lighting.Technology = Enum.Technology.Future
                end
            end)
        end
    end
})

VisualWindow:Toggle({
    Text = "Nametags",
    Flag = "Nametags",
    Default = Library.Flags["Nametags"] or false,
    Callback = function(state)
        Library.Flags["Nametags"] = state
        Library:SaveFlags()

        local function NameTagsFunc(state)
            NameTagsVar = state
            if state then
                for _, player in pairs(Players:GetPlayers()) do
                    NameTagCreate(player)
                end
            else
                clearNametags()
            end
        end

        NameTagsFunc(state)
    end
})

local FPSBoostVar = false
VisualWindow:Toggle({
    Text = "FPSBoost",
    Flag = "FPSBoost",
    Default = Library.Flags["FPSBoost"] or false,
    Callback = function(state)
        Library.Flags["FPSBoost"] = state
        Library:SaveFlags()
        FPSBoostVar = state

        if state then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Texture = ""
                elseif obj:IsA("MeshPart") then
                    obj.TextureID = ""
                end
            end

            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1000000
            Lighting.Brightness = 0

            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.SmoothPlastic
                    part.Reflectance = 0
                end
            end
        else

        end
    end
})

SettingsWindow:Keybind({
   Text = "Toggle Library",
   Default = Enum.KeyCode.RightShift,
   Callback = function()
       Library:Toggle()
   end
})

CreditsWindow:Label({
   Text = "Smoker Client",
   Color = Library.DefaultColor
})

local WatermarkState = nil
local WatermarkVar = false
CreditsWindow:Toggle({
    Text = "Watermark",
    Flag = "Watermark",
    Default = Library.Flags["Watermark"] or false,
    Callback = function(state)
        Library.Flags["Watermark"] = state
        Library:SaveFlags()
        WatermarkVar = state

        if state then
            if not WatermarkState then
                WatermarkState = Instance.new("ScreenGui")
                WatermarkState.Name = "SmokerWatermark"
                WatermarkState.ResetOnSpawn = false
                WatermarkState.IgnoreGuiInset = true
                WatermarkState.ZIndexBehavior = Enum.ZIndexBehavior.Global
                WatermarkState.DisplayOrder = 100
                WatermarkState.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

                local container = Instance.new("Frame")
                container.Name = "WatermarkContainer"
                container.AnchorPoint = Vector2.new(1, 0)
                container.Position = UDim2.new(1, -10, 0, 10)
                container.Size = UDim2.new(0, 320, 0, 60)
                container.BackgroundTransparency = 0.25
                container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                container.BorderSizePixel = 0
                container.Parent = WatermarkState

                local logo = Instance.new("ImageLabel")
                logo.Name = "Logo"
                logo.Size = UDim2.new(0, 48, 0, 48)
                logo.Position = UDim2.new(0, 6, 0.6, -24)
                logo.BackgroundTransparency = 1
                logo.Image = getcustomasset("Smoker/Assets/logo.png")
                logo.ScaleType = Enum.ScaleType.Fit
                logo.Parent = container

                local label = Instance.new("TextLabel")
                label.Name = "Title"
                label.Size = UDim2.new(1, -60, 1, 0)
                label.Position = UDim2.new(0, 60, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = "Smoker Client"
                label.TextColor3 = Library.DefaultColor
                label.TextStrokeTransparency = 0.75
                label.Font = Enum.Font.SourceSansBold
                label.TextScaled = true
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = container

                SyncColor(label)

                local design = Instance.new("UICorner")
                design.Parent = container
            else
                WatermarkState.Enabled = true
            end

            local playerGui = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if playerGui then
                for _, gui in ipairs(playerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name:lower():find("leader") then
                        gui.DisplayOrder = 1
                    end
                end
            end
        else
            if WatermarkState then
                WatermarkState.Enabled = false
            end
        end
    end
})

local modes = {
    ["TargetHead"] = function()
        return RunService.Heartbeat:Connect(function()
            local HumanoidRootPart = getHumanoidRootPart()
            if not HumanoidRootPart then return end
            if isInCityArea(HumanoidRootPart.Position) then return end

            local target = CurrentTarget
            if not target then
                target = ClosestPlayer(20)
                if target then
                    CurrentTarget = target
                end
            end
            if target and target.Character and target.Character:FindFirstChild("Head") and target.Character:FindFirstChild("Humanoid") then
                local humanoid = target.Character.Humanoid
                if humanoid.Health > 0 then
                    local desiredPosition = target.Character.Head.Position + Vector3.new(0, 8, 0)
                    local direction = (desiredPosition - HumanoidRootPart.Position).Unit
                    HumanoidRootPart.Velocity = direction * 20
                end
            end
        end)
    end,

    ["TargetBack"] = function()
        return RunService.Heartbeat:Connect(function()
            local HumanoidRootPart = getHumanoidRootPart()
            if not HumanoidRootPart then return end
            if isInCityArea(HumanoidRootPart.Position) then return end

            local target = CurrentTarget
            if not target then
                target = ClosestPlayer(20)
                if target then
                    CurrentTarget = target
                end
            end
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") then
                local humanoid = target.Character.Humanoid
                if humanoid.Health > 0 then
                    local targetHRP = target.Character.HumanoidRootPart
                    local backPosition = targetHRP.Position - (targetHRP.CFrame.LookVector * 5) + Vector3.new(0, 2, 0)
                    local direction = (backPosition - HumanoidRootPart.Position).Unit
                    HumanoidRootPart.Velocity = direction * 40
                end
            end
        end)
    end,

    ["TargetSafe"] = function()
        rotationAngle = 0
        return RunService.Heartbeat:Connect(function(deltaTime)
            local HumanoidRootPart = getHumanoidRootPart()
            if not HumanoidRootPart then return end
            local target = CurrentTarget
            if not target then
                local potentialTarget = PlayerLowHP(20)
                if potentialTarget and potentialTarget.Character and potentialTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = potentialTarget.Character.HumanoidRootPart
                    local direction = (targetHRP.Position - HumanoidRootPart.Position)

                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    rayParams.IgnoreWater = true

                    local rayResult = workspace:Raycast(HumanoidRootPart.Position, direction, rayParams)
                    if rayResult and potentialTarget.Character:IsAncestorOf(rayResult.Instance) then
                        target = potentialTarget
                        CurrentTarget = target
                    end
                end
            end

            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") then
                local humanoid = target.Character.Humanoid
                if humanoid.Health <= 0 then return end

                local targetHRP = target.Character.HumanoidRootPart
                if isInCityArea(targetHRP.Position) then return end

                rotationAngle = (rotationAngle + rotationSpeed * deltaTime) % (math.pi * 2)
                local offset = Vector3.new(math.cos(rotationAngle) * 5, 4, math.sin(rotationAngle) * 5)
                local desiredPosition = targetHRP.Position + offset
                local moveDirection = desiredPosition - HumanoidRootPart.Position
                local distance = moveDirection.Magnitude

                HumanoidRootPart.Velocity = distance > 0
                    and moveDirection.Unit * math.min(distance / deltaTime, 28)
                    or Vector3.new(0, 0, 0)
            end
        end)
    end,
}

CombatWindow:Dropdown({
    Text = "Follow Mode",
    List = {"None", "TargetHead", "TargetBack", "TargetSafe"},
    Callback = function(selected)
        if TargetVar then
            TargetVar:Disconnect()
            TargetVar = nil
        end

        TargetHeadHudVar = false
        TargetBackHudVar = false
        TargetSafeHudVar = false

        if selected ~= "None" and modes[selected] then
            TargetVar = modes[selected]()

            if selected == "TargetHead" then
                TargetHeadHudVar = true
            elseif selected == "TargetBack" then
                TargetBackHudVar = true
            elseif selected == "TargetSafe" then
                TargetSafeHudVar = true
            end
        end
    end
})

local StaffDetectVar = false
UtilityWindow:Toggle({
    Text = "StaffDetector",
    Flag = "StaffDetector",
    Default = Library.Flags["StaffDetector"] or false,
    Callback = function(state)
        Library.Flags["StaffDetector"] = state
        Library:SaveFlags()

        local function checkPlayer(player)
            if player ~= game.Players.LocalPlayer then
                local success, rank = pcall(function()
                    return player:GetRankInGroup(6604847)
                end)

                if success and rank > 1 then
                    local roleName = player:GetRoleInGroup(6604847)
                    Library:Notification({
                        Text = "Staff Detected! " .. player.Name .. " is a " .. roleName,
                        Duration = 20,
                        Color = Color3.fromRGB(255, 0, 34)
                    })
                else
                    
                end
            end
        end
        
        StaffDetectVar = state

        if state then
            for _, player in pairs(game.Players:GetPlayers()) do
                checkPlayer(player)
            end

            game.Players.PlayerAdded:Connect(function(player)
                if StaffDetectVar then
                    task.wait(1)
                    checkPlayer(player)
                end
            end)
        end
    end
})

local AntiHitLoop
local AntiHitVar = false
CombatWindow:Toggle({
    Text = "AntiHit",
    Flag = "AntiHit",
    Default = Library.Flags["AntiHit"] or false,
    Callback = function(state)
        Library.Flags["AntiHit"] = state
        Library:SaveFlags()

        local function AntiHitPlayer(maxDist)
            local closest, shortest = nil, maxDist or 25
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then return nil end

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and IsAlive(player.Character) then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local dist = (myHRP.Position - targetHRP.Position).Magnitude
                        if dist <= shortest then
                            closest = player
                            shortest = dist
                        end
                    end
                end
            end

            return closest
        end

        AntiHitVar = state
        if state then
            AntiHitLoop = task.spawn(function()
                while AntiHitVar do
                    local target = AntiHitPlayer(25)
                    local myChar = LocalPlayer.Character
                    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

                    if target and hrp and not isInCity() then
                        local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP then
                            local dir = (targetHRP.Position - hrp.Position).Unit
                            local horiz = Vector3.new(dir.X, 0, dir.Z) * 80
                            local upward = Vector3.new(0, 50, 0)

                            hrp.Velocity = horiz + upward
                            task.wait(0.5)
                            hrp.Velocity = Vector3.new(0, -50, 0)
                            task.wait(0.5)
                        end
                    else
                        task.wait(0.2)
                    end
                end
            end)
        else
            if AntiHitLoop then
                task.cancel(AntiHitLoop)
                AntiHitLoop = nil
            end
        end
    end
})

local SpeedLoop
local SpeedVar = false
local SpeedVal = 16
MovementWindow:Slider({
    Text = "SetSpeedBypass",
    Minimum = 16,
    Maximum = 28,
    Default = 28,
    Flag = "SetSpeedBypass",
    Callback = function(val)
        Library.Flags["SetSpeedBypass"] = val
        Library:SaveFlags()
        SpeedVal = val
    end
})
MovementWindow:Toggle({
    Text = "SpeedBypass",
    Flag = "SpeedBypass",
    Default = Library.Flags["SpeedBypass"] or false,
    Callback = function(state)
        Library.Flags["SpeedBypass"] = state
        Library:SaveFlags()
        SpeedVar = state
        if state then
            SpeedLoop = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    hrp.Velocity = hum.MoveDirection * SpeedVal + Vector3.new(0, hrp.Velocity.Y, 0)
                end
            end)
        else
            if SpeedLoop then
                SpeedLoop:Disconnect()
                SpeedLoop = nil
            end
        end
    end
})

local AntiPlaceVar = false
UtilityWindow:Toggle({
    Text = "AntiPlace",
    Flag = "AntiPlace",
    Default = Library.Flags["AntiPlace"] or false,
    Callback = function(state)
        Library.Flags["AntiPlace"] = state
        Library:SaveFlags()
        local function getAllNil(name, class)
            local results = {}
            for _, v in next, getnilinstances() do
                if v.ClassName == class and v.Name == name then
                    table.insert(results, v)
                end
            end
            return results
        end

        AntiPlaceVar = state
        if state then
            task.spawn(function()
                while AntiPlaceVar and task.wait() do
                    local map = workspace:FindFirstChild("Map")
                    if map then
                        for _, obj in ipairs(map:GetChildren()) do
                            if obj:IsA("Part") and obj.Name == "Block" then
                                obj:Destroy()
                            end
                        end
                    end

                    for _, nilObj in ipairs(getAllNil("Block", "Part")) do
                        nilObj:Destroy()
                    end
                end
            end)
        end
    end
})

local SidebarUI = game:GetService("Players").LocalPlayer.PlayerGui.MainGui["BRIDGE DUEL"]
local HotbarUI = game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.MainFrame.Background
local BetterUIsVar = false
VisualWindow:Toggle({
    Text = "BetterUIs",
    Flag = "BetterUIs",
    Default = Library.Flags["BetterUIs"] or false,
    Callback = function(state)
        Library.Flags["BetterUIs"] = state
        Library:SaveFlags()
        BetterUIsVar = state
        if state then
            task.spawn(function()
                while BetterUIsVar and task.wait() do
                    SidebarUI.Position = UDim2.new(0.899999976, 170, 0.5, 0)
                    SidebarUI.BackgroundColor3 = Color3.fromRGB(23, 39, 221)
                    SidebarUI.UIStroke.Thickness = 5
                    HotbarUI.BackgroundColor3 = Color3.fromRGB(23, 39, 221)
                    HotbarUI.UIStroke.Thickness = 5

                    SidebarUI.UIStroke.Color = Library.DefaultColor
                    HotbarUI.UIStroke.Color = Library.DefaultColor
                end
            end)
        end
    end
})

SettingsWindow:Button({
    Text = "UnInject",
    Callback = function()
        Library:Uninject()
    end
})

local targethudGui, mainFrame, pfp, nameText, hpText, targethudVar
UtilityWindow:Toggle({
    Text = "TargetHUD",
    Flag = "TargetHUD",
    Default = Library.Flags["TargetHUD"] or false,
    Callback = function(state)
        Library.Flags["TargetHUD"] = state
        Library:SaveFlags()
        if not state then
            if targethudVar then
                targethudVar:Disconnect()
                targethudVar = nil
            end
            if targethudGui then
                targethudGui:Destroy()
                targethudGui = nil
            end
            return
        end

        targethudGui = Instance.new("ScreenGui")
        targethudGui.Name = "TargetHUD"
        targethudGui.ResetOnSpawn = false
        targethudGui.IgnoreGuiInset = true
        targethudGui.Parent = game.CoreGui

        mainFrame = Instance.new("Frame", targethudGui)
        mainFrame.Size = UDim2.new(0, 250, 0, 70)
        mainFrame.Position = UDim2.new(0.5, -125, 0.7, 0)
        mainFrame.BackgroundColor3 = Library.DefaultColor
        mainFrame.BackgroundTransparency = 0.25
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Draggable = true

        SyncColor(mainFrame)

        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

        local stroke = Instance.new("UIStroke", mainFrame)
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Thickness = 5
        stroke.Transparency = 0.2

        pfp = Instance.new("ImageLabel", mainFrame)
        pfp.Size = UDim2.new(0, 60, 0, 60)
        pfp.Position = UDim2.new(0, 5, 0, 5)
        pfp.BackgroundTransparency = 1
        pfp.Image = ""
        Instance.new("UICorner", pfp).CornerRadius = UDim.new(1, 0)

        nameText = Instance.new("TextLabel", mainFrame)
        nameText.Size = UDim2.new(0, 170, 0, 30)
        nameText.Position = UDim2.new(0, 75, 0, 5)
        nameText.BackgroundTransparency = 1
        nameText.TextScaled = true
        nameText.Font = Enum.Font.GothamSemibold
        nameText.TextColor3 = Color3.fromRGB(200, 230, 255)
        nameText.Text = ""

        hpText = Instance.new("TextLabel", mainFrame)
        hpText.Size = UDim2.new(0, 170, 0, 25)
        hpText.Position = UDim2.new(0, 75, 0, 35)
        hpText.BackgroundTransparency = 1
        hpText.TextScaled = true
        hpText.Font = Enum.Font.Gotham
        hpText.TextColor3 = Color3.fromRGB(100, 200, 255)
        hpText.Text = ""

        targethudVar = RunService.RenderStepped:Connect(function()
            local target = ClosestPlayer(20)
            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                local hp = target.Character.Humanoid.Health
                if hp > 0 then
                    local name = target.DisplayName ~= "" and target.DisplayName or target.Name
                    nameText.Text = name
                    hpText.Text = "Health: " .. math.floor(hp)
                    pfp.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    mainFrame.Visible = true
                else
                    mainFrame.Visible = false
                end
            else
                mainFrame.Visible = false
            end
        end)
    end
})

local JumpFlyVar = false
MovementWindow:Keybind({
    Text = "JumpFly",
    Default = Enum.KeyCode.T,
    Callback = function()
        local keys = {
            W = false, A = false, S = false, D = false,
            Space = false, LeftShift = false
        }

        local function setKey(key, state)
            if key == Enum.KeyCode.W then keys.W = state
            elseif key == Enum.KeyCode.A then keys.A = state
            elseif key == Enum.KeyCode.S then keys.S = state
            elseif key == Enum.KeyCode.D then keys.D = state
            elseif key == Enum.KeyCode.Space then keys.Space = state
            elseif key == Enum.KeyCode.LeftShift then keys.LeftShift = state
            end
        end

        local function isMoving()
            return keys.W or keys.A or keys.S or keys.D or keys.Space or keys.LeftShift
        end

        JumpFlyVar = not JumpFlyVar

        if JumpFlyVar then
            local inputStart = UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe then setKey(input.KeyCode, true) end
            end)

            local inputEnd = UserInputService.InputEnded:Connect(function(input, gpe)
                if not gpe then setKey(input.KeyCode, false) end
            end)

            coroutine.wrap(function()
                local char = player.Character or player.CharacterAdded:Wait()
                local hum = char:WaitForChild("Humanoid")
                local root = char:WaitForChild("HumanoidRootPart")

                local gyro = Instance.new("BodyGyro")
                gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                gyro.P = 3000
                gyro.CFrame = root.CFrame
                gyro.Parent = root

                local vel = Instance.new("BodyVelocity")
                vel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                vel.P = 2000
                vel.Velocity = Vector3.zero
                vel.Parent = root

                hum.PlatformStand = false

                while JumpFlyVar do
                    local dir = Vector3.zero
                    if keys.W then dir += Vector3.new(0, 0, -1) end
                    if keys.S then dir += Vector3.new(0, 0, 1) end
                    if keys.A then dir += Vector3.new(-1, 0, 0) end
                    if keys.D then dir += Vector3.new(1, 0, 0) end

                    if dir.Magnitude > 0 then
                        local cam = workspace.CurrentCamera
                        dir = cam.CFrame:VectorToWorldSpace(dir.Unit)
                    end

                    local y = 0
                    if keys.Space then y = 1 end
                    if keys.LeftShift then y = -1 end

                    if isMoving() then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        vel.Velocity = dir * 30 + Vector3.new(0, y * 50, 0)
                    else
                        vel.Velocity = Vector3.zero
                    end

                    gyro.CFrame = workspace.CurrentCamera.CFrame
                    wait(0.4)
                end

                gyro:Destroy()
                vel:Destroy()
                hum.PlatformStand = false
                inputStart:Disconnect()
                inputEnd:Disconnect()
            end)()
        end
    end
})

local ForHudVars = {
	["NameTags"] = function() return NameTagsVar end,
	["InfJumps"] = function() return InfJumpsVar end,
	["AntiKB"] = function() return AntiKBVar end,
	["KillAura"] = function() return KAVar end,
	["FPSBoost"] = function() return FPSBoostVar end,
	["Vibe"] = function() return VibeVar end,
	["BetterUIs"] = function() return BetterUIsVar end,
	["AntiPlace"] = function() return AntiPlaceVar end,
	["AutoGG"] = function() return AutoGGVar end,
	["AutoL"] = function() return AutoLVar end,
	["AutoToxic"] = function() return NormalToxicVar end,
	["TargetHead"] = function() return TargetHeadHudVar end,
	["TargetBack"] = function() return TargetBackHudVar end,
	["TargetSafe"] = function() return TargetSafeHudVar end,
	["Watermark"] = function() return WatermarkVar end,
	["AntiHit"] = function() return AntiHitVar end,
	["StaffDetector"] = function() return StaffDetectVar end,
	["SpeedBypass"] = function() return SpeedVar end,
	["AntiCheatBypass"] = function() return JumpFlyVar end,
}

local function DestroyHUD()
	if hudconnect then
		hudconnect:Disconnect()
		hudconnect = nil
	end
	if hudGui then
		hudGui:Destroy()
		hudGui = nil
		listFrame = nil
		contentFrame = nil
		activeLabels = {}
	end
end

local function CreateHudStatus()
	DestroyHUD()
	if HUDStyle == "Off" then return end

	hudGui = Instance.new("ScreenGui")
	hudGui.Name = "HUDStatus"
	hudGui.Parent = CoreGui
	hudGui.ResetOnSpawn = false

	listFrame = Instance.new("Frame", hudGui)
	listFrame.Size = UDim2.new(0, 200, 0, 300)
	listFrame.Position = HUDStyle == "Drop" and UDim2.new(1, -210, 0, 10) or UDim2.new(1, -210, 0.3, 0)
	listFrame.BackgroundTransparency = (HUDStyle == "Drop") and 1 or 0.2
	listFrame.BackgroundColor3 = (HUDStyle == "Drop") and Color3.new(0, 0, 0) or Color3.fromRGB(20, 20, 30)
	listFrame.BorderSizePixel = 0
	Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)

	if HUDStyle == "Box" then
		local stroke = Instance.new("UIStroke", listFrame)
		stroke.Color = Library.DefaultColor
		stroke.Thickness = 5
		stroke.Transparency = 0

		local title = Instance.new("TextLabel", listFrame)
		title.Name = "BoxTitle"
		title.Size = UDim2.new(1, -10, 0, 30)
		title.Position = UDim2.new(0, 5, 0, 5)
		title.BackgroundTransparency = 1
		title.TextColor3 = Library.DefaultColor
		title.Font = Enum.Font.GothamBold
		title.TextScaled = true
		title.Text = "Smoker Client"

	elseif HUDStyle == "Drop" then
		local header = Instance.new("TextLabel", listFrame)
		header.Name = "DropHeader"
		header.Size = UDim2.new(1, -20, 0, 28)
		header.Position = UDim2.new(0, 10, 0, 0)
		header.BackgroundTransparency = 1
		header.RichText = true
		header.TextScaled = true
		header.Font = Enum.Font.GothamBold
		header.TextColor3 = Library.DefaultColor
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

local function UpdStatusHud()
	if not contentFrame then return end

	for name, isEnabled in pairs(ForHudVars) do
		local enabled = isEnabled()

		if enabled and not activeLabels[name] then
			local label = Instance.new("TextLabel")
			label.Name = name
			label.Size = UDim2.new(1, 0, 0, 24)
			label.Position = UDim2.new(0, -40, 0, 0)
			label.BackgroundTransparency = 1
			label.TextTransparency = 1
			label.Text = name
			label.Font = Enum.Font.GothamSemibold
			label.TextScaled = true
			label.LayoutOrder = #contentFrame:GetChildren()
			label.Parent = contentFrame

			if HUDStyle == "Box" then
				label.TextColor3 = Library.DefaultColor
			elseif HUDStyle == "Drop" then
				label.TextColor3 = Library.DefaultColor
				local line = Instance.new("Frame", label)
				line.Name = "ColorLine"
				line.Size = UDim2.new(0, 4, 1, 0)
				line.Position = UDim2.new(1, -4, 0, 0)
				line.AnchorPoint = Vector2.new(1, 0)
				line.BackgroundColor3 = Library.DefaultColor
				line.BorderSizePixel = 0
			end

			local showTween = TweenService:Create(label, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 0, 0, 0),
				TextTransparency = 0
			})
			showTween:Play()

			activeLabels[name] = label

		elseif not enabled and activeLabels[name] then
			local label = activeLabels[name]
			activeLabels[name] = nil

			local hideTween = TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = label.Position - UDim2.new(0, 40, 0, 0),
				TextTransparency = 1
			})

			hideTween:Play()
			hideTween.Completed:Connect(function()
				if label then
					label:Destroy()
				end
			end)
		end
	end
end

UtilityWindow:Dropdown({
	Text = "HUD Style",
	List = {"Off", "Box", "Drop"},
    Callback = function(selected)
	HUDStyle = selected
        if SidebarUI and SidebarUI:IsA("Frame") then
            SidebarUI.Visible = (HUDStyle ~= "Box")
        end

        if HUDStyle ~= "Off" then
            CreateHudStatus()
            UpdStatusHud()
            if hudconnect then hudconnect:Disconnect() end
            hudconnect = RunService.Heartbeat:Connect(UpdStatusHud)
        else
            DestroyHUD()
        end
    end
})

task.spawn(function()
	while true and task.wait(.1) do
		for _, label in pairs(activeLabels) do
			if label and label:IsDescendantOf(game) then
				label.TextColor3 = Library.DefaultColor

				local line = label:FindFirstChild("ColorLine")
				if line then
					line.BackgroundColor3 = Library.DefaultColor
				end
			end
		end

		if listFrame and HUDStyle == "Box" then
			local stroke = listFrame:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Color = Library.DefaultColor
			end

			local title = listFrame:FindFirstChild("BoxTitle")
			if title then
				title.TextColor3 = Library.DefaultColor
			end
		end

		if listFrame and HUDStyle == "Drop" then
			local header = listFrame:FindFirstChild("DropHeader")
			if header then
				header.TextColor3 = Library.DefaultColor
			end
		end

		for i = #LibrarySyncColors, 1, -1 do
			local lbl = LibrarySyncColors[i]
			if lbl and lbl:IsDescendantOf(game) then
				lbl.TextColor3 = Library.DefaultColor
			else
				table.remove(LibrarySyncColors, i)
			end
		end

		for i = #LibrarySyncBackgrounds, 1, -1 do
			local obj = LibrarySyncBackgrounds[i]
			if obj and obj:IsDescendantOf(game) then
				obj.BackgroundColor3 = Library.DefaultColor
			else
				table.remove(LibrarySyncBackgrounds, i)
			end
		end
	end
end)