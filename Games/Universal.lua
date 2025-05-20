-- Load GUI Library
local SmokerGUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

-- Services and Player References
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

-- State Variables
local duping = false
local stealing = false
local chatlogging = false
local existingBoombox = nil
local lastSoundIds = {}
local walkflinging = false
local characterConnection

-- Respawn Location
local respawnLocation = CFrame.new(
    811.037415, 451.005951, 263.201782,
    0.979701936, 0.0151739903, 0.199884593,
    -8.84046312e-06, 0.997134209, -0.0756528974,
    -0.200459689, 0.0741155297, 0.976894498
)

-- Utility Functions

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

-- Chat Credit Message
game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Credit Script: Made By Smxker", "All")

-- GUI Setup
local GUI = SmokerGUI:Create{
    Name = "Smoker",
    Size = UDim2.fromOffset(600, 400),
    Theme = SmokerGUI.Themes.Dark,
    Link = "https://github.com/7Smoker/"
}

local MainTab = GUI:Tab{
    Name = "Main",
    Icon = "rbxassetid://8569322835"
}

local VisualizerTab = GUI:Tab{
    Name = "Visualizer",
    Icon = "rbxassetid://103555619537122"
}

local LoggerTab = GUI:Tab{
    Name = "Loggers",
    Icon = "rbxassetid://103555619537122"
}

-- Dupe Button
MainTab:Button{
	Name = "Dupe",
	Description = "Dupe Radios",
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
}

-- Client-Sided Dupe Button
MainTab:Button{
    Name = "Client-Sided Dupe",
    Description = "Dupe Radios that only you can see",
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
}

-- Client-Sided Dupe Toggle
MainTab:Toggle{
    Name = "Client-Sided Dupe",
    StartingState = false,
    Description = "Dupe Radios that only you can see",
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
            GUI:Notification{
                Title = "Dupe Disabled",
                Text = "Dupe is now off.",
                Duration = 3,
                Callback = function() end
            }
        end
    end
}

-- Steal Tools Toggle
MainTab:Toggle{
    Name = "Steal Tools",
    StartingState = false,
    Description = "Automatically equips any tool found in the Workspace.",
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
            GUI:Notification{
                Title = "Steal Tools Disabled",
                Text = "Tool grabbing has been stopped.",
                Duration = 3
            }
        end
    end
}

--DropTools
MainTab:Button{
    Name = "DropTools",
    Description = "Drop all the radios in your inventory.",
    Callback = function()
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                humanoid:EquipTool(tool)
                wait(0.1)
                tool.Parent = workspace
            end
        end
    end
}

--Backpack
VisualizerTab:Button{
    Name = "Backpack",
    Description = "1 Boombox needed",
    Callback = function()
        character.Humanoid:UnequipTools()
        firstTool.Grip = CFrame.new(-1, 1.3, 2.3) * CFrame.Angles(0, math.rad(180), 0.65)
        firstTool.Parent = character
    end
}

--Logger
LoggerTab:Toggle{
    Name = "SayAllPlaying",
    StartingState = false,
    Description = "Say in chat all the players music id currently playing.",
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
            GUI:Notification{
                Title = "SayAllPlaying Disabled",
                Text = "Stealing IDS has been stopped.",
                Duration = 3
            }
            lastSoundIds = {}
        end
    end
}

--Logger
LoggerTab:Toggle{
    Name = "Logger",
    StartingState = false,
    Description = "Shows you what people are listening (IDS).",
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
                                            GUI:Notification{ Title = "Player: " .. player.Name, Text = "Listening ID: " .. soundId, Duration = 50}
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
            GUI:Notification{
                Title = "SayAllPlaying Disabled",
                Text = "Stealing IDS has been stopped.",
                Duration = 3
            }
            lastSoundIds = {}
        end
    end
}

--WalkFling
MainTab:Toggle{
    Name = "WalkFling",
    StartingState = false,
    Description = "Fling others, dont abuse.",
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
}

-- Credits
GUI:Credit{
    Name = "7Smoker",
    Description = "Created the script",
    V3rm = nil,
    Discord = nil
}