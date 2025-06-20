--[[
    High Phone Wrapper - Server Side
]]

if GetResourceState('high_phone') ~= 'started' then
    return {}
end

local function notification(source, title, text, timeout)
    TriggerClientEvent('high_phone:notify', source, title or 'Phone', text, timeout or 5000)
end

local function sendMessage(source, number, message)
    notification(source, 'Messages', message, 5000)
end

return {
    sendMessage  = sendMessage,
    notification = notification,
}
