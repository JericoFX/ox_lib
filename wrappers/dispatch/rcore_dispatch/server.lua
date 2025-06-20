--[[
    rcore_dispatch Integration - Server Side
]]

if GetResourceState('rcore_dispatch') ~= 'started' then
    return -- resource not present
end

-- Helper build -------------------------------------------------------------

---Helper to build call data compatible with rcore_dispatch
---@param data table
---@return table
local function buildCallData(data)
    return {
        code             = data.code or '10-90',
        default_priority = data.priority or 'medium',
        coords           = data.coords or vector3(0, 0, 0),
        job              = (data.job or (data.jobs and data.jobs[1])) or 'police',
        text             = data.message or data.title or 'Alert',
        type             = data.alertType or data.type or 'alerts',
        blip_time        = data.length or 5,
        image            = data.image,
        custom_sound     = data.sound,
        blip             = data.blip,
    }
end

-- Localised functions -------------------------------------------------------

local function sendAlert(data)
    TriggerEvent('rcore_dispatch:server:sendAlert', buildCallData(data or {}))
end

local function sendPoliceAlert(data)
    data       = data or {}
    data.job   = 'police'
    data.code  = data.code or '10-90'
    data.title = data.title or 'Police Alert'
    sendAlert(data)
end

local function sendEMSAlert(data)
    data       = data or {}
    data.job   = 'ambulance'
    data.code  = data.code or '10-54'
    data.title = data.title or 'EMS Alert'
    sendAlert(data)
end

local function sendFireAlert(data)
    data       = data or {}
    data.job   = 'fire'
    data.code  = data.code or '10-70'
    data.title = data.title or 'Fire Alert'
    sendAlert(data)
end

local function sendMechanicAlert(data)
    data       = data or {}
    data.job   = 'mechanic'
    data.code  = data.code or '10-50'
    data.title = data.title or 'Mechanic Request'
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

local Normalizer                      = require 'wrappers.core.normalizer'

Normalizer.dispatch.sendAlert         = sendAlert
Normalizer.dispatch.sendPoliceAlert   = sendPoliceAlert
Normalizer.dispatch.sendEMSAlert      = sendEMSAlert
Normalizer.dispatch.sendFireAlert     = sendFireAlert
Normalizer.dispatch.sendMechanicAlert = sendMechanicAlert
Normalizer.dispatch.sendCustomAlert   = sendCustomAlert
Normalizer.capabilities.dispatch      = true

return dispatch
