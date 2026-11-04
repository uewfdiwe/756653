local Teleports = {}

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local CUSTOM_PLACE_ID = 99214917572799

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

function Teleports.toRandomSpawn()
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then
        return false, "Map folder not found"
    end

    local partsFolder = mapFolder:FindFirstChild("Parts")
    if not partsFolder then
        return false, "Map.Parts not found"
    end

    local spawnsFolder = partsFolder:FindFirstChild("Spawns")
    if not spawnsFolder then
        return false, "Spawns folder not found"
    end

    local spawns = {}
    for _, obj in ipairs(spawnsFolder:GetChildren()) do
        if obj:IsA("BasePart") then
            table.insert(spawns, obj)
        elseif obj:IsA("Model") then
            local part = obj.PrimaryPart
                or obj:FindFirstChild("HumanoidRootPart")
                or obj:FindFirstChild("Head")
                or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                table.insert(spawns, part)
            end
        end
    end

    if #spawns == 0 then
        return false, "No spawns found"
    end

    local chosen = spawns[math.random(1, #spawns)]
    local hrp = getLocalHRP()
    if not hrp then
        return false, "HumanoidRootPart not found"
    end

    pcall(function()
        hrp.CFrame = CFrame.new(chosen.Position + Vector3.new(0, 3, 0))
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.Velocity = Vector3.new(0, 0, 0)
    end)

    return true, "Teleported to spawn"
end

function Teleports.joinCustomMap()
    pcall(function()
        TeleportService:Teleport(CUSTOM_PLACE_ID, LocalPlayer)
    end)
    return true, "Joining custom map..."
end

return Teleports
