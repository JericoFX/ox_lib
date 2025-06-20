--[[
    QS Smartphone Wrapper - Server Side
]]

if GetResourceState('qs-smartphone') ~= 'started' then
    return {}
end

-- helpers -------------------------------------------------------------------

local function _notify(source, payload)
    TriggerClientEvent('qs-smartphone:client:notification', source, payload)
end

local function sendMessage(source, number, message)
    _notify(source, { title = 'Messages', text = message, icon = 'fa fa-comment', duration = 5000, color = '#25D366' })
end

local function addContact(source, name, number, avatar)
    TriggerEvent('qs-smartphone:server:addNewContact', source, name, number, avatar or '')
end

local function removeContact(source, number)
    TriggerEvent('qs-smartphone:server:removeContact', source, number)
end

local function notification(source, title, text, icon, color, timeout)
    _notify(source, { title = title, text = text, icon = icon or 'fa fa-info-circle', duration = timeout or 5000, color = color or '#4299e1' })
end

return {
    sendMessage   = sendMessage,
    addContact    = addContact,
    removeContact = removeContact,
    notification  = notification,
}
