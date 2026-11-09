game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Draconic Hub",
    Text = "Welcome Draconic Hub Remake",
    Icon = "rbxassetid://102225156206159",
    Duration = 7
})
local Fluent = loadstring(game:HttpGet("https://github.com/uewfdiwe/756653/releases/download/Fluent/Fluent.lua"))()
local SaveManager = Fluent.SaveManager
local InterfaceManager = Fluent.InterfaceManager
local Window = Fluent:CreateWindow({
    Title = "Draconic-X-Remake",
    SubTitle = "Made by Unknownproooolucky",
    TabWidth = 160,
    Tags = {
        { Text = " Evade Overhaul ", Color = Color3.fromRGB(211, 15, 40) },
    },
    Version = "Version 3.7 Beta",
    Size = UDim2.fromOffset(580, 460),
    Theme = "Blood Red",
    Search = true,
    SearchInHeader = true,
    TitleIcon = "rbxassetid://102225156206159",
    UserInfoTop = true,
    UserInfoTitle = "Hallowen Evade?",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

local FLOATING_BTN_URL = "https://raw.githubusercontent.com/uewfdiwe/756653/refs/heads/main/Online%20Script/FlyBytton.lua"
local GRADIENT_BUTTON_URL = "https://raw.githubusercontent.com/uewfdiwe/756653/refs/heads/main/Online%20Script/CreateGradientButton.lua"
local SIMPLE_TIMER_URL = "https://raw.githubusercontent.com/uewfdiwe/756653/refs/heads/main/Online%20Script/CreateSimpleTimer.lua"
local floatingBtnSource
pcall(function()
    if typeof(readfile) == "function" then
        floatingBtnSource = readfile("Online Script/FlyBytton.lua")
    end
end)
if type(floatingBtnSource) ~= "string" or #floatingBtnSource < 80 then
    floatingBtnSource = game:HttpGet(FLOATING_BTN_URL, true)
end
local FloatingButton = loadstring(floatingBtnSource)()
FloatingButton.init(Window)

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "solar/home-bold", Favoriteable = true })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "Draconic X Evade",
    Content = "System Loaded...",
    Duration = 3
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local gradientButtonSource
pcall(function()
    if typeof(readfile) == "function" then
        gradientButtonSource = readfile("Online Script/CreateGradientButton.lua")
    end
end)
if type(gradientButtonSource) ~= "string" or #gradientButtonSource < 80 then
    gradientButtonSource = game:HttpGet(GRADIENT_BUTTON_URL, true)
end
local gradientButtonModule = loadstring(gradientButtonSource)()
local createGradientButton = gradientButtonModule.createGradientButton

local simpleTimerSource
pcall(function()
    if typeof(readfile) == "function" then
        simpleTimerSource = readfile("Online Script/CreateSimpleTimer.lua")
    end
end)
if type(simpleTimerSource) ~= "string" or #simpleTimerSource < 80 then
    simpleTimerSource = game:HttpGet(SIMPLE_TIMER_URL, true)
end
local simpleTimerModule = loadstring(simpleTimerSource)()
local createSimpleTimer = simpleTimerModule.createSimpleTimer

local ONLINE_SCRIPT_BASE = "https://raw.githubusercontent.com/uewfdiwe/756653/refs/heads/main/Online%20Script/"

local function loadOnlineModule(fileName)
    local source
    pcall(function()
        if typeof(readfile) == "function" then
            source = readfile("Online Script/" .. fileName)
        end
    end)
    if type(source) ~= "string" or #source < 80 then
        source = game:HttpGet(ONLINE_SCRIPT_BASE .. fileName, true)
    end
    local module = loadstring(source)()
    assert(type(module) == "table", "invalid module: " .. fileName)
    return module
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer


local NextbotBillboards = {}
local nextbotLoop = nil
local playerLoop = nil

local ExternalESP = nil
local ExternalESPLoaded = false
local ExternalNextbotESP = nil
local ExternalNextbotESPLoaded = false

local playerTracerElements = {}
local botTracerElements = {}
local playerTracerConnection = nil
local botTracerConnection = nil

local function forceCleanAllESP()


    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            if obj.Name:find("ESP") or obj.Name:find("Nextbot") or obj.Name:find("Billboard") then
                obj:Destroy()
            end
        end
    end


    local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") or gui:IsA("TextLabel") then
                if gui.Name:find("ESP") or gui.Name:find("Nextbot") then
                    gui:Destroy()
                end
            end
        end
    end


    local coreGui = game:GetService("CoreGui")
    for _, gui in ipairs(coreGui:GetDescendants()) do
        if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
            if gui.Name:find("ESP") or gui.Name:find("Nextbot") then
                gui:Destroy()
            end
        end
    end


    pcall(function()
        local drawings = {}


        for _, v in pairs(getgenv() or {}) do
            if type(v) == "table" then

                if v.Visible ~= nil and v.Color ~= nil and v.Thickness ~= nil then
                    table.insert(drawings, v)
                end
            end
        end


        for _, drawing in ipairs(drawings) do
            if drawing.Remove then
                pcall(function() drawing:Remove() end)
            end
        end
    end)

end

function cleanUpOnlyPlayerESPObjects()
    local cleaned = 0


    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then

                for _, obj in pairs(player.Character:GetDescendants()) do
                    if obj:IsA("BillboardGui") then
                        local objName = obj.Name:lower()

                        if objName:find("esp") and 
                           not objName:find("nextbot") and 
                           not objName:find("npc") and
                           not objName:find("bot") and
                           not objName:find("enemy") then
                            obj:Destroy()
                            cleaned = cleaned + 1
                        end
                    end
                end
            end
        end
    end


    local guiContainers = {
        game:GetService("CoreGui"),
        LocalPlayer.PlayerGui
    }

    for _, container in pairs(guiContainers) do
        for _, gui in pairs(container:GetDescendants()) do
            if gui:IsA("BillboardGui") or gui:IsA("ScreenGui") then
                local guiName = gui.Name:lower()

                if (guiName:find("player") or guiName:find("esp")) and 
                   not guiName:find("nextbot") and 
                   not guiName:find("bot") then
                    gui:Destroy()
                    cleaned = cleaned + 1
                end
            end
        end
    end

    return cleaned
end

billboardSection = Tabs.Main:AddSection("Billboard ESP", "solar/eye-bold")


NextbotToggle = Tabs.Main:AddToggle("NextbotToggle", {
    Title = "ESP Nextbots",
    Default = false
})

NextbotToggle:OnChanged(function(value)
    if value then

        if not ExternalNextbotESPLoaded then
            local success, errorMsg = pcall(function()
                ExternalNextbotESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/uewfdiwe/756653/refs/heads/main/Online%20Script/NextbotESP.lua"))()
                ExternalNextbotESPLoaded = true

                _G.NextbotESPRunning = true

                if ExternalNextbotESP and ExternalNextbotESP.Start then
                    ExternalNextbotESP.Start()
                end

                Fluent:Notify({
                    Title = "ESP Nextbots",
                    Content = "External Nextbot ESP loaded and running!",
                    Duration = 3
                })
            end)

            if not success then
                Fluent:Notify({
                    Title = "ESP Nextbots Error",
                    Content = "Failed to load external Nextbot ESP: " .. tostring(errorMsg),
                    Duration = 5
                })
                Options.NextbotToggle:Set(false)
                return
            end
        else
            if ExternalNextbotESP and ExternalNextbotESP.Start then
                ExternalNextbotESP.Start()
            end
            _G.NextbotESPRunning = true
        end


        if not nextbotLoop then
            nextbotLoop = RunService.Heartbeat:Connect(function()
                if Options.NextbotToggle.Value then
                    if _G.NextbotESPRunning == false then
                        _G.NextbotESPRunning = true
                        if ExternalNextbotESP and ExternalNextbotESP.Start then
                            pcall(ExternalNextbotESP.Start)
                        end
                    end
                end
            end)
        end

    else

        if nextbotLoop then
            nextbotLoop:Disconnect()
            nextbotLoop = nil
        end


        if ExternalNextbotESP and ExternalNextbotESPLoaded then
            if ExternalNextbotESP.Stop then
                pcall(function()
                    ExternalNextbotESP.Stop()
                end)
            end
        end


        task.spawn(function()
            task.wait(0.2)


            for model, data in pairs(NextbotBillboards) do
                if data.esp and data.esp:IsDescendantOf(game) then
                    local espName = data.esp.Name:lower()
                    if espName:find("nextbot") or espName:find("bot") or espName:find("npc") then
                        data.esp:Destroy()
                    end
                end
            end
            NextbotBillboards = {}


            for model, tracer in pairs(botTracerElements) do
                if tracer and tracer.Remove then
                    pcall(function()
                        tracer:Remove()
                    end)
                end
            end
            botTracerElements = {}


            pcall(function()
                for _, drawing in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
                    if drawing:IsA("BillboardGui") and drawing.Name:find("Nextbot") then
                        drawing:Destroy()
                    end
                end


                for _, obj in pairs(getgc(true)) do
                    if type(obj) == "table" then
                        if obj.__type and obj.__type == "Drawing" and obj.Color then

                            if obj.Color.r == 1 and obj.Color.g == 0 and obj.Color.b == 0 then
                                if obj.Remove then
                                    pcall(obj.Remove, obj)
                                end
                            end
                        end
                    end
                end
            end)
        end)


        ExternalNextbotESPLoaded = false
        _G.NextbotESPRunning = false

        Fluent:Notify({
            Title = "ESP Nextbots",
            Content = "Nextbot ESP disabled!",
            Duration = 3
        })
    end
end)

PlayerToggle = Tabs.Main:AddToggle("PlayerToggle", {
    Title = "ESP Players",
    Default = false
})

