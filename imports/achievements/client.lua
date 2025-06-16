---@meta

-- Shared Achievements table is already defined in shared.lua within same chunk
local playerState = LocalPlayer.state

---Check if local player unlocked an achievement
function Achievements.isUnlocked(id)
    local bag = playerState.achievements
    return bag and bag[id] ~= nil
end

---Return table of unlocked achievements
function Achievements.getAll()
    return playerState.achievements or {}
end

-- Listen for unlock events from server
RegisterNetEvent('lib:achievementsUnlocked', function(id)
    Achievements._dispatchUnlock(cache.source or -1, id)
end)

-- expose on lib
lib.achievements = Achievements

return Achievements
