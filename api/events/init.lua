-- Universal Events System for ox_lib
-- Provides normalized event handling across different frameworks

local events = {}
local registeredEvents = {}
local eventMappings = {}
local frameworkHandlers = {} -- Track framework event handlers for cleanup

-- Event mappings for different frameworks
local frameworkMappings = {
    ['es_extended'] = {
        ['player:loaded'] = 'esx:playerLoaded',
        ['player:logout'] = 'esx:playerLogout',
        ['player:job:changed'] = 'esx:setJob',
        ['player:money:changed'] = 'esx:setAccountMoney',
        ['player:money:add'] = 'esx:addMoney',
        ['player:money:remove'] = 'esx:removeMoney',
        ['vehicle:spawned'] = 'esx:spawnVehicle',
        ['player:arrested'] = 'esx:onPlayerArrested',
        ['player:died'] = 'esx:onPlayerDeath'
    },
    ['qbcore'] = {
        ['player:loaded'] = 'QBCore:Client:OnPlayerLoaded',
        ['player:logout'] = 'QBCore:Client:OnPlayerUnload',
        ['player:job:changed'] = 'QBCore:Client:OnJobUpdate',
        ['player:money:changed'] = 'QBCore:Client:OnMoneyChange',
        ['player:money:add'] = 'QBCore:Client:OnMoneyChange',
        ['player:money:remove'] = 'QBCore:Client:OnMoneyChange',
        ['vehicle:spawned'] = 'QBCore:Client:VehicleSpawned',
        ['player:arrested'] = 'police:client:SetInJail',
        ['player:died'] = 'hospital:client:Revive'
    },
    ['ox_core'] = {
        ['player:loaded'] = 'ox:playerLoaded',
        ['player:logout'] = 'ox:playerLogout',
        ['player:job:changed'] = 'ox:setGroup',
        ['player:money:changed'] = 'ox:setMoney',
        ['player:money:add'] = 'ox:addMoney',
        ['player:money:remove'] = 'ox:removeMoney',
        ['vehicle:spawned'] = 'ox:vehicleSpawned',
        ['player:arrested'] = 'ox:playerArrested',
        ['player:died'] = 'ox:playerDied'
    }
}

-- Server-side event mappings
local serverMappings = {
    ['es_extended'] = {
        ['player:connected'] = 'esx:playerLoaded',
        ['player:disconnected'] = 'esx:playerDropped',
        ['player:money:add'] = 'esx:addInventoryItem',
        ['player:item:add'] = 'esx:addInventoryItem',
        ['player:item:remove'] = 'esx:removeInventoryItem'
    },
    ['qbcore'] = {
        ['player:connected'] = 'QBCore:Server:OnPlayerLoaded',
        ['player:disconnected'] = 'QBCore:Server:OnPlayerUnload',
        ['player:money:add'] = 'QBCore:Server:OnMoneyChange',
        ['player:item:add'] = 'QBCore:Server:AddItem',
        ['player:item:remove'] = 'QBCore:Server:RemoveItem'
    },
    ['ox_core'] = {
        ['player:connected'] = 'ox:playerJoined',
        ['player:disconnected'] = 'ox:playerLeft',
        ['player:money:add'] = 'ox:addMoney',
        ['player:item:add'] = 'ox:addItem',
        ['player:item:remove'] = 'ox:removeItem'
    }
}

-- Detect framework
local function detectFramework()
    if GetResourceState('es_extended') == 'started' then
        return 'es_extended'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qbcore'
    elseif GetResourceState('ox_core') == 'started' then
        return 'ox_core'
    end
    return nil
end

-- Register event listener
function events.on(eventName, callback)

    if not registeredEvents[eventName] then
        registeredEvents[eventName] = {}
    end

    table.insert(registeredEvents[eventName], callback)
    local framework = detectFramework()

    if framework then
        local mappings = IsDuplicityVersion() and serverMappings[framework] or frameworkMappings[framework]
        local frameworkEvent = mappings and mappings[eventName]

        if frameworkEvent and not eventMappings[frameworkEvent] then
            eventMappings[frameworkEvent] = eventName

            local handler
            if IsDuplicityVersion() then
                handler = RegisterServerEvent(frameworkEvent, function(...)
                    events.trigger(eventName, ...)
                end)
            else
                handler = RegisterNetEvent(frameworkEvent, function(...)
                    events.trigger(eventName, ...)
                end)
            end
            
            frameworkHandlers[frameworkEvent] = handler
        end
    end

    return true
end

-- Remove event listener
function events.off(eventName, callback)
    local handlers = registeredEvents[eventName]
    if handlers then
        for i = #handlers, 1, -1 do
            if handlers[i] == callback then
                table.remove(handlers, i)
                
                -- Limpiamos los handlers de los frameworks o lo que se use para que no ocupen espacio
                if #handlers == 0 then
                    local framework = detectFramework()
                    if framework then
                        local mappings = IsDuplicityVersion() and serverMappings[framework] or frameworkMappings[framework]
                        local frameworkEvent = mappings and mappings[eventName]
                        
                        if frameworkEvent and frameworkHandlers[frameworkEvent] then
                            RemoveEventHandler(frameworkHandlers[frameworkEvent])
                            frameworkHandlers[frameworkEvent] = nil
                            eventMappings[frameworkEvent] = nil
                        end
                    end
                end
                
                return true
            end
        end
    end
    return false
end

-- Trigger event
function events.trigger(eventName, ...)
    local handlers = registeredEvents[eventName]
    if handlers then
        for i = 1, #handlers do
            handlers[i](...)
        end
        return true
    end
    return false
end

-- Emit event (cross-resource)
function events.emit(eventName, ...)
    if IsDuplicityVersion() then
        TriggerEvent(eventName, ...)
        TriggerClientEvent(eventName, -1, ...)
    else
        TriggerEvent(eventName, ...)
        TriggerServerEvent(eventName, ...)
    end
end

-- Get available events
function events.getAvailableEvents()
    local framework = detectFramework()
    if framework then
        local mappings = IsDuplicityVersion() and serverMappings[framework] or frameworkMappings[framework]
        local available = {}
        for universalEvent, _ in pairs(mappings) do
            table.insert(available, universalEvent)
        end
        return available
    end
    return {}
end

return events
