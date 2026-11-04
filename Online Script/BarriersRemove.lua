local BarriersRemove = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local watching = false

local function getInvisParts()
    return workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("InvisParts")
end

function BarriersRemove.set(state, silent)
    enabled = state and true or false

    local invisParts = getInvisParts()
    if not invisParts then
        return false, "InvisParts folder not found!"
    end

    local objectsChanged = 0
    for _, obj in ipairs(invisParts:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = not enabled
            obj.CanQuery = not enabled
            objectsChanged = objectsChanged + 1
        end
    end

    if silent then
        return true
    end

    return true, string.format(
        "%s collision and query for %d objects",
        enabled and "Disabled" or "Enabled",
        objectsChanged
    )
end

function BarriersRemove.init()
    if watching then
        return
    end
    watching = true

    LocalPlayer.CharacterAdded:Connect(function()
        if enabled then
            task.wait(1)
            BarriersRemove.set(true, true)
        end
    end)
end

return BarriersRemove
