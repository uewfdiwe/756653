local CarryPlayers = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local InteractRemote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Interact")

local CharacterService
pcall(function()
    CharacterService = require(ReplicatedStorage.Services.Asset.CharacterService)
end)

local deps = {}
local AutoCarryConnection = nil
local carryWeldConnection = nil
local started = false
local enabled = false
local isCarrying = false

local carryStates = {
    CarryIdle = true,
    CarryMove = true,
    CarryAir = true,
    CarrySlide = true,
}

local function getLocalState()
    if not CharacterService then
        return nil
    end
    local char = CharacterService:GetLocalCharacter()
    if char and char.State then
        return char.State.State
    end
    return nil
end

local function isInCarryState()
    local state = getLocalState()
    return state and carryStates[state] == true
end

local function isCarryingPlayer()
    local char = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild(player.Name)
    if char then
        local carryWeld = char:FindFirstChild("CarryWeld")
        if carryWeld then
            isCarrying = true
            return true
        end

        local carrying = char:GetAttribute("Carrying")
        if carrying and carrying ~= 0 then
            isCarrying = true
            return true
        end
    end

    isCarrying = false
    return false
end

local function startAutoCarry()
    if AutoCarryConnection then
        AutoCarryConnection:Disconnect()
        AutoCarryConnection = nil
    end

    AutoCarryConnection = RunService.Heartbeat:Connect(function()
        if not enabled then
            return
        end

        if isCarryingPlayer() then
            return
        end

        if isInCarryState() then
            return
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hrp then
            local playersFolder = Workspace:FindFirstChild("Players")
            if not playersFolder then return end

            for _, otherChar in ipairs(playersFolder:GetChildren()) do
                if otherChar.Name ~= player.Name then
                    local otherTag = otherChar:GetAttribute("Tag")
                    if otherTag then
                        local otherHrp = otherChar:FindFirstChild("HumanoidRootPart")
                        if otherHrp then
                            local dist = (hrp.Position - otherHrp.Position).Magnitude
                            if dist <= 20 then
                                if InteractRemote then
                                    InteractRemote:FireServer("Carry", otherTag)
                                end
                                task.wait(0.01)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoCarry()
    if AutoCarryConnection then
        AutoCarryConnection:Disconnect()
        AutoCarryConnection = nil
    end
    isCarrying = false
end

local function updateButtonText(btn)
    if btn and btn:FindFirstChild("TextLabel") then
        local text = isCarrying and "Auto Carry: Carrying" or (enabled and "Auto Carry: On" or "Auto Carry: Off")
        btn.TextLabel.Text = text
    end
end

function CarryPlayers.init(initDeps)
    deps = initDeps or {}
end

function CarryPlayers.setEnabled(state)
    enabled = state and true or false
    if enabled then
        startAutoCarry()
    else
        stopAutoCarry()
    end

    local screenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
    local btn = screenGui and screenGui:FindFirstChild("GradientBtn")
    updateButtonText(btn)
end

function CarryPlayers.setGUI(visible)
    local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")

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
    screenGui.Name = "AutoCarryButtonGUI"
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
        "Auto Carry: Off"
    )

    updateButtonText(btn)

    clicker.MouseButton1Click:Connect(function()
        CarryPlayers.setEnabled(not enabled)
        if deps.setAutoCarryToggle then
            deps.setAutoCarryToggle(enabled)
        end
    end)

    local autoCarryToggle = deps.getAutoCarryToggle and deps.getAutoCarryToggle()
    if autoCarryToggle then
        autoCarryToggle:OnChanged(function(state)
            CarryPlayers.setEnabled(state)
        end)
    end
end

local function setupCarryWeldListener()
    if carryWeldConnection then
        carryWeldConnection:Disconnect()
        carryWeldConnection = nil
    end

    local char = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild(player.Name)
    if char then
        carryWeldConnection = char.ChildAdded:Connect(function(child)
            if child.Name == "CarryWeld" then
                isCarrying = true
            end
        end)

        carryWeldConnection = char.ChildRemoved:Connect(function(child)
            if child.Name == "CarryWeld" then
                isCarrying = false
            end
        end)
    end
end

function CarryPlayers.start()
    if started then
        return
    end
    started = true

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        setupCarryWeldListener()
    end)

    task.wait(1)
    setupCarryWeldListener()
end

return CarryPlayers
