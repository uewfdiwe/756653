local EventTab = Window:AddTab({ Title = "Event", Icon = "calendar" })

EventTab:AddSection("Battlepass Modifications")

-- Первый тумблер: Unlocked Pass
local UnlockedPassToggle = EventTab:AddToggle("UnlockedPassToggle", {
    Title = "Unlocked Time Pass",
    Default = false,
    Callback = function(state)
        if state then
            -- Включаем скрытие
            if not featureStates.UnlockedPassLoop then
                featureStates.UnlockedPassLoop = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local menu = game:GetService("Players").LocalPlayer.PlayerGui.Menu
                        if menu and menu.Views and menu.Views.Battlepass and menu.Views.Battlepass.ViewPass then
                            local center = menu.Views.Battlepass.ViewPass.Center
                            if center and center.ViewPass and center.ViewPass.Unlocked then
                                center.ViewPass.Unlocked.Visible = false
                            end
                        end
                    end)
                end)
            end
        else
            -- Отключаем скрытие
            if featureStates.UnlockedPassLoop then
                featureStates.UnlockedPassLoop:Disconnect()
                featureStates.UnlockedPassLoop = nil
                
                -- Восстанавливаем видимость
                pcall(function()
                    local menu = game:GetService("Players").LocalPlayer.PlayerGui.Menu
                    if menu and menu.Views and menu.Views.Battlepass and menu.Views.Battlepass.ViewPass then
                        local center = menu.Views.Battlepass.ViewPass.Center
                        if center and center.ViewPass and center.ViewPass.Unlocked then
                            center.ViewPass.Unlocked.Visible = true
                        end
                    end
                end)
            end
        end
    end
})

-- Второй тумблер: Exchange Open
local ExchangeOpenToggle = EventTab:AddToggle("ExchangeOpenToggle", {
    Title = "Open Exchange",
    Default = false,
    Callback = function(state)
        if state then
            -- Включаем открытие Exchange
            if not featureStates.ExchangeOpenLoop then
                featureStates.ExchangeOpenLoop = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local menu = game:GetService("Players").LocalPlayer.PlayerGui.Menu
                        if menu and menu.Views and menu.Views.Battlepass then
                            -- Показываем Exchange
                            if menu.Views.Battlepass.Exchange then
                                menu.Views.Battlepass.Exchange.Visible = true
                            end
                            
                            -- Скрываем ViewPass
                            if menu.Views.Battlepass.ViewPass then
                                menu.Views.Battlepass.ViewPass.Visible = false
                            end
                        end
                    end)
                end)
            end
        else
            -- Отключаем
            if featureStates.ExchangeOpenLoop then
                featureStates.ExchangeOpenLoop:Disconnect()
                featureStates.ExchangeOpenLoop = nil
                
                -- Восстанавливаем стандартный вид
                pcall(function()
                    local menu = game:GetService("Players").LocalPlayer.PlayerGui.Menu
                    if menu and menu.Views and menu.Views.Battlepass then
                        -- Восстанавливаем Exchange
                        if menu.Views.Battlepass.Exchange then
                            menu.Views.Battlepass.Exchange.Visible = false
                        end
                        
                        -- Восстанавливаем ViewPass
                        if menu.Views.Battlepass.ViewPass then
                            menu.Views.Battlepass.ViewPass.Visible = true
                        end
                    end
                end)
            end
        end
    end
})

EventTab:AddSection("Info Unlocked Time Pass")

EventTab:AddParagraph({
    Title = "Pass 1-9",
    Content = "Buy Items 5"
})

EventTab:AddParagraph({
    Title = "Pass 10-18", 
    Content = "Buy Items 5"
})

EventTab:AddParagraph({
    Title = "Pass 19-25",
    Content = "Buy Items 5"
})
