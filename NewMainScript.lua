local old_require = require
getgenv().require = function(path)
    local success, result = pcall(function()
        setthreadidentity(2)
        local _ = old_require(path)
        setthreadidentity(8)
        return _
    end)
    return success and result or nil
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

local whitelist = getWhitelist()
if whitelist and whitelist[userId] then
    local function safeIsFile(file)
        local suc, res = pcall(function() return readfile(file) end)
        return suc and res ~= nil and res ~= ''
    end

    local function safeDeleteFile(file)
        pcall(function() writefile(file, '') end)
    end

    local function downloadFile(path, func)
        if not safeIsFile(path) then
            local suc, res = pcall(function()
                return game:HttpGet('https://raw.githubusercontent.com/pifaifiohawiohh8924920904444ffsfszcz/DHOHDOAHDA-HDDDA/' .. readfile('newvape/profiles/commit.txt') .. '/' .. select(1, path:gsub('newvape/', '')), true)
            end)
            if not suc or res == '404: Not Found' then
                warn("Failed to download file: " .. tostring(res))
                return nil
            end
            if path:find('.lua') then
                res = '--This watermark is used to delete the file if cached.\n' .. res
            end
            pcall(function() writefile(path, res) end)
        end
        return (func or readfile)(path)
    end

    local function wipeFolder(path)
        if not isfolder(path) then return end
        for _, file in listfiles(path) do
            if file:find('loader') then continue end
            if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if cached.')) == 1 then
                safeDeleteFile(file)
            end
        end
    end

    for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
        if not isfolder(folder) then
            pcall(function() makefolder(folder) end)
        end
    end

    if not shared.VapeDeveloper then
        task.spawn(function() -- Runs in background to prevent lag
            local _, subbed = pcall(function()
                return game:HttpGet('https://github.com/pifaifiohawiohh8924920904444ffsfszcz/DHOHDOAHDA-HDDDA')
            end)
            if subbed then
                local commit = subbed:find('currentOid')
                commit = commit and subbed:sub(commit + 13, commit + 52) or nil
                commit = commit and #commit == 40 and commit or 'main'
                if commit == 'main' or (safeIsFile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
                    wipeFolder('newvape')
                    wipeFolder('newvape/games')
                    wipeFolder('newvape/guis')
                    wipeFolder('newvape/libraries')
                end
                pcall(function() writefile('newvape/profiles/commit.txt', commit) end)
            end
        end)
    end

    -- Load script safely
    task.spawn(function() -- Runs in background
        local success, err = pcall(function()
            loadstring(downloadFile('newvape/main.lua'), 'main')()
        end)
        if not success then
            warn("Failed to load script: " .. tostring(err))
        end
    end)
else
    game.StarterGui:SetCore("SendNotification", {
        Title = "Access Denied",
        Text = "You are not whitelisted.",
        Duration = 2
    })
end
