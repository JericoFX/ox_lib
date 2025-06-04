local utils = require "wrappers.utils"

utils.createWrapper('core', 'core')


-- Fallback si no se puede cargar utils
lib.core = { framework = 'unknown' }
return lib.core
