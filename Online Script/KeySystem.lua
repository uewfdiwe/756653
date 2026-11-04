game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Draconic Hub X Key System",
    Text = "Welcome Draconic Hub Remake",
    Icon = "rbxassetid://102225156206159",
    Duration = 5
})
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DraconicHubGui"
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 350)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BackgroundTransparency = 0.7
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Selectable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = mainFrame

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
}
mainGradient.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(139, 0, 0)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

local logoContainer = Instance.new("Frame")
logoContainer.Name = "LogoContainer"
logoContainer.Size = UDim2.new(0, 180, 0, 180)
logoContainer.Position = UDim2.new(0.5, -90, 0, -100)
logoContainer.BackgroundTransparency = 1
logoContainer.Parent = mainFrame

local spinningBackground = Instance.new("ImageLabel")
spinningBackground.Name = "SpinningBackground"
spinningBackground.Size = UDim2.new(1.5, 0, 1.5, 0)
spinningBackground.AnchorPoint = Vector2.new(0.5, 0.5)
spinningBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
spinningBackground.BackgroundTransparency = 1
spinningBackground.Image = "rbxassetid://116363566728532"
spinningBackground.ImageTransparency = 0.3
spinningBackground.ZIndex = 1
spinningBackground.Parent = logoContainer

local mainLogo = Instance.new("ImageLabel")
mainLogo.Name = "MainLogo"
mainLogo.Size = UDim2.new(0.8, 0, 0.8, 0)
mainLogo.AnchorPoint = Vector2.new(0.5, 0.5)
mainLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
mainLogo.BackgroundTransparency = 1
mainLogo.Image = "rbxassetid://102225156206159"
mainLogo.ZIndex = 2
mainLogo.Parent = logoContainer

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0.2, 0)
logoCorner.Parent = mainLogo

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 660, 0, 50)
titleLabel.Position = UDim2.new(0.5, -325, 0, 90)
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.BackgroundTransparency = 0.35
titleLabel.Text = "Draconic Hub X Key System"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 40
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 20)
titleCorner.Parent = titleLabel

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(139, 0, 0)
titleStroke.Thickness = 1.5
titleStroke.Parent = titleLabel

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0, 660, 0, 50)
keyInput.Position = UDim2.new(0.5, -325, 0, 155)
keyInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
keyInput.BackgroundTransparency = 0.35
keyInput.PlaceholderText = "Enter Key Here"
keyInput.PlaceholderColor3 = Color3.fromRGB(220, 220, 220)
keyInput.Text = ""
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.Font = Enum.Font.SourceSans
keyInput.TextSize = 35
keyInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 20)
inputCorner.Parent = keyInput

local keyInputStroke = Instance.new("UIStroke")
keyInputStroke.Color = Color3.fromRGB(139, 0, 0)
keyInputStroke.Thickness = 1.5
keyInputStroke.Parent = keyInput

local platformContainer = Instance.new("Frame")
platformContainer.Name = "PlatformContainer"
platformContainer.Size = UDim2.new(0, 660, 0, 50)
platformContainer.Position = UDim2.new(0.5, -325, 0, 215)
platformContainer.BackgroundTransparency = 1
platformContainer.Parent = mainFrame

local platformLabel = Instance.new("TextLabel")
platformLabel.Name = "PlatformLabel"
platformLabel.Size = UDim2.new(0, 150, 1, 0)
platformLabel.Position = UDim2.new(0, 0, 0, 0)
platformLabel.BackgroundTransparency = 1
platformLabel.Text = "Evade Mode:"
platformLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
platformLabel.Font = Enum.Font.SourceSansBold
platformLabel.TextSize = 28
platformLabel.TextXAlignment = Enum.TextXAlignment.Left
platformLabel.Parent = platformContainer

local mobileBtn = Instance.new("TextButton")
mobileBtn.Name = "MobileButton"
mobileBtn.Size = UDim2.new(0, 120, 0, 40)
mobileBtn.Position = UDim2.new(0, 160, 0.5, -20)
mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mobileBtn.BackgroundTransparency = 0.35
mobileBtn.Text = "🌟 Overhaul"
mobileBtn.Font = Enum.Font.SourceSansBold
mobileBtn.TextSize = 24
mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileBtn.Parent = platformContainer

