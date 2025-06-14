--[[
    QBCore Framework Server Functions
]]

if GetResourceState('qb-core') ~= 'started' then
    return
end

local QBCore = exports['qb-core']:GetCoreObject()


local playerCache = {}
local frameCache = {}
local lastFrame = 0
local CACHE_TTL = 150

local function cleanupDisconnectedPlayers()
    local activePlayers = {}
    for _, playerId in ipairs(GetPlayers()) do
        activePlayers[tonumber(playerId)] = true
    end
    
    for source in pairs(playerCache) do
        if not activePlayers[source] then
            playerCache[source] = nil
        end
    end
end

local function getCachedQBPlayer(source)
    local currentFrame = GetGameTimer()
    
    if currentFrame ~= lastFrame then
        frameCache = {}
        lastFrame = currentFrame
        
        if math.random(1, 100) == 1 then
            cleanupDisconnectedPlayers()
        end
    end
    
    if frameCache[source] then
        return frameCache[source]
    end
    
    local cached = playerCache[source]
    if cached and (currentFrame - cached.timestamp) < CACHE_TTL then
        frameCache[source] = cached.player
        return cached.player
    end
    
    local qbPlayer = QBCore.Functions.GetPlayer(source)
    
    playerCache[source] = {
        player = qbPlayer,
        timestamp = currentFrame
    }
    frameCache[source] = qbPlayer
    
    return qbPlayer
end

local function invalidatePlayerCache(source)
    if playerCache[source] then
        playerCache[source] = nil
    end
    if frameCache[source] then
        frameCache[source] = nil
    end
end

AddEventHandler('playerDropped', function()
    local source = source
    invalidatePlayerCache(source)
end)

RegisterNetEvent('qb-core:server:moneyChange', function()
    invalidatePlayerCache(source)
end)

RegisterNetEvent('qb-core:server:jobUpdate', function()
    invalidatePlayerCache(source)
end)

RegisterNetEvent('qb-core:server:gangUpdate', function()
    invalidatePlayerCache(source)
end)

local function normalizePlayer(qbPlayer)
    if not qbPlayer then return nil end

    return {
        -- Identificadores normalizados
        source = qbPlayer.PlayerData.source,
        citizenid = qbPlayer.PlayerData.citizenid,
        identifier = qbPlayer.PlayerData.citizenid,
        name = qbPlayer.PlayerData.charinfo.firstname .. ' ' .. qbPlayer.PlayerData.charinfo.lastname,

        -- Job normalizado
        job = {
            name = qbPlayer.PlayerData.job.name,
            label = qbPlayer.PlayerData.job.label,
            grade = qbPlayer.PlayerData.job.grade.level,
            salary = qbPlayer.PlayerData.job.payment,
            onduty = qbPlayer.PlayerData.job.onduty
        },

        -- Gang normalizado (específico de QB)
        gang = {
            name = qbPlayer.PlayerData.gang.name,
            label = qbPlayer.PlayerData.gang.label,
            grade = qbPlayer.PlayerData.gang.grade.level
        },

        -- Money normalizado
        money = {
            cash = qbPlayer.PlayerData.money.cash or 0,
            bank = qbPlayer.PlayerData.money.bank or 0,
            crypto = qbPlayer.PlayerData.money.crypto or 0
        },

        -- Funciones normalizadas
        Functions = {
            AddMoney = function(moneytype, amount)
                qbPlayer.Functions.AddMoney(moneytype, amount)
            end,
            RemoveMoney = function(moneytype, amount)
                qbPlayer.Functions.RemoveMoney(moneytype, amount)
            end,
            SetJob = function(job, grade)
                qbPlayer.Functions.SetJob(job, grade or 0)
            end,
            GetMoney = function(moneytype)
                return qbPlayer.PlayerData.money[moneytype] or 0
            end
        },

        -- Acceso directo al objeto original
        _original = qbPlayer
    }
end

local coreWrapper = {
    getPlayer = function(source)
        local qbPlayer = getCachedQBPlayer(source)
        return normalizePlayer(qbPlayer)
    end,

    getPlayerByIdentifier = function(identifier)
        local qbPlayer = QBCore.Functions.GetPlayerByCitizenId(identifier)
        return normalizePlayer(qbPlayer)
    end,

    getAllPlayers = function()
        local players = {}
        local qbPlayers = QBCore.Functions.GetQBPlayers()

        for _, qbPlayer in pairs(qbPlayers) do
            players[#players + 1] = normalizePlayer(qbPlayer)
        end

        return players
    end,

    addMoney = function(source, money, account)
        local player = getCachedQBPlayer(source)
        if not player then return false end

        account = account or 'cash'
        player.Functions.AddMoney(account, money)
        invalidatePlayerCache(source)
        return true
    end,

    removeMoney = function(source, money, account)
        local player = getCachedQBPlayer(source)
        if not player then return false end

        account = account or 'cash'
        player.Functions.RemoveMoney(account, money)
        invalidatePlayerCache(source)
        return true
    end,

    getMoney = function(source, account)
        local player = getCachedQBPlayer(source)
        if not player then return 0 end

        account = account or 'cash'
        return player.PlayerData.money[account] or 0
    end,

    getJob = function(source)
        local player = getCachedQBPlayer(source)
        if not player then return nil end

        return player.PlayerData.job.name
    end,

    getJobGrade = function(source)
        local player = getCachedQBPlayer(source)
        if not player then return nil end

        return player.PlayerData.job.grade.level
    end,

    setJob = function(source, job, grade)
        local player = getCachedQBPlayer(source)
        if not player then return false end

        player.Functions.SetJob(job, grade or 0)
        invalidatePlayerCache(source)
        return true
    end,

    getGang = function(source)
        local player = getCachedQBPlayer(source)
        if not player then return nil end

        return player.PlayerData.gang.name
    end,

    setGang = function(source, gang, grade)
        local player = getCachedQBPlayer(source)
        if not player then return false end

        player.Functions.SetGang(gang, grade or 0)
        invalidatePlayerCache(source)
        return true
    end
}

return coreWrapper
