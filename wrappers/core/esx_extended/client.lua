--[[
    ESX pasarlo a clase y lo mismo que el qb
]]

local ESX = exports['es_extended']:getSharedObject()

local function normalizePlayerData()
    local playerData = ESX.GetPlayerData()
    if not playerData then return nil end

    local normalizedData = {
        -- Identificadores normalizados
        citizenid = playerData.identifier,
        identifier = playerData.identifier,
        name = playerData.name,

        -- Job normalizado
        job = {
            name = playerData.job and playerData.job.name,
            label = playerData.job and playerData.job.label,
            grade = playerData.job and playerData.job.grade,
            salary = playerData.job and playerData.job.grade_salary,
            onduty = true -- ESX no maneja duty por defecto
        },

        -- Money normalizado
        money = {
            cash = 0,
            bank = 0,
            black_money = 0
        },

        -- Acceso directo al objeto original
        _original = playerData
    }

    -- Normalizar accounts a money
    if playerData.accounts then
        for i = 1, #playerData.accounts do
            local account = playerData.accounts[i]
            if account.name == 'money' then
                normalizedData.money.cash = account.money
            elseif account.name == 'bank' then
                normalizedData.money.bank = account.money
            elseif account.name == 'black_money' then
                normalizedData.money.black_money = account.money
            end
        end
    end

    return normalizedData
end

return {
    getPlayerData = function()
        return normalizePlayerData()
    end,

    getJob = function()
        local playerData = normalizePlayerData()
        return playerData and playerData.job.name
    end,

    getJobGrade = function()
        local playerData = normalizePlayerData()
        return playerData and playerData.job.grade
    end,

    getJobLabel = function()
        local playerData = normalizePlayerData()
        return playerData and playerData.job.label
    end,

    getMoney = function(account)
        local playerData = normalizePlayerData()
        if not playerData then return 0 end

        account = account or 'cash'
        return playerData.money[account] or 0
    end,

    getIdentifier = function()
        local playerData = normalizePlayerData()
        return playerData and playerData.citizenid
    end,

    isPlayerLoaded = function()
        local playerData = normalizePlayerData()
        return playerData and playerData.citizenid ~= nil
    end,

    showNotification = function(message, type, duration)
        ESX.ShowNotification(message, type, duration)
    end,

    showAdvancedNotification = function(title, subject, msg, icon, iconType)
        ESX.ShowAdvancedNotification(title, subject, msg, icon, iconType)
    end
}
