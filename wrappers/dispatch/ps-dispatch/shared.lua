--[[
    PS Dispatch Functions
]]

return {
    sendAlert = function(data)
        local alertData = {
            coords = data.coords,
            message = data.message or 'No message',
            dispatchCode = data.code or '10-90',
            description = data.title or 'Alert',
            radius = data.radius or 0,
            sprite = data.sprite or 431,
            color = data.color or 3,
            scale = data.scale or 1.2,
            length = data.length or 5,
            sound = data.sound or 'Lose_1st',
            sound2 = data.sound2 or 'GTAO_FM_Events_Soundset',
            offset = data.offset or false,
            jobs = data.jobs or { 'police' }
        }

        if lib.context == 'client' then
            exports['ps-dispatch']:CustomAlert(alertData)
        else
            -- Server side dispatch para PS
            for _, playerId in pairs(GetPlayers()) do
                TriggerClientEvent('ps-dispatch:client:alert', playerId, alertData)
            end
        end
    end,

    sendPoliceAlert = function(data)
        data.jobs = { 'police' }
        data.code = data.code or '10-90'
        data.title = data.title or 'Police Alert'
        lib.dispatch.sendAlert(data)
    end,

    sendEMSAlert = function(data)
        data.jobs = { 'ambulance' }
        data.code = data.code or '10-54'
        data.title = data.title or 'EMS Alert'
        lib.dispatch.sendAlert(data)
    end,

    sendFireAlert = function(data)
        data.jobs = { 'fire' }
        data.code = data.code or '10-70'
        data.title = data.title or 'Fire Alert'
        lib.dispatch.sendAlert(data)
    end,

    sendVehicleAlert = function(data)
        data.jobs = { 'police' }
        data.code = data.code or '10-50'
        data.title = data.title or 'Vehicle Alert'
        lib.dispatch.sendAlert(data)
    end,

    sendDrugAlert = function(data)
        data.jobs = { 'police' }
        data.code = data.code or '10-31'
        data.title = data.title or 'Drug Activity'
        lib.dispatch.sendAlert(data)
    end,

    sendShootingAlert = function(data)
        data.jobs = { 'police' }
        data.code = data.code or '10-99'
        data.title = data.title or 'Shots Fired'
        lib.dispatch.sendAlert(data)
    end,

    sendCustomAlert = function(data)
        lib.dispatch.sendAlert(data)
    end
}
