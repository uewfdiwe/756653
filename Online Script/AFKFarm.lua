local AFKFarm = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AFKFarmConnection = nil
local AFKFarmHolding = false

local function getSecurityPart()
    return workspace:FindFirstChild("SecurityPart")
end

local function getLocalHRP()
    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        local model = playersFolder:FindFirstChild(LocalPlayer.Name)
        if model then
            return model:FindFirstChild("HumanoidRootPart")
        end
    end
    return nil
end

function AFKFarm.start()
    if AFKFarmConnection then
        AFKFarmConnection:Disconnect()
        AFKFarmConnection = nil
    end

    AFKFarmHolding = true

    AFKFarmConnection = RunService.Heartbeat:Connect(function()
        if not AFKFarmHolding then return end

        local securityPart = getSecurityPart()
        if not securityPart then return end

        local hrp = getLocalHRP()
        if hrp then
            pcall(function()
                hrp.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
        end
    end)
end

function AFKFarm.stop()
    AFKFarmHolding = false

    if AFKFarmConnection then
        AFKFarmConnection:Disconnect()
        AFKFarmConnection = nil
    end
end

return AFKFarm
