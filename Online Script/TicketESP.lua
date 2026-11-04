local TicketESP = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UPDATE_INTERVAL = 0.2
local COLOR = Color3.fromRGB(255, 165, 0)
local MAX_DISTANCE = 2000
local LABEL = "Ticket"

local instances = {}
local connection = nil
local accumulator = 0
local running = false
local folderConnections = nil

local function getFolder()
    local effects = workspace:FindFirstChild("Effects")
    if not effects then return nil end
    return effects:FindFirstChild("Tickets")
end

local function resolvePart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    return inst:FindFirstChild("HumanoidRootPart")
        or inst.PrimaryPart
        or inst:FindFirstChildWhichIsA("BasePart")
end

local function getName(inst)
    local attr = inst:GetAttribute("Name") or inst:GetAttribute("TicketName")
    if attr and tostring(attr) ~= "" then
        return tostring(attr)
    end
    local nameVal = inst:FindFirstChild("Name")
    if nameVal and nameVal:IsA("StringValue") and nameVal.Value ~= "" then
        return nameVal.Value
    end
    return LABEL
end

local function destroy(inst)
    local gui = instances[inst]
    if gui and gui.Parent then
        gui:Destroy()
    end
    instances[inst] = nil
end

local function clearAll()
    for inst, gui in pairs(instances) do
        if gui and gui.Parent then
            gui:Destroy()
        end
        instances[inst] = nil
    end
end

local function create(inst)
    local targetPart = resolvePart(inst)
    if not targetPart then return end

    destroy(inst)

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TicketESP"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = MAX_DISTANCE
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard.Parent = playerGui or targetPart

    local label = Instance.new("TextLabel")
    label.Name = "ESPText"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s - [?m]", getName(inst))
    label.TextColor3 = COLOR
    label.TextSize = 14
    label.Font = Enum.Font.RobotoMono
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Parent = billboard

    instances[inst] = billboard
end

local function updateAll()
    if not running then return end

    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

    for inst, gui in pairs(instances) do
        if not inst or not inst.Parent or not gui or not gui.Parent then
            destroy(inst)
        else
            local targetPart = resolvePart(inst)
            if targetPart then
                if gui.Adornee ~= targetPart then
                    gui.Adornee = targetPart
                end

                local label = gui:FindFirstChild("ESPText")
                if label then
                    local metersText = "?m"
                    if myRoot then
                        local distance = math.floor((targetPart.Position - myRoot.Position).Magnitude)
                        metersText = string.format("%dm", distance)
                    end

                    local newText = string.format("%s - [%s]", getName(inst), metersText)
                    if label.Text ~= newText then
                        label.Text = newText
                    end
                end
            end
        end
    end

    local folder = getFolder()
    if folder then
        for _, inst in ipairs(folder:GetChildren()) do
            if resolvePart(inst) and not instances[inst] then
                create(inst)
            end
        end
    end
end

local function bindFolder()
    if folderConnections then return end
    local folder = getFolder()
    if not folder then return end

    local added = folder.ChildAdded:Connect(function(inst)
        if running then
            task.wait(0.1)
            if running then
                create(inst)
            end
        end
    end)

    local removed = folder.ChildRemoved:Connect(function(inst)
        destroy(inst)
    end)

    folderConnections = {added, removed}
end

local function unbindFolder()
    if not folderConnections then return end
    for _, conn in ipairs(folderConnections) do
        if conn then conn:Disconnect() end
    end
    folderConnections = nil
end

function TicketESP.start()
    if running then return end
    running = true

    local folder = getFolder()
    if folder then
        for _, inst in ipairs(folder:GetChildren()) do
            create(inst)
        end
    end

    bindFolder()

    accumulator = 0
    connection = RunService.Heartbeat:Connect(function(dt)
        accumulator = accumulator + (dt or 0)
        if accumulator < UPDATE_INTERVAL then return end
        accumulator = 0
        updateAll()
    end)
end

function TicketESP.stop()
    if not running then return end
    running = false

    if connection then
        connection:Disconnect()
        connection = nil
    end

    unbindFolder()
    clearAll()
end

return TicketESP
