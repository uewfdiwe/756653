local ServerList = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local SAVE_PATH = "DraconicXEvade/ServerList.json"
local servers = {}

local function parseIndex(selected)
    if type(selected) ~= "string" or selected == "" then
        return nil
    end
    return tonumber(selected:match("#(%d+)"))
end

function ServerList.load()
    servers = {}
    pcall(function()
        if typeof(isfile) == "function" and typeof(readfile) == "function" then
            if isfile(SAVE_PATH) then
                local content = readfile(SAVE_PATH)
                if content and #content > 0 then
                    local decoded = HttpService:JSONDecode(content)
                    if type(decoded) == "table" then
                        servers = decoded
                    end
                end
            end
        end
    end)
    return ServerList.format()
end

function ServerList.save()
    pcall(function()
        if typeof(writefile) == "function" and typeof(makefolder) == "function" then
            if typeof(isfolder) == "function" and not isfolder("DraconicXEvade") then
                makefolder("DraconicXEvade")
            end
            writefile(SAVE_PATH, HttpService:JSONEncode(servers))
        end
    end)
end

function ServerList.format()
    local display = {}
    for i in ipairs(servers) do
        table.insert(display, "server#" .. i)
    end
    return display
end

function ServerList.addCurrent()
    local jobId = game.JobId
    if not jobId or jobId == "" then
        return false, "JobId not available", ServerList.format()
    end

    for _, existing in ipairs(servers) do
        if existing == jobId then
            return false, "Server already in list", ServerList.format()
        end
    end

    table.insert(servers, jobId)
    ServerList.save()
    return true, "Added server #" .. #servers, ServerList.format()
end

function ServerList.removeSelected(selected)
    local index = parseIndex(selected)
    if not index then
        return false, "No server selected", ServerList.format()
    end

    if not servers[index] then
        return false, "Invalid selection", ServerList.format()
    end

    table.remove(servers, index)
    ServerList.save()
    return true, "Removed server #" .. index, ServerList.format()
end

function ServerList.joinSelected(selected)
    local index = parseIndex(selected)
    if not index then
        return false, "No server selected"
    end

    local jobId = servers[index]
    if not jobId then
        return false, "Server not found"
    end

    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
    end)

    if success then
        return true, "Joining server #" .. index
    end
    return false, "Failed: " .. tostring(err)
end

return ServerList
