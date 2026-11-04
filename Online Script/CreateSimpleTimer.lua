local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StatsService = game:GetService("Stats")

local themeAccent = Color3.fromRGB(255, 0, 0)
local themeStroke = Color3.fromRGB(139, 0, 0)
local themeFill = nil
local hovered = false
local currentGradient = nil
local currentStroke = nil

local function makeGradient(color)
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, color)
    }
end

local function currentFill()
    if themeFill then
        return themeFill
    end
    return makeGradient(themeAccent)
end

local function lighten(color, amount)
    return Color3.new(
        color.R + (1 - color.R) * amount,
        color.G + (1 - color.G) * amount,
        color.B + (1 - color.B) * amount
    )
end

local function applyCurrentTheme()
    if not currentGradient or not currentStroke then
        return
    end
    if hovered then
        local hoverColor = lighten(themeAccent, 0.2)
        currentStroke.Color = hoverColor
        local source = currentFill()
        local keys = table.create(#source.Keypoints)
        for index, keypoint in ipairs(source.Keypoints) do
            keys[index] = ColorSequenceKeypoint.new(keypoint.Time, lighten(keypoint.Value, 0.12))
        end
        currentGradient.Color = ColorSequence.new(keys)
    else
        currentStroke.Color = themeStroke
        currentGradient.Color = currentFill()
    end
end

local function setThemeColor(accent, stroke, fill)
    if typeof(accent) == "Color3" then
        themeAccent = accent
    end
    if typeof(stroke) == "Color3" then
        themeStroke = stroke
    else
        themeStroke = Color3.new(themeAccent.R * 0.545, themeAccent.G * 0.545, themeAccent.B * 0.545)
    end
    themeFill = typeof(fill) == "ColorSequence" and fill or nil
    applyCurrentTheme()
end

local function createSimpleTimer()
    local LocalPlayer = Players.LocalPlayer

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DraconicFPS"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 165, 0, 48)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 0.7
    mainFrame.Parent = container

    local backgroundGradient = Instance.new("UIGradient")
    backgroundGradient.Color = currentFill()
    backgroundGradient.Rotation = 0
    backgroundGradient.Parent = mainFrame
    currentGradient = backgroundGradient

    local gradientAnimation
    gradientAnimation = RunService.RenderStepped:Connect(function(delta)
        backgroundGradient.Rotation = (backgroundGradient.Rotation + 90 * delta) % 360
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Color = themeStroke
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    currentStroke = stroke
    hovered = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(1, -8, 1, -8)
    textFrame.Position = UDim2.new(0, 4, 0, 4)
    textFrame.BackgroundTransparency = 1
    textFrame.Parent = mainFrame

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    local statsText = Instance.new("TextLabel")
    statsText.Size = UDim2.new(1, -10, 0.5, 0)
    statsText.Position = UDim2.new(0, 5, 0, 0)
    statsText.BackgroundTransparency = 1
    statsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsText.Font = Enum.Font.GothamBold
    statsText.TextSize = 13
    statsText.TextXAlignment = Enum.TextXAlignment.Center
    statsText.Text = "FPS: 60 | Ping: 0ms"
    statsText.Parent = textFrame

    local timerText = Instance.new("TextLabel")
    timerText.Size = UDim2.new(1, -10, 0.5, 0)
    timerText.Position = UDim2.new(0, 5, 0.5, 0)
    timerText.BackgroundTransparency = 1
    timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    timerText.Font = Enum.Font.GothamBold
    timerText.TextSize = 13
    timerText.TextXAlignment = Enum.TextXAlignment.Center
    timerText.Text = "Time: 0h 0m 0s"
    timerText.Parent = textFrame

    mainFrame.MouseEnter:Connect(function()
        hovered = true
        applyCurrentTheme()
    end)

    mainFrame.MouseLeave:Connect(function()
        hovered = false
        applyCurrentTheme()
    end)

    local startTime = tick()
    local frameCount = 0
    local lastUpdate = tick()

    local function getPing()
        local ping = 0

        pcall(function()
            local networkStats = StatsService:FindFirstChild("Network")
            if networkStats then
                local serverStats = networkStats:FindFirstChild("ServerStatsItem")
                if serverStats then
                    ping = math.floor(serverStats:GetValue())
                end
            end
        end)

        if ping == 0 then
            pcall(function()
                local performanceStats = StatsService:FindFirstChild("PerformanceStats")
                if performanceStats then
                    local pingStat = performanceStats:FindFirstChild("Ping")
                    if pingStat then
                        ping = math.floor(pingStat:GetValue())
                    end
                end
            end)
        end

        if ping == 0 then
            ping = 50
        end

        return ping
    end

    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1

        local currentTime = tick()

        if currentTime - lastUpdate >= 0.5 then
            local currentFPS = math.floor(frameCount / (currentTime - lastUpdate))
            frameCount = 0
            lastUpdate = currentTime

            local ping = getPing()
            statsText.Text = string.format("FPS: %d | Ping: %dms", currentFPS, ping)
        end

        local elapsed = currentTime - startTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)

        timerText.Text = string.format("Time: %dh %dm %ds", hours, minutes, seconds)
    end)

    container.Destroying:Connect(function()
        if currentGradient == backgroundGradient then
            currentGradient = nil
            currentStroke = nil
            hovered = false
        end
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end)

    function screenGui:SetPosition(x, y)
        container.Position = UDim2.new(0, x, 0, y)
    end

    function screenGui:SetVisible(visible)
        screenGui.Enabled = visible
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not screenGui or not screenGui.Parent then
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)

    return screenGui
end

return {
    createSimpleTimer = createSimpleTimer,
    setThemeColor = setThemeColor,
}
