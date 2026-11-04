local BarriersVisible = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local watching = false
local descendantConnection = nil

local function getInvisParts()
    return workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("InvisParts")
end

local function bindDescendantAdded(invisParts)
    if descendantConnection then
        descendantConnection:Disconnect()
        descendantConnection = nil
    end

    if not enabled or not invisParts then
        return
    end

    descendantConnection = invisParts.DescendantAdded:Connect(function(obj)
        if not enabled then
            return
        end
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            task.wait(0.05)
            if enabled then
                obj.Transparency = 0
            end
        end
    end)
end

function BarriersVisible.set(state, silent)
    enabled = state and true or false

    local invisParts = getInvisParts()
    if not invisParts then
        return false, "InvisParts folder not found!"
    end

    local changed = 0
    local transparency = enabled and 0 or 1

    for _, obj in ipairs(invisParts:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            obj.Transparency = transparency
            changed = changed + 1
        end
    end

    if enabled then
        bindDescendantAdded(invisParts)
    elseif descendantConnection then
        descendantConnection:Disconnect()
        descendantConnection = nil
    end

    if silent then
        return true
    end

    if enabled then
        return true, string.format("Set Transparency = 0 for %d objects", changed)
    end
    return true, string.format("Set Transparency = 1 for %d objects", changed)
end

function BarriersVisible.init()
    if watching then
        return
    end
    watching = true

    LocalPlayer.CharacterAdded:Connect(function()
        if enabled then
            task.wait(1)
            BarriersVisible.set(true, true)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer and enabled then
            BarriersVisible.set(false, true)
        end
    end)
end

return BarriersVisible
