local Phone = lib.class('phone')
local Normalizer = require 'wrappers.normalizer'

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

function Phone:open()
    TriggerEvent('lb-phone:client:ToggleOpen', true)
    return true
end

function Phone:close()
    TriggerEvent('lb-phone:client:ToggleOpen', false)
    return true
end

function Phone:isOpen()
    return exports['lb-phone']:isOpen() or false
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
