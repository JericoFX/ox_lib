--[[
    ESX Framework Server Functions
]]

if GetResourceState('es_extended') ~= 'started' then
    return
end

local ESX = exports['es_extended']:getSharedObject()

-- Caching tables
local playerCache = {}
local normalizedCache = {}
local frameCache = {}
local lastFrame = 0

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

-- Returns ESX player object with per-frame micro-cache and long cache cleared on invalidation
local function getCachedESXPlayer(source)
    local currentFrame = GetFrameCount()
    if currentFrame ~= lastFrame then
        frameCache = {}
        lastFrame = currentFrame
    end

    if frameCache[source] then
        return frameCache[source]
    end

    if playerCache[source] then
        frameCache[source] = playerCache[source]
        return playerCache[source]
    end

    local esxPlayer = ESX.GetPlayerFromId(source)
    playerCache[source] = esxPlayer
    frameCache[source] = esxPlayer
    return esxPlayer
end

-- Returns normalized player with caching
local function getNormalizedPlayer(source)
    if normalizedCache[source] then
        -- quick return if cached
        return normalizedCache[source]
    end

    local esxPlayer = getCachedESXPlayer(source)
    local normalized = normalizePlayer(esxPlayer)
    normalizedCache[source] = normalized
    return normalized
end

-- Adjust invalidate function to also clear normalized cache
local function invalidatePlayerCache(source)
    playerCache[source] = nil
    normalizedCache[source] = nil
    frameCache[source] = nil
end

-- Invalidate when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    invalidatePlayerCache(src)
end)

local coreWrapper = {
    -- Unified API
    player = function(source)
        return getNormalizedPlayer(source)
    end,
    playerByIdentifier = function(identifier)
        -- Identifier lookups are infrequent; no cache needed
        local esxPlayer = ESX.GetPlayerFromIdentifier(identifier)
        return normalizePlayer(esxPlayer)
    end,
    players = function()
        local list = {}
        local esxPlayers = ESX.GetExtendedPlayers()
        for i = 1, #esxPlayers do
            local src = esxPlayers[i].source
            list[#list + 1] = getNormalizedPlayer(src)
        end
        return list
    end,
    walletAdd = function(source, amount, account)
        local player = getCachedESXPlayer(source)
        if not player then return false end
        account = account or 'cash'
        if account == 'cash' then
            player.addMoney(amount)
        elseif account == 'bank' then
            player.addAccountMoney('bank', amount)
        else
            player.addAccountMoney(account, amount)
        end
        invalidatePlayerCache(source)
        return true
    end,
    walletRemove = function(source, amount, account)
        local player = getCachedESXPlayer(source)
        if not player then return false end
        account = account or 'cash'
        if account == 'cash' then
            player.removeMoney(amount)
        elseif account == 'bank' then
            player.removeAccountMoney('bank', amount)
        else
            player.removeAccountMoney(account, amount)
        end
        invalidatePlayerCache(source)
        return true
    end,
    wallet = function(source, account)
        local player = getCachedESXPlayer(source)
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
    role = function(source)
        local player = getCachedESXPlayer(source)
        if not player then return nil end
        return player.job.name
    end,
    roleGrade = function(source)
        local player = getCachedESXPlayer(source)
        if not player then return nil end
        return player.job.grade
    end,
    roleSet = function(source, job, grade)
        local player = getCachedESXPlayer(source)
        if not player then return false end
        player.setJob(job, grade or 0)
        invalidatePlayerCache(source)
        return true
    end
}

return coreWrapper
