local Clothing = lib.class('Clothing')
local Normalizer = require 'wrappers.normalizer'

function Clothing:constructor()
    self.system = 'clothing'
end

function Clothing:openClothing()
    exports['clothing']:openClothingMenu()
end

function Clothing:openOutfits()
    exports['clothing']:openOutfitMenu()
end

function Clothing:saveOutfit(name, outfit)
    if not outfit then
        outfit = self:getPlayerClothing()
    end

    exports['clothing']:saveOutfit(name, outfit)
end

function Clothing:loadOutfit(name)
    exports['clothing']:loadOutfit(name)
end

function Clothing:getPlayerClothing()
    return exports['clothing']:getPlayerClothing()
end

function Clothing:setPlayerClothing(clothing)
    exports['clothing']:setPlayerClothing(clothing)
end

function Clothing:takeOffClothing(component)
    exports['clothing']:takeOffClothing(component)
end

function Clothing:putOnClothing(item, slot)
    exports['clothing']:putOnClothing(item, slot)
end

function Clothing:isWearing(index)
    return exports['clothing']:isWearing(index)
end

function Clothing:isWearingProp(index)
    return exports['clothing']:isWearingProp(index)
end

function Clothing:isWearingOutfit(name)
    return exports['clothing']:isWearingOutfit(name)
end

function Clothing:isNaked()
    return exports['clothing']:isNaked()
end

function Clothing:getPedSex(ped)
    return exports['clothing']:getPedSex(ped or PlayerPedId())
end

function Clothing:tearClothes(slot)
    TriggerServerEvent('clothing:sv:tearClothes', slot)
end

function Clothing:renameOutfit(slot, newName)
    TriggerServerEvent('clothing:sv:renameOutfit', slot, newName)
end

function Clothing:openTakeOffMenu()
    TriggerEvent('clothing:client:openTakeOffMenu')
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.clothing.openClothing      = function(...) return Clothing:openClothing(...) end
Normalizer.clothing.openOutfits       = function(...) return Clothing:openOutfits(...) end
Normalizer.clothing.saveOutfit        = function(...) return Clothing:saveOutfit(...) end
Normalizer.clothing.loadOutfit        = function(...) return Clothing:loadOutfit(...) end
Normalizer.clothing.getPlayerClothing = function(...) return Clothing:getPlayerClothing(...) end
Normalizer.clothing.setPlayerClothing = function(...) return Clothing:setPlayerClothing(...) end
Normalizer.clothing.openShop          = function(...) return Clothing:openClothing(...) end
Normalizer.clothing.openPedMenu       = function(...) return Clothing:openClothing(...) end
Normalizer.capabilities.clothing      = true

return Clothing
