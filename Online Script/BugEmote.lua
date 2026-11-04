local BugEmote = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local sitLoopConnection = nil
local watching = false

local function getHumanoid()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            return humanoid
        end
    end

    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if gamePlayers then
        local playerModel = gamePlayers:FindFirstChild(LocalPlayer.Name)
        if playerModel then
            return playerModel:FindFirstChild("Humanoid")
        end
    end

    return nil
end

local function updateSit()
    if not enabled then return end
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.Sit = true
    end
end

function BugEmote.set(state)
    enabled = state and true or false

    if enabled then
        if sitLoopConnection then
            sitLoopConnection:Disconnect()
        end

        sitLoopConnection = RunService.Heartbeat:Connect(updateSit)
        updateSit()
    else
        if sitLoopConnection then
            sitLoopConnection:Disconnect()
            sitLoopConnection = nil
        end

        local humanoid = getHumanoid()
        if humanoid then
            humanoid.Sit = false
        end
    end
end

function BugEmote.init()
    if watching then
        return
    end
    watching = true

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if enabled then
            updateSit()
        end
    end)

    LocalPlayer.CharacterRemoving:Connect(function()
        if sitLoopConnection then
            sitLoopConnection:Disconnect()
            sitLoopConnection = nil
        end
    end)
end

return BugEmote
