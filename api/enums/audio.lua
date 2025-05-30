---@meta

---Audio-related enumerations for ox_lib
---@class lib.enums.audio
local audio = {}

-- Default sound sets
audio.DEFAULT_SOUND_SET = "HUD_FRONTEND_DEFAULT_SOUNDSET"

-- Common sound sets
audio.SOUND_SETS = {
    DEFAULT = "HUD_FRONTEND_DEFAULT_SOUNDSET",
    PHONE = "PHONE_SOUNDSET",
    WEAPON = "WEAPONS_SOUNDSET", 
    VEHICLE = "VEHICLES_SOUNDSET",
    RADIO = "RADIO_SOUNDSET",
    UI = "DLC_HEIST_FLEECA_SOUNDSET",
    MISSION = "MISSION_SOUNDSET",
    WORLD = "WORLD_SOUNDSET"
}

-- Common sounds
audio.SOUNDS = {
    -- UI Sounds
    SELECT = "SELECT",
    BACK = "BACK", 
    ERROR = "ERROR",
    SUCCESS = "CONTINUE",
    CANCEL = "CANCEL",
    
    -- Phone Sounds
    PHONE_RING = "Remote_Ring",
    PHONE_PICKUP = "Menu_Accept",
    PHONE_HANGUP = "Phone_SoundSet_Michael",
    
    -- Weapon Sounds
    WEAPON_RELOAD = "WEAPON_RELOAD",
    WEAPON_EMPTY = "DRY_FIRE",
    WEAPON_SWITCH = "WEAPON_SWITCH",
    
    -- Vehicle Sounds
    ENGINE_START = "ENGINE_START",
    ENGINE_STOP = "ENGINE_STOP",
    HORN = "HORN",
    BRAKE = "BRAKE",
    
    -- World Sounds
    EXPLOSION = "EXPLOSION",
    GLASS_BREAK = "GLASS_BREAK",
    METAL_HIT = "METAL_HIT",
    WATER_SPLASH = "WATER_SPLASH"
}

-- Radio stations
audio.RADIO_STATIONS = {
    OFF = "OFF",
    LOS_SANTOS_ROCK = "RADIO_01_CLASS_ROCK",
    NON_STOP_POP = "RADIO_02_POP",
    RADIO_LOS_SANTOS = "RADIO_03_HIPHOP_NEW",
    CHANNEL_X = "RADIO_04_PUNK",
    WEST_COAST_TALK = "RADIO_05_TALK_01",
    REBEL_RADIO = "RADIO_06_COUNTRY",
    SOULWAX_FM = "RADIO_07_DANCE_01",
    EAST_LOS_FM = "RADIO_08_MEXICAN",
    WEST_COAST_CLASSICS = "RADIO_09_HIPHOP_OLD",
    BLAINE_COUNTY_RADIO = "RADIO_11_TALK_02",
    THE_BLUE_ARK = "RADIO_12_REGGAE",
    WORLDWIDE_FM = "RADIO_13_JAZZ",
    FLYLO_FM = "RADIO_14_DANCE_02",
    THE_LOWDOWN = "RADIO_15_MOTOWN",
    RADIO_MIRROR_PARK = "RADIO_16_SILVERLAKE",
    SPACE = "RADIO_17_FUNK",
    VINEWOOD_BOULEVARD = "RADIO_18_90S_ROCK",
    SELF_RADIO = "RADIO_19_USER",
    THE_LAB = "RADIO_20_THELAB"
}

-- Audio fade types
audio.FADE_TYPES = {
    LINEAR = "linear",
    EASE_IN = "ease_in",
    EASE_OUT = "ease_out",
    EASE_IN_OUT = "ease_in_out"
}

return audio 