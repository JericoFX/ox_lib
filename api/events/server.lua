-- Server-side Events API - Pure Events Only
local events = require 'api.events.shared'

lib.events = lib.events or {}

---Register server event listener
---@param eventName string The event name to listen for
---@param callback function The callback function to execute
---@return boolean success True if event was registered successfully
function lib.events.on(eventName, callback)
    return events.on(eventName, callback)
end

---Remove server event listener
---@param eventName string The event name to stop listening for
---@param callback function The callback function to remove
---@return boolean success True if event was removed successfully
function lib.events.off(eventName, callback)
    return events.off(eventName, callback)
end

---Trigger server event
---@param eventName string The event name to trigger
---@param ... any Additional arguments to pass to event handlers
---@return boolean success True if event was triggered successfully
function lib.events.trigger(eventName, ...)
    return events.trigger(eventName, ...)
end

---Emit event to specific client
---@param source number The player source to emit to
---@param eventName string The event name to emit
---@param ... any Additional arguments to pass to client
function lib.events.emitClient(source, eventName, ...)
    TriggerClientEvent('lib:events:trigger', source, eventName, ...)
end

---Emit event to all clients
---@param eventName string The event name to emit to all clients
---@param ... any Additional arguments to pass to all clients
function lib.events.emitAllClients(eventName, ...)
    --  TriggerClientEvent('lib:events:trigger', -1, eventName, ...)
    lib.triggerClientEvent(eventName, -1, ...)
end

---Get available events for current framework
---@return table events List of available events for the current framework
function lib.events.getAvailable()
    return events.getAvailableEvents()
end

-- Register client event handlers
RegisterServerEvent('lib:events:emitAll', function(eventName, ...)
    local source <const> = source
    lib.events.emitAllClients(eventName, ...)
end)

-- Handle client-to-server events
local function registerClientEvent(eventName)
    RegisterServerEvent('lib:events:' .. eventName, function(...)
        local source = source
        events.trigger(eventName, source, ...)
    end)
end

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
