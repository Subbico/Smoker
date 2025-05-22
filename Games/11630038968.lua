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

--States
local ESPEnabled, InfiniteJumpEnabled, AutoGGEnabled, AntiKnockbackEnabled = false, false, false, false
local WatermarkEnabled, RGBEnabled, enabled, running, following = true, false, false, false, false
local followConnection, antiKnockbackConnection, runConnection, characterAddedConnection, humanoidDiedConnection
local originalCameraCFrame, currentTarget, lastSwingTime, watermarkGui = nil, nil, 0, nil
local activeMethod, connection, FPSBoostEnabled, Vibe, autoToxicEnabled, HumanoidRootPart, character, staffDetectorEnabled = nil, nil, false, false, false, hrp, Character, false
local SpeedEnabled, AntiHitEnabled, SpeedValue = false, false, 16

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local rotationAngle = 0
local rotationSpeed = math.rad(360)

local SwordItems = {"WoodenSword", "TemplateSword", "DiamondSword", "GoldSword", "Sword"}
local nametagConnections = {}
local connections = {}
local messages = {
    "L %s",
    "smxke.on.top",
    "smxke.own.this",
    "%s crying because no smxke private"
}

--Functions
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

local function getClosestPlayer(maxDistance)
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

local function createNametag(player)
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
            if not ESPEnabled then
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

local function toggleESP(state)
    ESPEnabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            createNametag(player)
        end
    else
        clearNametags()
    end
end


local function resetCamera()
    if camera and camera.CameraType == Enum.CameraType.Scriptable then
        camera.CameraType = Enum.CameraType.Custom
        if originalCameraCFrame then
            camera.CFrame = originalCameraCFrame
            originalCameraCFrame = nil
        end
    end
end

local function disconnectLoop()
    if runConnection then
        runConnection:Disconnect()
        runConnection = nil
    end
    if humanoidDiedConnection then
        humanoidDiedConnection:Disconnect()
        humanoidDiedConnection = nil
    end
    resetCamera()
end

local function getClosestPlayer()
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

local function CombatAura()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    disconnectLoop()

    runConnection = RunService.RenderStepped:Connect(function()
        if not enabled then
            disconnectLoop()
            return
        end

        if not character.Parent then
            disconnectLoop()
            return
        end

        local localSword = getSword(character)
        if not localSword then
            resetCamera()
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

        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") then
            local targetHumanoid = currentTarget.Character.Humanoid
            local targetHRP = currentTarget.Character:FindFirstChild("HumanoidRootPart")
            if targetHumanoid.Health <= 0 or not targetHRP then
                currentTarget = nil
            elseif (targetHRP.Position - humanoidRootPart.Position).Magnitude > 23 then
                currentTarget = nil
            end
        end


        if not currentTarget then
            local closestPlayer, distance = getClosestPlayer()
            if closestPlayer and distance <= 23 then
                currentTarget = closestPlayer
            end
        end

        if not isInCity and currentTarget and currentTarget.Character then
            local targetHead = currentTarget.Character:FindFirstChild("Head")
            if targetHead then
                if not originalCameraCFrame and camera.CameraType ~= Enum.CameraType.Scriptable then
                    originalCameraCFrame = camera.CFrame
                end

                camera.CameraType = Enum.CameraType.Scriptable
                camera.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 2, 0), targetHead.Position)

                if tick() - lastSwingTime >= 0.1 then
                    lastSwingTime = tick()
                    if localSword.Parent == character then
                        localSword:Activate()
                    end
                end

                return
            end
        end

        if camera.CameraType == Enum.CameraType.Scriptable then
            camera.CameraType = Enum.CameraType.Custom
            if originalCameraCFrame then
                camera.CFrame = originalCameraCFrame
                originalCameraCFrame = nil
            end
        end
    end)

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoidDiedConnection = humanoid.Died:Connect(function()
            disconnectLoop()
            currentTarget = nil
        end)
    end
end

local function onCharacterAdded(character)
    wait(1)
    if enabled then
        CombatAura()
    else
        resetCamera()
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

