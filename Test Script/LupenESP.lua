-- Lupen ESP Module
-- Специальное выделение для игрока Lupen зелёным цветом

local LupenESP = {}
local Fluent = nil
local Options = nil

function LupenESP:Init(fluentLibrary, optionsTable)
    Fluent = fluentLibrary
    Options = optionsTable
end

-- Внутренние переменные модуля
local moduleState = {
    Enabled = false,
    Highlight = nil,
    Billboard = nil,
    Tracer = nil,  -- Добавлено для Tracer
    Connection = nil,
    TracerConnection = nil,  -- Отдельное соединение для Tracer
    MonitorConnection = nil,
    ChildAddedConnection = nil,
    ChildRemovedConnection = nil,
    PlayerName = "Bee"
}

-- Функция для создания зелёного ESP для Lupen
local function createLupenESP()
    -- Очищаем предыдущие объекты
    if moduleState.Highlight then
        pcall(function() moduleState.Highlight:Destroy() end)
        moduleState.Highlight = nil
    end
    
    if moduleState.Billboard then
        pcall(function() moduleState.Billboard:Destroy() end)
        moduleState.Billboard = nil
    end
    
    if moduleState.Tracer then
        pcall(function() moduleState.Tracer:Remove() end)
        moduleState.Tracer = nil
    end
    
    -- Ищем игрока Lupen в workspace.Game.Players
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return false end
    
    local lupenModel = gamePlayers:FindFirstChild(moduleState.PlayerName)
    if not lupenModel then return false end
    
    -- Находим HumanoidRootPart для позиционирования
    local hrp = lupenModel:FindFirstChild("HumanoidRootPart") or 
                lupenModel:FindFirstChild("Torso") or 
                lupenModel:FindFirstChild("UpperTorso") or
                lupenModel:FindFirstChild("Head")
    
    if not hrp then return false end
    
    -- ===== 1. СОЗДАЁМ HIGHLIGHT (ЗЕЛЁНОЕ СВЕЧЕНИЕ) =====
    local highlight = Instance.new("Highlight")
    highlight.Name = "BeeHighlight"
    highlight.Adornee = lupenModel
    highlight.FillColor = Color3.fromRGB(255, 255, 0)  -- Зелёный
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = lupenModel
    
    moduleState.Highlight = highlight
    
    -- ===== 2. СОЗДАЁМ BILLBOARD GUI (ТЕКСТ НАД ГОЛОВОЙ) =====
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BeeESP"
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.ClipsDescendants = false
    
    -- Единый текст: Lupen - [расстояние]
    local mainLabel = Instance.new("TextLabel")
    mainLabel.Name = "MainLabel"
    mainLabel.Size = UDim2.new(1, 0, 1, 0)
    mainLabel.BackgroundTransparency = 1
    mainLabel.Text = "Bee"
    mainLabel.TextColor3 = Color3.fromRGB(255, 255, 0)  -- Зелёный
    mainLabel.TextStrokeColor3 = Color3.fromRGB(0, 100, 0)
    mainLabel.TextStrokeTransparency = 0
    mainLabel.TextSize = 16
    mainLabel.Font = Enum.Font.RobotoMono
    mainLabel.TextXAlignment = Enum.TextXAlignment.Center
    mainLabel.TextYAlignment = Enum.TextYAlignment.Center
    mainLabel.Parent = billboard
    
    billboard.Parent = lupenModel
    
    moduleState.Billboard = billboard
    
    -- ===== 3. СОЗДАЁМ TRACER (ЗЕЛЁНАЯ ЛИНИЯ) =====
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 2
    tracer.Color = Color3.fromRGB(255, 255, 0)  -- Зелёный
    tracer.Transparency = 1
    tracer.ZIndex = 2
    
    moduleState.Tracer = tracer
    
    -- Функция для обновления расстояния и Tracer
    local function updateDistanceAndTracer()
        if not moduleState.Enabled or not billboard or not billboard.Parent then return end
        
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if not character then return end
        
        local playerHRP = character:FindFirstChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        -- Обновляем ссылку на HRP если нужно
        if not hrp or not hrp.Parent then
            hrp = lupenModel:FindFirstChild("HumanoidRootPart") or 
                  lupenModel:FindFirstChild("Torso") or 
                  lupenModel:FindFirstChild("UpperTorso") or
                  lupenModel:FindFirstChild("Head")
            if hrp then
                billboard.Adornee = hrp
            else
                return
            end
        end
        
        -- Обновляем расстояние в тексте
        if hrp and playerHRP then
            local distance = (playerHRP.Position - hrp.Position).Magnitude
            mainLabel.Text = string.format("Bee - [%.0fm]", distance)
        end
        
        -- Обновляем Tracer
        if tracer and hrp and playerHRP and camera then
            local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
            local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                tracer.Visible = true
                tracer.From = screenBottomCenter
                tracer.To = Vector2.new(vector.X, vector.Y)
            else
                tracer.Visible = false
            end
        end
    end
    
    -- Запускаем обновление
    if moduleState.Connection then
        moduleState.Connection:Disconnect()
    end
    
    moduleState.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if moduleState.Enabled and billboard and billboard.Parent then
            updateDistanceAndTracer()
        end
    end)
    
    print("[Bee ESP] Created for", moduleState.PlayerName)
    return true
