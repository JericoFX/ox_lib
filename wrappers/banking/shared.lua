local utils = require "wrappers.utils"

utils.createWrapper('banking', 'banking')
-- Fallback si no se puede cargar utils
lib.banking = { system = 'unknown' }
return lib.banking
