local Normalizer = require 'wrappers.core.normalizer'

local Voice = lib.class('Voice')

function Voice:constructor()
    self.system = 'pma-voice'
    self.voice = exports['pma-voice']
end

function Voice:setPlayerRadio(frequency)
    self.voice:setPlayerRadio(frequency)
end

function Voice:setPlayerPhone(callId)
    self.voice:setPlayerCall(callId)
end

function Voice:setProximityRange(range)
    self.voice:setRange(range)
end

function Voice:mutePlayer(player, muted)
    self.voice:toggleMutePlayer(player, muted)
end

-- Register implementation in Normalizer -------------------------------------------------------
Normalizer.voice.setPlayerRadio    = function(...) return Voice:setPlayerRadio(...) end
Normalizer.voice.setPlayerPhone    = function(...) return Voice:setPlayerPhone(...) end
Normalizer.voice.setProximityRange = function(...) return Voice:setProximityRange(...) end
Normalizer.voice.mutePlayer        = function(...) return Voice:mutePlayer(...) end
Normalizer.capabilities.voice      = true

return Voice
