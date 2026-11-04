local Fly = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local flying = false
local enabled = false
local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil
local character = LocalPlayer.Character
local humanoid = character and character:FindFirstChild("Humanoid")
local rootPart = character and character:FindFirstChild("HumanoidRootPart")
local flyLoop = nil
local characterAddedConnection = nil
local characterRemovingConnection = nil

local function startFlying()
    if not character or not humanoid or not rootPart then
        character = LocalPlayer.Character
        if not character then return end
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
    end

    flying = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart

    humanoid.PlatformStand = true
end

local function stopFlying()
    flying = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function updateFly()
    if not flying or not bodyVelocity or not bodyGyro then return end
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    local direction = Vector3.new(0, 0, 0)
    local moveDirection = humanoid.MoveDirection

    if moveDirection.Magnitude > 0 then
        local forwardVector = cameraCFrame.LookVector
        local rightVector = cameraCFrame.RightVector
        local forwardComponent = moveDirection:Dot(forwardVector) * forwardVector
        local rightComponent = moveDirection:Dot(rightVector) * rightVector
        direction = direction + (forwardComponent + rightComponent).Unit * moveDirection.Magnitude
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0)
    end

    bodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * (flySpeed * 2) or Vector3.new(0, 0, 0)
    bodyGyro.CFrame = cameraCFrame
end

function Fly.setSpeed(value)
    flySpeed = tonumber(value) or flySpeed
end

function Fly.set(state)
    enabled = state and true or false

    if enabled then
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
        end

        characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
            character = newChar
            task.wait(0.5)
            humanoid = character:WaitForChild("Humanoid")
            rootPart = character:WaitForChild("HumanoidRootPart")

            if enabled and flying == false then
                startFlying()
            end
        end)

        if not characterRemovingConnection then
            characterRemovingConnection = LocalPlayer.CharacterRemoving:Connect(function()
                if enabled then
                    stopFlying()
                    if flyLoop then
                        flyLoop:Disconnect()
                        flyLoop = nil
                    end
                end
            end)
        end

        character = LocalPlayer.Character
        if character then
            humanoid = character:FindFirstChild("Humanoid")
            rootPart = character:FindFirstChild("HumanoidRootPart")
        end

        startFlying()

        if not flyLoop then
            flyLoop = RunService.RenderStepped:Connect(function()
                if enabled then
                    updateFly()
                end
            end)
        end
    else
        stopFlying()

        if flyLoop then
            flyLoop:Disconnect()
            flyLoop = nil
        end

        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
    end
end

return Fly
