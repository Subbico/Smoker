local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gameId = tostring(game.PlaceId)
local PathURL = "https://raw.githubusercontent.com/7Smoker/Smoker/main/Games/"

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

local function safeLoadstring(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success and response and not response:find("404") then
        local ok, err = pcall(loadstring(response))
        if not ok then

        end
        return true
    else
        return false
    end
end

local gameScriptUrl = PathURL .. gameId .. ".lua"
local loadedGameScript = safeLoadstring(gameScriptUrl)

if not loadedGameScript then
    local universalUrl = "https://raw.githubusercontent.com/7Smoker/Smoker/main/Games/Universal.lua"
    safeLoadstring(universalUrl)
end

local whitelistUrl = "https://raw.githubusercontent.com/7Smoker/Smoker/refs/heads/main/UILibrary/checkwhitelist.lua"
safeLoadstring(whitelistUrl)