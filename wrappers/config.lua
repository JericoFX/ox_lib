-- Configuración centralizada de wrappers
-- Mapeo de recursos a sus respectivos sistemas/frameworks

return {
    -- Core Frameworks
    core = {
        ['es_extended'] = 'esx_extended',
        ['qb-core'] = 'qb-core',
        ['qbx_core'] = 'qb-core',
        ['ox_core'] = 'ox_core'
    },

    -- Inventory Systems
    inventory = {
        ['ox_inventory'] = 'ox_inventory',
        ['qb-inventory'] = 'qb-inventory',
        --  ['qs-inventory'] = 'qs-inventory',
        --  ['core_inventory'] = 'core_inventory',
        --   ['lj-inventory'] = 'lj-inventory'
    },

    -- Dispatch Systems
    dispatch = {
        ['cd_dispatch'] = 'cd_dispatch',
        ['ps-dispatch'] = 'ps-dispatch',
        ['qs-dispatch'] = 'qs-dispatch',
        ['origen_police'] = 'origen_police',
        ['rcore_dispatch'] = 'rcore_dispatch'
    },

    -- Phone Systems
    phone = {
        ['qb-phone'] = 'qb-phone',
        ['qs-smartphone'] = 'qs-smartphone',
        ['lb-phone'] = 'lb-phone',
        ['renewed-phone'] = 'renewed-phone',
        ['high_phone'] = 'high_phone'
    },

    -- Banking Systems
    banking = {
        ['qb-banking'] = 'qb-banking',
        ['okokBanking'] = 'okokBanking',
        ['Renewed-Banking'] = 'Renewed-Banking',
        ['pickle_banking'] = 'pickle_banking',
        ['esx_atm'] = 'esx_atm'
    },

    -- Targeting Systems
    targeting = {
        ['bt-target'] = 'bt-target',
        ['qb-target'] = 'qb-target',
        ['qtarget']   = 'qb-target',
        ['ox_target'] = 'ox_target'
    },

    -- Fuel Systems
    fuel = {
        ['cdn-fuel']   = 'cdn-fuel',
        ['ox_fuel']    = 'ox_fuel',
        ['ps-fuel']    = 'ps-fuel',
        ['LegacyFuel'] = 'LegacyFuel',
        ['lc_fuel']    = 'lc_fuel',
        ['lj-fuel']    = 'lj-fuel'
    },

    -- Clothing Systems
    clothing = {
        ['illenium-appearance'] = 'illenium-appearance',
        ['bostra_appearance']   = 'bostra_appearance',
        ['fivem-appearance']    = 'fivem-appearance',
        ['qb-clothing']         = 'qb-clothing',
        ['esx_skin']            = 'esx_skin',
        ['clothing']            = 'clothing'
    },

    -- Housing Systems
    housing = {
        ['qb-houses']   = 'qb-houses',
        ['ox_property'] = 'ox_property',
        ['ps-housing']  = 'ps-housing'
    }
}
