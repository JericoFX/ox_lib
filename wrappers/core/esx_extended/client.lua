--[[
    ESX pasarlo a clase y lo mismo que el qb
]]

-- Crear clase local, NO asignar a lib.core directamente
local Core = lib.class('Core')

local ESX = exports['es_extended']:getSharedObject()

local function normalizePlayerData()
    -- Try to get from cache first
    if cache.playerData then
        return cache.playerData
    end

    -- Fallback to ESX API
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

    -- Cache the normalized data if events cache is available
    if lib.events and lib.events.cache and lib.events.cache.updatePlayer then
        lib.events.cache.updatePlayer(normalizedData)
    end

    return normalizedData
end

-- Constructor de la clase
function Core:constructor()
    self.framework = 'esx'
    self.frameworkObject = ESX
end

-- Métodos de la clase optimizados con cache directo
function Core:getPlayerData()
    -- Try cache first, fallback to API
    if cache.playerData then
        return cache.playerData
    end

    return normalizePlayerData()
end

function Core:getJob()
    -- Try cache first
    if cache.job then
        return cache.job.name
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.job.name
end

function Core:getJobGrade()
    -- Try cache first
    if cache.job then
        return cache.job.grade
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.job.grade
end

function Core:getJobLabel()
    -- Try cache first
    if cache.job then
        return cache.job.label
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.job.label
end

function Core:getMoney(account)
    account = account or 'cash'

    -- Try cache first
    if cache.money then
        return cache.money[account] or 0
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    if not playerData then return 0 end

    return playerData.money[account] or 0
end

function Core:getIdentifier()
    -- Try cache first
    if cache.citizenid then
        return cache.citizenid
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.citizenid
end

function Core:isPlayerLoaded()
    -- Try cache first
    if cache.citizenid then
        return true
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.citizenid ~= nil
end

function Core:showNotification(message, type, duration)
    ESX.ShowNotification(message, type, duration)
end

function Core:showAdvancedNotification(title, subject, msg, icon, iconType)
    ESX.ShowAdvancedNotification(title, subject, msg, icon, iconType)
end

-- Método adicional para debugging
function Core:getFramework()
    return self.framework
end

-- Método para invalidar cache manualmente
function Core:invalidateCache()
    if lib.events and lib.events.cache and lib.events.cache.clear then
        lib.events.cache.clear()
    end
end

-- Retornar la clase para que shared.lua la asigne a lib.core
return Core
