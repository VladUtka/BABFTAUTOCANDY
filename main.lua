local t0 = tick()
local p = game.Players.LocalPlayer
local ts = game:GetService("TeleportService")
local uis = game:GetService("UserInputService")
local h = game:GetService("HttpService")
local tws = game:GetService("TweenService")

pcall(function() game:GetService("StarterGui"):SetCore("DevConsoleVisible", true) end)

local function gp(txt)
    print(txt)
end

local pingStr = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
local ping = pingStr:match("%d+%.?%d*") or "0"
local lt = string.format("%.3f", tick() - t0)

gp("Loaded in " .. lt .. " Sec | Ping - " .. ping)
task.wait(1)

local visited = {}

local function getC()
    local t = {}
    local hs = workspace:FindFirstChild("Houses")
    if hs then
        for _, v in ipairs(hs:GetChildren()) do
            if v.Name == "TrickOrTreatHouse" and v:FindFirstChild("Carpet") then
                if not visited[v.Carpet] then
                    table.insert(t, v.Carpet)
                end
            end
        end
    end
    return t
end

local function hop()
    local req = request or http_request or (syn and syn.request)
    if req then
        local res = req({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"})
        if res and res.Body then
            local d = h:JSONDecode(res.Body).data
            local s = {}
            for _, v in ipairs(d) do
                if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(s, v.id)
                end
            end
            if #s > 0 then
                local q = queue_on_teleport or syn.queue_on_teleport
                if q then 
                    q('loadstring(game:HttpGet("ССЫЛКА_НА_ЭТОТ_СКРИПТ"))()') 
                end
                ts:TeleportToPlaceInstance(game.PlaceId, s[math.random(1, #s)], p)
            end
        end
    end
end

local c = getC()
if #c == 0 then
    gp("All models is collected, rejoining in - 15sec")
    task.wait(15)
    hop()
    return
end

gp("Fetching Models in Workspace - " .. tostring(#c))

local run = true
local col = 0

uis.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightAlt then
        run = false
    end
end)

while run do
    c = getC()
    if #c == 0 then
        gp("All models is collected, rejoining in - 15sec")
        task.wait(15)
        hop()
        break
    end
    
    for _, v in ipairs(c) do
        if not run then break end
        if v and v.Parent and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local targetCF = v:GetPivot()
            
            local tw = tws:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = targetCF})
            tw:Play()
            tw.Completed:Wait()
            
            visited[v] = true
            col = col + 1
            gp("Starting Collecting - " .. tostring(col))
            task.wait(2)
        end
    end
    task.wait(0.1)
end
