if GetResourceState('ox_property') ~= 'started' then
    return {}
end

local Normalizer = require 'wrappers.normalizer'

local enterHouse = function(source, houseId)
    TriggerClientEvent('ox_property:client:enterProperty', source, houseId)
end

local exitHouse = function(source)
    TriggerClientEvent('ox_property:client:exitProperty', source)
end

local createHouse = function(coords, price, owner, houseType)
    local success, result = pcall(function()
        return exports.ox_property:createProperty(coords, price, owner, houseType or 'house')
    end)
    return success and result or false
end

local buyHouse = function(source, houseId)
    local success, result = pcall(function()
        return exports.ox_property:buyProperty(source, houseId)
    end)
    return success and result or false
end

local getPlayerHouses = function(source)
    local success, result = pcall(function()
        return exports.ox_property:getPlayerProperties(source)
    end)
    return success and result or {}
end

local isPlayerInsideHouse = function(source)
    local success, result = pcall(function()
        return exports.ox_property:isPlayerInsideProperty(source)
    end)
    return success and result or false
end

local getHouseInfo = function(houseId)
    local success, result = pcall(function()
        return exports.ox_property:getPropertyInfo(houseId)
    end)
    return success and result or nil
end

-- Register in Normalizer
Normalizer.housing.enterHouse = enterHouse
Normalizer.housing.exitHouse = exitHouse
Normalizer.housing.createHouse = createHouse
Normalizer.housing.buyHouse = buyHouse
Normalizer.housing.getPlayerHouses = getPlayerHouses
Normalizer.housing.isPlayerInsideHouse = isPlayerInsideHouse
Normalizer.housing.getHouseInfo = getHouseInfo
Normalizer.capabilities.housing = true

return {
    system = 'ox_property',

    enterHouse = enterHouse,
    exitHouse = exitHouse,
    createHouse = createHouse,
    buyHouse = buyHouse,
    getPlayerHouses = getPlayerHouses,
    isPlayerInsideHouse = isPlayerInsideHouse,
    getHouseInfo = getHouseInfo
}
