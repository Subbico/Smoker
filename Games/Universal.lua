local SmokerGUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local duping = false

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player:WaitForChild("Backpack")
local humanoid = character:WaitForChild("Humanoid")
local existingBoombox = nil
local respawnLocation = CFrame.new(
    811.037415, 451.005951, 263.201782,
    0.979701936, 0.0151739903, 0.199884593,
    -8.84046312e-06, 0.997134209, -0.0756528974,
    -0.200459689, 0.0741155297, 0.976894498
)

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

game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Credit Script: Made By Smxker", "All")

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
                if nameLower:find("boombox") or nameLower:find("radio") then
                    tool.Handle.Anchored = false
                end
            end
        end
    end
}

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
            if GUI then
                GUI:Notification{
                    Title = "Dupe Disabled",
                    Text = nil,
                    Duration = 3,
                    Callback = function() end
                }
            end
        end
    end
}

GUI:Credit{
	Name = "7Smoker",
	Description = "Created the script",
	V3rm = nil,
	Discord = nil
}