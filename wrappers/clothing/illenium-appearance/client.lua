local Clothing = lib.class('Clothing')
local Normalizer = require 'wrappers.normalizer'

function Clothing:constructor()
    self.system = 'illenium-appearance'
end

function Clothing:openClothing()
    exports['illenium-appearance']:startPlayerCustomization()
end

function Clothing:openOutfits()
    exports['illenium-appearance']:openWardrobe()
end

function Clothing:saveOutfit(name, outfit)
    if not outfit then
        outfit = exports['illenium-appearance']:getPedAppearance(PlayerPedId())
    end

    if outfit then
        TriggerServerEvent('illenium-appearance:saveOutfit', name, outfit)
    end
end

function Clothing:loadOutfit(name)
    TriggerServerEvent('illenium-appearance:getOutfit', name)
end

function Clothing:getPlayerClothing()
    return exports['illenium-appearance']:getPedAppearance(PlayerPedId())
end

function Clothing:setPlayerClothing(appearance)
    exports['illenium-appearance']:setPedAppearance(PlayerPedId(), appearance)
end

function Clothing:openPedMenu()
    exports['illenium-appearance']:openPedCustomization()
end

function Clothing:openShop(shopType)
    local shopTypes = {
        clothing = function()
            exports['illenium-appearance']:openClothingShop()
        end,
        barber = function()
            exports['illenium-appearance']:openBarberShop()
        end,
        tattoo = function()
            exports['illenium-appearance']:openTattooShop()
        end
    }

    if shopTypes[shopType] then
        shopTypes[shopType]()
    end
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.clothing.openClothing      = function(...) return Clothing:openClothing(...) end
Normalizer.clothing.openOutfits       = function(...) return Clothing:openOutfits(...) end
Normalizer.clothing.saveOutfit        = function(...) return Clothing:saveOutfit(...) end
Normalizer.clothing.loadOutfit        = function(...) return Clothing:loadOutfit(...) end
Normalizer.clothing.getPlayerClothing = function(...) return Clothing:getPlayerClothing(...) end
Normalizer.clothing.setPlayerClothing = function(...) return Clothing:setPlayerClothing(...) end
Normalizer.clothing.openShop          = function(...) return Clothing:openShop(...) end
Normalizer.clothing.openPedMenu       = function(...) return Clothing:openPedMenu(...) end
Normalizer.capabilities.clothing      = true

return Clothing
