---@meta

---@class lib.events
---@field on fun(eventName: string, callback: function): boolean Register event listener
---@field off fun(eventName: string, callback: function): boolean Remove event listener
---@field trigger fun(eventName: string, ...): boolean Trigger client event
---@field emitServer fun(eventName: string, ...) Emit event to server
---@field emitAll fun(eventName: string, ...) Emit event to all clients
---@field getAvailable fun(): table Get available events for current framework

-- Client-side Events API - Pure Events Only
local events = require 'api.events.init'

lib.events = lib.events or {}

---Register client event listener
---@param eventName string The event name to listen for
---@param callback function The callback function to execute
---@return boolean success True if event was registered successfully
function lib.events.on(eventName, callback)
    return events.on(eventName, callback)
end

---Remove client event listener
---@param eventName string The event name to stop listening for
---@param callback function The callback function to remove
---@return boolean success True if event was removed successfully
function lib.events.off(eventName, callback)
    return events.off(eventName, callback)
end

---Trigger client event
---@param eventName string The event name to trigger
---@param ... any Additional arguments to pass to event handlers
---@return boolean success True if event was triggered successfully
function lib.events.trigger(eventName, ...)
    return events.trigger(eventName, ...)
end

---Emit event to server
---@param eventName string The event name to emit to server
---@param ... any Additional arguments to pass to server
function lib.events.emitServer(eventName, ...)
    TriggerServerEvent('lib:events:' .. eventName, ...)
end

---Emit event to all clients (if server allows)
---@param eventName string The event name to emit to all clients
---@param ... any Additional arguments to pass to all clients
function lib.events.emitAll(eventName, ...)
    TriggerServerEvent('lib:events:emitAll', eventName, ...)
end

---Get available events for current framework
---@return table events List of available events for the current framework
function lib.events.getAvailable()
    return events.getAvailableEvents()
end

-- Register server event handlers
RegisterNetEvent('lib:events:trigger')
AddEventHandler('lib:events:trigger', function(eventName, ...)
    events.trigger(eventName, ...)
end)