PlayerToggle:OnChanged(function(value)
    if value then

        cleanUpOnlyPlayerESPObjects()


        local nextbotESPActive = Options.NextbotToggle and Options.NextbotToggle.Value


        if not ExternalESPLoaded then
            local success, errorMsg = pcall(function()

                local espScript = game:HttpGet("https://raw.githubusercontent.com/uewfdiwe/756653/refs/heads/main/Online%20Script/Esp.lua", true)


                espScript = [[
                    if _G.PlayerESP_Loaded == true then
                        return
                    end
                    _G.PlayerESP_Loaded = true

                    local function cleanOldPlayerESP()
                        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                            if player ~= game:GetService("Players").LocalPlayer then
                                if player.Character then
                                    local esp = player.Character:FindFirstChild("PlayerESP")
                                    if esp then
                                        esp:Destroy()
                                    end
                                end
                            end
                        end
                    end
                    cleanOldPlayerESP()

                ]] .. espScript

                ExternalESP = loadstring(espScript)()
                ExternalESPLoaded = true


                _G.ExternalESPRunning = true
                _G.PlayerESP_Loaded = true

                Fluent:Notify({
                    Title = "ESP Players",
                    Content = "Player ESP loaded!",
                    Duration = 3
                })
            end)

            if not success then
                Fluent:Notify({
                    Title = "ESP Players Error",
                    Content = "Failed to load ESP: " .. tostring(errorMsg),
                    Duration = 5
                })
                Options.PlayerToggle:Set(false)
                return
            end
        else

            _G.ExternalESPRunning = true
            _G.PlayerESP_Loaded = true
        end


        if nextbotESPActive then
            task.wait(0.5)
            if ExternalNextbotESP and ExternalNextbotESPLoaded and ExternalNextbotESP.Start then
                pcall(ExternalNextbotESP.Start)
            end
        end


        if not playerLoop then
            playerLoop = RunService.Heartbeat:Connect(function()
                if Options.PlayerToggle.Value then

                    local playerEspCount = 0

                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then

                            for _, obj in pairs(player.Character:GetDescendants()) do
                                if obj:IsA("BillboardGui") then
                                    local textLabels = obj:GetDescendants()
                                    local labelCount = 0
                                    for _, label in pairs(textLabels) do
                                        if label:IsA("TextLabel") then
                                            labelCount = labelCount + 1
                                        end
                                    end


                                    if labelCount > 3 then
                                        obj:Destroy()
                                        playerEspCount = playerEspCount + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

    else

        if playerLoop then
            playerLoop:Disconnect()
            playerLoop = nil
        end


        cleanUpOnlyPlayerESPObjects()


        if ExternalESP and ExternalESPLoaded then
            if type(ExternalESP) == "table" and ExternalESP.Stop then
                pcall(ExternalESP.Stop)
            end
        end


        _G.ExternalESPRunning = false
        _G.PlayerESP_Loaded = false
        ExternalESPLoaded = false

        Fluent:Notify({
            Title = "ESP Players",
            Content = "Player ESP disabled!",
            Duration = 3
        })
    end
end)

local TicketESP
TicketToggle = Tabs.Main:AddToggle("TicketToggle", {
    Title = "ESP Tickets",
    Default = false
})

TicketToggle:OnChanged(function(value)
    if value then
        if not TicketESP then
            local ok, result = pcall(loadOnlineModule, "TicketESP.lua")
            if not ok then
                Fluent:Notify({
                    Title = "ESP Tickets",
                    Content = "Failed to load TicketESP.lua",
                    Duration = 5
                })
                Options.TicketToggle:Set(false)
                return
            end
            TicketESP = result
        end
        TicketESP.start()
        Fluent:Notify({
            Title = "ESP Tickets",
            Content = "Ticket ESP enabled!",
            Duration = 3
        })
    else
        if TicketESP then
            TicketESP.stop()
        end
        Fluent:Notify({
            Title = "ESP Tickets",
            Content = "Ticket ESP disabled!",
            Duration = 3
        })
    end
end)

function isNextbotModel(model)
    if not model or not model:IsA("Model") or not model.Name then
        return false
    end

    local parent = model.Parent
    if not parent or parent.Name ~= "Players" or parent.Parent ~= workspace then
        return false
    end

    local team = model:GetAttribute("Team")
    if team == "Nextbot" then
        return true
    end

    return false
end

function getDistanceFromPlayer(targetPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return 0 
    end
    local distance = (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    return math.floor(distance)
end

function createTracerObject()
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.ZIndex = 1
    return tracer
end

function updatePlayerTracers()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                currentTargets[player] = true

                if not playerTracerElements[player] then
                    playerTracerElements[player] = createTracerObject()
                end

                local tracer = playerTracerElements[player]
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

    for player, tracer in pairs(playerTracerElements) do
        if not currentTargets[player] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            playerTracerElements[player] = nil
        end
    end
end

function updateBotTracers()
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

                    if not botTracerElements[model] then
                        botTracerElements[model] = createTracerObject()
                    end

                    local tracer = botTracerElements[model]
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

    for model, tracer in pairs(botTracerElements) do
        if not currentTargets[model] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            botTracerElements[model] = nil
        end
    end
end

function startPlayerTracers()
    if playerTracerConnection then return end
    playerTracerConnection = RunService.RenderStepped:Connect(updatePlayerTracers)
end

function stopPlayerTracers()
    if playerTracerConnection then
        playerTracerConnection:Disconnect()
        playerTracerConnection = nil
    end
    for player, tracer in pairs(playerTracerElements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    playerTracerElements = {}
end

function startBotTracers()
    if botTracerConnection then return end
    botTracerConnection = RunService.RenderStepped:Connect(updateBotTracers)
end

function stopBotTracers()
    if botTracerConnection then
        botTracerConnection:Disconnect()
        botTracerConnection = nil
    end
    for model, tracer in pairs(botTracerElements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    botTracerElements = {}
end

Tabs.Main:AddSection("Highlight ESP", "solar/magic-stick-bold")

local HighlightBots
do
    local ok, result = pcall(loadOnlineModule, "HighlightBots.lua")
    HighlightBots = ok and result or nil
    if not ok then
        warn("[Main] Failed to load HighlightBots.lua:", result)
        Fluent:Notify({
            Title = "Main",
            Content = "Failed to load HighlightBots.lua",
            Duration = 5
        })
    else
        HighlightBots.init(Fluent, Options)
    end
end

HighlightBotsToggle = Tabs.Main:AddToggle("HighlightBotsToggle", {
    Title = "Highlight Bots",
    Default = false,
    Callback = function(state)
        if HighlightBots then
            if state then
                HighlightBots.Start()
            else
                HighlightBots.Stop()
            end
        end
    end
})

local HighlightPlayers
do
    local ok, result = pcall(loadOnlineModule, "HighlightPlayers.lua")
    HighlightPlayers = ok and result or nil
    if not ok then
        warn("[Main] Failed to load HighlightPlayers.lua:", result)
        Fluent:Notify({
            Title = "Main",
            Content = "Failed to load HighlightPlayers.lua",
            Duration = 5
        })
    else
        HighlightPlayers.init(Fluent, Options)
    end
end

HighlightPlayersToggle = Tabs.Main:AddToggle("HighlightPlayersToggle", {
    Title = "Highlight Players",
    Default = false,
    Callback = function(state)
        if HighlightPlayers then
            if state then
                HighlightPlayers.Start()
            else
                HighlightPlayers.Stop()
            end
        end
    end
})

local HighlightTickets
do
    local ok, result = pcall(loadOnlineModule, "HighlightTickets.lua")
    HighlightTickets = ok and result or nil
    if not ok then
        warn("[Main] Failed to load HighlightTickets.lua:", result)
        Fluent:Notify({
            Title = "Main",
            Content = "Failed to load HighlightTickets.lua",
            Duration = 5
        })
    else
        HighlightTickets.init(Fluent, Options)
    end
end

HighlightTicketsToggle = Tabs.Main:AddToggle("HighlightTicketsToggle", {
    Title = "Highlight Tickets",
    Default = false,
    Callback = function(state)
        if HighlightTickets then
            if state then
                HighlightTickets.Start()
            else
                HighlightTickets.Stop()
            end
        end
    end
})

tracerSection = Tabs.Main:AddSection("Tracer ESP", "solar/routing-bold")


TracerPlayerToggle = Tabs.Main:AddToggle("TracerPlayerToggle", {
    Title = "Tracer Players",
    Default = false
})

TracerPlayerToggle:OnChanged(function(value)
    if value then
        startPlayerTracers()
    else
        stopPlayerTracers()
    end
end)


TracerBotToggle = Tabs.Main:AddToggle("TracerBotToggle", {
    Title = "Tracer Bots",
    Default = false
})

TracerBotToggle:OnChanged(function(value)
    if value then
        startBotTracers()
    else
        stopBotTracers()
    end
end)

local TicketTracer = {}
TicketTracer.__index = TicketTracer

TicketTracer.COLOR = Color3.fromRGB(255, 165, 0)

function TicketTracer.new()
    local self = setmetatable({}, TicketTracer)
    self.elements = {}
    self.connection = nil
    self.running = false
    return self
end

function TicketTracer:_getFolder()
    local effects = workspace:FindFirstChild("Effects")
    if not effects then return nil end
    return effects:FindFirstChild("Tickets")
end

function TicketTracer:_resolvePart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    return inst:FindFirstChild("HumanoidRootPart")
        or inst.PrimaryPart
        or inst:FindFirstChildWhichIsA("BasePart")
end

function TicketTracer:_update()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    local folder = self:_getFolder()
    if folder then
        for _, inst in ipairs(folder:GetChildren()) do
            local part = self:_resolvePart(inst)
            if part then
                currentTargets[inst] = true

                if not self.elements[inst] then
                    self.elements[inst] = createTracerObject()
                end

                local tracer = self.elements[inst]
                local vector, onScreen = camera:WorldToViewportPoint(part.Position)

                if onScreen then
                    tracer.Visible = true
                    tracer.From = screenBottomCenter
                    tracer.To = Vector2.new(vector.X, vector.Y)
                    tracer.Color = self.COLOR
                else
                    tracer.Visible = false
                end
            end
        end
    end

    for inst, tracer in pairs(self.elements) do
        if not currentTargets[inst] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            self.elements[inst] = nil
        end
    end
end

function TicketTracer:Start()
    if self.running then return end
    self.running = true
    self.connection = RunService.RenderStepped:Connect(function()
        self:_update()
    end)
end

function TicketTracer:Stop()
    if not self.running then return end
    self.running = false

    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end

    for inst, tracer in pairs(self.elements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    self.elements = {}
end

local TicketTracerInstance = TicketTracer.new()

TracerTicketToggle = Tabs.Main:AddToggle("TracerTicketToggle", {
    Title = "Tracer Tickets",
    Default = false
})

TracerTicketToggle:OnChanged(function(value)
    if value then
        TicketTracerInstance:Start()
    else
        TicketTracerInstance:Stop()
    end
end)

 modificationSection = Tabs.Main:AddSection("Respawn", "solar/restart-bold")

 local CharacterService = require(game:GetService("ReplicatedStorage").Services.Asset.CharacterService)

 AutoRespawnTypeDropdown = Tabs.Main:AddDropdown("AutoRespawnTypeDropdown", {
    Title = "Auto Respawn Type",
    Values = {"Spawnpoint", "Fake Revive"},
    Multi = false,
    Default = "Spawnpoint",
})

getgenv().lastSavedPosition = nil
getgenv().respawnActive = false
getgenv().doRevive = nil

local SelfReviveMethod = "Spawnpoint"

AutoRespawnTypeDropdown:OnChanged(function(value)
    SelfReviveMethod = value
end)

local function getLocalState()
    local char = CharacterService:GetLocalCharacter()
    if char and char.State then
        return char.State.State
    end
    return nil
end

local function getLocalHRP()
    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        local model = playersFolder:FindFirstChild(LocalPlayer.Name)
        if model then
            return model:FindFirstChild("HumanoidRootPart")
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    local hrp = getLocalHRP()
    if hrp then
        local state = getLocalState()
        if state and state ~= "Downed" then
            getgenv().lastSavedPosition = hrp.Position
        end
    end
end)

local function doSpawnpointRevive()
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.Session.SetPlayerMode:FireServer(true)
    end)
end

local function doFakeRevive()
    local savedPos = getgenv().lastSavedPosition
    if not savedPos then
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.Session.SetPlayerMode:FireServer(true)
        end)
        return
    end

    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.Session.SetPlayerMode:FireServer(true)
    end)

    task.wait(1)

    for i = 1, 50 do
        local hrp = getLocalHRP()
        if hrp and hrp:IsDescendantOf(workspace) then
            pcall(function()
                hrp.CFrame = CFrame.new(savedPos)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
            break
        end
        task.wait(0.1)
    end
end

local function doRevive()
    local state = getLocalState()
    if state ~= "Downed" then
        return false
    end

    if SelfReviveMethod == "Spawnpoint" then
        doSpawnpointRevive()
    elseif SelfReviveMethod == "Fake Revive" then
        doFakeRevive()
    end

    return true
end

getgenv().doRevive = doRevive

AutoRespawnToggle = Tabs.Main:AddToggle("AutoRespawnToggle", {
    Title = "Auto Respawn",
    Default = false,
    Callback = function(value)
        if value then
            if getgenv().respawnActive then return end
            getgenv().respawnActive = true
            task.spawn(function()
                while getgenv().respawnActive do
                    local state = getLocalState()
                    if state == "Downed" then
                        doRevive()
                    end
                    task.wait(0.1)
                end
            end)
        else
            getgenv().respawnActive = false
        end
    end
})

RespawnButton = Tabs.Main:AddButton({
    Title = "Respawn Button",
    Callback = function()
        local CoreGui = game:GetService("CoreGui")
        local LocalPlayer = game:GetService("Players").LocalPlayer

        local existingScreenGui = CoreGui:FindFirstChild("DraconicRespawnButtonGUI")

        if existingScreenGui then
            existingScreenGui:Destroy()
        else
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "DraconicRespawnButtonGUI"
            screenGui.ResetOnSpawn = false
            screenGui.Parent = CoreGui

            local buttonSize = 180
            if Options.RespawnButtonSizeInput and Options.RespawnButtonSizeInput.Value and tonumber(Options.RespawnButtonSizeInput.Value) then
                buttonSize = tonumber(Options.RespawnButtonSizeInput.Value)
            end

            local btnWidth = math.max(150, math.min(buttonSize, 400))
            local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))

            local btn, clicker, stroke = createGradientButton(
                screenGui,
                UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
                UDim2.new(0, btnWidth, 0, btnHeight),
                "RESPAWN"
            )

            clicker.MouseButton1Click:Connect(function()
                if getgenv().doRevive then
                    getgenv().doRevive()
                end
            end)
        end
    end
})

function manualRevive()
    if getgenv().doRevive then
        getgenv().doRevive()
    end
end


modificationSection = Tabs.Main:AddSection("Things", "solar/settings-bold")


local AntiAFKConnection = nil
local function startAntiAFK()
    if AntiAFKConnection then return end
    AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

local function stopAntiAFK()
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
end

 AntiAFKToggle = Tabs.Main:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = false
})

AntiAFKToggle:OnChanged(function(value)
    if value then
        startAntiAFK()
    else
        stopAntiAFK()
    end
end)


local autoWhistleThread = nil
local autoWhistleRunning = false

local function startAutoWhistle()
    if autoWhistleRunning then return end
    autoWhistleRunning = true

    autoWhistleThread = task.spawn(function()
        while autoWhistleRunning do
            if not AutoWhistleToggle.Value then
                autoWhistleRunning = false
                break
            end

            pcall(function()
                ReplicatedStorage.Events.Action:FireServer(3)
            end)

            task.wait(0.5)
        end
        autoWhistleRunning = false
        autoWhistleThread = nil
    end)
end

local function stopAutoWhistle()
    autoWhistleRunning = false
    if autoWhistleThread then
        task.cancel(autoWhistleThread)
        autoWhistleThread = nil
    end
end

 AutoWhistleToggle = Tabs.Main:AddToggle("AutoWhistleToggle", {
    Title = "Auto Whistle",
    Default = false
})

AutoWhistleToggle:OnChanged(function(value)
    if value then
        startAutoWhistle()
    else
        stopAutoWhistle()
    end
end)

local TimerModule = loadOnlineModule("TimerGUI.lua")

TimerDisplayToggle = Tabs.Main:AddToggle("TimerDisplayToggle", {
    Title = "Show Timer",
    Default = false,
    Callback = function(state)
        if state then
            TimerModule.Start()
        else
            TimerModule.Stop()
        end
    end
})

local billboardSection = Tabs.Main:AddSection("Player Modification", "solar/user-bold")

local FlyModule
do
    local ok, result = pcall(loadOnlineModule, "Fly.lua")
    FlyModule = ok and result or nil
    if not ok then
        warn("[Main] Failed to load Fly.lua:", result)
    end
end

FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Fly",
    Default = false
})

FlySpeedInput = Tabs.Main:AddInput("FlySpeedInput", {
    Title = "Fly Speed",
    Default = "50",
    Placeholder = "Enter speed value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) and FlyModule then
            FlyModule.setSpeed(tonumber(Value))
        end
    end
})

FlyToggle:OnChanged(function(state)
    if not FlyModule then
        Fluent:Notify({ Title = "Fly", Content = "Fly module not loaded", Duration = 4 })
        return
    end
    FlyModule.set(state)
end)

modificationSection = Tabs.Main:AddSection("Manual", "solar/hand-shake-bold")


local NoclipModule
do
    local ok, result = pcall(loadOnlineModule, "Noclip.lua")
    NoclipModule = ok and result or nil
    if ok then
        NoclipModule.init()
    else
        warn("[Main] Failed to load Noclip.lua:", result)
    end
end

NoclipToggle = Tabs.Main:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Default = false
})

NoclipToggle:OnChanged(function(value)
    if not NoclipModule then
        Fluent:Notify({ Title = "Noclip", Content = "Noclip module not loaded", Duration = 4 })
        return
    end
    NoclipModule.set(value)
    Fluent:Notify({
        Title = "Noclip",
        Content = value and "Noclip enabled" or "Noclip disabled",
        Duration = 2
    })
end)

local BugEmote
do
    local ok, result = pcall(loadOnlineModule, "BugEmote.lua")
    BugEmote = ok and result or nil
    if ok then
        BugEmote.init()
    else
        warn("[Main] Failed to load BugEmote.lua:", result)
    end
end

SitToggle = Tabs.Main:AddToggle("SitToggle", {
    Title = "Bug Emote",
    Default = false
})

SitToggle:OnChanged(function(state)
    if not BugEmote then
        Fluent:Notify({ Title = "Force Sit", Content = "BugEmote module not loaded", Duration = 4 })
        return
    end
    BugEmote.set(state)
    Fluent:Notify({
        Title = "Force Sit",
        Content = state and "Character will now sit continuously" or "Sit mode disabled",
        Duration = 2
    })
end)


local BarriersRemove, BarriersVisible
do
    local ok, result = pcall(loadOnlineModule, "BarriersRemove.lua")
    BarriersRemove = ok and result or nil
    if ok then
        BarriersRemove.init()
    else
        warn("[Main] Failed to load BarriersRemove.lua:", result)
    end

    ok, result = pcall(loadOnlineModule, "BarriersVisible.lua")
    BarriersVisible = ok and result or nil
    if ok then
        BarriersVisible.init()
    else
        warn("[Main] Failed to load BarriersVisible.lua:", result)
    end
end

NoCollisionToggle = Tabs.Main:AddToggle("NoCollisionToggle", {
    Title = "Remove Barriers",
    Default = false
})

NoCollisionToggle:OnChanged(function(state)
    if not BarriersRemove then
        Fluent:Notify({ Title = "Remove Barriers", Content = "BarriersRemove module not loaded", Duration = 4 })
        return
    end
    local _, msg = BarriersRemove.set(state)
    Fluent:Notify({ Title = "Remove Barriers", Content = msg, Duration = 3 })
end)

InvisPartsTransparencyToggle = Tabs.Main:AddToggle("InvisPartsTransparencyToggle", {
    Title = "Barriers Visible",
    Default = false
})

InvisPartsTransparencyToggle:OnChanged(function(state)
    if not BarriersVisible then
        Fluent:Notify({ Title = "Barriers Visible", Content = "BarriersVisible module not loaded", Duration = 4 })
        return
    end
    local _, msg = BarriersVisible.set(state)
    Fluent:Notify({
        Title = state and "Barriers Visible" or "Barriers Disable",
        Content = msg,
        Duration = 3
    })
end)

