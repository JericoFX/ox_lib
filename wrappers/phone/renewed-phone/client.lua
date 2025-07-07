local Phone = lib.class('phone')
local Normalizer = require 'wrappers.normalizer'

function Phone:constructor()
    self.system = 'renewed-phone'
end

local function _notify(payload)
    TriggerEvent('renewed-phone:client:Notification', payload)
end

function Phone:sendMessage(number, message)
    _notify({ title = 'Messages', text = message, icon = 'message', timeout = 5000 })
end

function Phone:addContact(name, number, avatar)
    TriggerServerEvent('renewed-phone:server:AddContact', name, number, avatar or '')
end

function Phone:removeContact(number)
    TriggerServerEvent('renewed-phone:server:RemoveContact', number)
end

function Phone:notification(title, text, icon, color, timeout)
    _notify({ title = title, text = text, icon = icon or 'notification', timeout = timeout or 5000 })
end

function Phone:open()
    TriggerEvent('renewed-phone:client:Open')
    return true
end

function Phone:close()
    TriggerEvent('renewed-phone:client:Close')
    return true
end

function Phone:isOpen()
    return exports['renewed-phone']:isPhoneOpen() or false
end

-- Additional Functions Based on Research
function Phone:makeCall(number)
    TriggerServerEvent('renewed-phone:server:MakeCall', number)
    return true
end

function Phone:answerCall()
    TriggerEvent('renewed-phone:client:AnswerCall')
    return true
end

function Phone:declineCall()
    TriggerEvent('renewed-phone:client:DeclineCall')
    return true
end

function Phone:endCall()
    TriggerEvent('renewed-phone:client:EndCall')
    return true
end

function Phone:isInCall()
    -- This would need to be verified with actual renewed-phone implementation
    return false -- Conservative approach
end

function Phone:takePhoto()
    TriggerEvent('renewed-phone:client:TakePhoto')
    return true
end

function Phone:openGallery()
    TriggerEvent('renewed-phone:client:OpenApp', 'gallery')
    return true
end

function Phone:openApp(appName)
    if not appName then return false end
    TriggerEvent('renewed-phone:client:OpenApp', appName)
    return true
end

function Phone:closeApp(appName)
    if not appName then return false end
    TriggerEvent('renewed-phone:client:CloseApp', appName)
    return true
end

function Phone:getPhoneNumber()
    -- This would need framework integration
    return exports['renewed-phone']:GetPhoneNumber() or nil
end

function Phone:getContacts()
    return exports['renewed-phone']:GetContacts() or {}
end

function Phone:updateContact(id, data)
    TriggerServerEvent('renewed-phone:server:UpdateContact', id, data)
    return true
end

function Phone:deletePhoto(photoId)
    TriggerServerEvent('renewed-phone:server:DeletePhoto', photoId)
    return true
end

function Phone:sharePhoto(photoId, contacts)
    TriggerServerEvent('renewed-phone:server:SharePhoto', photoId, contacts)
    return true
end

function Phone:installApp(appId)
    TriggerServerEvent('renewed-phone:server:InstallApp', appId)
    return true
end

function Phone:uninstallApp(appId)
    TriggerServerEvent('renewed-phone:server:UninstallApp', appId)
    return true
end

function Phone:getInstalledApps()
    return exports['renewed-phone']:GetInstalledApps() or {}
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.phone.sendMessage      = function(...) return Phone:sendMessage(...) end
Normalizer.phone.addContact       = function(...) return Phone:addContact(...) end
Normalizer.phone.removeContact    = function(...) return Phone:removeContact(...) end
Normalizer.phone.notification     = function(...) return Phone:notification(...) end
Normalizer.phone.open             = function(...) return Phone:open(...) end
Normalizer.phone.close            = function(...) return Phone:close(...) end
Normalizer.phone.isOpen           = function(...) return Phone:isOpen(...) end
Normalizer.phone.makeCall         = function(...) return Phone:makeCall(...) end
Normalizer.phone.answerCall       = function(...) return Phone:answerCall(...) end
Normalizer.phone.declineCall      = function(...) return Phone:declineCall(...) end
Normalizer.phone.endCall          = function(...) return Phone:endCall(...) end
Normalizer.phone.isInCall         = function(...) return Phone:isInCall(...) end
Normalizer.phone.takePhoto        = function(...) return Phone:takePhoto(...) end
Normalizer.phone.openGallery      = function(...) return Phone:openGallery(...) end
Normalizer.phone.openApp          = function(...) return Phone:openApp(...) end
Normalizer.phone.closeApp         = function(...) return Phone:closeApp(...) end
Normalizer.phone.getPhoneNumber   = function(...) return Phone:getPhoneNumber(...) end
Normalizer.phone.getContacts      = function(...) return Phone:getContacts(...) end
Normalizer.phone.updateContact    = function(...) return Phone:updateContact(...) end
Normalizer.phone.deletePhoto      = function(...) return Phone:deletePhoto(...) end
Normalizer.phone.sharePhoto       = function(...) return Phone:sharePhoto(...) end
Normalizer.phone.installApp       = function(...) return Phone:installApp(...) end
Normalizer.phone.uninstallApp     = function(...) return Phone:uninstallApp(...) end
Normalizer.phone.getInstalledApps = function(...) return Phone:getInstalledApps(...) end
Normalizer.capabilities.phone     = true

return Phone
