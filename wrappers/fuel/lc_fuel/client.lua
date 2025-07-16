local normalizer = require 'wrappers.normalizer'

local Fuel = lib.class('Fuel')
function Fuel:constructor()
    self.system = 'lc_fuel'
end

local function _getExport(method)
    local export = exports['lc_fuel']
    if export and export[method] then
        return export[method]
    end
    if method == 'getFuel' and export.GetFuel then
        return export.GetFuel
    elseif method == 'setFuel' and export.SetFuel then
        return export.SetFuel
    end
end

function Fuel:getFuel(vehicle)
    local fn = _getExport('getFuel')
    return (fn and fn(vehicle)) or 0
end

function Fuel:setFuel(vehicle, fuel)
    local fn = _getExport('setFuel')
    if fn then return fn(vehicle, fuel) end
end

function Fuel:addFuel(vehicle, amount)
    local current = self:getFuel(vehicle)
    return self:setFuel(vehicle, current + amount)
end

-- Register implementation ---------------------------------------------------------
Normalizer.fuel.getFuel = function(...) return Fuel:getFuel(...) end
Normalizer.fuel.setFuel = function(...) return Fuel:setFuel(...) end
Normalizer.fuel.addFuel = function(...) return Fuel:addFuel(...) end
Normalizer.capabilities.fuel = true

return Fuel
