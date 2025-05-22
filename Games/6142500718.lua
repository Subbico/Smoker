local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7Smoker/Smoker/refs/heads/main/UILibrary/Library", true))()
Library.DefaultColor = Color3.fromRGB(3, 73, 252)
local Flags = Library.Flags

local UtilityWindow = Library:Window({Text = "Utility"})
local VisualWindow = Library:Window({Text = "Visual"})
local MovementWindow = Library:Window({Text = "Movement"})
local SettingsWindow = Library:Window({Text = "Settings"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game.Lighting
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player:WaitForChild("Backpack")
local humanoid = character:WaitForChild("Humanoid")
local Nameuser = player.Name
local tools = backpack:GetChildren()
local firstTool = tools[1]
local ChatEvent = game.ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
local boomBox = character:FindFirstChild("BoomBox")
local RunService = game:GetService("RunService")

local ESPEnabled = false
local InfiniteJumpEnabled = false
local Vibe = false
local FPSBoostEnabled = false
local watermarkGui
local watermarkEnabled = false
local nametagConnections = {}

local duping = false
local stealing = false
local chatlogging = false
local existingBoombox = nil
local lastSoundIds = {}
local walkflinging = false
local characterConnection

local respawnLocation = CFrame.new(
    811.037415, 451.005951, 263.201782,
    0.979701936, 0.0151739903, 0.199884593,
    -8.84046312e-06, 0.997134209, -0.0756528974,
    -0.200459689, 0.0741155297, 0.976894498
)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

local function createNametag(player)
    if player == player then return end
    if nametagConnections[player] then
        for _, conn in pairs(nametagConnections[player]) do
            conn:Disconnect()
        end
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
        textLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Text = ""
        billboard.Parent = head

        local updateConn
        updateConn = RunService.RenderStepped:Connect(function()
            if not ESPEnabled or humanoid.Health <= 0 then
                textLabel.Text = ""
                return
            end

            local health = math.floor(humanoid.Health)
            local maxHealth = math.floor(humanoid.MaxHealth)
            local name = player.Name
            local distance = 0
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                distance = math.floor((player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
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
        for _, p in pairs(Players:GetPlayers()) do
            createNametag(p)
        end
    else
        clearNametags()
    end
end

local function anchorCharacter(character, anchor)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = anchor
        end
    end
end

local function equipAndDropAllTools()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local backpack = player:WaitForChild("Backpack")

    anchorCharacter(character, true)

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            humanoid:EquipTool(tool)
            wait(0.1)
            tool.Parent = workspace
        end
    end

    wait(0.5)
    humanoid.Health = 0
end

local function collectToolsFromWorkspace()
    local character = player.Character or player.CharacterAdded:Wait()
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("Head")
    local backpack = player:WaitForChild("Backpack")

    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            local handle = v.Handle
            handle.Anchored = false
            handle.CFrame = torso.CFrame * CFrame.new(0, 3, 0)
            v.Parent = backpack
        end
    end
end

local function initialKill()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character:FindFirstChild("Humanoid"):TakeDamage(100)
    end
end

MovementWindow:Toggle({
    Text = "InfJumps",
    Callback = function(state)
        InfiniteJumpEnabled = state
    end
})

VisualWindow:Toggle({
    Text = "Vibe",
    Callback = function(state)
        Vibe = state
        if Vibe then
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
    Callback = toggleESP
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

VisualWindow:Toggle({
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
                watermarkGui.Parent = player:WaitForChild("PlayerGui")

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
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0.75
                label.Font = Enum.Font.SourceSansBold
                label.TextScaled = true
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = container
            else
                watermarkGui.Enabled = true
            end
        else
            if watermarkGui then
                watermarkGui.Enabled = false
            end
        end
    end
})

MovementWindow:Slider({
    Text = "Speed",
    Default = 16,
    Minimum = 16,
    Maximum = 100,
    Callback = function(value)
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

UtilityWindow:Button({
    Text = "Dupe",
    Callback = function()
        initialKill()
        for i = 1, 10 do
            player.CharacterAdded:Wait()
            wait(1)
            local character = player.Character
            character:WaitForChild("HumanoidRootPart").CFrame = respawnLocation
            anchorCharacter(character, false)
            wait(0.5)
            equipAndDropAllTools()
        end
        player.CharacterAdded:Wait()
        wait(1)
        collectToolsFromWorkspace()

        for _, tool in pairs(workspace:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                local nameLower = tool.Name:lower()
                if nameLower:find("BoomBox") then
                    tool.Handle.Anchored = false
                end
            end
        end
    end
})

VisualWindow:Button({
    Text = "Client-Sided Dupe",
    Callback = function()
    for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "BoomBox" then
                existingBoombox = tool
                break
            end
        end
        if existingBoombox then
            local clone = existingBoombox:Clone()
            clone.Parent = backpack
            print("Boombox duped.")
        else
            print("Boombox not equipped!")
        end
    end
})

VisualWindow:Toggle({
    Text = "Client-Sided Dupe",
    Callback = function(state)
        if state then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "BoomBox" then
                    existingBoombox = tool
                    break
                end
            end
            if existingBoombox then
                duping = true
                task.spawn(function()
                    while duping do
                        local clone = existingBoombox:Clone()
                        clone.Parent = backpack
                        task.wait(0.1)
                    end
                end)
            else
                warn("BoomBox not found in backpack!")
            end
        else
            duping = false
        end
    end
})

UtilityWindow:Toggle({
    Text = "Steal Tools",
    Callback = function(state)
        stealing = state

        if stealing then
            task.spawn(function()
                while stealing do
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        for _, item in ipairs(workspace:GetChildren()) do
                            if item:IsA("Tool") and item.Parent == workspace then
                                pcall(function()
                                    humanoid:EquipTool(item)
                                end)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            
        end
    end
})

UtilityWindow:Button({
    Text = "DropTools",
    Callback = function()
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                humanoid:EquipTool(tool)
                wait(0.1)
                tool.Parent = workspace
            end
        end
    end
})

UtilityWindow:Button({
    Text = "Backpack",
    Callback = function()
        character.Humanoid:UnequipTools()
        firstTool.Grip = CFrame.new(-1, 1.3, 2.3) * CFrame.Angles(0, math.rad(180), 0.65)
        firstTool.Parent = character
    end
})

UtilityWindow:Toggle({
    Text = "SayAllPlaying",
    Callback = function(state)
    chatlogging = state
        if chatlogging then
            task.spawn(function()
                while chatlogging and task.wait() do
                    for _, player in pairs(Players:GetPlayers()) do
                        local success, character = pcall(function()
                            return player.Character or player.CharacterAdded:Wait()
                        end)

                        if success and character then
                            local boomBox = character:FindFirstChild("BoomBox")

                            if boomBox and boomBox:IsA("Tool") then
                                local handle = boomBox:FindFirstChild("Handle")
                                if handle then
                                    local sound = handle:FindFirstChildWhichIsA("Sound")
                                    if sound and sound.SoundId ~= "" then
                                        local soundId = string.match(sound.SoundId, "%d+")
                                        if soundId and lastSoundIds[player] ~= soundId then
                                            lastSoundIds[player] = soundId
                                            local msg = "Player: " .. player.Name .. " | www.roblox.com/games/" .. soundId
                                            ChatEvent:FireServer(msg, "All")
                                            print(msg)
                                        end
                                    else
                                        print("Player:", player.Name, "| Is not playing any audio.")
                                    end
                                else
                                    print("Player:", player.Name, "| Handle not found.")
                                end
                            else
                                print("Player:", player.Name, "| BoomBox not found.")
                            end
                        end
                    end
                end
            end)
        else
            lastSoundIds = {}
        end
    end
})

VisualWindow:Toggle({
    Text = "Logger",
    Callback = function(state)
    chatlogging = state
        if chatlogging then
            task.spawn(function()
                while chatlogging and task.wait() do
                    for _, player in pairs(Players:GetPlayers()) do
                        local success, character = pcall(function()
                            return player.Character or player.CharacterAdded:Wait()
                        end)

                        if success and character then
                            local boomBox = character:FindFirstChild("BoomBox")

                            if boomBox and boomBox:IsA("Tool") then
                                local handle = boomBox:FindFirstChild("Handle")
                                if handle then
                                    local sound = handle:FindFirstChildWhichIsA("Sound")
                                    if sound and sound.SoundId ~= "" then
                                        local soundId = string.match(sound.SoundId, "%d+")
                                        if soundId and lastSoundIds[player] ~= soundId then
                                            lastSoundIds[player] = soundId
                                            Library:Notification{Text = "Player: " .. player.Name, Text = "Listening ID: " .. soundId, Duration = 50}
                                        end
                                    else
                                        print("Player:", player.Name, "| Is not playing any audio.")
                                    end
                                else
                                    print("Player:", player.Name, "| Handle not found.")
                                end
                            else
                                print("Player:", player.Name, "| BoomBox not found.")
                            end
                        end
                    end
                end
            end)
        else
            lastSoundIds = {}
        end
    end
})

UtilityWindow:Toggle({
    Text = "WalkFling",
    Callback = function(state)
    walkflinging = state

        if state then
            local function startWalkFling(char)
                local Root = char:WaitForChild("HumanoidRootPart")
                local Humanoid = char:WaitForChild("Humanoid")
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                Humanoid.BreakJointsOnDeath = false

                RunService.Stepped:Connect(function()
                    if walkflinging then
                        Humanoid.Health = math.huge
                        Humanoid.MaxHealth = math.huge
                    end
                end)

                Root.CanCollide = false
                Humanoid:ChangeState(11)

                spawn(function()
                    while walkflinging and Root and Root.Parent do
                        RunService.Heartbeat:Wait()
                        local vel = Root.Velocity
                        Root.Velocity = vel * 99999999 + Vector3.new(0, 99999999, 0)
                        RunService.RenderStepped:Wait()
                        Root.Velocity = vel
                        RunService.Stepped:Wait()
                        Root.Velocity = vel + Vector3.new(0, 0.1, 0)
                    end
                end)
            end

            if player.Character then
                startWalkFling(player.Character)
            end

            if characterConnection then characterConnection:Disconnect() end
            characterConnection = player.CharacterAdded:Connect(startWalkFling)

        else
            walkflinging = false
            if characterConnection then
                characterConnection:Disconnect()
                characterConnection = nil
            end
        end
    end
})

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