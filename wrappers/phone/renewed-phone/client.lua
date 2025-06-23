local Phone = lib.class('phone')
local Normalizer = require 'wrappers.normalizer'

function Phone:constructor()
    self.system = 'renewed-phone'
end

local function _notify(data)
    TriggerEvent('ren-phone:client:notification', data)
end

function Phone:sendMessage(number, message)
    _notify({ title = 'Messages', message = message, icon = 'mdi:message', color = 'green', timeout = 5000 })
end

function Phone:addContact(name, number, avatar)
    TriggerServerEvent('ren-phone:server:addContact', { name = name, number = number, avatar = avatar or '' })
    return true
end

function Phone:removeContact(number)
    TriggerServerEvent('ren-phone:server:removeContact', number)
    return true
end

function Phone:notification(title, text, icon, color, timeout)
    _notify({ title = title, message = text, icon = icon or 'mdi:information', color = color or 'white', timeout = timeout or 5000 })
end

function Phone:open()
    TriggerEvent('ren-phone:client:openPhone')
    return true
end

function Phone:close()
    TriggerEvent('ren-phone:client:closePhone')
    return true
end

function Phone:isOpen()
    return exports['renewed-phone']:isPhoneOpen() or false
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
