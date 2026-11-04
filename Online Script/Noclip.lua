local Noclip = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local noclipEnabled = false
local noclipConnection = nil
local watching = false

local function applyNoclip(state)
    noclipEnabled = state and true or false

    if noclipEnabled then
        if noclipConnection then
            noclipConnection:Disconnect()
        end

        noclipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

function Noclip.set(state)
    applyNoclip(state)
end

function Noclip.init()
    if watching then
        return
    end
    watching = true

    LocalPlayer.CharacterAdded:Connect(function()
        if noclipEnabled then
            task.wait(0.5)
            applyNoclip(false)
            task.wait(0.1)
            applyNoclip(true)
        end
    end)

    LocalPlayer.CharacterRemoving:Connect(function()
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end)
end

return Noclip
