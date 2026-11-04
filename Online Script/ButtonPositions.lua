-- ButtonPositions.lua
-- External module for saving and loading button positions

local ButtonPositions = {}

-- List of all GUI buttons
local buttonGUIs = {
    "DraconicRespawnButtonGUI",
    "AutoCarryButtonGUI",
    "SlideButtonGUI",
    "GravityButtonGUI",
    "CrouchButtonGUI",
    "BhopButtonGUI",
    "LagSwitchButtonGUI",
}

-- Collect current positions
function ButtonPositions:Collect()
    local positions = {}
    local CoreGui = game:GetService("CoreGui")
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    for _, guiName in ipairs(buttonGUIs) do
        local gui = CoreGui:FindFirstChild(guiName)
        if gui then
            local button = gui:FindFirstChild("GradientBtn")
            if button then
                positions[guiName] = {
                    Position = {
                        X = { Scale = button.Position.X.Scale, Offset = button.Position.X.Offset },
                        Y = { Scale = button.Position.Y.Scale, Offset = button.Position.Y.Offset }
                    }
                }
            end
        end
    end
    
    local fpsGui = playerGui:FindFirstChild("DraconicFPS")
    if fpsGui then
        local container = fpsGui:FindFirstChild("Frame")
        if container then
            positions["DraconicFPS"] = {
                Position = {
                    X = { Scale = container.Position.X.Scale, Offset = container.Position.X.Offset },
                    Y = { Scale = container.Position.Y.Scale, Offset = container.Position.Y.Offset }
                }
            }
        end
    end
    
    return positions
end

-- Apply positions
function ButtonPositions:Apply(positions)
    local CoreGui = game:GetService("CoreGui")
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    for guiName, data in pairs(positions) do
        if guiName == "DraconicFPS" then
            local fpsGui = playerGui:FindFirstChild("DraconicFPS")
            if fpsGui then
                local container = fpsGui:FindFirstChild("Frame")
                if container and data.Position then
                    container.Position = UDim2.new(
                        data.Position.X.Scale, data.Position.X.Offset,
                        data.Position.Y.Scale, data.Position.Y.Offset
                    )
                end
            end
        else
            local gui = CoreGui:FindFirstChild(guiName)
            if gui then
                local button = gui:FindFirstChild("GradientBtn")
                if button and data.Position then
                    button.Position = UDim2.new(
                        data.Position.X.Scale, data.Position.X.Offset,
                        data.Position.Y.Scale, data.Position.Y.Offset
                    )
                end
            end
        end
    end
end

-- Save to file
function ButtonPositions:Save()
    local positions = self:Collect()
    
    local success, err = pcall(function()
        local fileName = "DraconicX_ButtonPositions.json"
        local configData = {
            ButtonPositions = positions,
            SavedAt = os.date("%Y-%m-%d %H:%M:%S")
        }
        
        local jsonData = game:GetService("HttpService"):JSONEncode(configData)
        
        if writefile then
            writefile(fileName, jsonData)
            return true, "Saved to " .. fileName
        else
            return false, "writefile not available"
        end
    end)
    
    if not success then
        return false, tostring(err)
    end
    
    return true, "Saved successfully"
end

-- Load from file
function ButtonPositions:Load()
    local fileName = "DraconicX_ButtonPositions.json"
    
    if readfile and isfile and isfile(fileName) then
        local success, err = pcall(function()
            local jsonData = readfile(fileName)
            local configData = game:GetService("HttpService"):JSONDecode(jsonData)
            if configData and configData.ButtonPositions then
                self:Apply(configData.ButtonPositions)
                return true, "Loaded from file"
            end
        end)
        
        if success then
            return true, "Loaded successfully"
        else
            return false, tostring(err)
        end
    end
    
    return false, "File not found"
end

-- Reset to default positions
function ButtonPositions:Reset()
    local CoreGui = game:GetService("CoreGui")
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    local defaultPositions = {
        DraconicRespawnButtonGUI = { X = 0.5, Y = 0.5 },
        InstantReviveButtonGUI = { X = 0.5, Y = 0.6 },
        AutoCarryButtonGUI = { X = 0.5, Y = 0.7 },
        SlideButtonGUI = { X = 0.5, Y = 0.5 },
        GravityButtonGUI = { X = 0.5, Y = 0.55 },
        BhopButtonGUI = { X = 0.5, Y = 0.5 },
        LagSwitchButtonGUI = { X = 0.5, Y = 0.5 },
        DraconicFPS = { X = 0, Y = 0 },
        BacktrackButtonGUI = { X = 0.5, Y = 0.5 }
    }
    
    for guiName, defaultPos in pairs(defaultPositions) do
        if guiName == "DraconicFPS" then
            local fpsGui = playerGui:FindFirstChild("DraconicFPS")
            if fpsGui then
                local container = fpsGui:FindFirstChild("Frame")
                if container then
                    container.Position = UDim2.new(defaultPos.X, 10, defaultPos.Y, 10)
                end
            end
        else
            local gui = CoreGui:FindFirstChild(guiName)
            if gui then
                local button = gui:FindFirstChild("GradientBtn")
                if button then
                    local btnWidth = button.Size.X.Offset
                    local btnHeight = button.Size.Y.Offset
                    button.Position = UDim2.new(defaultPos.X, -btnWidth/2, defaultPos.Y, -btnHeight/2)
                end
            end
        end
    end
    
    return true
end

-- Auto load on script start
task.spawn(function()
    task.wait(3)
    ButtonPositions:Load()
end)

return ButtonPositions
