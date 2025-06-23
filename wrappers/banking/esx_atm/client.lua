if GetResourceState('esx_atm') ~= 'started' then
    return {}
end

local Banking = lib.class('Banking')

function Banking:constructor()
    self.system = 'esx_atm'
end

function Banking:openBanking()
    TriggerEvent('esx_atm:openATM')
end

function Banking:closeBanking()
    TriggerEvent('esx_atm:closeATM')
end

function Banking:isBankingOpen()
    return exports['esx_atm']:isATMOpen()
end

return Banking
