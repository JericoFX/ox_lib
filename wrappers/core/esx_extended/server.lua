--[[
    ESX Framework Server Functions
]]

local ESX = exports['es_extended']:getSharedObject()

local function normalizePlayer(esxPlayer)
    if not esxPlayer then return nil end

    return {
        -- Identificadores normalizados
        source = esxPlayer.source,
        citizenid = esxPlayer.identifier,
        identifier = esxPlayer.identifier,
        name = esxPlayer.getName(),

        -- Job normalizado
        job = {
            name = esxPlayer.job.name,
            label = esxPlayer.job.label,
            grade = esxPlayer.job.grade,
            salary = esxPlayer.job.grade_salary,
            onduty = true -- ESX no maneja duty por defecto
        },

        -- Money normalizado
        money = {
            cash = esxPlayer.getMoney(),
            bank = esxPlayer.getAccount('bank').money,
            black_money = esxPlayer.getAccount('black_money').money
        },

        -- Funciones normalizadas
        Functions = {
            AddMoney = function(moneytype, amount)
                if moneytype == 'cash' then moneytype = 'money' end
                if moneytype == 'bank' then
                    esxPlayer.addAccountMoney('bank', amount)
                else
                    esxPlayer.addMoney(amount)
                end
            end,
            RemoveMoney = function(moneytype, amount)
                if moneytype == 'cash' then moneytype = 'money' end
                if moneytype == 'bank' then
                    esxPlayer.removeAccountMoney('bank', amount)
                else
                    esxPlayer.removeMoney(amount)
                end
            end,
            SetJob = function(job, grade)
                esxPlayer.setJob(job, grade or 0)
            end,
            GetMoney = function(moneytype)
                if moneytype == 'cash' then return esxPlayer.getMoney() end
                if moneytype == 'bank' then return esxPlayer.getAccount('bank').money end
                return esxPlayer.getMoney()
            end
        },

        -- Acceso directo al objeto original
        _original = esxPlayer
    }
end

return {
    getPlayer = function(source)
        local esxPlayer = ESX.GetPlayerFromId(source)
        return normalizePlayer(esxPlayer)
    end,

    getPlayerByIdentifier = function(identifier)
        local esxPlayer = ESX.GetPlayerFromIdentifier(identifier)
        return normalizePlayer(esxPlayer)
    end,

    getAllPlayers = function()
        local players = {}
        local esxPlayers = ESX.GetExtendedPlayers()

        for i = 1, #esxPlayers do
            players[#players + 1] = normalizePlayer(esxPlayers[i])
        end

        return players
    end,

    addMoney = function(source, money, account)
        local player = ESX.GetPlayerFromId(source)
        if not player then return false end

        account = account or 'cash'
        if account == 'cash' then
            player.addMoney(money)
        elseif account == 'bank' then
            player.addAccountMoney('bank', money)
        else
            player.addAccountMoney(account, money)
        end
        return true
    end,

    removeMoney = function(source, money, account)
        local player = ESX.GetPlayerFromId(source)
        if not player then return false end

        account = account or 'cash'
        if account == 'cash' then
            player.removeMoney(money)
        elseif account == 'bank' then
            player.removeAccountMoney('bank', money)
        else
            player.removeAccountMoney(account, money)
        end
        return true
    end,

    getMoney = function(source, account)
        local player = ESX.GetPlayerFromId(source)
        if not player then return 0 end

        account = account or 'cash'
        if account == 'cash' then
            return player.getMoney()
        elseif account == 'bank' then
            return player.getAccount('bank').money
        else
            return player.getAccount(account).money
        end
    end,

    getJob = function(source)
        local player = ESX.GetPlayerFromId(source)
        if not player then return nil end

        return player.job.name
    end,

    getJobGrade = function(source)
        local player = ESX.GetPlayerFromId(source)
        if not player then return nil end

        return player.job.grade
    end,

    setJob = function(source, job, grade)
        local player = ESX.GetPlayerFromId(source)
        if not player then return false end

        player.setJob(job, grade or 0)
        return true
    end
}
