local Clothing = lib.class('Clothing')
local Normalizer = require 'wrappers.normalizer'

function Clothing:constructor()
    self.system = 'qb-clothing'
end

function Clothing:openClothing()
    ExecuteCommand('clothing')
end

function Clothing:openOutfits()
    TriggerEvent('qb-clothing:client:openOutfitMenu')
end

function Clothing:saveOutfit(name, outfit)
    if not outfit then
        outfit = self:getPlayerClothing()
    end

    TriggerServerEvent('qb-clothing:saveOutfit', name, outfit)
end

function Clothing:loadOutfit(name)
    TriggerServerEvent('qb-clothing:getOutfit', name)
end

function Clothing:getPlayerClothing()
    local ped = PlayerPedId()
    return {
        face = GetPedDrawableVariation(ped, 0),
        face_texture = GetPedTextureVariation(ped, 0),
        hair = GetPedDrawableVariation(ped, 2),
        hair_texture = GetPedTextureVariation(ped, 2),
        tshirt = GetPedDrawableVariation(ped, 8),
        tshirt_texture = GetPedTextureVariation(ped, 8),
        torso = GetPedDrawableVariation(ped, 11),
        torso_texture = GetPedTextureVariation(ped, 11),
        arms = GetPedDrawableVariation(ped, 3),
        arms_texture = GetPedTextureVariation(ped, 3),
        pants = GetPedDrawableVariation(ped, 4),
        pants_texture = GetPedTextureVariation(ped, 4),
        shoes = GetPedDrawableVariation(ped, 6),
        shoes_texture = GetPedTextureVariation(ped, 6),
        hat = GetPedPropIndex(ped, 0),
        hat_texture = GetPedPropTextureIndex(ped, 0),
        glasses = GetPedPropIndex(ped, 1),
        glasses_texture = GetPedPropTextureIndex(ped, 1)
    }
end

function Clothing:setPlayerClothing(clothing)
    local ped = PlayerPedId()

    if clothing.face then SetPedComponentVariation(ped, 0, clothing.face, clothing.face_texture or 0, 0) end
    if clothing.hair then SetPedComponentVariation(ped, 2, clothing.hair, clothing.hair_texture or 0, 0) end
    if clothing.tshirt then SetPedComponentVariation(ped, 8, clothing.tshirt, clothing.tshirt_texture or 0, 0) end
    if clothing.torso then SetPedComponentVariation(ped, 11, clothing.torso, clothing.torso_texture or 0, 0) end
    if clothing.arms then SetPedComponentVariation(ped, 3, clothing.arms, clothing.arms_texture or 0, 0) end
    if clothing.pants then SetPedComponentVariation(ped, 4, clothing.pants, clothing.pants_texture or 0, 0) end
    if clothing.shoes then SetPedComponentVariation(ped, 6, clothing.shoes, clothing.shoes_texture or 0, 0) end

    if clothing.hat and clothing.hat ~= -1 then
        SetPedPropIndex(ped, 0, clothing.hat, clothing.hat_texture or 0, true)
    else
        ClearPedProp(ped, 0)
    end

    if clothing.glasses and clothing.glasses ~= -1 then
        SetPedPropIndex(ped, 1, clothing.glasses, clothing.glasses_texture or 0, true)
    else
        ClearPedProp(ped, 1)
    end
end

function Clothing:openShop(shopType)
    if shopType == 'clothing' then
        TriggerEvent('qb-clothing:client:openMenu')
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
Normalizer.clothing.openPedMenu       = function() return false end
Normalizer.capabilities.clothing      = true

return Clothing
