---@meta

---@class NPCEnums
---@field STATES table<string,string> AI state constants

return {
    STATES = {
        IDLE = 'idle',
        PATROLLING = 'patrolling',
        INTERACTING = 'interacting',
        WORKING = 'working',
        ALERT = 'alert',
        FLEEING = 'fleeing',
        PURSUING = 'pursuing'
    }
}
