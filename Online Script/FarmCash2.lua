local module = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CharacterService = require(ReplicatedStorage.Services.Asset.CharacterService)

local CONFIG = {
    UnderOffset = Vector3.new(0, -4, 0), 
    ReviveDelay = 2,
    LoopDelay = 0.1
}

local enabled = false
local handle = nil
local currentlyReviving = {}
local activeTarget = nil

local function getInteractEvent()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local charFolder = remotes:FindFirstChild("Character")
        if charFolder then return charFolder:FindFirstChild("Interact") end
    end
    return nil
end

local interactEvent = getInteractEvent()

local function getHRP()
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    local myModel = playersFolder:FindFirstChild(LocalPlayer.Name)
    return myModel and myModel:FindFirstChild("HumanoidRootPart")
end

local function getMyState()
    local char = CharacterService:GetLocalCharacter()
    if char and char.State then
        return char.State.State
    end
    return nil
end

local function getCharacterByTag(tag)
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    for _, child in ipairs(playersFolder:GetChildren()) do
        if child:IsA("Model") and child:GetAttribute("Tag") == tag then
            return child
        end
    end
    return nil
end

local function findDownedPlayer()
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return nil end

    for _, otherChar in ipairs(playersFolder:GetChildren()) do
        if otherChar.Name ~= LocalPlayer.Name and otherChar:IsA("Model") then
            local otherTag = otherChar:GetAttribute("Tag")
            local otherHRP = otherChar:FindFirstChild("HumanoidRootPart")
            
            if otherTag and otherHRP and not currentlyReviving[otherTag] then
                local charData = CharacterService:GetCharacterFromTag(otherTag)
                
                if charData and charData.State and charData.State.State == "Downed" then
                    return otherHRP.Position, otherTag
                end
            end
        end
    end
    return nil
end

local function getPlatformPos()
    local secPart = Workspace:FindFirstChild("SecurityPart")
    if secPart then
        return secPart.Position + Vector3.new(0, 3, 0)
    end
    return Vector3.new(5000, 5000, 5000)
end

local function teleportTo(pos, freeze)
    local hrp = getHRP()
    if not hrp then return end
    
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
        if freeze then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function farmLoop()
    while enabled do
        local myState = getMyState()
        
        -- 1. Если Я упал
        if myState == "Downed" then
            getgenv().FarmCashBusy = true 
            local myTag = nil
            pcall(function()
                local myChar = CharacterService:GetLocalCharacter()
                if myChar and myChar.Model then
                    myTag = myChar.Model:GetAttribute("Tag")
                end
            end)
            
            if myTag and not currentlyReviving[myTag] then
                currentlyReviving[myTag] = true
                task.spawn(function()
                    if interactEvent then
                        pcall(function() interactEvent:FireServer("Revive", myTag, true) end)
                        task.wait(CONFIG.ReviveDelay)
                        pcall(function() interactEvent:FireServer("Revive", myTag) end)
                    end
                    task.wait(1)
                    currentlyReviving[myTag] = nil
                    getgenv().FarmCashBusy = false
                end)
            end
            task.wait(CONFIG.LoopDelay)
            continue
        end

        -- 2. Если есть цель (упавший игрок)
        if activeTarget then
            getgenv().FarmCashBusy = true 
            local targetTag = activeTarget.tag
            local targetChar = getCharacterByTag(targetTag)
            
            local isStillDowned = false
            if targetChar then
                local charData = CharacterService:GetCharacterFromTag(targetTag)
                if charData and charData.State and charData.State.State == "Downed" then
                    isStillDowned = true
                end
            end
            
            if isStillDowned then
                local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    teleportTo(targetHRP.Position + CONFIG.UnderOffset, true)
                end
            else
                activeTarget = nil
                getgenv().FarmCashBusy = false
                teleportTo(getPlatformPos(), true)
            end
        else
            -- 3. Ищем упавших других игроков
            local targetPos, targetTag = findDownedPlayer()
            
            if targetPos and targetTag then
                getgenv().FarmCashBusy = true 
                activeTarget = { tag = targetTag }
                currentlyReviving[targetTag] = true
                
                teleportTo(targetPos + CONFIG.UnderOffset, true)
                
                task.spawn(function()
                    task.wait(0.1)
                    
                    if interactEvent then
                        -- СНАЧАЛА TRUE
                        pcall(function() interactEvent:FireServer("Revive", targetTag, true) end)
                        
                        -- ЖДЕМ 2 СЕКУНДЫ
                        task.wait(CONFIG.ReviveDelay)
                        
                        -- ПОТОМ БЕЗ TRUE
                        pcall(function() interactEvent:FireServer("Revive", targetTag) end)
                    end
                    task.wait(3)
                    currentlyReviving[targetTag] = nil
                end)
            else
                getgenv().FarmCashBusy = false
                teleportTo(getPlatformPos(), true)
            end
        end

        task.wait(CONFIG.LoopDelay)
    end
end

function module.Start()
    if enabled then return end
    enabled = true
    getgenv().FarmCashBusy = false
    handle = task.spawn(farmLoop)
end

function module.Stop()
    enabled = false
    getgenv().FarmCashBusy = false
    if handle then
        task.cancel(handle)
        handle = nil
    end
    currentlyReviving = {}
    activeTarget = nil
end

return module
