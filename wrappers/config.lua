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
        ['qs-inventory'] = 'qs-inventory',
        ['core_inventory'] = 'core_inventory',
        ['lj-inventory'] = 'lj-inventory'
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
    }
}
