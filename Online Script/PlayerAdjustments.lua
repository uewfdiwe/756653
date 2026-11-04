local PlayerAdjustments = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local currentSettings = {
    Speed = 1500,
    JumpPower = 3,
    JumpCap = 1,
    AirStrafeAcceleration = 182
}

local BaseStats = nil
local started = false

local function findBaseStats()
    pcall(function()
        BaseStats = require(ReplicatedStorage.Objects.Game.Character.Client.Movement.MoveStats.BaseStats)
    end)

    if not BaseStats then
        for _, obj in ipairs(getgc(true)) do
            if type(obj) == "table" and rawget(obj, "Speed") ~= nil and rawget(obj, "JumpCap") ~= nil then
                BaseStats = obj
                break
            end
        end
    end
end

function PlayerAdjustments.apply()
    if BaseStats then
        BaseStats.Speed = currentSettings.Speed
        BaseStats.JumpHeight = currentSettings.JumpPower
        BaseStats.JumpCap = currentSettings.JumpCap
        BaseStats.AirStrafeAcceleration = currentSettings.AirStrafeAcceleration
    end
end

function PlayerAdjustments.setSpeed(value)
    currentSettings.Speed = value
    PlayerAdjustments.apply()
end

function PlayerAdjustments.setJumpPower(value)
    currentSettings.JumpPower = value
    PlayerAdjustments.apply()
end

function PlayerAdjustments.setJumpCap(value)
    currentSettings.JumpCap = value
    PlayerAdjustments.apply()
end

function PlayerAdjustments.setAirStrafe(value)
    currentSettings.AirStrafeAcceleration = value
    PlayerAdjustments.apply()
end

function PlayerAdjustments.start()
    if started then
        return
    end
    started = true

    findBaseStats()

    spawn(function()
        while task.wait(0.05) do
            PlayerAdjustments.apply()
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.3)
        PlayerAdjustments.apply()
    end)

    task.wait(0.3)
    PlayerAdjustments.apply()
end

return PlayerAdjustments