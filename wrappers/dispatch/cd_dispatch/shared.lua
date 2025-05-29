--[[
    CD Dispatch Functions
]]

return {
    sendAlert = function(data)
        local alertData = {
            job_table = data.jobs or { 'police' },
            coords = data.coords,
            title = data.title or 'Alert',
            message = data.message or 'No message',
            flash = data.flash or 0,
            unique_id = data.id or tostring(math.random(0000000, 9999999)),
            blip = data.blip or {
                sprite = 431,
                colour = 3,
                scale = 1.2,
                text = data.title or 'Alert',
                time = (data.time or 5) * 60000,
                sound = 1,
            }
        }

        if lib.context == 'client' then
            TriggerServerEvent('cd_dispatch:AddNotification', alertData)
        else
            TriggerEvent('cd_dispatch:AddNotification', alertData)
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

    sendMechanicAlert = function(data)
        data.jobs = { 'mechanic' }
        data.code = data.code or '10-35'
        data.title = data.title or 'Mechanic Alert'
        lib.dispatch.sendAlert(data)
    end,

    sendCustomAlert = function(data)
        lib.dispatch.sendAlert(data)
    end
}
