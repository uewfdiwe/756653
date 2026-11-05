local module = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local CharacterService = require(ReplicatedStorage.Services.Asset.CharacterService)

local settings = {
    Power = 70,
    Cooldown = 0.2,
    MinAngle = 30,
    MaxAngle = 75,
    MinSpeed = 70
}

local ALLOWED_STATES = {
    CarryAir = true,
    Air = true,
    EmotingAir = true
}

local cooldown = 0
local heartbeatConnection = nil
local isEnabled = false

local function isStateAllowed()
    local char = CharacterService:GetLocalCharacter()
    if char and char.State and char.State.State then
        return ALLOWED_STATES[char.State.State] == true
    end
    return false
end

local function getTrampolineFolder()
    return workspace:FindFirstChild("Map") 
        and workspace.Map:FindFirstChild("Parts") 
        and workspace.Map.Parts:FindFirstChild("Map")
end

local function onHeartbeat(dt)
    if not isEnabled then return end

    cooldown = cooldown - dt
    if cooldown > 0 then return end

    local char = LP.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not isStateAllowed() then
        return
    end

    local currentSpeed = hrp.AssemblyLinearVelocity.Magnitude
    if currentSpeed < settings.MinSpeed then
        return
    end

    local rayOrigin = hrp.Position
    local rayDirection = Vector3.new(0, -6, 0)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Include
    local folder = getTrampolineFolder()

    if folder then
        raycastParams.FilterDescendantsInstances = {folder}
    else
        raycastParams.FilterDescendantsInstances = {workspace.Map}
    end

    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if result and result.Instance then
        local normal = result.Normal
        local upVector = Vector3.new(0, 1, 0)
        local angle = math.deg(math.acos(normal:Dot(upVector)))

        if angle >= settings.MinAngle and angle <= settings.MaxAngle then
            cooldown = settings.Cooldown

            local dir = hrp.AssemblyLinearVelocity.Unit
            local boostVector = (dir + Vector3.new(0, 1, 0)).Unit * settings.Power

            hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + boostVector
        end
    end
end

function module:Start()
    if isEnabled then return end
    isEnabled = true
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
    end
    heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
end

function module:Stop()
    if not isEnabled then return end
    isEnabled = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
end

function module:SetPower(v)
    settings.Power = v
end

function module:SetCooldown(v)
    settings.Cooldown = v
end

function module:SetMinAngle(v)
    settings.MinAngle = v
end

function module:SetMaxAngle(v)
    settings.MaxAngle = v
end

function module:SetMinSpeed(v)
    settings.MinSpeed = v
end

return module
