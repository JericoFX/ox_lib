if GetResourceState('qb-banking') ~= 'started' then
    return {}
end

local Banking = lib.class('Banking')

function Banking:constructor()
    self.system = 'qb-banking'
end

function Banking:openBanking()
    TriggerEvent('qb-banking:openBankMenu')
end

function Banking:closeBanking()
    TriggerEvent('qb-banking:closeBankMenu')
end

function Banking:isBankingOpen()
    return exports['qb-banking']:isBankOpen()
end

return Banking
