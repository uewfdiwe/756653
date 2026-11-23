local TicketTracer = {}

local RunService = game:GetService("RunService")

local COLOR = Color3.fromRGB(255, 165, 0)
local elements = {}
local connection = nil

local function createTracer()
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.ZIndex = 1
    return tracer
end

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

local function update()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    local folder = getFolder()
    if folder then
        for _, inst in ipairs(folder:GetChildren()) do
            local part = resolvePart(inst)
            if part then
                currentTargets[inst] = true

                if not elements[inst] then
                    elements[inst] = createTracer()
                end

                local tracer = elements[inst]
                local vector, onScreen = camera:WorldToViewportPoint(part.Position)

                if onScreen then
                    tracer.Visible = true
                    tracer.From = screenBottomCenter
                    tracer.To = Vector2.new(vector.X, vector.Y)
                    tracer.Color = COLOR
                else
                    tracer.Visible = false
                end
            end
        end
    end

    for inst, tracer in pairs(elements) do
        if not currentTargets[inst] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            elements[inst] = nil
        end
    end
end

function TicketTracer.Start()
    if connection then return end
    connection = RunService.RenderStepped:Connect(update)
end

function TicketTracer.Stop()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    for _, tracer in pairs(elements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    elements = {}
end

return TicketTracer
