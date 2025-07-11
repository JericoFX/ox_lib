local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'
local loadedModules = {}
local moduleCache = {}

local LOAD_PRIORITY = {
    imports = 1,
    api = 2,
    wrappers = 3
}

local function getCallerInfo()
    local level = 3
    local info = debug.getinfo(level, "S")
    while info do
        local source = info.source
        if source and source:find("@@") then
            local resource = source:match("@@([^/]+)")
            if resource and resource ~= "ox_lib" then
                return resource, source
            end
        end
        level = level + 1
        info = debug.getinfo(level, "S")
    end
    return "ox_lib", nil
end

local function tryLoadFile(basePath, module, contextOverride)
    local ctx = contextOverride or context
    local paths = {
        ('%s/%s/%s.lua'):format(basePath, module, ctx),
        ('%s/%s/shared.lua'):format(basePath, module)
    }
    
    for _, path in ipairs(paths) do
        local content = LoadResourceFile('ox_lib', path)
        if content then
            return content, path
        end
    end
    
    return nil, nil
end

local function loadModuleInternal(module, callerResource)
    local cacheKey = ('%s:%s'):format(callerResource, module)
    
    if moduleCache[cacheKey] then
        return moduleCache[cacheKey]
    end
    
    if loadedModules[cacheKey] == 'loading' then
        error(('Circular dependency detected for module %s from %s'):format(module, callerResource))
    end
    
    loadedModules[cacheKey] = 'loading'
    
    local searchPaths = {
        { base = 'imports', priority = LOAD_PRIORITY.imports },
        { base = 'api', priority = LOAD_PRIORITY.api },
        { base = 'wrappers', priority = LOAD_PRIORITY.wrappers }
    }
    
    for _, searchPath in ipairs(searchPaths) do
        local content, path = tryLoadFile(searchPath.base, module)
        
        if content then
            local env = setmetatable({
                lib = lib,
                cache = cache,
                require = require,
                _ENV = _ENV
            }, { __index = _G })
            
            local fn, err = load(content, ('@@ox_lib/%s'):format(path), 't', env)
            
            if not fn then
                loadedModules[cacheKey] = 'error'
                error(('Error loading module %s: %s'):format(module, err))
            end
            
            local success, result = pcall(fn)
            
            if not success then
                loadedModules[cacheKey] = 'error'
                error(('Error executing module %s: %s'):format(module, result))
            end
            
            loadedModules[cacheKey] = 'loaded'
            moduleCache[cacheKey] = result or {}
            
            return moduleCache[cacheKey]
        end
    end
    
    if callerResource == 'ox_lib' then
        local wrapperUtils = tryLoadFile('wrappers', 'utils')
        if wrapperUtils then
            local fn = load(wrapperUtils, '@@ox_lib/wrappers/utils.lua')
            if fn then
                local utils = fn()
                if utils and utils.createWrapper then
                    local result = utils.createWrapper(module, module)
                    loadedModules[cacheKey] = 'loaded'
                    moduleCache[cacheKey] = result
                    return result
                end
            end
        end
    end
    
    loadedModules[cacheKey] = 'notfound'
    return nil
end

local function UnifiedLoader(module)
    local callerResource = getCallerInfo()
    return loadModuleInternal(module, callerResource)
end

local function clearModuleCache(module)
    if module then
        for key in pairs(moduleCache) do
            if key:find(':' .. module .. '$') then
                moduleCache[key] = nil
                loadedModules[key] = nil
            end
        end
    else
        moduleCache = {}
        loadedModules = {}
    end
end

return {
    load = UnifiedLoader,
    clearCache = clearModuleCache,
    getLoadedModules = function() return loadedModules end,
    getModuleCache = function() return moduleCache end
}
