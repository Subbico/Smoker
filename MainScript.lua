local p = game:GetService("Players").LocalPlayer
local hs = game:GetService("HttpService")
local base = "https://raw.githubusercontent.com/7Smoker/Smoker/main/"
local api = "https://api.github.com/repos/7Smoker/Smoker/contents/"
local root = "SmokerV4"

local Patched = {
    ["71480482338212"] = {
        Messages = {
            "Smxker its currently Patched for this game",
            "Please wait until we patch the anticheat again. (soon)",
            "⚠️ BANNABLE: KillAura, Speed been patched"
        },
        ExecuteAnyway = false
    }
}

local function notify(msg)
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = "Smoker Client";
        Text = msg;
        Duration = 15,
    })
end

local currentGame = Patched[tostring(game.PlaceId)]
if currentGame then
    for _, msg in ipairs(currentGame.Messages) do
        notify(msg)
        wait(1)
    end
    if not currentGame.ExecuteAnyway then
        return
    end
end

local function ex(f)
    local s, r = pcall(function() return isfolder(f) end)
    return s and r
end

if ex("SmokerV4/Chace") then
    p:Kick("Blacklisted from Smoker Client. Have a nice day")
    return
end

local function fetch(u)
    local s, r = pcall(function() return game:HttpGet(u) end)
    return s and r and not r:find("404") and r
end

local function run(u)
    local r = fetch(u)
    if r then pcall(loadstring(r)) return true end
end

if not run(base .. "games/" .. game.PlaceId .. ".lua") then
    run(base .. "games/Universal.lua")
end

run(base .. "UILibrary/Whitelist.lua")

local function mk(p)
    if not isfolder(p) then makefolder(p) end
end

for _, f in ipairs({"Games", "Assets", "Data", "UILibrary"}) do
    mk(root .. "/" .. f)
end

local function grab(path, localPath)
    local r = fetch(api .. path)
    if not r then return end
    for _, v in pairs(hs:JSONDecode(r)) do
        local lp = localPath .. "/" .. v.name
        if v.type == "file" then
            if not isfile(lp) then
                local d = fetch(v.download_url)
                if d then
                    local parts = string.split(lp, "/")
                    table.remove(parts)
                    local dir = table.concat(parts, "/")
                    if not isfolder(dir) then makefolder(dir) end
                    writefile(lp, d)
                end
            end
        else
            mk(lp)
            grab(path .. "/" .. v.name, lp)
        end
    end
end

for _, f in ipairs({"Games", "Assets", "Data", "UILibrary"}) do
    grab(f, root .. "/" .. f)
end

local function dl(u, path)
    local r = fetch(u)
    if r and not isfile(path) then writefile(path, r) end
end

dl(base .. "loader.lua", root .. "/loader.lua")
dl(base .. "loadstring", root .. "/loadstring")