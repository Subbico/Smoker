local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7Smoker/Smoker/refs/heads/main/UILibrary/Library", true))()
local Flags = Library.Flags

Library.DefaultColor = Color3.fromRGB(3, 73, 252)

local CreditsWindow = Library:Window({Text = "Credits"})
local CombatWindow = Library:Window({Text = "Combat"})
local UtilityWindow = Library:Window({Text = "Utility"})
local MovementWindow = Library:Window({Text = "Movement"})
local VisualWindow = Library:Window({Text = "Visual"})
local SettingsWindow = Library:Window({Text = "Settings"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game.Lighting

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

local SwordItems = {"WoodenSword", "TemplateSword", "DiamondSword", "GoldSword", "Sword"}

local enabled = false
local runConnection = nil
local humanoidDiedConnection = nil
local characterAddedConnection = nil
local originalCameraCFrame = nil
local currentTarget = nil
local lastSwingTime = 0

local activeMethod = nil
local running = false
local connection = nil

local ESPEnabled = false
local nametagConnections = {}

local FPSBoostEnabled = false

local following = false
local followConnection

local Vibe = false

local autoToxicEnabled = false

local InfiniteJumpEnabled = false

local antiKnockbackEnabled = false
local antiKnockbackConnection

local watermarkGui
local watermarkEnabled = true

local LocalPlayer = player
local Character = character
local HumanoidRootPart = hrp

local RGBEnabled = false

local messages = {
    "L %s",
    "smxke.on.top",
    "smxke.own.this",
    "%s crying because no smxke private"
}

local enabled = false
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

if not characterAddedConnection then
    characterAddedConnection = player.CharacterAdded:Connect(onCharacterAdded)
end

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
                            local speed = 45
                            HumanoidRootPart.Velocity = direction * speed
                        end
                    end
                end
            end)
        end
    end
})