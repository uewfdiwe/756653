local RunService = game:GetService("RunService")

local themeAccent = Color3.fromRGB(255, 0, 0)
local themeStroke = Color3.fromRGB(139, 0, 0)
local themeFill = nil
local trackedButtons = {}

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

    for button, data in pairs(trackedButtons) do
        if not button.Parent then
            trackedButtons[button] = nil
        else
            data.gradient.Color = currentFill()
            data.stroke.Color = data.active and themeAccent or themeStroke
        end
    end
end

local function createGradientButton(parent, position, size, text, onClickCallback)
    local button = Instance.new("Frame")
    button.Name = "GradientBtn"
    button.BackgroundTransparency = 0.7
    button.Size = size
    button.Position = position
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button

    local gradient = Instance.new("UIGradient")
    gradient.Color = currentFill()
    gradient.Rotation = 0
    gradient.Parent = button

    local gradientAnimation
    gradientAnimation = RunService.RenderStepped:Connect(function(delta)
        gradient.Rotation = (gradient.Rotation + 90 * delta) % 360
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Color = themeStroke
    stroke.Thickness = 2
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Parent = button

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.ZIndex = 5
    clicker.Parent = button

    local data = {
        gradient = gradient,
        stroke = stroke,
        active = false,
    }
    trackedButtons[button] = data

    button.Destroying:Connect(function()
        trackedButtons[button] = nil
        if gradientAnimation then
            gradientAnimation:Disconnect()
        end
    end)

    local activeTouchId = nil
    local startPos = nil
    local startButtonPos = nil

    local function updateButtonPosition(touchPos)
        if not startPos or not startButtonPos then return end
        local delta = touchPos - startPos
        button.Position = UDim2.new(startButtonPos.X.Scale, startButtonPos.X.Offset + delta.X,
                                    startButtonPos.Y.Scale, startButtonPos.Y.Offset + delta.Y)
    end

    local function resetDrag()
        activeTouchId = nil
        startPos = nil
        startButtonPos = nil
        data.active = false
        stroke.Color = themeStroke
    end

    clicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local touchId = input.UserInputState

            if activeTouchId ~= nil then
                return
            end

            activeTouchId = touchId
            startPos = input.Position
            startButtonPos = button.Position

            data.active = true
            stroke.Color = themeAccent

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resetDrag()
                    connection:Disconnect()
                end
            end)

        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            if activeTouchId ~= nil then return end

            activeTouchId = "mouse"
            startPos = input.Position
            startButtonPos = button.Position

            data.active = true
            stroke.Color = themeAccent

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resetDrag()
                    connection:Disconnect()
                end
            end)
        end
    end)

    clicker.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if activeTouchId ~= nil then
                updateButtonPosition(input.Position)
            end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement then
            if activeTouchId ~= nil then
                updateButtonPosition(input.Position)
            end
        end
    end)

    return button, clicker, stroke
end

return {
    createGradientButton = createGradientButton,
    setThemeColor = setThemeColor,
}
