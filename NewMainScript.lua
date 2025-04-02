local old_require = require
getgenv().require = function(path)
    setthreadidentity(2)
    local _ = old_require(path)
    setthreadidentity(8)
    return _
end

-- Load the whitelist manager
local success, WhitelistManager = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/wrealaero/whitelistcheck/main/whitelist_manager.lua"))()
end)

if not success or not WhitelistManager then
    warn("Failed to load whitelist manager")
    game.StarterGui:SetCore("SendNotification", {
        Title = "Error",
        Text = "Failed to load whitelist system",
        Duration = 2
    })
    return
end

-- Check if player is whitelisted
local player = game.Players.LocalPlayer
local userId = tostring(player.UserId)
local isWhitelisted, userTier = WhitelistManager:isWhitelisted(userId)

if not isWhitelisted then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Fuck nah u thought",
        Text = "ur not whitelisted nn lmao",
        Duration = 2
    })
    return
end

-- User is whitelisted, continue with script
-- Store tier information for later use
shared.UserTier = userTier

-- File system utilities
local isfile = isfile or function(file)
    local suc, res = pcall(function() return readfile(file) end)
    return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
    pcall(function() writefile(file, '') end)
end

-- Download file with improved error handling
local function downloadFile(path, func)
    if not isfile(path) then
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/pifaifiohawiohh8924920904444ffsfszcz/DHOHDOAHDA-HDDDA/' .. readfile('newvape/profiles/commit.txt') .. '/' .. select(1, path:gsub('newvape/', '')), true)
        end)
        
        if not suc or res == '404: Not Found' then
            warn("Failed to download file: " .. tostring(res))
            return nil
        end
        
        if path:find('.lua') then
            res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
        end
        
        pcall(function() writefile(path, res) end)
    end
    
    return (func or readfile)(path)
end

-- Wipe folder
local function wipeFolder(path)
    if not isfolder(path) then return end
    
    for _, file in pairs(listfiles(path)) do
        if file:find('loader') then continue end
        
        if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
            delfile(file)
        end
    end
end

-- Create necessary folders
for _, folder in pairs({'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'}) do
    if not isfolder(folder) then
        pcall(function() makefolder(folder) end)
    end
end

-- Check for updates
if not shared.VapeDeveloper then
    local retries = 3
    local subbed
    
    while retries > 0 do
        local success, response = pcall(function()
            return game:HttpGet('https://github.com/pifaifiohawiohh8924920904444ffsfszcz/DHOHDOAHDA-HDDDA')
        end)
        
        if success and response then
            subbed = response
            break
        end
        
        retries = retries - 1
        wait(1)
    end
    
    if subbed then
        local commit = subbed:find('currentOid')
        commit = commit and subbed:sub(commit + 13, commit + 52) or nil
        commit = commit and #commit == 40 and commit or 'main'
        
        if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
            wipeFolder('newvape')
            wipeFolder('newvape/games')
            wipeFolder('newvape/guis')
            wipeFolder('newvape/libraries')
        end
        
        pcall(function() writefile('newvape/profiles/commit.txt', commit) end)
    end
end

-- Load main script
local success, err = pcall(function()
    loadstring(downloadFile('newvape/main.lua'), 'main')()
end)

if not success then
    warn("Failed to load script: " .. tostring(err))
end
