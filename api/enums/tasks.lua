---@meta

---Task and Animation Enumerations
---@class TaskEnums
---@field TASK_TYPES table<string, number> Task type constants
---@field TASKS table<string, number> Common task hashes
---@field ANIM_FLAGS table<string, number> Animation flag constants
---@field BLEND table<string, number> Animation blend speed constants

return {
    -- Task Types
    ---@enum TaskTypes
    TASK_TYPES = {
        HANDS_UP = 0,
        PLAY_ANIM = 1,
        SCENARIO = 2,
        CLEAR_TASKS = 3,
        LOOK_AT = 4,
        MOVE_TO = 5
    },

    -- Common Tasks
    ---@enum Tasks
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
    ---@enum AnimFlags
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
    ---@enum BlendSpeeds
    BLEND = {
        IN_SLOW = 1.0,
        IN_NORMAL = 4.0,
        IN_FAST = 8.0,
        OUT_SLOW = 1.0,
        OUT_NORMAL = 4.0,
        OUT_FAST = 8.0
    },

    -- Task Sequence Types
    ---@enum SequenceTypes
    SEQUENCE_TYPES = {
        GOTO_COORD = "goto_coord",
        GOTO_ENTITY = "goto_entity",
        PLAY_ANIM = "play_anim",
        SCENARIO = "scenario",
        SCENARIO_AT_POSITION = "scenario_at_position",
        ENTER_VEHICLE = "enter_vehicle",
        DRIVE_TO_COORD = "drive_to_coord",
        HANDS_UP = "hands_up",
        LOOK_AT_ENTITY = "look_at_entity",
        TURN_TO_FACE_ENTITY = "turn_to_face_entity",
        FOLLOW_PED = "follow_ped",
        WAIT = "wait",
        CLEAR_TASKS = "clear_tasks",
        CUSTOM = "custom"
    },

    -- Task Status Constants
    ---@enum TaskStatus
    TASK_STATUS = {
        NONE = 0,
        RUNNING = 1,
        FINISHED = 7,
        INTERRUPTED = 8
    },

    -- Common Scenarios for Sequences
    ---@enum SequenceScenarios
    SCENARIOS = {
        GUARD_STAND = "WORLD_HUMAN_GUARD_STAND",
        COP_IDLE = "WORLD_HUMAN_COP_IDLES",
        SMOKING = "WORLD_HUMAN_SMOKING",
        DRINKING = "WORLD_HUMAN_DRINKING",
        CLIPBOARD = "WORLD_HUMAN_CLIPBOARD",
        BINOCULARS = "WORLD_HUMAN_BINOCULARS",
        SUNBATHE = "WORLD_HUMAN_SUNBATHE",
        WELDING = "WORLD_HUMAN_WELDING",
        JANITOR = "WORLD_HUMAN_JANITOR",
        MUSICIAN = "WORLD_HUMAN_MUSICIAN",
        PAPARAZZI = "WORLD_HUMAN_PAPARAZZI",
        PICNIC = "WORLD_HUMAN_PICNIC",
        PUSH_UPS = "WORLD_HUMAN_PUSH_UPS",
        SIT_UPS = "WORLD_HUMAN_SIT_UPS",
        YOGA = "WORLD_HUMAN_YOGA",
        JOG_STANDING = "WORLD_HUMAN_JOG_STANDING",
        CHEERING = "WORLD_HUMAN_CHEERING",
        PARTYING = "WORLD_HUMAN_PARTYING",
        PHONE_MOBILE = "WORLD_HUMAN_MOBILE_FILM_SHOCKING",
        TEXTING = "WORLD_HUMAN_STAND_MOBILE_TEXTING",
        TOURIST_MAP = "WORLD_HUMAN_TOURIST_MAP",
        DRUG_DEALER = "WORLD_HUMAN_DRUG_DEALER_HARD"
    }
}
