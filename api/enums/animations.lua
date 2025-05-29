--[[
    Supuestamente se cargan automatico, veremos...
]]

return {
    -- Police/Security Animations
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
