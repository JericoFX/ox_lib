local utils = require "wrappers.utils"

utils.createWrapper('dispatch', 'dispatch')
-- Fallback si no se puede cargar utils
lib.dispatch = { system = 'unknown' }
return lib.dispatch
