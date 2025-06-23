if GetResourceState('Renewed-Banking') ~= 'started' then
    return {}
end

local Normalizer = require 'wrappers.normalizer'
local renewedBanking = exports['Renewed-Banking']

local function addMoney(source, amount, account)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    renewedBanking:addAccountMoney(player.id, account or 'checking', amount)
    return true
end

local function removeMoney(source, amount, account)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    renewedBanking:removeAccountMoney(player.id, account or 'checking', amount)
    return true
end

local function getMoney(source, account)
    local player = lib.core.getPlayer(source)
    if not player then return 0 end

    return renewedBanking:getAccountMoney(player.id, account or 'checking')
end

local function transferMoney(fromSource, toSource, amount, fromAccount, toAccount)
    local fromPlayer = lib.core.getPlayer(fromSource)
    local toPlayer = lib.core.getPlayer(toSource)

    if not fromPlayer or not toPlayer then return false end

    local success = renewedBanking:removeAccountMoney(fromPlayer.id, fromAccount or 'checking', amount)
    if success then
        renewedBanking:addAccountMoney(toPlayer.id, toAccount or 'checking', amount)
        return true
    end
    return false
end

local function createAccount(source, accountName, accountType)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    renewedBanking:createAccount(player.id, accountName, accountType or 'checking')
    return true
end

local function addTransaction(source, account, amount, reason, type)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    renewedBanking:addTransaction(player.id, account or 'checking', amount, reason, type or 'deposit')
    return true
end

-- Register implementation in Normalizer
Normalizer.banking.addMoney       = addMoney
Normalizer.banking.removeMoney    = removeMoney
Normalizer.banking.getMoney       = getMoney
Normalizer.banking.transferMoney  = transferMoney
Normalizer.banking.createAccount  = createAccount
Normalizer.banking.addTransaction = addTransaction
Normalizer.capabilities.banking   = true

return {
    addMoney       = addMoney,
    removeMoney    = removeMoney,
    getMoney       = getMoney,
    transferMoney  = transferMoney,
    createAccount  = createAccount,
    addTransaction = addTransaction,
}
