local Normalizer = require 'wrappers.core.normalizer'

local Fuel = lib.class('Fuel')
function Fuel:constructor()
    self.system = 'ps-fuel'
end

function Fuel:getFuel(vehicle)
    return exports['ps-fuel']:GetFuel(vehicle) or 0
end

function Fuel:setFuel(vehicle, fuel)
    return exports['ps-fuel']:SetFuel(vehicle, fuel)
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
