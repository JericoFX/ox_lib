local Dispatch = lib.class('dispatch')

function Dispatch:constructor()
    self.framework = 'origen_police'
end

---Build the table expected by origen_police SendAlert
---@param data table
---@return table
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

---Generic alert to police dispatch
function Dispatch:sendAlert(data)
    TriggerServerEvent('SendAlert:police', buildCallData(data or {}))
end

function Dispatch:sendPoliceAlert(data)
    data           = data or {}
    data.job       = 'police'
    data.alertType = data.alertType or 'GENERAL'
    data.title     = data.title or 'Police Alert'
    self:sendAlert(data)
end

-- Fallback helpers ---------------------------------------------------------
function Dispatch:sendEMSAlert(data) self:sendAlert(data) end

function Dispatch:sendFireAlert(data) self:sendAlert(data) end

function Dispatch:sendMechanicAlert(data) self:sendAlert(data) end

function Dispatch:sendCustomAlert(data) self:sendAlert(data) end

return Dispatch
