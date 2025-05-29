-- Client-side Events API
local events = require 'api.events.init'

-- Client-specific event listeners
lib.events = lib.events or {}

-- Register client event
function lib.events.on(eventName, callback)
    return events.on(eventName, callback)
end

-- Remove client event listener
function lib.events.off(eventName, callback)
    return events.off(eventName, callback)
end

-- Trigger client event
function lib.events.trigger(eventName, ...)
    return events.trigger(eventName, ...)
end

-- Emit event to server
function lib.events.emitServer(eventName, ...)
    TriggerServerEvent('lib:events:' .. eventName, ...)
end

-- Emit event to all clients (if server allows)
function lib.events.emitAll(eventName, ...)
    TriggerServerEvent('lib:events:emitAll', eventName, ...)
end

-- Get available events for current framework
function lib.events.getAvailable()
    return events.getAvailableEvents()
end

-- Initialize common client events
CreateThread(function()
    -- Player loaded event
    lib.events.on('player:loaded', function(player)
        lib.print.info('Universal player loaded event triggered', player.citizenid)
    end)

    -- Job change event
    lib.events.on('player:job:changed', function(player, oldJob, newJob)
        lib.print.info('Player job changed', {
            citizenid = player.citizenid,
            from = oldJob and oldJob.name or 'none',
            to = newJob and newJob.name or 'none'
        })
    end)

    -- Money change event
    lib.events.on('player:money:changed', function(player, account, amount, reason)
        lib.print.info('Player money changed', {
            citizenid = player.citizenid,
            account = account,
            amount = amount,
            reason = reason
        })
    end)
end)

-- Register server event handlers
RegisterNetEvent('lib:events:trigger')
AddEventHandler('lib:events:trigger', function(eventName, ...)
    events.trigger(eventName, ...)
end)