LeaderboardToggle = Tabs.Main:AddButton({
    Title = "Unlock Leaderboard; Zoom; Front View",
    Callback = function()
        local player = game.Players.LocalPlayer
        local guiService = game:GetService("GuiService")
        local starterGui = game:GetService("StarterGui")
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        local VirtualUser = game:GetService("VirtualUser")

        local playerGui = player:WaitForChild("PlayerGui")
        if playerGui:FindFirstChild("CustomTopGui") then
            playerGui.CustomTopGui:Destroy()
        end

        starterGui:SetCore("TopbarEnabled", false)

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CustomTopGui"
        screenGui.IgnoreGuiInset = false
        screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
        screenGui.DisplayOrder = 100
        screenGui.ResetOnSpawn = false
        screenGui.Parent = playerGui

        local frame = Instance.new("Frame")
        frame.Parent = screenGui
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Position = UDim2.new(0, 0, 0, 0)
        frame.Size = UDim2.new(1, 0, 1, -2)

        local scrollingFrame = Instance.new("ScrollingFrame")
        scrollingFrame.Name = "Right"
        scrollingFrame.Parent = frame
        scrollingFrame.BackgroundTransparency = 1
        scrollingFrame.BorderSizePixel = 0
        scrollingFrame.Position = UDim2.new(0, 12, 0, 0)
        scrollingFrame.Size = UDim2.new(1, -24, 1, 0)
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
        scrollingFrame.ScrollBarThickness = 0
        scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
        scrollingFrame.ScrollingEnabled = false

        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.Parent = scrollingFrame
        uiListLayout.Padding = UDim.new(0, 12)
        uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiListLayout.FillDirection = Enum.FillDirection.Horizontal
        uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

        -- ★ Теперь мы эмулируем РЕАЛЬНЫЕ клавиши, а не шлем строки на сервер
        local buttonsConfig = {
            {
                name = "SecondaryButton",
                layoutOrder = 999,
                icon = "rbxassetid://126943351764139",
                label = "Zoom",
                width = 100,
                labelWidth = 45,
                keyCode = Enum.KeyCode.Z -- Кнопка Z (Прицел)
            },
            {
                name = "ReloadButton",
                layoutOrder = 997,
                icon = "rbxassetid://78648212535999",
                label = "Front View / View",
                width = 173,
                labelWidth = 118,
                keyCode = Enum.KeyCode.V -- Кнопка V (Вид от первого лица / Смена плеча)
            },
            {
                name = "LeaderboardButton",
                layoutOrder = 998,
                icon = "rbxassetid://5107166345",
                label = "Leaderboard",
                width = 143,
                labelWidth = 88,
                keyCode = Enum.KeyCode.Tab -- Кнопка Tab (Таблица лидеров)
            }
        }

        for _, config in ipairs(buttonsConfig) do
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            local Button = Instance.new("Frame")
            Button.Name = config.name
            Button.Parent = scrollingFrame
            Button.BackgroundTransparency = 1
            Button.ClipsDescendants = true
            Button.LayoutOrder = config.layoutOrder
            Button.Size = UDim2.new(0, 44, 0, 44)
            Button.ZIndex = 20

            local IconButton = Instance.new("Frame")
            IconButton.Name = "IconButton"
            IconButton.Parent = Button
            IconButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            IconButton.BackgroundTransparency = 0.3
            IconButton.BorderSizePixel = 0
            IconButton.ClipsDescendants = true
            IconButton.Size = UDim2.new(1, 0, 1, 0)
            IconButton.ZIndex = 2

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = IconButton

            local Menu = Instance.new("ScrollingFrame")
            Menu.Name = "Menu"
            Menu.Parent = IconButton
            Menu.BackgroundTransparency = 1
            Menu.BorderSizePixel = 0
            Menu.Position = UDim2.new(0, 4, 0, 0)
            Menu.Selectable = false
            Menu.Size = UDim2.new(1, 0, 1, 0)
            Menu.ZIndex = 20
            Menu.BottomImage = ""
            Menu.CanvasSize = UDim2.new(0, 0, 1, -1)
            Menu.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
            Menu.ScrollBarThickness = 3
            Menu.TopImage = ""

            local MenuUIListLayout = Instance.new("UIListLayout")
            MenuUIListLayout.Name = "MenuUIListLayout"
            MenuUIListLayout.Parent = Menu
            MenuUIListLayout.FillDirection = Enum.FillDirection.Horizontal
            MenuUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            MenuUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            local MenuGap = Instance.new("Frame")
            MenuGap.Name = "MenuGap"
            MenuGap.Parent = Menu
            MenuGap.AnchorPoint = Vector2.new(0, 0.5)
            MenuGap.BackgroundTransparency = 1
            MenuGap.Size = UDim2.new(0, 4, 0, 0)
            MenuGap.Visible = false
            MenuGap.ZIndex = 5

            local IconSpot = Instance.new("Frame")
            IconSpot.Name = "IconSpot"
            IconSpot.Parent = Menu
            IconSpot.AnchorPoint = Vector2.new(0, 0.5)
            IconSpot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            IconSpot.BackgroundTransparency = 1
            IconSpot.Position = UDim2.new(0, 4, 0.5, 0)
            IconSpot.Size = UDim2.new(0, 36, 1, -8)
            IconSpot.ZIndex = 5

            local UICorner_2 = Instance.new("UICorner")
            UICorner_2.CornerRadius = UDim.new(1, 0)
            UICorner_2.Parent = IconSpot

            local IconOverlay = Instance.new("Frame")
            IconOverlay.Name = "IconOverlay"
            IconOverlay.Parent = IconSpot
            IconOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            IconOverlay.BackgroundTransparency = 0.925
            IconOverlay.Size = UDim2.new(1, 0, 1, 0)
            IconOverlay.Visible = false
            IconOverlay.ZIndex = 6

            local UICorner_3 = Instance.new("UICorner")
            UICorner_3.CornerRadius = UDim.new(1, 0)
            UICorner_3.Parent = IconOverlay

            local ClickRegion = Instance.new("TextButton")
            ClickRegion.Name = "ClickRegion"
            ClickRegion.Parent = IconSpot
            ClickRegion.BackgroundTransparency = 1
            ClickRegion.Size = UDim2.new(1, 0, 1, 0)
            ClickRegion.ZIndex = 20
            ClickRegion.Text = ""
            ClickRegion.Active = true
            ClickRegion.Selectable = true

            local UICorner_4 = Instance.new("UICorner")
            UICorner_4.CornerRadius = UDim.new(1, 0)
            UICorner_4.Parent = ClickRegion

            local Contents = Instance.new("Frame")
            Contents.Name = "Contents"
            Contents.Parent = IconSpot
            Contents.BackgroundTransparency = 1
            Contents.Size = UDim2.new(1, 0, 1, 0)

            local ContentsList = Instance.new("UIListLayout")
            ContentsList.Name = "ContentsList"
            ContentsList.Parent = Contents
            ContentsList.FillDirection = Enum.FillDirection.Horizontal
            ContentsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            ContentsList.SortOrder = Enum.SortOrder.LayoutOrder
            ContentsList.VerticalAlignment = Enum.VerticalAlignment.Center
            ContentsList.Padding = UDim.new(0, 3)

            local PaddingLeft = Instance.new("Frame")
            PaddingLeft.Name = "PaddingLeft"
            PaddingLeft.Parent = Contents
            PaddingLeft.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            PaddingLeft.BackgroundTransparency = 1
            PaddingLeft.BorderColor3 = Color3.fromRGB(0, 0, 0)
            PaddingLeft.BorderSizePixel = 0
            PaddingLeft.LayoutOrder = 1
            PaddingLeft.Size = UDim2.new(0, 9, 1, 0)
            PaddingLeft.ZIndex = 5

            local PaddingCenter = Instance.new("Frame")
            PaddingCenter.Name = "PaddingCenter"
            PaddingCenter.Parent = Contents
            PaddingCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            PaddingCenter.BackgroundTransparency = 1
            PaddingCenter.BorderColor3 = Color3.fromRGB(0, 0, 0)
            PaddingCenter.BorderSizePixel = 0
            PaddingCenter.LayoutOrder = 3
            PaddingCenter.Size = UDim2.new(0, 0, 1, 0)
            PaddingCenter.ZIndex = 5

            local PaddingRight = Instance.new("Frame")
            PaddingRight.Name = "PaddingRight"
            PaddingRight.Parent = Contents
            PaddingRight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            PaddingRight.BackgroundTransparency = 1
            PaddingRight.BorderColor3 = Color3.fromRGB(0, 0, 0)
            PaddingRight.BorderSizePixel = 0
            PaddingRight.LayoutOrder = 5
            PaddingRight.Size = UDim2.new(0, 11, 1, 0)
            PaddingRight.ZIndex = 5

            local IconLabelContainer = Instance.new("Frame")
            IconLabelContainer.Name = "IconLabelContainer"
            IconLabelContainer.Parent = Contents
            IconLabelContainer.AnchorPoint = Vector2.new(0, 0.5)
            IconLabelContainer.BackgroundTransparency = 1
            IconLabelContainer.LayoutOrder = 4
            IconLabelContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            IconLabelContainer.Size = UDim2.new(0, 0, 1, 0)
            IconLabelContainer.Visible = false
            IconLabelContainer.ZIndex = 3

            local IconLabel = Instance.new("TextLabel")
            IconLabel.Name = "IconLabel"
            IconLabel.Parent = IconLabelContainer
            IconLabel.BackgroundTransparency = 1
            IconLabel.LayoutOrder = 4
            IconLabel.Size = UDim2.new(0, 1306, 1, 0)
            IconLabel.ZIndex = 15
            IconLabel.Font = Enum.Font.GothamMedium
            IconLabel.Text = config.label
            IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            IconLabel.TextSize = 16
            IconLabel.TextWrapped = true
            IconLabel.TextXAlignment = Enum.TextXAlignment.Left
            IconLabel.Visible = false

            local IconImage = Instance.new("ImageLabel")
            IconImage.Name = "IconImage"
            IconImage.Parent = Contents
            IconImage.AnchorPoint = Vector2.new(0, 0.5)
            IconImage.BackgroundTransparency = 1
            IconImage.LayoutOrder = 2
            IconImage.Position = UDim2.new(0, 11, 0.5, 0)
            IconImage.Size = UDim2.new(0.7, 0, 0.7, 0)
            IconImage.ZIndex = 15
            IconImage.Image = config.icon

            local IconImageCorner = Instance.new("UICorner")
            IconImageCorner.CornerRadius = UDim.new(0, 0)
            IconImageCorner.Name = "IconImageCorner"
            IconImageCorner.Parent = IconImage

            local IconImageRatio = Instance.new("UIAspectRatioConstraint")
            IconImageRatio.Name = "IconImageRatio"
            IconImageRatio.Parent = IconImage
            IconImageRatio.DominantAxis = Enum.DominantAxis.Height

            local IconSpotGradient = Instance.new("UIGradient")
            IconSpotGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(96, 98, 100)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(77, 78, 80))
            }
            IconSpotGradient.Rotation = 45
            IconSpotGradient.Name = "IconSpotGradient"
            IconSpotGradient.Parent = IconSpot

            local IconGradient = Instance.new("UIGradient")
            IconGradient.Name = "IconGradient"
            IconGradient.Parent = IconButton

            local isHovering = false
            local currentTween = nil
            local hideDelay = 0.3
            
            local smallButtonSize = UDim2.new(0, 44, 0, 44)
            local largeButtonSize = UDim2.new(0, config.width, 0, 44)
            local smallIconSpotSize = UDim2.new(0, 36, 1, -8)
            local largeIconSpotSize = UDim2.new(0, config.width - 8, 1, -8)
            local smallLabelSize = UDim2.new(0, 0, 1, 0)
            local largeLabelSize = UDim2.new(0, config.labelWidth, 1, 0)

            local function hideTextWithDelay()
                task.wait(hideDelay)
                if not isHovering then
                    IconLabel.Visible = false
                    IconLabelContainer.Visible = false
                    IconOverlay.Visible = false
                end
            end

            local function expand()
                isHovering = true
                if currentTween then currentTween:Cancel() end
                
                IconLabel.Visible = true
                IconLabelContainer.Visible = true
                IconOverlay.Visible = true
                
                currentTween = TweenService:Create(Button, tweenInfo, {Size = largeButtonSize})
                currentTween:Play()
                
                TweenService:Create(IconSpot, tweenInfo, {Size = largeIconSpotSize}):Play()
                TweenService:Create(IconLabelContainer, tweenInfo, {Size = largeLabelSize}):Play()
            end

            local function contract()
                isHovering = false
                if currentTween then currentTween:Cancel() end
                
                currentTween = TweenService:Create(Button, tweenInfo, {Size = smallButtonSize})
                currentTween:Play()
                
                TweenService:Create(IconSpot, tweenInfo, {Size = smallIconSpotSize}):Play()
                TweenService:Create(IconLabelContainer, tweenInfo, {Size = smallLabelSize}):Play()
                
                hideTextWithDelay()
            end

            -- ★ НОВАЯ ЛОГИКА: Эмуляция нажатия клавиш (работает и на ПК, и на телефоне)
            local function simulateKeyPress()
                if VirtualUser and UserInputService then
                    -- Для ПК: эмулируем нажатие клавиши
                    pcall(function()
                        keypress(config.keyCode)
                        task.wait(0.1)
                        keyrelease(config.keyCode)
                    end)
                    
                    -- Для мобилки: эмулируем нажатие через виртуальные кнопки
                    pcall(function()
                        VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    end)
                end
            end

            ClickRegion.MouseEnter:Connect(expand)
            ClickRegion.MouseLeave:Connect(function()
                contract()
            end)

            ClickRegion.MouseButton1Click:Connect(function()
                simulateKeyPress()
            end)

            ClickRegion.TouchTap:Connect(function()
                simulateKeyPress()
                expand()
                task.wait(0.2)
                contract()
            end)

            player.CharacterAdded:Connect(function()
                task.wait(0.1)
                isHovering = false
                if currentTween then
                    currentTween:Cancel()
                    currentTween = nil
                end
                
                Button.Size = smallButtonSize
                IconSpot.Size = smallIconSpotSize
                IconLabelContainer.Size = smallLabelSize
                IconLabel.Visible = false
                IconLabelContainer.Visible = false
                IconOverlay.Visible = false
            end)
        end
        
        Fluent:Notify({
            Title = "Custom Leaderboard",
            Content = "Leaderboard & Controls unlocked! Emulating real key presses.",
            Duration = 3
        })
    end
})

if not workspace:FindFirstChild("SecurityPart") then
    local SecurityPart = Instance.new("Part")
    SecurityPart.Name = "SecurityPart"
    SecurityPart.Size = Vector3.new(20, 1, 20)
    SecurityPart.Position = Vector3.new(5000, 5000, 5000)
    SecurityPart.Anchored = true
    SecurityPart.CanCollide = true
    SecurityPart.BrickColor = BrickColor.new("Really black")
    SecurityPart.Material = Enum.Material.SmoothPlastic
    SecurityPart.Parent = workspace
    local decal = Instance.new("Decal")
    decal.Name = "SecurityImage"
    decal.Face = Enum.NormalId.Top
    decal.Texture = "rbxassetid://102225156206159"
    decal.Parent = SecurityPart
