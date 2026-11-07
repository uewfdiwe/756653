local AutoJump = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterService = require(ReplicatedStorage.Services.Asset.CharacterService)
local player = Players.LocalPlayer

local state = {
    autoJumpType = "Bounce",
    autoJumpEnabled = false,
    bhopAccelValue = -0.5,
    jumpCooldown = 0.25,
    rotationEnabled = false,
    wallJumpEnabled = false,
    bhopHoldActive = false,
    realisticPCEnabled = false,
    bhopHoldToggle = false,
}

local refs = {
    Character = nil,
    Humanoid = nil,
    HumanoidRootPart = nil,
    bhopConnection = nil,
    bhopLoaded = false,
    rotationConnection = nil,
    wallJumpConnection = nil,
    autoResetConnection = nil,
    wasBhopActive = false,
    frictionTables = {},
    lastFrictionScanTime = 0,
    realisticLastJump = 0,
    LastJump = 0,
    characterConnection = nil,
    jumpButtonDownConnection = nil,
    jumpButtonUpConnection = nil,
}

local DEFAULT_FRICTION = 5
local FRICTION_SCAN_INTERVAL = 1
local GROUND_CHECK_OFFSET = 3.5
local GROUND_CHECK_RAY_LENGTH = 4
local MAX_SLOPE_ANGLE = 45
local rotationSpeed = 100000

local wallJumpStates = {
    WallrunLeft = true,
    WallrunRight = true,
    WallrunningLeft = true,
    WallrunningRight = true,
}

local function findFrictionTables()
    local now = tick()
    if now - refs.lastFrictionScanTime < FRICTION_SCAN_INTERVAL and #refs.frictionTables > 0 then return end
    refs.lastFrictionScanTime = now

    refs.frictionTables = {}

    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Friction") then
            local original = obj.Friction
            if original == -0.5 then original = DEFAULT_FRICTION end
            table.insert(refs.frictionTables, { obj = obj, original = original })
        end
    end

    local char = CharacterService:GetLocalCharacter()
    if char and char.Movement then
        local ms = char.Movement.MoveStats
        if ms then
            local target = ms.MoveStats or ms
            if target and type(target) == "table" and target.Friction ~= nil then
                local original = target.Friction
                if original == -0.5 then original = DEFAULT_FRICTION end
                local exists = false
                for _, t in ipairs(refs.frictionTables) do
                    if t.obj == target then exists = true; break end
                end
                if not exists then
                    table.insert(refs.frictionTables, { obj = target, original = original })
                end
            end
        end
    end
end

