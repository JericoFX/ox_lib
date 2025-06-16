---@meta

---@class AchievementDefinition
---@field id string
---@field name string
---@field description string
---@field listen_events? string[]
---@field eval? fun(src:number,event:string|nil,data:any):boolean
---@field hidden? boolean
---@field requires? string[]

---@class lib.achievements
local Achievements = {}

local _callbacks = {}

---Register callback executed on unlock (client & server)
---@param fn fun(src:number, id:string)
function Achievements.onUnlock(fn)
    _callbacks[#_callbacks + 1] = fn
end

function Achievements._dispatchUnlock(src, id)
    for i = 1, #_callbacks do
        local ok, err = pcall(_callbacks[i], src, id)
        if not ok then
            print(('^1[Achievements] onUnlock error: %s^0'):format(err))
        end
    end
end

return Achievements 