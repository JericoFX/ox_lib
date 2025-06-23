if GetResourceState('pma-voice') ~= 'started' then
    return {}
end

local normalizer = require 'wrappers.normalizer'
local voice = exports['pma-voice']

local function setPlayerRadio(frequency)
    voice:setPlayerRadio(frequency)
end

local function setPlayerPhone(callId)
    voice:setPlayerCall(callId)
end

local function setProximityRange(range)
    voice:setRange(range)
end

local function mutePlayer(player, muted)
    voice:toggleMutePlayer(player, muted)
end

normalizer.voice.setPlayerRadio = setPlayerRadio
normalizer.voice.setPlayerPhone = setPlayerPhone
normalizer.voice.setProximityRange = setProximityRange
normalizer.voice.mutePlayer = mutePlayer
normalizer.capabilities.voice = true

return {
    system = 'pma-voice',
    setPlayerRadio = setPlayerRadio,
    setPlayerPhone = setPlayerPhone,
    setProximityRange = setProximityRange,
    mutePlayer = mutePlayer
}
