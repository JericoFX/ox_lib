local Hud = lib.class('Hud')

function Hud:constructor()
    self.system = 'qbx-hud'
    self._hunger = 0
    self._thirst = 0
end

-- Update player health via StateBag
function Hud:updateHealth(health)
    LocalPlayer.state:set(lib.enums.statebags.COMMON_KEYS.PLAYER_HEALTH, health, true)
end

-- Update player armor via StateBag
function Hud:updateArmor(armor)
    LocalPlayer.state:set(lib.enums.statebags.COMMON_KEYS.PLAYER_ARMOR, armor, true)
end

-- Update hunger; store local copy to pair with thirst if needed
function Hud:updateHunger(hunger)
    self._hunger = hunger
    LocalPlayer.state:set('hunger', hunger, true)
end

-- Update thirst; keep hunger in local state but send separately too
function Hud:updateThirst(thirst)
    self._thirst = thirst
    LocalPlayer.state:set('thirst', thirst, true)
end

-- Toggle HUD visibility
function Hud:showHud(show)
    LocalPlayer.state:set('hudVisible', show, false)
end

-- Register a callback whenever any of the tracked values changes (health, armor, hunger, thirst)
function Hud:onChange(cb)
    if type(cb) ~= 'function' then return end

    local playerId = cache.serverId or GetPlayerServerId(PlayerId())

    local watchedKeys = {
        lib.enums.statebags.COMMON_KEYS.PLAYER_HEALTH,
        lib.enums.statebags.COMMON_KEYS.PLAYER_ARMOR,
        'hunger',
        'thirst'
    }

    for _, key in ipairs(watchedKeys) do
        lib.statebags:watchPlayerState(playerId, key, function(_, _, value, oldValue)
            if value ~= oldValue then
                cb(key, value, oldValue)
            end
        end)
    end
end

return Hud
