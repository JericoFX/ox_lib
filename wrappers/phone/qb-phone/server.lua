--[[
    QB Phone Wrapper - Server Side
]]

if GetResourceState('qb-phone') ~= 'started' then
    return {}
end

-- local helpers -------------------------------------------------------------

local function sendMessage(source, number, message)
    TriggerClientEvent('qb-phone:client:CustomNotification', source, 'Messages', message, 'fas fa-comment', '#25D366', 5000)
end

local function addContact(source, name, number, avatar)
    TriggerClientEvent('qb-phone:client:AddNewContact', source, name, number, avatar)
end

local function removeContact(source, number)
    TriggerClientEvent('qb-phone:client:RemoveContact', source, number)
end

local function notification(source, title, text, icon, color, timeout)
    TriggerClientEvent('qb-phone:client:CustomNotification', source, title, text, icon or 'fas fa-info-circle', color or '#4299e1', timeout or 5000)
end

local function addMail(source, sender, subject, message)
    local mailData = {
        sender = sender,
        subject = subject,
        message = message,
        button = {}
    }
    TriggerClientEvent('qb-phone:client:NewMail', source, mailData)
end

local function addAdvertisement(source, sender, message)
    TriggerClientEvent('qb-phone:client:AddAdvert', source, sender, message)
end

local function bankNotification(source, title, message, amount)
    TriggerClientEvent('qb-phone:client:BankNotify', source, {
        title = title,
        message = message,
        amount = amount
    })
end

-- export table --------------------------------------------------------------

return {
    sendMessage      = sendMessage,
    addContact       = addContact,
    removeContact    = removeContact,
    notification     = notification,
    addMail          = addMail,
    addAdvertisement = addAdvertisement,
    bankNotification = bankNotification,
}
