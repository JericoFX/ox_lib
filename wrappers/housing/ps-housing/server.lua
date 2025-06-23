if GetResourceState('ps-housing') ~= 'started' then
    return {}
end

local Normalizer = require 'wrappers.normalizer'

local enterHouse = function(source, houseId)
    TriggerClientEvent('ps-housing:client:enterHouse', source, houseId)
end

local exitHouse = function(source)
    TriggerClientEvent('ps-housing:client:exitHouse', source)
end

local createHouse = function(coords, price, owner, houseType)
    local success, result = pcall(function()
        return exports['ps-housing']:createHouse(coords, price, owner, houseType or 'house')
    end)
    return success and result or false
end

local buyHouse = function(source, houseId)
    local success, result = pcall(function()
        return exports['ps-housing']:buyHouse(source, houseId)
    end)
    return success and result or false
end

local getPlayerHouses = function(source)
    local success, result = pcall(function()
        return exports['ps-housing']:getPlayerHouses(source)
    end)
    return success and result or {}
end

local isPlayerInsideHouse = function(source)
    local success, result = pcall(function()
        return exports['ps-housing']:isPlayerInsideHouse(source)
    end)
    return success and result or false
end

local getHouseInfo = function(houseId)
    local success, result = pcall(function()
        return exports['ps-housing']:getHouseInfo(houseId)
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
    system = 'ps-housing',

    enterHouse = enterHouse,
    exitHouse = exitHouse,
    createHouse = createHouse,
    buyHouse = buyHouse,
    getPlayerHouses = getPlayerHouses,
    isPlayerInsideHouse = isPlayerInsideHouse,
    getHouseInfo = getHouseInfo
}
