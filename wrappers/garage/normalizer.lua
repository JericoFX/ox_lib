local N = require 'wrappers.normalizer'

local lib = lib or {}

local adapters = {}

------------------------------------------------------------------------
-- qb-garages adapter ---------------------------------------------------
------------------------------------------------------------------------

if GetResourceState('qb-garages') == 'started' then
    local QBCore = exports['qb-core'] and exports['qb-core']:GetCoreObject()
    adapters['qb-garages'] = {}
    local A = adapters['qb-garages']

    ---Abre el NUI original
    ---@param data table Tabla con indexgarage, type, category, etc.
    function A.openMenu(data)
        TriggerEvent('qb-garages:client:OpenGarage', data)
    end

    ---Obtiene la lista de vehículos del jugador
    function A.getVehicles(cb, index, gtype, category)
        QBCore.Functions.TriggerCallback('qb-garages:server:GetGarageVehicles', cb, index, gtype, category)
    end

    ---Saca un vehículo del garaje
    function A.spawnVehicle(plate, coords, heading, cb)
        QBCore.Functions.TriggerCallback('qb-garages:server:spawnvehicle', cb, plate, coords, heading)
    end

    ---Guarda / actualiza vehículo
    function A.storeVehicle(plate, fuel, engine, body)
        TriggerServerEvent('qb-garages:server:updateVehicle', plate, fuel, engine, body, true)
    end
end

------------------------------------------------------------------------
-- Ejemplo de como se puede agregar un nuevo adapter --------------------
------------------------------------------------------------------------

-- if GetResourceState('nombre_recurso') == 'started' then
--     local API = exports['nombre_recurso']      -- si expone exports
--     adapters['nombre_recurso'] = {
--         openMenu     = function(data)  ...  end,
--         getVehicles  = function(cb, id, t, cat) ... end,
--         spawnVehicle = function(plate, coords, h, cb) ... end,
--         storeVehicle = function(plate, fuel, eng, body) ... end,
--     }
-- end

------------------------------------------------------------------------
-- Stub helpers ---------------------------------------------------------
------------------------------------------------------------------------

local function _stub(name)
    return function()
        error(('Normalizer.garage.%s not implemented for current system'):format(name), 2)
    end
end

local function impl(fn)
    local sys = lib.garage and lib.garage.system or 'unknown'
    return (adapters[sys] and adapters[sys][fn]) or _stub(fn)
end

------------------------------------------------------------------------
-- Public API -----------------------------------------------------------
------------------------------------------------------------------------

local M = {}

function M.openMenu(data) impl('openMenu')(data) end

function M.getVehicles(cb, ...) impl('getVehicles')(cb, ...) end

function M.spawnVehicle(...) impl('spawnVehicle')(...) end

function M.storeVehicle(...) impl('storeVehicle')(...) end

-- Anunciamos capability
N.capabilities.garage = true
N.garage.openMenu     = M.openMenu
N.garage.getVehicles  = M.getVehicles
N.garage.spawnVehicle = M.spawnVehicle
N.garage.storeVehicle = M.storeVehicle

return M
