local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CharacterService = require(ReplicatedStorage.Services.Asset.CharacterService)

local CONFIG = {
    Range = 10,
    LoopDelay = 0.1,
    ReviveDelay = 1.5,
    ReviveCooldown = 0.5,
    UndergroundOffset = 4,
    PlatformOffset = 3,
}

local enabled = false
local handle = nil
local holdConnection = nil
local currentlyReviving = {}
local holdEnabled = false
local teleportingToTarget = false
local teleportLockUntil = 0

local function getInteractEvent()
    local events = ReplicatedStorage:FindFirstChild("Events")
    if events then
        local interact = events:FindFirstChild("Interact")
        if interact then return interact end
    end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local charFolder = remotes:FindFirstChild("Character")
        if charFolder then
            return charFolder:FindFirstChild("Interact")
        end
    end
    return nil
end

local function getSetPlayerModeRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local session = remotes:FindFirstChild("Session")
        if session then
            return session:FindFirstChild("SetPlayerMode")
        end
    end
    local events = ReplicatedStorage:FindFirstChild("Events")
    if events then
        local player = events:FindFirstChild("Player")
        if player then
            return player:FindFirstChild("ChangePlayerMode")
        end
        return events:FindFirstChild("SetPlayerMode")
    end
    return nil
end

local function getLocalChar()
    local ok, char = pcall(function()
        return CharacterService:GetLocalCharacter()
    end)
    if ok then return char end
    return nil
end

local function getLocalHRP()
    local playersFolder = Workspace:FindFirstChild("Players")
    if playersFolder then
        local model = playersFolder:FindFirstChild(LocalPlayer.Name)
        if model then
            return model:FindFirstChild("HumanoidRootPart")
        end
    end
    return nil
end

local function getSecurityPart()
    return Workspace:FindFirstChild("SecurityPart")
end

local function getLocalState()
    local char = getLocalChar()
    if char and char.State then
        return char.State.State
    end
    return nil
end

local function isDowned(charModel)
    if not charModel then return false end
    if charModel:GetAttribute("Downed") == true then return true end
    local tag = charModel:GetAttribute("Tag")
    if tag then
        local char = CharacterService:GetCharacterFromTag(tag)
        if char and char.State and char.State.State == "Downed" then
            return true
        end
    end
    return false
end

local function teleportTo(pos)
    local hrp = getLocalHRP()
    if not hrp then return end
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.Velocity = Vector3.new(0, 0, 0)
    end)
end

local function getPlatformPosition()
    local secPart = getSecurityPart()
    if not secPart then return nil end
    return secPart.Position + Vector3.new(0, CONFIG.PlatformOffset, 0)
end

-- Удержание на платформе — каждые 0.1 сек, но НЕ перебивает телепорт
local function startHold()
    if holdConnection then return end
    holdEnabled = true

    holdConnection = task.spawn(function()
        while enabled and holdEnabled do
            -- Блокируем hold, пока идёт телепорт
            if not teleportingToTarget and tick() > teleportLockUntil then
                local platformPos = getPlatformPosition()
                if platformPos then
                    teleportTo(platformPos)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function stopHold()
    holdEnabled = false
    if holdConnection then
        task.cancel(holdConnection)
        holdConnection = nil
    end
end

local function findNearestDowned()
    local myHrp = getLocalHRP()
    if not myHrp then return nil end

    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return nil end

    local nearest = nil
    local nearestDist = math.huge

    for _, otherChar in ipairs(playersFolder:GetChildren()) do
        if otherChar.Name ~= LocalPlayer.Name and otherChar:IsA("Model") then
            local tag = otherChar:GetAttribute("Tag")
            local otherHrp = otherChar:FindFirstChild("HumanoidRootPart")

            if tag and otherHrp and isDowned(otherChar) then
                local dist = (myHrp.Position - otherHrp.Position).Magnitude
                if dist < nearestDist then
                    nearest = {
                        tag = tag,
                        pos = otherHrp.Position,
                        model = otherChar,
                    }
                    nearestDist = dist
                end
            end
        end
    end

    return nearest
end

local function sendRevive(tag, interactEvent)
    if not interactEvent then return end
    pcall(function()
        interactEvent:FireServer("Revive", tag, true)
    end)
    task.wait(CONFIG.ReviveDelay)
    pcall(function()
        interactEvent:FireServer("Revive", tag)
    end)
end

local function updateLoop()
    if not enabled then return end

    local interactEvent = getInteractEvent()
    local remote = getSetPlayerModeRemote()

    if getLocalState() == "Downed" then
        if remote then
            pcall(function() remote:FireServer(true) end)
        end
        task.wait(0.5)
        return
    end

    local target = findNearestDowned()

    if target then
        -- Блокируем hold на 2 секунды (пока телепорт + ревайв)
        teleportingToTarget = true
        teleportLockUntil = tick() + 2.0

        local undergroundPos = target.pos - Vector3.new(0, CONFIG.UndergroundOffset, 0)
        teleportTo(undergroundPos)

        if not currentlyReviving[target.tag] then
            currentlyReviving[target.tag] = true
            task.spawn(function()
                sendRevive(target.tag, interactEvent)
                task.wait(CONFIG.ReviveCooldown)
                currentlyReviving[target.tag] = nil
            end)
        end

        -- Ждём, пока hold разблокируется
        task.wait(0.5)

        teleportingToTarget = false
    end
end

function module.Start()
    if enabled then return end
    enabled = true
    currentlyReviving = {}
    teleportingToTarget = false
    teleportLockUntil = 0

    startHold()

    handle = task.spawn(function()
        while enabled do
            pcall(updateLoop)
            task.wait(CONFIG.LoopDelay)
        end
    end)
end

function module.Stop()
    enabled = false
    if handle then
        task.cancel(handle)
        handle = nil
    end
    stopHold()
    currentlyReviving = {}
    teleportingToTarget = false
end

function module.SetRange(range)
    CONFIG.Range = tonumber(range) or 10
end

function module.SetDelay(delay)
    CONFIG.LoopDelay = tonumber(delay) or 0.1
end

function module.SetCooldown(cooldown)
    CONFIG.ReviveCooldown = tonumber(cooldown) or 0.5
end

function module.SetUndergroundOffset(offset)
    CONFIG.UndergroundOffset = tonumber(offset) or 4
end

return module
