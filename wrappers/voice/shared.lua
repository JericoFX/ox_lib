if IsDuplicityVersion() then
    return {}
end

if GetResourceState('pma-voice') == 'started' then
    return require 'wrappers.voice.pma-voice.client'
end

return {}
