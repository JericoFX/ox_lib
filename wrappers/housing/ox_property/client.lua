if GetResourceState('ox_property') ~= 'started' then return end

local Housing = lib.class('Housing')

function Housing:constructor()
    self.system = 'ox_property'
end

function Housing:enterHouse(houseId)
    TriggerEvent('ox_property:client:enterProperty', houseId)
    return true
end

function Housing:exitHouse()
    TriggerEvent('ox_property:client:exitProperty')
    return true
end

function Housing:createHouse(coords, price, houseType)
    TriggerServerEvent('ox_property:server:createProperty', coords, price, houseType or 'house')
    return true
end

function Housing:buyHouse(houseId)
    TriggerServerEvent('ox_property:server:buyProperty', houseId)
    return true
end

function Housing:openHouseMenu()
    TriggerEvent('ox_property:client:openMenu')
    return true
end

function Housing:getPlayerHouses()
    local success, result = pcall(function()
        return exports.ox_property:getPlayerProperties()
    end)
    return success and result or {}
end

function Housing:isPlayerInsideHouse()
    local success, result = pcall(function()
        return exports.ox_property:isInsideProperty()
    end)
    return success and result or false
end

function Housing:getCurrentHouse()
    local success, result = pcall(function()
        return exports.ox_property:getCurrentProperty()
    end)
    return success and result or nil
end

return Housing
