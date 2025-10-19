-- Bridge to support both QBCore and ESX

Bridge = {}
Bridge.IsQB = false
Bridge.IsESX = false
Bridge.QBCore = nil
Bridge.ESX = nil

local function initQB()
    if GetResourceState('qb-core') ~= 'started' then return false end
    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    if ok and core then
        Bridge.QBCore = core
        Bridge.IsQB = true
        return true
    end
    return false
end

local function initESX()
    if GetResourceState('es_extended') ~= 'started' then return false end
    -- Try export first (legacy/new)
    local ok, esx = pcall(function()
        if exports and exports['es_extended'] and exports['es_extended']['getSharedObject'] then
            return exports['es_extended']:getSharedObject()
        end
        return nil
    end)
    if ok and esx then
        Bridge.ESX = esx
        Bridge.IsESX = true
        return true
    end
    -- Fallback event-based init
    local fetched = nil
    TriggerEvent('esx:getSharedObject', function(obj) fetched = obj end)
    if fetched then
        Bridge.ESX = fetched
        Bridge.IsESX = true
        return true
    end
    return false
end

function Bridge.Init()
    if Config.Framework == 'qb' then
        if not initQB() then print('^1[ilv-kick] QBCore not found or not started^7') end
    elseif Config.Framework == 'esx' then
        if not initESX() then print('^1[ilv-kick] ESX not found or not started^7') end
    else
        print('^1[ilv-kick] Invalid Config.Framework, expected "qb" or "esx"^7')
    end
end

function Bridge.HasPermission(src)
    if Bridge.IsQB and Bridge.QBCore then
        return Bridge.QBCore.Functions.HasPermission(src, Config.QBPermission)
    elseif Bridge.IsESX and Bridge.ESX then
        local xPlayer = Bridge.ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        local grp = xPlayer.getGroup and xPlayer.getGroup() or 'user'
        return Config.ESXAllowedGroups[grp] == true
    end
    -- fallback: only allow console
    return src == 0
end

function Bridge.RegisterKickCommand(cmd, cb)
    if Bridge.IsQB and Bridge.QBCore then
        Bridge.QBCore.Commands.Add(cmd, 'Kick a player with scene', {
            {name = "Id", help = "Player Id"}
        }, false, function(source, args)
            if not Bridge.HasPermission(source) then
                TriggerClientEvent("chat:addMessage", source, { args = {"^1Error", "No permission"} })
                return
            end
            cb(source, args)
        end, Config.QBPermission)
    else
        RegisterCommand(cmd, function(source, args)
            if not Bridge.HasPermission(source) then
                TriggerClientEvent("chat:addMessage", source, { args = {"^1Error", "No permission"} })
                return
            end
            cb(source, args)
        end, false)
        -- Add simple suggestion if chat resource supports it
        TriggerClientEvent('chat:addSuggestion', -1, '/'..cmd, 'Kick a player with scene', {
            { name = "Id", help = "Player Id" }
        })
    end
end
