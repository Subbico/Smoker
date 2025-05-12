local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local userId = tostring(player.UserId)
local gameId = game.PlaceId
local baseUrl = "https://raw.githubusercontent.com/7Smoker/Smoker/main/Games/"

local function showNotification(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

local scriptUrl = baseUrl .. gameId .. ".lua"
local scriptFound, scriptCode = pcall(function()
    return game:HttpGet(scriptUrl)
end)

if scriptFound and scriptCode and not scriptCode:find("404") then
    loadstring(scriptCode)()
else
    showNotification("Game Not Supported", "Launching Universal Script...")
    loadstring(game:HttpGet(baseUrl .. "Universal.lua"))()
end
