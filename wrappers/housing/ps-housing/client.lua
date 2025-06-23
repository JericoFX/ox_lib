if GetResourceState('ps-housing') ~= 'started' then return end

local Housing = lib.class('Housing')

function Housing:constructor()
    self.system = 'ps-housing'
end

function Housing:enterHouse(houseId)
    TriggerEvent('ps-housing:client:enterHouse', houseId)
    return true
end

function Housing:exitHouse()
    TriggerEvent('ps-housing:client:exitHouse')
    return true
end

function Housing:createHouse(coords, price, houseType)
    TriggerServerEvent('ps-housing:server:createHouse', coords, price, houseType or 'house')
    return true
end

function Housing:buyHouse(houseId)
    TriggerServerEvent('ps-housing:server:buyHouse', houseId)
    return true
end

function Housing:openHouseMenu()
    TriggerEvent('ps-housing:client:openMenu')
    return true
end

function Housing:getPlayerHouses()
    local success, result = pcall(function()
        return exports['ps-housing']:getPlayerHouses()
    end)
    return success and result or {}
end

function Housing:isPlayerInsideHouse()
    local success, result = pcall(function()
        return exports['ps-housing']:isInsideHouse()
    end)
    return success and result or false
end

function Housing:getCurrentHouse()
    local success, result = pcall(function()
        return exports['ps-housing']:getCurrentHouse()
    end)
    return success and result or nil
end

function Housing:openInventory()
    TriggerEvent('ps-housing:client:openInventory')
    return true
end

return Housing
