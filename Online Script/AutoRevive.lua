local module = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local CharacterService = require(ReplicatedStorage.Services.Asset.CharacterService)

local CONFIG = {
    Range = 10,
    LoopDelay = 0.15,
    ReviveCooldown = 1.5,
    IgnoreCarry = false,
}

local carryStates = {
    CarryMove = true,
    CarryIdle = true,
    CarryCrouchMove = true,
    CarrySlide = true,
    CarryCrouchIdle = true,
    CarryAir = true,
    CarrySlideAir = true,
}

local enabled = false
local handle = nil
local currentlyReviving = {}

local function getInteractEvent()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    local charFolder = remotes:FindFirstChild("Character")
    if not charFolder then return nil end
    return charFolder:FindFirstChild("Interact")
end

local interactEvent = getInteractEvent()

local function getLocalState()
    local char = CharacterService:GetLocalCharacter()
    if char and char.State then
        return char.State.State
    end
    return nil
end

local function isInCarryState()
    local s = getLocalState()
    if not s then return false end
    return carryStates[s] == true
end

local function shouldBlockRevive()
    return CONFIG.IgnoreCarry and isInCarryState()
end

local function reviveLoop()
    while enabled do
        if shouldBlockRevive() then
            task.wait(CONFIG.LoopDelay)
            continue
        end

        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if myHRP then
            local playersFolder = Workspace:FindFirstChild("Players")
            if playersFolder then
                for _, otherChar in ipairs(playersFolder:GetChildren()) do
                    if otherChar.Name ~= LocalPlayer.Name and otherChar:IsA("Model") then
                        local otherTag = otherChar:GetAttribute("Tag")
                        local otherHrp = otherChar:FindFirstChild("HumanoidRootPart")

                        if otherTag and otherHrp and not currentlyReviving[otherTag] then
                            local dist = (myHRP.Position - otherHrp.Position).Magnitude

                            if dist <= CONFIG.Range then
                                local charData = CharacterService:GetCharacterFromTag(otherTag)

                                if charData and charData.State and charData.State.State == "Downed" then
                                    currentlyReviving[otherTag] = true

                                    task.spawn(function()
                                        -- 1. Первый FireServer (true)
                                        if not shouldBlockRevive() and interactEvent then
                                            pcall(function()
                                                interactEvent:FireServer("Revive", otherTag, true)
                                            end)
                                        else
                                            currentlyReviving[otherTag] = nil
                                            return
                                        end

                                        -- Ждём
                                        task.wait(CONFIG.ReviveCooldown)

                                        -- 2. Второй FireServer — только если не в Carry
                                        if not shouldBlockRevive() and interactEvent then
                                            pcall(function()
                                                interactEvent:FireServer("Revive", otherTag)
                                            end)
                                        end

                                        task.wait(1)
                                        currentlyReviving[otherTag] = nil
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end

        task.wait(CONFIG.LoopDelay)
    end
end

function module.Start()
    if enabled then return end
    enabled = true
    handle = task.spawn(reviveLoop)
end

function module.Stop()
    enabled = false
    if handle then
        task.cancel(handle)
        handle = nil
    end
    currentlyReviving = {}
end

function module.SetDelay(delay)
    CONFIG.LoopDelay = tonumber(delay) or 0.15
end

function module.SetRange(range)
    CONFIG.Range = tonumber(range) or 10
end

function module.SetCooldown(cooldown)
    CONFIG.ReviveCooldown = tonumber(cooldown) or 1.5
end

function module.SetIgnoreCarry(value)
    CONFIG.IgnoreCarry = value and true or false
end

return module
