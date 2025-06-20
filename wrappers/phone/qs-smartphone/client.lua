local Phone = lib.class('phone')

function Phone:constructor()
    self.system = 'qs-smartphone'
end

local function _notify(payload)
    TriggerEvent('qs-smartphone:client:notification', payload)
end

function Phone:sendMessage(number, message)
    _notify({ title = 'Messages', text = message, icon = 'fa fa-comment', duration = 5000, color = '#25D366' })
end

function Phone:addContact(name, number, avatar)
    TriggerServerEvent('qs-smartphone:server:addNewContact', name, number, avatar or '')
end

function Phone:removeContact(number)
    TriggerServerEvent('qs-smartphone:server:removeContact', number)
end

function Phone:notification(title, text, icon, color, timeout)
    _notify({ title = title, text = text, icon = icon or 'fa fa-info-circle', duration = timeout or 5000, color = color or '#4299e1' })
end

return Phone
