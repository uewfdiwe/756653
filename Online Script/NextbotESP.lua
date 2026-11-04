-- NextbotESP_Optimized.lua
-- Optimized external Nextbot ESP for URL loadstring usage.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local SCAN_INTERVAL = 0.12
local DIST_UPDATE_INTERVAL = 0.24
local STALE_TIMEOUT = 8

local nextbotBillboards = {}
local nextbotLoop = nil
local scanAccumulator = 0
local distAccumulator = 0
local localHrp = nil
local localHrpRefreshAccumulator = 0
local LOCAL_HRP_REFRESH_INTERVAL = 0.5

_G.NextbotESPRunning = false

local function isNextbotPlayer(model)
    if not model or not model:IsA("Model") or not model.Name then
        return false
    end
    
    -- Проверяем, находится ли модель в workspace.Players
    local parent = model.Parent
    if not parent or parent.Name ~= "Players" or parent.Parent ~= Workspace then
        return false
    end
    
    -- Проверяем атрибут Team
    local team = model:GetAttribute("Team")
    if team == "Nextbot" then
        return true
    end
    
    return false
end

local function getDistance(targetPosition)
    if not localHrp or not localHrp.Parent then
        local character = LocalPlayer.Character
        localHrp = character and character:FindFirstChild("HumanoidRootPart")
    end

    if not localHrp then
        return 0
    end
    return math.floor((targetPosition - localHrp.Position).Magnitude)
end

local function getAnchorWorldPosition(anchor)
    if not anchor then
        return nil
    end

    if anchor:IsA("Attachment") then
        return anchor.WorldPosition
    end

    if anchor:IsA("BasePart") then
        return anchor.Position
    end

    return nil
end

local function resolveAnchor(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then
        local attachment = hrp:FindFirstChild("ESP_Attachment")
        if not attachment then
            attachment = Instance.new("Attachment")
            attachment.Name = "ESP_Attachment"
            attachment.Parent = hrp
        end
        return attachment, true
    end

    return nil, false
end

local function createEsp(part)
    local gui = Instance.new("BillboardGui")
    gui.Name = "NextbotESP"
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 200, 0, 50)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.MaxDistance = 1000
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.Name = "ESPText"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.RobotoMono
    label.TextStrokeTransparency = 0.5
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.Text = "Loading..."
    label.Parent = gui

    return gui, label
end

local function clearAll()
    for model, data in pairs(nextbotBillboards) do
        if data.gui and data.gui.Parent then
            data.gui:Destroy()
        end
        if data.fakeAnchor and data.anchor and data.anchor.Parent then
            data.anchor:Destroy()
        end
        nextbotBillboards[model] = nil
    end
end

local function collectCandidates()
    local result = {}

    local playersFolder = Workspace:FindFirstChild("Players")
    if playersFolder then
        for _, model in ipairs(playersFolder:GetChildren()) do
            if isNextbotPlayer(model) then
                result[model] = true
            end
        end
    end

    return result
end

local function updateLabelsDistanceOnly()
    for model, data in pairs(nextbotBillboards) do
        if model and model.Parent and data.anchor and data.anchor.Parent and data.label then
            local worldPos = getAnchorWorldPosition(data.anchor)
            if worldPos then
                local newText = string.format("%s - [%dm]", model.Name, getDistance(worldPos))
                if data.label.Text ~= newText then
                    data.label.Text = newText
                end
            end
        end
    end
end

local function fullScanAndSync()
    local now = tick()
    local candidates = collectCandidates()

    for model in pairs(candidates) do
        local data = nextbotBillboards[model]
        if not data then
            local anchor, fakeAnchor = resolveAnchor(model)
            if anchor then
                local gui, label = createEsp(anchor)
                nextbotBillboards[model] = {
                    anchor = anchor,
                    fakeAnchor = fakeAnchor,
                    gui = gui,
                    label = label,
                    lastSeen = now
                }
            end
        else
            data.lastSeen = now
            local freshAnchor = select(1, resolveAnchor(model))
            if freshAnchor and freshAnchor ~= data.anchor then
                data.anchor = freshAnchor
                if data.gui then
                    if data.gui.Adornee ~= freshAnchor then
                        data.gui.Adornee = freshAnchor
                    end
                    if data.gui.Parent ~= freshAnchor then
                        data.gui.Parent = freshAnchor
                    end
                end
            end
        end
    end

    for model, data in pairs(nextbotBillboards) do
        if not candidates[model] or not model.Parent or (now - (data.lastSeen or 0) > STALE_TIMEOUT) then
            if data.gui and data.gui.Parent then
                data.gui:Destroy()
            end
            if data.fakeAnchor and data.anchor and data.anchor.Parent then
                data.anchor:Destroy()
            end
            nextbotBillboards[model] = nil
        end
    end

    updateLabelsDistanceOnly()
end

local function start()
    if nextbotLoop then
        _G.NextbotESPRunning = true
        return true
    end

    _G.NextbotESPRunning = true
    scanAccumulator = 0
    distAccumulator = 0
    localHrp = nil
    localHrpRefreshAccumulator = 0

    nextbotLoop = RunService.Heartbeat:Connect(function(dt)
        if not _G.NextbotESPRunning then
            return
        end

        local delta = dt or 0
        scanAccumulator = scanAccumulator + delta
        distAccumulator = distAccumulator + delta
        localHrpRefreshAccumulator = localHrpRefreshAccumulator + delta

        if localHrpRefreshAccumulator >= LOCAL_HRP_REFRESH_INTERVAL then
            localHrpRefreshAccumulator = 0
            local character = LocalPlayer.Character
            localHrp = character and character:FindFirstChild("HumanoidRootPart")
        end

        if scanAccumulator >= SCAN_INTERVAL then
            scanAccumulator = 0
            fullScanAndSync()
        elseif distAccumulator >= DIST_UPDATE_INTERVAL then
            distAccumulator = 0
            updateLabelsDistanceOnly()
        end
    end)

    task.spawn(function()
        for _ = 1, 2 do
            fullScanAndSync()
            task.wait(0.08)
        end
    end)

    return true
end

local function stop()
    _G.NextbotESPRunning = false
    if nextbotLoop then
        nextbotLoop:Disconnect()
        nextbotLoop = nil
    end
    localHrp = nil
    clearAll()
    return true
end

_G.StopNextbotESP = stop

return {
    Start = start,
    Stop = stop,
    ClearAll = clearAll,
    IsRunning = function()
        return _G.NextbotESPRunning == true
    end
}
