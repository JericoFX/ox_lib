local utils = LoadResourceFile('ox_lib', 'wrappers/utils.lua')
if utils then
    local fn = load(utils, '@@ox_lib/wrappers/utils.lua')
    if fn then
        local wrapperUtils = fn()
        return wrapperUtils.createWrapper('banking', 'banking')
    end
end

-- Fallback si no se puede cargar utils
lib.banking = { system = 'unknown' }
return lib.banking
