--[[
    QS Dispatch Functions - Server Side
]]

if GetResourceState('qs-dispatch') ~= 'started' then
    return -- Do not register if the resource is not running
end

-- Internal helper to build payload -----------------------------------------
local function buildCallData(data)
    local title = data.title or data.description or 'Alert'
    local code  = data.code or '10-90'

    return {
        job          = data.jobs or { 'police' },
        callLocation = data.coords or vector3(0, 0, 0),
        callCode     = { code = code, snippet = title },
        message      = data.message or '',
        flashes      = data.flashes ~= false,
        image        = data.image,
        blip         = {
            sprite  = data.sprite or 431,
            scale   = data.scale or 1.2,
            colour  = data.color or 3,
            flashes = true,
            text    = title,
            time    = (data.length or 5) * 1000,
        },
        otherData    = data.otherData
    }
end

-- Localised functions --------------------------------------------------------

local function sendAlert(data)
    TriggerEvent('qs-dispatch:server:CreateDispatchCall', buildCallData(data or {}))
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
    data.code  = data.code or '10-50'
    data.title = data.title or 'Mechanic Needed'
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

-- Register with Normalizer ---------------------------------------------------
local Normalizer                      = require 'wrappers.core.normalizer'

Normalizer.dispatch.sendAlert         = sendAlert
Normalizer.dispatch.sendPoliceAlert   = sendPoliceAlert
Normalizer.dispatch.sendEMSAlert      = sendEMSAlert
Normalizer.dispatch.sendFireAlert     = sendFireAlert
Normalizer.dispatch.sendMechanicAlert = sendMechanicAlert
Normalizer.dispatch.sendCustomAlert   = sendCustomAlert
Normalizer.capabilities.dispatch      = true

return dispatch
