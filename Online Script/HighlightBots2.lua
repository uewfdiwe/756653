local HighlightBots = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local botHighlights = {}
local botWatchers = {}
local highlightConnection = nil
local isEnabled = false
local Fluent = nil
local Options = nil

local SCAN_INTERVAL = 0.5
local scanAccumulator = 0

local originalTransparencies = setmetatable({}, { __mode = "k" })

local function isNextbotModel(model)
    if not model or not model:IsA("Model") then return false end
    
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    
    local playerModel = playersFolder:FindFirstChild(model.Name)
    if not playerModel then return false end
    
    return playerModel:GetAttribute("Team") == "Nextbot"
end

local function isHitboxPart(part)
    if not part or not part.Name then return false end
    
    local nameLower = part.Name:lower()
    return nameLower:find("hitbox") or 
           nameLower:find("hit") or 
           nameLower:find("collision") or
           nameLower:find("collide") or
           nameLower:find("damage") or
           nameLower:find("hurt") or
           nameLower:find("attack") or
           nameLower:find("body") or
           nameLower:find("root") or
           nameLower:find("torso") or
           nameLower:find("head") or
           nameLower:find("limb") or
           nameLower:find("arm") or
           nameLower:find("leg")
end

local function applyHitboxPart(part)
    if not part:IsA("BasePart") or not isHitboxPart(part) then return end

    if originalTransparencies[part] == nil then
        originalTransparencies[part] = part.Transparency
    end
    if part.Transparency ~= 0 then
        part.Transparency = 0
    end
    if part.CanQuery ~= true then
        part.CanQuery = true
    end
end

local function makeHitboxesVisible(model)
    if not model then return end

    for _, part in ipairs(model:GetDescendants()) do
        applyHitboxPart(part)
    end
end

local function watchBot(bot)
    if botWatchers[bot] then return end
    botWatchers[bot] = bot.DescendantAdded:Connect(function(desc)
        if isEnabled then
            applyHitboxPart(desc)
        end
    end)
end

local function unwatchBot(bot)
    local connection = botWatchers[bot]
    if connection then
        connection:Disconnect()
        botWatchers[bot] = nil
    end
end

local function restoreHitboxesTransparency(model)
    if not model then return end
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and originalTransparencies[part] then
            part.Transparency = originalTransparencies[part]
            originalTransparencies[part] = nil
        end
    end
end

function HighlightBots.init(fluentLib, options)
    Fluent = fluentLib
    Options = options
end

local function updateBotHighlight(bot)
    if not bot or not isEnabled then return end
    
    local hrp = bot:FindFirstChild("HumanoidRootPart") or 
                bot:FindFirstChild("Torso") or 
                bot:FindFirstChild("Head") or
                bot:FindFirstChildWhichIsA("BasePart")
    
    if not hrp then return end
    
    makeHitboxesVisible(bot)
    watchBot(bot)

    if botHighlights[bot] then
        local highlight = botHighlights[bot]
        if highlight and highlight.Parent then
            return
        else
            botHighlights[bot] = nil
        end
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "BotHighlight"
    highlight.Parent = bot
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
    
    botHighlights[bot] = highlight
end

local function removeBotHighlight(bot)
    unwatchBot(bot)
    restoreHitboxesTransparency(bot)
    
    if botHighlights[bot] then
        local highlight = botHighlights[bot]
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        botHighlights[bot] = nil
    end
end

local function clearAllHighlights()
    for bot in pairs(botWatchers) do
        unwatchBot(bot)
    end

    for bot in pairs(botHighlights) do
        restoreHitboxesTransparency(bot)
    end
    
    for bot, highlight in pairs(botHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    botHighlights = {}
end

local function findAllBots()
    local bots = {}
    
    local rigsFolder = workspace:FindFirstChild("Rigs")
    if rigsFolder then
        for _, model in ipairs(rigsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                table.insert(bots, model)
            end
        end
    end
    
    return bots
end

local function updateAllHighlights()
    if not isEnabled then return end
    
    local currentBots = {}
    local bots = findAllBots()
    
    for _, bot in ipairs(bots) do
        currentBots[bot] = true
        updateBotHighlight(bot)
    end
    
    for bot in pairs(botHighlights) do
        if not currentBots[bot] or not bot.Parent then
            removeBotHighlight(bot)
        end
    end
end

function HighlightBots.Start()
    if isEnabled then return end
    isEnabled = true
    
    originalTransparencies = setmetatable({}, { __mode = "k" })
    scanAccumulator = 0

    updateAllHighlights()

    if highlightConnection then
        highlightConnection:Disconnect()
    end

    highlightConnection = RunService.Heartbeat:Connect(function(dt)
        if not isEnabled then return end
        scanAccumulator = scanAccumulator + (dt or 0)
        if scanAccumulator < SCAN_INTERVAL then return end
        scanAccumulator = 0
        updateAllHighlights()
    end)
    
    if Fluent then
        Fluent:Notify({ Title = "Highlight Bots", Content = "Enabled", Duration = 3 })
    end
end

function HighlightBots.Stop()
    if not isEnabled then return end
    isEnabled = false
    
    if highlightConnection then
        highlightConnection:Disconnect()
        highlightConnection = nil
    end
    
    clearAllHighlights()
    
    if Fluent then
        Fluent:Notify({ Title = "Highlight Bots", Content = "Disabled", Duration = 3 })
    end
end

function HighlightBots.Toggle()
    if isEnabled then
        HighlightBots.Stop()
    else
        HighlightBots.Start()
    end
    return isEnabled
end

function HighlightBots.IsEnabled()
    return isEnabled
end

function HighlightBots.Refresh()
    if isEnabled then
        updateAllHighlights()
    end
end

return HighlightBots
