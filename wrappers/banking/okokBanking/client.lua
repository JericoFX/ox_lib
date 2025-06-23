if GetResourceState('okokBanking') ~= 'started' then
    return {}
end

local Banking = lib.class('Banking')

function Banking:constructor()
    self.system = 'okokBanking'
end

function Banking:openBanking()
    TriggerEvent('okokBanking:openBankMenu')
end

function Banking:closeBanking()
    TriggerEvent('okokBanking:closeBankMenu')
end

function Banking:isBankingOpen()
    return exports['okokBanking']:isBankOpen()
end

return Banking