end

-- Функция для удаления ESP Lupen
local function removeLupenESP()
    if moduleState.Highlight then
        pcall(function() moduleState.Highlight:Destroy() end)
        moduleState.Highlight = nil
    end
    
    if moduleState.Billboard then
        pcall(function() moduleState.Billboard:Destroy() end)
        moduleState.Billboard = nil
    end
    
    if moduleState.Tracer then
        pcall(function() moduleState.Tracer:Remove() end)
        moduleState.Tracer = nil
    end
    
    if moduleState.Connection then
        moduleState.Connection:Disconnect()
        moduleState.Connection = nil
    end
    
    print("[Bee ESP] Removed")
end

-- Функция для поиска и применения ESP к Lupen
local function checkForLupen()
    if not moduleState.Enabled then return end
    
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return end
    
    local lupenModel = gamePlayers:FindFirstChild(moduleState.PlayerName)
    
    if lupenModel and not (moduleState.Highlight and moduleState.Highlight.Parent) then
        -- Lupen появился и ESP ещё не создано
        createLupenESP()
    elseif not lupenModel and (moduleState.Highlight or moduleState.Billboard or moduleState.Tracer) then
        -- Lupen исчез, удаляем ESP
        removeLupenESP()
    end
end

-- Публичные методы модуля
function LupenESP:Start()
    if moduleState.Enabled then return end
    
    moduleState.Enabled = true
    print("[Bee ESP] Starting...")
    
    -- Проверяем сразу
    checkForLupen()
    
    -- Запускаем мониторинг появления Lupen
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if gamePlayers then
        -- Отслеживаем добавление новых игроков
        moduleState.ChildAddedConnection = gamePlayers.ChildAdded:Connect(function(child)
            if moduleState.Enabled and child.Name == moduleState.PlayerName then
                task.wait(0.5) -- Даем время на загрузку
                checkForLupen()
            end
        end)
        
        -- Отслеживаем удаление игроков
        moduleState.ChildRemovedConnection = gamePlayers.ChildRemoved:Connect(function(child)
            if moduleState.Enabled and child.Name == moduleState.PlayerName then
                removeLupenESP()
            end
        end)
    end
    
    -- Также проверяем каждые 2 секунды для надежности
    moduleState.MonitorConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if moduleState.Enabled then
            checkForLupen()
        end
    end)
    
    if Fluent then
        Fluent:Notify({
            Title = "Bee ESP",
            Content = "Enable",
            Duration = 3
        })
    end
end

function LupenESP:Stop()
    if not moduleState.Enabled then return end
    
    moduleState.Enabled = false
    print("[Bee ESP] Stopping...")
    
    -- Удаляем ESP
    removeLupenESP()
    
    -- Отключаем все соединения
    if moduleState.MonitorConnection then
        moduleState.MonitorConnection:Disconnect()
        moduleState.MonitorConnection = nil
    end
    
    if moduleState.ChildAddedConnection then
        moduleState.ChildAddedConnection:Disconnect()
        moduleState.ChildAddedConnection = nil
    end
    
    if moduleState.ChildRemovedConnection then
        moduleState.ChildRemovedConnection:Disconnect()
        moduleState.ChildRemovedConnection = nil
    end
    
    if Fluent then
        Fluent:Notify({
            Title = "Bee ESP",
            Content = "Disabled",
            Duration = 3
        })
    end
end

function LupenESP:Refresh()
    if moduleState.Enabled then
        removeLupenESP()
        task.wait(0.2)
        checkForLupen()
    end
end

function LupenESP:IsEnabled()
    return moduleState.Enabled
end

-- Автоматическое восстановление при респавне игрока
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if moduleState.Enabled then
        LupenESP:Refresh()
    end
end)

return LupenESP
