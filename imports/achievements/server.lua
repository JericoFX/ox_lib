local jsonDefsLoaded = false

local function opFunc(op)
    if op == '>' then
        return function(a, b) return a > b end
    elseif op == '>=' then
        return function(a, b) return a >= b end
    elseif op == '==' then
        return function(a, b) return a == b end
    elseif op == '<=' then
        return function(a, b) return a <= b end
    elseif op == '<' then
        return function(a, b) return a < b end
    else
        return function() return false end
    end
end

local function compileCondition(cond)
    if cond.counter then
        local var = cond.counter.var
        local op = opFunc(cond.counter.op or '>=')
        local value = cond.counter.value or 0
        return function(src)
            local cur = lib.stats.get(src, var)
            return op(cur, value)
        end
    end
    return function() return false end
end

local function loadDefinitionsOnce()
    if jsonDefsLoaded then return end
    jsonDefsLoaded = true
    local dirFiles
    dirFiles = lib.getFilesInDirectory('achievements', '.+%.json$')
    for _, file in ipairs(dirFiles) do
        if file:sub(-5) == '.json' then
            local pathNoExt = ('achievements.%s'):format(file:sub(1, -6))
            local ok, defs = pcall(lib.loadJson, pathNoExt)
            if ok and type(defs) == 'table' then
                for _, def in ipairs(defs) do
                    if def.conditions and not def.eval then
                        def.eval = compileCondition(def.conditions)
                    end
                    Achievements.register(def)
                end
            else
                print(('^1[Achievements] Failed loading %s: %s^0'):format(file, defs))
            end
        end
    end
end

-- Call loading after resource start
CreateThread(function()
    Wait(0)
    loadDefinitionsOnce()
end)

-- integrate with hooks trigger
local Hooks = lib.hooks
if Hooks and Hooks.trigger then
    -- listen to all hook triggers via wrapper
    local originalTrigger = Hooks.trigger
    function Hooks.trigger(name, ...)
        local src = ... or 0
        Achievements.handleEvent(name, src, select(2, ...))
        return originalTrigger(name, ...)
    end
end

local registered = registered or {}
local playerProgress = playerProgress or {}
local _eventMap = _eventMap or {}

---Register a new achievement definition.
---@param def AchievementDefinition
---@return boolean success
function Achievements.register(def)
    if not def or not def.id then return false end
    if registered[def.id] then return false end
    registered[def.id] = def

    if def.listen_events then
        for _, evt in ipairs(def.listen_events) do
            if not _eventMap[evt] then _eventMap[evt] = {} end
            table.insert(_eventMap[evt], def.id)
        end
    end
    return true
end

---Unlock an achievement for a player.
---@param src number
---@param id string
---@return boolean unlocked
function Achievements.unlock(src, id)
    if not registered[id] then return false end
    if not playerProgress[src] then playerProgress[src] = {} end
    if playerProgress[src][id] then return false end
    playerProgress[src][id] = os.time()

    -- Sync via state bag
    local ply = Player(src)
    if ply and ply.state then
        ply.state:set('achievements', playerProgress[src], true)
    end

    Achievements._dispatchUnlock(src, id)
    lib.hooks.trigger('achievement:unlocked', src, id)
    TriggerClientEvent('lib:achievementsUnlocked', src, id)
    return true
end

---Handle game event for evaluation.
---@param event string
---@param src number
---@param data any
function Achievements.handleEvent(event, src, data)
    local list = _eventMap[event]
    if not list then return end
    for _, id in ipairs(list) do
        local def = registered[id]
        if def and def.eval and not (playerProgress[src] and playerProgress[src][id]) then
            local ok, passed = pcall(def.eval, src, event, data)
            if ok and passed then
                Achievements.unlock(src, id)
            elseif not ok then
                print(('^1[Achievements] eval error (%s): %s^0'):format(id, passed))
            end
        end
    end
end

---Check if a player has unlocked an achievement
---@param src number
---@param id string
---@return boolean
function Achievements.isUnlocked(src, id)
    return playerProgress[src] and playerProgress[src][id] ~= nil
end

---Return all unlocked achievements for player
function Achievements.getAll(src)
    return playerProgress[src] or {}
end

---Utility to wipe progress (e.g., admin)
function Achievements.resetPlayer(src)
    playerProgress[src] = nil
    local ply = Player(src)
    if ply and ply.state then
        ply.state:set('achievements', {}, true)
    end
end

---Handle player dropping to clean up
AddEventHandler('playerDropped', function()
    playerProgress[source] = nil
end)

-- Export to lib table when server context
lib.achievements = Achievements
