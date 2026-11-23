local PlayerTracer = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local elements = {}
local connection = nil

local function createTracer()
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.ZIndex = 1
    return tracer
end

local function update()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                currentTargets[player] = true

                if not elements[player] then
                    elements[player] = createTracer()
                end

                local tracer = elements[player]
                local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    tracer.Visible = true
                    tracer.From = screenBottomCenter
                    tracer.To = Vector2.new(vector.X, vector.Y)
                    tracer.Color = Color3.fromRGB(255, 255, 255)
                else
                    tracer.Visible = false
                end
            end
        end
    end

    for player, tracer in pairs(elements) do
        if not currentTargets[player] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            elements[player] = nil
        end
    end
end

function PlayerTracer.Start()
    if connection then return end
    connection = RunService.RenderStepped:Connect(update)
end

function PlayerTracer.Stop()
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

return PlayerTracer
