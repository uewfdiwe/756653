local module = {}

local Minimized = false
local Window
local FloatButton
local gui, button, topImage, backgroundImage

local REF_BUTTON_WIDTH = 120

local function playAudio()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://100955166524786"
    sound.Volume = 1
    sound.Parent = game:GetService("SoundService")

    sound.Ended:Connect(function()
        sound:Destroy()
    end)

    local success = pcall(function()
        sound:Play()
    end)

    if not success then
        sound:Destroy()
        return nil
    end

    return sound
end

local function ToggleMinimize()
    if Window then
        Window:Minimize()
        Minimized = true
        return true
    end
    return false
end

function module.init(fluentWindow)
    if gui and gui.Parent then
        warn("Floating button already initialized!")
        return module
    end

    Window = fluentWindow

    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui
    if player then
        playerGui = player:WaitForChild("PlayerGui")
    else
        warn("Player not found!")
        return module
    end

    gui = Instance.new("ScreenGui")
    gui.Name = "FloatingButtonGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    button = Instance.new("Frame")
    button.Name = "FloatingButton"
    button.Size = UDim2.new(0, 120, 0, 90)
    button.Position = UDim2.new(0.5, -75, 0.5, -75)
    button.BackgroundTransparency = 1
    button.Parent = gui

    topImage = Instance.new("ImageButton")
    topImage.Name = "TopAsset"
    topImage.Size = UDim2.new(0.5, 0, 0.600000024, 0)
    topImage.AnchorPoint = Vector2.new(0.5, 0.5)
    topImage.Position = UDim2.new(0.5, -230, 0.5, -71)
    topImage.BackgroundTransparency = 1
    topImage.Image = "rbxassetid://102225156206159"
    topImage.ZIndex = 2
    topImage.Parent = button
    topImage.Draggable = true

    FloatButton = topImage

    FloatButton.MouseButton1Click:Connect(function()
        local minimized = ToggleMinimize()
        if minimized then
            playAudio()
        end
    end)

    if Window then
        Window.MinimizeToggle = ToggleMinimize
    end

    backgroundImage = Instance.new("ImageLabel")
    backgroundImage.Name = "SpinningBackground"
    backgroundImage.Size = UDim2.new(1, 0, 1, 10)
    backgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
    backgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    backgroundImage.BackgroundTransparency = 1
    backgroundImage.Image = "rbxassetid://116363566728532"
    backgroundImage.ZIndex = 1
    backgroundImage.Parent = topImage
    backgroundImage.Interactable = false

    local backgroundScale = Instance.new("UIScale")
    backgroundScale.Scale = 2
    backgroundScale.Parent = backgroundImage

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = topImage

    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    local RunService = game:GetService("RunService")
    local connection
    connection = RunService.RenderStepped:Connect(function(deltaTime)
        if backgroundImage and backgroundImage.Parent then
            backgroundImage.Rotation = (backgroundImage.Rotation + (100 * deltaTime)) % 360
        else
            if connection then
                connection:Disconnect()
            end
        end
    end)

    print("Floating button initialized successfully!")
    return module
end

--- Width in pixels (80–400). Uses UIScale on root frame; base layout width 120.
function module.setSize(widthPx)
    if not button then
        return false
    end
    local n = tonumber(widthPx)
    if not n then
        n = REF_BUTTON_WIDTH
    end
    n = math.max(80, math.min(n, 400))
    local uiScale = button:FindFirstChild("FloatingBtnUIScale")
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Name = "FloatingBtnUIScale"
        uiScale.Parent = button
    end
    uiScale.Scale = n / REF_BUTTON_WIDTH
    return true
end

--- Hide icon and spinner visuals; ImageButton stays clickable.
function module.setStealth(enabled)
    if not topImage then
        return false
    end
    topImage.ImageTransparency = enabled and 1 or 0
    if backgroundImage then
        backgroundImage.ImageTransparency = enabled and 1 or 0
    end
    return true
end

function module.destroy()
    if gui then
        gui:Destroy()
        gui = nil
    end
    button = nil
    topImage = nil
    backgroundImage = nil
    FloatButton = nil
    print("Floating button destroyed")
    return true
end

function module.getButton()
    return button
end

function module.getGUI()
    return gui
end

function module.isMinimized()
    return Minimized
end

function module.playSound()
    return playAudio()
end

function module.toggleMinimize()
    return ToggleMinimize()
end

function module.setWindowPosition(x, y)
    if button then
        button.Position = UDim2.new(x, 0, y, 0)
        return true
    end
    return false
end

function module.getWindowPosition()
    if button then
        return button.Position
    end
    return nil
end

return module
