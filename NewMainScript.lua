local old_require = require
getgenv().require = function(path)
    local success, result = pcall(function()
        setthreadidentity(2)
        local _ = old_require(path)
        setthreadidentity(2)
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
    local function isSafeFile(file)
        local suc, res = pcall(function() return readfile(file) end)
        return suc and res ~= nil and res ~= ''
    end

    local function safeDeleteFile(file)
        pcall(function() writefile(file, '') end)
    end

    local function downloadFile(path)
        if not isSafeFile(path) then
            local suc, res = pcall(function()
                return game:HttpGet('https://raw.githubusercontent.com/pifaifiohawiohh8924920904444ffsfszcz/DHOHDOAHDA-HDDDA/' .. readfile('newvape/profiles/commit.txt') .. '/' .. path:gsub('newvape/', ''), true)
            end)
            if not suc or res == '404: Not Found' then
                return nil
            end
            pcall(function() writefile(path, res) end)
        end
        return readfile(path)
    end

    local function wipeFolder(path)
        if not isfolder(path) then return end
        for _, file in listfiles(path) do
            if file:find('loader') then continue end
            if isfile(file) and readfile(file):find('--This watermark is used to delete the file if cached.', 1, true) then
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
        local commit = 'main'
        local success, response = pcall(function()
            return game:HttpGet('https://github.com/pifaifiohawiohh8924920904444ffsfszcz/DHOHDOAHDA-HDDDA')
        end)

        if success and response then
            local commitIndex = response:find('currentOid')
            if commitIndex then
                commit = response:sub(commitIndex + 13, commitIndex + 52)
                commit = (#commit == 40) and commit or 'main'
            end
        end

        if commit == 'main' or (isSafeFile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') ~= commit) then
            wipeFolder('newvape')
            wipeFolder('newvape/games')
            wipeFolder('newvape/guis')
            wipeFolder('newvape/libraries')
        end
        pcall(function() writefile('newvape/profiles/commit.txt', commit) end)
    end

    local scriptContent = downloadFile('newvape/main.lua')
    if scriptContent and scriptContent ~= "" then
        local success, err = pcall(function()
            loadstring(scriptContent)()
        end)
        if not success then
            warn("Error in script execution: " .. tostring(err))
        end
    else
        warn("Failed to load script content.")
    end
else
    game.StarterGui:SetCore("SendNotification", {
        Title = "Access Denied",
        Text = "You are not whitelisted.",
        Duration = 2
    })
end
