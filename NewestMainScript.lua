local old_require = require
getgenv().require = function(path)
    setthreadidentity(2)
    local _ = old_require(path)
    setthreadidentity(8)
    return _
end

local whitelist_url = "https://raw.githubusercontent.com/wrealaero/whitelistcheck/main/whitelist.json"
local player = game.Players.LocalPlayer
local userId = tostring(player.UserId)

local function getWhitelist()
    local success, response = pcall(function()
        return game:HttpGet(whitelist_url)
    end)

    if success and response then
        local successDecode, whitelist = pcall(function()
            return game:GetService("HttpService"):JSONDecode(response)
        end)

        if successDecode then
            return whitelist
        end
    end
    return nil
end

-- Check Executor Compatibility
local CheatEngineMode = false
local function checkExecutor()
    if identifyexecutor ~= nil and type(identifyexecutor) == "function" then
        local suc, res = pcall(function()
            return identifyexecutor()
        end)

        -- List of blacklisted executors that are known to cause issues
        local blacklist = {'solara', 'cryptic', 'xeno'}
        local core_blacklist = {'solara', 'xeno'}

        if suc then
            -- Check for blacklisted executors
            for i, v in pairs(blacklist) do
                if string.find(string.lower(tostring(res)), v) then
                    CheatEngineMode = true
                end
            end

            -- Core blacklist handling for specific executors
            for i, v in pairs(core_blacklist) do
                if string.find(string.lower(tostring(res)), v) then
                    pcall(function()
                        getgenv().queue_on_teleport = function() warn('queue_on_teleport disabled!') end
                    end)
                end
            end
        end
    end
end

-- Run the checkExecutor function
task.spawn(function() pcall(checkExecutor) end)

-- Function to handle when CheatEngineMode is enabled (bad executer detected)
local function handleBadExecutor()
    if CheatEngineMode then
        warn("Bad or unsupported executor detected! Some features may not work as intended.")
        -- You can disable certain features or functions here if necessary
    end
end

-- Call handleBadExecutor to adjust behavior when a bad executor is detected
task.spawn(function() pcall(handleBadExecutor) end)

-- Executor Compatibility Adjustments
if (not getgenv) or (getgenv and type(getgenv) ~= "function") then
    CheatEngineMode = true
end

if getgenv and not getgenv().shared then
    CheatEngineMode = true
    getgenv().shared = {}
end

if getgenv and not getgenv().debug then
    CheatEngineMode = true
    getgenv().debug = {traceback = function(string) return string end}
end

if getgenv and not getgenv().require then
    CheatEngineMode = true
end

if getgenv and getgenv().require and type(getgenv().require) ~= "function" then
    CheatEngineMode = true
end

-- Debug check function to ensure compatibility
local debugChecks = {
    Type = "table",
    Functions = {
        "getupvalue",
        "getupvalues",
        "getconstants",
        "getproto"
    }
}

local function checkDebug()
    if CheatEngineMode then return end
    if not getgenv().debug then
        CheatEngineMode = true
    else
        if type(debug) ~= debugChecks.Type then
            CheatEngineMode = true
        else
            for i, v in pairs(debugChecks.Functions) do
                if not debug[v] or (debug[v] and type(debug[v]) ~= "function") then
                    CheatEngineMode = true
                else
                    local suc, res = pcall(debug[v])
                    if tostring(res) == "Not Implemented" then
                        CheatEngineMode = true
                    end
                end
            end
        end
    end
end

if (not CheatEngineMode) then checkDebug() end

-- Your Original Script Logic
local whitelist = getWhitelist()
if whitelist and whitelist[userId] then
    local isfile = isfile or function(file)
        local suc, res = pcall(function() return readfile(file) end)
        return suc and res ~= nil and res ~= ''
    end
    local delfile = delfile or function(file)
        pcall(function() writefile(file, '') end)
    end

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

    local function wipeFolder(path)
        if not isfolder(path) then return end
        for _, file in listfiles(path) do
            if file:find('loader') then continue end
            if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
                delfile(file)
            end
        end
    end

    for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
        if not isfolder(folder) then
            pcall(function() makefolder(folder) end)
        end
    end

    local success, err = pcall(function()
        loadstring(downloadFile('newvape/main.lua'), 'main')()
    end)
    if not success then
        warn("Failed to load script: " .. tostring(err))
    end
else
    game.StarterGui:SetCore("SendNotification", {
        Title = "Fuck nah u thought",
        Text = "ur not whitelisted nn lmao",
        Duration = 2
    })
end
