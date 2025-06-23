if GetResourceState('okokBanking') ~= 'started' then
    return {}
end

local Normalizer = require 'wrappers.normalizer'
local okokBanking = exports['okokBanking']

local function addMoney(source, amount, account)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    okokBanking:AddMoney(player.id, amount)
    return true
end

local function removeMoney(source, amount, account)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    okokBanking:RemoveMoney(player.id, amount)
    return true
end

local function getMoney(source, account)
    local player = lib.core.getPlayer(source)
    if not player then return 0 end

    return okokBanking:GetAccount(player.id)
end

local function transferMoney(fromSource, toSource, amount)
    local fromPlayer = lib.core.getPlayer(fromSource)
    local toPlayer = lib.core.getPlayer(toSource)

    if not fromPlayer or not toPlayer then return false end

    local success = okokBanking:RemoveMoney(fromPlayer.id, amount)
    if success then
        okokBanking:AddMoney(toPlayer.id, amount)
        return true
    end
    return false
end

local function createAccount(source, accountName, accountType)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    okokBanking:CreateAccount(player.id, accountName, accountType)
    return true
end

local function addTransaction(source, account, amount, reason, type)
    local player = lib.core.getPlayer(source)
    if not player then return false end

    okokBanking:AddTransaction(player.id, amount, reason, type)
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
