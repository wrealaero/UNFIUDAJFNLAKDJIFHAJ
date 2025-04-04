local old_require = require
getgenv().require = function(path)
    setthreadidentity(2)
    local _ = old_require(path)
    setthreadidentity(8)
    return _
end

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

local player = game.Players.LocalPlayer
local userId = tostring(player.UserId)
local isWhitelisted, userTier = WhitelistManager:isWhitelisted(userId)

if not isWhitelisted then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Access Denied",
        Text = "You are not whitelisted.",
        Duration = 2
    })
    return
end

shared.UserTier = userTier

local CheatEngineMode = false

if (not getgenv) or (getgenv and type(getgenv) ~= "function") then CheatEngineMode = true end
if getgenv and not getgenv().shared then CheatEngineMode = true; getgenv().shared = {}; end
if getgenv and not getgenv().debug then CheatEngineMode = true; getgenv().debug = {traceback = function(string) return string end} end
if getgenv and not getgenv().require then CheatEngineMode = true; end
if getgenv and getgenv().require and type(getgenv().require) ~= "function" then CheatEngineMode = true end

local function checkExecutor()
    if identifyexecutor ~= nil and type(identifyexecutor) == "function" then
        local suc, res = pcall(function()
            return identifyexecutor()
        end)   
        local blacklist = {'solara', 'cryptic'} 
        local core_blacklist = {'solara'} 
        if suc then
            for i,v in pairs(blacklist) do
                if string.find(string.lower(tostring(res)), v) then 
                    CheatEngineMode = true
                end
            end

            if string.find(string.lower(tostring(res)), 'xeno') then
                warn("Xeno executor detected. Some features may not work as expected.")
            end
        end
    end
end

task.spawn(function() pcall(checkExecutor) end)

local function checkDebug()
    if CheatEngineMode then return end
    if not getgenv().debug then 
        CheatEngineMode = true 
    else 
        local debugChecks = {
            "getupvalue",
            "getupvalues",
            "getconstants",
            "getproto"
        }
        for _, v in pairs(debugChecks) do
            if not debug[v] or type(debug[v]) ~= "function" then 
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

if not CheatEngineMode then checkDebug() end
shared.CheatEngineMode = shared.CheatEngineMode or CheatEngineMode

if shared.CheatEngineMode then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Security Alert",
        Text = "Detected Cheat Engine Usage!",
        Duration = 5
    })
    warn("Cheat Engine detected. Script execution stopped.")
    return
end

local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/wrealaero/UNFIUDAJFNLAKDJIFHAJ/refs/heads/main/NewMainScript.lua", true))()
end)

if not success then
    warn("Failed to load main script: " .. tostring(err))
end
