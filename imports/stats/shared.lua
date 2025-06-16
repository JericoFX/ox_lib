---@meta

---@class lib.stats
local Stats = {}

if IsDuplicityVersion() then
    local playerStats = {}

    ---Increment named counter for a player.
    ---@param src number
    ---@param key string
    ---@param amount? number
    function Stats.increment(src, key, amount)
        amount = amount or 1
        local tbl = playerStats[src]
        if not tbl then
            tbl = {}
            playerStats[src] = tbl
        end
        tbl[key] = (tbl[key] or 0) + amount
        local ply = Player(src)
        if ply and ply.state then
            ply.state:set('stats', tbl, true)
        end
    end

    ---Get counter value for player.
    function Stats.get(src, key)
        local tbl = playerStats[src]
        return tbl and tbl[key] or 0
    end

    ---Set counter value (admin / internal)
    function Stats.set(src, key, value)
        local tbl = playerStats[src] or {}
        playerStats[src] = tbl
        tbl[key] = value
        local ply = Player(src)
        if ply and ply.state then
            ply.state:set('stats', tbl, true)
        end
    end

    ---Clear stats for player (on drop)
    AddEventHandler('playerDropped', function()
        playerStats[source] = nil
        local ply = Player(source)
        if ply and ply.state then
            ply.state:set('stats', nil, true)
        end
    end)
else
    -- CLIENT: request value from state bag or assume zero
    local playerState = LocalPlayer.state

    function Stats.get(key)
        local stats = playerState.stats
        return stats and stats[key] or 0
    end

    function Stats.increment(key, amount)
        print('lib.stats.increment should be called server-side')
    end

    function Stats.set(key, value)
        print('lib.stats.set should be called server-side')
    end
end

return Stats
