local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7Smoker/Smoker/refs/heads/main/UILibrary/Library", true))()
Library.DefaultColor = Color3.fromRGB(3, 73, 252)

local VisualWindow = Library:Window({Text = "Visual"})
local MovementWindow = Library:Window({Text = "Movement"})
local SettingsWindow = Library:Window({Text = "Settings"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local nametagConnections = {}

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
        textLabel.TextStrokeColor3 = Color3.new()
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Text = ""

        billboard.Parent = head

        task.spawn(function()
            while textLabel and textLabel.Parent do
                textLabel.TextColor3 = Library.DefaultColor
                task.wait(0.03)
            end
        end)

        local updateConn = RunService.RenderStepped:Connect(function()
            if not Library.Flags["Nametags"] then
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
        for _, conn in pairs(conns) do conn:Disconnect() end
        nametagConnections[player] = nil
        if player.Character and player.Character:FindFirstChild("Head") then
            local tag = player.Character.Head:FindFirstChild("CustomNametag")
            if tag then tag:Destroy() end
        end
    end
end

VisualWindow:Label({
    Text = "Smoker Client",
    Color = Library.DefaultColor
})

VisualWindow:Toggle({
    Text = "Vibe",
    Flag = "Vibe",
    Default = Library.Flags["Vibe"] or false,
    Callback = function(state)
        Library.Flags["Vibe"] = state
        Library:SaveFlags()
        if state then
            Lighting.TimeOfDay = "00:00:00"
            Lighting.Ambient = Color3.fromRGB(0, 85, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
            Lighting.Technology = Enum.Technology.Future
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
        if state then
            for _, player in pairs(Players:GetPlayers()) do
                NameTagCreate(player)
            end
        else
            clearNametags()
        end
    end
})

VisualWindow:Toggle({
    Text = "FPSBoost",
    Flag = "FPSBoost",
    Default = Library.Flags["FPSBoost"] or false,
    Callback = function(state)
        Library.Flags["FPSBoost"] = state
        Library:SaveFlags()
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
        end
    end
})

local WatermarkState = nil
local WatermarkVar = false
VisualWindow:Toggle({
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

MovementWindow:Slider({
    Text = "Speed",
    Flag = "Speed",
    Default = Library.Flags["Speed"] or 16,
    Minimum = 16,
    Maximum = 100,
    Callback = function(value)
        Library.Flags["Speed"] = value
        Library:SaveFlags()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

SettingsWindow:Dropdown({
    Text = "Theme",
    List = {"Dark", "White", "Aqua", "Nova", "RGB"},
    Callback = function(theme)
        RGBEnabled = false

        if theme == "Dark" then
            Library.DefaultColor = Color3.new(0, 0, 0)
        elseif theme == "White" then
            Library.DefaultColor = Color3.new(1, 1, 1)
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
    end
})

SettingsWindow:Keybind({
    Text = "Toggle Library",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        Library:Toggle()
    end
})