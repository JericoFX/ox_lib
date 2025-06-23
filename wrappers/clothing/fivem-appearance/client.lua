local Clothing = lib.class('Clothing')
local Normalizer = require 'wrappers.normalizer'

function Clothing:constructor()
    self.system = 'fivem-appearance'
end

function Clothing:openClothing(config)
    local defaultConfig = {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        tattoos = true
    }

    config = config or defaultConfig

    exports['fivem-appearance']:startPlayerCustomization(function(appearance)
        if appearance then
            TriggerServerEvent('fivem-appearance:saveAppearance', appearance)
        end
    end, config)
end

function Clothing:openOutfits()
    exports['fivem-appearance']:openWardrobe()
end

function Clothing:saveOutfit(name, outfit)
    if not outfit then
        outfit = exports['fivem-appearance']:getPedAppearance(PlayerPedId())
    end

    TriggerServerEvent('fivem-appearance:saveOutfit', name, outfit)
end

function Clothing:loadOutfit(name)
    TriggerServerEvent('fivem-appearance:getOutfit', name)
end

function Clothing:getPlayerClothing()
    return exports['fivem-appearance']:getPedAppearance(PlayerPedId())
end

function Clothing:setPlayerClothing(appearance)
    exports['fivem-appearance']:setPlayerAppearance(appearance)
end

function Clothing:openShop(shopType)
    local config = {
        ped = false,
        headBlend = false,
        faceFeatures = false,
        headOverlays = false,
        components = true,
        props = true,
        tattoos = shopType == 'tattoo'
    }

    if shopType == 'barber' then
        config.headBlend = true
        config.faceFeatures = true
        config.headOverlays = true
        config.components = false
        config.props = false
    end

    self:openClothing(config)
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.clothing.openClothing      = function(...) return Clothing:openClothing(...) end
Normalizer.clothing.openOutfits       = function(...) return Clothing:openOutfits(...) end
Normalizer.clothing.saveOutfit        = function(...) return Clothing:saveOutfit(...) end
Normalizer.clothing.loadOutfit        = function(...) return Clothing:loadOutfit(...) end
Normalizer.clothing.getPlayerClothing = function(...) return Clothing:getPlayerClothing(...) end
Normalizer.clothing.setPlayerClothing = function(...) return Clothing:setPlayerClothing(...) end
Normalizer.clothing.openShop          = function(...) return Clothing:openShop(...) end
Normalizer.clothing.openPedMenu       = function(...) return Clothing:openClothing(...) end
Normalizer.capabilities.clothing      = true

return Clothing
