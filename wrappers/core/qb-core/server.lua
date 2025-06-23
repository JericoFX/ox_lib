--[[
    QBCore Server Wrapper (clean rewrite)
    Provides a consistent, table-based API following server wrapper standards.
]]

if GetResourceState('qb-core') ~= 'started' then
    return
end

local QBCore    = exports['qb-core']:GetCoreObject()
local normalize = require 'wrappers.normalizer'

-- Framework-specific mapping for the shared normalizer ------------------------
local map       = {
    id       = 'citizenid',
    name     = function(pd)
        return pd.charinfo and (pd.charinfo.firstname .. ' ' .. pd.charinfo.lastname) or 'Unknown'
    end,
    job      = function(pd)
        return {
            name   = pd.job and pd.job.name or 'unemployed',
            label  = pd.job and pd.job.label or 'Unemployed',
            grade  = pd.job and pd.job.grade and pd.job.grade.level or 0,
            salary = pd.job and pd.job.payment or 0,
            onduty = pd.job and pd.job.onduty or false
        }
    end,
    gang     = function(pd)
        return {
            name  = pd.gang and pd.gang.name or 'none',
            label = pd.gang and pd.gang.label or 'None',
            grade = pd.gang and pd.gang.grade and pd.gang.grade.level or 0
        }
    end,
    money    = function(pd) return pd.money or { cash = 0, bank = 0, crypto = 0 } end,
    charinfo = function(pd) return pd.charinfo or {} end,
    metadata = 'metadata'
}

-- Caches ----------------------------------------------------------------------
local qbCache   = {} ---@type table<number,{player:any,time:number}>
local normCache = {} ---@type table<number,table|nil>
local CACHE_TTL = 1000 -- milliseconds

local function now() return GetGameTimer() end

local function invalidate(src)
    qbCache[src]   = nil
    normCache[src] = nil
end

-- Invalidate on relevant framework events
AddEventHandler('playerDropped', function() invalidate(source) end)
RegisterNetEvent('qb-core:server:moneyChange', function() invalidate(source) end)
RegisterNetEvent('qb-core:server:jobUpdate', function() invalidate(source) end)
RegisterNetEvent('qb-core:server:gangUpdate', function() invalidate(source) end)

-- Low-level helpers -----------------------------------------------------------
local function getQB(src)
    local entry = qbCache[src]
    local t = now()
    if entry and (t - entry.time) < CACHE_TTL then
        return entry.player
    end

    local player = QBCore.Functions.GetPlayer(src)
    if player then qbCache[src] = { player = player, time = t } end
    return player
end

local function getNormalised(src)
    local cached = normCache[src]
    if cached ~= nil then return cached end -- may be nil (player hasn't loaded)

    local pData = getQB(src)
    local normalised = normalize(pData and pData.PlayerData, map)
    normCache[src] = normalised
    return normalised
end

-- Table-based implementation -------------------------------------------------
local core = {}
core.framework = 'qb-core'

-- Returns a normalised player table for the given source
function core.getPlayer(src)
    return getNormalised(src)
end

-- Money helpers
function core.wallet(src, account)
    account = account or 'cash'
    local qb = getQB(src)
    return qb and qb.PlayerData.money[account] or 0
end

function core.walletAdd(src, amount, account)
    local qb = getQB(src)
    if not qb then return false end
    qb.Functions.AddMoney(account or 'cash', amount)
    invalidate(src)
    return true
end

function core.walletRemove(src, amount, account)
    local qb = getQB(src)
    if not qb then return false end
    qb.Functions.RemoveMoney(account or 'cash', amount)
    invalidate(src)
    return true
end

-- Job / Role helpers
function core.role(src)
    local qb = getQB(src)
    return qb and qb.PlayerData.job.name or 'unemployed'
end

function core.roleLabel(src)
    local qb = getQB(src)
    return qb and qb.PlayerData.job.label or 'Unemployed'
end

function core.roleGrade(src)
    local qb = getQB(src)
    return qb and qb.PlayerData.job.grade and qb.PlayerData.job.grade.level or 0
end

function core.roleSet(src, job, grade)
    local qb = getQB(src)
    if not qb then return false end
    qb.Functions.SetJob(job, grade or 0)
    invalidate(src)
    return true
end

-- Gang helpers
function core.guild(src)
    local qb = getQB(src)
    return qb and qb.PlayerData.gang.name or 'none'
end

function core.guildLabel(src)
    local qb = getQB(src)
    return qb and qb.PlayerData.gang.label or 'None'
end

function core.guildGrade(src)
    local qb = getQB(src)
    return qb and qb.PlayerData.gang.grade and qb.PlayerData.gang.grade.level or 0
end

function core.guildSet(src, gang, grade)
    local qb = getQB(src)
    if not qb then return false end
    qb.Functions.SetGang(gang, grade or 0)
    invalidate(src)
    return true
end

-- Utility
function core.players()
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        list[#list + 1] = getNormalised(tonumber(id))
    end
    return list
end

return core
