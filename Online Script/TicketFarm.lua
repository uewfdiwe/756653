local TicketFarm = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PICKUP_RADIUS = 6
local TICKET_OFFSET = Vector3.new(0, 2, 0)
local RESPAWN_COOLDOWN = 1.0
local NEXTBOT_CHECK_RADIUS = 100
local NEXTBOT_TELEPORT_COOLDOWN = 0

local running = false
local connection = nil
local targetTicket = nil
local state = "waiting"
local lastRespawn = 0
local lastNextbotTeleport = 0

local function getNextbotFolders()
    local folders = {}
    
    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        table.insert(folders, playersFolder)
    end
    
    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        table.insert(folders, npcsFolder)
    end
    
    local gameFolder = workspace:FindFirstChild("Game")
    if gameFolder then
        local gamePlayers = gameFolder:FindFirstChild("Players")
        if gamePlayers then
            table.insert(folders, gamePlayers)
        end
    end
    
    return folders
end

local function isNextbot(model)
    if not model or not model:IsA("Model") then return false end
    
    local team = model:GetAttribute("Team")
    if team == "Nextbot" then return true end
    
    local ai = model:GetAttribute("AI")
    if ai == true then return true end
    
    return false
end

local function getNearestNextbot(maxDist)
    maxDist = maxDist or NEXTBOT_CHECK_RADIUS
    
    local myChar = LocalPlayer.Character
    local myHRP = nil
    
    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        local model = playersFolder:FindFirstChild(LocalPlayer.Name)
        if model then
            myHRP = model:FindFirstChild("HumanoidRootPart")
        end
    end
    if not myHRP and myChar then
        myHRP = myChar:FindFirstChild("HumanoidRootPart")
    end
    if not myHRP then return nil end
    
    local folders = getNextbotFolders()
    local nearest, nearestDist = nil, maxDist
    
    for _, folder in ipairs(folders) do
        for _, model in ipairs(folder:GetChildren()) do
            if model:IsA("Model") and model.Name ~= LocalPlayer.Name then
                if isNextbot(model) then
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (myHRP.Position - hrp.Position).Magnitude
                        if dist < nearestDist then
                            nearest = model
                            nearestDist = dist
                        end
                    end
                end
            end
        end
    end
    
    return nearest, nearestDist
end

local function getRandomSpawn()
    local map = workspace:FindFirstChild("Map")
    if not map then return nil end
    
    local parts = map:FindFirstChild("Parts")
    if not parts then return nil end
    
    local spawns = parts:FindFirstChild("Spawns")
    if not spawns then return nil end
    
    local spawnParts = {}
    for _, obj in ipairs(spawns:GetChildren()) do
        if obj:IsA("BasePart") then
            table.insert(spawnParts, obj)
        elseif obj:IsA("Model") then
            local part = obj.PrimaryPart
                or obj:FindFirstChild("HumanoidRootPart")
                or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                table.insert(spawnParts, part)
            end
        end
    end
    
    if #spawnParts == 0 then return nil end
    return spawnParts[math.random(1, #spawnParts)]
end

local function getTicketsFolder()
    local effects = workspace:FindFirstChild("Effects")
    if not effects then return nil end
    return effects:FindFirstChild("Tickets")
end

local function getLocalHRP()
    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        local model = playersFolder:FindFirstChild(LocalPlayer.Name)
        if model then
            return model:FindFirstChild("HumanoidRootPart")
        end
    end
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function resolveTicketPart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    return inst:FindFirstChild("HumanoidRootPart")
        or inst.PrimaryPart
        or inst:FindFirstChildWhichIsA("BasePart")
end

local function holdAt(pos)
    local hrp = getLocalHRP()
    if not hrp or not hrp.Parent then return end
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)
end

local function findNearestTicket()
    local folder = getTicketsFolder()
    if not folder then return nil end

    local hrp = getLocalHRP()
    local myPos = hrp and hrp.Position or Vector3.new(0, 0, 0)

    local best, bestDist = nil, math.huge
    for _, inst in ipairs(folder:GetChildren()) do
        local part = resolveTicketPart(inst)
        if part then
            local d = (part.Position - myPos).Magnitude
            if d < bestDist then
                best, bestDist = inst, d
            end
        end
    end
    return best
end

local function isDowned()
    local ok, downedState = pcall(function()
        local cs = require(game:GetService("ReplicatedStorage").Services.Asset.CharacterService)
        local char = cs:GetLocalCharacter()
        if char and char.State then
            return char.State.State
        end
        return nil
    end)
    return ok and downedState == "Downed"
end

local function tryRespawn()
    local now = tick()
    if now - lastRespawn < RESPAWN_COOLDOWN then return end
    lastRespawn = now

    if getgenv().doRevive then
        pcall(getgenv().doRevive)
    end
end

local function teleportToRandomSpawn()
    local now = tick()
    if now - lastNextbotTeleport < NEXTBOT_TELEPORT_COOLDOWN then return false end
    lastNextbotTeleport = now
    
    local spawn = getRandomSpawn()
    if not spawn then return false end
    
    local hrp = getLocalHRP()
    if not hrp then return false end
    
    holdAt(spawn.Position + Vector3.new(0, 5, 0))
    return true
end

local function tickFarm()
    if not running then return end

    if isDowned() then
        tryRespawn()
        return
    end

    local nearestBot, botDist = getNearestNextbot(NEXTBOT_CHECK_RADIUS)
    if nearestBot then
        teleportToRandomSpawn()
        return
    end

    local folder = getTicketsFolder()

    if targetTicket and (not targetTicket.Parent or not folder or targetTicket.Parent ~= folder) then
        targetTicket = nil
        state = "waiting"
    end

    if not targetTicket then
        local ticket = findNearestTicket()
        if ticket then
            targetTicket = ticket
            state = "moving"
        end
    end

    if targetTicket then
        local part = resolveTicketPart(targetTicket)
        if part then
            local hrp = getLocalHRP()
            if hrp then
                local dist = (hrp.Position - part.Position).Magnitude
                if dist <= PICKUP_RADIUS then
                    state = "picking"
                    holdAt(hrp.Position)
                    return
                end
            end
            holdAt(part.Position + TICKET_OFFSET)
            state = "moving"
            return
        else
            targetTicket = nil
            state = "waiting"
        end
    end

    state = "waiting"
end

function TicketFarm.start()
    if running then return end
    running = true
    targetTicket = nil
    state = "waiting"
    lastRespawn = 0
    lastNextbotTeleport = 0

    connection = RunService.Heartbeat:Connect(function()
        tickFarm()
    end)
end

function TicketFarm.stop()
    if not running then return end
    running = false

    if connection then
        connection:Disconnect()
        connection = nil
    end

    targetTicket = nil
    state = "idle"

    local hrp = getLocalHRP()
    if hrp then
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
    end
end

return TicketFarm
