local Phone = lib.class('phone')
local Normalizer = require 'wrappers.normalizer'

function Phone:constructor()
    self.system = 'qb-phone'
end

---@param number string|number
---@param message string
function Phone:sendMessage(number, message)
    TriggerEvent('qb-phone:client:CustomNotification', 'Messages', message, 'fas fa-comment', '#25D366', 5000)
end

function Phone:addContact(name, number, avatar)
    TriggerEvent('qb-phone:client:AddNewContact', name, number, avatar)
end

function Phone:removeContact(number)
    TriggerEvent('qb-phone:client:RemoveContact', number)
end

function Phone:notification(title, text, icon, color, timeout)
    TriggerEvent('qb-phone:client:CustomNotification', title, text, icon or 'fas fa-info-circle', color or '#4299e1', timeout or 5000)
end

function Phone:open()
    TriggerEvent('qb-phone:client:openPhone')
end

function Phone:close()
    TriggerEvent('qb-phone:client:closePhone')
end

function Phone:isOpen()
    return exports['qb-phone']:isPhoneOpen()
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
