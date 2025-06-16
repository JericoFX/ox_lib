---@meta
--[[
    Hooks module inspired by Qbox-project/qbx_core (MIT).
    https://github.com/Qbox-project/qbx_core/blob/main/modules/hooks.lua
    Copyright (C) 2021  Linden <https://github.com/thelindat>, Dunak <https://github.com/dunak-debug>, Luke <https://github.com/LukeWasTakenn>
    Provides simple middleware-style event hooks usable from client and server.
]]

local Hooks = {
    _events = {}
}

---Register a hook callback.
---@param name string  # Hook name (e.g. "player:loaded")
---@param fn fun(...: any): boolean? # Callback; return false to stop chain
---@param priority? number  # Higher runs earlier (default 0)
function Hooks.on(name, fn, priority)
    priority = priority or 0
    local list = Hooks._events[name] or {}
    list[#list + 1] = { p = priority, f = fn }
    table.sort(list, function(a, b) return a.p > b.p end)
    Hooks._events[name] = list
end

---Trigger a hook chain.
---@param name string  # Hook name.
---@param ... any      # Payload forwarded to callbacks.
function Hooks.trigger(name, ...)
    local list = Hooks._events[name]
    if not list then return end

    local args = { ... }

    for i = 1, #list do
        local h = list[i]
        local ok, ret = pcall(h.f, table.unpack(args))
        if not ok then
            print(('^1[Hooks] error in "%s": %s^0'):format(name, ret))
        elseif ret == false then
            -- stop propagation for this trigger call
            break
        end
    end
end

return Hooks
