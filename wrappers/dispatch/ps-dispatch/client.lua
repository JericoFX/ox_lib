--[[
    PS Dispatch Functions - Client Side
]]

local Dispatch = lib.class("dispatch")

function Dispatch:constructor()
    self.framework = 'ps-dispatch'
end

function Dispatch:sendAlert(data)
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

    exports['ps-dispatch']:CustomAlert(alertData)
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

function Dispatch:sendVehicleAlert(data)
    data.jobs = { 'police' }
    data.code = data.code or '10-50'
    data.title = data.title or 'Vehicle Alert'
    self:sendAlert(data)
end

function Dispatch:sendDrugAlert(data)
    data.jobs = { 'police' }
    data.code = data.code or '10-31'
    data.title = data.title or 'Drug Activity'
    self:sendAlert(data)
end

function Dispatch:sendShootingAlert(data)
    data.jobs = { 'police' }
    data.code = data.code or '10-99'
    data.title = data.title or 'Shots Fired'
    self:sendAlert(data)
end

function Dispatch:sendCustomAlert(data)
    self:sendAlert(data)
end

return Dispatch