local function applyBhopFriction()
    local isActive = state.autoJumpEnabled or state.bhopHoldActive or state.realisticPCEnabled

    if #refs.frictionTables == 0 then findFrictionTables() end

    for _, tableData in ipairs(refs.frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            if isActive then
                pcall(function()
                    tableData.obj.Friction = state.bhopAccelValue or -0.5
                end)
            else
                pcall(function()
                    local restore = tableData.original
                    if restore == nil or restore == -0.5 then restore = DEFAULT_FRICTION end
                    tableData.obj.Friction = restore
                end)
            end
        end
    end
end

local function forceDefaultFriction()
    if #refs.frictionTables == 0 then findFrictionTables() end
    for _, tableData in ipairs(refs.frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            pcall(function()
                tableData.obj.Friction = DEFAULT_FRICTION
            end)
        end
    end
end

local function forceAccelerationFriction()
    local value = state.bhopAccelValue or -0.5
    if #refs.frictionTables == 0 then findFrictionTables() end
    for _, tableData in ipairs(refs.frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            pcall(function()
                tableData.obj.Friction = value
            end)
        end
    end
end

local function autoResetFriction()
    if #refs.frictionTables == 0 then findFrictionTables() end
    for _, tableData in ipairs(refs.frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            pcall(function()
                tableData.obj.Friction = DEFAULT_FRICTION
            end)
        end
    end
end

local function startAutoReset()
    if refs.autoResetConnection then return end
    refs.autoResetConnection = RunService.Heartbeat:Connect(function()
        local isActive = state.autoJumpEnabled or state.bhopHoldActive or state.realisticPCEnabled

        if refs.wasBhopActive and not isActive then
            autoResetFriction()
        end

        -- ★ НОВАЯ ЛОГИКА: Если State = Idle или Move, сбрасываем таблицу
        local char = CharacterService:GetLocalCharacter()
        if char and char.State and char.State.State then
            local currentState = char.State.State
            if currentState == "Idle" or currentState == "Move" then
                if #refs.frictionTables > 0 then
                    forceDefaultFriction()
                    refs.frictionTables = {}
                    refs.lastFrictionScanTime = 0
                end
            end
        end

        refs.wasBhopActive = isActive
    end)
end

local function canJumpRealistic()
    local char = CharacterService:GetLocalCharacter()
    if not char or not char.State then return false end
    local s = char.State.State
    if s == "Downed" or s == "Climbing" or s == "Seated"
        or s == "Carrying" or s == "Dead" then
        return false
    end
    if char.DataRegistry then
        if char.DataRegistry:Get("Grounded") == false then return false end
    end
    return true
end

local function doJumpRealistic()
    local char = CharacterService:GetLocalCharacter()
    if not char then return false end

    local success = false

    if char.Movement and char.Movement.Jump then
        local ok = pcall(function()
            char.Movement:Jump(nil, true)
        end)
        if ok then success = true end
    end

    if not success and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum.Jump = true end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            success = true
        end
    end

    return success
end

local function IsOnGround()
    local Character = refs.Character
    local Humanoid = refs.Humanoid
    local HRP = refs.HumanoidRootPart
    if not Character or not HRP or not Humanoid then return false end

    local s = Humanoid:GetState()
    if s == Enum.HumanoidStateType.Jumping or
       s == Enum.HumanoidStateType.Freefall or
       s == Enum.HumanoidStateType.Swimming then
        return false
    end
    if s == Enum.HumanoidStateType.Running then
        return true
    end

    local rayOrigin = HRP.Position
    local rayDirection = Vector3.new(0, -GROUND_CHECK_RAY_LENGTH, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Character}
    raycastParams.IgnoreWater = true
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult then
        local surfaceNormal = raycastResult.Normal
        local angle = math.deg(math.acos(surfaceNormal:Dot(Vector3.new(0, 1, 0))))
        if angle <= MAX_SLOPE_ANGLE then
            local heightDiff = math.abs(rayOrigin.Y - raycastResult.Position.Y)
            return heightDiff <= GROUND_CHECK_OFFSET
        end
    end
    if HRP.Velocity.Y > -1 and HRP.Velocity.Y < 1 then
        return true
    end
    return false
end

local function updateBhop()
    if not refs.bhopLoaded then return end

    local isActive = state.autoJumpEnabled or state.bhopHoldActive or state.realisticPCEnabled

    if isActive then
        if not refs.Character or not refs.Humanoid or not refs.HumanoidRootPart then
            refs.Character = player.Character
            if refs.Character then
                refs.Humanoid = refs.Character:FindFirstChildOfClass("Humanoid")
                refs.HumanoidRootPart = refs.Character:FindFirstChild("HumanoidRootPart")
            end
            if not refs.Humanoid or not refs.HumanoidRootPart then return end
        end

        if refs.Humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

        applyBhopFriction()

        if state.autoJumpType == "Bounce" then
            local now = tick()
            local cooldown = state.jumpCooldown or 0.25
            if IsOnGround() and (now - refs.LastJump) > cooldown then
                refs.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                refs.LastJump = now
            end
        end
    end
end

local function loadBhop()
    if refs.bhopLoaded then return end
    refs.bhopLoaded = true
    if #refs.frictionTables == 0 then findFrictionTables() end
    forceAccelerationFriction()
    if refs.bhopConnection then refs.bhopConnection:Disconnect() end
    refs.bhopConnection = RunService.Heartbeat:Connect(function(deltaTime)
        updateBhop()
    end)
end

local function unloadBhop()
    if not refs.bhopLoaded then return end
    refs.bhopLoaded = false
    if refs.bhopConnection then
        refs.bhopConnection:Disconnect()
        refs.bhopConnection = nil
    end
    state.bhopHoldActive = false
    if #refs.frictionTables == 0 then findFrictionTables() end
    forceDefaultFriction()
end

local function startRotation()
    if refs.rotationConnection then
        refs.rotationConnection:Disconnect()
        refs.rotationConnection = nil
    end
    if not state.rotationEnabled or not refs.HumanoidRootPart then return end
    refs.rotationConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if refs.HumanoidRootPart and refs.HumanoidRootPart.Parent then
            local currentRotation = refs.HumanoidRootPart.Orientation
            local newRotation = Vector3.new(
                currentRotation.X,
                currentRotation.Y + (rotationSpeed * deltaTime),
                currentRotation.Z
            )
            refs.HumanoidRootPart.Orientation = newRotation
        else
            if refs.rotationConnection then
                refs.rotationConnection:Disconnect()
                refs.rotationConnection = nil
            end
        end
    end)
end

local function stopRotation()
    if refs.rotationConnection then
        refs.rotationConnection:Disconnect()
        refs.rotationConnection = nil
    end
end

local function updateRotationState()
    if state.rotationEnabled and state.autoJumpEnabled then
        startRotation()
    else
        stopRotation()
    end
end

local function updateWallJump()
    if not state.wallJumpEnabled then return end
    local char = CharacterService:GetLocalCharacter()
    if not char or not char.State then return end
    local s = char.State.State
    if not wallJumpStates[s] then return end
    if char.Movement and char.Movement.Jump then
        pcall(function()
            char.Movement:Jump(nil, true)
        end)
    end
end

local function startWallJump()
    if refs.wallJumpConnection then return end
    refs.wallJumpConnection = RunService.Heartbeat:Connect(updateWallJump)
end

local function stopWallJump()
    if refs.wallJumpConnection then
        refs.wallJumpConnection:Disconnect()
        refs.wallJumpConnection = nil
    end
end

local function checkBhopState()
    local shouldLoad = state.autoJumpEnabled or state.bhopHoldActive or state.realisticPCEnabled

    if shouldLoad then
        loadBhop()
        updateRotationState()
    else
        unloadBhop()
        stopRotation()
    end
end

RunService.Heartbeat:Connect(function()
    local isRealistic = (state.autoJumpType == "Realistic")
    if not isRealistic then return end

    local shouldJump = state.realisticPCEnabled or state.autoJumpEnabled

    if shouldJump and not refs.bhopLoaded then
        checkBhopState()
    elseif not shouldJump and refs.bhopLoaded and not (state.autoJumpEnabled or state.bhopHoldActive) then
        checkBhopState()
    end

    if not shouldJump then return end

    local now = tick()
    local cooldown = state.jumpCooldown or 0.25
    if now - refs.realisticLastJump < cooldown then return end

    if canJumpRealistic() then
        doJumpRealistic()
        refs.realisticLastJump = now
    end
end)

local function onCharacter(character)
    refs.Character = character
    refs.frictionTables = {}
    refs.lastFrictionScanTime = 0
    task.wait(0.5)
    refs.Humanoid = character:WaitForChild("Humanoid")
    refs.HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

    if state.autoJumpEnabled or state.bhopHoldActive then
        task.wait(1)
        checkBhopState()
    else
        task.wait(1)
        forceDefaultFriction()
    end
    updateRotationState()
end

local function setupInput()
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Space then
            if state.autoJumpType == "Realistic" then
                state.realisticPCEnabled = true
            end
            if state.bhopHoldToggle then
                state.bhopHoldActive = true
                checkBhopState()
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then
            state.realisticPCEnabled = false
            if state.bhopHoldToggle then
                state.bhopHoldActive = false
                checkBhopState()
            end
        end
    end)
end

local function setupMobileJump()
    if not UserInputService.TouchEnabled then return end
    task.spawn(function()
        task.wait(2)
        pcall(function()
            local touchGui = player:WaitForChild("PlayerGui"):WaitForChild("TouchGui", 10)
            if not touchGui then return end
            local frame = touchGui:WaitForChild("TouchControlFrame", 10)
            if not frame then return end
            local jumpBtn = frame:WaitForChild("JumpButton", 10)
            if not jumpBtn then return end

            if refs.jumpButtonDownConnection then
                refs.jumpButtonDownConnection:Disconnect()
                refs.jumpButtonDownConnection = nil
            end
            if refs.jumpButtonUpConnection then
                refs.jumpButtonUpConnection:Disconnect()
                refs.jumpButtonUpConnection = nil
            end

            refs.jumpButtonDownConnection = jumpBtn.MouseButton1Down:Connect(function()
                if state.bhopHoldToggle then
                    state.bhopHoldActive = true
                    checkBhopState()
                end
            end)

            refs.jumpButtonUpConnection = jumpBtn.MouseButton1Up:Connect(function()
                if state.bhopHoldToggle then
                    state.bhopHoldActive = false
                    checkBhopState()
                end
            end)
        end)
    end)
end

function AutoJump.Init(createGradientButtonFunc)
    setupInput()
    setupMobileJump()
    startAutoReset()

    refs.characterConnection = player.CharacterAdded:Connect(onCharacter)

    if player.Character then
        task.spawn(function()
            onCharacter(player.Character)
        end)
    end
end

function AutoJump.SetMode(mode)
    state.autoJumpType = mode
end

function AutoJump.SetEnabled(enabled)
    state.autoJumpEnabled = enabled
    checkBhopState()
end

function AutoJump.SetHold(enabled)
    state.bhopHoldToggle = enabled
    if not enabled then
        state.bhopHoldActive = false
        checkBhopState()
    end
end

function AutoJump.SetRotation(enabled)
    state.rotationEnabled = enabled
    updateRotationState()
end

function AutoJump.SetWallJump(enabled)
    state.wallJumpEnabled = enabled
    if enabled then
        startWallJump()
    else
        stopWallJump()
    end
end

function AutoJump.SetAcceleration(value)
    state.bhopAccelValue = value
    if #refs.frictionTables == 0 then findFrictionTables() end
    if state.autoJumpEnabled or state.bhopHoldActive or state.realisticPCEnabled then
        for _, t in ipairs(refs.frictionTables) do
            if t.obj and type(t.obj) == "table" then
                pcall(function()
                    t.obj.Friction = value
                end)
            end
        end
    end
end

function AutoJump.SetCooldown(value)
    state.jumpCooldown = value
end

function AutoJump.IsEnabled()
    return state.autoJumpEnabled
end

function AutoJump.Destroy()
    unloadBhop()
    stopRotation()
    stopWallJump()
    if refs.autoResetConnection then
        refs.autoResetConnection:Disconnect()
        refs.autoResetConnection = nil
    end
    if refs.characterConnection then
        refs.characterConnection:Disconnect()
        refs.characterConnection = nil
    end
end

return AutoJump
