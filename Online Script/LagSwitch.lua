local LagSwitch = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local deps = {}
local enabled = false
local lagDelayValue = 0.1
local lagIntensity = 1000000
local lagSwitchMode = "Normal"
local isLagActive = false
local demonRiseHeight = 100
local demonRiseSpeed = 80

local function notify(title, content, duration)
    if deps.notify then
        deps.notify(title, content, duration)
    end
end

local function performMathLag()
    local startTime = tick()
    local duration = lagDelayValue

    while tick() - startTime < duration do
        for i = 1, lagIntensity do
            local a = math.random(1, 1000000) * math.random(1, 1000000)
            a = a / math.random(1, 10000)
            local b = math.sqrt(math.random(1, 1000000))
            b = b * math.pi * math.exp(1)
            local c = math.sin(math.rad(math.random(1, 360))) * math.cos(math.rad(math.random(1, 360)))
        end
    end
end

local function performDemonLag()
    local startTime = tick()
    local duration = lagDelayValue

    local currentHeightInput = demonRiseHeight
    local currentSpeedInput = demonRiseSpeed
    if deps.getDemonHeight then
        currentHeightInput = tonumber(deps.getDemonHeight()) or currentHeightInput
    end
    if deps.getDemonSpeed then
        currentSpeedInput = tonumber(deps.getDemonSpeed()) or currentSpeedInput
    end

    local RISE_HEIGHT = tonumber(currentHeightInput) or 10
    local BOOST_SPEED = tonumber(currentSpeedInput) or 80

    task.spawn(function()
        local startLagTime = tick()
        while tick() - startLagTime < duration do
            for i = 1, math.floor(lagIntensity / 2) do
                local a = math.random(1, 1000000) * math.random(1, 1000000)
                a = a / math.random(1, 10000)
                local b = math.sqrt(math.random(1, 1000000))
                b = b * math.pi * math.exp(1)
            end
        end
    end)

    local player = Players.LocalPlayer
    local character = player.Character

    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        if humanoidRootPart and humanoid then
            local startHeight = humanoidRootPart.Position.Y

            local bodyThrust = Instance.new("BodyThrust")
            bodyThrust.Name = "DemonRiseThrust"
            bodyThrust.Force = Vector3.new(0, BOOST_SPEED * 500, 0)
            bodyThrust.Location = Vector3.new(0, 0, 0)
            bodyThrust.Parent = humanoidRootPart

            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "DemonRiseVelocity"
            bodyVelocity.MaxForce = Vector3.new(0, 500000, 0)
            bodyVelocity.Velocity = Vector3.new(0, BOOST_SPEED, 0)
            bodyVelocity.Parent = humanoidRootPart

            local waitTime = 0
            local maxWaitTime = 5

            while waitTime < maxWaitTime do
                local currentHeight = humanoidRootPart.Position.Y
                local heightGained = currentHeight - startHeight

                if heightGained >= RISE_HEIGHT then
                    break
                end

                task.wait(0.1)
                waitTime = waitTime + 0.1
            end

            if bodyThrust then
                bodyThrust:Destroy()
            end
            if bodyVelocity then
                bodyVelocity:Destroy()
            end

            local finalHeight = humanoidRootPart.Position.Y
            local heightGained = finalHeight - startHeight

            notify("Demon Mode", string.format("Lifted %.1f meters", heightGained), 3)
        end
    end

    isLagActive = false
end

function LagSwitch.init(initDeps)
    deps = initDeps or {}
    getgenv().DemonRiseHeight = demonRiseHeight
    getgenv().DemonRiseSpeed = demonRiseSpeed
    getgenv().DemonSoftLanding = true
end

function LagSwitch.setEnabled(value)
    enabled = value and true or false
end

function LagSwitch.setMode(value)
    lagSwitchMode = value or "Normal"
end

function LagSwitch.setDelay(value)
    lagDelayValue = value
end

function LagSwitch.setIntensity(value)
    lagIntensity = value
end

function LagSwitch.setDemonHeight(value)
    demonRiseHeight = value
    getgenv().DemonRiseHeight = value
end

function LagSwitch.setDemonSpeed(value)
    demonRiseSpeed = value
    getgenv().DemonRiseSpeed = value
end

function LagSwitch.toggle()
    if not enabled then
        return
    end
    if isLagActive then
        return
    end

    isLagActive = true

    if lagSwitchMode == "Normal" then
        task.spawn(function()
            performMathLag()
            isLagActive = false
        end)
    elseif lagSwitchMode == "Demon" then
        task.spawn(function()
            performDemonLag()
            isLagActive = false
        end)
    else
        isLagActive = false
    end
end

function LagSwitch.updateButtonLabel()
    local screenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")
    if screenGui then
        local button = screenGui:FindFirstChild("GradientBtn")
        if button and button:FindFirstChild("TextLabel") then
            button.TextLabel.Text = "Lag Switch"
        end
    end
end

function LagSwitch.setGUI(visible)
    local existingScreenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")

    if not visible then
        if existingScreenGui then
            existingScreenGui:Destroy()
        end
        return
    end

    if existingScreenGui then
        existingScreenGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LagSwitchButtonGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    local buttonSize = 180
    if deps.getButtonSize then
        buttonSize = tonumber(deps.getButtonSize()) or 180
    end
    local btnWidth = math.max(150, math.min(buttonSize, 400))
    local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))

    local btn, clicker = deps.createGradientButton(
        screenGui,
        UDim2.new(0.5, -btnWidth / 2, 0.5, -btnHeight / 2),
        UDim2.new(0, btnWidth, 0, btnHeight),
        "Lag Switch"
    )

    clicker.MouseButton1Click:Connect(function()
        LagSwitch.toggle()
    end)
end

return LagSwitch
