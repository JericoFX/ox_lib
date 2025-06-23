local Clothing = lib.class('Clothing')
local Normalizer = require 'wrappers.normalizer'

function Clothing:constructor()
    self.system = 'esx_skin'
end

function Clothing:openClothing()
    TriggerEvent('esx_skin:openSaveableMenu')
end

function Clothing:openOutfits()
    TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)
        menu.close()
    end, function(data, menu)
        menu.close()
    end, 'esx_skin:getPlayerSkin')
end

function Clothing:saveOutfit(name, outfit)
    if not outfit then
        TriggerEvent('skinchanger:getSkin', function(skin)
            outfit = skin
            self:_saveOutfitCallback(name, outfit)
        end)
    else
        self:_saveOutfitCallback(name, outfit)
    end
end

function Clothing:_saveOutfitCallback(name, outfit)
    TriggerServerEvent('esx_skin:saveOutfit', name, outfit)
end

function Clothing:loadOutfit(name)
    TriggerServerEvent('esx_skin:getOutfit', name)
end

function Clothing:getPlayerClothing()
    local clothing = {}
    TriggerEvent('skinchanger:getSkin', function(skin)
        clothing = skin
    end)
    return clothing
end

function Clothing:setPlayerClothing(clothing)
    TriggerEvent('skinchanger:loadSkin', clothing)
end

function Clothing:openClothingShop()
    TriggerEvent('esx_skin:openSaveableMenu', function(data, menu)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function Clothing:changeSkin(skinData)
    TriggerEvent('skinchanger:change', skinData.component, skinData.value)
end

function Clothing:getSkinComponent(component)
    local value = nil
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin[component] then
            value = skin[component]
        end
    end)
    return value
end

function Clothing:reloadSkin()
    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.clothing.openClothing      = function(...) return Clothing:openClothing(...) end
Normalizer.clothing.openOutfits       = function(...) return Clothing:openOutfits(...) end
Normalizer.clothing.saveOutfit        = function(...) return Clothing:saveOutfit(...) end
Normalizer.clothing.loadOutfit        = function(...) return Clothing:loadOutfit(...) end
Normalizer.clothing.getPlayerClothing = function(...) return Clothing:getPlayerClothing(...) end
Normalizer.clothing.setPlayerClothing = function(...) return Clothing:setPlayerClothing(...) end
Normalizer.clothing.openShop          = function(...) return Clothing:openClothingShop(...) end
Normalizer.clothing.openPedMenu       = function(...) return Clothing:openClothing(...) end
Normalizer.capabilities.clothing      = true

return Clothing
