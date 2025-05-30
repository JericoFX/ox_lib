---@meta

---Vehicle Related Enumerations
---@class VehicleEnums
---@field DOORS table<string, number> Vehicle door indices
---@field WINDOWS table<string, number> Vehicle window indices
---@field LIGHTS table<string, number> Vehicle light types
---@field CLASSES table<string, number> Vehicle class IDs
---@field MODS table<string, number> Vehicle modification indices
---@field COLORS table<string, number> Vehicle color IDs
---@field DAMAGE table<string, number> Vehicle damage states
---@field SEATS table<string, number> Vehicle seat indices
---@field ENGINE table<string, number> Vehicle engine states

return {
    -- Vehicle Doors
    ---@enum VehicleDoors
    DOORS = {
        FRONT_LEFT = 0,
        FRONT_RIGHT = 1,
        REAR_LEFT = 2,
        REAR_RIGHT = 3,
        HOOD = 4,
        TRUNK = 5,
        TRUNK2 = 6 -- For some special vehicles
    },

    -- Vehicle Windows
    ---@enum VehicleWindows
    WINDOWS = {
        FRONT_LEFT = 0,
        FRONT_RIGHT = 1,
        REAR_LEFT = 2,
        REAR_RIGHT = 3,
        WINDSCREEN = 6,
        REAR_WINDSCREEN = 7
    },

    -- Vehicle Lights
    ---@enum VehicleLights
    LIGHTS = {
        HEADLIGHTS = 1,
        INTERIOR = 2,
        HAZARDS = 3,
        LEFT_INDICATOR = 4,
        RIGHT_INDICATOR = 5
    },

    -- Vehicle Classes
    ---@enum VehicleClasses
    CLASSES = {
        COMPACTS = 0,
        SEDANS = 1,
        SUVS = 2,
        COUPES = 3,
        MUSCLE = 4,
        SPORTS_CLASSIC = 5,
        SPORTS = 6,
        SUPER = 7,
        MOTORCYCLES = 8,
        OFF_ROAD = 9,
        INDUSTRIAL = 10,
        UTILITY = 11,
        VANS = 12,
        CYCLES = 13,
        BOATS = 14,
        HELICOPTERS = 15,
        PLANES = 16,
        SERVICE = 17,
        EMERGENCY = 18,
        MILITARY = 19,
        COMMERCIAL = 20,
        TRAINS = 21
    },

    -- Vehicle Mods
    ---@enum VehicleMods
    MODS = {
        SPOILERS = 0,
        FRONT_BUMPER = 1,
        REAR_BUMPER = 2,
        SIDE_SKIRT = 3,
        EXHAUST = 4,
        FRAME = 5,
        GRILLE = 6,
        HOOD = 7,
        FENDER = 8,
        RIGHT_FENDER = 9,
        ROOF = 10,
        ENGINE = 11,
        BRAKES = 12,
        TRANSMISSION = 13,
        HORNS = 14,
        SUSPENSION = 15,
        ARMOR = 16,
        TURBO = 18,
        XENON = 22,
        FRONT_WHEELS = 23,
        BACK_WHEELS = 24,
        PLATE_HOLDERS = 25,
        VANITY_PLATES = 26,
        TRIM = 27,
        ORNAMENTS = 28,
        DASHBOARD = 29,
        DIAL = 30,
        DOOR_SPEAKER = 31,
        SEATS = 32,
        STEERING_WHEEL = 33,
        SHIFTER_LEAVERS = 34,
        PLAQUES = 35,
        SPEAKERS = 36,
        TRUNK = 37,
        HYDRAULICS = 38,
        ENGINE_BLOCK = 39,
        AIR_FILTER = 40,
        STRUTS = 41,
        ARCH_COVER = 42,
        AERIALS = 43,
        TRIM2 = 44,
        TANK = 45,
        WINDOWS = 46,
        LIVERY = 48
    },

    -- Vehicle Colors (Primary colors)
    ---@enum VehicleColors
    COLORS = {
        BLACK = 0,
        CARBON_BLACK = 1,
        GRAPHITE = 2,
        STEEL = 3,
        DARK_SILVER = 4,
        SILVER = 5,
        BLUE_SILVER = 6,
        ROLLED_STEEL = 7,
        SHADOW_SILVER = 8,
        STONE_SILVER = 9,
        MIDNIGHT_SILVER = 10,
        GUN_METAL = 11,
        WHITE = 111,
        FROST_WHITE = 112,
        RED = 27,
        TORINO_RED = 28,
        BLUE = 64,
        YELLOW = 88,
        GREEN = 53,
        ORANGE = 38,
        PURPLE = 71,
        PINK = 137
    },

    -- Vehicle Damage States
    ---@enum VehicleDamage
    DAMAGE = {
        NONE = 0,
        LIGHT = 1,
        MEDIUM = 2,
        HEAVY = 3,
        DESTROYED = 4
    },

    -- Vehicle Seats
    ---@enum VehicleSeats
    SEATS = {
        DRIVER = -1,
        PASSENGER = 0,
        REAR_LEFT = 1,
        REAR_RIGHT = 2
    },

    -- Vehicle Engine States
    ---@enum VehicleEngine
    ENGINE = {
        OFF = 0,
        ON = 1,
        STARTING = 2,
        STOPPING = 3
    }
}
