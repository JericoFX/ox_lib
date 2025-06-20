local Phone = lib.class('phone')

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

return Phone

