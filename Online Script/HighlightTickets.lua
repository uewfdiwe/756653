local HighlightTickets = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ticketHighlights = {}
local highlightConnection = nil
local isEnabled = false
local Fluent = nil
local Options = nil

local function getTicketsFolder()
    local effects = workspace:FindFirstChild("Effects")
    if not effects then return nil end
    return effects:FindFirstChild("Tickets")
end

local function resolveTicketPart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    return inst:FindFirstChild("HumanoidRootPart")
        or inst.PrimaryPart
        or inst:FindFirstChildWhichIsA("BasePart")
end

local function createTicketHighlight(ticket)
    local part = resolveTicketPart(ticket)
    if not part then return end
    
    if ticketHighlights[ticket] and ticketHighlights[ticket].Parent then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TicketHighlight"
    
    if ticket:IsA("Model") then
        highlight.Parent = ticket
    else
        highlight.Parent = part
        highlight.Adornee = part
    end
    
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    highlight.FillColor = Color3.fromRGB(255, 140, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 90, 0)
    
    ticketHighlights[ticket] = highlight
end

local function removeTicketHighlight(ticket)
    if ticketHighlights[ticket] then
        if ticketHighlights[ticket].Parent then
            ticketHighlights[ticket]:Destroy()
        end
        ticketHighlights[ticket] = nil
    end
end

local function clearAllHighlights()
    for ticket, highlight in pairs(ticketHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    ticketHighlights = {}
end

local function updateAllHighlights()
    if not isEnabled then return end
    
    local folder = getTicketsFolder()
    if not folder then
        if next(ticketHighlights) then
            clearAllHighlights()
        end
        return
    end
    
    local currentTickets = {}
    
    -- Добавляем подсветку новым билетам
    for _, ticket in ipairs(folder:GetChildren()) do
        currentTickets[ticket] = true
        createTicketHighlight(ticket)
    end
    
    -- Удаляем подсветку, если билет исчез
    for ticket in pairs(ticketHighlights) do
        if not currentTickets[ticket] or not ticket.Parent then
            removeTicketHighlight(ticket)
        end
    end
end

function HighlightTickets.init(fluentLib, options)
    Fluent = fluentLib
    Options = options
end

function HighlightTickets.Start()
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
        Fluent:Notify({ Title = "Highlight Tickets", Content = "Enabled", Duration = 3 })
    end
end

function HighlightTickets.Stop()
    if not isEnabled then return end
    isEnabled = false
    
    if highlightConnection then
        highlightConnection:Disconnect()
        highlightConnection = nil
    end
    
    clearAllHighlights()
    
    if Fluent then
        Fluent:Notify({ Title = "Highlight Tickets", Content = "Disabled", Duration = 3 })
    end
end

function HighlightTickets.Toggle()
    if isEnabled then
        HighlightTickets.Stop()
    else
        HighlightTickets.Start()
    end
    return isEnabled
end

function HighlightTickets.IsEnabled()
    return isEnabled
end

function HighlightTickets.Refresh()
    if isEnabled then
        updateAllHighlights()
    end
end

return HighlightTickets
