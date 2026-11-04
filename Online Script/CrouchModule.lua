local CrouchModule = {}

local RunService = game:GetService("RunService")
local CharacterService = require(game:GetService("ReplicatedStorage").Services.Asset.CharacterService)

local enabled = false
local mode = "Spam"
local delay = 0.1
local connection = nil
local lastTime = 0

local airStates = {
    ["Air"] = true,
    ["CarryAir"] = true,
    ["Jumping"] = true,
    ["Freefall"] = true,
}

local function setCrouchKey(state)
    local char = CharacterService:GetLocalCharacter()
    if char and char.DataRegistry then
        pcall(function()
            char.DataRegistry:Set("CrouchKey", state)
        end)
    end
end

local function simulateCrouchPress()
    setCrouchKey(true)
    task.wait(0.05)
    setCrouchKey(false)
end

function CrouchModule.Start()
    if connection then return end
    enabled = true

    connection = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        
        local char = CharacterService:GetLocalCharacter()
        if not char then return end

        if mode == "Classic" then
            setCrouchKey(true)
            
        elseif mode == "Spam" then
            if tick() - lastTime > delay then
                lastTime = tick()
                simulateCrouchPress()
            end
            
        elseif mode == "Air" then
            local state = char.State and char.State.State
            
            if state and airStates[state] then
                if tick() - lastTime > delay then
                    lastTime = tick()
                    setCrouchKey(true)
                    
                    task.delay(0.05, function()
                        setCrouchKey(false)
                    end)
                end
            end
        end
    end)
end

function CrouchModule.Stop()
    enabled = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
    setCrouchKey(false)
end

function CrouchModule.SetMode(newMode)
    mode = newMode
end

function CrouchModule.SetDelay(newDelay)
    local num = tonumber(newDelay)
    if num and num > 0 then
        delay = num
    end
end

return CrouchModule
