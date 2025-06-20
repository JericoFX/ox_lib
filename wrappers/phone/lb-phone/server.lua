--[[
    LB-Phone Wrapper - Server Side
]]

if GetResourceState('lb-phone') ~= 'started' then
    return {}
end

local function _notify(source, payload)
    TriggerClientEvent('lb-phone:client:Notification', source, payload)
end

local function sendMessage(source, number, message)
    _notify(source, { title = 'Messages', text = message, icon = 'fa fa-comment', timeout = 5000, color = '#25D366' })
end

local function addContact(source, name, number, avatar)
    TriggerClientEvent('lb-phone:client:AddContact', source, name, number, avatar or '')
end

local function removeContact(source, number)
    TriggerClientEvent('lb-phone:client:RemoveContact', source, number)
end

local function notification(source, title, text, icon, color, timeout)
    _notify(source, { title = title, text = text, icon = icon or 'fa fa-info-circle', timeout = timeout or 5000, color = color or '#4299e1' })
end

return {
    sendMessage   = sendMessage,
    addContact    = addContact,
    removeContact = removeContact,
    notification  = notification,
}
