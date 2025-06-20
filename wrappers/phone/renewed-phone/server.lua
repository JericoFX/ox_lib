--[[
    Renewed Phone Wrapper - Server Side
]]

if GetResourceState('renewed-phone') ~= 'started' then
    return {}
end

local function notify(source, title, text, icon, color, timeout)
    TriggerClientEvent('ren-phone:client:notification', source, {
        title   = title,
        message = text,
        icon    = icon or 'mdi:information',
        color   = color or 'white',
        timeout = timeout or 5000
    })
end

local function sendMessage(source, number, message)
    notify(source, 'Messages', message, 'mdi:message', 'green')
end

return {
    sendMessage  = sendMessage,
    notification = notify,
}
