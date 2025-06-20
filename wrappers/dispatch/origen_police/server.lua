--[[
    Origen Police Dispatch - Server Side
]]

if GetResourceState('origen_police') ~= 'started' then
    return -- Abort if resource not running
end

-- Format helper -------------------------------------------------------------
local function buildCallData(data)
    return {
        coords   = data.coords or vector3(0, 0, 0),
        title    = data.title or 'Alert',
        type     = data.alertType or data.type or 'GENERAL',
        message  = data.message or '',
        job      = data.job or ((data.jobs and data.jobs[1]) or 'police'),
        metadata = data.metadata or data.extra or {},
    }
end

-- Localised functions -------------------------------------------------------

local function sendAlert(data)
    exports['origen_police']:SendAlert(buildCallData(data or {}))
end

local function sendPoliceAlert(data)
    data           = data or {}
    data.job       = 'police'
    data.alertType = data.alertType or 'GENERAL'
    data.title     = data.title or 'Police Alert'
    sendAlert(data)
end

local function sendEMSAlert(data) sendAlert(data) end
local function sendFireAlert(data) sendAlert(data) end
local function sendMechanicAlert(data) sendAlert(data) end
local function sendCustomAlert(data) sendAlert(data) end

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
