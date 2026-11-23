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
    preSimConnection = nil,
    bhopLoaded = false,
    rotationConnection = nil,
    wallJumpConnection = nil,
    frictionTables = {},
    lastFrictionScanTime = 0,
    realisticLastJump = 0,
    LastJump = 0,
    characterConnection = nil,
    jumpButtonDownConnection = nil,
    jumpButtonUpConnection = nil,
    bhopButtonScreenGui = nil,
    createGradientButton = nil,
}

local DEFAULT_FRICTION = 5
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

local function normalizeOriginal(original)
    if type(original) ~= "number" or original < 1 then
        return DEFAULT_FRICTION
    end
    return original
end

local function eachLiveMoveStats(callback)
    local char = CharacterService:GetLocalCharacter()
    if not char or not char.Movement then return end
    local ms = char.Movement.MoveStats
    if type(ms) ~= "table" then return end
    if ms.Friction ~= nil then
        callback(ms)
    end
    if type(ms.MoveStats) == "table" and ms.MoveStats ~= ms and ms.MoveStats.Friction ~= nil then
        callback(ms.MoveStats)
    end
end

local function getLiveMoveStats()
    local found = nil
    eachLiveMoveStats(function(target)
        found = target
    end)
    return found
end

local function rememberFrictionTable(target)
    if type(target) ~= "table" then return end
    for _, tableData in ipairs(refs.frictionTables) do
        if tableData.obj == target then return end
    end
    table.insert(refs.frictionTables, { obj = target, original = normalizeOriginal(target.Friction) })
end

local function rememberLiveTables()
    eachLiveMoveStats(rememberFrictionTable)
end

local function slideOwnsFriction()
    local api = rawget(getgenv(), "InfiniteSlide")
    if type(api) ~= "table" or type(api.IsApplying) ~= "function" then
        return false
    end
    local ok, applying = pcall(api.IsApplying)
    return ok and applying == true
end

local function findFrictionTables()
    if #refs.frictionTables > 0 then
        rememberLiveTables()
        return
    end
    refs.lastFrictionScanTime = tick()

    refs.frictionTables = {}

    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Friction") then
            table.insert(refs.frictionTables, { obj = obj, original = normalizeOriginal(obj.Friction) })
        end
    end

    local target = getLiveMoveStats()
    if target then
        local exists = false
        for _, t in ipairs(refs.frictionTables) do
            if t.obj == target then exists = true; break end
        end
        if not exists then
            table.insert(refs.frictionTables, { obj = target, original = normalizeOriginal(target.Friction) })
        end
    end
end

