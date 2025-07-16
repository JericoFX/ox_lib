local normalizer = require 'wrappers.normalizer'

local Fuel = lib.class('Fuel')
function Fuel:constructor()
    self.system = 'cdn-fuel'
end

function Fuel:getFuel(vehicle)
    return exports['cdn-fuel']:GetFuelLevel(vehicle) or 0
end

function Fuel:setFuel(vehicle, fuel)
    return exports['cdn-fuel']:SetFuelLevel(vehicle, fuel)
end

function Fuel:addFuel(vehicle, amount)
    return exports['cdn-fuel']:AddFuel(vehicle, amount)
end

Normalizer.fuel.getFuel = function(...) return Fuel:getFuel(...) end
Normalizer.fuel.setFuel = function(...) return Fuel:setFuel(...) end
Normalizer.fuel.addFuel = function(...) return Fuel:addFuel(...) end
Normalizer.capabilities.fuel = true

return Fuel
