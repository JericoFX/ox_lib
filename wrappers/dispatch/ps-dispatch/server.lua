--[[
    PS Dispatch Functions - Server Side
]]

if GetResourceState('ps-dispatch') ~= 'started' then
    return
end

-- Localised functions -------------------------------------------------------

local function sendAlert(data)
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

    for _, playerId in pairs(GetPlayers()) do
        TriggerClientEvent('ps-dispatch:client:alert', playerId, alertData)
    end
end

local function sendPoliceAlert(data)
    data.jobs = { 'police' }
    data.code = data.code or '10-90'
    data.title = data.title or 'Police Alert'
    sendAlert(data)
end

local function sendEMSAlert(data)
    data.jobs = { 'ambulance' }
    data.code = data.code or '10-54'
    data.title = data.title or 'EMS Alert'
    sendAlert(data)
end

local function sendFireAlert(data)
    data.jobs = { 'fire' }
    data.code = data.code or '10-70'
    data.title = data.title or 'Fire Alert'
    sendAlert(data)
end

local function sendVehicleAlert(data)
    data.jobs = { 'police' }
    data.code = data.code or '10-50'
    data.title = data.title or 'Vehicle Alert'
    sendAlert(data)
end

local function sendDrugAlert(data)
    data.jobs = { 'police' }
    data.code = data.code or '10-31'
    data.title = data.title or 'Drug Activity'
    sendAlert(data)
end

local function sendShootingAlert(data)
    data.jobs = { 'police' }
    data.code = data.code or '10-99'
    data.title = data.title or 'Shots Fired'
    sendAlert(data)
end

local function sendCustomAlert(data)
    sendAlert(data)
end

local dispatch = {
    sendAlert         = sendAlert,
    sendPoliceAlert   = sendPoliceAlert,
    sendEMSAlert      = sendEMSAlert,
    sendFireAlert     = sendFireAlert,
    sendVehicleAlert  = sendVehicleAlert,
    sendDrugAlert     = sendDrugAlert,
    sendShootingAlert = sendShootingAlert,
    sendCustomAlert   = sendCustomAlert,
}



-- Normalizer registration ---------------------------------------------------
local Normalizer                      = require 'wrappers.core.normalizer'

Normalizer.dispatch.sendAlert         = sendAlert
Normalizer.dispatch.sendPoliceAlert   = sendPoliceAlert
Normalizer.dispatch.sendEMSAlert      = sendEMSAlert
Normalizer.dispatch.sendFireAlert     = sendFireAlert
Normalizer.dispatch.sendMechanicAlert = sendVehicleAlert -- using vehicle as mechanic
Normalizer.dispatch.sendCustomAlert   = sendCustomAlert
Normalizer.capabilities.dispatch      = true

return dispatch
