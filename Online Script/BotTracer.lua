local BotTracer = {}

local RunService = game:GetService("RunService")

local elements = {}
local connection = nil

local function createTracer()
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.ZIndex = 1
    return tracer
end

local function isNextbotModel(model)
    if not model or not model:IsA("Model") or not model.Name then
        return false
    end

    local parent = model.Parent
    if not parent or parent.Name ~= "Players" or parent.Parent ~= workspace then
        return false
    end

    return model:GetAttribute("Team") == "Nextbot"
end

local function update()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        for _, model in ipairs(playersFolder:GetChildren()) do
            if isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    currentTargets[model] = true

                    if not elements[model] then
                        elements[model] = createTracer()
                    end

                    local tracer = elements[model]
                    local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        tracer.Visible = true
                        tracer.From = screenBottomCenter
                        tracer.To = Vector2.new(vector.X, vector.Y)
                        tracer.Color = Color3.fromRGB(255, 0, 0)
                    else
                        tracer.Visible = false
                    end
                end
            end
        end
    end

    for model, tracer in pairs(elements) do
        if not currentTargets[model] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            elements[model] = nil
        end
    end
end

function BotTracer.Start()
    if connection then return end
    connection = RunService.RenderStepped:Connect(update)
end

function BotTracer.Stop()
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

return BotTracer
