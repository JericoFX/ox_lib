--[[
    Task and Animation Enums
]]

return {
    -- Task Types
    TASK_TYPES = {
        HANDS_UP = 0,
        PLAY_ANIM = 1,
        SCENARIO = 2,
        CLEAR_TASKS = 3,
        LOOK_AT = 4,
        MOVE_TO = 5
    },

    -- Common Tasks
    TASKS = {
        HANDS_UP = `HANDS_UP`,
        HANDSUP = `HANDS_UP`,
        KNEEL = `CODE_HUMAN_MEDIC_KNEEL`,
        SURRENDER = `handsup_2`,
        SEARCH = `PROP_HUMAN_BUM_BIN`,
        MECHANIC = `WORLD_HUMAN_VEHICLE_MECHANIC`,
        CLEAN = `WORLD_HUMAN_MAID_CLEAN`,
        FISHING = `WORLD_HUMAN_STAND_FISHING`,
        SMOKING = `WORLD_HUMAN_SMOKING`,
        DRINKING = `WORLD_HUMAN_DRINKING`,
        GUARD = `WORLD_HUMAN_GUARD_STAND`,
        COP_IDLE = `WORLD_HUMAN_COP_IDLES`,
        CLIPBOARD = `WORLD_HUMAN_CLIPBOARD`,
        WELDING = `WORLD_HUMAN_WELDING`
    },

    -- Animation Flags
    ANIM_FLAGS = {
        NORMAL = 0,
        REPEAT = 1,
        STOP_LAST_FRAME = 2,
        UPPER_BODY_ONLY = 16,
        ENABLE_PLAYER_CONTROL = 32,
        CANCELABLE = 120,
        NOT_CANCELABLE = 0
    },

    -- Animation Blend
    BLEND = {
        IN_SLOW = 1.0,
        IN_NORMAL = 4.0,
        IN_FAST = 8.0,
        OUT_SLOW = 1.0,
        OUT_NORMAL = 4.0,
        OUT_FAST = 8.0
    }
}
