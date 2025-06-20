local Phone = lib.class('phone')

function Phone:constructor()
    self.system = 'lb-phone'
end

local function _notify(payload)
    TriggerEvent('lb-phone:client:Notification', payload)
end

function Phone:sendMessage(number, message)
    _notify({ title = 'Messages', text = message, icon = 'fa fa-comment', timeout = 5000, color = '#25D366' })
end

function Phone:addContact(name, number, avatar)
    TriggerServerEvent('lb-phone:server:AddContact', name, number, avatar or '')
end

function Phone:removeContact(number)
    TriggerServerEvent('lb-phone:server:RemoveContact', number)
end

function Phone:notification(title, text, icon, color, timeout)
    _notify({ title = title, text = text, icon = icon or 'fa fa-info-circle', timeout = timeout or 5000, color = color or '#4299e1' })
end

return Phone
