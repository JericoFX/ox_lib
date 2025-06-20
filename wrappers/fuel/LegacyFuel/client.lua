local Normalizer = require 'wrappers.core.normalizer'

local Fuel = lib.class('Fuel')
function Fuel:constructor()
    self.system = 'LegacyFuel'
end

function Fuel:getFuel(vehicle)
    return exports.LegacyFuel:GetFuel(vehicle) or 0
end

function Fuel:setFuel(vehicle, fuel)
    return exports.LegacyFuel:SetFuel(vehicle, fuel)
end

function Fuel:addFuel(vehicle, amount)
    local current = self:getFuel(vehicle)
    return self:setFuel(vehicle, current + amount)
end

-- Register implementation in Normalizer (client-side) -----------------------------
Normalizer.fuel.getFuel = function(...) return Fuel:getFuel(...) end
Normalizer.fuel.setFuel = function(...) return Fuel:setFuel(...) end
Normalizer.fuel.addFuel = function(...) return Fuel:addFuel(...) end
Normalizer.capabilities.fuel = true

return Fuel
