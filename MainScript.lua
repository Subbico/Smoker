local P,S,G=game:GetService("Players"),game:GetService("StarterGui"),game:GetService("HttpService")
local pl=P.LocalPlayer
local R="SmokerV4" D=R.."/Data" VF=D.."/Version.json"
local RV="https://raw.githubusercontent.com/Subbico/Smoker/main/Data/Version.json"
local B="https://raw.githubusercontent.com/Subbico/Smoker/main/"
local A="https://api.github.com/repos/Subbico/Smoker/contents/"

local function n(m) S:SetCore("SendNotification", {Title = "⚠Smoker Client⚠",Text = m,Duration = 15,Button1 = "OK"}) end
local function f(p) if not isfolder(p) then makefolder(p) end end

f(R) f(D) for _,v in ipairs({"Games","Assets","Data","UILibrary"}) do f(R.."/"..v) end

local function g(u) local s,r=pcall(game.HttpGet,game,u) return s and r and not r:find("404") and r end
local function rV() if isfile(VF) then return G:JSONDecode(readfile(VF)) end writefile(VF,"{}") return {} end
local function sV(d) writefile(VF,G:JSONEncode(d)) end

local ln={}
local function cV()
    local id=tostring(game.PlaceId)
    local ld=rV()
    local rd=g(RV) and G:JSONDecode(g(RV))
    if not rd or not rd[id] then ld[id]=nil sV(ld) return true,false end
    local i=rd[id] ld[id]=i sV(ld)
    if i.Bannable then 
        if ln[id]~="b" then 
            n("⚠ SmokerV4 is patched! RISK BANNABLE for this game. Please wait until our staff team fixes the code.") 
            ln[id]="b" 
        end 
        return false,true 
    end

    if tonumber(game.PlaceVersion or 0)>tonumber(i.Version) then
        if ln[id]~="o" then 
            n("SmokerV4 may be outdated! Some features could break — use at your own risk or wait until the staff team fully unpatches.") 
            n("Current Version: "..tostring(game.PlaceVersion).." | Outdated Version: "..tostring(i.Version))
            ln[id]="o" 
        end 
    else 
        ln[id]=i.Version 
    end

    return true,false
end

local a,b=cV() if b then return end
task.spawn(function() while true do task.wait(1) cV() end end)

local function blk() if isfolder(R.."/Chace") then n("Blacklisted") pl:Kick("Blacklisted") end end
blk() task.spawn(function() while true do task.wait(20) blk() end end)

local function run(u) local c=g(u) if c then pcall(loadstring(c)) return true end end
local function grab(p,lp)
    local d=g(A..p) if not d then return end
    for _,v in ipairs(G:JSONDecode(d)) do
        local pa=lp.."/"..v.name
        if v.type=="file" then
            if not isfile(pa) then
                local c=g(v.download_url)
                if c then local t=string.split(pa,"/") table.remove(t) local dir=table.concat(t,"/") if not isfolder(dir) then makefolder(dir) end writefile(pa,c) end
            end
        else f(pa) grab(p.."/"..v.name,pa) end
    end
end

for _,v in ipairs({"Games","Assets","Data","UILibrary"}) do grab(v,R.."/"..v) end
if not run(B.."games/"..game.PlaceId..".lua") then run(B.."games/Universal.lua") end
run(B.."UILibrary/Whitelist.lua")

local function dl(u,p) local c=g(u) if c and not isfile(p) then writefile(p,c) end end
dl(B.."loader.lua",R.."/loader.lua") dl(B.."loadstring",R.."/loadstring")
