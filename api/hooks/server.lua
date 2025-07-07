-- Server-side Hooks API - Secure Hook System
local hooks = {
    _events = {},
    _locked = false
}

lib.hooks = lib.hooks or {}

---Register a hook callback (server-only for security)
---@param name string Hook name (e.g. "player:before_give_item", "vehicle:before_spawn")
---@param callback function Callback function - return false to prevent action
---@param priority? number Higher priority runs first (default: 0)
---@return boolean success True if hook was registered successfully
function lib.hooks.register(name, callback, priority)
    if type(name) ~= 'string' or type(callback) ~= 'function' then
        return false
    end

    priority = priority or 0
    local list = hooks._events[name] or {}
    list[#list + 1] = { priority = priority, callback = callback }
    table.sort(list, function(a, b) return a.priority > b.priority end)
    hooks._events[name] = list

    return true
end

---Trigger a hook chain (server-only)
---@param name string Hook name
---@param ... any Arguments to pass to callbacks
---@return boolean allowed True if action should proceed, false if prevented
function lib.hooks.trigger(name, ...)
    local list = hooks._events[name]
    if not list then return true end

    local args = { ... }

    for i = 1, #list do
        local hook = list[i]
        local success, result = pcall(hook.callback, table.unpack(args))

        if not success then
            lib.print.error(('Hook error in "%s": %s'):format(name, result))
        elseif result == false then
            return false
        end
    end

    return true
end

---Remove a specific hook callback
---@param name string Hook name
---@param callback function The callback function to remove
---@return boolean success True if hook was removed
function lib.hooks.remove(name, callback)
    local list = hooks._events[name]
    if not list then return false end

    for i = #list, 1, -1 do
        if list[i].callback == callback then
            table.remove(list, i)
            return true
        end
    end

    return false
end

---Remove all hooks for a specific name
---@param name string Hook name
---@return boolean success True if hooks were cleared
function lib.hooks.clear(name)
    if hooks._events[name] then
        hooks._events[name] = nil
        return true
    end
    return false
end

---Get registered hooks for debugging (admin only)
---@param name? string Specific hook name, or nil for all
---@return table hooks List of registered hooks
function lib.hooks.getRegistered(name)
    if name then
        return hooks._events[name] or {}
    end

    local result = {}
    for hookName, hookList in pairs(hooks._events) do
        result[hookName] = #hookList
    end

    return result
end

---Check if a hook is registered
---@param name string Hook name
---@return boolean exists True if hook has registered callbacks
function lib.hooks.exists(name)
    local list = hooks._events[name]
    return list and #list > 0
end

---Execute a hook with custom return handling
---@param name string Hook name
---@param handler function Custom handler for results (receives all return values)
---@param ... any Arguments to pass to callbacks
---@return any result Result from custom handler
function lib.hooks.triggerWithHandler(name, handler, ...)
    local list = hooks._events[name]
    if not list then return handler() end

    local args = { ... }
    local results = {}

    for i = 1, #list do
        local hook = list[i]
        local success, result = pcall(hook.callback, table.unpack(args))

        if not success then
            lib.print.error(('Hook error in "%s": %s'):format(name, result))
        else
            results[#results + 1] = result
        end
    end

    return handler(table.unpack(results))
end
