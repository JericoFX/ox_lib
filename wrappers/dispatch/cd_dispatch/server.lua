--[[
    CD Dispatch Functions - Server Side
    ]]

if GetResourceState('cd_dispatch') ~= 'started' then
    return
end

local Normalizer = require 'wrappers.normalizer'

-- Convert to localised functions ------------------------------------------

local function sendAlert(data)
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

local function sendPoliceAlert(data)
    data       = data or {}
    data.jobs  = { 'police' }
    data.code  = data.code or '10-90'
    data.title = data.title or 'Police Alert'
    sendAlert(data)
end

local function sendEMSAlert(data)
    data       = data or {}
    data.jobs  = { 'ambulance' }
    data.code  = data.code or '10-54'
    data.title = data.title or 'EMS Alert'
    sendAlert(data)
end

local function sendFireAlert(data)
    data       = data or {}
    data.jobs  = { 'fire' }
    data.code  = data.code or '10-70'
    data.title = data.title or 'Fire Alert'
    sendAlert(data)
end

local function sendMechanicAlert(data)
    data       = data or {}
    data.jobs  = { 'mechanic' }
    data.code  = data.code or '10-35'
    data.title = data.title or 'Mechanic Alert'
    sendAlert(data)
end

local function sendCustomAlert(data)
    sendAlert(data)
end

local dispatch                        = {
    sendAlert         = sendAlert,
    sendPoliceAlert   = sendPoliceAlert,
    sendEMSAlert      = sendEMSAlert,
    sendFireAlert     = sendFireAlert,
    sendMechanicAlert = sendMechanicAlert,
    sendCustomAlert   = sendCustomAlert,
}

-- Register implementation in Normalizer -------------------------------------------------------
Normalizer.dispatch.sendAlert         = sendAlert
Normalizer.dispatch.sendPoliceAlert   = sendPoliceAlert
Normalizer.dispatch.sendEMSAlert      = sendEMSAlert
Normalizer.dispatch.sendFireAlert     = sendFireAlert
Normalizer.dispatch.sendMechanicAlert = sendMechanicAlert
Normalizer.dispatch.sendCustomAlert   = sendCustomAlert
Normalizer.capabilities.dispatch      = true

-- Return a dummy instance for legacy table-style access ----------------------------------------
return dispatch
