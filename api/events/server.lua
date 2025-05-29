-- Server-side Events API
local events = require 'api.events.init'

-- Server-specific event listeners
lib.events = lib.events or {}

-- Register server event
function lib.events.on(eventName, callback)
    return events.on(eventName, callback)
end

-- Remove server event listener
function lib.events.off(eventName, callback)
    return events.off(eventName, callback)
end

-- Trigger server event
function lib.events.trigger(eventName, ...)
    return events.trigger(eventName, ...)
end

-- Emit event to specific client
function lib.events.emitClient(source, eventName, ...)
    TriggerClientEvent('lib:events:trigger', source, eventName, ...)
end

-- Emit event to all clients
function lib.events.emitAllClients(eventName, ...)
    TriggerClientEvent('lib:events:trigger', -1, eventName, ...)
end

-- Get available events for current framework
function lib.events.getAvailable()
    return events.getAvailableEvents()
end

-- Register client event handlers
RegisterServerEvent('lib:events:emitAll')
AddEventHandler('lib:events:emitAll', function(eventName, ...)
    local source = source
    lib.events.emitAllClients(eventName, ...)
end)

-- Handle client-to-server events
local function registerClientEvent(eventName)
    RegisterServerEvent('lib:events:' .. eventName)
    AddEventHandler('lib:events:' .. eventName, function(...)
        local source = source
        events.trigger(eventName, source, ...)
    end)
end

-- Initialize common server events
CreateThread(function()
    -- Player connection events
    lib.events.on('player:connected', function(player)
        lib.print.info('Universal player connected event triggered', player.citizenid)
        lib.events.emitClient(player.source, 'player:loaded', player)
    end)

    lib.events.on('player:disconnected', function(player, reason)
        lib.print.info('Player disconnected', {
            citizenid = player.citizenid,
            reason = reason
        })
    end)

    -- Money and item events
    lib.events.on('player:money:add', function(player, account, amount, reason)
        lib.print.info('Player money added', {
            citizenid = player.citizenid,
            account = account,
            amount = amount,
            reason = reason
        })
    end)

    lib.events.on('player:item:add', function(player, item, count, metadata)
        lib.print.info('Player item added', {
            citizenid = player.citizenid,
            item = item,
            count = count,
            metadata = metadata
        })
    end)

    lib.events.on('player:item:remove', function(player, item, count, metadata)
        lib.print.info('Player item removed', {
            citizenid = player.citizenid,
            item = item,
            count = count,
            metadata = metadata
        })
    end)
end)

-- Auto-register common client events
local commonClientEvents = {
    'player:interact',
    'player:keypress',
    'player:vehicle:enter',
    'player:vehicle:exit',
    'player:death',
    'player:respawn'
}

for _, eventName in ipairs(commonClientEvents) do
    registerClientEvent(eventName)
end
