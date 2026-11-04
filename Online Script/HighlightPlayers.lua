local HighlightPlayers = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local playerHighlights = {}
local highlightConnection = nil
local isEnabled = false
local Fluent = nil
local Options = nil

local function isPlayerDowned(player)
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    
    local playerModel = playersFolder:FindFirstChild(player.Name)
    if not playerModel then return false end
    
    local humanoid = playerModel:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid.Health <= 0
    end
    
    return false
end

-- ★ Модель для подсветки берем из workspace.Rigs
local function getRigsModel(player)
    local rigsFolder = workspace:FindFirstChild("Rigs")
    if not rigsFolder then return nil end
    
    return rigsFolder:FindFirstChild(player.Name)
end

local function updatePlayerHighlight(player)
    if not player or player == LocalPlayer then return end
    if not isEnabled then return end
    
    local rigsModel = getRigsModel(player)
    if not rigsModel then return end
    
    local isDowned = isPlayerDowned(player)
    
    if playerHighlights[player] then
        local highlight = playerHighlights[player]
        if highlight and highlight.Parent then
            highlight.FillColor = isDowned and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
            highlight.OutlineColor = isDowned and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(200, 200, 200)
            return
        else
            playerHighlights[player] = nil
        end
    end
    
    -- Создаем новую подсветку в модели из Rigs
    local highlight = Instance.new("Highlight")
    highlight.Name = "DraconicHighlight_" .. player.Name
    highlight.Parent = rigsModel
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = isDowned and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = isDowned and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(200, 200, 200)
    
    playerHighlights[player] = highlight
end

local function removePlayerHighlight(player)
    if playerHighlights[player] then
        local highlight = playerHighlights[player]
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        playerHighlights[player] = nil
    end
end

local function clearAllHighlights()
    for player, highlight in pairs(playerHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    playerHighlights = {}
end

local function updateAllHighlights()
    if not isEnabled then return end
    
    local currentPlayers = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            currentPlayers[player] = true
            updatePlayerHighlight(player)
        end
    end
    
    -- Удаляем подсветку, если игрок вышел
    for player in pairs(playerHighlights) do
        if not currentPlayers[player] then
            removePlayerHighlight(player)
        end
    end
end

function HighlightPlayers.init(fluentLib, options)
    Fluent = fluentLib
    Options = options
end

function HighlightPlayers.Start()
    if isEnabled then return end
    isEnabled = true
    
    updateAllHighlights()
    
    if highlightConnection then
        highlightConnection:Disconnect()
    end
    
    highlightConnection = RunService.Heartbeat:Connect(function()
        if isEnabled then
            updateAllHighlights()
        end
    end)
    
    if Fluent then
        Fluent:Notify({ Title = "Highlight Players", Content = "Enabled", Duration = 3 })
    end
end

function HighlightPlayers.Stop()
    if not isEnabled then return end
    isEnabled = false
    
    if highlightConnection then
        highlightConnection:Disconnect()
        highlightConnection = nil
    end
    
    clearAllHighlights()
    
    if Fluent then
        Fluent:Notify({ Title = "Highlight Players", Content = "Disabled", Duration = 3 })
    end
end

function HighlightPlayers.Toggle()
    if isEnabled then
        HighlightPlayers.Stop()
    else
        HighlightPlayers.Start()
    end
    return isEnabled
end

function HighlightPlayers.IsEnabled()
    return isEnabled
end

function HighlightPlayers.Refresh()
    if isEnabled then
        updateAllHighlights()
    end
end

return HighlightPlayers
