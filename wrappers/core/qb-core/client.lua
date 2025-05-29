--[[
  Mueve las funciones que se puedan de qb a ox_lib y usa el cache para datos mas normales como el citizenid y esas cosas
]]

-- Crear clase local, NO asignar a lib.core directamente
local Core = lib.class('Core')

-- Funciones locales privadas (mantener las mismas)
local QBCore = exports['qb-core']:GetCoreObject()

local function normalizePlayerData()
    -- Try to get from cache first
    if cache.playerData then
        return cache.playerData
    end

    -- Fallback to QBCore API
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData then return nil end

    local normalized = {
        -- Identificadores normalizados
        citizenid = playerData.citizenid,
        identifier = playerData.citizenid,
        name = playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname,

        -- Job normalizado
        job = {
            name = playerData.job and playerData.job.name,
            label = playerData.job and playerData.job.label,
            grade = playerData.job and playerData.job.grade.level,
            salary = playerData.job and playerData.job.payment,
            onduty = playerData.job and playerData.job.onduty
        },

        -- Gang normalizado (específico de QB)
        gang = {
            name = playerData.gang and playerData.gang.name,
            label = playerData.gang and playerData.gang.label,
            grade = playerData.gang and playerData.gang.grade.level
        },

        -- Money normalizado
        money = {
            cash = playerData.money and playerData.money.cash or 0,
            bank = playerData.money and playerData.money.bank or 0,
            crypto = playerData.money and playerData.money.crypto or 0
        },

        -- Acceso directo al objeto original
        _original = playerData
    }

    -- Cache the normalized data if events cache is available
    if lib.events and lib.events.cache and lib.events.cache.updatePlayer then
        lib.events.cache.updatePlayer(normalized)
    end

    return normalized
end

-- Constructor de la clase
function Core:constructor()
    self.framework = 'qb-core'
    self.frameworkObject = QBCore
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

function Core:getGang()
    -- Try cache first
    if cache.playerData and cache.playerData.gang then
        return cache.playerData.gang.name
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.gang.name
end

function Core:getGangGrade()
    -- Try cache first
    if cache.playerData and cache.playerData.gang then
        return cache.playerData.gang.grade
    end

    -- Fallback to full player data
    local playerData = self:getPlayerData()
    return playerData and playerData.gang.grade
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
    QBCore.Functions.Notify(message, type, duration)
end

function Core:drawText(text, position)
    QBCore.Functions.DrawText(text, position)
end

function Core:hideText()
    QBCore.Functions.HideText()
end

function Core:progressBar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
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
