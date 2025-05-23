local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gameId = game.PlaceId
local PathURL = "https://raw.githubusercontent.com/7Smoker/Smoker/main/Games/"

local scriptUrl = PathURL .. gameId .. ".lua"
local SF, SC = pcall(function()
    return game:HttpGet(scriptUrl)
end)

if SF and SC and not SC:find("404") then
    loadstring(SC)()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/7Smoker/Smoker/refs/heads/main/UILibrary/checkwhitelist.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/7Smoker/Smoker/main/Games/Universal.lua"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/7Smoker/Smoker/refs/heads/main/UILibrary/checkwhitelist.lua"))()
end