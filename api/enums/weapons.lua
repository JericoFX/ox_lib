---@meta

---Weapons-related enumerations for ox_lib
---@class lib.enums.weapons
local weapons = {}

-- Weapon categories
weapons.CATEGORIES = {
    MELEE = "melee",
    HANDGUN = "handgun",
    SMG = "smg",
    SHOTGUN = "shotgun",
    ASSAULT_RIFLE = "assault_rifle",
    SNIPER = "sniper",
    HEAVY = "heavy",
    THROWN = "thrown",
    SPECIAL = "special"
}

-- Common weapons
weapons.WEAPONS = {
    -- Melee
    UNARMED = "WEAPON_UNARMED",
    KNIFE = "WEAPON_KNIFE",
    NIGHTSTICK = "WEAPON_NIGHTSTICK",
    HAMMER = "WEAPON_HAMMER",
    BAT = "WEAPON_BAT",
    CROWBAR = "WEAPON_CROWBAR",
    GOLF_CLUB = "WEAPON_GOLFCLUB",
    BOTTLE = "WEAPON_BOTTLE",
    SWITCHBLADE = "WEAPON_SWITCHBLADE",
    
    -- Handguns
    PISTOL = "WEAPON_PISTOL",
    COMBAT_PISTOL = "WEAPON_COMBATPISTOL",
    AP_PISTOL = "WEAPON_APPISTOL",
    PISTOL_50 = "WEAPON_PISTOL50",
    SNS_PISTOL = "WEAPON_SNSPISTOL",
    HEAVY_PISTOL = "WEAPON_HEAVYPISTOL",
    VINTAGE_PISTOL = "WEAPON_VINTAGEPISTOL",
    FLARE_GUN = "WEAPON_FLAREGUN",
    MARKSMAN_PISTOL = "WEAPON_MARKSMANPISTOL",
    
    -- SMGs
    MICRO_SMG = "WEAPON_MICROSMG",
    SMG = "WEAPON_SMG",
    ASSAULT_SMG = "WEAPON_ASSAULTSMG",
    COMBAT_PDW = "WEAPON_COMBATPDW",
    MG = "WEAPON_MG",
    COMBAT_MG = "WEAPON_COMBATMG",
    
    -- Shotguns
    PUMP_SHOTGUN = "WEAPON_PUMPSHOTGUN",
    SAWED_OFF_SHOTGUN = "WEAPON_SAWNOFFSHOTGUN",
    ASSAULT_SHOTGUN = "WEAPON_ASSAULTSHOTGUN",
    BULLPUP_SHOTGUN = "WEAPON_BULLPUPSHOTGUN",
    MUSKET = "WEAPON_MUSKET",
    HEAVY_SHOTGUN = "WEAPON_HEAVYSHOTGUN",
    
    -- Assault Rifles
    ASSAULT_RIFLE = "WEAPON_ASSAULTRIFLE",
    CARBINE_RIFLE = "WEAPON_CARBINERIFLE",
    ADVANCED_RIFLE = "WEAPON_ADVANCEDRIFLE",
    SPECIAL_CARBINE = "WEAPON_SPECIALCARBINE",
    BULLPUP_RIFLE = "WEAPON_BULLPUPRIFLE",
    
    -- Sniper Rifles
    SNIPER_RIFLE = "WEAPON_SNIPERRIFLE",
    HEAVY_SNIPER = "WEAPON_HEAVYSNIPER",
    MARKSMAN_RIFLE = "WEAPON_MARKSMANRIFLE",
    
    -- Heavy Weapons
    RPG = "WEAPON_RPG",
    GRENADE_LAUNCHER = "WEAPON_GRENADELAUNCHER",
    MINIGUN = "WEAPON_MINIGUN",
    FIREWORK = "WEAPON_FIREWORK",
    RAILGUN = "WEAPON_RAILGUN",
    HOMING_LAUNCHER = "WEAPON_HOMINGLAUNCHER",
    
    -- Thrown
    GRENADE = "WEAPON_GRENADE",
    STICKY_BOMB = "WEAPON_STICKYBOMB",
    PROXIMITY_MINE = "WEAPON_PROXIMITYMINE",
    BZ_GAS = "WEAPON_BZGAS",
    MOLOTOV = "WEAPON_MOLOTOV",
    FIRE_EXTINGUISHER = "WEAPON_FIREEXTINGUISHER",
    PETROL_CAN = "WEAPON_PETROLCAN",
    SNOWBALL = "WEAPON_SNOWBALL",
    FLARE = "WEAPON_FLARE"
}

-- Weapon attachments
weapons.ATTACHMENTS = {
    -- Scopes
    SCOPE = "COMPONENT_AT_SCOPE_MACRO",
    SCOPE_SMALL = "COMPONENT_AT_SCOPE_SMALL",
    SCOPE_MEDIUM = "COMPONENT_AT_SCOPE_MEDIUM",
    SCOPE_LARGE = "COMPONENT_AT_SCOPE_LARGE",
    
    -- Suppressors
    SUPPRESSOR = "COMPONENT_AT_AR_SUPP",
    SUPPRESSOR_LIGHT = "COMPONENT_AT_PI_SUPP",
    
    -- Flashlights
    FLASHLIGHT = "COMPONENT_AT_AR_FLSH",
    FLASHLIGHT_LIGHT = "COMPONENT_AT_PI_FLSH",
    
    -- Grips
    GRIP = "COMPONENT_AT_AR_AFGRIP",
    
    -- Extended Clips
    EXTENDED_CLIP = "COMPONENT_AT_AR_CLIP_02",
    EXTENDED_CLIP_LIGHT = "COMPONENT_AT_PI_CLIP_02",
    
    -- Special
    ADVANCED_SCOPE = "COMPONENT_AT_SCOPE_MAX",
    THERMAL_SCOPE = "COMPONENT_AT_SCOPE_THERMAL"
}

-- Weapon tints
weapons.TINTS = {
    DEFAULT = 0,
    GREEN = 1,
    GOLD = 2,
    PINK = 3,
    ARMY = 4,
    LSPD = 5,
    ORANGE = 6,
    PLATINUM = 7
}

-- Ammo types
weapons.AMMO_TYPES = {
    PISTOL = "AMMO_PISTOL",
    SMG = "AMMO_SMG",
    RIFLE = "AMMO_RIFLE",
    MG = "AMMO_MG",
    SHOTGUN = "AMMO_SHOTGUN",
    SNIPER = "AMMO_SNIPER",
    SNIPER_REMOTE = "AMMO_SNIPER_REMOTE",
    GRENADE = "AMMO_GRENADE",
    RPG = "AMMO_RPG",
    TANK = "AMMO_TANK",
    SPACE_ROCKET = "AMMO_SPACE_ROCKET",
    PLAYER_LAUNCHER = "AMMO_PLAYER_LAUNCHER",
    STINGER = "AMMO_STINGER",
    MINIGUN = "AMMO_MINIGUN",
    GRENADE_LAUNCHER = "AMMO_GRENADELAUNCHER",
    RAILGUN = "AMMO_RAILGUN"
}

return weapons 