end

OtherTab = Window:AddTab({ Title = "Other", Icon = "solar/widget-bold", Favoriteable = true })

local function loadOtherModule(fileName)
    local ok, result = pcall(loadOnlineModule, fileName)
    if not ok then
        warn("[Other] Failed to load " .. fileName .. ":", result)
        Fluent:Notify({
            Title = "Other",
            Content = "Failed to load " .. fileName,
            Duration = 5
        })
        return nil
    end
    return result
end

local AFKFarm = loadOtherModule("AFKFarm.lua")
local TicketFarm = loadOtherModule("TicketFarm.lua")
local Teleports = loadOtherModule("Teleports.lua")
local ServerList = loadOtherModule("ServerList.lua")

OtherTab:AddSection("AFK Farm", "solar/clock-circle-bold")

AFKFarmToggle = OtherTab:AddToggle("AFKFarmToggle", {
    Title = "Farm AFK",
    Description = "Teleport to SecurityPart and hold position",
    Default = false,
    Callback = function(value)
        if not AFKFarm then
            Fluent:Notify({ Title = "Other", Content = "AFKFarm module not loaded", Duration = 4 })
            return
        end
        if value then
            AFKFarm.start()
        else
            AFKFarm.stop()
        end
    end
})

TicketFarmToggle = OtherTab:AddToggle("TicketFarmToggle", {
    Title = "Farm Tickets",
    Description = "Hold on platform, teleport to tickets, auto respawn if Downed",
    Default = false,
    Callback = function(value)
        if not TicketFarm then
            Fluent:Notify({ Title = "Other", Content = "TicketFarm module not loaded", Duration = 4 })
            return
        end
        if value then
            if AFKFarmToggle and AFKFarmToggle.Value then
                AFKFarmToggle:Set(false)
            end
            TicketFarm.start()
            Fluent:Notify({
                Title = "Farm Tickets",
                Content = "Ticket farm enabled!",
                Duration = 3
            })
        else
            TicketFarm.stop()
            Fluent:Notify({
                Title = "Farm Tickets",
                Content = "Ticket farm disabled!",
                Duration = 3
            })
        end
    end
})

OtherTab:AddSection("Teleports", "solar/map-arrow-right-bold")

OtherTab:AddButton({
    Title = "Teleport to Random Spawn",
    Description = "Teleport to a random spawn point",
    Callback = function()
        if not Teleports then
            Fluent:Notify({ Title = "Other", Content = "Teleports module not loaded", Duration = 4 })
            return
        end
        local ok, msg = Teleports.toRandomSpawn()
        Fluent:Notify({ Title = "Other", Content = msg, Duration = ok and 2 or 3 })
    end
})

OtherTab:AddButton({
    Title = "Create Custom Map",
    Description = "Teleport to a custom place",
    Callback = function()
        if not Teleports then
            Fluent:Notify({ Title = "Other", Content = "Teleports module not loaded", Duration = 4 })
            return
        end
        local _, msg = Teleports.joinCustomMap()
        Fluent:Notify({ Title = "Other", Content = msg, Duration = 3 })
    end
})

OtherTab:AddSection("Server List", "solar/server-bold")

local serverListValues = {}
if ServerList then
    serverListValues = ServerList.load()
end

local ServerListDropdown = OtherTab:AddDropdown("ServerListDropdown", {
    Title = "Server List",
    Values = serverListValues,
    Multi = false,
    Default = "",
    Searchable = true,
})

OtherTab:AddButton({
    Title = "Add Current Server",
    Description = "Add current JobId to the list",
    Callback = function()
        if not ServerList then
            Fluent:Notify({ Title = "Server List", Content = "ServerList module not loaded", Duration = 4 })
            return
        end
        local ok, msg, values = ServerList.addCurrent()
        pcall(function()
            ServerListDropdown:SetValues(values)
        end)
        Fluent:Notify({ Title = "Server List", Content = msg, Duration = 3 })
    end
})

OtherTab:AddButton({
    Title = "Remove Selected Server",
    Description = "Remove selected server from the list",
    Callback = function()
        if not ServerList then
            Fluent:Notify({ Title = "Server List", Content = "ServerList module not loaded", Duration = 4 })
            return
        end
        local selected = ServerListDropdown.Value
        if not selected or selected == "" then
            Fluent:Notify({ Title = "Server List", Content = "No server selected", Duration = 3 })
            return
        end
        local ok, msg, values = ServerList.removeSelected(selected)
        pcall(function()
            ServerListDropdown:SetValues(values)
        end)
        Fluent:Notify({ Title = "Server List", Content = msg, Duration = 3 })
    end
})

OtherTab:AddButton({
    Title = "Join Selected Server",
    Description = "Join selected server",
    Callback = function()
        if not ServerList then
            Fluent:Notify({ Title = "Server List", Content = "ServerList module not loaded", Duration = 4 })
            return
        end
        local selected = ServerListDropdown.Value
        if not selected or selected == "" then
            Fluent:Notify({ Title = "Server List", Content = "No server selected", Duration = 3 })
            return
        end
        local ok, msg = ServerList.joinSelected(selected)
        Fluent:Notify({ Title = "Server List", Content = msg, Duration = ok and 3 or 5 })
    end
})

MiscTab = Window:AddTab({ Title = "Misc", Icon = "star", Favoriteable = true })

MiscTab:AddSection("Player Adjustments", "solar/user-rounded-bold")

local PlayerAdjustments
do
    local ok, result = pcall(loadOnlineModule, "PlayerAdjustments.lua")
    PlayerAdjustments = ok and result or nil
    if not ok then
        warn("[Misc] Failed to load PlayerAdjustments.lua:", result)
        Fluent:Notify({
            Title = "Misc",
            Content = "Failed to load PlayerAdjustments.lua",
            Duration = 5
        })
    else
        PlayerAdjustments.start()
    end
end

MiscTab:AddInput("SpeedInput", {
    Title = "Player Speed",
    Default = "1500",
    Placeholder = "Default 1500",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 1 and val <= 100000000 and PlayerAdjustments then
            PlayerAdjustments.setSpeed(val)
        end
    end
})

MiscTab:AddInput("JumpPowerInput", {
    Title = "Player Jump Height",
    Default = "3",
    Placeholder = "Default 3",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 0.1 and val <= 100000000 and PlayerAdjustments then
            PlayerAdjustments.setJumpPower(val)
        end
    end
})

MiscTab:AddInput("JumpCapInput", {
    Title = "Player Jump Cap",
    Default = "1",
    Placeholder = "Default 1",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 0.1 and val <= 100000000 and PlayerAdjustments then
            PlayerAdjustments.setJumpCap(val)
        end
    end
})

MiscTab:AddInput("AirStrafeInput", {
    Title = "Air Strafe Acceleration",
    Default = "182",
    Placeholder = "Default 182",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 1 and val <= 10000 and PlayerAdjustments then
            PlayerAdjustments.setAirStrafe(val)
        end
    end
})

MiscTab:AddSection("Bounce", "solar/transfer-vertical-bold")

BounceToggle = MiscTab:AddToggle("BounceToggle", {
    Title = "Modify Bounce",
    Default = false
})

BounceInput = MiscTab:AddInput("BounceInput", {
    Title = "Player Bounce",
    Default = "110",
    Placeholder = "Enter bounce speed",
    Numeric = true,
    Finished = false
})

local bounceConnection = nil
local player = game:GetService("Players").LocalPlayer

local function updateBounce()
    if not BounceToggle.Value then return end

    local gamePlayers = workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return end

    local playerModel = gamePlayers:FindFirstChild(player.Name)
    if not playerModel then return end

    local humanoid = playerModel:FindFirstChild("Humanoid")
    if not humanoid then return end

    local speedValue = tonumber(BounceInput.Value) or 110
    humanoid.WalkSpeed = speedValue
end

BounceToggle:OnChanged(function(state)
    if state then

        if bounceConnection then
            bounceConnection:Disconnect()
        end

        bounceConnection = game:GetService("RunService").Heartbeat:Connect(updateBounce)
    else
        if bounceConnection then
            bounceConnection:Disconnect()
            bounceConnection = nil
        end


        local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        if gamePlayers then
            local playerModel = gamePlayers:FindFirstChild(player.Name)
            if playerModel then
                local humanoid = playerModel:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 0  
                end
            end
        end
    end
end)

BounceInput:OnChanged(function(Value)
    if BounceToggle.Value then
        local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        if gamePlayers then
            local playerModel = gamePlayers:FindFirstChild(player.Name)
            if playerModel then
                local humanoid = playerModel:FindFirstChild("Humanoid")
                if humanoid then
                    local speedValue = tonumber(Value) or 110
                    humanoid.WalkSpeed = speedValue
                end
            end
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if BounceToggle.Value then

        task.wait(1)
        updateBounce()
    end
end)

MiscTab:AddSection("Carry Players", "solar/users-group-rounded-bold")

AutoCarryToggle = MiscTab:AddToggle("AutoCarryToggle", {
    Title = "Auto Carry",
    Default = false
})

CarryGUIToggle = MiscTab:AddToggle("CarryGUIToggle", {
    Title = "Carry GUI Button",
    Default = false
})

local CarryPlayers
do
    local ok, result = pcall(loadOnlineModule, "CarryPlayers.lua")
    CarryPlayers = ok and result or nil
    if not ok then
        warn("[Misc] Failed to load CarryPlayers.lua:", result)
        Fluent:Notify({
            Title = "Misc",
            Content = "Failed to load CarryPlayers.lua",
            Duration = 5
        })
    else
        CarryPlayers.init({
            createGradientButton = createGradientButton,
            getButtonSize = function()
                if Options.CarryButtonSizeInput and Options.CarryButtonSizeInput.Value then
                    return tonumber(Options.CarryButtonSizeInput.Value) or 180
                end
                return 180
            end,
            getAutoCarryToggle = function()
                return AutoCarryToggle
            end,
            setAutoCarryToggle = function(value)
                if Options.AutoCarryToggle then
                    Options.AutoCarryToggle:SetValue(value)
                end
            end
        })
        CarryPlayers.start()
    end
end

AutoCarryToggle:OnChanged(function(state)
    if CarryPlayers then
        CarryPlayers.setEnabled(state)
    end
end)

CarryGUIToggle:OnChanged(function(state)
    if CarryPlayers then
        CarryPlayers.setGUI(state)
    end
end)

CarryKeybind = MiscTab:AddKeybind("CarryKeybind", {
    Title = "Auto Carry Keybind",
    Mode = "Toggle",
    Default = "U",
    ChangedCallback = function(New)
    end,
    Callback = function()
        if not CarryPlayers then return end

        local current = false
        if Options.AutoCarryToggle then
            current = Options.AutoCarryToggle.Value
        end

        local newValue = not current

        if Options.AutoCarryToggle then
            Options.AutoCarryToggle:SetValue(newValue)
        end

        CarryPlayers.setEnabled(newValue)
    end
})

MiscTab:AddSection("Gun Functions", "solar/bomb-emoji-bold")

local GunFunctions
do
    local ok, result = pcall(loadOnlineModule, "GunFunctions.lua")
    GunFunctions = ok and result or nil
    if not ok then
        warn("[Misc] Failed to load GunFunctions.lua:", result)
    end
end

