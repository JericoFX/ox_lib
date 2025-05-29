--[[
    Notification and UI Enums
]]

return {
    -- Notification Types
    TYPES = {
        SUCCESS = 'success',
        ERROR = 'error',
        WARNING = 'warning',
        INFO = 'info',
        DEFAULT = 'default'
    },

    -- Notification Positions
    POSITIONS = {
        TOP_LEFT = 'top-left',
        TOP_CENTER = 'top-center',
        TOP_RIGHT = 'top-right',
        BOTTOM_LEFT = 'bottom-left',
        BOTTOM_CENTER = 'bottom-center',
        BOTTOM_RIGHT = 'bottom-right',
        CENTER_LEFT = 'center-left',
        CENTER_RIGHT = 'center-right'
    },

    -- Notification Icons (FontAwesome)
    ICONS = {
        SUCCESS = 'fas fa-check',
        ERROR = 'fas fa-times',
        WARNING = 'fas fa-exclamation-triangle',
        INFO = 'fas fa-info-circle',
        MONEY = 'fas fa-dollar-sign',
        BANK = 'fas fa-university',
        POLICE = 'fas fa-shield-alt',
        MEDICAL = 'fas fa-plus',
        MECHANIC = 'fas fa-wrench',
        PHONE = 'fas fa-phone',
        MESSAGE = 'fas fa-comment',
        EMAIL = 'fas fa-envelope',
        INVENTORY = 'fas fa-box',
        CAR = 'fas fa-car',
        KEY = 'fas fa-key',
        HOME = 'fas fa-home',
        SETTINGS = 'fas fa-cog',
        USER = 'fas fa-user',
        HEART = 'fas fa-heart',
        STAR = 'fas fa-star',
        CLOCK = 'fas fa-clock'
    },

    -- Notification Colors
    COLORS = {
        SUCCESS = '#4CAF50',
        ERROR = '#F44336',
        WARNING = '#FF9800',
        INFO = '#2196F3',
        DEFAULT = '#9E9E9E',
        MONEY = '#4CAF50',
        BANK = '#2196F3',
        POLICE = '#3F51B5',
        MEDICAL = '#F44336',
        MECHANIC = '#FF9800'
    },

    -- Duration Presets (milliseconds)
    DURATION = {
        SHORT = 3000,
        MEDIUM = 5000,
        LONG = 8000,
        VERY_LONG = 12000,
        PERSISTENT = 0 -- 0 = no auto close
    },

    -- Dispatch Alert Types
    DISPATCH = {
        POLICE = {
            code = '10-90',
            type = 'police',
            color = '#3F51B5',
            icon = 'fas fa-shield-alt'
        },
        MEDICAL = {
            code = '10-54',
            type = 'medical',
            color = '#F44336',
            icon = 'fas fa-plus'
        },
        FIRE = {
            code = '10-70',
            type = 'fire',
            color = '#FF5722',
            icon = 'fas fa-fire'
        },
        MECHANIC = {
            code = '10-35',
            type = 'mechanic',
            color = '#FF9800',
            icon = 'fas fa-wrench'
        }
    }
}
