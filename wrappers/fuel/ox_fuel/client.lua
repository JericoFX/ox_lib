local Normalizer = require 'wrappers.normalizer'

local Fuel = lib.class('Fuel')
function Fuel:constructor()
    self.system = 'ox_fuel'
end

local function _stateFuel(entity)
    local state = Entity(entity).state
    return state and state.fuel
end

function Fuel:getFuel(vehicle)
    -- Prefer statebag if available, else native
    return _stateFuel(vehicle) or GetVehicleFuelLevel(vehicle)
end

function Fuel:setFuel(vehicle, fuel)
    if NetworkGetEntityIsNetworked(vehicle) then
        Entity(vehicle).state:set('fuel', fuel, true)
    end
    SetVehicleFuelLevel(vehicle, fuel)
    return true
end

function Fuel:addFuel(vehicle, amount)
    local current = self:getFuel(vehicle)
    return self:setFuel(vehicle, current + amount)
end

Normalizer.fuel.getFuel = function(...) return Fuel:getFuel(...) end
Normalizer.fuel.setFuel = function(...) return Fuel:setFuel(...) end
Normalizer.fuel.addFuel = function(...) return Fuel:addFuel(...) end
Normalizer.capabilities.fuel = true

return Fuel
