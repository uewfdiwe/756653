local EventTab = Window:AddTab({ Title = "Event", Icon = "calendar" })

EventTab:AddSection("Modification Event")

-- Загружаем внешний модуль Lupen ESP
local LupenESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Test%20Script/LupenESP.lua"))()
LupenESPModule:Init(Fluent, Options)

-- Добавляем тумблер
local LupenESPToggle = EventTab:AddToggle("LupenESPToggle", {
    Title = "ESP Lupen",
    Default = false,
    Callback = function(state)
        if state then
            LupenESPModule:Start()
        else
            LupenESPModule:Stop()
        end
    end
})

-- ==================== AUTO FARM LUPEN (ROTATION MODE) ====================
-- Добавьте этот код в конец файла ScriptMobile.lua, например, после раздела Auto Ticket Farm

-- Переменные для Auto Farm Lupen
local AutoLupenConnection = nil
local AutoLupenEnabled = false
local LupenTarget = nil
local RotationAngle = 0
local RotationRadius = 1 -- Радиус вращения вокруг Lupen
local RotationSpeed = 15 -- Скорость вращения

-- Функция для поиска Lupen в workspace.Game.Players
local function findLupen()
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return nil end
    
    -- Ищем персонажа с именем "Lupen"
    local lupen = gamePlayers:FindFirstChild("Lupen")
    if not lupen then 
        -- Альтернативный поиск: ищем по части имени
        for _, playerObj in ipairs(gamePlayers:GetChildren()) do
            if playerObj.Name:lower():find("lupen") then
                lupen = playerObj
                break
            end
        end
    end
    
    return lupen
end

-- Основная функция Auto Farm Lupen
local function startAutoLupen()
    if AutoLupenConnection then return end
    
    local securityPart = workspace:FindFirstChild("SecurityPart")
    RotationAngle = 0 -- Сбрасываем угол при старте
    
    AutoLupenConnection = RunService.Heartbeat:Connect(function()
        if not AutoLupenEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Проверяем, не лежит ли игрок
        if character:GetAttribute("Downed") then
            -- Автоматическое возрождение
            pcall(function()
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end)
            
            if securityPart then
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
            end
            return
        end
        
        -- Находим Lupen
        local lupen = findLupen()
        if not lupen then
            -- Если Lupen не найден, стоим на месте
            if securityPart then
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
            end
            return
        end
        
        -- Получаем HumanoidRootPart Lupen
        local lupenHRP = lupen:FindFirstChild("HumanoidRootPart")
        if not lupenHRP then return end
        
        -- Увеличиваем угол вращения
        RotationAngle = (RotationAngle + RotationSpeed) % 360
        
        -- Рассчитываем позицию по кругу вокруг Lupen
        local radAngle = math.rad(RotationAngle)
        local offsetX = math.cos(radAngle) * RotationRadius
        local offsetZ = math.sin(radAngle) * RotationRadius
        
        -- Позиция: центр Lupen + смещение по кругу + высота
        local targetPosition = Vector3.new(
            lupenHRP.Position.X + offsetX,
            lupenHRP.Position.Y + 1, -- Немного выше, чтобы не застревать
            lupenHRP.Position.Z + offsetZ
        )
        
        -- Телепортируемся на рассчитанную позицию
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
    end)
    
    Fluent:Notify({
        Title = "Auto Farm Lupen",
        Content = "Now teleporting around Lupen!",
        Duration = 3
    })
end

local function stopAutoLupen()
    if AutoLupenConnection then
        AutoLupenConnection:Disconnect()
        AutoLupenConnection = nil
    end
    
    Fluent:Notify({
        Title = "Auto Farm Lupen",
        Content = "Stopped following Lupen.",
        Duration = 3
    })
end

-- Добавляем тумблер в Auto Farm вкладку
AutoLupenToggle = EventTab:AddToggle("AutoLupenToggle", {
    Title = "Auto Farm Lupen",
    Default = false,
    Callback = function(state)
        AutoLupenEnabled = state
        if state then
            startAutoLupen()
        else
            stopAutoLupen()
        end
    end
})

-- Обновляем при респавне
LocalPlayer.CharacterAdded:Connect(function()
    if AutoLupenEnabled then
        -- Небольшая задержка, чтобы персонаж успел загрузиться
        task.wait(1)
        if AutoLupenEnabled then
            stopAutoLupen()
            startAutoLupen()
        end
    end
end)
