if GetResourceState('pickle_banking') ~= 'started' then
    return {}
end

local Banking = lib.class('Banking')

function Banking:constructor()
    self.system = 'pickle_banking'
end

function Banking:openBanking()
    TriggerEvent('pickle_banking:openBank')
end

function Banking:closeBanking()
    TriggerEvent('pickle_banking:closeBank')
end

function Banking:isBankingOpen()
    return exports['pickle_banking']:isBankOpen()
end

return Banking
