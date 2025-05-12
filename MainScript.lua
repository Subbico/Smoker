local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local userId = tostring(player.UserId)
local gameId = game.PlaceId
local baseUrl = "https://raw.githubusercontent.com/7Smoker/Smoker/main/Games/"

local success, data = pcall(function()
    return game:HttpGet(baseUrl .. "Blacklist.json")
end)

if success and data then
    local blacklist = HttpService:JSONDecode(data)
    if blacklist[userId] and blacklist[userId].Kick then
        player:Kick(blacklist[userId].Kick)
        return
    end
end

local scriptUrl = baseUrl .. gameId .. ".lua"
local scriptFound, scriptCode = pcall(function()
    return game:HttpGet(scriptUrl)
end)

if scriptFound and scriptCode and not scriptCode:find("404") then
    loadstring(scriptCode)()
else
    loadstring(game:HttpGet(baseUrl .. "Universal.lua"))()
end