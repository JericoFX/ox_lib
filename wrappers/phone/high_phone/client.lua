--[[
    High Phone Wrapper - Client Side
]]

if GetResourceState('high_phone') ~= 'started' then
    return {}
end

local Phone = lib.class('phone')
local Normalizer = require 'wrappers.normalizer'

function Phone:constructor()
    self.system = 'high_phone'
end

function Phone:sendMessage(number, message)
    TriggerEvent('high_phone:client:sendMessage', number, message)
    return true
end

function Phone:addContact(name, number, avatar)
    TriggerEvent('high_phone:client:addContact', name, number, avatar or '')
    return true
end

function Phone:removeContact(number)
    TriggerEvent('high_phone:client:removeContact', number)
    return true
end

function Phone:notification(title, text, icon, color, timeout)
    TriggerEvent('high_phone:client:notification', {
        title = title,
        text = text,
        icon = icon or 'fa fa-info-circle',
        color = color or '#4299e1',
        timeout = timeout or 5000
    })
    return true
end

function Phone:open()
    TriggerEvent('high_phone:client:open')
    return true
end

function Phone:close()
    TriggerEvent('high_phone:client:close')
    return true
end

function Phone:isOpen()
    return exports['high_phone']:isOpen() or false
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
