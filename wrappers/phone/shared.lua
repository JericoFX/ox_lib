local utils = require "wrappers.utils"

utils.createWrapper('phone', 'phone')
-- Fallback si no se puede cargar utils
lib.phone = { system = 'unknown' }
return lib.phone
