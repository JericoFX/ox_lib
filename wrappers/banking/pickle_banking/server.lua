if GetResourceState('pickle_banking') ~= 'started' then
    return {}
end

local Normalizer = require 'wrappers.normalizer'
local pickleBanking = exports['pickle_banking']

local function addMoney(source, amount, account)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    pickleBanking:AddMoney(player.id, amount, account or 'checking')
    return true
end

local function removeMoney(source, amount, account)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    pickleBanking:RemoveMoney(player.id, amount, account or 'checking')
    return true
end

local function getMoney(source, account)
    local player = lib.core.getPlayer(source)
    if not player then return 0 end

    return pickleBanking:GetAccountBalance(player.id, account or 'checking')
end

local function transferMoney(fromSource, toSource, amount, fromAccount, toAccount)
    local fromPlayer = lib.core.getPlayer(fromSource)
    local toPlayer = lib.core.getPlayer(toSource)

    if not fromPlayer or not toPlayer then return false end

    local success = pickleBanking:RemoveMoney(fromPlayer.id, amount, fromAccount or 'checking')
    if success then
        pickleBanking:AddMoney(toPlayer.id, amount, toAccount or 'checking')
        return true
    end
    return false
end

local function createAccount(source, accountName, accountType)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    pickleBanking:CreateAccount(player.id, accountName, accountType or 'checking')
    return true
end

local function addTransaction(source, account, amount, reason, type)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    pickleBanking:AddTransaction(player.id, account or 'checking', amount, reason, type or 'deposit')
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
