local old_require = require
getgenv().require = function(path)
    local thread_identity = syn and syn.set_thread_identity or setthreadidentity
    if thread_identity then thread_identity(2) end
    local result = old_require(path)
    if thread_identity then thread_identity(8) end
    return result
end

local WHITELIST_URL = "https://raw.githubusercontent.com/wrealaero/whitelistcheck/main/whitelist.json"
local player = game:GetService("Players").LocalPlayer
local userId = tostring(player.UserId)

local function fetchWhitelist()
    local success, response = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)
    
    if success and response then
        local successDecode, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(response)
        end)
        if successDecode then return data end
    end
    return nil
end

local whitelist = fetchWhitelist()
if not (whitelist and whitelist[userId]) then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Access Denied",
        Text = "You are not whitelisted.",
        Duration = 3
    })
    return
end

local function safeReadFile(path)
    local success, content = pcall(readfile, path)
    return success and content or nil
end

local function safeWriteFile(path, content)
    pcall(writefile, path, content)
end

local function isFile(path)
    return safeReadFile(path) ~= nil
end

local function deleteFile(path)
    pcall(function() writefile(path, '') end)
end

local function downloadFile(path, func)
    if not isFile(path) then
        local success, content = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/pifaifiohawiohh8924920904444ffsfszcz/DHOHDOAHDA-HDDDA/" ..
                safeReadFile("newvape/profiles/commit.txt") .. "/" .. path:gsub("newvape/", ""), true)
        end)
        
        if not success or content == "404: Not Found" then
            warn("Failed to download file: " .. tostring(content))
            return nil
        end
        
        if path:find(".lua") then
            content = "-- Cache Control Marker\n" .. content
        end
        
        safeWriteFile(path, content)
    end
    return (func or readfile)(path)
end

local function wipeFolder(path)
    if not isfolder(path) then return end
    for _, file in ipairs(listfiles(path)) do
        if file:find("loader") then continue end
        if isfile(file) and safeReadFile(file):find("-- Cache Control Marker") then
            deleteFile(file)
        end
    end
end

for _, folder in ipairs({"newvape", "newvape/games", "newvape/profiles", "newvape/assets", "newvape/libraries", "newvape/guis"}) do
    if not isfolder(folder) then
        pcall(makefolder, folder)
    end
end

if not shared.VapeDeveloper then
    local _, subbed = pcall(function()
        return game:HttpGet("https://github.com/pifaifiohawiohh8924920904444ffsfszcz/DHOHDOAHDA-HDDDA")
    end)
    
    if subbed then
        local commit = subbed:match("currentOid":"([a-f0-9]+)") or "main"
        local currentCommit = safeReadFile("newvape/profiles/commit.txt") or ""
        
        if commit == "main" or currentCommit ~= commit then
            wipeFolder("newvape")
            wipeFolder("newvape/games")
            wipeFolder("newvape/guis")
            wipeFolder("newvape/libraries")
        end
        
        safeWriteFile("newvape/profiles/commit.txt", commit)
    end
end

local success, err = pcall(function()
    loadstring(downloadFile("newvape/main.lua"), "main")()
end)

if not success then
    warn("Script execution failed: " .. tostring(err))
end