if not characterAddedConnection then
    characterAddedConnection = player.CharacterAdded:Connect(onCharacterAdded)
end

local function isAnotherPlayerAlive(deadPlayer)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= deadPlayer then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    return true
                end
            end
        end
    end
    return false
end

local function onHumanoidDied(deadPlayer)
    if not AutoGGEnabled then return end
    if isAnotherPlayerAlive(deadPlayer) then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            local message = "gg " .. deadPlayer.DisplayName
            channel:SendAsync(message)
        else
            warn("RBXGeneral channel not found.")
        end
    end
end

local function connectCharacter(character, player)
    local humanoid = character:WaitForChild("Humanoid")
    local conn = humanoid.Died:Connect(function()
        onHumanoidDied(player)
    end)
    table.insert(connections, conn)
end

local function connectPlayer(player)
    if player.Character then
        connectCharacter(player.Character, player)
    end
    local conn = player.CharacterAdded:Connect(function(character)
        connectCharacter(character, player)
    end)
    table.insert(connections, conn)
end

local function disconnectAll()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}
end

local function getPlayerWithLowestHealth(range)
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

local function isLineOfSightClear(origin, targetPosition)
    local direction = targetPosition - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        local distanceToHit = (raycastResult.Position - origin).Magnitude
        local distanceToTarget = direction.Magnitude
        if distanceToHit < distanceToTarget then
            return false
        end
    end
    return true
end

