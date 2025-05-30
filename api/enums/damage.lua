---@meta

---Damage-related enumerations for ox_lib
---@class lib.enums.damage
local damage = {}

-- Damage types
damage.DAMAGE_TYPES = {
    MELEE = "melee",
    BULLET = "bullet",
    EXPLOSION = "explosion",
    FIRE = "fire",
    COLLISION = "collision",
    FALL = "fall",
    DROWN = "drown",
    ELECTRIC = "electric",
    BARBED_WIRE = "barbed_wire",
    SMOKE = "smoke",
    WATER_CANNON = "water_cannon",
    GAS = "gas"
}

-- Body parts / components
damage.BODY_PARTS = {
    HEAD = 31086,
    NECK = 39317,
    SPINE_ROOT = 57597,
    SPINE_0 = 23553,
    SPINE_1 = 24816,
    SPINE_2 = 24817,
    SPINE_3 = 24818,
    PELVIS = 11816,
    LEFT_HIP = 58271,
    LEFT_LEG = 63931,
    LEFT_FOOT = 14201,
    RIGHT_HIP = 51826,
    RIGHT_LEG = 36864,
    RIGHT_FOOT = 52301,
    LEFT_SHOULDER = 45509,
    LEFT_ARM = 61163,
    LEFT_HAND = 18905,
    RIGHT_SHOULDER = 40269,
    RIGHT_ARM = 28252,
    RIGHT_HAND = 57005
}

-- Damage multipliers by body part
damage.DAMAGE_MULTIPLIERS = {
    [31086] = 2.0,  -- Head
    [39317] = 1.5,  -- Neck
    [24818] = 1.0,  -- Spine
    [24816] = 1.0,  -- Chest
    [0] = 1.0       -- Default
}

-- Vehicle damage components
damage.VEHICLE_COMPONENTS = {
    ENGINE = 1,
    PETROL_TANK = 2,
    RADIATOR = 3,
    REAR_BUMPER = 4,
    FRONT_BUMPER = 5,
    LEFT_FRONT_WHEEL = 6,
    RIGHT_FRONT_WHEEL = 7,
    LEFT_REAR_WHEEL = 8,
    RIGHT_REAR_WHEEL = 9
}

-- Damage sources
damage.DAMAGE_SOURCES = {
    UNKNOWN = 0,
    MELEE = 1,
    HANDGUN = 2,
    SMG = 3,
    SHOTGUN = 4,
    ASSAULT_RIFLE = 5,
    SNIPER = 6,
    HEAVY = 7,
    THROWN = 8,
    EXPLOSION = 9,
    FIRE = 10,
    COLLISION = 11,
    FALL = 12,
    DROWNING = 13,
    ENVIRONMENT = 14
}

return damage 