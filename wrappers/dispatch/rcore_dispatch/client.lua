local Dispatch = lib.class('dispatch')

function Dispatch:constructor()
    self.framework = 'rcore_dispatch'
end

---Internal helper to build data table expected by rcore_dispatch
---@param data table
---@return table
local function buildCallData(data)
    return {
        code             = data.code or '10-90',
        default_priority = data.priority or 'medium',
        coords           = data.coords or GetEntityCoords(cache.ped),
        job              = (data.job or (data.jobs and data.jobs[1])) or 'police',
        text             = data.message or data.title or 'Alert',
        type             = data.alertType or data.type or 'alerts',
        blip_time        = data.length or 5,
        image            = data.image,
        custom_sound     = data.sound,
        blip             = data.blip,
    }
end

function Dispatch:sendAlert(data)
    TriggerServerEvent('rcore_dispatch:server:sendAlert', buildCallData(data or {}))
end

function Dispatch:sendPoliceAlert(data)
    data       = data or {}
    data.job   = 'police'
    data.code  = data.code or '10-90'
    data.title = data.title or 'Police Alert'
    self:sendAlert(data)
end

function Dispatch:sendEMSAlert(data)
    data       = data or {}
    data.job   = 'ambulance'
    data.code  = data.code or '10-54'
    data.title = data.title or 'EMS Alert'
    self:sendAlert(data)
end

function Dispatch:sendFireAlert(data)
    data       = data or {}
    data.job   = 'fire'
    data.code  = data.code or '10-70'
    data.title = data.title or 'Fire Alert'
    self:sendAlert(data)
end

function Dispatch:sendMechanicAlert(data)
    data       = data or {}
    data.job   = 'mechanic'
    data.code  = data.code or '10-50'
    data.title = data.title or 'Mechanic Request'
    self:sendAlert(data)
end

function Dispatch:sendCustomAlert(data)
    self:sendAlert(data)
end

return Dispatch
