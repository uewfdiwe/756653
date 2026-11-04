local ClientModification = {}

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local state = {
    FullBright = false,
    originalBrightness = nil,
    originalAmbient = nil,
    originalOutdoorAmbient = nil,
    originalColorShiftBottom = nil,
    originalColorShiftTop = nil,
    fullBrightConnection = nil,
    fullBrightCharConnection = nil,
    originalFogEnd = nil,
    originalAtmospheres = nil,
}

local function applyFullBright()
    if Lighting.Brightness ~= 1 then
        Lighting.Brightness = 1
    end
    if Lighting.Ambient ~= Color3.new(1, 1, 1) then
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
    if Lighting.OutdoorAmbient ~= Color3.new(1, 1, 1) then
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end
    if Lighting.ColorShift_Bottom ~= Color3.new(1, 1, 1) then
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
    end
    if Lighting.ColorShift_Top ~= Color3.new(1, 1, 1) then
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    end
end

function ClientModification.setFullBright(enabled)
    state.FullBright = enabled
    if enabled then
        state.originalBrightness = Lighting.Brightness
        state.originalAmbient = Lighting.Ambient
        state.originalOutdoorAmbient = Lighting.OutdoorAmbient
        state.originalColorShiftBottom = Lighting.ColorShift_Bottom
        state.originalColorShiftTop = Lighting.ColorShift_Top

        applyFullBright()

        if state.fullBrightConnection then
            state.fullBrightConnection:Disconnect()
        end

        state.fullBrightConnection = RunService.Heartbeat:Connect(function()
            if state.FullBright then
                applyFullBright()
            end
        end)

        state.fullBrightCharConnection = Players.LocalPlayer.CharacterAdded:Connect(function()
            task.wait(1)
            if state.FullBright then
                applyFullBright()
            end
        end)
    else
        if state.fullBrightConnection then
            state.fullBrightConnection:Disconnect()
            state.fullBrightConnection = nil
        end

        if state.fullBrightCharConnection then
            state.fullBrightCharConnection:Disconnect()
            state.fullBrightCharConnection = nil
        end

        if state.originalBrightness then
            Lighting.Brightness = state.originalBrightness
            Lighting.Ambient = state.originalAmbient
            Lighting.OutdoorAmbient = state.originalOutdoorAmbient
            Lighting.ColorShift_Bottom = state.originalColorShiftBottom
            Lighting.ColorShift_Top = state.originalColorShiftTop
        end
    end
end

function ClientModification.antiLag1()
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    local LocalPlayer = Players.LocalPlayer

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 1

    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj:Destroy()
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("Accessory") or part:IsA("Clothing") then
                    part:Destroy()
                end
            end
        end
    end
end

function ClientModification.antiLag2()
    local ToDisable = {
        Textures = true,
        VisualEffects = true,
        Parts = true,
        Particles = true,
        Sky = true
    }

    local ToEnable = {
        FullBright = false
    }

    local Stuff = {}

    for _, v in next, game:GetDescendants() do
        if ToDisable.Parts then
            if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                table.insert(Stuff, 1, v)
            end
        end

        if ToDisable.Particles then
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then
                v.Enabled = false
                table.insert(Stuff, 1, v)
            end
        end

        if ToDisable.VisualEffects then
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
                table.insert(Stuff, 1, v)
            end
        end

        if ToDisable.Textures then
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Texture = ""
                table.insert(Stuff, 1, v)
            end
        end

        if ToDisable.Sky then
            if v:IsA("Sky") then
                v.Parent = nil
                table.insert(Stuff, 1, v)
            end
        end
    end

    if ToEnable.FullBright then
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        Lighting.FogEnd = math.huge
        Lighting.FogStart = math.huge
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 5
        Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Outlines = true
    end
end

function ClientModification.removeTextures()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("WedgePart") or part:IsA("CornerWedgePart") then
            if part:IsA("Part") then
                part.Material = Enum.Material.SmoothPlastic
            end
            if part:FindFirstChildWhichIsA("Texture") then
                local texture = part:FindFirstChildWhichIsA("Texture")
                texture.Texture = "rbxassetid://0"
            end
            if part:FindFirstChildWhichIsA("Decal") then
                local decal = part:FindFirstChildWhichIsA("Decal")
                decal.Texture = "rbxassetid://0"
            end
        end
    end
end

function ClientModification.setNoFog(enabled)
    if enabled then
        state.originalFogEnd = Lighting.FogEnd
        state.originalAtmospheres = {}

        for _, atmosphere in ipairs(Lighting:GetChildren()) do
            if atmosphere:IsA("Atmosphere") then
                table.insert(state.originalAtmospheres, atmosphere:Clone())
            end
        end

        Lighting.FogEnd = 1000000
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then
                v:Destroy()
            end
        end
    else
        if state.originalFogEnd then
            Lighting.FogEnd = state.originalFogEnd
        end

        if state.originalAtmospheres then
            for _, atmosphere in ipairs(state.originalAtmospheres) do
                if not atmosphere.Parent then
                    local newAtmosphere = Instance.new("Atmosphere")
                    for _, prop in pairs({"Density", "Offset", "Color", "Decay", "Glare", "Haze"}) do
                        if atmosphere[prop] then
                            newAtmosphere[prop] = atmosphere[prop]
                        end
                    end
                    newAtmosphere.Parent = Lighting
                end
            end
        end
    end
end

return ClientModification
