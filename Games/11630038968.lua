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

local player = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local KillFeed = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Notifications"):WaitForChild("Notifications")

--States
local NameTagsVar, InfJumpsVar, AntiKBVar = false, false, false
local RGBVar, KAVar, LongJumpVar = false, false, false
local TargetVar, AntiKBConnect, RunKAConnect, CharAddedConnect, CharDiedConnect
local PreCameraCFrame, CurrentTarget, LastSwing = nil, nil, 0
local FPSBoostVar, VibeVar, HumanoidRootPart, character = false, false, hrp, Character

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
    "smxke.on.top",
    "smxke.own.this",
    "%s crying because no smxke private"
}

--Functions
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
    wait(1)
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
SettingsWindow:Dropdown({
    Text = "Theme",
    List = {"Dark", "White", "Aqua", "Nova", "RGB"},
    Callback = function(theme)
        RGBVar = false

        if theme == "Dark" then
            Library.DefaultColor = Color3.fromRGB(0, 0, 0)
        elseif theme == "White" then
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
    Callback = function(state)
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
    Callback = function(state)
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

        if selected == "Off" then return end

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
                            message = "gg " .. deadPlayer.DisplayName .. " | imusingsmxkclient"
                        elseif selected == "AutoL" then
                            message = "L " .. deadPlayer.DisplayName .. " | imusingsmxkclient"
                        elseif selected == "AutoToxic" then
                            local fmt = Messages[math.random(1, #Messages)]
                            message = string.format(fmt, deadPlayer.DisplayName, LocalPlrDisplay) .. " | imusingsmxkclient"
                        end

                        channel:SendAsync(message)
                    end
                end
            end
        end)
    end
})

MovementWindow:Toggle({
    Text = "AntiKnockback Beta",
    Callback = function(state)
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

VisualWindow:Toggle({
    Text = "Vibe",
    Callback = function(state)
        VibeVar = state
        if VibeVar == true then
            Lighting.TimeOfDay = "00:00:00"
            Lighting.Ambient = Color3.fromRGB(0, 85, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
            Lighting.Technology = Enum.Technology.Future
        else

        end
    end
})

VisualWindow:Toggle({
    Text = "Nametags",
    Callback = function(state)

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

VisualWindow:Toggle({
    Text = "FPSBoost",
    Callback = function(state)
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
    Callback = function(state)
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

MovementWindow:Keybind({
    Text = "LongJump",
    Default = Enum.KeyCode.L,
    Callback = function()

        local function LongJumpFunc()
            local character = player.Character
            if not character then return end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not rootPart then return end

            humanoid:TakeDamage(10)

            local lookVector = camera.CFrame.LookVector
            local jumpVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit * 10
            rootPart.CFrame = rootPart.CFrame + jumpVector
        end

        LongJumpVar = not LongJumpVar
        if LongJumpVar then
            LongJumpFunc()
        end
    end
})

local modes = {
    ["TargetHead"] = function()
        return RunService.Heartbeat:Connect(function()
            local HumanoidRootPart = getHumanoidRootPart()
            if not HumanoidRootPart then return end
            if isInCityArea(HumanoidRootPart.Position) then return end

            local target = ClosestPlayer(20)
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

            local target = ClosestPlayer(20)
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

            local target = PlayerLowHP(20)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") then
                local humanoid = target.Character.Humanoid
                if humanoid.Health <= 0 then return end

                local targetHRP = target.Character.HumanoidRootPart
                if isInCityArea(targetHRP.Position) then return end

                local direction = (targetHRP.Position - HumanoidRootPart.Position)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                rayParams.IgnoreWater = true

                local rayResult = workspace:Raycast(HumanoidRootPart.Position, direction, rayParams)
                if rayResult and not target.Character:IsAncestorOf(rayResult.Instance) then return end

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

        if selected ~= "None" and modes[selected] then
            TargetVar = modes[selected]()
        end
    end
})

local StaffDetectVar = false
UtilityWindow:Toggle({
    Text = "StaffDetector",
    Callback = function(state)

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
    Callback = function(state)

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
    Maximum = 37,
    Default = 35,
    Callback = function(val)
        SpeedVal = val
    end
})
MovementWindow:Toggle({
    Text = "SpeedBypass",
    Callback = function(state)
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