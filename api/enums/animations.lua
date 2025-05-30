---@meta

---Animation data structure
---@class AnimationData
---@field dict string Animation dictionary name
---@field anim string Animation name

---Animation Enumerations
---@class AnimationEnums
---@field POLICE table<string, AnimationData> Police/Security animations
---@field MEDICAL table<string, AnimationData> Medical/EMS animations
---@field MECHANIC table<string, AnimationData> Mechanic animations
---@field GENERAL table<string, AnimationData> General action animations
---@field EMOTES table<string, AnimationData> Emote animations
---@field CRIMINAL table<string, AnimationData> Criminal activity animations

return {
    -- Police/Security Animations
    ---@enum PoliceAnimations
    POLICE = {
        ARREST = {
            dict = "mp_arrest_paired",
            anim = "cop_p2_back_right"
        },
        FRISK = {
            dict = "mini@prostitutes@sexlow_veh",
            anim = "low_car_sex_loop_player"
        },
        TICKET = {
            dict = "amb@code_human_police_investigate@idle_a",
            anim = "idle_b"
        },
        RADIO = {
            dict = "random@arrests",
            anim = "generic_radio_chatter"
        }
    },

    -- Medical/EMS Animations
    ---@enum MedicalAnimations
    MEDICAL = {
        CPR = {
            dict = "mini@cpr@char_a@cpr_str",
            anim = "cpr_pumpchest"
        },
        BANDAGE = {
            dict = "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@",
            anim = "plant_floor"
        },
        CHECK_PULSE = {
            dict = "amb@medic@standing@kneel@base",
            anim = "base"
        }
    },

    -- Mechanic Animations
    ---@enum MechanicAnimations
    MECHANIC = {
        REPAIR = {
            dict = "mini@repair",
            anim = "fixing_a_ped"
        },
        WELD = {
            dict = "amb@world_human_welding@male@base",
            anim = "base"
        },
        CHECK_ENGINE = {
            dict = "amb@prop_human_movie_bulb@base",
            anim = "base"
        }
    },

    -- General Actions
    ---@enum GeneralAnimations
    GENERAL = {
        DRINKING = {
            dict = "mp_player_intdrink",
            anim = "loop_bottle"
        },
        SMOKING = {
            dict = "amb@world_human_smoking@male@male_a@base",
            anim = "base"
        },
        PHONE_CALL = {
            dict = "cellphone@",
            anim = "cellphone_call_listen_base"
        },
        TYPING = {
            dict = "anim@heists@prison_heistig@typing",
            anim = "stop_typing"
        },
        CLIPBOARD = {
            dict = "missfam4",
            anim = "base"
        }
    },

    -- Emotes
    ---@enum EmoteAnimations
    EMOTES = {
        WAVE = {
            dict = "friends@",
            anim = "pickupwait"
        },
        CLAP = {
            dict = "anim@mp_player_intcelebrationmale@slow_clap",
            anim = "slow_clap"
        },
        THUMBS_UP = {
            dict = "anim@mp_player_intcelebrationmale@thumbs_up",
            anim = "thumbs_up"
        },
        MIDDLE_FINGER = {
            dict = "anim@mp_player_intcelebrationmale@finger",
            anim = "finger"
        }
    },

    -- Criminal Activities
    ---@enum CriminalAnimations
    CRIMINAL = {
        LOCKPICK = {
            dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer"
        },
        STEAL = {
            dict = "random@shop_robbery",
            anim = "robbery_action_b"
        },
        DRUGS = {
            dict = "switch@trevor@trev_scares_tramp",
            anim = "trev_scares_tramp_idle_tramp"
        }
    }
}
