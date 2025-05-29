--[[
    QB Phone Functions
]]

return {
    sendMessage = function(source, number, message)
        if lib.context == 'server' then
            TriggerClientEvent('qb-phone:client:CustomNotification', source, 'Messages', message, 'fas fa-comment', '#25D366', 5000)
        else
            TriggerEvent('qb-phone:client:CustomNotification', 'Messages', message, 'fas fa-comment', '#25D366', 5000)
        end
    end,

    addContact = function(source, name, number, avatar)
        if lib.context == 'server' then
            TriggerClientEvent('qb-phone:client:AddNewContact', source, name, number, avatar)
        else
            TriggerEvent('qb-phone:client:AddNewContact', name, number, avatar)
        end
    end,

    removeContact = function(source, number)
        if lib.context == 'server' then
            TriggerClientEvent('qb-phone:client:RemoveContact', source, number)
        else
            TriggerEvent('qb-phone:client:RemoveContact', number)
        end
    end,

    notification = function(source, title, text, icon, color, timeout)
        if lib.context == 'server' then
            TriggerClientEvent('qb-phone:client:CustomNotification', source, title, text, icon, color, timeout)
        else
            TriggerEvent('qb-phone:client:CustomNotification', title, text, icon, color, timeout)
        end
    end,

    addMail = function(source, sender, subject, message)
        if lib.context == 'server' then
            local mailData = {
                sender = sender,
                subject = subject,
                message = message,
                button = {}
            }
            TriggerClientEvent('qb-phone:client:NewMail', source, mailData)
        end
    end,

    addAdvertisement = function(source, sender, message)
        if lib.context == 'server' then
            TriggerClientEvent('qb-phone:client:AddAdvert', source, sender, message)
        end
    end,

    bankNotification = function(source, title, message, amount)
        if lib.context == 'server' then
            TriggerClientEvent('qb-phone:client:BankNotify', source, {
                title = title,
                message = message,
                amount = amount
            })
        end
    end,

    openPhone = function()
        if lib.context == 'client' then
            TriggerEvent('qb-phone:client:openPhone')
        end
    end,

    closePhone = function()
        if lib.context == 'client' then
            TriggerEvent('qb-phone:client:closePhone')
        end
    end,

    isPhoneOpen = function()
        if lib.context == 'client' then
            return exports['qb-phone']:isPhoneOpen()
        end
        return false
    end
}