local mobileCorner = Instance.new("UICorner")
mobileCorner.CornerRadius = UDim.new(0, 10)
mobileCorner.Parent = mobileBtn

local mobileStroke = Instance.new("UIStroke")
mobileStroke.Color = Color3.fromRGB(255, 0, 0)
mobileStroke.Thickness = 1.5
mobileStroke.Parent = mobileBtn

local pcBtn = Instance.new("TextButton")
pcBtn.Name = "PCButton"
pcBtn.Size = UDim2.new(0, 120, 0, 40)
pcBtn.Position = UDim2.new(0, 300, 0.5, -20)
pcBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pcBtn.BackgroundTransparency = 0.35
pcBtn.Text = "Legacy(Soon)"
pcBtn.Font = Enum.Font.SourceSansBold
pcBtn.TextSize = 24
pcBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
pcBtn.Parent = platformContainer

local pcCorner = Instance.new("UICorner")
pcCorner.CornerRadius = UDim.new(0, 10)
pcCorner.Parent = pcBtn

local pcStroke = Instance.new("UIStroke")
pcStroke.Color = Color3.fromRGB(139, 0, 0)
pcStroke.Thickness = 1.5
pcStroke.Parent = pcBtn

local selectedPlatform = "Mobile"

local function updatePlatformSelection(platform)
    selectedPlatform = platform
    
    if platform == "Mobile" then
        mobileStroke.Color = Color3.fromRGB(255, 0, 0)
        mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        pcStroke.Color = Color3.fromRGB(139, 0, 0)
        pcBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    else
        mobileStroke.Color = Color3.fromRGB(139, 0, 0)
        mobileBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        pcStroke.Color = Color3.fromRGB(255, 0, 0)
        pcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    showMessage("Selected: " .. platform, Color3.fromRGB(0, 200, 255))
end

mobileBtn.MouseButton1Click:Connect(function()
    updatePlatformSelection("Mobile")
end)

pcBtn.MouseButton1Click:Connect(function()
    updatePlatformSelection("PC")
end)

local function setupPlatformButtonHover(button)
    button.MouseEnter:Connect(function()
        if not (button == mobileBtn and selectedPlatform == "Mobile") and 
           not (button == pcBtn and selectedPlatform == "PC") then
            local stroke = button == mobileBtn and mobileStroke or pcStroke
            stroke.Color = Color3.fromRGB(180, 0, 0)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button == mobileBtn then
            if selectedPlatform == "Mobile" then
                mobileStroke.Color = Color3.fromRGB(255, 0, 0)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                mobileStroke.Color = Color3.fromRGB(139, 0, 0)
                button.TextColor3 = Color3.fromRGB(220, 220, 220)
            end
        else
            if selectedPlatform == "PC" then
                pcStroke.Color = Color3.fromRGB(255, 0, 0)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                pcStroke.Color = Color3.fromRGB(139, 0, 0)
                button.TextColor3 = Color3.fromRGB(220, 220, 220)
            end
        end
    end)
end

setupPlatformButtonHover(mobileBtn)
setupPlatformButtonHover(pcBtn)

local submitBtn = Instance.new("TextButton")
submitBtn.Name = "SubmitButton"
submitBtn.Size = UDim2.new(0, 260, 0, 60)
submitBtn.Position = UDim2.new(0, 25, 0, 280)
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
submitBtn.BackgroundTransparency = 0.35
submitBtn.Text = "Submit"
submitBtn.Font = Enum.Font.SourceSansBold
submitBtn.TextSize = 35
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Parent = mainFrame

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 20)
submitCorner.Parent = submitBtn

local submitStroke = Instance.new("UIStroke")
submitStroke.Color = Color3.fromRGB(139, 0, 0)
submitStroke.Thickness = 2
submitStroke.Parent = submitBtn

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Name = "GetKeyButton"
getKeyBtn.Size = UDim2.new(0, 260, 0, 60)
getKeyBtn.Position = UDim2.new(0, 420, 0, 280)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
getKeyBtn.BackgroundTransparency = 0.35
getKeyBtn.Text = "Locked"
getKeyBtn.Font = Enum.Font.SourceSansBold
getKeyBtn.TextSize = 35
getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyBtn.Parent = mainFrame

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 20)
getKeyCorner.Parent = getKeyBtn

