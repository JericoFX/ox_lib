local Phone = lib.class('phone')
local Normalizer = require 'wrappers.normalizer'

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

function Phone:open()
    TriggerEvent('qs-smartphone:client:openPhone')
    return true
end

function Phone:close()
    TriggerEvent('qs-smartphone:client:closePhone')
    return true
end

function Phone:isOpen()
    return exports['qs-smartphone']:isPhoneOpen() or false
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.phone.sendMessage   = function(...) return Phone:sendMessage(...) end
Normalizer.phone.addContact    = function(...) return Phone:addContact(...) end
Normalizer.phone.removeContact = function(...) return Phone:removeContact(...) end
Normalizer.phone.notification  = function(...) return Phone:notification(...) end
Normalizer.phone.open          = function(...) return Phone:open(...) end
Normalizer.phone.close         = function(...) return Phone:close(...) end
Normalizer.phone.isOpen        = function(...) return Phone:isOpen(...) end
Normalizer.capabilities.phone  = true

return Phone