GrappleHookToggle = MiscTab:AddButton({
    Title = "Grapplehook",
    Callback = function()
        if not GunFunctions then
            Fluent:Notify({
                Title = "GrappleHook Error",
                Content = "GunFunctions module not loaded",
                Duration = 5
            })
            return
        end

        local success, result = pcall(GunFunctions.grappleHook)
        if success then
            Fluent:Notify({
                Title = "GrappleHook",
                Content = "GrappleHook upgraded! Infinite ammo, no cooldown",
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "GrappleHook Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

BreacherToggle = MiscTab:AddButton({
    Title = "Breacher (Portal Gun)",
    Callback = function()
        if not GunFunctions then
            Fluent:Notify({
                Title = "Breacher Error",
                Content = "GunFunctions module not loaded",
                Duration = 5
            })
            return
        end

        local success, result = pcall(GunFunctions.breacher)
        if success then
            Fluent:Notify({
                Title = "Breacher (Portal Gun)",
                Content = "Portal Gun upgraded! Infinite charges, max range, instant reload",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Breacher Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

MiscTab:AddSection("Gravity", "solar/planet-bold")

local gravityEnabled = false
local originalGravity = workspace.Gravity
local gravityValue = 10
local gravityHeartbeat = nil
local gravityKeybindValue = "J"

local function toggleGravity()
    gravityEnabled = not gravityEnabled
    local CoreGui = game:GetService("CoreGui")
    local screenGui = CoreGui:FindFirstChild("GravityButtonGUI")
    local btn = screenGui and screenGui:FindFirstChild("GradientBtn")
    if btn and btn:FindFirstChild("TextLabel") then
        btn.TextLabel.Text = gravityEnabled and "Gravity: On" or "Gravity: Off"
    end
    if gravityEnabled then
        workspace.Gravity = gravityValue
    else
        workspace.Gravity = originalGravity
    end
    if Options.GravityToggle then
        Options.GravityToggle:SetValue(gravityEnabled)
    end
end

local function createGravityButton()
    local CoreGui = game:GetService("CoreGui")
    local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")

    if existingScreenGui then
        existingScreenGui:Destroy()
    else
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GravityButtonGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui

        local buttonSize = 180
        if Options.GravityButtonSizeInput and Options.GravityButtonSizeInput.Value and tonumber(Options.GravityButtonSizeInput.Value) then
            buttonSize = tonumber(Options.GravityButtonSizeInput.Value)
        end
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))

        local btn, clicker, stroke = createGradientButton(
            screenGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
            UDim2.new(0, btnWidth, 0, btnHeight),
            gravityEnabled and "Gravity: On" or "Gravity: Off"
        )

        clicker.MouseButton1Click:Connect(function()
            toggleGravity()
        end)
    end
end

GravityToggle = MiscTab:AddToggle("GravityToggle", {
    Title = "Gravity",
    Default = false,
    Callback = function(Value)
        gravityEnabled = Value
        
        if Value then
            workspace.Gravity = gravityValue
        else
            workspace.Gravity = originalGravity
        end
    end
})

GravityButtonToggle = MiscTab:AddToggle("GravityButtonToggle", {
    Title = "Gravity Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createGravityButton()
        else
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
            if existingScreenGui then
                existingScreenGui:Destroy()
            end
        end
    end
})

GravityKeybind = MiscTab:AddKeybind("GravityKeybind", {
    Title = "Gravity Keybind",
    Mode = "Toggle",
    Default = "J",
    ChangedCallback = function(New)
        gravityKeybindValue = New
    end,
    Callback = function()
        toggleGravity()
    end
})

GravityAdjustmentInput = MiscTab:AddInput("GravityAdjustmentInput", {
    Title = "Gravity Adjustment",
    Default = "10",
    Placeholder = "Enter gravity value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            gravityValue = num
            if gravityEnabled then
                workspace.Gravity = gravityValue
            end
        end
    end
})

originalGravity = workspace.Gravity

GravityToggle:OnChanged(function(state)
    if Options.GravityButtonToggle and Options.GravityButtonToggle.Value then
        local CoreGui = game:GetService("CoreGui")
        local screenGui = CoreGui:FindFirstChild("GravityButtonGUI")
        if screenGui then
            local button = screenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = state and "Gravity: On" or "Gravity: Off"
            end
        end
    end
end)

MiscTab:AddSection("Crouch", "solar/accessibility-bold")

local CrouchModule = nil
local crouchGui = nil
local crouchEnabled = false

pcall(function()
    CrouchModule = loadOnlineModule("CrouchModule.lua")
end)

if CrouchModule then
    CrouchModeDropdown = MiscTab:AddDropdown("CrouchModeDropdown", {
        Title = "Crouch Mode",
        Values = {"Spam", "Air", "Classic"},
        Multi = false,
        Default = "Spam",
        Callback = function(Value)
            CrouchModule.SetMode(Value)
        end
    })

    CrouchDelayInput = MiscTab:AddInput("CrouchDelayInput", {
        Title = "Crouch Spam Delay",
        Default = "0.1",
        Placeholder = "Enter delay in seconds",
        Numeric = true,
        Finished = false,
        Callback = function(Value)
            CrouchModule.SetDelay(Value)
        end
    })

    local function toggleCrouch(state)
        crouchEnabled = state
        if state then
            CrouchModule.Start()
        else
            CrouchModule.Stop()
        end
        
        if crouchGui and crouchGui:FindFirstChild("GradientBtn") then
            local btn = crouchGui.GradientBtn
            if btn:FindFirstChild("TextLabel") then
                btn.TextLabel.Text = state and "Crouch: On" or "Crouch: Off"
            end
        end
    end

    local function createCrouchButton()
        local CoreGui = game:GetService("CoreGui")
        if crouchGui then
            crouchGui:Destroy()
            crouchGui = nil
        end
        
        crouchGui = Instance.new("ScreenGui")
        crouchGui.Name = "CrouchButtonGUI"
        crouchGui.ResetOnSpawn = false
        crouchGui.Parent = CoreGui
        
        local buttonSize = 180
        if Options.CrouchButtonSizeInput and Options.CrouchButtonSizeInput.Value and tonumber(Options.CrouchButtonSizeInput.Value) then
            buttonSize = tonumber(Options.CrouchButtonSizeInput.Value)
        end
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
        
        local btn, clicker, stroke = createGradientButton(
            crouchGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
            UDim2.new(0, btnWidth, 0, btnHeight),
            crouchEnabled and "Crouch: On" or "Crouch: Off"
        )
        
        clicker.MouseButton1Click:Connect(function()
            toggleCrouch(not crouchEnabled)
            if Options.CrouchToggle then
                Options.CrouchToggle:SetValue(crouchEnabled)
            end
        end)
    end

    CrouchToggle = MiscTab:AddToggle("CrouchToggle", {
        Title = "Enable Crouch",
        Default = false,
        Callback = function(Value)
            toggleCrouch(Value)
        end
    })

    CrouchButtonToggle = MiscTab:AddToggle("CrouchButtonToggle", {
        Title = "Crouch GUI Button",
        Default = false,
        Callback = function(Value)
            if Value then
                createCrouchButton()
            else
                if crouchGui then
                    crouchGui:Destroy()
                    crouchGui = nil
                end
            end
        end
    })

    CrouchKeybind = MiscTab:AddKeybind("CrouchKeybind", {
        Title = "Crouch Keybind",
        Mode = "Toggle",
        Default = "C",
        ChangedCallback = function(New)
        end,
        Callback = function()
            toggleCrouch(not crouchEnabled)
            if Options.CrouchToggle then
                Options.CrouchToggle:SetValue(crouchEnabled)
            end
        end
    })
else
    MiscTab:AddParagraph({
        Title = "Crouch",
        Content = "Failed to load CrouchModule.lua"
    })
end

MiscTab:AddSection("Arrow Speed", "solar/arrow-right-bold")

local arrowSpeedActive = false
local arrowSpeedValue = 5
local arrowSpeedKeybindValue = "H"
local arrowSpeedOriginalFunction = nil
local arrowSpeedModuleRef = nil
local arrowSpeedCurrentMultiplier = 1

local function applyArrowSensitivity(multiplier)
    multiplier = math.clamp(multiplier or 1, 0.1, 20)

    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("ModuleScript") and obj.Name == "CameraInput" then
            local success, module = pcall(function() return require(obj) end)
            if success and module and module.getRotation then
                if not arrowSpeedOriginalFunction then
                    arrowSpeedOriginalFunction = module.getRotation
                    arrowSpeedModuleRef = module
                end

                module.getRotation = function(self, dt, ...)
                    if not arrowSpeedOriginalFunction then
                        return Vector2.new()
                    end
                    local result = arrowSpeedOriginalFunction(self, dt, ...)
                    return result * multiplier
                end

                arrowSpeedCurrentMultiplier = multiplier
                return true
            end
        end
    end

    return false
end

local function resetArrowSensitivity()
    if arrowSpeedOriginalFunction and arrowSpeedModuleRef then
        arrowSpeedModuleRef.getRotation = arrowSpeedOriginalFunction
        arrowSpeedOriginalFunction = nil
        arrowSpeedModuleRef = nil
        arrowSpeedCurrentMultiplier = 1
    end
end

local function toggleArrowSpeed()
    if not arrowSpeedActive then
        local success = applyArrowSensitivity(arrowSpeedValue)
        if success then
            arrowSpeedActive = true
            Fluent:Notify({
                Title = "Arrow Speed",
                Content = "Arrow speed: x" .. tostring(arrowSpeedValue),
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "Arrow Speed",
                Content = "CameraInput not found",
                Duration = 3
            })
        end
    else
        resetArrowSensitivity()
        arrowSpeedActive = false
        Fluent:Notify({
            Title = "Arrow Speed",
            Content = "Arrow speed: default (x1)",
            Duration = 2
        })
    end
end

ArrowSpeedValueInput = MiscTab:AddInput("ArrowSpeedValueInput", {
    Title = "Arrow Speed Multiplier",
    Description = "Arrow speed multiplier (0.1 - 20)",
    Default = "5",
    Placeholder = "Enter multiplier (e.g., 5)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0.1 and num <= 20 then
            arrowSpeedValue = num
            if arrowSpeedActive then
                applyArrowSensitivity(arrowSpeedValue)
            end
        else
            Fluent:Notify({
                Title = "Arrow Speed",
                Content = "Value must be between 0.1 and 20",
                Duration = 3
            })
        end
    end
})

ArrowSpeedKeybind = MiscTab:AddKeybind("ArrowSpeedKeybind", {
    Title = "Arrow Speed Keybind",
    Mode = "Toggle",
    Default = "H",
    ChangedCallback = function(New)
        arrowSpeedKeybindValue = New
    end,
    Callback = function()
        toggleArrowSpeed()
    end
})

_G.ArrowSpeed = function(multiplier)
    arrowSpeedValue = tonumber(multiplier) or arrowSpeedValue
    if ArrowSpeedValueInput then
        pcall(function()
            ArrowSpeedValueInput:SetValue(tostring(arrowSpeedValue))
        end)
    end
    applyArrowSensitivity(arrowSpeedValue)
    arrowSpeedActive = true
end

_G.ResetArrowSpeed = function()
    resetArrowSensitivity()
    arrowSpeedActive = false
end

LocalPlayer.CharacterAdded:Connect(function()
    if arrowSpeedActive then
        task.wait(1)
        applyArrowSensitivity(arrowSpeedValue)
    end
end)

MiscTab:AddSection("Emote Speed", "solar/playback-speed-bold")

local EmoteSpeedModule = nil
local featureStates = { EmoteSpeedValue = 2000 }

pcall(function()
    EmoteSpeedModule = loadOnlineModule("EmoteSpeed.lua")
    if EmoteSpeedModule then
        EmoteSpeedModule.init(featureStates)
    end
end)

if EmoteSpeedModule then
    EmoteSpeedModeDropdown = MiscTab:AddDropdown("EmoteSpeedModeDropdown", {
        Title = "Emote Speed Mode",
        Values = {"Off", "Legit (speed mult)", "Walk multiplier"},
        Multi = false,
        Default = "Off",
        Callback = function(Value)
            EmoteSpeedModule.CurrentMode = Value
            EmoteSpeedModule.SetMode(Value)
        end
    })

    EmoteSpeedInput = MiscTab:AddInput("EmoteSpeedInput", {
        Title = "Emote Speed Value",
        Default = "2000",
        Placeholder = "Enter speed (1000 = normal)",
        Numeric = true,
        Finished = false,
        Callback = function(Value)
            EmoteSpeedModule.SetValue(Value)
        end
    })

    ApplyUnwalkableButton = MiscTab:AddButton({
        Title = "Apply Speed to Unwalkable Emotes",
        Callback = function()
            EmoteSpeedModule.ApplyUnwalkable(featureStates.EmoteSpeedValue)
            Fluent:Notify({
                Title = "Emote Speed",
                Content = "Applied speed to unwalkable emotes",
                Duration = 3
            })
        end
    })

    ResetEmoteSpeedButton = MiscTab:AddButton({
        Title = "Reset Emote Speed",
        Callback = function()
            EmoteSpeedModule.Reset()
            Fluent:Notify({
                Title = "Emote Speed",
                Content = "All emote speeds reset",
                Duration = 3
            })
        end
    })

    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        task.wait(2)
        EmoteSpeedModule.OnRespawn()
    end)
else
    MiscTab:AddParagraph({
        Title = "Emote Speed",
        Content = "Failed to load EmoteSpeed.lua module."
    })
end

MiscTab:AddSection("Infinity Slide", "solar/running-bold")

local CharacterService = require(game:GetService("ReplicatedStorage").Services.Asset.CharacterService)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local infiniteSlideEnabled = false
local slideFrictionValue = -8
local slideOriginalValues = {}
local infiniteSlideHeartbeat = nil
local infiniteSlideCharacterConn = nil

local slideStates = {
    Slide = true,
    EmotingSlide = true,
    CarrySlide = true,
}

local function getLocalChar()
    return CharacterService:GetLocalCharacter()
end

local function getMoveStatsTable(char)
    if not char or not char.Movement then return nil end
    local ms = char.Movement.MoveStats
    if not ms then return nil end
    return ms.MoveStats or ms
end

local function applySlideFriction()
    local char = getLocalChar()
    if not char then return end
    local tbl = getMoveStatsTable(char)
    if not tbl then return end

    if slideOriginalValues.Friction == nil then
        slideOriginalValues.Friction = tbl.Friction
    end
    if slideOriginalValues.RunDeaccel == nil then
        slideOriginalValues.RunDeaccel = tbl.RunDeaccel
    end

    tbl.Friction = slideFrictionValue
end

local function restoreFriction()
    local char = getLocalChar()
    if not char then return end
    local tbl = getMoveStatsTable(char)
    if not tbl then return end

    if slideOriginalValues.Friction ~= nil then
        tbl.Friction = slideOriginalValues.Friction
    end
    if slideOriginalValues.RunDeaccel ~= nil then
        tbl.RunDeaccel = slideOriginalValues.RunDeaccel
    end
end

local function infiniteSlideHeartbeatFunc()
    if not infiniteSlideEnabled then return end

    local char = getLocalChar()
    if not char or not char.State then return end

    local state = char.State.State

    if slideStates[state] then
        applySlideFriction()
    else
        restoreFriction()
    end
end

local function startInfiniteSlide()
    if infiniteSlideHeartbeat then
        infiniteSlideHeartbeat:Disconnect()
        infiniteSlideHeartbeat = nil
    end

    infiniteSlideHeartbeat = RunService.Heartbeat:Connect(infiniteSlideHeartbeatFunc)
end

local function stopInfiniteSlide()
    if infiniteSlideHeartbeat then
        infiniteSlideHeartbeat:Disconnect()
        infiniteSlideHeartbeat = nil
    end
    restoreFriction()
    slideOriginalValues = {}
end

local function setInfiniteSlide(enabled)
    infiniteSlideEnabled = enabled

    if enabled then
        startInfiniteSlide()
    else
        stopInfiniteSlide()
    end
end

InfiniteSlideToggle = MiscTab:AddToggle("InfiniteSlideToggle", {
    Title = "Sprint Slide",
    Default = false,
    Callback = function(Value)
        setInfiniteSlide(Value)
    end
})

SlideFrictionInput = MiscTab:AddInput("SlideFrictionInput", {
    Title = "Slide Friction (negative only)",
    Default = "-8",
    Placeholder = "Enter negative value (e.g., -8)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            slideFrictionValue = num
        end
    end
})

local slideButtonScreenGui = nil

local function createSlideGradientButton()
    local CoreGui = game:GetService("CoreGui")

    if slideButtonScreenGui then
        slideButtonScreenGui:Destroy()
        slideButtonScreenGui = nil
    end

    slideButtonScreenGui = Instance.new("ScreenGui")
    slideButtonScreenGui.Name = "SlideButtonGUI"
    slideButtonScreenGui.ResetOnSpawn = false
    slideButtonScreenGui.Parent = CoreGui

    local buttonSize = 180
    if Options.SlideButtonScaleInput and Options.SlideButtonScaleInput.Value and tonumber(Options.SlideButtonScaleInput.Value) then
        buttonSize = tonumber(Options.SlideButtonScaleInput.Value)
    end
    local btnWidth = math.max(150, math.min(buttonSize, 400))
    local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))

    local btn, clicker, stroke = createGradientButton(
        slideButtonScreenGui,
        UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
        UDim2.new(0, btnWidth, 0, btnHeight),
        infiniteSlideEnabled and "Sprint Slide: On" or "Sprint Slide: Off"
    )

    clicker.MouseButton1Click:Connect(function()
        infiniteSlideEnabled = not infiniteSlideEnabled
        setInfiniteSlide(infiniteSlideEnabled)

        if btn:FindFirstChild("TextLabel") then
            btn.TextLabel.Text = infiniteSlideEnabled and "Sprint Slide: On" or "Sprint Slide: Off"
        end

        if Options.InfiniteSlideToggle then
            Options.InfiniteSlideToggle:SetValue(infiniteSlideEnabled)
        end
    end)

    return slideButtonScreenGui
end

local function updateSlideButtonText()
    if slideButtonScreenGui and slideButtonScreenGui:FindFirstChild("GradientBtn") then
        local button = slideButtonScreenGui:FindFirstChild("GradientBtn")
        if button and button:FindFirstChild("TextLabel") then
            button.TextLabel.Text = infiniteSlideEnabled and "Sprint Slide: On" or "Sprint Slide: Off"
        end
    end
end

SlideButtonToggle = MiscTab:AddToggle("SlideButtonToggle", {
    Title = "Sprint Slide Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createSlideGradientButton()
        else
            if slideButtonScreenGui then
                slideButtonScreenGui:Destroy()
                slideButtonScreenGui = nil
            end
        end
    end
})

SlideKeybind = MiscTab:AddKeybind("SlideKeybind", {
    Title = "Sprint Slide Keybind",
    Mode = "Toggle",
    Default = "X",
    ChangedCallback = function(New)
    end,
    Callback = function()
        infiniteSlideEnabled = not infiniteSlideEnabled
        setInfiniteSlide(infiniteSlideEnabled)

        if Options.InfiniteSlideToggle then
            Options.InfiniteSlideToggle:SetValue(infiniteSlideEnabled)
        end

        updateSlideButtonText()
    end
})

getgenv().InfiniteSlide = {
    Enable = function(friction)
        slideFrictionValue = friction or -8
        infiniteSlideEnabled = true
        startInfiniteSlide()
    end,
    Disable = function()
        infiniteSlideEnabled = false
        stopInfiniteSlide()
    end,
    SetFriction = function(v)
        slideFrictionValue = v
    end,
}

local UserInputService = game:GetService("UserInputService")

MiscTab:AddSection("Auto Jump", "solar/arrow-up-bold")

local AutoJump
do
    local ok, result = pcall(loadOnlineModule, "AutoJump.lua")
    AutoJump = ok and result or nil
    if not ok then
        warn("[Misc] Failed to load AutoJump.lua:", result)
        Fluent:Notify({
            Title = "Misc",
            Content = "Failed to load AutoJump.lua",
            Duration = 5
        })
    else
        AutoJump.Init(createGradientButton)
    end
end

AutoJumpTypeDropdown = MiscTab:AddDropdown("AutoJumpTypeDropdown", {
    Title = "Auto Jump Mode",
    Description = "Bounce / Realistic",
    Values = {"Bounce", "Realistic"},
    Multi = false,
    Default = "Bounce",
    Callback = function(value)
        if AutoJump then
            AutoJump.SetMode(value)
        end
    end
})

RotationToggle = MiscTab:AddToggle("RotationToggle", {
    Title = "Rotation 360",
    Description = "Do not use with emotions!",
    Default = false,
    Callback = function(Value)
        if AutoJump then
            AutoJump.SetRotation(Value)
        end
    end
})

BhopToggle = MiscTab:AddToggle("BhopToggle", {
    Title = "Bunny Hop",
    Default = false,
    Callback = function(Value)
        if AutoJump then
            AutoJump.SetEnabled(Value)
            AutoJump.UpdateButtonText(Value and "Auto Jump: On" or "Auto Jump: Off")
        end
    end
})

BhopHoldToggle = MiscTab:AddToggle("BhopHoldToggle", {
    Title = "Bhop Hold (Hold Space/Jump)",
    Default = false,
    Callback = function(Value)
        if AutoJump then
            AutoJump.SetHold(Value)
        end
    end
})

WallJumpToggle = MiscTab:AddToggle("WallJumpToggle", {
    Title = "Wall Jump",
    Description = "Auto jump while wallrunning",
    Default = false,
    Callback = function(Value)
        if AutoJump then
            AutoJump.SetWallJump(Value)
        end
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.Space then
        if Options.BhopHoldToggle and Options.BhopHoldToggle.Value and AutoJump then
            AutoJump.SetHold(true)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        if AutoJump then
            AutoJump.SetHold(false)
        end
    end
end)

BhopButtonToggle = MiscTab:AddToggle("BhopButtonToggle", {
    Title = "Bhop Button GUI",
    Default = false,
    Callback = function(Value)
        if not AutoJump then return end

        if Value then
            local buttonSize = 180
            if Options.BhopButtonScaleInput and Options.BhopButtonScaleInput.Value and tonumber(Options.BhopButtonScaleInput.Value) then
                buttonSize = tonumber(Options.BhopButtonScaleInput.Value)
            end
            local btnWidth = math.max(150, math.min(buttonSize, 400))
            local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))

            AutoJump.CreateButton(
                game:GetService("CoreGui"),
                UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
                UDim2.new(0, btnWidth, 0, btnHeight),
                AutoJump.IsEnabled() and "Auto Jump: On" or "Auto Jump: Off",
                function()
                    if not AutoJump then return end
                    local newState = not AutoJump.IsEnabled()
                    if Options.BhopToggle then
                        Options.BhopToggle:SetValue(newState)
                    end
                    AutoJump.UpdateButtonText(newState and "Auto Jump: On" or "Auto Jump: Off")
                end,
                createGradientButton
            )
        else
            if AutoJump then
                local gui = game:GetService("CoreGui"):FindFirstChild("BhopButtonGUI")
                if gui then
                    gui:Destroy()
                end
            end
        end
    end
})

BhopKeybind = MiscTab:AddKeybind("BhopKeybind", {
    Title = "Bhop Keybind",
    Mode = "Toggle",
    Default = "B",
    ChangedCallback = function(New) end,
    Callback = function()
        if not AutoJump then return end
        local newState = not AutoJump.IsEnabled()
        if Options.BhopToggle then
            Options.BhopToggle:SetValue(newState)
        end
        AutoJump.UpdateButtonText(newState and "Auto Jump: On" or "Auto Jump: Off")
    end
})

BhopAccelInput = MiscTab:AddInput("BhopAccelInput", {
    Title = "Bhop Acceleration",
    Default = "-0.5",
    Placeholder = "Enter negative value (e.g., -0.5)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and string.sub(Value, 1, 1) == "-" and AutoJump then
            AutoJump.SetAcceleration(num)
        end
    end
})

JumpCooldownInput = MiscTab:AddInput("JumpCooldownInput", {
    Title = "Jump Cooldown (Seconds)",
    Default = "0.25",
    Placeholder = "Enter cooldown in seconds",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 and AutoJump then
            AutoJump.SetCooldown(num)
        end
    end
})

AutoJumpResetButton = MiscTab:AddButton({
    Title = "Reset Speed",
    Description = "Reset friction to default (5) and re-apply on next jump",
    Callback = function()
        if AutoJump then
            AutoJump.ResetSpeed()
            Fluent:Notify({
                Title = "Auto Jump",
                Content = "Speed reset to default",
                Duration = 2
            })
        end
    end
})

AutoJumpResetKeybind = MiscTab:AddKeybind("AutoJumpResetKeybind", {
    Title = "Reset Speed Keybind",
    Mode = "Toggle",
    Default = "K",
    ChangedCallback = function(New) end,
    Callback = function()
        if AutoJump then
            AutoJump.ResetSpeed()
            Fluent:Notify({
                Title = "Auto Jump",
                Content = "Speed reset to default (K)",
                Duration = 2
            })
        end
    end
})

MiscTab:AddSection("Lag Switch", "solar/wifi-router-bold")

local LagSwitch
do
    local ok, result = pcall(loadOnlineModule, "LagSwitch.lua")
    LagSwitch = ok and result or nil
    if not ok then
        warn("[Misc] Failed to load LagSwitch.lua:", result)
        Fluent:Notify({
            Title = "Misc",
            Content = "Failed to load LagSwitch.lua",
            Duration = 5
        })
    else
        LagSwitch.init({
            createGradientButton = createGradientButton,
            getButtonSize = function()
                if Options.LagSwitchScaleInput and Options.LagSwitchScaleInput.Value then
                    return tonumber(Options.LagSwitchScaleInput.Value) or 180
                end
                return 180
            end,
            getDemonHeight = function()
                if Options.DemonRiseHeightInput and Options.DemonRiseHeightInput.Value then
                    return Options.DemonRiseHeightInput.Value
                end
                return 100
            end,
            getDemonSpeed = function()
                if Options.DemonRiseSpeedInput and Options.DemonRiseSpeedInput.Value then
                    return Options.DemonRiseSpeedInput.Value
                end
                return 80
            end,
            notify = function(title, content, duration)
                Fluent:Notify({
                    Title = title,
                    Content = content,
                    Duration = duration
                })
            end
        })
    end
end

LagSwitchToggle = MiscTab:AddToggle("LagSwitchToggle", {
    Title = "Lag Switch",
    Default = false,
    Callback = function(Value)
        if LagSwitch then
            LagSwitch.setEnabled(Value)
        end
    end
})

LagSwitchModeDropdown = MiscTab:AddDropdown("LagSwitchModeDropdown", {
    Title = "Lag Switch Mode",
    Values = {"Normal", "Demon"},
    Multi = false,
    Default = "Normal",
    Callback = function(Value)
        if LagSwitch then
            LagSwitch.setMode(Value)
        end
    end
})

LagDelayInput = MiscTab:AddInput("LagDelayInput", {
    Title = "Lag Delay (Seconds)",
    Default = "0.1",
    Placeholder = "Enter delay in seconds (0.1-5)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 and num <= 5 and LagSwitch then
            LagSwitch.setDelay(num)
        end
    end
})

LagIntensityInput = MiscTab:AddInput("LagIntensityInput", {
    Title = "Lag Intensity",
    Default = "1000000",
    Placeholder = "Enter intensity (1000-10000000)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 1000 and num <= 10000000 and LagSwitch then
            LagSwitch.setIntensity(num)
        end
    end
})

DemonRiseHeightInput = MiscTab:AddInput("DemonRiseHeightInput", {
    Title = "Demon Rise Height (meters)",
    Default = "10",
    Placeholder = "Enter rise height in meters (10-500)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 10 and num <= 500 then
            if LagSwitch then
                LagSwitch.setDemonHeight(num)
            end
            Fluent:Notify({
                Title = "Demon Mode",
                Content = string.format("Rise height set to %d meters", num),
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Demon Mode",
                Content = "Height must be between 10 and 500 meters",
                Duration = 3
            })
        end
    end
})

DemonRiseSpeedInput = MiscTab:AddInput("DemonRiseSpeedInput", {
    Title = "Demon Rise Speed",
    Default = "80",
    Placeholder = "Enter rise speed (20-200)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 20 and num <= 200 then
            if LagSwitch then
                LagSwitch.setDemonSpeed(num)
            end
            Fluent:Notify({
                Title = "Demon Mode",
                Content = string.format("Rise speed set to %d", num),
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Demon Mode",
                Content = "Speed must be between 20 and 200",
                Duration = 3
            })
        end
    end
})

LagSwitchButtonToggle = MiscTab:AddToggle("LagSwitchButtonToggle", {
    Title = "Lag Switch Button",
    Default = false,
    Callback = function(Value)
        if LagSwitch then
            LagSwitch.setGUI(Value)
        end
    end
})

LagSwitchKeybind = MiscTab:AddKeybind("LagSwitchKeybind", {
    Title = "Lag Switch Keybind",
    Mode = "Toggle",
    Default = "F12",
    ChangedCallback = function()
        if LagSwitch then
            LagSwitch.updateButtonLabel()
        end
    end,
    Callback = function()
        if LagSwitch then
            LagSwitch.toggle()
        end
    end
})

LagSwitchKeybind:OnChanged(function()
    if LagSwitch then
        LagSwitch.updateButtonLabel()
    end
end)

task.spawn(function()
    task.wait(1)
    if DemonRiseHeightInput then
        DemonRiseHeightInput:SetValue("100")
    end
    if DemonRiseSpeedInput then
        DemonRiseSpeedInput:SetValue("80")
    end
    if DemonSoftLandingToggle then
        DemonSoftLandingToggle:SetValue(true)
    end
end)

MiscTab:AddParagraph({
    Title = "Demon Mode Features",
    Content = "Demon mode combines lag switch with character elevation. Default height: 100 meters. You can adjust height and speed settings."
})

MiscTab:AddSection("Camera Adjustments", "solar/camera-bold")

local cameraStretchConnection = nil
local stretchHorizontal = 0.80
local stretchVertical = 0.80

local function setupCameraStretch()
    if cameraStretchConnection then 
        cameraStretchConnection:Disconnect() 
        cameraStretchConnection = nil
    end
    
    cameraStretchConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local Camera = workspace.CurrentCamera
        if Camera then
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, stretchHorizontal, 0, 0, 0, stretchVertical, 0, 0, 0, 1)
        end
    end)
