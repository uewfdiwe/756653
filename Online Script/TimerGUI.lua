local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ServerStateRegistryService = require(ReplicatedStorage.Services.Data.ServerStateRegistryService)

local module = {}

local timerGui = nil
local timerLabel = nil
local statusLabel = nil
local updateConnection = nil
local backgroundAnimation = nil
local themeAccent = Color3.fromRGB(255, 0, 0)
local themeStroke = Color3.fromRGB(139, 0, 0)
local themeFill = nil
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

local function applyCurrentTheme()
    if currentGradient then
        currentGradient.Color = currentFill()
    end
    if currentStroke then
        currentStroke.Color = themeStroke
    end
end

function module.SetThemeColor(accent, stroke, fill)
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

local function formatTime(seconds)
    if not seconds or type(seconds) ~= "number" then return "0:00" end
    seconds = math.floor(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%d:%02d", minutes, remainingSeconds)
end

local function createTimerGUI()
    if timerGui then return end

    local oldGui = PlayerGui:FindFirstChild("MainInterface")
    if oldGui then oldGui:Destroy() end

    local MainInterface = Instance.new("ScreenGui")
    MainInterface.Name = "MainInterface"
    MainInterface.Parent = PlayerGui
    MainInterface.ResetOnSpawn = false
    MainInterface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainInterface.Enabled = true
    MainInterface.DisplayOrder = 2

    local TimerContainer = Instance.new("Frame")
    TimerContainer.Name = "TimerContainer"
    TimerContainer.Parent = MainInterface
    TimerContainer.AnchorPoint = Vector2.new(0.5, 0)
    TimerContainer.BackgroundTransparency = 1
    TimerContainer.Position = UDim2.new(0.5, 0, 0, 0)
    TimerContainer.Size = UDim2.new(1, 0, 1, 0)
    TimerContainer.Visible = true

    local AspectRatio = Instance.new("UIAspectRatioConstraint")
    AspectRatio.Parent = TimerContainer

    local SizeLimit = Instance.new("UISizeConstraint")
    SizeLimit.MaxSize = Vector2.new(900, 900)
    SizeLimit.Parent = TimerContainer

    local TimerDisplay = Instance.new("Frame")
    TimerDisplay.Name = "TimerDisplay"
    TimerDisplay.Parent = TimerContainer
    TimerDisplay.AnchorPoint = Vector2.new(0.5, 0.5)
    TimerDisplay.BackgroundTransparency = 1
    TimerDisplay.Position = UDim2.new(0.5, 0, 0.1, 0)
    TimerDisplay.Size = UDim2.new(0.3, 0, 0.1, 0)
    TimerDisplay.ZIndex = 10000

    local RoundedCorners = Instance.new("UICorner")
    RoundedCorners.CornerRadius = UDim.new(0, 12)
    RoundedCorners.Parent = TimerDisplay

    local BorderOutline = Instance.new("UIStroke")
    BorderOutline.Parent = TimerDisplay
    BorderOutline.Thickness = 2
    BorderOutline.Color = themeStroke
    BorderOutline.Transparency = 0.1

    local BackgroundFrame = Instance.new("Frame")
    BackgroundFrame.Name = "BackgroundFrame"
    BackgroundFrame.Parent = TimerDisplay
    BackgroundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundFrame.BackgroundTransparency = 0.7
    BackgroundFrame.BorderSizePixel = 0
    BackgroundFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    BackgroundFrame.ZIndex = 9998

    local BackgroundCorner = Instance.new("UICorner")
    BackgroundCorner.CornerRadius = UDim.new(0, 12)
    BackgroundCorner.Parent = BackgroundFrame

    local BackgroundGradient = Instance.new("UIGradient")
    BackgroundGradient.Color = currentFill()
    BackgroundGradient.Rotation = 0
    BackgroundGradient.Parent = BackgroundFrame
    currentGradient = BackgroundGradient
    currentStroke = BorderOutline

    backgroundAnimation = RunService.RenderStepped:Connect(function(delta)
        if BackgroundGradient and BackgroundGradient.Parent then
            BackgroundGradient.Rotation = (BackgroundGradient.Rotation + 90 * delta) % 360
        end
    end)

    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Parent = TimerDisplay
    StatusText.AnchorPoint = Vector2.new(0.5, 0.5)
    StatusText.BackgroundTransparency = 1
    StatusText.Position = UDim2.new(0.5, 0, 0.3, 0)
    StatusText.Size = UDim2.new(0.9, 0, 0.3, 0)
    StatusText.ZIndex = 10002
    StatusText.Font = Enum.Font.GothamBold
    StatusText.Text = "ROUND ACTIVE"
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusText.TextScaled = true
    StatusText.TextSize = 14
    StatusText.TextStrokeTransparency = 0.85
    StatusText.TextWrapped = true

    local TextGradient = Instance.new("UIGradient")
    TextGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220))
    }
    TextGradient.Rotation = 90
    TextGradient.Parent = StatusText

    local StatusBorder = Instance.new("UIStroke")
    StatusBorder.Parent = StatusText
    StatusBorder.Thickness = 1
    StatusBorder.Color = Color3.fromRGB(255, 255, 255)
    StatusBorder.Transparency = 0.7

    local CountdownText = Instance.new("TextLabel")
    CountdownText.Name = "CountdownText"
    CountdownText.Parent = TimerDisplay
    CountdownText.AnchorPoint = Vector2.new(0.5, 0.5)
    CountdownText.BackgroundTransparency = 1
    CountdownText.Position = UDim2.new(0.5, 0, 0.7, 0)
    CountdownText.Size = UDim2.new(0.9, 0, 0.5, 0)
    CountdownText.ZIndex = 10002
    CountdownText.Font = Enum.Font.GothamBold
    CountdownText.Text = "0:00"
    CountdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    CountdownText.TextScaled = true
    CountdownText.TextSize = 14
    CountdownText.TextStrokeTransparency = 0.85
    CountdownText.TextWrapped = true

    local TimerGradient = Instance.new("UIGradient")
    TimerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220))
    }
    TimerGradient.Rotation = 90
    TimerGradient.Parent = CountdownText

    local CountdownBorder = Instance.new("UIStroke")
    CountdownBorder.Parent = CountdownText
    CountdownBorder.Thickness = 1
    CountdownBorder.Color = Color3.fromRGB(255, 255, 255)
    CountdownBorder.Transparency = 0.7

    -- Drag
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function updatePosition(input)
        local delta = input.Position - dragStart
        TimerContainer.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    TimerDisplay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = TimerContainer.Position

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    TimerDisplay.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            updatePosition(input)
        end
    end)

    timerGui = MainInterface
    timerLabel = CountdownText
    statusLabel = StatusText

    local function updateTimer()
        local timeValue = ServerStateRegistryService:Get("Time") or 0
        local roundStatus = ServerStateRegistryService:Get("RoundStatus")

        timerLabel.Text = formatTime(timeValue)

        if timeValue <= 5 then
            timerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        if roundStatus == 2 then
            statusLabel.Text = "ROUND ACTIVE"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            statusLabel.Text = "INTERMISSION"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end

    updateConnection = RunService.Heartbeat:Connect(updateTimer)
    updateTimer()
end

function module.Start()
    createTimerGUI()
end

function module.Stop()
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    if backgroundAnimation then
        backgroundAnimation:Disconnect()
        backgroundAnimation = nil
    end
    if timerGui then
        timerGui:Destroy()
        timerGui = nil
    end
    timerLabel = nil
    statusLabel = nil
    currentGradient = nil
    currentStroke = nil
end

function module.IsRunning()
    return timerGui ~= nil
end

return module
