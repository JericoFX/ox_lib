--[[
  Mueve las funciones que se puedan de qb a ox_lib y usa el cache para datos mas normales como el citizenid y esas cosas
]]

-- Crear clase local, NO asignar a lib.core directamente
local Core = lib.class('Core')

-- Funciones locales privadas (mantener las mismas)
local QBCore = exports['qb-core']:GetCoreObject()

local function normalizePlayerData()
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData then return nil end

    return {
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
end

-- Constructor de la clase
function Core:constructor()
    self.framework = 'qb-core'
    self.frameworkObject = QBCore
end

-- Métodos de la clase (misma funcionalidad, sintaxis de clase)
function Core:getPlayerData()
    return normalizePlayerData()
end

function Core:getJob()
    local playerData = normalizePlayerData()
    return playerData and playerData.job.name
end

function Core:getJobGrade()
    local playerData = normalizePlayerData()
    return playerData and playerData.job.grade
end

function Core:getJobLabel()
    local playerData = normalizePlayerData()
    return playerData and playerData.job.label
end

function Core:getGang()
    local playerData = normalizePlayerData()
    return playerData and playerData.gang.name
end

function Core:getGangGrade()
    local playerData = normalizePlayerData()
    return playerData and playerData.gang.grade
end

function Core:getMoney(account)
    local playerData = normalizePlayerData()
    if not playerData then return 0 end

    account = account or 'cash'
    return playerData.money[account] or 0
end

function Core:getIdentifier()
    local playerData = normalizePlayerData()
    return playerData and playerData.citizenid
end

function Core:isPlayerLoaded()
    local playerData = normalizePlayerData()
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

-- Retornar la clase para que shared.lua la asigne a lib.core
return Core
