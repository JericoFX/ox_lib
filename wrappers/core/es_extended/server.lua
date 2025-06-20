--[[
    ESX Server Wrapper – clean rewrite
]]

if GetResourceState('es_extended') ~= 'started' then
    return
end

local ESX       = exports['es_extended']:getSharedObject()
local normalize = require 'wrappers.core.normalizer'

-- Mapping for shared normalizer ---------------------------------------------
local map       = {
    id       = 'identifier',
    name     = 'name',

    job      = function(pd)
        return {
            name   = pd.job and pd.job.name or 'unemployed',
            label  = pd.job and pd.job.label or 'Unemployed',
            grade  = pd.job and pd.job.grade or 0,
            salary = pd.job and pd.job.grade_salary or 0,
            onduty = true
        }
    end,

    money    = function(pd)
        local m = { cash = 0, bank = 0, black_money = 0 }
        if pd.accounts then
            for _, acc in ipairs(pd.accounts) do
                if acc.name == 'money' then
                    m.cash = acc.money
                elseif acc.name == 'bank' then
                    m.bank = acc.money
                elseif acc.name == 'black_money' then
                    m.black_money = acc.money
                end
            end
        end
        return m
    end,

    metadata = 'metadata'
}

-- Internal caches ------------------------------------------------------------
local esxCache  = {} ---@type table<number,{player:any,time:number}>
local normCache = {} ---@type table<number,table|nil>
local CACHE_TTL = 1000 -- ms

local function now() return GetGameTimer() end

local function invalidate(src)
    esxCache[src]  = nil
    normCache[src] = nil
end

AddEventHandler('playerDropped', function() invalidate(source) end)
RegisterNetEvent('esx:setAccountMoney', function() invalidate(source) end)
RegisterNetEvent('esx:setJob', function() invalidate(source) end)

-- Helpers --------------------------------------------------------------------
local Core = {}

local function getESX(src)
    local entry = esxCache[src]
    local t = now()
    if entry and (t - entry.time) < CACHE_TTL then return entry.player end

    local player = ESX.GetPlayerFromId(src)
    if player then esxCache[src] = { player = player, time = t } end
    return player
end

local function getNormalised(src)
    if normCache[src] ~= nil then return normCache[src] end

    local esx = getESX(src)
    local data = esx and {
        identifier = esx.identifier,
        name       = esx.getName(),
        job        = esx.job,
        accounts   = esx.accounts,
        metadata   = esx.getMeta and esx:getMeta() or {},
    }
    local norm = normalize(data, map)
    normCache[src] = norm
    return norm
end

-- Class ----------------------------------------------------------------------

-- Money ----------------------------------------------------------------------
function Core:wallet(account)
    account = account or 'cash'
    local esx = getESX(self.source)
    if not esx then return 0 end
    if account == 'cash' then return esx.getMoney() end
    local acc = esx.getAccount(account)
    return acc and acc.money or 0
end

function Core:walletAdd(amount, account)
    local esx = getESX(self.source)
    if not esx then return false end
    account = account or 'cash'
    if account == 'cash' then
        esx.addMoney(amount)
    else
        esx.addAccountMoney(account, amount)
    end
    invalidate(self.source)
    return true
end

function Core:walletRemove(amount, account)
    local esx = getESX(self.source)
    if not esx then return false end
    account = account or 'cash'
    if account == 'cash' then
        esx.removeMoney(amount)
    else
        esx.removeAccountMoney(account, amount)
    end
    invalidate(self.source)
    return true
end

-- Job / Role -----------------------------------------------------------------
function Core:role()
    local esx = getESX(self.source); return esx and esx.job.name
end

function Core:roleLabel()
    local esx = getESX(self.source); return esx and esx.job.label
end

function Core:roleGrade()
    local esx = getESX(self.source); return esx and esx.job.grade
end

function Core:roleSet(job, grade)
    local esx = getESX(self.source)
    if not esx then return false end
    esx.setJob(job, grade or 0)
    invalidate(self.source)
    return true
end

-- Static helpers -------------------------------------------------------------
function Core.of(src) return Core(src) end

function Core.players()
    local list = {}
    local players = ESX.GetExtendedPlayers()
    for i = 1, #players do
        list[#list + 1] = Core(players[i].source)
    end
    return list
end

-- NEW IMPLEMENTATION: Replace class-based export with simple table functions
local core = {}
core.framework = 'esx'

-- Public API -----------------------------------------------------------------

-- Returns a normalised player table for the given source.
function core.getPlayer(src)
    return getNormalised(src)
end

-- Money helpers --------------------------------------------------------------
function core.wallet(src, account)
    account = account or 'cash'
    local esx = getESX(src)
    if not esx then return 0 end
    if account == 'cash' then return esx.getMoney() end
    local acc = esx.getAccount(account)
    return acc and acc.money or 0
end

function core.walletAdd(src, amount, account)
    local esx = getESX(src)
    if not esx then return false end
    account = account or 'cash'
    if account == 'cash' then
        esx.addMoney(amount)
    else
        esx.addAccountMoney(account, amount)
    end
    invalidate(src)
    return true
end

function core.walletRemove(src, amount, account)
    local esx = getESX(src)
    if not esx then return false end
    account = account or 'cash'
    if account == 'cash' then
        esx.removeMoney(amount)
    else
        esx.removeAccountMoney(account, amount)
    end
    invalidate(src)
    return true
end

-- Job / Role helpers ---------------------------------------------------------
function core.role(src)
    local esx = getESX(src)
    return esx and esx.job and esx.job.name or 'unemployed'
end

function core.roleLabel(src)
    local esx = getESX(src)
    return esx and esx.job and esx.job.label or 'Unemployed'
end

function core.roleGrade(src)
    local esx = getESX(src)
    return esx and esx.job and esx.job.grade or 0
end

function core.roleSet(src, job, grade)
    local esx = getESX(src)
    if not esx then return false end
    esx.setJob(job, grade or 0)
    invalidate(src)
    return true
end

-- Utility --------------------------------------------------------------------
function core.players()
    local list = {}
    local players = ESX.GetExtendedPlayers and ESX.GetExtendedPlayers() or {}
    for i = 1, #players do
        list[#list + 1] = getNormalised(players[i].source)
    end
    return list
end

return core