local function applyBhopFriction()
    if slideOwnsFriction() then return end

    local isActive = state.autoJumpEnabled or state.bhopHoldActive or state.realisticPCEnabled
    rememberLiveTables()
    if #refs.frictionTables == 0 then findFrictionTables() end

    local value = state.bhopAccelValue or -0.5
    for _, tableData in ipairs(refs.frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            pcall(function()
                if isActive then
                    tableData.obj.Friction = value
                else
                    local restore = tableData.original
                    if type(restore) ~= "number" or restore < 1 then restore = DEFAULT_FRICTION end
                    tableData.obj.Friction = restore
                end
            end)
        end
    end
    if isActive then
        eachLiveMoveStats(function(target)
            pcall(function()
                target.Friction = value
            end)
        end)
    end
end

local function writeDefaultFriction(obj)
    if obj and type(obj) == "table" and obj.Friction ~= nil then
        pcall(function()
            obj.Friction = DEFAULT_FRICTION
        end)
    end
end

local function writeLiveFriction(value)
    eachLiveMoveStats(function(target)
        pcall(function()
            target.Friction = value
        end)
    end)
end

local function resetSpeedTable()
    local sliding = slideOwnsFriction()
    for _, tableData in ipairs(refs.frictionTables) do
        tableData.original = DEFAULT_FRICTION
        if not sliding then
            writeDefaultFriction(tableData.obj)
        end
    end
    if not sliding then
        writeLiveFriction(DEFAULT_FRICTION)
    end
end

local function forceAccelerationFriction()
    if slideOwnsFriction() then return end
    local value = state.bhopAccelValue or -0.5
    if #refs.frictionTables == 0 then findFrictionTables() end
    for _, tableData in ipairs(refs.frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            pcall(function()
                tableData.obj.Friction = value
            end)
        end
    end
    writeLiveFriction(value)
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

local function refreshCharacter()
    local character = player.Character
    if not character then return false end
    if refs.Character ~= character
        or not refs.Humanoid or not refs.Humanoid.Parent
        or not refs.HumanoidRootPart or not refs.HumanoidRootPart.Parent then
        refs.Character = character
        refs.Humanoid = character:FindFirstChildOfClass("Humanoid")
        refs.HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    end
    return refs.Humanoid ~= nil and refs.HumanoidRootPart ~= nil
end

local function IsOnGround()
    if not refreshCharacter() then return false end
    local Character = refs.Character
    local Humanoid = refs.Humanoid
    local HRP = refs.HumanoidRootPart

    local ok, s = pcall(function()
        return Humanoid:GetState()
    end)
    if not ok then return false end
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

local function doJumpBounce()
    if not refs.Humanoid then return end
    pcall(function()
        refs.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

local function updateBhop()
    if not refs.bhopLoaded then return end

    local isActive = state.autoJumpEnabled or state.bhopHoldActive or state.realisticPCEnabled
    if not isActive then return end

    applyBhopFriction()
    if not refreshCharacter() then return end

    local ok, humanoidState = pcall(function()
        return refs.Humanoid:GetState()
    end)
    if not ok or humanoidState == Enum.HumanoidStateType.Dead then return end

    if state.autoJumpType == "Bounce" then
        local now = tick()
        local cooldown = state.jumpCooldown or 0.25
        if IsOnGround() and (now - refs.LastJump) > cooldown then
            doJumpBounce()
            refs.LastJump = now
        end
    end
end

local function loadBhop()
    if refs.bhopLoaded then return end
    refs.bhopLoaded = true
    if #refs.frictionTables == 0 then findFrictionTables() end
    forceAccelerationFriction()
    if refs.bhopConnection then refs.bhopConnection:Disconnect() end
    refs.bhopConnection = RunService.Heartbeat:Connect(function()
        pcall(updateBhop)
    end)
    if refs.preSimConnection then refs.preSimConnection:Disconnect() end
    if RunService.PreSimulation then
        refs.preSimConnection = RunService.PreSimulation:Connect(function()
            if not refs.bhopLoaded then return end
            if state.autoJumpEnabled or state.bhopHoldActive or state.realisticPCEnabled then
                pcall(applyBhopFriction)
            end
        end)
    end
end

local function unloadBhop()
    if not refs.bhopLoaded then return end
    refs.bhopLoaded = false
    if refs.bhopConnection then
        refs.bhopConnection:Disconnect()
        refs.bhopConnection = nil
    end
    if refs.preSimConnection then
        refs.preSimConnection:Disconnect()
        refs.preSimConnection = nil
    end
    state.bhopHoldActive = false
    resetSpeedTable()
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
        resetSpeedTable()
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
    if createGradientButtonFunc then
        refs.createGradientButton = createGradientButtonFunc
    end
    setupInput()
    setupMobileJump()

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
    if slideOwnsFriction() then return end
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

function AutoJump.IsFrictionActive()
    return state.autoJumpEnabled or state.bhopHoldActive or state.realisticPCEnabled
end

function AutoJump.GetAcceleration()
    return state.bhopAccelValue or -0.5
end

function AutoJump.ReapplyAcceleration()
    if not AutoJump.IsFrictionActive() or slideOwnsFriction() then return end
    local value = state.bhopAccelValue or -0.5
    for _, tableData in ipairs(refs.frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            pcall(function()
                tableData.obj.Friction = value
            end)
        end
    end
    writeLiveFriction(value)
end

function AutoJump.SetExternalFriction(value)
    if type(value) ~= "number" then return end
    for _, tableData in ipairs(refs.frictionTables) do
        if tableData.obj and type(tableData.obj) == "table" then
            pcall(function()
                tableData.obj.Friction = value
            end)
        end
    end
    writeLiveFriction(value)
end

function AutoJump.ResetFriction()
    resetSpeedTable()
end

function AutoJump.CreateButton(parent, position, size, text, onClick)
    if refs.bhopButtonScreenGui then
        refs.bhopButtonScreenGui:Destroy()
        refs.bhopButtonScreenGui = nil
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BhopButtonGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parent

    local btn, clicker, stroke = refs.createGradientButton(
        screenGui,
        position,
        size,
        text
    )

    clicker.MouseButton1Click:Connect(onClick)

    refs.bhopButtonScreenGui = screenGui
    return screenGui, btn, clicker
end

function AutoJump.UpdateButtonText(text)
    if refs.bhopButtonScreenGui and refs.bhopButtonScreenGui:FindFirstChild("GradientBtn") then
        local button = refs.bhopButtonScreenGui:FindFirstChild("GradientBtn")
        if button and button:FindFirstChild("TextLabel") then
            button.TextLabel.Text = text
        end
    end
end

function AutoJump.Destroy()
    unloadBhop()
    stopRotation()
    stopWallJump()
    resetSpeedTable()
    if refs.characterConnection then
        refs.characterConnection:Disconnect()
        refs.characterConnection = nil
    end
    if refs.bhopButtonScreenGui then
        refs.bhopButtonScreenGui:Destroy()
        refs.bhopButtonScreenGui = nil
    end
end

return AutoJump
