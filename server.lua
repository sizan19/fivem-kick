-- ilv-kick server (framework-agnostic)
-- Uses Bridge to work with QBCore or ESX, configured via Config.Framework

local Config = Config or {}
local Bridge = Bridge or {}

CreateThread(function()
    Bridge.Init()

    Bridge.RegisterKickCommand(Config.CommandName, function(source, args)
        local targetId = tonumber(args[1])
        if not targetId or GetPlayerName(targetId) == nil then
            TriggerClientEvent("chat:addMessage", source, { args = {"^1Error", "Invalid player ID"} })
            return
        end

        -- Play the scene on target client
        TriggerClientEvent("kick:ilv-scripts:KickKidnapScene", targetId)

        -- Kick after 10 seconds
        SetTimeout(10000, function()
            if GetPlayerName(targetId) ~= nil then
                DropPlayer(targetId, "You have been kidnapped and kicked from the server.")
            end
        end)
    end)
end)
