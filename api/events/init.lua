-- Universal Events System for ox_lib
-- Provides normalized event handling across different frameworks

local events = {}
local registeredEvents = {}
local eventMappings = {}

-- Event mappings for different frameworks
local frameworkMappings = {
    ['esx'] = {
        ['player:loaded'] = 'esx:playerLoaded',
        ['player:logout'] = 'esx:playerLogout',
        ['player:job:changed'] = 'esx:setJob',
        ['player:money:changed'] = 'esx:setAccountMoney',
        ['vehicle:spawned'] = 'esx:spawnVehicle',
        ['player:arrested'] = 'esx:onPlayerArrested',
        ['player:died'] = 'esx:onPlayerDeath'
    },
    ['qbcore'] = {
        ['player:loaded'] = 'QBCore:Client:OnPlayerLoaded',
        ['player:logout'] = 'QBCore:Client:OnPlayerUnload',
        ['player:job:changed'] = 'QBCore:Client:OnJobUpdate',
        ['player:money:changed'] = 'QBCore:Client:OnMoneyChange',
        ['vehicle:spawned'] = 'QBCore:Client:VehicleSpawned',
        ['player:arrested'] = 'police:client:SetInJail',
        ['player:died'] = 'hospital:client:Revive'
    },
    ['ox_core'] = {
        ['player:loaded'] = 'ox:playerLoaded',
        ['player:logout'] = 'ox:playerLogout',
        ['player:job:changed'] = 'ox:setGroup',
        ['player:money:changed'] = 'ox:setMoney',
        ['vehicle:spawned'] = 'ox:vehicleSpawned',
        ['player:arrested'] = 'ox:playerArrested',
        ['player:died'] = 'ox:playerDied'
    }
}

-- Server-side event mappings
local serverMappings = {
    ['esx'] = {
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
        return 'esx'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qbcore'
    elseif GetResourceState('ox_core') == 'started' then
        return 'ox_core'
    end
    return nil
end

-- Data normalization functions
local function normalizePlayerData(framework, data)
    if framework == 'esx' then
        return {
            source = data.source,
            citizenid = data.identifier,
            charinfo = {
                firstname = data.firstName or data.get('firstName'),
                lastname = data.lastName or data.get('lastName'),
                phone = data.phone or data.get('phoneNumber')
            },
            money = {
                cash = data.getMoney and data.getMoney() or data.money,
                bank = data.getAccount and data.getAccount('bank').money or 0
            },
            job = {
                name = data.job and data.job.name or 'unemployed',
                label = data.job and data.job.label or 'Unemployed',
                grade = data.job and data.job.grade or 0
            }
        }
    elseif framework == 'qbcore' then
        return {
            source = data.PlayerData.source,
            citizenid = data.PlayerData.citizenid,
            charinfo = data.PlayerData.charinfo,
            money = data.PlayerData.money,
            job = data.PlayerData.job
        }
    elseif framework == 'ox_core' then
        return {
            source = data.source,
            citizenid = data.charid,
            charinfo = {
                firstname = data.get('firstName'),
                lastname = data.get('lastName'),
                phone = data.get('phoneNumber')
            },
            money = {
                cash = data.get('money'),
                bank = data.getAccount('bank')
            },
            job = {
                name = data.getGroup(),
                label = data.getGroup(),
                grade = data.getGrade()
            }
        }
    end
    return data
end

-- Register event listener
function events.on(eventName, callback)
    if not registeredEvents[eventName] then
        registeredEvents[eventName] = {}
    end

    table.insert(registeredEvents[eventName], callback)

    -- Auto-register framework-specific events
    local framework = detectFramework()
    if framework then
        local mappings = IsDuplicityVersion() and serverMappings[framework] or frameworkMappings[framework]
        local frameworkEvent = mappings and mappings[eventName]

        if frameworkEvent and not eventMappings[frameworkEvent] then
            eventMappings[frameworkEvent] = eventName

            if IsDuplicityVersion() then
                -- Server-side
                RegisterServerEvent(frameworkEvent)
                AddEventHandler(frameworkEvent, function(...)
                    local args = { ... }
                    local normalizedData = normalizePlayerData(framework, args[1])
                    events.trigger(eventName, normalizedData, table.unpack(args, 2))
                end)
            else
                -- Client-side
                RegisterNetEvent(frameworkEvent)
                AddEventHandler(frameworkEvent, function(...)
                    local args = { ... }
                    local normalizedData = normalizePlayerData(framework, args[1])
                    events.trigger(eventName, normalizedData, table.unpack(args, 2))
                end)
            end
        end
    end
end

-- Trigger event
function events.trigger(eventName, ...)
    local handlers = registeredEvents[eventName]
    if handlers then
        for i = 1, #handlers do
            handlers[i](...)
        end
    end
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

-- Remove event listener
function events.off(eventName, callback)
    local handlers = registeredEvents[eventName]
    if handlers then
        for i = #handlers, 1, -1 do
            if handlers[i] == callback then
                table.remove(handlers, i)
                break
            end
        end
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