end

CameraStretchToggle = MiscTab:AddToggle("CameraStretchToggle", {
    Title = "Camera Stretch",
    Default = false,
    Callback = function(Value)
        if Value then
            setupCameraStretch()
        else
            if cameraStretchConnection then
                cameraStretchConnection:Disconnect()
                cameraStretchConnection = nil
            end
        end
    end
})

CameraStretchHorizontalInput = MiscTab:AddInput("CameraStretchHorizontalInput", {
    Title = "Camera Stretch Horizontal",
    Default = "0.80",
    Placeholder = "Enter horizontal stretch value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            stretchHorizontal = num
            if Options.CameraStretchToggle and Options.CameraStretchToggle.Value then
                setupCameraStretch()
            end
        end
    end
})

CameraStretchVerticalInput = MiscTab:AddInput("CameraStretchVerticalInput", {
    Title = "Camera Stretch Vertical",
    Default = "0.80",
    Placeholder = "Enter vertical stretch value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            stretchVertical = num
            if Options.CameraStretchToggle and Options.CameraStretchToggle.Value then
                setupCameraStretch()
            end
        end
    end
})
MiscTab:AddSection("Client Modification", "solar/monitor-bold")

local ClientModification
do
    local ok, result = pcall(loadOnlineModule, "ClientModification.lua")
    ClientModification = ok and result or nil
    if not ok then
        warn("[Misc] Failed to load ClientModification.lua:", result)
    end
end

FullBrightToggle = MiscTab:AddToggle("FullBrightToggle", {
    Title = "Full Bright",
    Default = false,
    Callback = function(state)
        if not ClientModification then
            Fluent:Notify({ Title = "Misc", Content = "ClientModification module not loaded", Duration = 4 })
            return
        end
        ClientModification.setFullBright(state)
    end
})

AntiLag1 = MiscTab:AddButton({
    Title = "Anti lag 1",
    Callback = function()
        if not ClientModification then
            Fluent:Notify({ Title = "Misc", Content = "ClientModification module not loaded", Duration = 4 })
            return
        end
        ClientModification.antiLag1()
    end
})

AntiLag2 = MiscTab:AddButton({
    Title = "Anti lag 2",
    Callback = function()
        if not ClientModification then
            Fluent:Notify({ Title = "Misc", Content = "ClientModification module not loaded", Duration = 4 })
            return
        end
        ClientModification.antiLag2()
    end
})

AntiLag3 = MiscTab:AddButton({
    Title = "Remove Texture",
    Callback = function()
        if not ClientModification then
            Fluent:Notify({ Title = "Misc", Content = "ClientModification module not loaded", Duration = 4 })
            return
        end
        ClientModification.removeTextures()
    end
})

NoFogToggle = MiscTab:AddToggle("NoFogToggle", {
    Title = "Remove fog",
    Default = false,
    Callback = function(state)
        if not ClientModification then
            Fluent:Notify({ Title = "Misc", Content = "ClientModification module not loaded", Duration = 4 })
            return
        end
        ClientModification.setNoFog(state)
    end
})

local VisualTab = Window:AddTab({ Title = "Visual", Icon = "solar/gallery-bold", Favoriteable = true })

