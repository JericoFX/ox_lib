if GetResourceState('qb-houses') ~= 'started' then return end
local Housing = lib.class('Housing')

function Housing:constructor()
    self.system = 'qb-houses'
end

function Housing:enterHouse(houseId)
    TriggerServerEvent('qb-houses:server:enterHouse', houseId)
    return true
end

function Housing:exitHouse()
    TriggerServerEvent('qb-houses:server:exitHouse')
    return true
end

function Housing:createHouse(coords, price, houseType)
    TriggerServerEvent('qb-houses:server:createHouse', coords, price, houseType or 'house')
    return true
end

function Housing:buyHouse(houseId)
    TriggerServerEvent('qb-houses:server:buyHouse', houseId)
    return true
end

function Housing:openHouseMenu()
    TriggerEvent('qb-houses:client:openHouseMenu')
    return true
end

function Housing:getPlayerHouses()
    return exports['qb-houses']:getPlayerHouses() or {}
end

function Housing:isPlayerInsideHouse()
    return exports['qb-houses']:isInsideHouse() or false
end

function Housing:getCurrentHouse()
    return exports['qb-houses']:getCurrentHouse()
end

return Housing
