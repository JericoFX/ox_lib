local Phone = lib.class('phone')

function Phone:constructor()
    self.system = 'renewed-phone'
end

local function _notify(data)
    TriggerEvent('ren-phone:client:notification', data)
end

function Phone:sendMessage(number, message)
    _notify({ title = 'Messages', message = message, icon = 'mdi:message', color = 'green', timeout = 5000 })
end

function Phone:notification(title, text, icon, color, timeout)
    _notify({ title = title, message = text, icon = icon or 'mdi:information', color = color or 'white', timeout = timeout or 5000 })
end

return Phone
