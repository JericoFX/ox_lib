--[[
    CD Dispatch Functions
]]

local Dispatch = lib.class("dispatch")

function Dispatch:constructor()
    self.framework = 'cd_dispatch'
end

function Dispatch:sendAlert(data)
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

    TriggerServerEvent('cd_dispatch:AddNotification', alertData)
end

function Dispatch:sendPoliceAlert(data)
    data.jobs = { 'police' }
    data.code = data.code or '10-90'
    data.title = data.title or 'Police Alert'
    self:sendAlert(data)
end

function Dispatch:sendEMSAlert(data)
    data.jobs = { 'ambulance' }
    data.code = data.code or '10-54'
    data.title = data.title or 'EMS Alert'
    self:sendAlert(data)
end

function Dispatch:sendFireAlert(data)
    data.jobs = { 'fire' }
    data.code = data.code or '10-70'
    data.title = data.title or 'Fire Alert'
    self:sendAlert(data)
end

function Dispatch:sendMechanicAlert(data)
    data.jobs = { 'mechanic' }
    data.code = data.code or '10-35'
    data.title = data.title or 'Mechanic Alert'
    self:sendAlert(data)
end

function Dispatch:sendCustomAlert(data)
    self:sendAlert(data)
end

return Dispatch
