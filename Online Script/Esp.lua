-- Esp_Optimized.lua
-- Optimized external Player ESP for URL loadstring usage.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local UPDATE_INTERVAL = 0.2
local espInstances = {}
local updateConnection = nil
local accumulator = 0

_G.ExternalESPRunning = true

local function clearAll()
    for player, gui in pairs(espInstances) do
        if gui and gui.Parent then
            gui:Destroy()
        end
        espInstances[player] = nil
    end
end

local function resolveTargetPart(character)
    if not character then
        return nil
    end

    return character:FindFirstChild("Head")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("HumanoidRootPart")
        or character.PrimaryPart
        or character:FindFirstChildWhichIsA("BasePart")
end

local function hideDefaultName(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
end

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character then return end
    local targetPart = resolveTargetPart(character)
    if not targetPart then return end

    hideDefaultName(character)

    local old = espInstances[player]
    if old and old.Parent then
        old:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ExternalPlayerESP"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1500
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard.Parent = targetPart

    local label = Instance.new("TextLabel")
    label.Name = "ESPText"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.RobotoMono
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Parent = billboard

    espInstances[player] = billboard
    return billboard
end

local function updateAll()
    if not _G.ExternalESPRunning then
        return
    end

    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

    for player, gui in pairs(espInstances) do
        if not player or not player.Parent or not player.Character or not gui or not gui.Parent then
            if gui then
                gui:Destroy()
            end
            espInstances[player] = nil
        else
            local character = player.Character
            local targetPart = resolveTargetPart(character)
            local label = gui:FindFirstChild("ESPText")
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            hideDefaultName(character)

            if targetPart and gui.Adornee ~= targetPart then
                gui.Adornee = targetPart
                if gui.Parent ~= targetPart then
                    gui.Parent = targetPart
                end
            end

            if targetPart and label and humanoid then
                local color = Color3.fromRGB(255, 255, 255)
                local suffix = ""
                local metersText = "?m"

                -- Проверяем здоровье Humanoid (0 = revives)
                if humanoid.Health <= 0 then
                    color = Color3.fromRGB(255, 255, 0)
                    suffix = " [Revives]"
                end

                if myRoot then
                    local distance = math.floor((targetPart.Position - myRoot.Position).Magnitude)
                    metersText = string.format("%dm", distance)
                end

                local newText = string.format("%s - [%s]%s", player.Name, metersText, suffix)
                if label.Text ~= newText then
                    label.Text = newText
                end
                if label.TextColor3 ~= color then
                    label.TextColor3 = color
                end
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and not espInstances[player] then
            createPlayerESP(player)
        end
    end
end

local function start()
    _G.ExternalESPRunning = true
    if updateConnection then
        return true
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createPlayerESP(player)
        end
    end

    accumulator = 0
    updateConnection = RunService.Heartbeat:Connect(function(dt)
        accumulator = accumulator + (dt or 0)
        if accumulator < UPDATE_INTERVAL then
            return
        end
        accumulator = 0
        updateAll()
    end)

    return true
end

local function stop()
    _G.ExternalESPRunning = false
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    clearAll()
end

_G.StopExternalESP = stop

Players.PlayerRemoving:Connect(function(player)
    local gui = espInstances[player]
    if gui then
        gui:Destroy()
        espInstances[player] = nil
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.ExternalESPRunning then
            createPlayerESP(player)
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    if _G.ExternalESPRunning then
        updateAll()
    end
end)

start()

return {
    Start = start,
    Stop = stop,
    ClearAll = clearAll,
    IsRunning = function()
        return _G.ExternalESPRunning == true
    end
}
