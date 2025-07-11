-- Logger System for ox_lib
local logger = {}
local levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5
}

local colors = {
    DEBUG = '^6',   -- Cyan
    INFO = '^7',    -- White
    WARN = '^3',    -- Yellow
    ERROR = '^1',   -- Red
    FATAL = '^9'    -- Pink
}

-- Retrieve log level from environment
local currentLevel = GetConvar('ox:loglevel', 'INFO'):upper()

-- Format message with consistent styling
local function formatMessage(level, module, message, debugInfo)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local color = colors[level] or '^7'
    local prefix = string.format('%s[%s][%s][%s]^7', color, timestamp, level, module)
    
    if debugInfo and level == 'DEBUG' then
        local info = debug.getinfo(3, 'Sl')
        return string.format('%s %s ^5(@%s:%d)^7', prefix, message, info.short_src, info.currentline)
    end
    
    return string.format('%s %s^7', prefix, message)
end

-- Core logging function
local function log(level, module, message, ...)
    if levels[level] < levels[currentLevel] then return end
    
    local args = {...}
    if #args > 0 then
        message = string.format(message, table.unpack(args))
    end
    
    -- Handle table logging
    if type(message) == 'table' then
        message = json.encode(message, {indent = true})
    end
    
    print(formatMessage(level, module, message, level == 'DEBUG'))
end

-- Public interface
function logger.debug(module, message, ...)
    log('DEBUG', module, message, ...)
end

function logger.info(module, message, ...)
    log('INFO', module, message, ...)
end

function logger.warn(module, message, ...)
    log('WARN', module, message, ...)
end

function logger.error(module, message, ...)
    log('ERROR', module, message, ...)
end

function logger.fatal(module, message, ...)
    log('FATAL', module, message, ...)
end

-- Set log level dynamically
function logger.setLevel(level)
    level = level:upper()
    if levels[level] then
        currentLevel = level
        logger.info('LOGGER', 'Log level set to: %s', level)
    end
end

-- Get current log level
function logger.getLevel()
    return currentLevel
end

return logger