VisualTab:AddSection("Avatar Replacer", "solar/user-circle-bold")

local AvatarModule = nil
pcall(function()
    AvatarModule = loadOnlineModule("AvatarModule.lua")
end)

if AvatarModule then
    local avatarStatus = VisualTab:AddParagraph({
        Title = "Status",
        Content = "Click 'Refresh Players' to load."
    })

    AvatarPlayerDropdown = VisualTab:AddDropdown("AvatarPlayerDropdown", {
        Title = "Players on Server",
        Values = {},
        Multi = false,
        Default = "",
        Searchable = true,
    })

    VisualTab:AddButton({
        Title = "Refresh Players",
        Description = "Scan",
        Callback = function()
            local list = AvatarModule.Scan()
            pcall(function()
                AvatarPlayerDropdown:SetValues(list)
            end)
            
            if #list > 0 then
                pcall(function()
                    avatarStatus:SetDesc(string.format("Found %d players.", #list))
                end)
                Fluent:Notify({ Title = "Avatar", Content = "Found " .. #list .. " players", Duration = 3 })
            else
                pcall(function()
                    avatarStatus:SetDesc("No players found in cache.")
                end)
                Fluent:Notify({ Title = "Avatar", Content = "No players found", Duration = 3 })
            end
        end
    })

    VisualTab:AddButton({
        Title = "Apply Selected Avatar",
        Description = "Clone selected player's",
        Callback = function()
            local target = AvatarPlayerDropdown.Value
            if not target or target == "" then
                Fluent:Notify({ Title = "Avatar", Content = "No player selected", Duration = 3 })
                return
            end
            
            local ok, msg = AvatarModule.Apply(target)
            Fluent:Notify({ 
                Title = "Avatar", 
                Content = msg, 
                Duration = 4,
                Type = ok and "Success" or "Error"
            })
        end
    })

    VisualTab:AddButton({
        Title = "Restore My Avatar",
        Description = "Restore your original",
        Callback = function()
            local ok, msg = AvatarModule.Restore()
            Fluent:Notify({ 
                Title = "Avatar", 
                Content = msg, 
                Duration = 3,
                Type = ok and "Success" or "Error"
            })
        end
    })

else
    VisualTab:AddParagraph({
        Title = "Avatar Replacer",
        Content = "Failed to load AvatarModule.lua"
    })
end

local EmoteChanger, CosmeticModule, CarryAnimationModule, SkinsModule
do
    local ok, result = pcall(loadOnlineModule, "EmoteChanger.lua")
    EmoteChanger = ok and result or nil
    if not ok then
        warn("[Visual] Failed to load EmoteChanger.lua:", result)
    end

    ok, result = pcall(loadOnlineModule, "Cosmetic.lua")
    CosmeticModule = ok and result or nil
    if not ok then
        warn("[Visual] Failed to load Cosmetic.lua:", result)
    end

    ok, result = pcall(loadOnlineModule, "CarryAnimation.lua")
    CarryAnimationModule = ok and result or nil
    if not ok then
        warn("[Visual] Failed to load CarryAnimation.lua:", result)
    end

    ok, result = pcall(loadOnlineModule, "Skins.lua")
    SkinsModule = ok and result or nil
    if not ok then
        warn("[Visual] Failed to load Skins.lua:", result)
    end
end

VisualTab:AddSection("Emote Content Replacer", "solar/shuffle-bold")

local emoteStatusLabel = VisualTab:AddParagraph({
    Title = "Emote Content Replacer",
    Content = "List not loaded. Click 'Load Emotes' to load."
})

local TargetEmoteDropdown = VisualTab:AddDropdown("TargetEmoteDropdown", {
    Title = "Target Emote",
    Values = {},
    Multi = false,
    Default = "",
    Searchable = true,
})

local DonorEmoteDropdown = VisualTab:AddDropdown("DonorEmoteDropdown", {
    Title = "Donor Emote",
    Values = {},
    Multi = false,
    Default = "",
    Searchable = true,
})

local VariantDropdown = VisualTab:AddDropdown("VariantDropdown", {
    Title = "Animation Variant",
    Values = {},
    Multi = false,
    Default = "",
    Searchable = true,
})

DonorEmoteDropdown:OnChanged(function(value)
    if not value or value == "" then
        pcall(function() VariantDropdown:SetValues({}) VariantDropdown:SetValue("") end)
        return
    end
    
    if EmoteChanger and EmoteChanger.getSelectionVariants then
        local variants = EmoteChanger.getSelectionVariants(value)
        pcall(function()
            VariantDropdown:SetValues(variants)
            if #variants > 0 then
                VariantDropdown:SetValue(variants[1])
            else
                VariantDropdown:SetValue("")
            end
        end)
    end
end)

VisualTab:AddButton({
    Title = "Load Emotes",
    Description = "Scan and load all emotes",
    Callback = function()
        if not EmoteChanger then
            Fluent:Notify({ Title = "Visual", Content = "EmoteChanger module not loaded", Duration = 4 })
            return
        end
        local names, ok = EmoteChanger.scan()
        if not ok or #names == 0 then
            Fluent:Notify({ Title = "Visual", Content = "No emotes found", Duration = 3 })
            pcall(function()
                emoteStatusLabel:SetDesc("No emotes found.")
            end)
            return
        end

        pcall(function()
            TargetEmoteDropdown:SetValues(names)
            DonorEmoteDropdown:SetValues(names)
        end)

        pcall(function()
            emoteStatusLabel:SetDesc(string.format("Found emotes: %d", #names))
        end)

        Fluent:Notify({ Title = "Visual", Content = string.format("Loaded emotes: %d", #names), Duration = 3 })
    end
})

VisualTab:AddButton({
    Title = "Replace Emote Content",
    Description = "Replace target with donor",
    Callback = function()
        local target = TargetEmoteDropdown.Value
        local donor = DonorEmoteDropdown.Value
        local variant = VariantDropdown.Value

        if not target or target == "" then
            Fluent:Notify({ Title = "Visual", Content = "No target selected", Duration = 3 })
            return
        end
        if not donor or donor == "" then
            Fluent:Notify({ Title = "Visual", Content = "No donor selected", Duration = 3 })
            return
        end
        if target == donor then
            Fluent:Notify({ Title = "Visual", Content = "Target and donor are the same", Duration = 3 })
            return
        end

        if not EmoteChanger then
            Fluent:Notify({ Title = "Visual", Content = "EmoteChanger module not loaded", Duration = 4 })
            return
        end

        local ok, msg = EmoteChanger.replace(target, donor, variant)
        Fluent:Notify({ Title = "Visual", Content = msg, Duration = 4 })
    end
})

VisualTab:AddButton({
    Title = "Restore Emote Content",
    Description = "Restore original content of the target emote",
    Callback = function()
        local target = TargetEmoteDropdown.Value
        if not target or target == "" then
            Fluent:Notify({ Title = "Visual", Content = "No target selected", Duration = 3 })
            return
        end

        if not EmoteChanger then
            Fluent:Notify({ Title = "Visual", Content = "EmoteChanger module not loaded", Duration = 4 })
            return
        end

        local ok, msg = EmoteChanger.restore(target)
        Fluent:Notify({ Title = "Visual", Content = msg, Duration = 3 })
    end
})

VisualTab:AddSection("Cosmetic Content Replacer", "solar/shuffle-bold")

local cosmeticStatusLabel = VisualTab:AddParagraph({
    Title = "Cosmetic Content Replacer",
    Content = "List not loaded. Click 'Load Cosmetics' to load."
})

local TargetCosmeticDropdown = VisualTab:AddDropdown("TargetCosmeticDropdown", {
    Title = "Target Cosmetic",
    Values = {},
    Multi = false,
    Default = "",
    Searchable = true,
})

local DonorCosmeticDropdown = VisualTab:AddDropdown("DonorCosmeticDropdown", {
    Title = "Donor Cosmetic",
    Values = {},
    Multi = false,
    Default = "",
    Searchable = true,
})

VisualTab:AddButton({
    Title = "Load Cosmetics",
    Description = "Scan and load all cosmetics",
    Callback = function()
        if not CosmeticModule then
            Fluent:Notify({ Title = "Visual", Content = "Cosmetic module not loaded", Duration = 4 })
            return
        end
        local names, ok = CosmeticModule.scan()
        if not ok or #names == 0 then
            Fluent:Notify({ Title = "Visual", Content = "No cosmetics found", Duration = 3 })
            pcall(function()
                cosmeticStatusLabel:SetDesc("No cosmetics found.")
            end)
            return
        end

        pcall(function()
            TargetCosmeticDropdown:SetValues(names)
            DonorCosmeticDropdown:SetValues(names)
        end)

        pcall(function()
            cosmeticStatusLabel:SetDesc(string.format("Found cosmetics: %d", #names))
        end)

        Fluent:Notify({ Title = "Visual", Content = string.format("Loaded cosmetics: %d", #names), Duration = 3 })
    end
})

VisualTab:AddButton({
    Title = "Replace Cosmetic Content",
    Description = "Delete all target content and paste all donor content",
    Callback = function()
        local target = TargetCosmeticDropdown.Value
        local donor = DonorCosmeticDropdown.Value

        if not target or target == "" then
            Fluent:Notify({ Title = "Visual", Content = "No target selected", Duration = 3 })
            return
        end
        if not donor or donor == "" then
            Fluent:Notify({ Title = "Visual", Content = "No donor selected", Duration = 3 })
            return
        end
        if target == donor then
            Fluent:Notify({ Title = "Visual", Content = "Target and donor are the same", Duration = 3 })
            return
        end

        local ok, msg = CosmeticModule.replace(target, donor)
        Fluent:Notify({ Title = "Visual", Content = msg, Duration = 4 })
    end
})

VisualTab:AddButton({
    Title = "Restore Cosmetic Content",
    Description = "Restore original content of the target cosmetic",
    Callback = function()
        local target = TargetCosmeticDropdown.Value
        if not target or target == "" then
            Fluent:Notify({ Title = "Visual", Content = "No target selected", Duration = 3 })
            return
        end

        local ok, msg = CosmeticModule.restore(target)
        Fluent:Notify({ Title = "Visual", Content = msg, Duration = 3 })
    end
})

VisualTab:AddSection("CarryAnimation Content Replacer", "solar/shuffle-bold")
local carryStatusLabel = VisualTab:AddParagraph({
    Title = "CarryAnimation Content Replacer",
    Content = "List not loaded. Click 'Load Carry Animations' to load."
})

local TargetCarryDropdown = VisualTab:AddDropdown("TargetCarryDropdown", {
    Title = "Target CarryAnimation",
    Values = {},
    Multi = false,
    Default = "",
    Searchable = true,
})

local DonorCarryDropdown = VisualTab:AddDropdown("DonorCarryDropdown", {
    Title = "Donor CarryAnimation",
    Values = {},
    Multi = false,
    Default = "",
    Searchable = true,
})

VisualTab:AddButton({
    Title = "Load Carry Animations",
    Description = "Scan and load all carry animations",
    Callback = function()
        if not CarryAnimationModule then
            Fluent:Notify({ Title = "Visual", Content = "CarryAnimation module not loaded", Duration = 4 })
            return
        end
        local names, ok = CarryAnimationModule.scan()
        if not ok or #names == 0 then
            Fluent:Notify({ Title = "Visual", Content = "No carry animations found", Duration = 3 })
            pcall(function()
                carryStatusLabel:SetDesc("No carry animations found.")
            end)
            return
        end

        pcall(function()
            TargetCarryDropdown:SetValues(names)
            DonorCarryDropdown:SetValues(names)
        end)

        pcall(function()
            carryStatusLabel:SetDesc(string.format("Found carry animations: %d", #names))
        end)

        Fluent:Notify({ Title = "Visual", Content = string.format("Loaded carry animations: %d", #names), Duration = 3 })
    end
})

VisualTab:AddButton({
    Title = "Replace CarryAnimation Content",
    Description = "Delete all target content and paste all donor content",
    Callback = function()
        local target = TargetCarryDropdown.Value
        local donor = DonorCarryDropdown.Value

        if not target or target == "" then
            Fluent:Notify({ Title = "Visual", Content = "No target selected", Duration = 3 })
            return
        end
        if not donor or donor == "" then
            Fluent:Notify({ Title = "Visual", Content = "No donor selected", Duration = 3 })
            return
        end
        if target == donor then
            Fluent:Notify({ Title = "Visual", Content = "Target and donor are the same", Duration = 3 })
            return
        end

        local ok, msg = CarryAnimationModule.replace(target, donor)
        Fluent:Notify({ Title = "Visual", Content = msg, Duration = 4 })
    end
})

VisualTab:AddButton({
    Title = "Restore CarryAnimation Content",
    Description = "Restore original content of the target carry animation",
    Callback = function()
        local target = TargetCarryDropdown.Value
        if not target or target == "" then
            Fluent:Notify({ Title = "Visual", Content = "No target selected", Duration = 3 })
            return
        end

        local ok, msg = CarryAnimationModule.restore(target)
        Fluent:Notify({ Title = "Visual", Content = msg, Duration = 3 })
    end
})

VisualTab:AddSection("Skin Content Replacer", "solar/shuffle-bold")

local skinStatusLabel = VisualTab:AddParagraph({
    Title = "Skin Content Replacer",
    Content = "List not loaded. Click 'Load Skins' to load."
})

local TargetSkinDropdown = VisualTab:AddDropdown("TargetSkinDropdown", {
    Title = "Target Skin",
    Values = {},
    Multi = false,
    Default = "",
    Searchable = true,
})

local DonorSkinDropdown = VisualTab:AddDropdown("DonorSkinDropdown", {
    Title = "Donor Skin",
    Values = {},
    Multi = false,
    Default = "",
    Searchable = true,
})

VisualTab:AddButton({
    Title = "Load Skins",
    Description = "Scan and load all skins",
    Callback = function()
        if not SkinsModule then
            Fluent:Notify({ Title = "Visual", Content = "Skins module not loaded", Duration = 4 })
            return
        end
        local names, ok = SkinsModule.scan()
        if not ok or #names == 0 then
            Fluent:Notify({ Title = "Visual", Content = "No skins found", Duration = 3 })
            pcall(function()
                skinStatusLabel:SetDesc("No skins found.")
            end)
            return
        end

        pcall(function()
            TargetSkinDropdown:SetValues(names)
            DonorSkinDropdown:SetValues(names)
        end)

        pcall(function()
            skinStatusLabel:SetDesc(string.format("Found skins: %d", #names))
        end)

        Fluent:Notify({ Title = "Visual", Content = string.format("Loaded skins: %d", #names), Duration = 3 })
    end
})

VisualTab:AddButton({
    Title = "Replace Skin Content",
    Description = "Delete all target content and paste all donor content",
    Callback = function()
        local target = TargetSkinDropdown.Value
        local donor = DonorSkinDropdown.Value

        if not target or target == "" then
            Fluent:Notify({ Title = "Visual", Content = "No target selected", Duration = 3 })
            return
        end
        if not donor or donor == "" then
            Fluent:Notify({ Title = "Visual", Content = "No donor selected", Duration = 3 })
            return
        end
        if target == donor then
            Fluent:Notify({ Title = "Visual", Content = "Target and donor are the same", Duration = 3 })
            return
        end

        local ok, msg = SkinsModule.replace(target, donor)
        Fluent:Notify({ Title = "Visual", Content = msg, Duration = 4 })
    end
})

VisualTab:AddButton({
    Title = "Restore Skin Content",
    Description = "Restore original content of the target skin",
    Callback = function()
        local target = TargetSkinDropdown.Value
        if not target or target == "" then
            Fluent:Notify({ Title = "Visual", Content = "No target selected", Duration = 3 })
            return
        end

        local ok, msg = SkinsModule.restore(target)
        Fluent:Notify({ Title = "Visual", Content = msg, Duration = 3 })
    end
})

local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold", Favoriteable = false })

SettingsTab:AddSection("Configuration", "solar/settings-bold")

SettingsTab:AddSection("FPS, Ping, Timer Settings", "solar/chart-bold")

local function setFPSTimerVisible(state)
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local timerGUI = PlayerGui:FindFirstChild("DraconicFPS")

    if state then
        if not timerGUI then
            createSimpleTimer()
        else
            timerGUI.Enabled = true
        end
    elseif timerGUI then
        timerGUI.Enabled = false
    end
end

local FPSTimerToggle = SettingsTab:AddToggle("FPSTimerToggle", {
    Title = "Show FPS, Ping, Timer",
    Description = "Display FPS and session timer",
    Default = true,
    Callback = setFPSTimerVisible
})

FPSTimerToggle:OnChanged(setFPSTimerVisible)

task.spawn(function()
    task.wait(1.35)
    if Options.FPSTimerToggle then
        setFPSTimerVisible(Options.FPSTimerToggle.Value)
    end
end)

SettingsTab:AddSection("Interface Manager", "solar/widget-bold")
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("DraconicXEvade")
InterfaceManager:BuildInterfaceSection(SettingsTab)

local BLOOD_RED_ACCENT = Color3.fromRGB(255, 0, 0)
local BLOOD_RED_STROKE = Color3.fromRGB(139, 0, 0)
local themeFollowConnection = nil

local function currentThemeName()
    if type(Fluent.Theme) == "string" and Fluent.Theme ~= "" then
        return Fluent.Theme
    end
    local option = Options.InterfaceTheme
    if option and type(option.Value) == "string" and option.Value ~= "" then
        return option.Value
    end
    return "Blood Red"
end

local function colorId(color)
    return string.format(
        "%d,%d,%d",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

local function collectSequenceColors(sequence, into)
    if typeof(sequence) ~= "ColorSequence" then
        return
    end
    for _, keypoint in ipairs(sequence.Keypoints) do
        if typeof(keypoint.Value) == "Color3" then
            table.insert(into, keypoint.Value)
        end
    end
end

local function colorsByBrightness(colors)
    local seen = {}
    local unique = {}
    for _, color in ipairs(colors) do
        local id = colorId(color)
        if not seen[id] then
            seen[id] = true
            table.insert(unique, color)
        end
    end
    table.sort(unique, function(a, b)
        local _, _, valueA = Color3.toHSV(a)
        local _, _, valueB = Color3.toHSV(b)
        return valueA > valueB
    end)
    return unique
end

local function buildSpinGradient(colors)
    local bright = colors[1]
    local dark = colors[#colors]
    if #colors == 1 then
        return ColorSequence.new(bright, bright)
    end

    local points = { bright }
    for index = 2, #colors - 1 do
        table.insert(points, colors[index])
    end
    table.insert(points, dark)
    for index = #colors - 1, 2, -1 do
        table.insert(points, colors[index])
    end
    table.insert(points, bright)

    local keypoints = table.create(#points)
    for index, color in ipairs(points) do
        keypoints[index] = ColorSequenceKeypoint.new((index - 1) / (#points - 1), color)
    end
    return ColorSequence.new(keypoints)
end

local function currentThemeColors()
    local name = currentThemeName()
    if name == "Blood Red" then
        return BLOOD_RED_ACCENT, BLOOD_RED_STROKE, ColorSequence.new({
            ColorSequenceKeypoint.new(0, BLOOD_RED_ACCENT),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, BLOOD_RED_ACCENT),
        })
    end

    local gradients = Fluent.ButtonGradients
    local colors = {}
    if type(gradients) == "table" then
        collectSequenceColors(gradients.Stroke, colors)
        collectSequenceColors(gradients.Background, colors)
    end
    colors = colorsByBrightness(colors)
    if #colors == 0 then
        return BLOOD_RED_ACCENT, BLOOD_RED_STROKE, nil
    end

    local accent = colors[1]
    local stroke = accent
    if type(gradients) == "table" and typeof(gradients.Stroke) == "ColorSequence" then
        local first = gradients.Stroke.Keypoints[1]
        if first and typeof(first.Value) == "Color3" then
            stroke = first.Value
        end
    end
    if colorId(stroke) == colorId(accent) and #colors > 1 then
        stroke = colors[2]
    end
    if colorId(stroke) == colorId(accent) then
        local hue, saturation, value = Color3.toHSV(accent)
        stroke = Color3.fromHSV(hue, saturation, math.clamp(value * 0.55, 0, 1))
    end

    return accent, stroke, buildSpinGradient(colors)
end

local function applyOnlineScriptTheme()
    local accent, stroke, fill = currentThemeColors()
    if gradientButtonModule and gradientButtonModule.setThemeColor then
        gradientButtonModule.setThemeColor(accent, stroke, fill)
    end
    if simpleTimerModule and simpleTimerModule.setThemeColor then
        simpleTimerModule.setThemeColor(accent, stroke, fill)
    end
    if TimerModule and TimerModule.SetThemeColor then
        TimerModule.SetThemeColor(accent, stroke, fill)
    end

    if themeFollowConnection then
        themeFollowConnection:Disconnect()
        themeFollowConnection = nil
    end
    if currentThemeName() == "RGB" then
        themeFollowConnection = RunService.Heartbeat:Connect(function()
            if Fluent.Theme ~= "RGB" then
                if themeFollowConnection then
                    themeFollowConnection:Disconnect()
                    themeFollowConnection = nil
                end
                return
            end
            local liveAccent, liveStroke, liveFill = currentThemeColors()
            if gradientButtonModule and gradientButtonModule.setThemeColor then
                gradientButtonModule.setThemeColor(liveAccent, liveStroke, liveFill)
            end
            if simpleTimerModule and simpleTimerModule.setThemeColor then
                simpleTimerModule.setThemeColor(liveAccent, liveStroke, liveFill)
            end
            if TimerModule and TimerModule.SetThemeColor then
                TimerModule.SetThemeColor(liveAccent, liveStroke, liveFill)
            end
        end)
    end
end

if type(Fluent.SetTheme) == "function" then
    local originalSetTheme = Fluent.SetTheme
    Fluent.SetTheme = function(self, themeName, ...)
        local result = originalSetTheme(self, themeName, ...)
        task.defer(applyOnlineScriptTheme)
        return result
    end
end

applyOnlineScriptTheme()
task.defer(applyOnlineScriptTheme)

SettingsTab:AddSection("Save Manager", "solar/diskette-bold")
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("DraconicXEvade/Config")
SaveManager:BuildConfigSection(SettingsTab)

task.spawn(function()
    task.wait(1)
    SaveManager:LoadAutoloadConfig()
end)

SettingsTab:AddSection("GUI Button Sizes", "solar/widget-2-bold")

RespawnButtonSizeInput = SettingsTab:AddInput("RespawnButtonSizeInput", {
    Title = "Respawn Button Size",
    Default = "180",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("DraconicRespawnButtonGUI")

            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

CarryButtonSizeInput = SettingsTab:AddInput("CarryButtonSizeInput", {
    Title = "Carry Button Size",
    Default = "180",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")

            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

GravityButtonSizeInput = SettingsTab:AddInput("GravityButtonSizeInput", {
    Title = "Gravity Button Size",
    Default = "180",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")

            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale")
                    if uiScale then
                        uiScale:Destroy()
                    end
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

CrouchButtonSizeInput = SettingsTab:AddInput("CrouchButtonSizeInput", {
    Title = "Crouch Button Size",
    Default = "180",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("CrouchButtonGUI")

            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale")
                    if uiScale then
                        uiScale:Destroy()
                    end
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

SlideButtonScaleInput = SettingsTab:AddInput("SlideButtonScaleInput", {
    Title = "Sprint Slide Button Size",
    Default = "180",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("SlideButtonGUI")

            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale")
                    if uiScale then
                        uiScale:Destroy()
                    end
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

BhopButtonScaleInput = SettingsTab:AddInput("BhopButtonScaleInput", {
    Title = "Auto Jump Button Size",
    Default = "180",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("BhopButtonGUI")

            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale")
                    if uiScale then
                        uiScale:Destroy()
                    end
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

LagSwitchScaleInput = SettingsTab:AddInput("LagSwitchScaleInput", {
    Title = "Lag Switch Button Size",
    Default = "180",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("LagSwitchButtonGUI")

            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale")
                    if uiScale then
                        uiScale:Destroy()
                    end
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

SettingsTab:AddSection("Floating Menu Button", "solar/widget-2-bold")

FloatingButtonSizeInput = SettingsTab:AddInput("FloatingButtonSizeInput", {
    Title = "Floating Button Size",
    Default = "120",
    Placeholder = "Width px (80-400), base 120",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) and FloatingButton.setSize then
            FloatingButton.setSize(Value)
        end
    end
})

FloatingButtonSizeInput:OnChanged(function(Value)
    if Value and tonumber(Value) and FloatingButton.setSize then
        FloatingButton.setSize(Value)
    end
end)

FloatingButtonInvisibleToggle = SettingsTab:AddToggle("FloatingButtonInvisibleToggle", {
    Title = "Floating Button invisible",
    Description = "Hides icon but keeps it clickable",
    Default = false,
    Callback = function(Value)
        if FloatingButton.setStealth then
            FloatingButton.setStealth(Value)
        end
    end
})

FloatingButtonInvisibleToggle:OnChanged(function(Value)
    if FloatingButton.setStealth then
        FloatingButton.setStealth(Value)
    end
end)

task.spawn(function()
    task.wait(1.35)
    if Options.FloatingButtonSizeInput and tonumber(Options.FloatingButtonSizeInput.Value) and FloatingButton.setSize then
        FloatingButton.setSize(Options.FloatingButtonSizeInput.Value)
    end
    if Options.FloatingButtonInvisibleToggle and Options.FloatingButtonInvisibleToggle.Value and FloatingButton.setStealth then
        FloatingButton.setStealth(true)
    end
end)

SettingsTab:AddSection("Button Positions", "solar/cursor-bold")

local ButtonPositions = loadstring(game:HttpGet("https://raw.githubusercontent.com/uewfdiwe/756653/refs/heads/main/Online%20Script/ButtonPositions.lua"))()

SettingsTab:AddButton({
    Title = "Save Button Positions",
    Description = "Save current positions of all GUI buttons",
    Callback = function()
        local success, msg = ButtonPositions:Save()
        Fluent:Notify({
            Title = "Button Positions",
            Content = msg,
            Duration = 3
        })
    end
})

SettingsTab:AddButton({
    Title = "Load Button Positions",
    Description = "Load saved button positions from file",
    Callback = function()
        local success, msg = ButtonPositions:Load()
        Fluent:Notify({
            Title = "Button Positions",
            Content = msg,
            Duration = 3
        })
    end
})

SettingsTab:AddButton({
    Title = "Reset Button Positions",
    Description = "Reset all buttons to default positions",
    Callback = function()
        Window:Dialog({
            Title = "Reset Button Positions",
            Content = "Are you sure you want to reset all button positions to default?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        ButtonPositions:Reset()
                        Fluent:Notify({
                            Title = "Button Positions",
                            Content = "All buttons reset to default positions!",
                            Duration = 3
                        })
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                    end
                }
            }
        })
    end
})

local InfoTab = Window:AddTab({ Title = "Info", Icon = "solar/info-circle-bold", Favoriteable = false })

InfoTab:AddSection("Telegram Support", "solar/chat-round-bold")

InfoTab:AddParagraph({
    Title = "Telegram Support",
    Content = "Join our Telegram channel for updates and support"
})

InfoTab:AddButton({
    Title = "Copy Telegram Link",
    Description = "Click to copy Telegram link to clipboard",
    Callback = function()
        local telegramLink = "https://t.me/DraconicHub"


        setclipboard(telegramLink)

        Fluent:Notify({
            Title = "Telegram",
            Content = "Link copied to clipboard!",
            Duration = 3
        })
    end
})

InfoTab:AddSection("Discord Support", "solar/users-group-rounded-bold")

InfoTab:AddParagraph({
    Title = "Discord Server Support",
    Content = "Join our Discord Server for updates and support"
})

InfoTab:AddButton({
    Title = "Copy Discord Link",
    Description = "Click to copy Discord link to clipboard",
    Callback = function()
        local telegramLink = "https://discord.gg/F74VB7u"


        setclipboard(telegramLink)

        Fluent:Notify({
            Title = "Discord",
            Content = "Link copied to clipboard!",
            Duration = 3
        })
    end
})

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2) 


    if Options.PlayerToggle and Options.PlayerToggle.Value then
        if not ExternalESPLoaded or not _G.ExternalESPRunning then
            Fluent:Notify({
                Title = "ESP Players",
                Content = "Restoring Player ESP after respawn...",
                Duration = 3
            })


            cleanupPlayerESPObjects()


            ExternalESPLoaded = false
            ExternalESP = nil
            _G.ExternalESPRunning = false


            local success = pcall(function()
                ExternalESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/uewfdiwe/756653/refs/heads/main/Online%20Script/Esp.lua"))()
                ExternalESPLoaded = true
                _G.ExternalESPRunning = true
            end)

            if success then
                Fluent:Notify({
                    Title = "ESP Players",
                    Content = "Player ESP restored successfully!",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "ESP Players Error",
                    Content = "Failed to restore Player ESP",
                    Duration = 3
                })
                Options.PlayerToggle:Set(false)
            end
        end
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if Options.NextbotToggle and Options.NextbotToggle.Value then

        if ExternalNextbotESPLoaded and ExternalNextbotESP then
            if ExternalNextbotESP.Stop then
                pcall(ExternalNextbotESP.Stop)
            end
        end


        for model, data in pairs(NextbotBillboards) do
            if data.esp then
                data.esp:Destroy()
            end
        end
        NextbotBillboards = {}


        for model, tracer in pairs(botTracerElements) do
            if tracer and tracer.Remove then
                tracer:Remove()
            end
        end
        botTracerElements = {}
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)

    if Options.NextbotToggle and Options.NextbotToggle.Value then
        if ExternalNextbotESPLoaded and ExternalNextbotESP then
            if ExternalNextbotESP.Start then
                pcall(function()
                    ExternalNextbotESP.Start()
                    _G.NextbotESPRunning = true
                    Fluent:Notify({
                        Title = "ESP Nextbots",
                        Content = "Nextbot ESP restored after respawn!",
                        Duration = 3
                    })
                end)
            end
        end
    end

end)
