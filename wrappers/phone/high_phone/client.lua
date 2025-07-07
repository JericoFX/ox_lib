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

local function _notify(payload)
    TriggerEvent('high_phone:client:Notification', payload)
end

function Phone:sendMessage(number, message)
    _notify({ title = 'Messages', text = message, icon = 'message', timeout = 5000 })
end

function Phone:addContact(name, number, avatar)
    TriggerServerEvent('high_phone:server:AddContact', name, number, avatar or '')
end

function Phone:removeContact(number)
    TriggerServerEvent('high_phone:server:RemoveContact', number)
end

function Phone:notification(title, text, icon, color, timeout)
    _notify({ title = title, text = text, icon = icon or 'notification', timeout = timeout or 5000 })
end

function Phone:open()
    TriggerEvent('high_phone:client:Open')
    return true
end

function Phone:close()
    TriggerEvent('high_phone:client:Close')
    return true
end

function Phone:isOpen()
    return exports['high_phone']:isOpen() or false
end

-- Additional Functions Based on Research
function Phone:makeCall(number)
    TriggerServerEvent('high_phone:server:MakeCall', number)
    return true
end

function Phone:answerCall()
    TriggerEvent('high_phone:client:AnswerCall')
    return true
end

function Phone:declineCall()
    TriggerEvent('high_phone:client:DeclineCall')
    return true
end

function Phone:endCall()
    TriggerEvent('high_phone:client:EndCall')
    return true
end

function Phone:isInCall()
    -- This would need to be verified with actual high_phone implementation
    return false -- Conservative approach
end

function Phone:takePhoto()
    TriggerEvent('high_phone:client:TakePhoto')
    return true
end

function Phone:openGallery()
    TriggerEvent('high_phone:client:OpenApp', 'gallery')
    return true
end

function Phone:openApp(appName)
    if not appName then return false end
    TriggerEvent('high_phone:client:OpenApp', appName)
    return true
end

function Phone:closeApp(appName)
    if not appName then return false end
    TriggerEvent('high_phone:client:CloseApp', appName)
    return true
end

function Phone:getPhoneNumber()
    -- This would need framework integration
    return exports['high_phone']:GetPhoneNumber() or nil
end

function Phone:getContacts()
    return exports['high_phone']:GetContacts() or {}
end

function Phone:updateContact(id, data)
    TriggerServerEvent('high_phone:server:UpdateContact', id, data)
    return true
end

function Phone:deletePhoto(photoId)
    TriggerServerEvent('high_phone:server:DeletePhoto', photoId)
    return true
end

function Phone:sharePhoto(photoId, contacts)
    TriggerServerEvent('high_phone:server:SharePhoto', photoId, contacts)
    return true
end

-- Register implementation in Normalizer ------------------------------------
Normalizer.phone.sendMessage    = function(...) return Phone:sendMessage(...) end
Normalizer.phone.addContact     = function(...) return Phone:addContact(...) end
Normalizer.phone.removeContact  = function(...) return Phone:removeContact(...) end
Normalizer.phone.notification   = function(...) return Phone:notification(...) end
Normalizer.phone.open           = function(...) return Phone:open(...) end
Normalizer.phone.close          = function(...) return Phone:close(...) end
Normalizer.phone.isOpen         = function(...) return Phone:isOpen(...) end
Normalizer.phone.makeCall       = function(...) return Phone:makeCall(...) end
Normalizer.phone.answerCall     = function(...) return Phone:answerCall(...) end
Normalizer.phone.declineCall    = function(...) return Phone:declineCall(...) end
Normalizer.phone.endCall        = function(...) return Phone:endCall(...) end
Normalizer.phone.isInCall       = function(...) return Phone:isInCall(...) end
Normalizer.phone.takePhoto      = function(...) return Phone:takePhoto(...) end
Normalizer.phone.openGallery    = function(...) return Phone:openGallery(...) end
Normalizer.phone.openApp        = function(...) return Phone:openApp(...) end
Normalizer.phone.closeApp       = function(...) return Phone:closeApp(...) end
Normalizer.phone.getPhoneNumber = function(...) return Phone:getPhoneNumber(...) end
Normalizer.phone.getContacts    = function(...) return Phone:getContacts(...) end
Normalizer.phone.updateContact  = function(...) return Phone:updateContact(...) end
Normalizer.phone.deletePhoto    = function(...) return Phone:deletePhoto(...) end
Normalizer.phone.sharePhoto     = function(...) return Phone:sharePhoto(...) end
Normalizer.capabilities.phone   = true

return Phone
