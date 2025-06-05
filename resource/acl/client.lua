--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

-- Client-side permission checking
function lib.hasPermission(permission)
    if not permission then
        return false
    end

    return lib.callback.await('ox_lib:checkPlayerAce', false, permission)
end