local getKeyStroke = Instance.new("UIStroke")
getKeyStroke.Color = Color3.fromRGB(139, 0, 0)
getKeyStroke.Thickness = 2
getKeyStroke.Parent = getKeyBtn

RunService.RenderStepped:Connect(function(delta)
    local spin = (90 * delta)
    mainGradient.Rotation = (mainGradient.Rotation + spin) % 360
end)

local errorLabel = Instance.new("TextLabel")
errorLabel.Size = UDim2.new(0, 660, 0, 40)
errorLabel.Position = UDim2.new(0.5, -325, 0, 360)
errorLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
errorLabel.BackgroundTransparency = 0.5
errorLabel.Text = ""
errorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
errorLabel.Font = Enum.Font.SourceSansBold
errorLabel.TextSize = 25
errorLabel.Visible = false
errorLabel.Parent = mainFrame

local errorCorner = Instance.new("UICorner")
errorCorner.CornerRadius = UDim.new(0, 10)
errorCorner.Parent = errorLabel

local rotationSpeed = 0.5
local currentRotation = 0

local function animateLogo()
    while true do
        task.wait()
        currentRotation = (currentRotation + rotationSpeed) % 360
        spinningBackground.Rotation = currentRotation
    end
end

task.spawn(animateLogo)

local service = 16094
local secret = "9bfce86e-a6fc-4baf-93d8-4d77a2254e41"
local useNonce = true

local TEST_MODE = true
local TEST_KEYS = {
    ["FREE_KEY"] = true,
    ["FREE_TEST"] = true,
    ["FREE_ACCESS"] = true
}

local HttpService = game:GetService("HttpService")

local fSetClipboard = setclipboard or toclipboard or writeclipboard or (syn and syn.write_clipboard)
local fRequest = request or http_request or (syn and syn.request) or (http and http.request)
local fStringChar = string.char
local fToString = tostring
local fStringSub = string.sub
local fOsTime = os.time
local fMathRandom = math.random
local fMathFloor = math.floor
local fGetHwid = gethwid or function() 
    return tostring(game:GetService("Players").LocalPlayer.UserId)
end

local function lEncode(data)
    return HttpService:JSONEncode(data)
end

local function lDecode(data)
    local success, result = pcall(function()
        return HttpService:JSONDecode(data)
    end)
    return success and result or nil
end

local function lDigest(input)
    local hash = 0
    for i = 1, #input do
        hash = (hash * 31 + string.byte(input, i)) % 2^32
    end
    return tostring(hash)
end

local host = "https://api.platoboost.com"

