local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeId = tostring(game.PlaceId)

local function folderExists(folderName)
    local success, result = pcall(function()
        return isfolder and isfolder(folderName)
    end)
    return success and result
end

if folderExists("Smoker/Chace") then
    player:Kick("Blacklisted from Smoker Client. Have a nice day")
    return
end

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

    local success, err = pcall(function()
        loadstring(remoteScript)()
    end)

    if not success then

    end
else
    local fallbackScript = readFileSafely("Smoker/Games/Universal.lua")
    if fallbackScript then
        local success, err = pcall(function()
            loadstring(fallbackScript)()
        end)
        if not success then
            warn("Errore eseguendo fallback script:", err)
        end
    else
        warn("Nessuno script disponibile da caricare.")
    end
end

local whitelistScript = readFileSafely("Smoker/UILibrary/checkwhitelist.lua")
if whitelistScript then
    local success, err = pcall(function()
        loadstring(whitelistScript)()
    end)
    if not success then
        
    end
end