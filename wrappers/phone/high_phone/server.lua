--[[
    High Phone Wrapper - Server Side
]]

if GetResourceState('high_phone') ~= 'started' then
    return {}
end

local Normalizer = require 'wrappers.normalizer'

local function notification(source, title, text, timeout)
    TriggerClientEvent('high_phone:notify', source, title or 'Phone', text, timeout or 5000)
end

local function sendMessage(source, number, message)
    notification(source, 'Messages', message, 5000)
end

local function addContact(source, name, number, avatar)
    TriggerClientEvent('high_phone:addContact', source, name, number, avatar or '')
    return true
end

local function removeContact(source, number)
    TriggerClientEvent('high_phone:removeContact', source, number)
    return true
end

-- Register implementation in Normalizer ------------------------------------
-- Note: high_phone is primarily server-side, so we register basic functionality
-- Normalizer.phone.sendMessage  = sendMessage  -- Server normalizer would need different pattern
-- Normalizer.phone.notification = notification
-- Normalizer.capabilities.phone = true

return {
    sendMessage   = sendMessage,
    notification  = notification,
    addContact    = addContact,
    removeContact = removeContact,
}
