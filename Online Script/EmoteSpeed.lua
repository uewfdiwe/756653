local EmoteSpeed = {}

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CharacterService = nil
pcall(function()
    CharacterService = require(RS.Services.Asset.CharacterService)
end)

local emoteModules = {}
local originalSpeeds = {}
local featureStates = {}
local emoteConnection = nil

function EmoteSpeed.init(options)
    featureStates = options
    local function walk(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Folder") then
                if child.Name == "Emotes" then
                    for _, mod in ipairs(child:GetChildren()) do
                        if mod:IsA("ModuleScript") then
                            table.insert(emoteModules, mod)
                        end
                    end
                else
                    walk(child)
                end
            end
        end
    end
    local items = RS:FindFirstChild("Items")
    if items then walk(items) end

    for _, mod in ipairs(emoteModules) do
        local ok, data = pcall(require, mod)
        if ok and type(data) == "table" and data.EmoteInfo then
            originalSpeeds[mod] = data.EmoteInfo.SpeedMult
        end
    end
end

local function getLocalChar()
    if CharacterService then
        return CharacterService:GetLocalCharacter()
    end
    return nil
end

local function applyEmoteSpeed(speedValue)
    for _, mod in ipairs(emoteModules) do
        local ok, data = pcall(require, mod)
        if ok and type(data) == "table" and data.EmoteInfo then
            if originalSpeeds[mod] and originalSpeeds[mod] ~= 0 then
                pcall(function() data.EmoteInfo.SpeedMult = speedValue end)
            end
        end
    end
end

local function restoreEmoteSpeeds()
    for _, mod in ipairs(emoteModules) do
        local orig = originalSpeeds[mod]
        if orig then
            local ok, data = pcall(require, mod)
            if ok and type(data) == "table" and data.EmoteInfo then
                pcall(function() data.EmoteInfo.SpeedMult = orig end)
            end
        end
    end
end

local requiredFields = {
    Friction = true, AirStrafeAcceleration = true, JumpHeight = true,
    RunDeaccel = true, JumpSpeedMultiplier = true, JumpCap = true,
    SprintCap = true, WalkSpeedMultiplier = true, BhopEnabled = true,
    Speed = true, AirAcceleration = true, RunAccel = true, SprintAcceleration = true
}

local function getMovementTables()
    local matched = {}
    pcall(function()
        for _, obj in pairs(getgc(true)) do
            if typeof(obj) == "table" then
                local ok = true
                for field in pairs(requiredFields) do
                    if rawget(obj, field) == nil then ok = false; break end
                end
                if ok then table.insert(matched, obj) end
            end
        end
    end)
    return matched
end

local function applyMovementMultiplier(mult)
    for _, tbl in ipairs(getMovementTables()) do
        pcall(function() tbl.WalkSpeedMultiplier = mult end)
    end
end

local function setupEmoteStateListener()
    if emoteConnection then
        emoteConnection:Disconnect()
        emoteConnection = nil
    end
    
    local char = getLocalChar()
    if not char or not char.State then return end
    
    local function onStateChange()
        pcall(function()
            local state = char.State.State
            local isEmoting = state == "Emote" or state == "Emoting" or state == "EmotingSlide"
            
            if isEmoting then
                applyMovementMultiplier(featureStates.EmoteSpeedValue / 1000)
            else
                applyMovementMultiplier(1.5)
            end
        end)
    end
    
    onStateChange()
    pcall(function()
        emoteConnection = char.State:GetPropertyChangedSignal("State"):Connect(onStateChange)
    end)
end

function EmoteSpeed.SetMode(mode)
    if emoteConnection then
        emoteConnection:Disconnect()
        emoteConnection = nil
    end
    
    if mode == "Off" then
        restoreEmoteSpeeds()
        applyMovementMultiplier(1.5)
    elseif mode == "Legit (speed mult)" then
        restoreEmoteSpeeds()
        applyEmoteSpeed(featureStates.EmoteSpeedValue / 1000)
    elseif mode == "Walk multiplier" then
        restoreEmoteSpeeds()
        setupEmoteStateListener()
    end
end

function EmoteSpeed.SetValue(value)
    local num = tonumber(value)
    if num and num > 0 then
        featureStates.EmoteSpeedValue = num
        local appliedValue = num / 1000
        
        local mode = EmoteSpeed.CurrentMode
        if mode == "Legit (speed mult)" then
            applyEmoteSpeed(appliedValue)
        elseif mode == "Walk multiplier" then
            local char = getLocalChar()
            if char and char.State then
                local state = char.State.State
                if state == "Emote" or state == "Emoting" or state == "EmotingSlide" then
                    applyMovementMultiplier(appliedValue)
                end
            end
        end
    end
end

function EmoteSpeed.ApplyUnwalkable(speedValue)
    local speed = tonumber(speedValue) / 1000
    for _, mod in ipairs(emoteModules) do
        local orig = originalSpeeds[mod]
        if orig == 0 then
            local ok, data = pcall(require, mod)
            if ok and type(data) == "table" and data.EmoteInfo then
                pcall(function() data.EmoteInfo.SpeedMult = speed end)
            end
        end
    end
end

function EmoteSpeed.Reset()
    restoreEmoteSpeeds()
    applyMovementMultiplier(1.5)
    if emoteConnection then
        emoteConnection:Disconnect()
        emoteConnection = nil
    end
end

function EmoteSpeed.OnRespawn()
    if EmoteSpeed.CurrentMode == "Walk multiplier" then
        setupEmoteStateListener()
    end
end

return EmoteSpeed
