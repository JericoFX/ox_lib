if GetResourceState('esx_atm') ~= 'started' then
    return {}
end

local Normalizer = require 'wrappers.normalizer'

local function addMoney(source, amount, account)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    lib.core.walletAdd(source, amount, 'bank')
    return true
end

local function removeMoney(source, amount, account)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    lib.core.walletRemove(source, amount, 'bank')
    return true
end

local function getMoney(source, account)
    local player = lib.core.getPlayer(source)
    if not player then return 0 end

    return lib.core.wallet(source, 'bank')
end

local function transferMoney(fromSource, toSource, amount, fromAccount, toAccount)
    local fromPlayer = lib.core.getPlayer(fromSource)
    local toPlayer = lib.core.getPlayer(toSource)

    if not fromPlayer or not toPlayer then return false end

    local success = lib.core.walletRemove(fromSource, amount, 'bank')
    if success then
        lib.core.walletAdd(toSource, amount, 'bank')
        return true
    end
    return false
end

local function createAccount(source, accountName, accountType)
    return true
end

local function addTransaction(source, account, amount, reason, type)
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
