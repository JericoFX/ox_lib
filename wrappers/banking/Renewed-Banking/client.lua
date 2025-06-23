if GetResourceState('Renewed-Banking') ~= 'started' then
    return {}
end

local Banking = lib.class('Banking')

function Banking:constructor()
    self.system = 'Renewed-Banking'
end

function Banking:openBanking()
    TriggerEvent('Renewed-Banking:client:openBank')
end

function Banking:closeBanking()
    TriggerEvent('Renewed-Banking:client:closeBank')
end

function Banking:isBankingOpen()
    return exports['Renewed-Banking']:IsBankOpen()
end

return Banking
