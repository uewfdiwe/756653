local AvatarModule = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local playerList = {}
local originalAvatar = {}
local currentMode = "Direct"

function AvatarModule.Scan()
    playerList = {}
    local cache = workspace:FindFirstChild("PlayerCache")
    if not cache then return playerList end

    for _, model in ipairs(cache:GetChildren()) do
        if model.Name ~= LocalPlayer.Name then
            if model:FindFirstChild("Player") or model:FindFirstChild("R6") then
                table.insert(playerList, model.Name)
            end
        end
    end
    table.sort(playerList)
    return playerList
end

function AvatarModule.Apply(targetName)
    if not targetName or targetName == "" then return false, "No target selected" end

    local cache = workspace:FindFirstChild("PlayerCache")
    if not cache then return false, "PlayerCache not found" end

    local targetModel = cache:FindFirstChild(targetName)
    local myCache = cache:FindFirstChild(LocalPlayer.Name)

    if not targetModel then return false, "Target player left the server." end
    if not myCache then return false, "Your PlayerCache not found" end

    local targetPlayer = targetModel:FindFirstChild("Player")
    local targetR6 = targetModel:FindFirstChild("R6")

    if not targetPlayer and not targetR6 then return false, "Target has no Player or R6" end

    local myPlayer = myCache:FindFirstChild("Player")
    local myR6 = myCache:FindFirstChild("R6")

    if not originalAvatar.Player and myPlayer then originalAvatar.Player = myPlayer:Clone() end
    if not originalAvatar.R6 and myR6 then originalAvatar.R6 = myR6:Clone() end

    if myPlayer then myPlayer:Destroy() end
    if myR6 then myR6:Destroy() end

    local replaced = 0
    if targetPlayer then
        local ok, clone = pcall(function() return targetPlayer:Clone() end)
        if ok and clone then
            clone.Name = "Player"
            clone.Parent = myCache
            replaced = replaced + 1
        end
    end
    
    if targetR6 then
        local ok, clone = pcall(function() return targetR6:Clone() end)
        if ok and clone then
            clone.Name = "R6"
            clone.Parent = myCache
            replaced = replaced + 1
        end
    end

    return true, string.format("Applied %d models from %s", replaced, targetName)
end

function AvatarModule.Restore()
    local cache = workspace:FindFirstChild("PlayerCache")
    local myCache = cache and cache:FindFirstChild(LocalPlayer.Name)
    if not myCache then return false, "Your PlayerCache not found" end

    if not originalAvatar.Player and not originalAvatar.R6 then 
        return false, "No original saved" 
    end

    local myPlayer = myCache:FindFirstChild("Player")
    local myR6 = myCache:FindFirstChild("R6")
    if myPlayer then myPlayer:Destroy() end
    if myR6 then myR6:Destroy() end

    local restored = 0
    if originalAvatar.Player then
        local c = originalAvatar.Player:Clone()
        c.Name = "Player"
        c.Parent = myCache
        restored = restored + 1
    end
    if originalAvatar.R6 then
        local c = originalAvatar.R6:Clone()
        c.Name = "R6"
        c.Parent = myCache
        restored = restored + 1
    end

    return true, string.format("Restored %d models", restored)
end

function AvatarModule.ResetOriginal()
    originalAvatar = {}
end

return AvatarModule
