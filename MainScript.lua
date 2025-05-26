local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeId = game.PlaceId

task.spawn(function()
    while true do
        if isfolder("Smoker/Chace") then
            player:Kick("Blacklisted from Smoker Client. Have a nice day")
            break
        end
        task.wait()
    end
end)

local function readFileSafely(path)
    local success, result = pcall(readfile, path)
    return success and result or nil
end

local function writeFileSafely(path, content)
    pcall(function() writefile(path, content) end)
end

local function fetchFromUrl(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    return success and result or nil
end

local baseUrl = "https://raw.githubusercontent.com/7Smoker/Smoker/main/Games/"
local remoteUrl = baseUrl .. placeId .. ".lua"
local localFilePath = "Smoker/Games/" .. placeId .. ".lua"
local remoteScript = fetchFromUrl(remoteUrl)

if remoteScript and not remoteScript:find("404") then
    local localScript = readFileSafely(localFilePath)

    if localScript ~= remoteScript then
        writeFileSafely(localFilePath, remoteScript)
    end

    loadstring(remoteScript)()
else
    local fallbackScript = readFileSafely("Smoker/Games/Universal.lua")
    if fallbackScript then
        loadstring(fallbackScript)()
    else
        
    end
end

local whitelistScript = readFileSafely("Smoker/UILibrary/checkwhitelist.lua")
if whitelistScript then
    loadstring(whitelistScript)()
end