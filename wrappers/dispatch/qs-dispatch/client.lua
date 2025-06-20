local Dispatch = lib.class('dispatch')

function Dispatch:constructor()
    self.framework = 'qs-dispatch'
end

---Internal helper to build the dispatch call data structure expected by qs-dispatch
---@param data table
---@return table
local function buildCallData(data)
    local title = data.title or data.description or 'Alert'
    local code  = data.code or '10-90'

    return {
        job          = data.jobs or { 'police' },
        callLocation = data.coords or vector3(0, 0, 0),
        callCode     = { code = code, snippet = title },
        message      = data.message or '',
        flashes      = data.flashes ~= false, -- defaults to true
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

function Dispatch:sendAlert(data)
    TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', buildCallData(data or {}))
end

function Dispatch:sendPoliceAlert(data)
    data       = data or {}
    data.jobs  = { 'police' }
    data.code  = data.code or '10-90'
    data.title = data.title or 'Police Alert'
    self:sendAlert(data)
end

function Dispatch:sendEMSAlert(data)
    data       = data or {}
    data.jobs  = { 'ambulance' }
    data.code  = data.code or '10-54'
    data.title = data.title or 'EMS Alert'
    self:sendAlert(data)
end

function Dispatch:sendFireAlert(data)
    data       = data or {}
    data.jobs  = { 'fire' }
    data.code  = data.code or '10-70'
    data.title = data.title or 'Fire Alert'
    self:sendAlert(data)
end

function Dispatch:sendVehicleAlert(data)
    data       = data or {}
    data.jobs  = { 'police' }
    data.code  = data.code or '10-50'
    data.title = data.title or 'Vehicle Alert'
    self:sendAlert(data)
end

function Dispatch:sendDrugAlert(data)
    data       = data or {}
    data.jobs  = { 'police' }
    data.code  = data.code or '10-31'
    data.title = data.title or 'Drug Activity'
    self:sendAlert(data)
end

function Dispatch:sendShootingAlert(data)
    data       = data or {}
    data.jobs  = { 'police' }
    data.code  = data.code or '10-99'
    data.title = data.title or 'Shots Fired'
    self:sendAlert(data)
end

function Dispatch:sendCustomAlert(data)
    self:sendAlert(data or {})
end

return Dispatch
