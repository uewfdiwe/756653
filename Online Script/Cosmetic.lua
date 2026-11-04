local Cosmetic = {}

local cosmeticRegistry = {}
local originalCosmeticContents = {}

function Cosmetic.scan()
    cosmeticRegistry = {}
    local found = false

    local roots = {
        game:GetService("ReplicatedStorage"):FindFirstChild("Items")
            and game:GetService("ReplicatedStorage").Items:FindFirstChild("ItemPacks"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Items")
            and game:GetService("ReplicatedStorage").Items:FindFirstChild("BaseItems"),
    }

    local function collectModules(parent, pathPrefix)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ModuleScript") then
                local key = child.Name
                if cosmeticRegistry[key] then
                    local i = 2
                    while cosmeticRegistry[key .. " (" .. i .. ")"] do
                        i = i + 1
                    end
                    key = key .. " (" .. i .. ")"
                end
                cosmeticRegistry[key] = {
                    module = child,
                    path = pathPrefix .. "." .. child.Name,
                    realName = child.Name,
                }
                found = true
            elseif child:IsA("Folder") then
                collectModules(child, pathPrefix .. "." .. child.Name)
            end
        end
    end

    local function walk(parent, pathPrefix, depth)
        if depth > 15 then return end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("Folder") then
                if child.Name == "Cosmetics" then
                    collectModules(child, pathPrefix .. "." .. child.Name)
                else
                    walk(child, pathPrefix .. "." .. child.Name, depth + 1)
                end
            end
        end
    end

    for _, root in ipairs(roots) do
        if root then
            pcall(function()
                walk(root, "ReplicatedStorage.Items." .. root.Name, 0)
            end)
        end
    end

    local names = {}
    for name, _ in pairs(cosmeticRegistry) do
        table.insert(names, name)
    end
    table.sort(names)

    return names, found
end

local function saveOriginalCosmetic(name)
    if originalCosmeticContents[name] then return end
    local entry = cosmeticRegistry[name]
    if not entry then return end

    local saved = {
        children = {},
        name = nil,
        desc = nil,
        creator = nil,
        icon = nil,
        header = nil,
    }

    for _, child in ipairs(entry.module:GetChildren()) do
        saved.children[child.Name] = child:Clone()
    end

    local ok, data = pcall(require, entry.module)
    if ok and type(data) == "table" then
        if data.AppearanceInfo then
            saved.name = data.AppearanceInfo.Name
            saved.desc = data.AppearanceInfo.Desc
            saved.creator = data.AppearanceInfo.Creator
            saved.icon = data.AppearanceInfo.Icon
        end
        if data.UIInfo then
            saved.header = data.UIInfo.Header
        end
    end

    originalCosmeticContents[name] = saved
end

function Cosmetic.replace(targetName, donorName)
    local targetEntry = cosmeticRegistry[targetName]
    local donorEntry = cosmeticRegistry[donorName]
    if not targetEntry or not donorEntry then
        return false, "Cosmetic not found in registry"
    end

    saveOriginalCosmetic(targetName)

    local donorChildren = donorEntry.module:GetChildren()
    if #donorChildren == 0 then
        return false, "Donor has no children"
    end

    local removedCount = 0
    for _, child in ipairs(targetEntry.module:GetChildren()) do
        child:Destroy()
        removedCount = removedCount + 1
    end

    local addedCount = 0
    for _, child in ipairs(donorChildren) do
        local clone = child:Clone()
        clone.Parent = targetEntry.module
        addedCount = addedCount + 1
    end

    local okTarget, targetData = pcall(require, targetEntry.module)
    local okDonor, donorData = pcall(require, donorEntry.module)

    if okTarget and okDonor and type(targetData) == "table" and type(donorData) == "table" then
        if donorData.AppearanceInfo then
            targetData.AppearanceInfo = targetData.AppearanceInfo or {}
            
            if donorData.AppearanceInfo.Name then
                targetData.AppearanceInfo.Name = donorData.AppearanceInfo.Name
            end
            if donorData.AppearanceInfo.Desc then
                targetData.AppearanceInfo.Desc = donorData.AppearanceInfo.Desc
            end
            if donorData.AppearanceInfo.Creator then
                targetData.AppearanceInfo.Creator = donorData.AppearanceInfo.Creator
            end
            if donorData.AppearanceInfo.Icon then
                targetData.AppearanceInfo.Icon = donorData.AppearanceInfo.Icon
            end
        end
        
        -- ★ Копируем Header
        if donorData.UIInfo and donorData.UIInfo.Header then
            targetData.UIInfo = targetData.UIInfo or {}
            targetData.UIInfo.Header = donorData.UIInfo.Header
        end
    end

    return true, string.format(
        "Removed %d, added %d objects from '%s' to '%s' (Name, Desc, Creator, Icon, Header)",
        removedCount, addedCount, donorName, targetName
    )
end

function Cosmetic.restore(targetName)
    local saved = originalCosmeticContents[targetName]
    if not saved then
        return false, "Original not saved (replace was not performed)"
    end
    local entry = cosmeticRegistry[targetName]
    if not entry then
        return false, "Module not found"
    end

    for _, child in ipairs(entry.module:GetChildren()) do
        child:Destroy()
    end

    local restored = 0
    for _, clone in pairs(saved.children or {}) do
        local newClone = clone:Clone()
        newClone.Parent = entry.module
        restored = restored + 1
    end

    local ok, data = pcall(require, entry.module)
    if ok and type(data) == "table" then
        data.AppearanceInfo = data.AppearanceInfo or {}
        if saved.name ~= nil then data.AppearanceInfo.Name = saved.name end
        if saved.desc ~= nil then data.AppearanceInfo.Desc = saved.desc end
        if saved.creator ~= nil then data.AppearanceInfo.Creator = saved.creator end
        if saved.icon ~= nil then data.AppearanceInfo.Icon = saved.icon end
        
        if saved.header ~= nil then
            data.UIInfo = data.UIInfo or {}
            data.UIInfo.Header = saved.header
        end
    end

    return true, string.format("Restored %d objects + properties for '%s'", restored, targetName)
end

return Cosmetic
