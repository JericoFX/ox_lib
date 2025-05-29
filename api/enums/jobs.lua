return {
    -- Common Job Names
    NAMES = {
        UNEMPLOYED = 'unemployed',
        POLICE = 'police',
        SHERIFF = 'sheriff',
        AMBULANCE = 'ambulance',
        DOCTOR = 'doctor',
        FIRE = 'fire',
        MECHANIC = 'mechanic',
        TAXI = 'taxi',
        BUS = 'bus',
        TRUCKER = 'trucker',
        GARBAGE = 'garbage',
        FISHERMAN = 'fisherman',
        MINER = 'miner',
        LUMBERJACK = 'lumberjack',
        FARMER = 'farmer',
        HUNTER = 'hunter',
        COOK = 'cook',
        BARTENDER = 'bartender',
        SHOPKEEPER = 'shopkeeper',
        BANKER = 'banker',
        LAWYER = 'lawyer',
        JUDGE = 'judge',
        REPORTER = 'reporter',
        REALESTATE = 'realestate',
        CARDEALER = 'cardealer'
    },

    -- Job Categories
    CATEGORIES = {
        EMERGENCY = {
            'police',
            'sheriff',
            'ambulance',
            'doctor',
            'fire'
        },
        LEGAL = {
            'police',
            'sheriff',
            'lawyer',
            'judge'
        },
        MEDICAL = {
            'ambulance',
            'doctor'
        },
        SERVICE = {
            'mechanic',
            'taxi',
            'bus',
            'trucker',
            'garbage'
        },
        LABOR = {
            'fisherman',
            'miner',
            'lumberjack',
            'farmer',
            'hunter'
        },
        BUSINESS = {
            'cook',
            'bartender',
            'shopkeeper',
            'banker',
            'realestate',
            'cardealer'
        }
    },

    -- Job Grades (Common structure)
    GRADES = {
        TRAINEE = 0,
        OFFICER = 1,
        SENIOR = 2,
        SUPERVISOR = 3,
        LIEUTENANT = 4,
        CAPTAIN = 5,
        COMMANDER = 6,
        DEPUTY_CHIEF = 7,
        CHIEF = 8,
        BOSS = 9
    },

    -- Police Ranks
    POLICE_RANKS = {
        CADET = 0,
        OFFICER = 1,
        SENIOR_OFFICER = 2,
        CORPORAL = 3,
        SERGEANT = 4,
        LIEUTENANT = 5,
        CAPTAIN = 6,
        COMMANDER = 7,
        DEPUTY_CHIEF = 8,
        CHIEF = 9
    },

    -- Medical Ranks
    MEDICAL_RANKS = {
        TRAINEE = 0,
        PARAMEDIC = 1,
        SENIOR_PARAMEDIC = 2,
        NURSE = 3,
        DOCTOR = 4,
        SENIOR_DOCTOR = 5,
        SPECIALIST = 6,
        CHIEF_RESIDENT = 7,
        ATTENDING = 8,
        CHIEF = 9
    },

    -- Job Colors (for UI/blips)
    COLORS = {
        POLICE = '#3F51B5',
        SHERIFF = '#5D4037',
        AMBULANCE = '#F44336',
        DOCTOR = '#E91E63',
        FIRE = '#FF5722',
        MECHANIC = '#FF9800',
        TAXI = '#FFEB3B',
        BUS = '#4CAF50',
        TRUCKER = '#607D8B',
        GARBAGE = '#795548',
        UNEMPLOYED = '#9E9E9E'
    },

    -- Job Permissions/Flags
    PERMISSIONS = {
        ARREST = 'arrest',
        UNCUFF = 'uncuff',
        IMPOUND = 'impound',
        FINE = 'fine',
        SEARCH = 'search',
        SEIZE = 'seize',
        ESCORT = 'escort',
        HEAL = 'heal',
        REVIVE = 'revive',
        REPAIR = 'repair',
        TOWING = 'towing',
        BILLS = 'bills'
    }
}