--Features
SettingsWindow:Dropdown({
    Text = "Theme",
    List = {"Dark", "White", "Aqua", "Nova", "RGB"},
    Callback = function(theme)
        RGBEnabled = false

        if theme == "Dark" then
            Library.DefaultColor = Color3.fromRGB(0, 0, 0)
        elseif theme == "White" then
            Library.DefaultColor = Color3.fromRGB(255, 255, 255)
        elseif theme == "Aqua" then
            Library.DefaultColor = Color3.fromRGB(66, 245, 194)
        elseif theme == "Nova" then
            Library.DefaultColor = Color3.fromRGB(255, 0, 234)
        elseif theme == "RGB" then
            RGBEnabled = true
            task.spawn(function()
                while RGBEnabled do
                    for hue = 0, 1, 0.01 do
                        if not RGBEnabled then break end
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
        enabled = state
        if enabled then
            if player.Character then
                CombatAura()
            end
        else
            disconnectLoop()
        end
    end
})

CombatWindow:Toggle({
    Text = "TargetHead",
    Callback = function(state)
        following = state

        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end

        if following then
            followConnection = RunService.Heartbeat:Connect(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart

                local cityModel = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("City")
                local isInCity = false
                if cityModel and cityModel:IsA("Model") then
                    local cityRegion = cityModel:GetExtentsSize()
                    local cityCFrame = cityModel:GetModelCFrame()
                    local cityMin = cityCFrame.Position - (cityRegion / 2)
                    local cityMax = cityCFrame.Position + (cityRegion / 2)

                    local pos = HumanoidRootPart.Position
                    if pos.X >= cityMin.X and pos.X <= cityMax.X and
                    pos.Y >= cityMin.Y and pos.Y <= cityMax.Y and
                    pos.Z >= cityMin.Z and pos.Z <= cityMax.Z then
                        isInCity = true
                    end
                end

                if not isInCity then
                    local target = getClosestPlayer(20)

                    if target and target.Character and target.Character:FindFirstChild("Head") and target.Character:FindFirstChild("Humanoid") then
                        local humanoid = target.Character.Humanoid
                        if humanoid.Health > 0 then
                            local targetHead = target.Character.Head
                            local desiredPosition = targetHead.Position + Vector3.new(0, 8, 0)
                            local direction = (desiredPosition - HumanoidRootPart.Position).Unit
                            local speed = 20
                            HumanoidRootPart.Velocity = direction * speed
                        end
                    end
                end
            end)
        end
    end
})

MovementWindow:Toggle({
    Text = "InfJumps",
    Callback = function(state)
        InfiniteJumpEnabled = state
    end
})

UtilityWindow:Toggle({
    Text = "AutoToxic",
    Callback = function(state)
        autoToxicEnabled = state
        if autoToxicEnabled then
            spawn(function()
                while autoToxicEnabled do
                    local otherPlayers = {}
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            table.insert(otherPlayers, player)
                        end
                    end

                    if #otherPlayers > 0 then
                        local randomPlayer = otherPlayers[math.random(1, #otherPlayers)]
                        local randomMsgTemplate = messages[math.random(1, #messages)]
                        local msg = string.format(randomMsgTemplate, randomPlayer.Name)
                        TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
                    end

                    wait(10)
                end
            end)
        end
    end
})

MovementWindow:Toggle({
    Text = "AntiKnockback Beta",
    Callback = function(state)
        antiKnockbackEnabled = state
        if antiKnockbackEnabled then
            antiKnockbackConnection = RunService.Heartbeat:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end)
        else
            if antiKnockbackConnection then
                antiKnockbackConnection:Disconnect()
                antiKnockbackConnection = nil
            end
        end
    end
})

VisualWindow:Toggle({
    Text = "Vibe",
    Callback = function(state)
        Vibe = state
        if Vibe == true then
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
        toggleESP(state)
    end
})

VisualWindow:Toggle({
    Text = "FPSBoost",
    Callback = function(state)
        FPSBoostEnabled = state

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

CreditsWindow:Toggle({
    Text = "Watermark",
    Callback = function(state)
        watermarkEnabled = state

        if state then
            if not watermarkGui then
                watermarkGui = Instance.new("ScreenGui")
                watermarkGui.Name = "SmokerWatermark"
                watermarkGui.ResetOnSpawn = false
                watermarkGui.IgnoreGuiInset = true
                watermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
                watermarkGui.DisplayOrder = 100
                watermarkGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

                local container = Instance.new("Frame")
                container.Name = "WatermarkContainer"
                container.AnchorPoint = Vector2.new(1, 0)
                container.Position = UDim2.new(1, -10, 0, 10)
                container.Size = UDim2.new(0, 320, 0, 60)
                container.BackgroundTransparency = 0.25
                container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                container.BorderSizePixel = 0
                container.Parent = watermarkGui

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
                watermarkGui.Enabled = true
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
            if watermarkGui then
                watermarkGui.Enabled = false
            end
        end
    end
})

MovementWindow:Keybind({
    Text = "LongJump",
    Default = Enum.KeyCode.L,
    Callback = function()

        local function doLongJump()
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

        enabled = not enabled
        if enabled then
            doLongJump()
        end
    end
})

CombatWindow:Toggle({
    Text = "TargetBack",
    Callback = function(state)
        following = state

        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end

        if following then
            followConnection = RunService.Heartbeat:Connect(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart

                local cityModel = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("City")
                local isInCity = false
                if cityModel and cityModel:IsA("Model") then
                    local cityRegion = cityModel:GetExtentsSize()
                    local cityCFrame = cityModel:GetModelCFrame()
                    local cityMin = cityCFrame.Position - (cityRegion / 2)
                    local cityMax = cityCFrame.Position + (cityRegion / 2)

                    local pos = HumanoidRootPart.Position
                    if pos.X >= cityMin.X and pos.X <= cityMax.X and
                       pos.Y >= cityMin.Y and pos.Y <= cityMax.Y and
                       pos.Z >= cityMin.Z and pos.Z <= cityMax.Z then
                        isInCity = true
                    end
                end

                if not isInCity then
                    local target = getClosestPlayer(20)

                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") then
                        local humanoid = target.Character.Humanoid
                        if humanoid.Health > 0 then
                            local targetHRP = target.Character.HumanoidRootPart

                            local backPosition = targetHRP.Position - (targetHRP.CFrame.LookVector * 5) + Vector3.new(0, 2, 0)

                            local direction = (backPosition - HumanoidRootPart.Position).Unit
                            local speed = 40
                            HumanoidRootPart.Velocity = direction * speed
                        end
                    end
                end
            end)
        end
    end
})

UtilityWindow:Toggle({
    Text = "AutoGG",
    Callback = function(enabled)
        AutoGGEnabled = enabled
        if enabled then
            for _, player in pairs(Players:GetPlayers()) do
                connectPlayer(player)
            end
            Players.PlayerAdded:Connect(connectPlayer)
        else
            disconnectAll()
        end
    end
})

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
                    print("[StaffDetector] Staff detected: " .. player.Name .. " - Rank: " .. roleName)
                    Library:Notification({
                        Text = "Staff Detected! " .. player.Name .. " is a " .. roleName,
                        Duration = 20,
                        Color = Color3.fromRGB(255, 0, 34)
                    })
                else
                    print("[StaffDetector] No role detected for: ", player.Name, "(Rank:", rank .. ")")
                end
            end
        end
        
        staffDetectorEnabled = state

        if state then
            for _, player in pairs(game.Players:GetPlayers()) do
                checkPlayer(player)
            end

            game.Players.PlayerAdded:Connect(function(player)
                if staffDetectorEnabled then
                    task.wait(1)
                    checkPlayer(player)
                end
            end)
        end
    end
})

CombatWindow:Toggle({
    Text = "TargetSafe",
    Callback = function(state)
        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end

        if state then
            rotationAngle = 0

            followConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart

                local target = getPlayerWithLowestHealth(20)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") then
                    local humanoid = target.Character.Humanoid
                    if humanoid.Health > 0 then
                        local targetHRP = target.Character.HumanoidRootPart

                        local cityModel = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("City")
                        local isInCity = false
                        if cityModel and cityModel:IsA("Model") then
                            local cityRegion = cityModel:GetExtentsSize()
                            local cityCFrame = cityModel:GetModelCFrame()
                            local cityMin = cityCFrame.Position - (cityRegion / 2)
                            local cityMax = cityCFrame.Position + (cityRegion / 2)

                            local pos = targetHRP.Position
                            if pos.X >= cityMin.X and pos.X <= cityMax.X and
                               pos.Y >= cityMin.Y and pos.Y <= cityMax.Y and
                               pos.Z >= cityMin.Z and pos.Z <= cityMax.Z then
                                isInCity = true
                            end
                        end

                        if isInCity then return end

                        local direction = (targetHRP.Position - HumanoidRootPart.Position)
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        rayParams.IgnoreWater = true

                        local rayResult = workspace:Raycast(HumanoidRootPart.Position, direction, rayParams)
                        if rayResult and not target.Character:IsAncestorOf(rayResult.Instance) then
                            return
                        end

                        rotationAngle = rotationAngle + rotationSpeed * deltaTime
                        if rotationAngle > math.pi * 2 then
                            rotationAngle = rotationAngle - math.pi * 2
                        end

                        local offset = Vector3.new(math.cos(rotationAngle) * 5, 4, math.sin(rotationAngle) * 5)
                        local desiredPosition = targetHRP.Position + offset

                        local moveDirection = (desiredPosition - HumanoidRootPart.Position)
                        local distance = moveDirection.Magnitude
                        if distance > 0 then
                            local moveSpeed = math.min(distance / deltaTime, 28)
                            HumanoidRootPart.Velocity = moveDirection.Unit * moveSpeed
                        else
                            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end)
        end
    end
})

local AntiHitLoop

local function getAntiHitPlayer(maxDist)
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

CombatWindow:Toggle({
    Text = "AntiHit",
    Callback = function(state)
        AntiHitEnabled = state

        if state then
            AntiHitLoop = task.spawn(function()
                while AntiHitEnabled do
                    local target = getAntiHitPlayer(25)
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
MovementWindow:Slider({
    Text = "SetSpeedBypass",
    Minimum = 16,
    Maximum = 37,
    Default = 35,
    Callback = function(val)
        SpeedValue = val
    end
})

MovementWindow:Toggle({
    Text = "SpeedBypass",
    Callback = function(state)
        SpeedEnabled = state

        if state then
            SpeedLoop = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    hrp.Velocity = hum.MoveDirection * SpeedValue + Vector3.new(0, hrp.Velocity.Y, 0)
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