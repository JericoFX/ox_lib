local utils = require "wrappers.utils"

utils.createWrapper('inventory', 'inventory')
-- Fallback si no se puede cargar utils
lib.inventory = { system = 'unknown' }
return lib.inventory