if fRequest then
    local success, hostResponse = pcall(function()
        return fRequest({
            Url = host .. "/public/connectivity",
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    if not success or (hostResponse and (hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429)) then
        host = "https://api.platoboost.net"
    end
end

local cachedLink, cachedTime = "", 0
local requestSending = false

local function cacheLink()
    if requestSending then
        return false, "A request is already being sent"
    end
    
    if cachedTime + (10 * 60) > fOsTime() and cachedLink ~= "" then
        return true, cachedLink
    end
    
    requestSending = true
    
    local hwid = fGetHwid()
    local data = {
        service = service,
        identifier = lDigest(hwid)
    }
    
    
    local success, response = pcall(function()
        return fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode(data),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    requestSending = false
    
    if not success or not response then
        return false, "Failed to connect to Platoboost"
    end
    
    
    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        
        if decoded and decoded.success == true then
            cachedLink = decoded.data.url
            cachedTime = fOsTime()
            return true, cachedLink
        else
            return false, decoded and decoded.message or "Failed to get link"
        end
    elseif response.StatusCode == 429 then
        return false, "Rate limited. Please wait 20 seconds"
    else
        return false, "Server error: " .. tostring(response.StatusCode)
    end
end

local function generateNonce()
    local str = ""
    for _ = 1, 16 do
        str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
    end
    return str
end

local function redeemKey(key)
    
    local nonce = generateNonce()
    local endpoint = host .. "/public/redeem/" .. fToString(service)
    
    local body = {
        identifier = lDigest(fGetHwid()),
        key = key
    }
    
    if useNonce then
        body.nonce = nonce
    end
    
    local response = fRequest({
        Url = endpoint,
        Method = "POST",
        Body = lEncode(body),
        Headers = {
            ["Content-Type"] = "application/json"
        }
    })
    
    if response and response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        
        if decoded and decoded.success == true then
            if decoded.data.valid == true then
                if useNonce then
                    if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                        return true, "Key activated successfully!"
                    else
                        return false, "Failed to verify integrity"
                    end
                else
                    return true, "Key activated successfully!"
                end
            else
                return false, "Key is invalid"
            end
        else
            if decoded and string.sub(decoded.message, 1, 27) == "unique constraint violation" then
                return false, "You already have an active key, please wait for it to expire"
            else
                return false, decoded and decoded.message or "Activation failed"
            end
        end
    elseif response and response.StatusCode == 429 then
        return false, "You are being rate limited, please wait 20 seconds"
    else
        return false, "Server returned an invalid status code: " .. tostring(response and response.StatusCode or "No response")
    end
end

local function verifyKey(key)
    if requestSending then
        return false, "A request is already being sent, please slow down"
    end
    
    if key == "" or key == nil then
        return false, "Please enter a key"
    end
    
    key = string.gsub(key, "%s+", "")
    
    
    if TEST_MODE then
        
        if TEST_KEYS[key] then
            return true, "Test key accepted! Loading..."
        end
        
        if string.sub(key, 1, 5):upper() == "FREE_" and string.len(key) > 10 then
            return true, "Free key accepted! Loading..."
        end
    end
    
    requestSending = true
    
    local hwid = fGetHwid()
    local nonce = useNonce and generateNonce() or ""
    
    local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(hwid) .. "&key=" .. key
    
    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce
    end
    
    
    local success, response = pcall(function()
        return fRequest({
            Url = endpoint,
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    requestSending = false
    
    if not success or not response then
        return false, "Failed to connect to verification server"
    end
    
    
    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        
        if decoded then
            
            if decoded.success == true then
                if decoded.data.valid == true then
                    if useNonce then
                        if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                            return true, "Key verified successfully!"
                        else
                            return false, "Security verification failed"
                        end
                    else
                        return true, "Key verified successfully!"
                    end
                else
                    local redeemSuccess, redeemMessage = redeemKey(key)
                    
                    if redeemSuccess then
                        return true, redeemMessage
                    else
                        return false, redeemMessage or "Key is invalid or expired"
                    end
                end
            else
                return false, decoded.message or "Verification failed"
            end
        else
            return false, "Invalid server response"
        end
    elseif response.StatusCode == 429 then
        return false, "Rate limited. Please wait 20 seconds"
    else
        return false, "Server error: " .. tostring(response.StatusCode)
    end
end

local function showMessage(text, color)
    errorLabel.Text = text
    errorLabel.TextColor3 = color
    errorLabel.Visible = true
    
    task.spawn(function()
        task.wait(3)
        errorLabel.Visible = false
    end)
end

local function executeScript()
    rotationSpeed = 0
    screenGui.Enabled = false
    
    showMessage("Loading Draconic Hub (" .. selectedPlatform .. ")...", Color3.fromRGB(0, 255, 0))
    
    local success, errorMsg = pcall(function()
        if selectedPlatform == "Mobile" then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/uewfdiwe/756653/refs/heads/main/Online%20Script/Script.lua"))()
        else
            loadstring(game:HttpGet(""))()
        end
    end)
    
    if not success then
        screenGui.Enabled = true
        rotationSpeed = 0.5
        showMessage("Script error: " .. tostring(errorMsg), Color3.fromRGB(255, 50, 50))
        
        submitBtn.Text = "Submit"
        submitStroke.Color = Color3.fromRGB(139, 0, 0)
        submitBtn.TextSize = 35
        submitBtn.AutoButtonColor = true
    end
end

submitBtn.MouseButton1Click:Connect(function()
    
    local enteredKey = keyInput.Text
    
    if enteredKey == "" then
        showMessage("Please enter a key!", Color3.fromRGB(255, 255, 0))
        return
    end
    
    submitBtn.Text = "Checking..."
    submitStroke.Color = Color3.fromRGB(255, 0, 0)
    submitBtn.TextSize = 30
    submitBtn.AutoButtonColor = false
    
    task.spawn(function()
        task.wait(0.5)
        
        local success, message = verifyKey(enteredKey)
        
        if success then
            showMessage(message, Color3.fromRGB(50, 255, 50))
            rotationSpeed = 3
            
            for i = 1, 10 do
                submitStroke.Color = Color3.fromRGB(50, 255 - i*10, 50)
                task.wait(0.05)
            end
            
            task.wait(1)
            executeScript()
        else
            showMessage("Error: " .. message, Color3.fromRGB(255, 50, 50))
            
            submitBtn.Text = "Submit"
            submitStroke.Color = Color3.fromRGB(139, 0, 0)
            submitBtn.TextSize = 35
            submitBtn.AutoButtonColor = true
            rotationSpeed = 0.5
            
            local originalPos = keyInput.Position
            for i = 1, 5 do
                keyInput.Position = UDim2.new(0.5, -325 + math.random(-5, 5), 0, 155 + math.random(-2, 2))
                task.wait(0.05)
            end
            keyInput.Position = originalPos
            
            keyInputStroke.Color = Color3.fromRGB(255, 0, 0)
            task.wait(0.5)
            keyInputStroke.Color = Color3.fromRGB(139, 0, 0)
        end
    end)
end)

getKeyBtn.MouseButton1Click:Connect(function()
    
    getKeyBtn.Text = "Getting Link..."
    getKeyStroke.Color = Color3.fromRGB(255, 0, 0)
    getKeyBtn.TextSize = 30
    getKeyBtn.AutoButtonColor = false
    rotationSpeed = 2
    
    task.spawn(function()
        task.wait(999999999.5)
        
        local success, link = cacheLink()
        
        if success then
            if fSetClipboard then
                local copySuccess = pcall(function()
                    fSetClipboard(link)
                end)
                
                if copySuccess then
                    showMessage("Link copied to clipboard!", Color3.fromRGB(50, 150, 255))
                    
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Draconic Hub",
                            Text = "Link copied! Open in browser",
                            Duration = 5
                        })
                    end)
                else
                    showMessage("Link: " .. link, Color3.fromRGB(50, 150, 255))
                end
            else
                showMessage("Link: " .. link, Color3.fromRGB(50, 150, 255))
            end
        else
            showMessage("Error: " .. link, Color3.fromRGB(255, 50, 50))
        end
        
        getKeyBtn.Text = "Locked"
        getKeyStroke.Color = Color3.fromRGB(139, 0, 0)
        getKeyBtn.TextSize = 35
        getKeyBtn.AutoButtonColor = true
        rotationSpeed = 0.5
    end)
end)

local function setupButtonHover(button)
    local stroke = button == submitBtn and submitStroke or getKeyStroke
    
    button.MouseEnter:Connect(function()
        stroke.Color = Color3.fromRGB(255, 0, 0)
        rotationSpeed = 1.5
    end)
    
    button.MouseLeave:Connect(function()
        stroke.Color = Color3.fromRGB(139, 0, 0)
        rotationSpeed = 0.5
    end)
end

setupButtonHover(submitBtn)
setupButtonHover(getKeyBtn)

logoContainer.MouseEnter:Connect(function()
    rotationSpeed = 2
    mainLogo.ImageTransparency = 0.2
end)

logoContainer.MouseLeave:Connect(function()
    rotationSpeed = 0.5
    mainLogo.ImageTransparency = 0
end)

local dragging, dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local userInputService = game:GetService("UserInputService")
local guiVisible = true

userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    end
end)

task.spawn(function()
    task.wait(1)
    if TEST_MODE then
        showMessage("TEST MODE: FREE keys accepted", Color3.fromRGB(255, 255, 0))
    else
        showMessage("Click 'Get Key' to get access link", Color3.fromRGB(255, 255, 255))
    end
end)

keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        submitBtn.MouseButton1Click:Fire()
    end
end)

if TEST_MODE then
    task.spawn(function()
        task.wait(1)
        keyInput.Text = "FREE_KEY"
        showMessage("Test key inserted automatically", Color3.fromRGB(0, 255, 0))
    end)
end

task.spawn(function()
    task.wait(2)
    local success, link = cacheLink()
    if success then
    else
    end
end)
