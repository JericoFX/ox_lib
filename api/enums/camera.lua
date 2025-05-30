---@meta

---Camera-related enumerations for ox_lib
---@class lib.enums.camera
local camera = {}

-- Camera types
camera.CAMERA_TYPES = {
    DEFAULT_SCRIPTED = "DEFAULT_SCRIPTED_CAMERA",
    DEFAULT_ANIMATED = "DEFAULT_ANIMATED_CAMERA",
    DEFAULT_SPLINE = "DEFAULT_SPLINE_CAMERA",
    TIMED_SPLINE = "TIMED_SPLINE_CAMERA",
    CUSTOM_TIMED_SPLINE = "CUSTOM_TIMED_SPLINE_CAMERA",
    SCRIPTED_FLY = "DEFAULT_SCRIPTED_FLY_CAMERA"
}

-- Camera shake types
camera.SHAKE_TYPES = {
    HAND = "HAND_SHAKE",
    SMALL_EXPLOSION = "SMALL_EXPLOSION_SHAKE",
    MEDIUM_EXPLOSION = "MEDIUM_EXPLOSION_SHAKE",
    LARGE_EXPLOSION = "LARGE_EXPLOSION_SHAKE",
    JOLT = "JOLT_SHAKE",
    VIBRATE = "VIBRATE_SHAKE",
    ROAD_VIBRATION = "ROAD_VIBRATION_SHAKE",
    DRUNK = "DRUNK_SHAKE",
    SKY_DIVING = "SKY_DIVING_SHAKE",
    FAMILY5_DRUG_TRIP = "FAMILY5_DRUG_TRIP_SHAKE"
}

-- Camera transition easing
camera.EASING_TYPES = {
    LINEAR = "linear",
    EASE_IN = "ease_in",
    EASE_OUT = "ease_out",
    EASE_IN_OUT = "ease_in_out",
    EASE_IN_BACK = "ease_in_back",
    EASE_OUT_BACK = "ease_out_back",
    EASE_IN_OUT_BACK = "ease_in_out_back",
    BOUNCE_IN = "bounce_in",
    BOUNCE_OUT = "bounce_out",
    BOUNCE_IN_OUT = "bounce_in_out"
}

-- Camera view modes
camera.VIEW_MODES = {
    FIRST_PERSON = 4,
    THIRD_PERSON_NEAR = 1,
    THIRD_PERSON_MEDIUM = 2,
    THIRD_PERSON_FAR = 3,
    CINEMATIC = 5
}

-- Camera angles
camera.ANGLES = {
    LOW = -30.0,
    EYE_LEVEL = 0.0,
    HIGH = 30.0,
    BIRD = 75.0,
    TOP_DOWN = 90.0
}

-- Field of View presets
camera.FOV_PRESETS = {
    VERY_NARROW = 15.0,
    NARROW = 30.0,
    NORMAL = 50.0,
    WIDE = 70.0,
    VERY_WIDE = 90.0,
    ULTRA_WIDE = 110.0
}

-- Camera follow modes
camera.FOLLOW_MODES = {
    RIGID = 0,
    LOOSE = 1,
    SMOOTH = 2,
    CINEMATIC = 3
}

return camera 