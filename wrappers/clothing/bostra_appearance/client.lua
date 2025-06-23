local Clothing = lib.class('Clothing')
local Normalizer = require 'wrappers.normalizer'

function Clothing:constructor()
    self.system = 'bostra_appearance'
end

function Clothing:openClothing()
    exports['bostra_appearance']:startPlayerCustomization()
end

function Clothing:openOutfits()
    exports['bostra_appearance']:openWardrobe()
end

function Clothing:saveOutfit(name, outfit)
    if not outfit then
        outfit = exports['bostra_appearance']:getPedAppearance(PlayerPedId())
    end

    if outfit then
        TriggerServerEvent('bostra_appearance:saveOutfit', name, outfit)
    end
end

function Clothing:loadOutfit(name)
    TriggerServerEvent('bostra_appearance:getOutfit', name)
end

function Clothing:getPlayerClothing()
    return exports['bostra_appearance']:getPedAppearance(PlayerPedId())
end

function Clothing:setPlayerClothing(appearance)
    exports['bostra_appearance']:setPedAppearance(PlayerPedId(), appearance)
end

function Clothing:openPedMenu()
    exports['bostra_appearance']:openPedCustomization()
end

function Clothing:openShop(shopType)
    local shopTypes = {
        clothing = function()
            exports['bostra_appearance']:openClothingShop()
        end,
        barber = function()
            exports['bostra_appearance']:openBarberShop()
        end,
        tattoo = function()
            exports['bostra_appearance']:openTattooShop()
        end,
        surgeon = function()
            exports['bostra_appearance']:openSurgeonShop()
        end
    }

    if shopTypes[shopType] then
        shopTypes[shopType]()
    end
end

function Clothing:enableCameraControls()
    exports['bostra_appearance']:enableCameraControls()
end

function Clothing:disableCameraControls()
    exports['bostra_appearance']:disableCameraControls()
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
