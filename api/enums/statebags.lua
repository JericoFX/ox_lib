---@meta

---StateBag-related enumerations for ox_lib
---@class lib.enums.statebags
local statebags = {}

-- State types
statebags.STATE_TYPES = {
    GLOBAL = "global",
    PLAYER = "player", 
    ENTITY = "entity"
}

-- Common state keys
statebags.COMMON_KEYS = {
    -- Player states
    PLAYER_LOADED = "playerLoaded",
    PLAYER_JOB = "playerJob",
    PLAYER_MONEY = "playerMoney",
    PLAYER_COORDS = "playerCoords",
    PLAYER_HEALTH = "playerHealth",
    PLAYER_ARMOR = "playerArmor",
    PLAYER_WEAPONS = "playerWeapons",
    PLAYER_STATUS = "playerStatus",
    
    -- Vehicle states
    VEHICLE_OWNER = "vehicleOwner",
    VEHICLE_LOCKED = "vehicleLocked",
    VEHICLE_ENGINE = "vehicleEngine",
    VEHICLE_FUEL = "vehicleFuel",
    VEHICLE_DAMAGE = "vehicleDamage",
    VEHICLE_PROPERTIES = "vehicleProperties",
    
    -- Entity states
    ENTITY_OWNER = "entityOwner",
    ENTITY_DATA = "entityData",
    ENTITY_HEALTH = "entityHealth",
    ENTITY_COORDS = "entityCoords",
    
    -- Global states
    SERVER_TIME = "serverTime",
    WEATHER = "weather",
    PLAYER_COUNT = "playerCount",
    SERVER_STATUS = "serverStatus",
    BLACKOUT = "blackout"
}

-- State metadata flags
statebags.METADATA_FLAGS = {
    PERSISTENT = "persistent",
    PRIVATE = "private",
    REPLICATED = "replicated",
    READONLY = "readonly",
    ENCRYPTED = "encrypted"
}

-- State change reasons
statebags.CHANGE_REASONS = {
    SET = "set",
    UPDATE = "update",
    DELETE = "delete",
    SYNC = "sync",
    INIT = "init"
}

return statebags 