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

-- Additional Functions Based on Research
function Phone:makeCall(number)
    TriggerEvent('qb-phone:client:CallContact', number, nil, nil)
    return true
end

function Phone:answerCall()
    TriggerEvent('qb-phone:client:AnswerCall')
    return true
end

function Phone:declineCall()
    TriggerEvent('qb-phone:client:CancelCall')
    return true
end

function Phone:endCall()
    TriggerEvent('qb-phone:client:CancelCall')
    return true
end

function Phone:isInCall()
    -- This would need to be verified with actual qb-phone implementation
    return false -- Conservative approach
end

function Phone:takePhoto()
    TriggerEvent('qb-phone:client:TakePhoto')
    return true
end

function Phone:openGallery()
    TriggerEvent('qb-phone:client:OpenApp', 'gallery')
    return true
end

function Phone:openApp(appName)
    if not appName then return false end
    TriggerEvent('qb-phone:client:OpenApp', appName)
    return true
end

function Phone:closeApp(appName)
    if not appName then return false end
    TriggerEvent('qb-phone:client:CloseApp', appName)
    return true
end

function Phone:getPhoneNumber()
    -- This would need framework integration
    local player = QBCore.Functions.GetPlayerData()
    return player?.charinfo?.phone or nil
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
Normalizer.capabilities.phone   = true

return Phone
