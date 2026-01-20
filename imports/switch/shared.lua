--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---A pattern matching switch statement that allows chaining multiple cases.
---@param value any
---@return table
function lib.switch(value)
    local matched = false

    return {
        ---@param match any
        ---@param callback fun(): any
        ---@return table
        on = function(match, callback)
            if not matched and value == match then
                matched = true
                return callback()
            end
            return lib.switch(value)
        end,

        ---@param callback fun(): any
        default = function(callback)
            if not matched then
                return callback()
            end
        end
    }
end
