---@meta

---Game Flags and States Enumerations
---@class FlagEnums
---@field CONTROLS table<string, number> Control input flags
---@field ENTITY_STATES table<string, number> Entity state flags
---@field PED_STATES table<string, number> Ped state flags
---@field NOTIFY_TYPES table<string, string> Notification type flags
---@field KEY_STATES table<string, number> Key state flags
---@field BLIP_TYPES table<string, number> Blip type flags
---@field BLIP_COLORS table<string, number> Blip color IDs

return {
    -- Control Flags
    ---@enum ControlFlags
    CONTROLS = {
        LOOK_LR = 1,
        LOOK_UD = 2,
        LOOK_UP_ONLY = 3,
        LOOK_DOWN_ONLY = 4,
        LOOK_LEFT_ONLY = 5,
        LOOK_RIGHT_ONLY = 6,
        CINEMATIC_SLOWMO = 7,
        FLY_UP_DOWN = 8,
        FLY_LEFT_RIGHT = 9,
        SLIDE_LEFT_RIGHT = 10,
        SLIDE_UP_DOWN = 11,
        MOVE_LEFT_RIGHT = 30,
        MOVE_UP_DOWN = 31,
        MOVE_UP_ONLY = 32,
        MOVE_DOWN_ONLY = 33,
        MOVE_LEFT_ONLY = 34,
        MOVE_RIGHT_ONLY = 35,
        DUCK = 36,
        SELECT_WEAPON = 37,
        PICKUP = 38,
        SNIPER_ZOOM = 39,
        SNIPER_ZOOM_IN_ONLY = 40,
        SNIPER_ZOOM_OUT_ONLY = 41,
        SNIPER_ZOOM_IN_SECONDARY = 42,
        SNIPER_ZOOM_OUT_SECONDARY = 43,
        COVER = 44,
        RELOAD = 45,
        TALK = 46,
        DETONATE = 47,
        HUD_SPECIAL = 48,
        ARREST = 49,
        ACCURATE_AIM = 50,
        CONTEXT = 51,
        CONTEXT_SECONDARY = 52,
        WEAPON_SPECIAL = 53,
        WEAPON_SPECIAL_TWO = 54,
        DIVE = 55,
        DROP_WEAPON = 56,
        DROP_AMMO = 57,
        THROW_GRENADE = 58,
        VEH_MOVE_LEFT_RIGHT = 59,
        VEH_MOVE_UP_DOWN = 60,
        VEH_MOVE_UP_ONLY = 61,
        VEH_MOVE_DOWN_ONLY = 62,
        VEH_MOVE_LEFT_ONLY = 63,
        VEH_MOVE_RIGHT_ONLY = 64,
        VEH_SPECIAL = 65,
        VEH_GUN_LEFT_RIGHT = 66,
        VEH_GUN_UP_DOWN = 67,
        VEH_AIM = 68,
        VEH_ATTACK = 69,
        VEH_ATTACK2 = 70,
        VEH_ACCELERATE = 71,
        VEH_BRAKE = 72,
        VEH_DUCK = 73,
        VEH_HEADLIGHT = 74,
        VEH_EXIT = 75,
        VEH_HANDBRAKE = 76,
        VEH_HOTWIRE_LEFT = 77,
        VEH_HOTWIRE_RIGHT = 78,
        VEH_LOOK_BEHIND = 79,
        VEH_CIN_CAM = 80,
        VEH_NEXT_RADIO = 81,
        VEH_PREV_RADIO = 82,
        VEH_NEXT_RADIO_TRACK = 83,
        VEH_PREV_RADIO_TRACK = 84,
        VEH_RADIO_WHEEL = 85,
        VEH_HORN = 86,
        VEH_FLY_THROTTLE_UP = 87,
        VEH_FLY_THROTTLE_DOWN = 88,
        VEH_FLY_YAW_LEFT = 89,
        VEH_FLY_YAW_RIGHT = 90,
        VEH_PASSENGER_AIM = 91,
        VEH_PASSENGER_ATTACK = 92,
        VEH_SPECIAL_ABILITY_FRANKLIN = 93,
        VEH_STUNT_UD = 94,
        VEH_CINEMATIC_UD = 95,
        VEH_CINEMATIC_UP_ONLY = 96,
        VEH_CINEMATIC_DOWN_ONLY = 97,
        VEH_CINEMATIC_LR = 98
    },

    -- Entity States
    ---@enum EntityStates
    ENTITY_STATES = {
        SPAWNED = 0,
        CREATED = 1,
        VISIBLE = 2,
        NETWORKED = 3,
        MISSION = 4,
        DEAD = 5,
        FROZEN = 6,
        INVINCIBLE = 7
    },

    -- Ped States
    ---@enum PedStates
    PED_STATES = {
        IDLE = 0,
        WALKING = 1,
        RUNNING = 2,
        SPRINTING = 3,
        DRIVING = 4,
        FLYING = 5,
        FALLING = 6,
        CLIMBING = 7,
        SWIMMING = 8,
        DIVING = 9,
        PARACHUTING = 10,
        DEAD = 11,
        RAGDOLL = 12,
        ARREST = 13,
        SEARCHING = 14
    },

    -- Notification Types
    ---@enum NotifyTypes
    NOTIFY_TYPES = {
        INFO = 'info',
        SUCCESS = 'success',
        WARNING = 'warning',
        ERROR = 'error',
        DEFAULT = 'default'
    },

    -- Key States
    ---@enum KeyStates
    KEY_STATES = {
        UP = 0,
        DOWN = 1,
        PRESSED = 2,
        RELEASED = 3
    },

    -- Blip Types
    ---@enum BlipTypes
    BLIP_TYPES = {
        COORD = 1,
        AREA = 2,
        RADIUS = 3,
        PICKUP = 4,
        COP = 5,
        PLAYER = 6,
        NETWORKPLAYER = 7,
        FRIEND = 8,
        WAYPOINT = 9
    },

    -- Blip Colors
    ---@enum BlipColors
    BLIP_COLORS = {
        WHITE = 0,
        RED = 1,
        GREEN = 2,
        BLUE = 3,
        YELLOW = 5,
        LIGHT_RED = 6,
        VIOLET = 7,
        PINK = 8,
        LIGHT_ORANGE = 9,
        LIGHT_BROWN = 10,
        LIGHT_GREEN = 11,
        LIGHT_BLUE = 12,
        LIGHT_PURPLE = 13,
        DARK_PURPLE = 14,
        CYAN = 15,
        LIGHT_YELLOW = 16,
        ORANGE = 17,
        BLUE2 = 18,
        DARK_GREEN = 19,
        DARK_BLUE = 20,
        DARK_CYAN = 21,
        LIGHT_CYAN = 22,
        YELLOW2 = 23,
        LIGHT_PINK = 24,
        LIGHT_RED2 = 25,
        LIGHT_YELLOW2 = 26,
        LIGHT_PINK2 = 27,
        LIGHT_RED3 = 28,
        LIGHT_YELLOW3 = 29
    }
}
